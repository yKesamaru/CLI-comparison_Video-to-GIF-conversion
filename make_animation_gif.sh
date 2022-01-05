#!/bin/bash

# 初期設定 ###########
FPS=10
WIDTH=600
FILE="input.mp4"
# ####################

CASE="PNGQUANT1-1"
set_START() { local dummy; read START dummy < /proc/uptime; }; get_ELAPS() { local dummy; read END dummy < /proc/uptime; let ELAPS=${END/./}0-${START/./}0; }; time { set_START; }; START=$START;
ffmpeg -threads 0 -t 5 -i "${FILE}" -c:v pam -f image2pipe - | pngquant --quality=0-5 {} - | convert - -loop 0 output.gif
# ffmpeg -threads 0 -t 5 -i "${FILE}" -c:v png -f image2 - | pngquant --quality=0-5 {} - | convert - -loop 0 output.gif
# ffmpeg -threads 0 -t 5 -i "${FILE}" -f png_pipe pipe:1 | pngquant --quality=0-5 {} - | convert - -loop 0 output.gif

# find . -maxdepth 1 -type f -name '*.png' -not -name '*fs8.png' -print0 | parallel -0 pngquant --quality=0-5 {}
# convert *fs8.png -loop 0 output.gif
# rm *.png

time { get_ELAPS; }; END=$END; ELAPS=START-END=$ELAPS; mv output.gif ${CASE}_${ELAPS}.gif;
convert ${CASE}_${ELAPS}.gif[0] gif:- | convert -crop 200x100+200+50 gif:- ${CASE}_${ELAPS}.jpg; unset dummy START END ELAPS START-END CASE;


CASE="GIFSICLE1-1"
set_START() { local dummy; read START dummy < /proc/uptime; }; get_ELAPS() { local dummy; read END dummy < /proc/uptime; let ELAPS=${END/./}0-${START/./}0; }; time { set_START; }; START=$START;
ffmpeg -threads 0 -t 5 -i "${FILE}" -pix_fmt rgb8 -f gif - | gifsicle --loopcount=0 --resize-width ${WIDTH} --resize-method mix --optimize=3 > output.gif
time { get_ELAPS; }; END=$END; ELAPS=START-END=$ELAPS; mv output.gif ${CASE}_${ELAPS}.gif;
convert ${CASE}_${ELAPS}.gif[0] gif:- | convert -crop 200x100+200+50 gif:- ${CASE}_${ELAPS}.jpg; unset dummy START END ELAPS START-END CASE;

CASE="GIFSICLE1-2"
set_START() { local dummy; read START dummy < /proc/uptime; }; get_ELAPS() { local dummy; read END dummy < /proc/uptime; let ELAPS=${END/./}0-${START/./}0; }; time { set_START; }; START=$START;
ffmpeg -threads 0 -t 5 -i "${FILE}" -pix_fmt rgb8 -f gif - | gifsicle --loopcount=0 --resize-width ${WIDTH} --resize-method mix --optimize=2 > output.gif
time { get_ELAPS; }; END=$END; ELAPS=START-END=$ELAPS; mv output.gif ${CASE}_${ELAPS}.gif;
convert ${CASE}_${ELAPS}.gif[0] gif:- | convert -crop 200x100+200+50 gif:- ${CASE}_${ELAPS}.jpg; unset dummy START END ELAPS START-END CASE;

CASE="GIFSICLE1-3"
set_START() { local dummy; read START dummy < /proc/uptime; }; get_ELAPS() { local dummy; read END dummy < /proc/uptime; let ELAPS=${END/./}0-${START/./}0; }; time { set_START; }; START=$START;
ffmpeg -threads 0 -t 5 -i "${FILE}" -pix_fmt rgb8 -f gif - | gifsicle --loopcount=0 --resize-width ${WIDTH} --resize-method sample --optimize=1 > output.gif
time { get_ELAPS; }; END=$END; ELAPS=START-END=$ELAPS; mv output.gif ${CASE}_${ELAPS}.gif;
convert ${CASE}_${ELAPS}.gif[0] gif:- | convert -crop 200x100+200+50 gif:- ${CASE}_${ELAPS}.jpg; unset dummy START END ELAPS START-END CASE;

CASE="GIFSICLE1-4"
set_START() { local dummy; read START dummy < /proc/uptime; }; get_ELAPS() { local dummy; read END dummy < /proc/uptime; let ELAPS=${END/./}0-${START/./}0; }; time { set_START; }; START=$START;
ffmpeg -threads 0 -t 5 -i "${FILE}" -pix_fmt rgb8 -f gif - | gifsicle --loopcount=0 --resize-width ${WIDTH} --resize-method box --optimize=1 > output.gif
time { get_ELAPS; }; END=$END; ELAPS=START-END=$ELAPS; mv output.gif ${CASE}_${ELAPS}.gif;
convert ${CASE}_${ELAPS}.gif[0] gif:- | convert -crop 200x100+200+50 gif:- ${CASE}_${ELAPS}.jpg; unset dummy START END ELAPS START-END CASE;

CASE="GIFSICLE1-5"
set_START() { local dummy; read START dummy < /proc/uptime; }; get_ELAPS() { local dummy; read END dummy < /proc/uptime; let ELAPS=${END/./}0-${START/./}0; }; time { set_START; }; START=$START;
ffmpeg -threads 0 -t 5 -i "${FILE}" -pix_fmt rgb8 -f gif - | gifsicle --loopcount=0 --resize-width ${WIDTH} --resize-method lanczos3 --optimize=1 > output.gif
time { get_ELAPS; }; END=$END; ELAPS=START-END=$ELAPS; mv output.gif ${CASE}_${ELAPS}.gif;
convert ${CASE}_${ELAPS}.gif[0] gif:- | convert -crop 200x100+200+50 gif:- ${CASE}_${ELAPS}.jpg; unset dummy START END ELAPS START-END CASE;

CASE="GIFSICLE1-6"
set_START() { local dummy; read START dummy < /proc/uptime; }; get_ELAPS() { local dummy; read END dummy < /proc/uptime; let ELAPS=${END/./}0-${START/./}0; }; time { set_START; }; START=$START;
ffmpeg -threads 0 -t 5 -i "${FILE}" -pix_fmt rgb8 -f gif - | gifsicle --loopcount=0 --resize-width ${WIDTH} --resize-method mix --dither=floyd-steinberg --optimize=1 > output.gif
time { get_ELAPS; }; END=$END; ELAPS=START-END=$ELAPS; mv output.gif ${CASE}_${ELAPS}.gif;
convert ${CASE}_${ELAPS}.gif[0] gif:- | convert -crop 200x100+200+50 gif:- ${CASE}_${ELAPS}.jpg; unset dummy START END ELAPS START-END CASE;

CASE="GIFSICLE2-1"
set_START() { local dummy; read START dummy < /proc/uptime; }; get_ELAPS() { local dummy; read END dummy < /proc/uptime; let ELAPS=${END/./}0-${START/./}0; }; time { set_START; }; START=$START;
ffmpeg -threads 0 -t 5 -i "${FILE}" -vf "fps=${FPS},scale=${WIDTH}:(ow/a/2)*2:flags=lanczos" -pix_fmt rgb8 -f gif - | gifsicle --loopcount=0 --optimize=3 > output.gif
time { get_ELAPS; }; END=$END; ELAPS=START-END=$ELAPS; mv output.gif ${CASE}_${ELAPS}.gif;
convert ${CASE}_${ELAPS}.gif[0] gif:- | convert -crop 200x100+200+50 gif:- ${CASE}_${ELAPS}.jpg; unset dummy START END ELAPS START-END CASE;

CASE="GIFSICLE2-2"
set_START() { local dummy; read START dummy < /proc/uptime; }; get_ELAPS() { local dummy; read END dummy < /proc/uptime; let ELAPS=${END/./}0-${START/./}0; }; time { set_START; }; START=$START;
ffmpeg -threads 0 -t 5 -i "${FILE}" -vf "fps=${FPS},scale=${WIDTH}:(ow/a/2)*2:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse" -pix_fmt rgb8 -f gif - | gifsicle --loopcount=0 --optimize=3 > output.gif
time { get_ELAPS; }; END=$END; ELAPS=START-END=$ELAPS; mv output.gif ${CASE}_${ELAPS}.gif;
convert ${CASE}_${ELAPS}.gif[0] gif:- | convert -crop 200x100+200+50 gif:- ${CASE}_${ELAPS}.jpg; unset dummy START END ELAPS START-END CASE;

# ffmpeg -threads 0 -t 5 -i "${FILE}" -pix_fmt rgb8 -f gif - | gifsicle --loopcount=0 --resize-width ${WIDTH} --resize-method catrom 
# ffmpeg -threads 0 -t 5 -i "${FILE}" -pix_fmt rgb8 -f gif - | gifsicle --loopcount=0 --resize-width ${WIDTH} --resize-method mitchell 
# ffmpeg -threads 0 -t 5 -i "${FILE}" -pix_fmt rgb8 -f gif - | gifsicle --loopcount=0 --resize-width ${WIDTH} --resize-method mix --dither=ro64
# ffmpeg -threads 0 -t 5 -i "${FILE}" -pix_fmt rgb8 -f gif - | gifsicle --loopcount=0 --resize-width ${WIDTH} --resize-method mix --dither=o3
# ffmpeg -threads 0 -t 5 -i "${FILE}" -pix_fmt rgb8 -f gif - | gifsicle --loopcount=0 --resize-width ${WIDTH} --resize-method mix --dither=o4
# ffmpeg -threads 0 -t 5 -i "${FILE}" -pix_fmt rgb8 -f gif - | gifsicle --loopcount=0 --resize-width ${WIDTH} --resize-method mix --dither=ordered
# ffmpeg -threads 0 -t 5 -i "${FILE}" -pix_fmt rgb8 -f gif - | gifsicle --loopcount=0 --resize-width ${WIDTH} --resize-method mix --dither=halftone,10,3
# ffmpeg -threads 0 -t 5 -i "${FILE}" -pix_fmt rgb8 -f gif - | gifsicle --loopcount=0 --resize-width ${WIDTH} --resize-method mix --dither=squarehalftone
# ffmpeg -threads 0 -t 5 -i "${FILE}" -pix_fmt rgb8 -f gif - | gifsicle --loopcount=0 --resize-width ${WIDTH} --resize-method mix --dither=diagonal
# ffmpeg -threads 0 -t 5 -i "${FILE}" -pix_fmt rgb8 -f gif - | gifsicle --loopcount=0 --resize-width ${WIDTH} --resize-method mix --color-method blend-diversity
# ffmpeg -threads 0 -t 5 -i "${FILE}" -pix_fmt rgb8 -f gif - | gifsicle --loopcount=0 --resize-width ${WIDTH} --resize-method mix --color-method median-cut





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