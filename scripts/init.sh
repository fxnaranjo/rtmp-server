clubname=$1
camera=$2
port=$3
port2=$4
tiempo=$5
user=$6

if [ ! -d /videos/clubs/$clubname/$camera/$user ] 

then

     mkdir -p /videos/clubs/$clubname/$camera/$user
     chmod -R 777 /videos/clubs/$clubname/$camera/$user

fi

videoPath=/videos/clubs/$clubname/$camera/$user

dockerName=$clubname-$camera-$user

docker run --name $dockerName -p $port:1935 -p $port2:8000 -v $videoPath:/myvideos -d fxnaranjom/club1:1


HOUR_MINUTES=60;
EXTRA_MINUTES=5;

COUNTER=$(($tiempo * $HOUR_MINUTES + $EXTRA_MINUTES));

echo Duration:$COUNTER;


minute=$( date --date='+'$COUNTER' minutes' +"%M" );
hour=$( date --date='+'$COUNTER' minutes' +"%H" );


echo Minute:$minute;
echo Hour:$hour;


#write out current crontab
crontab -l > /rtmp-server/scripts/mycron
#echo new cron into cron file
echo $minute $hour" * * * sh /rtmp-server/scripts/stop.sh" $dockerName $clubname $camera $user" >> /rtmp-server/scripts/stop.log" >> /rtmp-server/scripts/mycron
#install new cron file
crontab /rtmp-server/scripts/mycron
rm /rtmp-server/scripts/mycron

fecha=$(date);

echo $dockerName $port $port2 $tiempo $fecha $videoPath >> /rtmp-server/scripts/active.log
