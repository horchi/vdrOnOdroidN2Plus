#!/bin/bash

# fix slow IR (at least with logitech harmony)

/usr/bin/ir-keytable -D 375 -P 80
/usr/bin/ir-ctl -t 10000

