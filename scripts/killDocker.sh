clubname=$1
camera=$2
user=$3
record=$4

cd /videos/clubs/$clubname/$camera/$user/$streamId

numFiles=$(ls -1 *.flv 2>/dev/null | wc -l)

if [ $numFiles -eq 0 ]
then




    dockerName=$clubname-$camera-$user
    isValid=$(docker stop $dockerName)
    docker rm $dockerName

    crontab -l > /rtmp-server/scripts/mycron

    sed -i '/'$record'/d' /rtmp-server/scripts/mycron

    crontab /rtmp-server/scripts/mycron

    rm -fr /rtmp-server/scripts/mycron

    PGPASSWORD=F020kw31xx! psql -h 10.70.208.3 -A -t -U sportprodb -d sportpro -c "DELETE FROM stream.live where STREAM.live.id ='"$record"'"
    PGPASSWORD=F020kw31xx! psql -h 10.70.208.3 -A -t -U sportprodb -d sportpro -c "DELETE FROM stream.live2 where STREAM.live2.liveid ='"$record"'"

fi


