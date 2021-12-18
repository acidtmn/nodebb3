#!/bin/ash
shutdown() {
  pkill -f redis-server
  echo "Redis stoped"
  [ ! -e /etc/nodebb/config.json ] && [ -e /opt/nodebb/config.json ] && cp /opt/nodebb/config.json /etc/nodebb/config.json
  echo "Stopped"
  exit 143;
}

term_handler() {
  echo "SIGTERM received"
  pkill -f node
  echo "NodeBB stoped"
  shutdown
}

set_timezone() {
  if [ ! -z $timezone ]
  then
    echo "Setting timezone"
    apk add tzdata;
    cp /usr/share/zoneinfo/"$timezone" /etc/localtime;
    echo $timezone > /etc/timezone;
    apk del tzdata;
  fi
}

trap term_handler SIGTERM

echo "Starting"
[ -e /var/lib/redis/appendonly.aof ] && chown redis /var/lib/redis/appendonly.aof
redis-server /etc/redis.conf
[ -e /etc/nodebb/config.json ] && rm -f /opt/nodebb/config.json && ln -s /etc/nodebb/config.json /opt/nodebb/config.json
cd /opt/nodebb/
[ -e /etc/nodebb/config.json ] && yes n | node nodebb upgrade
set_timezone
node app.js & wait ${!}
echo "NodeBB died"
shutdown
