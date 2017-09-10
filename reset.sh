#! /bin/bash

if [[ -e ~/Documents/sdcc_grp_buy/tmp/pids/websocket_rails.pid ]]; then
	bundle exec rake websocket_rails:stop_server
	bundle exec rake websocket_rails:start_server
else
	bundle exec rake websocket_rails:start_server
fi



