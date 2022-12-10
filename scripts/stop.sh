# new stop script
echo Shut down streaming Container:$1

clubname=$1
camera=$2
user=$3
record=$4
tiempo=$5

cd /videos/clubs/$clubname/$camera/$user/$record

 myTime=$(date +"%m-%d-%Y %H:%M:%S");

echo "********************************************************************************************************************************" >> stop.log
        echo "Fecha:"$myTime >> stop.log
        echo "Record:"$record >> stop.log
        echo "Tiempo:"$tiempo >> stop.log
        echo "..........INITIAL DIRECTORY FILES......................................................" >> stop.log
            ls -ltrh >> stop.log
        echo "......................................................................................." >> stop.log

#######################  DATABASE ACTIONS  ##########################

idLive=$(PGPASSWORD=F020kw31xx! psql -h 10.246.0.3 -A -t -U sportprodb -d sportpro -c "SELECT l.liveid from stream.live2 l where l.liveid='"$record"'")

echo "idLive:"$idLive >> stop.log

if [ "$idLive" != "" ]
then

        

        if [ "$tiempo" = "" ]
        then
            echo "Stop Type: manualStop" >> stop.log
            
            initialTime=$(PGPASSWORD=F020kw31xx! psql -h 10.246.0.3 -A -t -U sportprodb -d sportpro -c "SELECT l.initialtime from stream.live l where l.id='"$record"'")
            actualTime=$(date +"%Y-%m-%d %H:%M:%S");

            echo "InitialTime:"$initialTime >> stop.log
            echo "actualTime:"$actualTime >> stop.log

            StartDate=$(date -u -d "$initialTime" +"%s")
            FinalDate=$(date -u -d "$actualTime" +"%s")
            MINUTES=$(( ($FinalDate - $StartDate) / 60 ))
        
            tiempo=$MINUTES


        else
            echo "Stop Type: normalStop" >> stop.log
        fi


        echo "Tiempo de grabacion:"$tiempo >> stop.log



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

        numFiles=$(ls -1 *.flv 2>/dev/null | wc -l)

         echo "Number of FLV Files:"$numFiles >> stop.log
       

        theFile="myfile"

     
        mycase="normal"

    

        if [ $numFiles -gt 1 ]
        then
            echo "This video have multiple flv files" > fix.log
            echo "This video have multiple flv files" >> stop.log
            ls -ltr >> fix.log
            theFile=$(du -sh * | sort -rh | head -1 | awk '{print $2}')
            echo "The largest file is:"$theFile >> stop.log
            echo $theFile >> fix.log
            mv $theFile auxVideo.flv
            rm -fr stream-*
            ffmpeg -i auxVideo.flv -vcodec copy thevideo2.mp4
            rm -fr auxVideo.flv

            #################################################################################3
            #a=1;
            #for file in `ls -tr *.flv`; do
                #mv $file $a.flv
                #echo "file '"$a.flv"'" >> inputs.txt
                #a=$((a+1))	
            #done
            #ffmpeg -f concat -i inputs.txt -c copy thevideo2.mp4
            #rm -fr *.flv
            #################################################################################

            theFile=thevideo2.mp4
            mycase="excp"
        else
            theFile=$(ls stream*)
            if [ $numFiles -eq 1 ]
            then
                 echo "This video have only one flv file" >> stop.log
            fi
           
        fi

        echo ".............THE FILE............" >> stop.log
        echo $theFile >> stop.log

        if [ "$theFile" != "" ] && [ $numFiles -ne 0 ]
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

            cp $newVideo /library/$clubname/

            echo "Creating VIDEO DONE" >> stop.log
            echo "....................................................................................." >> stop.log
            ls -ltrh >> stop.log
            echo "....................................................................................." >> stop.log

            ########################### DATABASE ACTIONS #####################################################

            googleCloudStorage="https://storage.googleapis.com/"$clubname"/"$newVideo;

            googleCloudStorage2="https://storage.googleapis.com/"$clubname"/"$newPhoto;

            endTime=$(date +"%m-%d-%Y %H:%M:%S");

            PGPASSWORD=F020kw31xx! psql -h 10.246.0.3 -A -t -U sportprodb -d sportpro -c "UPDATE stream.live set islive = false , videopath='"$googleCloudStorage"', photopath='"$googleCloudStorage2"', endtime='\"$endTime\"' where STREAM.live.id ='"$record"'"

            echo "TABLE LIVE UPDATED" >> stop.log

            PGPASSWORD=F020kw31xx! psql -h 10.246.0.3 -A -t -U sportprodb -d sportpro -c "DELETE FROM stream.live2 where STREAM.live2.liveid ='"$record"'"

            echo "TABLE LIVE2 RECORD DELETED" >> stop.log

            ########################### DATABASE ACTIONS #####################################################

            sed -i '/'$dockerName'/d' /rtmp-server/scripts/active.log

            echo "Creating Photo:"$newPhoto >> stop.log
            ffmpeg -i $finalVideo -r 1 -ss 00:00:10 -vf scale=320:180 -t 1 $newPhoto

            echo "Creating PHOTO DONE" >> stop.log
            echo "....................................................................................." >> stop.log
            ls -ltrh >> stop.log
            echo "....................................................................................." >> stop.log
            
            rm -fr $finalVideo

            
            cp $newPhoto /library/$clubname/

            rm -fr $newVideo
            rm -fr $newPhoto

            echo "VERIFIYING API SERVER............" >> stop.log

            apiServer=$(ps -e | grep node | awk '{print $4}')


            if [ "$apiServer" != "node" ]
            then
                cd /api/apistream/
                npm start server.js &
                cd /videos/clubs/$clubname/$camera/$user/$record
                echo "THE API SERVER WAS STOPPED......RUNNING NOW" >> stop.log
            else
                echo "THE API SERVER WAS RUNNING" >> stop.log

            fi


            echo "FINISHED STOP SCRIPT PROCESSING" >> stop.log
            echo "*************************************************************************************************" >> stop.log

        else
            echo "No video available" >> stop.log
            echo "No Connection" >> cameraError.log
            PGPASSWORD=F020kw31xx! psql -h 10.246.0.3 -A -t -U sportprodb -d sportpro -c "DELETE FROM stream.live where STREAM.live.id ='"$record"'"
            PGPASSWORD=F020kw31xx! psql -h 10.246.0.3 -A -t -U sportprodb -d sportpro -c "DELETE FROM stream.live2 where STREAM.live2.liveid ='"$record"'"
        fi

        else
            echo "No container available" >> stop.log
            PGPASSWORD=F020kw31xx! psql -h 10.246.0.3 -A -t -U sportprodb -d sportpro -c "DELETE FROM stream.live2 where STREAM.live2.liveid ='"$record"'"
        fi
else

        echo "No hay registro el tabla live 2" >> stop.log
        echo "*************************************************************************************************" >> stop.log
        dockerName=$clubname-$camera-$user
        isValid=$(docker stop $dockerName)
        docker rm $dockerName
        echo "RecordID:"$record >> stop.log

fi


