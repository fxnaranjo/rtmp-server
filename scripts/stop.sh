# new stop script
echo Shut down streaming Container:$1

clubname=$1
camera=$2
user=$3
record=$4
tiempo=$5

cd /videos/clubs/$clubname/$camera/$user/$record

numFilesVal=$(ls -l | wc -l)

 myTime=$(date +"%m-%d-%Y %H:%M:%S");

echo "*************************************************************************************************" >> stop.log
        echo "Fecha:"$myTime >> stop.log
        echo "Record:"$record >> stop.log
        echo "Tiempo:"$tiempo >> stop.log
        echo "..........INITIAL DIRECTORY FILES......................................................" >> stop.log
            ls -ltrh >> stop.log
        echo "......................................................................................." >> stop.log

#######################  DATABASE ACTIONS  ##########################

idLive=$(PGPASSWORD=F020kw31xx! psql -h 10.70.208.3 -A -t -U sportprodb -d sportpro -c "SELECT l.liveid from stream.live2 l where l.liveid='"$record"'")

echo "idLive:"$idLive >> stop.log

if [ "$idLive" != "" ]
then

        

        if [ "$tiempo" = "" ]
        then
            echo "Stop Type: manualStop" >> stop.log
            tiempo=40
            initialTime=$(PGPASSWORD=F020kw31xx! psql -h 10.70.208.3 -A -t -U sportprodb -d sportpro -c "SELECT l.initialtime from stream.live l where l.id='"$record"'")
            actualTime=$(date +"%Y-%m-%d %H:%M:%S");

            echo "InitialTime:"$initialTime >> stop.log
            echo "actualTime:"$actualTime >> stop.log

            StartDate=$(date -u -d "$initialTime" +"%s")
            FinalDate=$(date -u -d "$actualTime" +"%s")
            MINUTES=$(( ($FinalDate - $StartDate) / 60 ))
        
            tiempo=$MINUTES

            echo "Tiempo:"$tiempo

            if [ $tiempo -eq 0 ]
            then
                tiempo=1
            fi
        else
            echo "Stop Type: normalStop" >> stop.log
        fi


        echo "Tiempo despues de calculo:"$tiempo >> stop.log



        dockerName=$clubname-$camera-$user

        isValid=$(docker stop $dockerName)
        docker rm $dockerName

        crontab -l > /rtmp-server/scripts/mycron

        sed -i '/'$record'/d' /rtmp-server/scripts/mycron

        crontab /rtmp-server/scripts/mycron

        rm -fr /rtmp-server/scripts/mycron


        echo "Valid:"$isValid >> stop.log

        if [ "$isValid" != "" ]
        then


        numFiles=$(ls -l | wc -l)

        echo "NumFiles:"$numFiles >> stop.log

        theFile="myfile"

        hora=0
        sobrante=0

        if [ $numFiles -ne 4 ] && [ $tiempo -gt 2 ]
        then
        tiempo=$(($tiempo-2))
        fi

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

        echo "SnipTime:"$snipTime >> stop.log

        if [ $numFiles -ne 4 ]
        then
            echo "This video have multiple flv files" > fix.log
            echo "This video have multiple flv files" >> stop.log
            ls -ltr >> fix.log
            theFile=$(du -sh * | sort -rh | head -1 | awk '{print $2}')
            echo $theFile >> fix.log
            echo $snipTime >> fix.log
            mv $theFile auxVideo.flv
            rm -fr stream-*
            ffmpeg -i auxVideo.flv -map 0 -ss 00:00:00 -to $snipTime -c copy thevideo2.mp4
            rm -fr auxVideo.flv
            theFile=thevideo2.mp4
            mycase="excp"
        else
            theFile=$(ls stream*)
            echo "This video have only one flv file" >> stop.log
        fi

        echo ".............THE FILE............" >> stop.log
        echo $theFile >> stop.log

        if [ "$theFile" != "" ] && [ $numFilesVal -ne 2 ]
        then

            extension=".flv"

            extension2=".mp4"

            extension3=".jpg"

            myRecordId=$(echo $record | awk -F- '{print $4}')

            echo "myRecordId:"$myRecordId >> stop.log

            finalVideo=$user-$myRecordId$extension

            newVideo=$user-$myRecordId$extension2

            newPhoto=$user-$myRecordId$extension3


            mv /videos/clubs/$clubname/$camera/$user/$record/$theFile  /videos/clubs/$clubname/$camera/$user/$record/$finalVideo
            
            echo "Flag:"$mycase >> stop.log

            if [ "$mycase" = "normal" ]
            then
            echo "Normal processing" >> stop.log
                ffmpeg -i $finalVideo -vcodec copy $newVideo
            else
            echo "changing video name" >> fix.log    
            echo "Just change name, mp4 already created" >> stop.log
            cp $finalVideo $newVideo
            fi

            echo "Creating Photo:"$newPhoto >> stop.log
            ffmpeg -i $finalVideo -r 1 -ss 00:00:10 -vf scale=320:180 -t 1 $newPhoto


            echo "....................................................................................." >> stop.log
            ls -ltrh >> stop.log
            echo "....................................................................................." >> stop.log
            
            rm -fr $finalVideo

            cp $newVideo /library/$clubname/
            cp $newPhoto /library/$clubname/

            rm -fr $newVideo
            rm -fr $newPhoto


            googleCloudStorage="https://storage.googleapis.com/"$clubname"/"$newVideo;

            googleCloudStorage2="https://storage.googleapis.com/"$clubname"/"$newPhoto;

            endTime=$(date +"%m-%d-%Y %H:%M:%S");

            PGPASSWORD=F020kw31xx! psql -h 10.70.208.3 -A -t -U sportprodb -d sportpro -c "UPDATE stream.live set islive = false , videopath='"$googleCloudStorage"', photopath='"$googleCloudStorage2"', endtime='\"$endTime\"' where STREAM.live.id ='"$record"'"

            echo "TABLE LIVE UPDATED" >> stop.log

            PGPASSWORD=F020kw31xx! psql -h 10.70.208.3 -A -t -U sportprodb -d sportpro -c "DELETE FROM stream.live2 where STREAM.live2.liveid ='"$record"'"

            echo "TABLE LIVE2 RECORD DELETED" >> stop.log


            sed -i '/'$dockerName'/d' /rtmp-server/scripts/active.log

            echo "FINISHED STOP SCRIPT PROCESSING" >> stop.log
            echo "*************************************************************************************************" >> stop.log

        else
            echo "No video available" >> stop.log
            PGPASSWORD=F020kw31xx! psql -h 10.70.208.3 -A -t -U sportprodb -d sportpro -c "DELETE FROM stream.live where STREAM.live.id ='"$record"'"
            PGPASSWORD=F020kw31xx! psql -h 10.70.208.3 -A -t -U sportprodb -d sportpro -c "DELETE FROM stream.live2 where STREAM.live2.liveid ='"$record"'"
        fi

        else
            echo "No container available" >> stop.log
            PGPASSWORD=F020kw31xx! psql -h 10.70.208.3 -A -t -U sportprodb -d sportpro -c "DELETE FROM stream.live where STREAM.live.id ='"$record"'"
            PGPASSWORD=F020kw31xx! psql -h 10.70.208.3 -A -t -U sportprodb -d sportpro -c "DELETE FROM stream.live2 where STREAM.live2.liveid ='"$record"'"
        fi
else

        echo "Stop Type: manualStop" >> stop.log
        echo "No hay registro el tabla live 2" >> stop.log
        echo "*************************************************************************************************" >> stop.log

fi


