clubname=$1
highlight=$2
port=$3
startHL=$4
stopHL=$5
user=$6
private=$7
description=$8
videoPath=$9
categoria=$10

tiempo=1
cd /library/$clubname

echo "************************************************************************************************************************" >> hl.log
echo $clubname >> hl.log
echo $highlight >> hl.log
echo $port >> hl.log
echo $tiempo >> hl.log
echo $startHL >> hl.log
echo $stopHL >> hl.log
echo $user >> hl.log
echo $private >> hl.log
echo $description >> hl.log
echo $videoPath >> hl.log
echo $categoria >> hl.log


extension1=".mp4"
extension2=".jpg"

videoTime=$(date +"%d%m%Y%H%M%S");

streamId=$user-$clubname-$videoTime;

newVideo="/library/"$clubname"/"$highlight$extension1
newPhoto=$highlight$extension2


echo "---------------------------------------------" >> hl.log
echo "New Video:"$newVideo >> hl.log
echo "New Photo:"$newPhoto >> hl.log

#######################  DATABASE ACTIONS  ##########################
idCamera=$(PGPASSWORD=F020kw31xx! psql -h 10.246.0.3 -A -t -U sportprodb -d sportpro -c 'SELECT c.id from stream.camera c where c.liveport='$port)
idPlayer=$(PGPASSWORD=F020kw31xx! psql -h 10.246.0.3 -A -t -U sportprodb -d sportpro -c "SELECT p.id from stream.player p where p.username='"$user"'")

echo idCamera:$idCamera >> hl.log
echo idPlayer:$idPlayer >> hl.log


ffmpeg -i $videoPath -map 0 -ss $startHL -to $stopHL -c copy $newVideo

echo "Video created" >> hl.log



ffmpeg -i $newVideo -r 1 -ss 00:00:01 -vf scale=320:180 -t 1 $newPhoto

echo "Photo created" >> hl.log

googleCloudStorage="https://storage.googleapis.com/"$clubname"/"$highlight$extension1;
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

PGPASSWORD=F020kw31xx! psql -h 10.246.0.3 -A -t -U sportprodb -d sportpro -c "INSERT INTO stream.live (id, id_camera, id_player,description,initialtime,playingtime,endtime,ishighlight,isprivate,isrecorded,videopath,photopath,islive,id_highlightcat)
 VALUES('"$streamId"',"$idCamera","$idPlayer",'\"$description\"','\"$initialTime\"',"$tiempo",'\"$endTime\"',true,"$private",true,'"$googleCloudStorage"','"$googleCloudStorage2"',false,$categoria)"

echo "Record ID:"$streamId >> hl.log
echo "Record Initial Time:"$initialTime >> hl.log


echo "************************************************************************************************************************" >> hl.log




