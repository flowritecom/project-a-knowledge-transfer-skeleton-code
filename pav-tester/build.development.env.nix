let
  sources = import ./nix/sources.nix;
  pkgs = import sources.nixpkgs { };
  APP_NAME = "pav-tester";
  APP_ENV = "development";
  STAGE = "development";
  VAR_STAGE = "developmentLocal";
in with pkgs;
mkShell {
  name = "node-env";
  buildInputs = [
    nodejs-12_x
    jq
    docker
    openssl
    unzip
    zip
    terraform
    direnv
    awscli2
    skopeo
    amazon-ecr-credential-helper
  ];

  shellHook = ''
    unset SOURCE_DATE_EPOCH
    cat <<EOT > .envrc
    export APP_ENV=${APP_ENV}
    export APP_NAME=${APP_NAME}
    export AWS_ACCESS_KEY_ID=${builtins.getEnv "AWS_ACCESS_KEY_ID"}
    export AWS_ACCOUNT_ID=${builtins.getEnv "AWS_ACCOUNT_ID"}
    export AWS_DEFAULT_REGION=${builtins.getEnv "AWS_DEFAULT_REGION"}
    export AWS_SECRET_ACCESS_KEY=${builtins.getEnv "AWS_SECRET_ACCESS_KEY"}
    export STAGE=${STAGE}
    export VAR_STAGE=${VAR_STAGE}
    EOT
    cat <<EOF > .env
    APP_ENV=${APP_ENV}
    APP_NAME=${APP_NAME}
    AWS_ACCESS_KEY_ID=${builtins.getEnv "AWS_ACCESS_KEY_ID"}
    AWS_ACCOUNT_ID=${builtins.getEnv "AWS_ACCOUNT_ID"}
    AWS_DEFAULT_REGION=${builtins.getEnv "AWS_DEFAULT_REGION"}
    AWS_SECRET_ACCESS_KEY=${builtins.getEnv "AWS_SECRET_ACCESS_KEY"}
    STAGE=${STAGE}
    VAR_STAGE=${VAR_STAGE}
    EOF
  '';
}
