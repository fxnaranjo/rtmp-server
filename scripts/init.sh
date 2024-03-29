
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


#######################  FOLDER ACTIONS  ##########################
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

cd /videos/clubs/$clubname/$camera/$user/$streamId

echo "**********************************************************" >> init.log
echo "THE STREAMING IS BEING INITIATED" >> init.log
echo "Clubname:"$clubname >> init.log
echo "Camera:"$camera >> init.log
echo "Port1:"$port >> init.log
echo "Port2:"$port2 >> init.log
echo "Time:"$tiempo >> init.log
echo "Username:"$user >> init.log
echo "isPrivate:"$private >> init.log
echo "Description:"$description >> init.log
echo "----------------------------------------------------" >> init.log

#######################  DATABASE ACTIONS  ##########################
idCamera=$(PGPASSWORD=F020kw31xx! psql -h 10.246.0.3 -A -t -U sportprodb -d sportpro -c 'SELECT c.id from stream.camera c where c.liveport='$port)
idPlayer=$(PGPASSWORD=F020kw31xx! psql -h 10.246.0.3 -A -t -U sportprodb -d sportpro -c "SELECT p.id from stream.player p where p.username='"$user"'")

echo "idCamera:"$idCamera >> init.log
echo "idPlayer:"$idPlayer >> init.log

idLive=$(PGPASSWORD=F020kw31xx! psql -h 10.246.0.3 -A -t -U sportprodb -d sportpro -c 'SELECT l.liveid from stream.live2 l,stream.player p where l.id_player='$idPlayer' and p.id_membership <> 3 and l.id_player = p.id')

echo "idLiveUser:"$idLive >> init.log

if [ "$idLive" = "" ]
then

idLive=$(PGPASSWORD=F020kw31xx! psql -h 10.246.0.3 -A -t -U sportprodb -d sportpro -c 'SELECT l.liveid from stream.live2 l where l.id_camera='$idCamera)


fi





echo "idLiveCamera:"$idLive >> init.log
echo "----------------------------------------------------" >> init.log

if [ "$idLive" = "" ]
then

          

          echo "No live for camera or user, continue to docker start" >> init.log
          

          videoPath=/videos/clubs/$clubname/$camera/$user/$streamId
          photoPath=https://storage.googleapis.com/$clubname/$clubname-live-photo-$camera.jpg

          dockerName=$clubname-$camera-$user

          docker run --name $dockerName -p $port:1935 -p $port2:8000 -v $videoPath:/myvideos -d fxnaranjom/club1:1 >> /dev/null

           echo "Docker Created" >> init.log

          initialTime=$(date +"%m-%d-%Y %H:%M:%S");


          streamingUrl="https://streaming.sportpro.tv:"$port2"/hls/stream.m3u8"

          echo "streamingUrl:"$streamingUrl >> init.log


          PGPASSWORD=F020kw31xx! psql -h 10.246.0.3 -A -t -U sportprodb -d sportpro -c "INSERT INTO stream.live (id, id_camera, id_player,description,initialtime,playingtime,endtime,islive,isprivate,isrecorded,streamingurl,photopath,videopath)
          VALUES('"$streamId"',"$idCamera","$idPlayer",'\"$description\"','\"$initialTime\"',"$tiempo",null,true,"$private",true,'"$streamingUrl"','"$photoPath"',null)"


          PGPASSWORD=F020kw31xx! psql -h 10.246.0.3 -A -t -U sportprodb -d sportpro -c "INSERT INTO stream.live2 (liveid, id_camera, id_player,streamingurl)
          VALUES('"$streamId"',"$idCamera","$idPlayer",'"$streamingUrl"')";

          echo "Database registry created" >> init.log

          #HOUR_MINUTES=60;
          EXTRA_MINUTES=1;

          #COUNTER=$(($tiempo * $HOUR_MINUTES + $EXTRA_MINUTES));
          COUNTER=$(($tiempo + $EXTRA_MINUTES));



          minute=$( date --date='+'$COUNTER' minutes' +"%M" );
          hour=$( date --date='+'$COUNTER' minutes' +"%H" );



          #write out current crontab
          crontab -l > /rtmp-server/scripts/mycron
          #echo new cron into cron file
          echo $minute $hour" * * * sh /rtmp-server/scripts/stop.sh" $clubname $camera $user $streamId $COUNTER >> /rtmp-server/scripts/mycron
          #install new cron file
          crontab /rtmp-server/scripts/mycron
          rm /rtmp-server/scripts/mycron

          fecha=$(date);

          echo $dockerName $port $port2 $tiempo $fecha $videoPath >> /rtmp-server/scripts/active.log

          echo "STREAMING INIT SUCCESSFULLY" >> init.log

          echo "**********************************************************" >> init.log

          #COUNTERX=1;
          #minutex=$( date --date='+'$COUNTERX' minutes' +"%M" );
          #hourx=$( date --date='+'$COUNTERX' minutes' +"%H" );
          #write out current crontab
          #crontab -l > /rtmp-server/scripts/mycron
          #echo new cron into cron file
          #echo $minutex $hourx" * * * sh /rtmp-server/scripts/killDocker.sh" $clubname $camera $user $streamId >> /rtmp-server/scripts/mycron
          #install new cron file
          #crontab /rtmp-server/scripts/mycron
          #rm /rtmp-server/scripts/mycron
          

else

          fecha=$(date);
          echo $fecha "Video Rejected because user or camera is already active:"$user $streamId $idLive >> init.log
          echo "nook";


fi

