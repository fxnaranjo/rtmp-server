# new stop script
echo Shut down streaming Container:$1

clubname=$1
camera=$2
user=$3
record=$4

dockerName=$clubname-$camera-$user

isValid=$(docker stop $dockerName)
docker rm $dockerName

crontab -l > /rtmp-server/scripts/mycron

sed -i '/'$record'/d' /rtmp-server/scripts/mycron

crontab /rtmp-server/scripts/mycron

rm -fr /rtmp-server/scripts/mycron


echo Valid:$isValid

if [ "$isValid" != "" ]; then



echo "***************************************************************"

if [ ! -d /library/$clubname ]

then

     mkdir -p /library/$clubname

fi



cd /videos/clubs/$clubname/$camera/$user/$record

theFile=$(ls)

if [ "$theFile" != "" ]; then

     extension=".flv"

     extension2=".mp4"

     extension3=".jpg"

     videoTime=$(date +"%d%m%Y%H%M%S")

     finalVideo=$user-$videoTime$extension

     newVideo=$user-$videoTime$extension2

     newPhoto=$user-$videoTime$extension3

#     newVideoWlogo=$user-$videoTime$extension2

     mv /videos/clubs/$clubname/$camera/$user/$record/$theFile  /videos/clubs/$clubname/$camera/$user/$record/$finalVideo

     ffmpeg -i $finalVideo -vcodec copy $newVideo

 #    ffmpeg -i $newVideo -i logo.png -filter_complex "overlay=1:1" $newVideoWlogo

     ffmpeg -i $finalVideo -r 1 -ss 00:01:00 -vf scale=320:180 -t 1 $newPhoto

     rm -fr $finalVideo

     cp $newVideo /library/$clubname/

     cp $newPhoto /library/$clubname/

   #  cp $newVideoWlogo /library/$clubname/

     rm -fr $newVideo

     rm -fr $newPhoto

  #   rm -fr $newVideoWlogo

     cd /videos/clubs/$clubname/$camera/$user

     rm -fr $record

     googleCloudStorage="https://storage.googleapis.com/"$clubname"/"$newVideo;

     googleCloudStorage2="https://storage.googleapis.com/"$clubname"/"$newPhoto;

     endTime=$(date +"%m-%d-%Y %H:%M:%S");

     PGPASSWORD=acetv2022 psql -h 10.70.208.3 -A -t -U acetvdev -d sportpro -c "UPDATE stream.live set islive = false , videopath='"$googleCloudStorage"', photopath='"$googleCloudStorage2"', endtime='\"$endTime\"' where STREAM.live.id ='"$record"'"

     PGPASSWORD=acetv2022 psql -h 10.70.208.3 -A -t -U acetvdev -d sportpro -c "DELETE FROM stream.live2 where STREAM.live2.liveid ='"$record"'"

     sed -i '/'$dockerName'/d' /rtmp-server/scripts/active.log

else
    echo "No video available"
    cd /videos/clubs/$clubname/$camera/$user
    rm -fr $record
    PGPASSWORD=acetv2022 psql -h 10.70.208.3 -A -t -U acetvdev -d sportpro -c "DELETE FROM stream.live where STREAM.live.id ='"$record"'"
    PGPASSWORD=acetv2022 psql -h 10.70.208.3 -A -t -U acetvdev -d sportpro -c "DELETE FROM stream.live2 where STREAM.live2.liveid ='"$record"'"
fi

else
     echo "No container available"
     cd /videos/clubs/$clubname/$camera/$user
     rm -fr $record
     PGPASSWORD=acetv2022 psql -h 10.70.208.3 -A -t -U acetvdev -d sportpro -c "DELETE FROM stream.live where STREAM.live.id ='"$record"'"
     PGPASSWORD=acetv2022 psql -h 10.70.208.3 -A -t -U acetvdev -d sportpro -c "DELETE FROM stream.live2 where STREAM.live2.liveid ='"$record"'"
fi
