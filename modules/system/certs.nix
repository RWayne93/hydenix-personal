{
  security.pki.certificateFiles = [
    ./certs/root.crt
    ./certs/dod-sw-ca-82.pem
    ./certs/dod-root-ca-6-bundle.pem
  ];

  environment.etc."docker/certs.d/registry.levelup.cce.af.mil/ca.crt".source =
    ./certs/levelup-cce-docker-ca-bundle.pem;

  environment.etc."docker/certs.d/code.levelup.cce.af.mil/ca.crt".source =
    ./certs/levelup-cce-docker-ca-bundle.pem;
}
