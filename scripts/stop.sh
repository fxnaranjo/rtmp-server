# new stop script
echo Shut down streaming Container:$1

clubname=$1
camera=$2
user=$3
record=$4
tiempo=$5




if [ "$tiempo" = "" ]
then
	tiempo=40
    initialTime=$(PGPASSWORD=F020kw31xx! psql -h 10.70.208.3 -A -t -U sportprodb -d sportpro -c "SELECT l.initialtime from stream.live l where l.id='"$record"'")
    actualTime=$(date +"%Y-%m-%d %H:%M:%S");

    echo "InitialTime:"$initialTime
    echo "actualTime:"$actualTime

    StartDate=$(date -u -d "$initialTime" +"%s")
    FinalDate=$(date -u -d "$actualTime" +"%s")
    MINUTES=$(( ($FinalDate - $StartDate) / 60 ))
  
    tiempo=$MINUTES

    echo "Tiempo:"$tiempo

    if [ $tiempo -eq 0 ]
    then
        tiempo=1
    fi
    
fi

tiempo=$(($tiempo-2))

dockerName=$clubname-$camera-$user

isValid=$(docker stop $dockerName)
docker rm $dockerName

crontab -l > /rtmp-server/scripts/mycron

sed -i '/'$record'/d' /rtmp-server/scripts/mycron

crontab /rtmp-server/scripts/mycron

rm -fr /rtmp-server/scripts/mycron


echo Valid:$isValid

if [ "$isValid" != "" ]
then



echo "***************************************************************"

if [ ! -d /library/$clubname ]

then

     mkdir -p /library/$clubname

fi



cd /videos/clubs/$clubname/$camera/$user/$record

numFiles=$(ls -l | wc -l)

echo "NumFiles:"$numFiles

theFile="myfile"

hora=0
sobrante=0

if [ $tiempo -gt 60 ]
then
   hora=1
   sobrante=$(($tiempo-60))
   tiempo=$sobrante
fi

STRLENGTH=$(echo -n $tiempo | wc -m)

if [ $STRLENGTH -eq 1 ]
then
   tiempo="0"$tiempo
else
 echo "Time is right"

fi

mycase="normal"

snipTime="0$hora:"$tiempo":00"

echo "SnipTime:"$snipTime

if [ $numFiles -ne 2 ]
then
    echo "This video have multiple files" > fix.log
    ls -ltr >> fix.log
    theFile=$(du -sh * | sort -rh | head -1 | awk '{print $2}')
    echo $theFile >> fix.log
    echo $snipTime >> fix.log
    mv $theFile auxVideo.flv
    rm -fr stream-*
    ffmpeg -i auxVideo.flv -map 0 -ss 00:00:00 -to $snipTime -c copy thevideo2.mp4
    theFile=thevideo2.mp4
    mycase="excp"
else
    theFile=$(ls)
fi

echo ".............THE FILE............"
echo $theFile

if [ "$theFile" != "" ]
then

     extension=".flv"

     extension2=".mp4"

     extension3=".jpg"

     videoTime=$(date +"%d%m%Y%H%M%S")

     finalVideo=$user-$videoTime$extension

     newVideo=$user-$videoTime$extension2

     newPhoto=$user-$videoTime$extension3


     mv /videos/clubs/$clubname/$camera/$user/$record/$theFile  /videos/clubs/$clubname/$camera/$user/$record/$finalVideo
      
     echo "Flag:"$mycase

     if [ "$mycase" = "normal" ];
     then
	 echo "Normal processing"
         ffmpeg -i $finalVideo -vcodec copy $newVideo
     else
	 echo "changing video name" >> fix.log    
	 echo "Just change name, mp4 already created"
	 cp $finalVideo $newVideo
     fi

     ffmpeg -i $finalVideo -r 1 -ss 00:00:10 -vf scale=320:180 -t 1 $newPhoto

     rm -fr $finalVideo

     cp $newVideo /library/$clubname/
     cp $newPhoto /library/$clubname/

    rm -fr $newVideo
    rm -fr $newPhoto

     cd /videos/clubs/$clubname/$camera/$user

 #    rm -fr $record

     googleCloudStorage="https://storage.googleapis.com/"$clubname"/"$newVideo;

     googleCloudStorage2="https://storage.googleapis.com/"$clubname"/"$newPhoto;

     endTime=$(date +"%m-%d-%Y %H:%M:%S");

     PGPASSWORD=F020kw31xx! psql -h 10.70.208.3 -A -t -U sportprodb -d sportpro -c "UPDATE stream.live set islive = false , videopath='"$googleCloudStorage"', photopath='"$googleCloudStorage2"', endtime='\"$endTime\"' where STREAM.live.id ='"$record"'"

     PGPASSWORD=F020kw31xx! psql -h 10.70.208.3 -A -t -U sportprodb -d sportpro -c "DELETE FROM stream.live2 where STREAM.live2.liveid ='"$record"'"


     sed -i '/'$dockerName'/d' /rtmp-server/scripts/active.log

else
    echo "No video available"
    cd /videos/clubs/$clubname/$camera/$user
    rm -fr $record
    PGPASSWORD=F020kw31xx! psql -h 10.70.208.3 -A -t -U sportprodb -d sportpro -c "DELETE FROM stream.live where STREAM.live.id ='"$record"'"
    PGPASSWORD=F020kw31xx! psql -h 10.70.208.3 -A -t -U sportprodb -d sportpro -c "DELETE FROM stream.live2 where STREAM.live2.liveid ='"$record"'"
fi

else
    echo "No container available"
    cd /videos/clubs/$clubname/$camera/$user
    rm -fr $record
    PGPASSWORD=F020kw31xx! psql -h 10.70.208.3 -A -t -U sportprodb -d sportpro -c "DELETE FROM stream.live where STREAM.live.id ='"$record"'"
    PGPASSWORD=F020kw31xx! psql -h 10.70.208.3 -A -t -U sportprodb -d sportpro -c "DELETE FROM stream.live2 where STREAM.live2.liveid ='"$record"'"
fi
