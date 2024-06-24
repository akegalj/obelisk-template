{ system ? builtins.currentSystem
, obelisk ? import ./.obelisk/impl {
    inherit system;
    iosSdkVersion = "13.2";

    # You must accept the Android Software Development Kit License Agreement at
    # https://developer.android.com/studio/terms in order to build Android apps.
    # Uncomment and set this to `true` to indicate your acceptance:
    config.android_sdk.accept_license = true;

    # In order to use Let's Encrypt for HTTPS deployments you must accept
    # their terms of service at https://letsencrypt.org/repository/.
    # Uncomment and set this to `true` to indicate your acceptance:
    # terms.security.acme.acceptTerms = false;
  }
}:
with obelisk;
project ./. ({ pkgs, ... }: {
  android.applicationId = "systems.obsidian.obelisk.examples.minimal";
  android.displayName = "Obelisk Minimal Example";
  ios.bundleIdentifier = "systems.obsidian.obelisk.examples.minimal";
  ios.bundleName = "Obelisk Minimal Example";

# TODO: see https://github.com/jonathanknowles/obelisk-reflex-servant-example/blob/master/default.nix
#   packages = {
#   };
  overrides = self: super: {
     servant = self.callHackageDirect {
       pkg = "servant";
       ver = "0.20.1";
       sha256 = "wpvDsVJeq+ETvjMkCDyrZEjjYpeZO9Mddw7YAlEi1Wk=";
     } {};
     servant-client = self.callHackageDirect {
       pkg = "servant-client";
       ver = "0.20";
       sha256 = "IajPlRqWP/zKmYU2oxnrIHre2DoAkYB5rW6fIyApYkc=";
     } {};
     servant-client-core = self.callHackageDirect {
       pkg = "servant-client-core";
       ver = "0.20";
       sha256 = "KOW1AkFxtDnY73ONrTnvmsYUNATSbVq3/Arnv28P5Ho=";
     } {};
     servant-server = self.callHackageDirect {
       pkg = "servant-server";
       ver = "0.20";
       sha256 = "krUEfIbGyqkCAX8ahRJCGnR4d45k1FbTz7NaXEbV0mc=";
     } {};
  };
})
