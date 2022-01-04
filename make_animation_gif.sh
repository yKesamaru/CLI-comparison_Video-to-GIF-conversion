#!/bin/bash

# 初期設定 ###########
FPS=10
WIDTH=600
FILE="input.mp4"
# ####################


CASE="1"
set_START() { local dummy; read START dummy < /proc/uptime; }; get_ELAPS() { local dummy; read END dummy < /proc/uptime; let ELAPS=${END/./}0-${START/./}0; }; time { set_START; }; START=$START;
ffmpeg -threads 0 -t 5 -i "${FILE}" -vf "fps=${FPS},scale=${WIDTH}:(ow/a/2)*2:flags=lanczos" -loop 0 -y output.gif
time { get_ELAPS; }; END=$END; ELAPS=START-END=$ELAPS; mv output.gif ${CASE}_${ELAPS}.gif;
convert ${CASE}_${ELAPS}.gif[0] gif:- | convert -crop 200x100+200+50 gif:- ${CASE}_${ELAPS}.jpg; unset dummy START END ELAPS START-END CASE;

CASE="2"
set_START() { local dummy; read START dummy < /proc/uptime; }; get_ELAPS() { local dummy; read END dummy < /proc/uptime; let ELAPS=${END/./}0-${START/./}0; }; time { set_START; }; START=$START;
ffmpeg -threads 0 -t 5 -i "${FILE}" -vf "fps=${FPS},scale=${WIDTH}:(ow/a/2)*2:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse" -loop 0 -y output.gif
time { get_ELAPS; }; END=$END; ELAPS=START-END=$ELAPS; mv output.gif ${CASE}_${ELAPS}.gif;
convert ${CASE}_${ELAPS}.gif[0] gif:- | convert -crop 200x100+200+50 gif:- ${CASE}_${ELAPS}.jpg; unset dummy START END ELAPS START-END CASE;


CASE="3-1"
set_START() { local dummy; read START dummy < /proc/uptime; }; get_ELAPS() { local dummy; read END dummy < /proc/uptime; let ELAPS=${END/./}0-${START/./}0; }; time { set_START; }; START=$START;
ffmpeg -threads 0 -t 5 -i $FILE -vf "palettegen=stats_mode=diff" -y palette.png
ffmpeg -threads 0 -t 5 -i $FILE -i palette.png -lavfi "fps=${FPS},scale=${WIDTH}:(ow/a/2)*2:flags=lanczos [x]; [x][1:v]\
    paletteuse=dither=bayer:bayer_scale=1:diff_mode=rectangle"\
    -y -loop 0 output.gif
time { get_ELAPS; }; END=$END; ELAPS=START-END=$ELAPS; mv output.gif ${CASE}_${ELAPS}.gif; 
convert ${CASE}_${ELAPS}.gif[0] gif:- | convert -crop 200x100+200+50 gif:- ${CASE}_${ELAPS}.jpg; unset dummy START END ELAPS START-END CASE;


CASE="3-2"
set_START() { local dummy; read START dummy < /proc/uptime; }; get_ELAPS() { local dummy; read END dummy < /proc/uptime; let ELAPS=${END/./}0-${START/./}0; }; time { set_START; }; START=$START;
ffmpeg -threads 0 -t 5 -i $FILE -vf "palettegen=stats_mode=diff" -y palette.png
ffmpeg -threads 0 -t 5 -i $FILE -i palette.png -lavfi "fps=${FPS},scale=${WIDTH}:(ow/a/2)*2:flags=lanczos [x]; [x][1:v]\
    paletteuse=dither=bayer:bayer_scale=5:diff_mode=rectangle"\
    -y -loop 0 output.gif
time { get_ELAPS; }; END=$END; ELAPS=START-END=$ELAPS; mv output.gif ${CASE}_${ELAPS}.gif;
convert ${CASE}_${ELAPS}.gif[0] gif:- | convert -crop 200x100+200+50 gif:- ${CASE}_${ELAPS}.jpg; unset dummy START END ELAPS START-END CASE;


CASE="3-3"
set_START() { local dummy; read START dummy < /proc/uptime; }; get_ELAPS() { local dummy; read END dummy < /proc/uptime; let ELAPS=${END/./}0-${START/./}0; }; time { set_START; }; START=$START;
ffmpeg -threads 0 -t 5 -i $FILE -vf "palettegen=stats_mode=diff" -y palette.png
ffmpeg -threads 0 -t 5 -i $FILE -i palette.png -lavfi "fps=${FPS},scale=${WIDTH}:(ow/a/2)*2:flags=lanczos [x]; [x][1:v]\
    paletteuse=dither=floyd_steinberg"\
    -y -loop 0 output.gif
time { get_ELAPS; }; END=$END; ELAPS=START-END=$ELAPS; mv output.gif ${CASE}_${ELAPS}.gif; 
convert ${CASE}_${ELAPS}.gif[0] gif:- | convert -crop 200x100+200+50 gif:- ${CASE}_${ELAPS}.jpg; unset dummy START END ELAPS START-END CASE;


CASE="4-1"
set_START() { local dummy; read START dummy < /proc/uptime; }; get_ELAPS() { local dummy; read END dummy < /proc/uptime; let ELAPS=${END/./}0-${START/./}0; }; time { set_START; }; START=$START;
ffmpeg -threads 0 -t 5 -i "${FILE}" -vf "fps=${FPS},scale=${WIDTH}:(ow/a/2)*2:flags=lanczos" %04d.png 
find . -maxdepth 1 -type f -name '*.png' -not -name '*fs8.png' -print0 | parallel -0 pngquant --quality=0-5 {}
convert *fs8.png -loop 0 output.gif
rm *.png
time { get_ELAPS; }; END=$END; ELAPS=START-END=$ELAPS; mv output.gif ${CASE}_${ELAPS}.gif;
convert ${CASE}_${ELAPS}.gif[0] gif:- | convert -crop 200x100+200+50 gif:- ${CASE}_${ELAPS}.jpg; unset dummy START END ELAPS START-END CASE;

CASE="4-2"
set_START() { local dummy; read START dummy < /proc/uptime; }; get_ELAPS() { local dummy; read END dummy < /proc/uptime; let ELAPS=${END/./}0-${START/./}0; }; time { set_START; }; START=$START;
ffmpeg -threads 0 -t 5 -i "${FILE}" -vf "fps=${FPS},scale=${WIDTH}:(ow/a/2)*2:flags=lanczos" %04d.png 
find . -maxdepth 1 -type f -name '*.png' -not -name '*fs8.png' -print0 | parallel -0 pngquant --quality=0-20 {}
convert *fs8.png -loop 0 output.gif
rm *.png
time { get_ELAPS; }; END=$END; ELAPS=START-END=$ELAPS; mv output.gif ${CASE}_${ELAPS}.gif;
convert ${CASE}_${ELAPS}.gif[0] gif:- | convert -crop 200x100+200+50 gif:- ${CASE}_${ELAPS}.jpg; unset dummy START END ELAPS START-END CASE;


CASE="4-3"
set_START() { local dummy; read START dummy < /proc/uptime; }; get_ELAPS() { local dummy; read END dummy < /proc/uptime; let ELAPS=${END/./}0-${START/./}0; }; time { set_START; }; START=$START;
ffmpeg -threads 0 -t 5 -i "${FILE}" -vf "fps=${FPS},scale=${WIDTH}:(ow/a/2)*2:flags=lanczos" %04d.png 
find . -maxdepth 1 -type f -name '*.png' -not -name '*fs8.png' -print0 | parallel -0 pngquant --quality=0-40 {}
convert *fs8.png -loop 0 output.gif
rm *.png
time { get_ELAPS; }; END=$END; ELAPS=START-END=$ELAPS; mv output.gif ${CASE}_${ELAPS}.gif;
convert ${CASE}_${ELAPS}.gif[0] gif:- | convert -crop 200x100+200+50 gif:- ${CASE}_${ELAPS}.jpg; unset dummy START END ELAPS START-END CASE;


CASE="4-4"
set_START() { local dummy; read START dummy < /proc/uptime; }; get_ELAPS() { local dummy; read END dummy < /proc/uptime; let ELAPS=${END/./}0-${START/./}0; }; time { set_START; }; START=$START;
ffmpeg -threads 0 -t 5 -i "${FILE}" -vf "fps=${FPS},scale=${WIDTH}:(ow/a/2)*2:flags=lanczos" %04d.png 
find . -maxdepth 1 -type f -name '*.png' -not -name '*fs8.png' -print0 | parallel -0 pngquant --quality=0-60 {}
convert *fs8.png -loop 0 output.gif
rm *.png
time { get_ELAPS; }; END=$END; ELAPS=START-END=$ELAPS; mv output.gif ${CASE}_${ELAPS}.gif;
convert ${CASE}_${ELAPS}.gif[0] gif:- | convert -crop 200x100+200+50 gif:- ${CASE}_${ELAPS}.jpg; unset dummy START END ELAPS START-END CASE;


CASE="5"
set_START() { local dummy; read START dummy < /proc/uptime; }; get_ELAPS() { local dummy; read END dummy < /proc/uptime; let ELAPS=${END/./}0-${START/./}0; }; time { set_START; }; START=$START;
ffmpeg -threads 0 -t 5 -i "${FILE}" -vf "fps=${FPS},scale=${WIDTH}:(ow/a/2)*2:flags=lanczos" %04d.png 
find . -maxdepth 1 -type f -name '*.png' -not -name '*fs8.png' -print0 | parallel -0 pngquant --quality=0-60 {}
convert *fs8.png -loop 0 -layers optimize output.gif
rm *.png
time { get_ELAPS; }; END=$END; ELAPS=START-END=$ELAPS; mv output.gif ${CASE}_${ELAPS}.gif; 
convert ${CASE}_${ELAPS}.gif[0] gif:- | convert -crop 200x100+200+50 gif:- ${CASE}_${ELAPS}.jpg; unset dummy START END ELAPS START-END CASE;


CASE="6"
set_START() { local dummy; read START dummy < /proc/uptime; }; get_ELAPS() { local dummy; read END dummy < /proc/uptime; let ELAPS=${END/./}0-${START/./}0; }; time { set_START; }; START=$START;
ffmpeg -threads 0 -t 5 -i "${FILE}" -vf "fps=${FPS},scale=${WIDTH}:(ow/a/2)*2:flags=lanczos" -c:v pam -f image2pipe - | convert -delay $((100 / ${FPS})) - -loop 0 -layers optimize output.gif
time { get_ELAPS; }; END=$END; ELAPS=START-END=$ELAPS; mv output.gif ${CASE}_${ELAPS}.gif;
convert ${CASE}_${ELAPS}.gif[0] gif:- | convert -crop 200x100+200+50 gif:- ${CASE}_${ELAPS}.jpg; unset dummy START END ELAPS START-END CASE;


paplay "Positive.ogg"
notify-send "アニメーションGIF計測" "終了しました"