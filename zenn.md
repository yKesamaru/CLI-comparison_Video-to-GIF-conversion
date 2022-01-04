# Best practice
```bash
#!/bin/bash

# 初期設定 ###########
FPS=10
WIDTH=600
FILE="input.mp4"
# ####################

ffmpeg -threads 0 -t 5 -i "${FILE}" -vf "fps=${FPS},scale=${WIDTH}:(ow/a/2)*2:flags=lanczos" %04d.png 
find . -maxdepth 1 -type f -name '*.png' -not -name '*fs8.png' -print0 | parallel -0 pngquant --quality=0-40 {}
convert *fs8.png -loop 0 output.gif
rm *.png
```
次点以降は後述。
# Performance table
## 処理時間とファイルサイズの関係
|       | Time(mSec) | Size(MB) |
| ---- | ---- | ---- |
| case 1 | 1310 | 3.3 |
| case 2 | 4310 | 7.2 |
| case 3-1 | 13650 | 6.9 |
| case 3-2 | 13940 | 6.2 |
| case 3-3 | 14430 | 6.9 |
| case 4-1 | 5580 | 3.5 |
| case 4-2 | 6020 | 4.6 |
| case 4-3 | 6260 | 5.3 |
| case 4-4 | 7340 | 6.6 |
| case 5 | 10850 | 7.8 |
| case 6 | 5330 | 8.0 |
![](https://raw.githubusercontent.com/yKesamaru/CLI-comparison_Video-to-GIF-conversion/master/time+size.jpg)  
*数値が低いほうがbetter*
## 時間 x サイズ = コスト
| | Cost (Time x Size) |
| ---- | ---- |
| case 1 | 4323 |
| case 2 | 31032 |
| case 3-1 | 94185 |
| case 3-2 | 86428 |
| case 3-3 | 99567 |
| case 4-1 | 19530 |
| case 4-2 | 27692 |
| case 4-3 | 33178 |
| case 4-4 | 48444 |
| case 5 | 84630 |
| case 6 | 42640 |
![](https://raw.githubusercontent.com/yKesamaru/CLI-comparison_Video-to-GIF-conversion/master/cost.jpg)　 
*数値が低いほうがbetter。コストの低さと出来上がる画質を比べる必要がある。*

# 計測方法
10ミリ秒単位で計測。こちらを参考にさせて頂きました。  
[bash で処理時間を 10 ミリ秒単位で計測する方法](https://luna2-linux.blogspot.com/2011/10/bash-10.html?m=0)  
https://luna2-linux.blogspot.com/2011/10/bash-10.html?m=0  
```bash
set_START() { local dummy; read START dummy < /proc/uptime; }; get_ELAPS() { local dummy; read END dummy < /proc/uptime; let ELAPS=${END/./}0-${START/./}0; }; time { set_START; }; START=$START;
  
処理  
  
time { get_ELAPS; }; END=$END; ELAPS=START-END=$ELAPS; mv output.gif ${CASE}_${ELAPS}.gif;
```
# 高速化
共通。
- ffmpeg
  - -threads 0
- pngquant
  - GNU parallel

# case1
```bash
ffmpeg -threads 0 -t 5 -i "${FILE}" -vf "fps=${FPS},scale=${WIDTH}:(ow/a/2)*2:flags=lanczos" -loop 0 -y output.gif
```
![](https://raw.githubusercontent.com/yKesamaru/CLI-comparison_Video-to-GIF-conversion/master/1_START-END=1310.jpg =600x)
*1秒310, 3.3 MB, 一部領域を拡大*
![](https://raw.githubusercontent.com/yKesamaru/CLI-comparison_Video-to-GIF-conversion/master/case1-1.png =600x)
![](https://raw.githubusercontent.com/yKesamaru/CLI-comparison_Video-to-GIF-conversion/master/case1-2.png =600x)
# case2
- ffmpeg
  - palettegen
    - stats_mode=full(Default)
  - paletteuse
    - dither=sierra2_4a(Default)
    - diff_mode=none(Default)
```bash
ffmpeg -threads 0 -t 5 -i "${FILE}" -lavfi "fps=${FPS},scale=${WIDTH}:(ow/a/2)*2:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse" -loop 0 -y output.gif
```
![](https://raw.githubusercontent.com/yKesamaru/CLI-comparison_Video-to-GIF-conversion/master/2_START-END=4310.jpg =600x)
*4秒310, 7.2 MB, 一部領域を拡大*
![](https://raw.githubusercontent.com/yKesamaru/CLI-comparison_Video-to-GIF-conversion/master/case2-1.png =600x)
![](https://raw.githubusercontent.com/yKesamaru/CLI-comparison_Video-to-GIF-conversion/master/case2-2.png =600x)
# case3-1
- ffmpeg
  - palettegen
    - stats_mode=diff
  - paletteuse
    - dither=bayer
    - bayer_scale=***1***
    - :diff_mode=rectangle
```bash
ffmpeg -threads 0 -t 5 -i $FILE -vf "palettegen=stats_mode=diff" -y palette.png
ffmpeg -threads 0 -t 5 -i $FILE -i palette.png -lavfi "fps=${FPS},scale=${WIDTH}:(ow/a/2)*2:flags=lanczos [x]; [x][1:v]\
    paletteuse=dither=bayer:bayer_scale=1:diff_mode=rectangle"\
    -y -loop 0 output.gif
```
![](https://raw.githubusercontent.com/yKesamaru/CLI-comparison_Video-to-GIF-conversion/master/3-1_START-END=13650.jpg =600x)
*13秒650, 6.9 MB, 一部領域を拡大*
![](https://raw.githubusercontent.com/yKesamaru/CLI-comparison_Video-to-GIF-conversion/master/case3-1-1.png =600x)
![](https://raw.githubusercontent.com/yKesamaru/CLI-comparison_Video-to-GIF-conversion/master/case3-1-2.png =600x)
# case3-2
- ffmpeg
  - palettegen
    - stats_mode=diff
  - paletteuse
    - dither=bayer
    - bayer_scale=***5***
    - diff_mode=rectangle
```bash
ffmpeg -threads 0 -t 5 -i $FILE -vf "palettegen=stats_mode=diff" -y palette.png
ffmpeg -threads 0 -t 5 -i $FILE -i palette.png -lavfi "fps=${FPS},scale=${WIDTH}:(ow/a/2)*2:flags=lanczos [x]; [x][1:v]\
    paletteuse=dither=bayer:bayer_scale=5:diff_mode=rectangle"\
    -y -loop 0 output.gif
```
![](https://raw.githubusercontent.com/yKesamaru/CLI-comparison_Video-to-GIF-conversion/master/3-2_START-END=13940.jpg =600x)
*13秒940, 6.2 MB, 一部領域を拡大*
![](https://raw.githubusercontent.com/yKesamaru/CLI-comparison_Video-to-GIF-conversion/master/case3-2-1.png =600x)
![](https://raw.githubusercontent.com/yKesamaru/CLI-comparison_Video-to-GIF-conversion/master/case3-2-2.png =600x)
# case3-3
- ffmpeg
  - palettegen
    - stats_mode=diff
  - paletteuse
    - dither=***floyd_steinberg***
```bash
ffmpeg -threads 0 -t 5 -i $FILE -vf "palettegen=stats_mode=diff" -y palette.png
ffmpeg -threads 0 -t 5 -i $FILE -i palette.png -lavfi "fps=${FPS},scale=${WIDTH}:(ow/a/2)*2:flags=lanczos [x]; [x][1:v]\
    paletteuse=dither=floyd_steinberg"\
    -y -loop 0 output.gif
```
![](https://raw.githubusercontent.com/yKesamaru/CLI-comparison_Video-to-GIF-conversion/master/3-3_START-END=14430.jpg =600x)
*14秒430, 6.9 MB, 一部領域を拡大*
![](https://raw.githubusercontent.com/yKesamaru/CLI-comparison_Video-to-GIF-conversion/master/case3-3-1.png =600x)
![](https://raw.githubusercontent.com/yKesamaru/CLI-comparison_Video-to-GIF-conversion/master/case3-3-2.png =600x)
# case4-1
- pngquant
  - quality=***0-5***
```bash
ffmpeg -threads 0 -t 5 -i "${FILE}" -vf "fps=${FPS},scale=${WIDTH}:(ow/a/2)*2:flags=lanczos" %04d.png 
find . -maxdepth 1 -type f -name '*.png' -not -name '*fs8.png' -print0 | parallel -0 pngquant --quality=0-5 {}
convert *fs8.png -loop 0 output.gif
rm *.png
```
![](https://raw.githubusercontent.com/yKesamaru/CLI-comparison_Video-to-GIF-conversion/master/4-1_START-END=5580.jpg =600x)
*5秒580, 3.5 MB, 一部領域を拡大*
![](https://raw.githubusercontent.com/yKesamaru/CLI-comparison_Video-to-GIF-conversion/master/case4-1-1.png =600x)
![](https://raw.githubusercontent.com/yKesamaru/CLI-comparison_Video-to-GIF-conversion/master/case4-1-2.png =600x)
# case4-2
- pngquant
  - quality=***0-20***
```bash
ffmpeg -threads 0 -t 5 -i "${FILE}" -vf "fps=${FPS},scale=${WIDTH}:(ow/a/2)*2:flags=lanczos" %04d.png 
find . -maxdepth 1 -type f -name '*.png' -not -name '*fs8.png' -print0 | parallel -0 pngquant --quality=0-20 {}
convert *fs8.png -loop 0 output.gif
rm *.png
```
![](https://raw.githubusercontent.com/yKesamaru/CLI-comparison_Video-to-GIF-conversion/master/4-2_START-END=6020.jpg =600x)
*6秒020, 4.6 MB, 一部領域を拡大*
![](https://raw.githubusercontent.com/yKesamaru/CLI-comparison_Video-to-GIF-conversion/master/case4-2-1.png =600x)
![](https://raw.githubusercontent.com/yKesamaru/CLI-comparison_Video-to-GIF-conversion/master/case4-2-2.png =600x)
# case4-3
- pngquant
  - quality=***0-40***
```bash
ffmpeg -threads 0 -t 5 -i "${FILE}" -vf "fps=${FPS},scale=${WIDTH}:(ow/a/2)*2:flags=lanczos" %04d.png 
find . -maxdepth 1 -type f -name '*.png' -not -name '*fs8.png' -print0 | parallel -0 pngquant --quality=0-40 {}
convert *fs8.png -loop 0 output.gif
rm *.png
```
![](https://raw.githubusercontent.com/yKesamaru/CLI-comparison_Video-to-GIF-conversion/master/4-3_START-END=6260.jpg =600x)
*6秒260, 5.3 MB, 一部領域を拡大*
![](https://raw.githubusercontent.com/yKesamaru/CLI-comparison_Video-to-GIF-conversion/master/case4-3-1.png =600x)
![](https://raw.githubusercontent.com/yKesamaru/CLI-comparison_Video-to-GIF-conversion/master/case4-3-2.png =600x)
# case4-4
- pngquant
  - quality=***0-60***
```bash
ffmpeg -threads 0 -t 5 -i "${FILE}" -vf "fps=${FPS},scale=${WIDTH}:(ow/a/2)*2:flags=lanczos" %04d.png 
find . -maxdepth 1 -type f -name '*.png' -not -name '*fs8.png' -print0 | parallel -0 pngquant --quality=0-60 {}
convert *fs8.png -loop 0 output.gif
rm *.png
```
![](https://raw.githubusercontent.com/yKesamaru/CLI-comparison_Video-to-GIF-conversion/master/4-4_START-END=7340.jpg =600x)
*7秒340, 6.6 MB, 一部領域を拡大*
![](https://raw.githubusercontent.com/yKesamaru/CLI-comparison_Video-to-GIF-conversion/master/case4-4-1.png =600x)
![](https://raw.githubusercontent.com/yKesamaru/CLI-comparison_Video-to-GIF-conversion/master/case4-4-2.png =600x)
# case5
- pngquant
  - quality=0-60
- convert
  - layers optimize
```bash
ffmpeg -threads 0 -t 5 -i "${FILE}" -vf "fps=${FPS},scale=${WIDTH}:(ow/a/2)*2:flags=lanczos" %04d.png 
find . -maxdepth 1 -type f -name '*.png' -not -name '*fs8.png' -print0 | parallel -0 pngquant --quality=0-60 {}
convert *fs8.png -loop 0 -layers optimize output.gif
rm *.png
```
![](https://raw.githubusercontent.com/yKesamaru/CLI-comparison_Video-to-GIF-conversion/master/5_START-END=10850.jpg =600x)
*10秒850, 7.8 MB, 一部領域を拡大*
![](https://raw.githubusercontent.com/yKesamaru/CLI-comparison_Video-to-GIF-conversion/master/case5-1.png =600x)
![](https://raw.githubusercontent.com/yKesamaru/CLI-comparison_Video-to-GIF-conversion/master/case5-2.png =600x)
# case6
- Use pipeline
- convert
  - layers optimize
```bash
ffmpeg -threads 0 -t 5 -i "${FILE}" -vf "fps=${FPS},scale=${WIDTH}:(ow/a/2)*2:flags=lanczos" -c:v pam -f image2pipe - | convert -delay $((100 / ${FPS})) - -loop 0 -layers optimize output.gif
```
![](https://raw.githubusercontent.com/yKesamaru/CLI-comparison_Video-to-GIF-conversion/master/6_START-END=5330.jpg =600x)
*5秒330, 8.0 MB, 一部領域を拡大*
![](https://raw.githubusercontent.com/yKesamaru/CLI-comparison_Video-to-GIF-conversion/master/case6-1.png =600x)
![](https://raw.githubusercontent.com/yKesamaru/CLI-comparison_Video-to-GIF-conversion/master/case6-2.png =600x)
  
# GIF動画の見た目比較
## case1
![](https://raw.githubusercontent.com/yKesamaru/CLI-comparison_Video-to-GIF-conversion/master/1_START-END=1310.gif) 
## case2
![](https://raw.githubusercontent.com/yKesamaru/CLI-comparison_Video-to-GIF-conversion/master/2_START-END=4310.gif)
## case3-1
![](https://raw.githubusercontent.com/yKesamaru/CLI-comparison_Video-to-GIF-conversion/master/3-1_START-END=13650.gif)
## case3-2
![](https://raw.githubusercontent.com/yKesamaru/CLI-comparison_Video-to-GIF-conversion/master/3-2_START-END=13940.gif)
## case3-3
![](https://raw.githubusercontent.com/yKesamaru/CLI-comparison_Video-to-GIF-conversion/master/3-3_START-END=14430.gif)
## case4-1
![](https://raw.githubusercontent.com/yKesamaru/CLI-comparison_Video-to-GIF-conversion/master/4-1_START-END=5580.gif)
## case4-2
![](https://raw.githubusercontent.com/yKesamaru/CLI-comparison_Video-to-GIF-conversion/master/4-2_START-END=6020.gif)
## case4-3
![](https://raw.githubusercontent.com/yKesamaru/CLI-comparison_Video-to-GIF-conversion/master/4-3_START-END=6260.gif)
## case4-4
![](https://raw.githubusercontent.com/yKesamaru/CLI-comparison_Video-to-GIF-conversion/master/4-4_START-END=7340.gif)
## case5
![](https://raw.githubusercontent.com/yKesamaru/CLI-comparison_Video-to-GIF-conversion/master/5_START-END=10850.gif)
## case6
![](https://raw.githubusercontent.com/yKesamaru/CLI-comparison_Video-to-GIF-conversion/master/6_START-END=5330.gif)

# Gifsicle
サイズ変化は誤差の範囲だった。  
```bash
gifsicle --colors 256 --optimize=3 --batch -i *.gif
gifsicle:1_START-END=1310.gif: warning: trivial adaptive palette (only 108 colors in source)
gifsicle:2_START-END=4310.gif: warning: trivial adaptive palette (only 255 colors in source)
gifsicle:3-1_START-END=13650.gif: warning: trivial adaptive palette (only 255 colors in source)
gifsicle:3-2_START-END=13940.gif: warning: trivial adaptive palette (only 255 colors in source)
gifsicle:3-3_START-END=14430.gif: warning: trivial adaptive palette (only 255 colors in source)
gifsicle:5_START-END=10850.gif: warning: trivial adaptive palette (only 254 colors in source)
gifsicle:6_START-END=5330.gif: warning: trivial adaptive palette (only 255 colors in source)
```
## gifsicle適用前
![](https://raw.githubusercontent.com/yKesamaru/CLI-comparison_Video-to-GIF-conversion/master/no_gifsicle.jpg)
## gifsicle適用後
![](https://raw.githubusercontent.com/yKesamaru/CLI-comparison_Video-to-GIF-conversion/master/gifsicle.jpg)
  
# Install
```bash
sudo install gifsicle parallel ffmpeg imagemagick pngquant pulseaudio-utils libnotify-bin
```
# 全体のコード
```bash
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
notify-send "動画GIF変換計測" "終了しました"
```
# Reference
https://qiita.com/yoya/items/6bacfe84cd49237aea27
https://qiita.com/yusuga/items/ba7b5c2cac3f2928f040
https://nico-lab.net/optimized_256_colors_with_ffmpeg/
https://superuser.com/questions/556029/how-do-i-convert-a-video-to-gif-using-ffmpeg-with-reasonable-quality/556031#556031
https://ffmpeg.org/ffmpeg-filters.html
http://blog.pkh.me/p/21-high-quality-gif-with-ffmpeg.html
https://github.com/kohler/gifsicle
https://github.com/yKesamaru/CLI-comparison_Video-to-GIF-conversion
http://www.gnu.org/software/parallel/parallel.html#EXAMPLE:-Working-as-xargs--n1.-Argument-appending
![ffmpegでaspect比を維持しつつ、縮小サイズの動画を書き出す](https://zenn.dev/mattak/articles/817ee679a6c080)
https://zenn.dev/mattak/articles/817ee679a6c080
> なんか毎回忘れるのでメモ
> ```bash
> $ ffmpeg -i tmp.mp4 -vf 'scale=320:-1' tmp_small.mp4
> ```
> これでうまくいくこともあるのだけど、
> 動画の縦の大きさが2で割り切れない場合に、下記のようなメッセージでうまく行かない。
> ```bash
> [libx264 @ 0x14000ee00] height not divisible by 2 (320x257)
> ```
> 端数を丸め込むとうまくいく.
> (ow=original_width, a=aspect_ratio, 2で割って戻して、奇数を偶数化する)  
  
個人的にはインパクトがありました。ほんとたまにうまくいかないので代替策やってたんですが、ズバリ直球で解決しちゃってます。リスペクトします。今回の検証用コード全てに使わせて頂きました！
