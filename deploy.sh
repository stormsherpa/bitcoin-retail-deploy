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

LOGS_DIR="`pwd`/logs"

VIRT_ENV="$TARGET_DIR/virtualenv"

mkdir -p "$TARGET_DIR"

if [ ! -d $VIRT_ENV ]; then
    virtualenv "$VIRT_ENV" || exit 1
fi

"$VIRT_ENV/bin/pip" install -r requirements.txt

"$VIRT_ENV/bin/pip" install --upgrade https://github.com/skruger/bitcoin-python/archive/master.zip
"$VIRT_ENV/bin/pip" install --upgrade https://github.com/skruger/coinbase_python/archive/master.zip

pushd "$COINEXCHANGE_SRC"

"$VIRT_ENV/bin/python" setup.py install

popd

CONFIG_DIR="../coinexchange-config"

if [ -d "$CONFIG_DIR" ]; then
    pushd "$CONFIG_DIR"
        "$VIRT_ENV/bin/python" setup.py install
    popd
fi

echo "Installed packages..."
"$VIRT_ENV/bin/pip" list

pushd "$TARGET_DIR"
mkdir -p "$TARGET_DIR/static_files"
"$VIRT_ENV/bin/coinexchange-manage.py" collectstatic -c --noinput

if [ ! -d "bitcoin-0.8.6-linux" ]; then
    wget "http://downloads.sourceforge.net/project/bitcoin/Bitcoin/bitcoin-0.8.6/bitcoin-0.8.6-linux.tar.gz?r=http%3A%2F%2Fsourceforge.net%2Fprojects%2Fbitcoin%2F&ts=1393306292&use_mirror=softlayer-dal" -O bitcoin-0.8.6-linux.tar.gz
    tar zxf bitcoin-0.8.6-linux.tar.gz
fi

if [ ! -d "rabbitmq_server-3.2.3" ]; then
    wget "http://www.rabbitmq.com/releases/rabbitmq-server/v3.2.3/rabbitmq-server-generic-unix-3.2.3.tar.gz" -O rabbitmq-server-generic-unix-3.2.3.tar.gz
    tar zxf rabbitmq-server-generic-unix-3.2.3.tar.gz
fi

pushd rabbitmq_server-3.2.3
    
popd

popd

echo "Installing crontab"
NOW=`date`

cat > local.crontab  << EOF
# Installed: $NOW
# Min Hr Dom  Mo Dow
*/5 * * * *  "$VIRT_ENV/bin//coinexchange-manage.py" process_coinbase_payout >> "$LOGS_DIR/coinbase_payout.log"

EOF

crontab local.crontab

echo "Installed crontab from local.crontab:"
crontab -l

