#!/bin/bash

apps="uWSGI coinbase_recv_callbacks pay_merchant_batches"

for a in "$apps"; do
    echo Performing $1 on $a
    target/virtualenv/bin/supervisorctl $1 $a
done
