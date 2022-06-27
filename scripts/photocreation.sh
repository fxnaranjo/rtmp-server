# new createphoto script

extension=".jpg"
FILES="/library/jaimepinto-squash/*.mp4"
for file in $FILES
do
newfile=${file::-4}
# echo $newfile
ffmpeg -i $file -r 1 -ss 00:01:00 -vf scale=320:180 -t 1 $newfile$extension
done
