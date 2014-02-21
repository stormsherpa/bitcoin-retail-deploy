#!/bin/bash

TARGET_DIR="`pwd`/target"

VIRT_ENV="$TARGET_DIR/virtualenv"

mkdir -p "$TARGET_DIR"

if [ ! -d $VIRT_ENV ]; then
    virtualenv "$VIRT_ENV" || exit 1
fi

"$VIRT_ENV/bin/pip" install -r requirements.txt

cd ../coinexchange-django

"$VIRT_ENV/bin/python" setup.py install

"$VIRT_ENV/bin/pip" list

