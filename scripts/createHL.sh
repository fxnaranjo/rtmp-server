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


videoTime=$(date +"%d%m%Y%H%M%S");

streamId=$user-$clubname-$videoTime;



newVideo="/library/"$clubname"/"$highlight



#######################  DATABASE ACTIONS  ##########################
idCamera=$(PGPASSWORD=acetv2022 psql -h 10.70.208.3 -A -t -U acetvdev -d sportpro -c 'SELECT c.id from stream.camera c where c.liveport='$port)
idPlayer=$(PGPASSWORD=acetv2022 psql -h 10.70.208.3 -A -t -U acetvdev -d sportpro -c "SELECT p.id from stream.player p where p.username='"$user"'")

echo idCamera:$idCamera;
echo idPlayer:$idPlayer;

initialTime=$(date +"%m-%d-%Y %H:%M:%S");

ffmpeg -i $videoPath -map 0 -ss $startHL -to $stopHL -c copy $newVideo

cd /library/$clubname

extension3=".jpg"

newPhoto=$user-$videoTime$extension3

ffmpeg -i $newVideo -r 1 -ss 00:01:00 -vf scale=320:180 -t 1 $newPhoto

googleCloudStorage="https://storage.googleapis.com/"$clubname"/"$highlight;
 googleCloudStorage2="https://storage.googleapis.com/"$clubname"/"$newPhoto;


PGPASSWORD=acetv2022 psql -h 10.70.208.3 -A -t -U acetvdev -d sportpro -c "INSERT INTO stream.live (id, id_camera, id_player,description,initialtime,playingtime,endtime,ishighlight,isprivate,isrecorded,videopath,photopath,islive)
 VALUES('"$streamId"',"$idCamera","$idPlayer",'\"$description\"','\"$initialTime\"',"$tiempo",null,true,"$private",true,'"$googleCloudStorage"','"$googleCloudStorage2"',false)"








