

echo Shut down streaming Container:$1

#docker stop $1

#docker rm $1

echo "**************************************************************"

if [ ! -d /library/$2 ]

then

     #mkdir -p /library/$2

fi



#crontab -l > /rtmp-server/scripts/mycron

#sed -i '/'$1'/d' /rtmp-server/scripts/mycron

#crontab /rtmp-server/scripts/mycron

#rm -fr /rtmp-server/scripts/mycron

theFile=$(ls)

videoTime=$(date +"%H:%M")

echo $theFile

echo $videoTime

#mv /videos/clubs/$2/$3/$4/$thefile  /videos/clubs/$2/$3/$4/$thefile

#/library/$2


#sed -i '/'$1'/d' /rtmp-server/scripts/active.log
