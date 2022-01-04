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

# case1
```bash
ffmpeg -threads 0 -t 5 -i "${FILE}" -vf "fps=${FPS},scale=${WIDTH}:(ow/a/2)*2:flags=lanczos" -loop 0 -y output.gif
```
<!-- ![altテキスト](1_START-END=1310.jpg =250x) -->
![](1_START-END=1310.jpg)
*1秒31, 3.3 MB*
# case2
```bash
ffmpeg -threads 0 -t 5 -i "${FILE}" -lavfi "fps=${FPS},scale=${WIDTH}:(ow/a/2)*2:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse" -loop 0 -y output.gif
```
![](2_START-END=4310.jpg)
*4秒31, 7.2 MB*
# case3-1
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
![](3-1_START-END=13650.jpg)
*13秒65, 6.9 MB*
# case3-2
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
![](3-2_START-END=13940.jpg)
*13秒94, 6.2 MB*
# case3-3
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
![](3-3_START-END=14430.jpg)
*14秒43, 6.9 MB*
# case4-1
- pngquant
  - quality=***0-5***
```bash
ffmpeg -threads 0 -t 5 -i "${FILE}" -vf "fps=${FPS},scale=${WIDTH}:(ow/a/2)*2" %04d.png 
find . -maxdepth 1 -type f -name '*.png' -not -name '*fs8.png' -print0 | parallel -0 pngquant --quality=0-5 {}
convert *fs8.png -loop 0 output.gif
rm *.png
```
![](4-1_START-END=5580.jpg)
*5秒58, 3.5 MB*
# case4-2
- pngquant
  - quality=***0-20***
```bash
ffmpeg -threads 0 -t 5 -i "${FILE}" -vf "fps=${FPS},scale=${WIDTH}:(ow/a/2)*2" %04d.png 
find . -maxdepth 1 -type f -name '*.png' -not -name '*fs8.png' -print0 | parallel -0 pngquant --quality=0-20 {}
convert *fs8.png -loop 0 output.gif
rm *.png
```
![](4-2_START-END=6020.jpg)
*6秒02, 4.6 MB*
# case4-3
- pngquant
  - quality=***0-40***
```bash
ffmpeg -threads 0 -t 5 -i "${FILE}" -vf "fps=${FPS},scale=${WIDTH}:(ow/a/2)*2" %04d.png 
find . -maxdepth 1 -type f -name '*.png' -not -name '*fs8.png' -print0 | parallel -0 pngquant --quality=0-40 {}
convert *fs8.png -loop 0 output.gif
rm *.png
```
![](4-3_START-END=6260.jpg)
*6秒26, 5.3 MB*
# case4-4
- pngquant
  - quality=***0-60***
```bash
ffmpeg -threads 0 -t 5 -i "${FILE}" -vf "fps=${FPS},scale=${WIDTH}:(ow/a/2)*2" %04d.png 
find . -maxdepth 1 -type f -name '*.png' -not -name '*fs8.png' -print0 | parallel -0 pngquant --quality=0-60 {}
convert *fs8.png -loop 0 output.gif
rm *.png
```
![](4-4_START-END=7340.jpg)
*7秒34, 6.6 MB*
# case5
- pngquant
  - quality=0-60
- convert
  - layers optimize
```bash
ffmpeg -threads 0 -t 5 -i "${FILE}" -vf "fps=${FPS},scale=${WIDTH}:(ow/a/2)*2" %04d.png 
find . -maxdepth 1 -type f -name '*.png' -not -name '*fs8.png' -print0 | parallel -0 pngquant --quality=0-60 {}
convert *fs8.png -loop 0 -layers optimize output.gif
rm *.png
```
![](5_START-END=10850.jpg)
*10秒85, 7.8 MB*
# case6
- Use pipeline
- convert
  - layers optimize
```bash
ffmpeg -threads 0 -t 5 -i "${FILE}" -vf "fps=${FPS},scale=${WIDTH}:(ow/a/2)*2:flags=lanczos" -c:v pam -f image2pipe - | convert -delay $((100 / ${FPS})) - -loop 0 -layers optimize output.gif
```
![](6_START-END=5330.jpg)
*5秒33, 8.0 MB*
# Install
```bash
sudo install gifsicle parallel ffmpeg imagemagick pngquant pulseaudio-utils libnotify-bin
```
# Performance table
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

![](time+size.png)  
![](cost.png)

# GIF動画の見た目比較
## case1
![](1_START-END=1310.gif) 
## case2
![](2_START-END=4310.gif)
## case3-1
![](3-1_START-END=13650.gif)
## case3-2
![](3-2_START-END=13940.gif)
## case3-3
![](3-3_START-END=14430.gif)
## case4-1
![](4-1_START-END=5580.gif)
## case4-2
![](4-2_START-END=6020.gif)
## case4-3
![](4-3_START-END=6260.gif)
## case4-4
![](4-4_START-END=7340.gif)
## case5
![](5_START-END=10850.gif)
## case6
![](6_START-END=5330.gif)

# 計測方法
10ミリ秒単位で計測。こちらを参考にさせて頂きました。  
[bash で処理時間を 10 ミリ秒単位で計測する方法](https://luna2-linux.blogspot.com/2011/10/bash-10.html?m=0)  
https://luna2-linux.blogspot.com/2011/10/bash-10.html?m=0  
```bash
set_START() { local dummy; read START dummy < /proc/uptime; }; get_ELAPS() { local dummy; read END dummy < /proc/uptime; let ELAPS=${END/./}0-${START/./}0; }; time { set_START; }; START=$START;
  
処理  
  
time { get_ELAPS; }; END=$END; ELAPS=START-END=$ELAPS; mv output.gif ${CASE}_${ELAPS}.gif;
```

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
![](no_gifsicle.png)
## gifsicle適用後
![](gifsicle.png)