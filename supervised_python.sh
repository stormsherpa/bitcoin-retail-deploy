#!/bin/bash

apps="uWSGI bitcoind_worker poll_pos_transactions"

for a in "$apps"; do
    echo Performing $1 on $a
    target/virtualenv/bin/supervisorctl $1 $a
done
