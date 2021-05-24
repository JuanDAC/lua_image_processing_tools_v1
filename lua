#!/bin/sh

LUAROCKS_SYSCONFDIR='/usr/local/etc/luarocks' exec '/usr/local/bin/lua' -e 'package.path="/root/.luarocks/share/lua/5.4/?.lua;/root/.luarocks/share/lua/5.4/?/init.lua;/usr/local/share/lua/5.4/?.lua;/usr/local/share/lua/5.4/?/init.lua;"..package.path;package.cpath="/root/.luarocks/lib/lua/5.4/?.so;/usr/local/lib/lua/5.4/?.so;"..package.cpath' $([ "$*" ] || echo -i) "$@"
