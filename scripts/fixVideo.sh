video=$1

ffmpeg -y -i $video.mp4 -c copy -f h264 $video.h264
ffmpeg -y -i $video.mp4 -vn -acodec copy $video.aac
mv $video.mp4 $video.old.mp4
ffmpeg -y -r 25 -i $video.h264 -i $video.aac -c copy $video.mp4
ffmpeg -i $video.mp4 -r 1 -ss 00:00:10 -vf scale=320:180 -t 1 $video.jpg

rm -fr $video.h264
rm -fr $video.aac
