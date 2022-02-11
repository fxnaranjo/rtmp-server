

echo Shut down streaming Container:$1

docker stop $1

docker rm $1

echo "**************************************************************"

if [ ! -d /library/$2 ]

then

     mkdir -p /library/$2

fi



crontab -u apache -l > /server/nms-template/activeStreams/mycron

sed -i '/'$1'/d' /server/nms-template/activeStreams/mycron

crontab -u apache /server/nms-template/activeStreams/mycron

rm -fr /server/nms-template/activeStreams/mycron


mv /server/clubs/$2/$3/$4/* /library/$2


sed -i '/'$1'/d' /server/nms-template/activeStreams/active.log
