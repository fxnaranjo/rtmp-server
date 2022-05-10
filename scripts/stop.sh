
echo Shut down streaming Container:$1

clubname=$1
camera=$2
user=$3
record=$4

dockerName=$clubname-$camera-$user

isValid=$(docker stop $dockerName)

crontab -l > /rtmp-server/scripts/mycron

sed -i '/'$record'/d' /rtmp-server/scripts/mycron

crontab /rtmp-server/scripts/mycron

rm -fr /rtmp-server/scripts/mycron


echo Valid:$isValid

if [ "$isValid" != "" ]; then

docker rm $dockerName

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

     videoTime=$(date +"%d%m%Y%H%M%S")

     finalVideo=$user-$videoTime$extension

     newVideo=$user-$videoTime$extension2

     mv /videos/clubs/$clubname/$camera/$user/$record/$theFile  /videos/clubs/$clubname/$camera/$user/$record/$finalVideo

     ffmpeg -i $finalVideo -vcodec copy $newVideo

     rm -fr $finalVideo

     cp $newVideo /library/$clubname/

     rm -fr $newVideo

     cd /videos/clubs/$clubname/$camera/$user

     rm -fr $record

     googleCloudStorage="https://storage.googleapis.com/"$clubname"/"$newVideo;

     endTime=$(date +"%m-%d-%Y %H:%M:%S");

     PGPASSWORD=acetv2022 psql -h 10.70.208.3 -A -t -U acetvdev -d sportpro -c "UPDATE stream.live set islive = false , videopath='"$googleCloudStorage"', endtime='\"$endTime\"' where STREAM.live.id ='"$record"'"


     sed -i '/'$dockerName'/d' /rtmp-server/scripts/active.log

else
    echo "No video available"
    PGPASSWORD=acetv2022 psql -h 10.70.208.3 -A -t -U acetvdev -d sportpro -c "DELETE FROM stream.live where STREAM.live.id ='"$record"'"
fi

else
    echo "No container available"
fi
