#!/usr/bin/env python3
import os, sys, re, time, pexpect

# ---- Your xfreerdp command (exactly what you run) ----
XFREERDP_CMD = [
    "/run/current-system/sw/bin/xfreerdp",
    "/home/nixie/Downloads/cARMY.rdpw",
    "/gateway:type:arm",
    "/sec:aad",
    "/azure:use-tenantid:off,ad:login.microsoftonline.us",
    "/smartcard",
    "/size:1920x1080",
    "/monitors:0",
    "/timeout:60000",
    "/wm-class:cArmy-Dev-RDP",
]
extra_args = os.environ.get("XFREERDP_EXTRA_ARGS")
if extra_args:
    XFREERDP_CMD.extend(extra_args.split())

# ---- Patterns FreeRDP prints ----
BROWSE_TO_RE = re.compile(r"^Browse to:\s*(\S+)$")
PASTE_PROMPT_RE = re.compile(r"^Paste redirect URL here:\s*$")
NATIVECLIENT_RE = re.compile(
    r"^https://login\.microsoftonline\.com/common/oauth2/nativeclient\?code="
)

# ---- Selenium setup ----
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.chrome.service import Service
from shutil import which


def build_chrome_driver() -> webdriver.Chrome:
    """Create and return a Chrome/Chromium WebDriver with sane defaults."""
    chrome_opts = Options()
    if os.environ.get("HEADLESS") == "1":
        chrome_opts.add_argument("--headless=new")
    chrome_opts.add_argument("--incognito")
    chrome_opts.add_argument("--no-first-run")
    chrome_opts.add_argument("--no-default-browser-check")
    chrome_opts.add_argument("--disable-extensions")
    chrome_opts.add_argument("--disable-popup-blocking")
    chrome_log = os.environ.get("CHROME_LOG_FILE")
    if chrome_log:
        chrome_opts.add_argument("--enable-logging")
        chrome_opts.add_argument("--v=1")
        chrome_opts.add_argument(f"--log-file={chrome_log}")

    extra_args = os.environ.get("CHROME_EXTRA_ARGS")
    if extra_args:
        for arg in extra_args.split():
            chrome_opts.add_argument(arg)

    # Detect Chrome/Chromium binary
    chrome_binary = os.environ.get("CHROME_BINARY")
    if not chrome_binary:
        for candidate in [
            "google-chrome-stable",
            "google-chrome",
            "chromium",
            "chromium-browser",
        ]:
            path = which(candidate)
            if path:
                chrome_binary = path
                break
    if chrome_binary:
        chrome_opts.binary_location = chrome_binary

    try:
        return webdriver.Chrome(options=chrome_opts)
    except TypeError:
        return webdriver.Chrome(service=Service(), options=chrome_opts)


def get_redirect_for(
    authorize_url: str, driver: webdriver.Chrome, timeout_sec: int = 600
) -> str:
    """
    Navigate the provided authorize URL with the given driver and wait until it
    lands on the nativeclient redirect. Return that final URL.
    """
    driver.get(authorize_url)
    start = time.time()
    while True:
        url = driver.current_url
        if NATIVECLIENT_RE.match(url):
            return url
        if time.time() - start > timeout_sec:
            raise TimeoutError(
                "Timed out waiting for nativeclient redirect (finish login/MFA?)"
            )
        time.sleep(1)


def main():
    print("[*] Starting xfreerdp…")
    driver = None
    keep_browser = os.environ.get("KEEP_BROWSER") == "1"
    close_after_redirect = os.environ.get("CLOSE_BROWSER_AFTER_REDIRECT", "1") == "1"
    stop_log_after_redirect = os.environ.get("STOP_LOG_AFTER_REDIRECT", "1") == "1"
    stop_log_after_rounds = int(os.environ.get("STOP_LOG_AFTER_ROUNDS", "2"))
    try:
        child = pexpect.spawn(
            XFREERDP_CMD[0], XFREERDP_CMD[1:], encoding="utf-8", timeout=1200
        )
        child.logfile_read = sys.stdout  # mirror xfreerdp output
        child.logfile_send = sys.stdout

        # We’ll read line-by-line and react to prompts as they appear.
        # Strategy: whenever we see "Browse to:", grab URL, fetch redirect via Selenium;
        # when we see "Paste redirect URL here:", immediately paste the last captured redirect.
        pending_redirect = None
        awaiting_paste = False
        redirect_rounds_completed = 0
        close_after_rounds = int(os.environ.get("CLOSE_BROWSER_AFTER_ROUNDS", "2"))

        last_output = time.time()
        while True:
            try:
                line = child.readline().rstrip("\r\n")
            except pexpect.exceptions.TIMEOUT:
                if time.time() - last_output > 20:
                    print("[*] Still waiting for xfreerdp output...")
                    last_output = time.time()
                continue
            except pexpect.exceptions.EOF:
                print("[*] xfreerdp exited.")
                print(
                    f"[*] exitstatus={child.exitstatus} signal={child.signalstatus}"
                )
                return

            if not line:
                # Keep running; FreeRDP can go quiet between prompts.
                time.sleep(0.1)
                continue
            last_output = time.time()

            # Match "Browse to:"
            m = BROWSE_TO_RE.match(line)
            if m:
                auth_url = m.group(1)
                print(f"[*] Launching browser for auth: {auth_url}")
                try:
                    if driver is None:
                        driver = build_chrome_driver()
                    pending_redirect = get_redirect_for(auth_url, driver)
                    print("[*] Got redirect URL from browser.")
                    if awaiting_paste and pending_redirect:
                        print("[*] Sending redirect URL to FreeRDP.")
                        child.sendline(pending_redirect)
                        pending_redirect = None
                        awaiting_paste = False
                        redirect_rounds_completed += 1
                        if (
                            stop_log_after_redirect
                            and redirect_rounds_completed >= stop_log_after_rounds
                        ):
                            print("[*] Stopping log capture after redirect rounds.")
                            child.logfile_read = None
                            child.logfile_send = None
                        if (
                            (not keep_browser)
                            and redirect_rounds_completed >= close_after_rounds
                            and driver is not None
                        ):
                            try:
                                driver.quit()
                            except Exception:
                                pass
                            driver = None
                        print(
                            "[*] Closed browser after obtaining required redirect(s)."
                        )
                except Exception as e:
                    print(
                        f"[!] Failed to obtain redirect for above URL: {e}",
                        file=sys.stderr,
                    )
                    child.terminate(force=True)
                    sys.exit(2)
                continue

            # Match "Paste redirect URL here:"
            if PASTE_PROMPT_RE.match(line):
                if not pending_redirect:
                    awaiting_paste = True
                    continue
                print("[*] Sending redirect URL to FreeRDP.")
                child.sendline(pending_redirect)
                pending_redirect = None
                redirect_rounds_completed += 1
                if (
                    stop_log_after_redirect
                    and redirect_rounds_completed >= stop_log_after_rounds
                ):
                    print("[*] Stopping log capture after redirect rounds.")
                    child.logfile_read = None
                    child.logfile_send = None
                if (
                    driver is not None
                    and not keep_browser
                    and close_after_redirect
                    and redirect_rounds_completed >= close_after_rounds
                ):
                    try:
                        driver.quit()
                    except Exception:
                        pass
                    driver = None
                continue

            # If framebuffer/devices logs appear, we just keep streaming until RDP connects.
    finally:
        if driver is not None and not keep_browser:
            try:
                driver.quit()
            except Exception:
                pass


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("\n[!] Interrupted by user.")
        sys.exit(130)
    except Exception as e:
        print(f"[!] Error: {e}", file=sys.stderr)
        sys.exit(1)

