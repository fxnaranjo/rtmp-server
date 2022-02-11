clubname=$1
camera=$2
port=$3
port2=$4
tiempo=$5
user=$6

if [ ! -d /server/clubs/$clubname/$camera/$user ] 

then

     mkdir -p /server/clubs/$clubname/$camera/$user
     chmod -R 777 /server/clubs/$clubname/$camera/$user

fi

videoPath=/server/clubs/$clubname/$camera/$user

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
crontab -u apache -l > /server/nms-template/mycron
#echo new cron into cron file
echo $minute $hour" * * * sh /server/nms-template/activeStreams/stop.sh" $dockerName $clubname $camera $user" >> /server/nms-template/activeStreams/stop.log" >> /server/nms-template/mycron
#install new cron file
crontab -u apache /server/nms-template/mycron
rm /server/nms-template/mycron

fecha=$(date);

echo $dockerName $port $port2 $tiempo $fecha $videoPath >> /server/nms-template/activeStreams/active.log
