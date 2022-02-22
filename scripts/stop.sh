

echo Shut down streaming Container:$1

docker stop $1

docker rm $1

echo "**************************************************************"

if [ ! -d /library/$2 ]

then

     mkdir -p /library/$2

fi



crontab -l > /rtmp-server/scripts/mycron

sed -i '/'$1'/d' /rtmp-server/scripts/mycron

crontab /rtmp-server/scripts/mycron

rm -fr /rtmp-server/scripts/mycron

cd /videos/clubs/$2/$3/$4

theFile=$(ls)

extension=".flv"

extension2=".mp4"

videoTime=$(date +"%d%m%Y%H%M%S")

finalVideo=$4-$videoTime$extension

newVideo=$4-$videoTime$extension2

mv /videos/clubs/$2/$3/$4/$theFile  /videos/clubs/$2/$3/$4/$finalVideo

ffmpeg -i $finalVideo -vcodec copy $newVideo

rm -fr $finalVideo

cp $newVideo /library/$2/

rm -fr $newVideo

googleCloudStorage="https://storage.googleapis.com/jaimepinto-squash/"+$newVideo;

PGPASSWORD=acetv2022 psql -h 10.70.208.3 -A -t -U acetvdev -d sportpro -c "UPDATE stream.live set islive = false , videopath='"$googleCloudStorage"' where STREAM.live.id ='"$5"'"


sed -i '/'$1'/d' /rtmp-server/scripts/active.log
