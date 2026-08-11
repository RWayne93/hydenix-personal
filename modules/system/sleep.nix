{ ... }:

{
  # Disable all system sleep states for now (suspend/hibernate/hybrid).
  systemd.sleep.settings.Sleep = {
    AllowSuspend = false;
    AllowHibernation = false;
    AllowSuspendThenHibernate = false;
    AllowHybridSleep = false;
  };

  # Prevent logind from triggering sleep on idle/lid events.
  services.logind.settings.Login = {
    IdleAction = "ignore";
    HandleLidSwitch = "ignore";
    HandleLidSwitchExternalPower = "ignore";
    HandleLidSwitchDocked = "ignore";
  };
}
