#!/bin/bash

SCRIPTPATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
KSPATH=$(sed 's/\/scripts//g' <<< $SCRIPTPATH)
KSENV="${HOME}/.KlipperScreen-env"

install_packages()
{
    echo "Update package data"
    sudo apt update

    echo "Installing package dependencies"
    sudo apt install -y \
        xserver-xorg-video-fbturbo \
        xinit \
        xinput \
        x11-xserver-utils \
        python3-gi \
        python3-gi-cairo \
        gir1.2-gtk-3.0
}

create_virtualenv()
{
    echo "Creating virtual environment"
    [ ! -d ${PYTHONDIR} ] && virtualenv -p /usr/bin/python3 ${PYTHONDIR}

    ${PYTHONDIR}/bin/pip install -r ${SRCDIR}/scripts/KlipperScreen-requirements.txt
}

install_systemd_service()
{
    echo "Installing KlipperScreen unit file"

    SERVICE=$(<$SCRIPTPATH/KlipperScreen.service)
    KSPATH_ESC=$(sed "s/\//\\\\\//g" <<< $KSPATH)
    KSENV_ESC=$(sed "s/\//\\\\\//g" <<< $KSENV)

    SERVICE=$(sed "s/KS_ENV/$KSENV_ESC/g" <<< $SERVICE)
    SERVICE=$(sed "s/KS_DIR/$KSPATH_ESC/g" <<< $SERVICE)

    echo "$SERVICE" | sudo tee /etc/systemd/system/KlipperScreen.service > /dev/null
    sudo systemctl daemon-reload
}


install_packages
create_virtualenv
install_systemd_service
