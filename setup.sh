#!/usr/bin/env bash

set -e

show_usage() {
  echo "Usage: $(basename $0) takes exactly 1 argument (install | uninstall)"
}

if [ $# -ne 1 ]
then
  show_usage
  exit 1
fi

check_env() {
  if [[ -z "${RALPM_TMP_DIR}" ]]; then
    echo "RALPM_TMP_DIR is not set"
    exit 1
  
  elif [[ -z "${RALPM_PKG_INSTALL_DIR}" ]]; then
    echo "RALPM_PKG_INSTALL_DIR is not set"
    exit 1
  
  elif [[ -z "${RALPM_PKG_BIN_DIR}" ]]; then
    echo "RALPM_PKG_BIN_DIR is not set"
    exit 1
  fi
}

install() {
  wget https://github.com/skylot/jadx/releases/download/v1.4.5/jadx-1.4.5.zip -O $RALPM_TMP_DIR/jadx-1.4.5.zip
  unzip $RALPM_TMP_DIR/jadx-1.4.5.zip -d $RALPM_PKG_INSTALL_DIR/jadx/

  wget https://github.com/adoptium/temurin18-binaries/releases/download/jdk-18.0.2%2B9/OpenJDK18U-jre_x64_linux_hotspot_18.0.2_9.tar.gz -O $RALPM_TMP_DIR/OpenJDK18U-jre_x64_linux_hotspot_18.0.2_9.tar.gz
  tar xf $RALPM_TMP_DIR/OpenJDK18U-jre_x64_linux_hotspot_18.0.2_9.tar.gz -C $RALPM_PKG_INSTALL_DIR

  echo "#!/usr/bin/env sh" > $RALPM_PKG_BIN_DIR/jadx-gui
  echo "export PATH=$RALPM_PKG_INSTALL_DIR/jdk-18.0.2+9-jre/bin/:\$PATH" >> $RALPM_PKG_BIN_DIR/jadx-gui
  echo "export JAVA_HOME=$RALPM_PKG_INSTALL_DIR/jdk-18.0.2+9-jre/" >> $RALPM_PKG_BIN_DIR/jadx-gui
  echo "$RALPM_PKG_INSTALL_DIR/jadx/bin/jadx-gui \"\$@\"" >> $RALPM_PKG_BIN_DIR/jadx-gui
  chmod +x $RALPM_PKG_BIN_DIR/jadx-gui
}

uninstall() {
  rm $RALPM_PKG_BIN_DIR/jadx-gui
  rm -rf $RALPM_PKG_INSTALL_DIR/jadx
  rm -rf $RALPM_PKG_INSTALL_DIR/jdk-18.0.2+9-jre
}

run() {
  if [[ "$1" == "install" ]]; then 
    install
  elif [[ "$1" == "uninstall" ]]; then 
    uninstall
  else
    show_usage
  fi
}

check_env
run $1