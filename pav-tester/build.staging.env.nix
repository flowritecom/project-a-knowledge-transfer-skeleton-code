let
  sources = import ./nix/sources.nix;
  pkgs = import sources.nixpkgs { };
  g = x: "export ${x}=${builtins.getEnv x}";
  p = x: "${x}=${builtins.getEnv x}";
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
    direnv
    awscli
    skopeo
    amazon-ecr-credential-helper
  ];

  AWS_ACCESS_KEY_ID = builtins.getEnv "AWS_ACCESS_KEY_ID";
  AWS_SECRET_ACCESS_KEY = builtins.getEnv "AWS_SECRET_ACCESS_KEY";
  AWS_ACCOUNT_ID = builtins.getEnv "AWS_ACCOUNT_ID";
  AWS_DEFAULT_REGION = builtins.getEnv "AWS_DEFAULT_REGION";
  STAGE = builtins.getEnv "STAGE";
  VAR_STAGE = builtins.getEnv "VAR_STAGE";
  APP_NAME = builtins.getEnv "APP_NAME";
  APP_ENV = builtins.getEnv "APP_ENV";

  shellHook = ''
    unset SOURCE_DATE_EPOCH
    cat <<EOT > .envrc
    ${g "APP_NAME"}
    ${g "APP_ENV"}
    ${g "AWS_ACCESS_KEY_ID"}
    ${g "AWS_ACCOUNT_ID"}
    ${g "AWS_DEFAULT_REGION"}
    ${g "AWS_SECRET_ACCESS_KEY"}
    ${g "STAGE"}
    ${g "VAR_STAGE"}
    EOT
    cat <<EOF > .env
    ${g "APP_NAME"}
    ${g "APP_ENV"}
    ${p "AWS_ACCESS_KEY_ID"}
    ${p "AWS_ACCOUNT_ID"}
    ${p "AWS_DEFAULT_REGION"}
    ${p "AWS_SECRET_ACCESS_KEY"}
    ${p "STAGE"}
    ${p "VAR_STAGE"}
    EOF
  '';
}
