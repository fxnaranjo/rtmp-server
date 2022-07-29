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


videoTime=$(date +"%d%m%Y%H%M%S");

streamId=$user-$clubname-$videoTime;





videoPath=/videos/clubs/$clubname/$camera/$user/$streamId

dockerName=$clubname-$camera-$user

docker run --name $dockerName -p $port:1935 -p $port2:8000 -v $videoPath:/myvideos -d fxnaranjom/club1:1



#######################  DATABASE ACTIONS  ##########################
idCamera=$(PGPASSWORD=acetv2022 psql -h 10.70.208.3 -A -t -U acetvdev -d sportpro -c 'SELECT c.id from stream.camera c where c.liveport='$port)
idPlayer=$(PGPASSWORD=acetv2022 psql -h 10.70.208.3 -A -t -U acetvdev -d sportpro -c "SELECT p.id from stream.player p where p.username='"$user"'")

echo idCamera:$idCamera;
echo idPlayer:$idPlayer;

initialTime=$(date +"%m-%d-%Y %H:%M:%S");

googleCloudStorage="https://storage.googleapis.com/"$clubname"/"$highlight;


PGPASSWORD=acetv2022 psql -h 10.70.208.3 -A -t -U acetvdev -d sportpro -c "INSERT INTO stream.live (id, id_camera, id_player,description,initialtime,playingtime,endtime,islive,isprivate,isrecorded,videopath,videopath)
 VALUES('"$streamId"',"$idCamera","$idPlayer",'\"$description\"','\"$initialTime\"',"$tiempo",null,true,"$private",true,'"$googleCloudStorage"',null)"








