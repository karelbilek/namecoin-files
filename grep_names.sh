#!/usr/bin/env bash
$NAMECOIN_PATH/namecoind name_filter '^fb/*' | grep 'name' | sed 's/[[:space:]]\+"name" : "fb\///' | sed 's/",//'
