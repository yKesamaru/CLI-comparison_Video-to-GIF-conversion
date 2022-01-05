# 速い・サイズが小さい・綺麗


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
これが使うべきコードです。適宜ワンライナーにしたりシェルスクリプトのまま保存していつでも使って下さい。  
　　
代表的な自称ベストプラクティスを見ながら自分なりにチューンナップして全11種類にまとめました。  
次点以降は後述します。まずはデータをご覧ください。
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
基本形。画像の粗さがかえってノスタルジーな気分にさせる。
```bash
ffmpeg -threads 0 -t 5 -i "${FILE}" -vf "fps=${FPS},scale=${WIDTH}:(ow/a/2)*2:flags=lanczos" -loop 0 -y output.gif
```
![](https://raw.githubusercontent.com/yKesamaru/CLI-comparison_Video-to-GIF-conversion/master/1_START-END=1310.jpg =600x)  
*1秒310, 3.3 MB, 一部領域を拡大*
![](https://raw.githubusercontent.com/yKesamaru/CLI-comparison_Video-to-GIF-conversion/master/case1-1.png =600x)  
![](https://raw.githubusercontent.com/yKesamaru/CLI-comparison_Video-to-GIF-conversion/master/case1-2.png =600x)  
# case2
基本形の発展型。画質が綺麗。出来るサイズがかなり大きい。時間ははやい。尺がある場合使用をためらうタイプ。
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
海外サイトでたまにお目にかかる。前景が動いてればstats_mode=diffだよね、と分かるくらいでないとそのまま使うのは難しい。その割にはbayer_scale=*1*だと画質は荒い。コストも凄く高い。実は実験用にわざとこうしました。1を5にすると良くなります。それがcase3-2。
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
3-1との違いはbayer_scale値。けっこうなめらか。case3-1に比べ僅かにサイズが小さくなる。時間は同じ様に長い。凄く長い。
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
画質は良い方。しかし時間が長すぎる。サイズも大きい。今回の検証で一番コストが高かった。
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
サイズは今検証中最低ランク。時間もそこそこ短い。コストめっちゃ低い。しかし画質が荒い。これだったらcase1でもいいんじゃない？って思ってしまう。ちなみにGIF変換はこれがいいと思ってました（過去記事）。
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
過去記事にも書いた通り、ここらへんは良いと思ってました。でもあとひとつ、って感じが否めないですね。速いしサイズも小さくてコストが低い。
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
これがBest practiceです。画質・サイズ・速度・コスト全てにおいて良いバランスです。ただし一時ファイルを大量に作るタイプなので***HDDの方***は避けたほうが良いかも知れません。
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
処理時間は全検証中真ん中くらい。画質は綺麗。サイズは大きめです。
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
convertコマンドにlayer optimizeをつけました。処理時間はそこそこ長い感じでサイズはかなり大きくなります。コスト的にも大きい方です。
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
ffmpegから直接convertにパイプでつなげています。処理速度は速い方ですがサイズが大きすぎます。
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
Ubuntu18.04では1.91、Ubuntu20.04では1.92がUniverseリポジトリに登録されています。1.92ではオプション`--lossy`が使えるようになります。  
`--lossy`オプションがない状態で作成された各GIFファイルに適用した結果、サイズ変化は誤差の範囲でした。  
```bash
gifsicle --colors 256 --optimize=3 --batch -i *.gif
```
## gifsicle適用前
![](https://raw.githubusercontent.com/yKesamaru/CLI-comparison_Video-to-GIF-conversion/master/no_gifsicle.jpg)
## gifsicle適用後
![](https://raw.githubusercontent.com/yKesamaru/CLI-comparison_Video-to-GIF-conversion/master/gifsicle.jpg)

# 次点
case4-4、その次がcase2でしょうか。case2はサイズが大きすぎるので使用用途に注意が必要です。
```bash:case4-4
ffmpeg -threads 0 -t 5 -i "${FILE}" -vf "fps=${FPS},scale=${WIDTH}:(ow/a/2)*2:flags=lanczos" %04d.png 
find . -maxdepth 1 -type f -name '*.png' -not -name '*fs8.png' -print0 | parallel -0 pngquant --quality=0-60 {}
convert *fs8.png -loop 0 output.gif
rm *.png
```
```bash:case2
ffmpeg -threads 0 -t 5 -i "${FILE}" -lavfi "fps=${FPS},scale=${WIDTH}:(ow/a/2)*2:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse" -loop 0 -y output.gif
```
  
# Install
```bash:Ubuntu
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
[ffmpegでaspect比を維持しつつ、縮小サイズの動画を書き出す](https://zenn.dev/mattak/articles/817ee679a6c080)
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
  
たまにうまくいかないので代替策やってたんですが、ズバリ直球で解決です。今回の検証用コード全てに使わせて頂きました！  