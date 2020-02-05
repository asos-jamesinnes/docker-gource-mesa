#!/bin/sh

Xvfb :99 -ac -screen 0 1920x1080x24 -nolisten tcp &
sleep 5

mkdir /video
cp /mnt/gource-mesa/commits.log /

mkdir -p ./tmp
mkfifo ./tmp/gource.pipe

gource --1920x1080 \
    --camera-mode overview \
    --file-idle-time 0 \
    --auto-skip-seconds 0.5 \
    --seconds-per-day 1 \
    --bloom-multiplier 0.5 \
    --bloom-intensity 0.1 \
    --date-format "Day %j %b %Y" \
    --max-file-lag 0.1 \
    -key \
    --background 000000 \
    --font-size 16 \
    --font-colour ffffff \
    --hide "mouse,filenames,dirnames,usernames" \
    --hide-root \
    --stop-at-end \
    /commits.log \
    -r 60 \
    -o - >./tmp/gource.pipe &

ffmpeg -r 60 -f image2pipe -probesize 100M -i ./tmp/gource.pipe -threads 0 \
    -vcodec libx264 -level 5.1 -pix_fmt yuv420p -crf 23 -preset medium -threads 0 -bf 0 /video/$(date +%s).mp4

rm -rf ./tmp
cp /video/* /mnt/gource-mesa/video

echo "All Done"
