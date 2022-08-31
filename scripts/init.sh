
clubname=$1
camera=$2
port=$3
port2=$4
tiempo=$5
user=$6
private=$7
description=$8

videoTime=$(date +"%d%m%Y%H%M%S");

streamId=$user-$clubname-$videoTime;

if [ ! -d /videos/clubs/$clubname/$camera/$user ] 
then

     mkdir -p /videos/clubs/$clubname/$camera/$user
     chmod -R 777 /videos/clubs/$clubname/$camera/$user

fi


if [ ! -d /videos/clubs/$clubname/$camera/$user/$streamId ]
then

     mkdir -p /videos/clubs/$clubname/$camera/$user/$streamId
     chmod -R 777 /videos/clubs/$clubname/$camera/$user/$streamId

fi





videoPath=/videos/clubs/$clubname/$camera/$user/$streamId
photoPath=https://storage.googleapis.com/$clubname/$clubname-live-photo-$camera.jpg

dockerName=$clubname-$camera-$user

docker run --name $dockerName -p $port:1935 -p $port2:8000 -v $videoPath:/myvideos -d fxnaranjom/club1:1



#######################  DATABASE ACTIONS  ##########################
idCamera=$(PGPASSWORD=acetv2022 psql -h 10.70.208.3 -A -t -U acetvdev -d sportpro -c 'SELECT c.id from stream.camera c where c.liveport='$port)
idPlayer=$(PGPASSWORD=acetv2022 psql -h 10.70.208.3 -A -t -U acetvdev -d sportpro -c "SELECT p.id from stream.player p where p.username='"$user"'")

echo idCamera:$idCamera;
echo idPlayer:$idPlayer;

initialTime=$(date +"%m-%d-%Y %H:%M:%S");

streamingUrl="https://streaming.sportpro.tv:"$port2"/hls/stream.m3u8"


PGPASSWORD=acetv2022 psql -h 10.70.208.3 -A -t -U acetvdev -d sportpro -c "INSERT INTO stream.live (id, id_camera, id_player,description,initialtime,playingtime,endtime,islive,isprivate,isrecorded,streamingurl,photopath,videopath)
 VALUES('"$streamId"',"$idCamera","$idPlayer",'\"$description\"','\"$initialTime\"',"$tiempo",null,true,"$private",true,'"$streamingUrl"','"$photoPath"',null)"


PGPASSWORD=acetv2022 psql -h 10.70.208.3 -A -t -U acetvdev -d sportpro -c "INSERT INTO stream.live2 (liveid, id_camera, id_player,streamingurl)
VALUES('"$streamId"',"$idCamera","$idPlayer",'"$streamingUrl"')";


#HOUR_MINUTES=60;
EXTRA_MINUTES=1;

#COUNTER=$(($tiempo * $HOUR_MINUTES + $EXTRA_MINUTES));
COUNTER=$(($tiempo + $EXTRA_MINUTES));

echo Duration:$COUNTER;


minute=$( date --date='+'$COUNTER' minutes' +"%M" );
hour=$( date --date='+'$COUNTER' minutes' +"%H" );


echo Minute:$minute;
echo Hour:$hour;


#write out current crontab
crontab -l > /rtmp-server/scripts/mycron
#echo new cron into cron file
echo $minute $hour" * * * sh /rtmp-server/scripts/stop.sh" $clubname $camera $user $streamId $COUNTER >> /rtmp-server/scripts/mycron
#install new cron file
crontab /rtmp-server/scripts/mycron
rm /rtmp-server/scripts/mycron

fecha=$(date);

echo $dockerName $port $port2 $tiempo $fecha $videoPath >> /rtmp-server/scripts/active.log
