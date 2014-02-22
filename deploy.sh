#!/bin/bash -xe

if [ "x$COINEXCHANGE_SRC" = "x" ]; then
    echo "Using default location for coinexchange source."
    COINEXCHANGE_SRC="../coinexchange-django"
fi

echo Coinexchange application location: $COINEXCHANGE_SRC

if [ ! -f "$COINEXCHANGE_SRC/setup.py" ]; then
    echo "Directory '$COINEXCHANGE_SRC' does not contain setup.py and is invalid."
    exit 1
fi

TARGET_DIR="`pwd`/target"

VIRT_ENV="$TARGET_DIR/virtualenv"

mkdir -p "$TARGET_DIR"

if [ ! -d $VIRT_ENV ]; then
    virtualenv "$VIRT_ENV" || exit 1
fi

"$VIRT_ENV/bin/pip" install -r requirements.txt

"$VIRT_ENV/bin/pip" install https://github.com/skruger/bitcoin-python/archive/master.zip

cd "$COINEXCHANGE_SRC"

"$VIRT_ENV/bin/python" setup.py install

"$VIRT_ENV/bin/pip" list

