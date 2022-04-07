
echo Shut down streaming Container:$1

clubname=$1
camera=$2
user=$3
record=$4

dockerName=$clubname-$camera-$user

docker stop $dockerName

docker rm $dockerName

echo "**************************************************************"

if [ ! -d /library/$clubname ]

then

     mkdir -p /library/$clubname

fi



crontab -l > /rtmp-server/scripts/mycron

sed -i '/'$dockerName'/d' /rtmp-server/scripts/mycron

crontab /rtmp-server/scripts/mycron

rm -fr /rtmp-server/scripts/mycron

cd /videos/clubs/$clubname/$camera/$user/$record

theFile=$(ls)

extension=".flv"

extension2=".mp4"

videoTime=$(date +"%d%m%Y%H%M%S")

finalVideo=$4-$videoTime$extension

newVideo=$4-$videoTime$extension2

mv /videos/clubs/$clubname/$camera/$user/$record/$theFile  /videos/clubs/$clubname/$camera/$user/$record/$finalVideo

ffmpeg -i $finalVideo -vcodec copy $newVideo

rm -fr $finalVideo

cp $newVideo /library/$clubname/

rm -fr $newVideo

cd /videos/clubs/$clubname/$camera/$user

rm -fr $record

googleCloudStorage="https://storage.googleapis.com/"$clubname"/"$newVideo;

endTime=$(date +"%m-%d-%Y %H:%M:%S");

PGPASSWORD=acetv2022 psql -h 10.70.208.3 -A -t -U acetvdev -d sportpro -c "UPDATE stream.live set islive = false , videopath='"$googleCloudStorage"', endtime='\"$endTime\"' where STREAM.live.id ='"$5"'"


sed -i '/'$dockerName'/d' /rtmp-server/scripts/active.log
