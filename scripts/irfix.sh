#!/bin/bash

# fix slow IR (at least with logitech harmony)

ir-keytable -D 375 -P 80
ir-ctl -t 10000
