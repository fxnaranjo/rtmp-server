


rm -fr /videos/clubs/*

echo "" > /rtmp-server/scripts/active.log

echo "" > /rtmp-server/scripts/aux

crontab /rtmp-server/scripts/aux

rm -fr /rtmp-server/scripts/aux

echo "DONE CLEAN"
