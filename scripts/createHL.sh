clubname=$1
highlight=$2
camera=$3
port=$4
port2=$5
tiempo=$6
startHL=$7
stopHL=$8
user=$9
private=$10
description=$11
videoPath=$12

cd /library/$clubname

echo "*****************************************************************************************" >> hl.log
echo $clubname >> hl.log
echo $highlight >> hl.log
echo $camera >> hl.log
echo $port >> hl.log
echo $port2 >> hl.log
echo $tiempo >> hl.log
echo $startHL >> hl.log
echo $stopHL >> hl.log
echo $user >> hl.log
echo $private >> hl.log
echo $description >> hl.log
echo $videoPath >> hl.log

videoTime=$(date +"%d%m%Y%H%M%S");

streamId=$user-$clubname-$videoTime;

newVideo="/library/"$clubname"/"$highlight



#######################  DATABASE ACTIONS  ##########################
idCamera=$(PGPASSWORD=F020kw31xx! psql -h 10.70.208.3 -A -t -U sportprodb -d sportpro -c 'SELECT c.id from stream.camera c where c.liveport='$port)
idPlayer=$(PGPASSWORD=F020kw31xx! psql -h 10.70.208.3 -A -t -U sportprodb -d sportpro -c "SELECT p.id from stream.player p where p.username='"$user"'")

echo idCamera:$idCamera >> hl.log
echo idPlayer:$idPlayer >> hl.log


ffmpeg -i $videoPath -map 0 -ss $startHL -to $stopHL -c copy $newVideo

echo "Video created" >> hl.log


extension3=".jpg"

newPhoto=$user-$videoTime$extension3

ffmpeg -i $newVideo -r 1 -ss 00:00:01 -vf scale=320:180 -t 1 $newPhoto

echo "Photo created" >> hl.log

googleCloudStorage="https://storage.googleapis.com/"$clubname"/"$highlight;
googleCloudStorage2="https://storage.googleapis.com/"$clubname"/"$newPhoto;


initialTime=$(date +"%m-%d-%Y %H:%M:%S");

StartDate=$(date -u -d "$startHL" +"%s")
FinalDate=$(date -u -d "$stopHL" +"%s")
HLtime=$(date -u -d "0 $FinalDate sec - $StartDate sec" +"%H:%M:%S")


a=$(date -u -d "$HLtime" +"%H");
b=$(date -u -d "$HLtime" +"%M");
c=$(date -u -d "$HLtime" +"%S");

now=$(date --iso-8601=seconds)
future=$(date -d "$now + $b minutes" --iso-8601=seconds)


future2=$(date -d "$future + $c seconds" --iso-8601=seconds)

endTime=$( date -d "$future2" +"%m-%d-%Y %H:%M:%S");

PGPASSWORD=F020kw31xx! psql -h 10.70.208.3 -A -t -U sportprodb -d sportpro -c "INSERT INTO stream.live (id, id_camera, id_player,description,initialtime,playingtime,endtime,ishighlight,isprivate,isrecorded,videopath,photopath,islive)
 VALUES('"$streamId"',"$idCamera","$idPlayer",'\"$description\"','\"$initialTime\"',"$tiempo",'\"$endTime\"',true,"$private",true,'"$googleCloudStorage"','"$googleCloudStorage2"',false)"

echo "Record ID:"$streamId >> hl.log
echo "Record Initial Time:"$initialTime >> hl.log


echo "*****************************************************************************************" >> hl.log




