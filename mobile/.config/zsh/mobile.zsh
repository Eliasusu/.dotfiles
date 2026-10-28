# mobile.zsh — perfil mobile (React Native / Android): SDK, emulador y aliases
# Solo existe si corriste `./install.sh mobile`.

# --- Android SDK -------------------------------------------------------------------
# El SDK vive fuera de ~/.config para no mezclar datos con configs versionadas.
if [[ -d "$HOME/Android/sdk" ]]; then
  export ANDROID_HOME="$HOME/Android/sdk"
  export ANDROID_SDK_ROOT="$ANDROID_HOME"
  export PATH="$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator:$ANDROID_HOME/cmdline-tools/latest/bin:$PATH"
fi

# --- Aliases ----------------------------------------------------------------------
if [[ -n "$ANDROID_HOME" ]]; then
  # Listar/arrancar AVDs (emuladores)
  alias avd-list='$ANDROID_HOME/emulator/emulator -list-avds'
  alias avd-start='$ANDROID_HOME/emulator/emulator -avd'
  # Actualizar componentes del SDK
  alias sdk-up='sdkmanager --update'
  alias sdk-list='sdkmanager --list_installed'
fi

# React Native: usar pnpm donde exista
alias rna='npx react-native run-android'
