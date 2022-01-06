# 何のために行ったか
動画からGIF変換の「速い・サイズが小さい・綺麗」を比較するために検証を行いました。  
代表的な例を自分なりにチューンナップして全19種類のデータをとりましたので共有します。  
:::details TOC
- [何のために行ったか](#何のために行ったか)
- [個人的なベストプラクティス](#個人的なベストプラクティス)
- [Performance table](#performance-table)
  - [処理時間とファイルサイズの関係](#処理時間とファイルサイズの関係)
  - [時間 x サイズ = コスト](#時間-x-サイズ--コスト)
    - [Gifsicleを除外](#gifsicleを除外)
- [計測方法](#計測方法)
- [高速化](#高速化)
- [結果1: コードと拡大画像の見た目比較](#結果1-コードと拡大画像の見た目比較)
  - [CASE1](#case1)
  - [CASE2](#case2)
  - [CASE3-1](#case3-1)
  - [CASE3-2](#case3-2)
  - [CASE3-3](#case3-3)
  - [CASE4-1](#case4-1)
  - [CASE4-2](#case4-2)
  - [CASE4-3](#case4-3)
  - [CASE4-4](#case4-4)
  - [CASE5](#case5)
  - [CASE6](#case6)
- [結果2: GIF動画の見た目比較](#結果2-gif動画の見た目比較)
  - [CASE1](#case1-1)
  - [CASE2](#case2-1)
  - [CASE3-1](#case3-1-1)
  - [CASE3-2](#case3-2-1)
  - [CASE3-3](#case3-3-1)
  - [CASE4-1](#case4-1-1)
  - [CASE4-2](#case4-2-1)
  - [CASE4-3](#case4-3-1)
  - [CASE4-4](#case4-4-1)
  - [CASE5](#case5-1)
  - [CASE6](#case6-1)
- [次点と思われるもの](#次点と思われるもの)
- [今後の改善点](#今後の改善点)
- [Install](#install)
- [全体のコード](#全体のコード)
- [Reference](#reference)
:::
# 個人的なベストプラクティス
先に速度・サイズ・画質共にバランスのとれていると結果がでたコードを載せておきます。  
```bash
#!/bin/bash

# 初期設定 ###########
FPS=10
WIDTH=600
FILE="input.mp4"
# ####################

mkdir '.tmp'
ffmpeg -threads 0 -i "${FILE}" -vf "fps=${FPS},scale=${WIDTH}:(ow/a/2)*2:flags=lanczos" .tmp/%04d.png 
find .tmp/ -maxdepth 1 -type f -name '*.png' -not -name '*fs8.png' -print0 | parallel -0 pngquant --quality=0-40 {}
convert .tmp/*fs8.png -loop 0 output.gif
rm -r '.tmp'
```
  
個人的な次点以降は後述します。まずはデータをご覧ください。
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
| GIFSICLE1-1 | 33560 | 5.6 |
| GIFSICLE1-2 | 31980 | 5.7 |
| GIFSICLE1-3 | 23070 | 10.6 |
| GIFSICLE1-4 | 31060 | 7.1 |
| GIFSICLE1-5 | 40040 | 7.3 |
| GIFSICLE1-6 | 31570 | 7.1 |
| GIFSICLE2-1 | 2280 | 3.3 |
| GIFSICLE2-2 | 5860 | 5.2 |

![](https://raw.githubusercontent.com/yKesamaru/CLI-comparison_Video-to-GIF-conversion/master/img/time+size.jpg)  
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
| GIFSICLE1-1 | 187936 |
| GIFSICLE1-2 | 182286 |
| GIFSICLE1-3 | 244542 |
| GIFSICLE1-4 | 220526 |
| GIFSICLE1-5 | 292292 |
| GIFSICLE1-6 | 224147 |
| GIFSICLE2-1 | 7524 |
| GIFSICLE2-2 | 30472 |


![](https://raw.githubusercontent.com/yKesamaru/CLI-comparison_Video-to-GIF-conversion/master/img/cost.jpg)  
*数値が低いほうがbetter。コストの低さと出来上がる画質を比べる必要がある。*  
### Gifsicleを除外
Ubuntu18.04では1.91、Ubuntu20.04では1.92がUniverseリポジトリに登録されています。今回1.91を用いました。1.92ではオプション`--lossy`が使えるようになります。  
![](https://raw.githubusercontent.com/yKesamaru/CLI-comparison_Video-to-GIF-conversion/master/img/case1togifsicle.png)  
![](https://raw.githubusercontent.com/yKesamaru/CLI-comparison_Video-to-GIF-conversion/master/img/cost_case1togifsicle.png)  
ピンクの網掛け部分がGifsicleによる処理結果部分です。  
Gifsicle2-1とGifsicle2-2の画質  
![](https://raw.githubusercontent.com/yKesamaru/CLI-comparison_Video-to-GIF-conversion/master/img/GIFSICLE2-1_START-END=2280.jpg)
![](https://raw.githubusercontent.com/yKesamaru/CLI-comparison_Video-to-GIF-conversion/master/img/GIFSICLE2-2_START-END=5860.jpg)  
Gifsicle以外と比べて非常に成績が悪かったため^[Gifsicleの性能が出なかったのは想定された使用方法とは異なるからと思います。]以降Gifsicleの結果は外します。  
  
`--lossy`オプションがない状態で作成された各GIFファイルに適用した結果、サイズ変化は誤差の範囲でした。  
```bash
gifsicle --colors 256 --optimize=3 --batch -i *.gif
```
- gifsicle適用前
![](https://raw.githubusercontent.com/yKesamaru/CLI-comparison_Video-to-GIF-conversion/master/img/no_gifsicle.jpg)
- gifsicle適用後
![](https://raw.githubusercontent.com/yKesamaru/CLI-comparison_Video-to-GIF-conversion/master/img/gifsicle.jpg)  
  

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
共通。改善点を教えて頂けると嬉しいです。  
- ffmpeg
  - `-threads 0` (デフォルトは`slice+frame`。`-threads 0 -thread_type frame`も可)
- pngquant
  - GNU parallel
- ほか
# 結果1: コードと拡大画像の見た目比較
- `${FILE}`
  - インプットされる動画ファイル
- `${FPS}`
  - 設定したいFPS
- `${WIDTH}`
  - 設定したい横幅
## CASE1
基本形。画像の粗さがかえってノスタルジーな気分にさせる。
```bash
ffmpeg -threads 0 -i "${FILE}" -vf "fps=${FPS},scale=${WIDTH}:(ow/a/2)*2:flags=lanczos" -loop 0 -y output.gif
```
![](https://raw.githubusercontent.com/yKesamaru/CLI-comparison_Video-to-GIF-conversion/master/img/1_START-END=1310.jpg)  
*1秒310, 3.3 MB, 一部領域を拡大*
![](https://raw.githubusercontent.com/yKesamaru/CLI-comparison_Video-to-GIF-conversion/master/img/case1-1.png)  
![](https://raw.githubusercontent.com/yKesamaru/CLI-comparison_Video-to-GIF-conversion/master/img/case1-2.png)  
## CASE2
基本形の発展型。画質が綺麗。サイズ大きい。時間ははやい。尺がある場合使用をためらうタイプ。
- ffmpeg
  - palettegen
    - `stats_mode=full`(Default)
  - paletteuse
    - `dither=sierra2_4a`(Default)
    - `diff_mode=none`(Default)
```bash
ffmpeg -threads 0 -i "${FILE}" -lavfi "fps=${FPS},scale=${WIDTH}:(ow/a/2)*2:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse" -loop 0 -y output.gif
```
![](https://raw.githubusercontent.com/yKesamaru/CLI-comparison_Video-to-GIF-conversion/master/img/2_START-END=4310.jpg)  
*4秒310, 7.2 MB, 一部領域を拡大*
![](https://raw.githubusercontent.com/yKesamaru/CLI-comparison_Video-to-GIF-conversion/master/img/case2-1.png)  
![](https://raw.githubusercontent.com/yKesamaru/CLI-comparison_Video-to-GIF-conversion/master/img/case2-2.png)  
## CASE3-1
`stats_mode=diff`は前景の動きが激しい場合に用います。`bayer_scale=*1*`だと画質は荒くコスト高い。実験用にわざとこうしました。
- ffmpeg
  - palettegen
    - `stats_mode=diff`
  - paletteuse
    - `dither=bayer`
    - `bayer_scale=1`
    - `diff_mode=rectangle`
```bash
ffmpeg -threads 0 -i $FILE -vf "palettegen=stats_mode=diff" -y palette.png
ffmpeg -threads 0 -i $FILE -i palette.png -lavfi "fps=${FPS},scale=${WIDTH}:(ow/a/2)*2:flags=lanczos [x]; [x][1:v]\
    paletteuse=dither=bayer:bayer_scale=1:diff_mode=rectangle"\
    -y -loop 0 output.gif
```
![](https://raw.githubusercontent.com/yKesamaru/CLI-comparison_Video-to-GIF-conversion/master/img/3-1_START-END=13650.jpg)  
*13秒650, 6.9 MB, 一部領域を拡大*
![](https://raw.githubusercontent.com/yKesamaru/CLI-comparison_Video-to-GIF-conversion/master/img/case3-1-1.png)  
![](https://raw.githubusercontent.com/yKesamaru/CLI-comparison_Video-to-GIF-conversion/master/img/case3-1-2.png)  
## CASE3-2
3-1との違いは`bayer_scale`値。case3-1に比べ僅かにサイズが小さくなる。時間は同じ様に長い。
- ffmpeg
  - palettegen
    - `stats_mode=diff`
  - paletteuse
    - `dither=bayer`
    - `bayer_scale=5`
    - `diff_mode=rectangle`
```bash
ffmpeg -threads 0 -i $FILE -vf "palettegen=stats_mode=diff" -y palette.png
ffmpeg -threads 0 -i $FILE -i palette.png -lavfi "fps=${FPS},scale=${WIDTH}:(ow/a/2)*2:flags=lanczos [x]; [x][1:v]\
    paletteuse=dither=bayer:bayer_scale=5:diff_mode=rectangle"\
    -y -loop 0 output.gif
```
![](https://raw.githubusercontent.com/yKesamaru/CLI-comparison_Video-to-GIF-conversion/master/img/3-2_START-END=13940.jpg)  
*13秒940, 6.2 MB, 一部領域を拡大*
![](https://raw.githubusercontent.com/yKesamaru/CLI-comparison_Video-to-GIF-conversion/master/img/case3-2-1.png)  
![](https://raw.githubusercontent.com/yKesamaru/CLI-comparison_Video-to-GIF-conversion/master/img/case3-2-2.png)  
## CASE3-3
画質は良い方。処理時間は長い。サイズ大きい。コスト高い。
- ffmpeg
  - palettegen
    - `stats_mode=diff`
  - paletteuse
    - `dither=floyd_steinberg`
```bash
ffmpeg -threads 0 -i $FILE -vf "palettegen=stats_mode=diff" -y palette.png
ffmpeg -threads 0 -i $FILE -i palette.png -lavfi "fps=${FPS},scale=${WIDTH}:(ow/a/2)*2:flags=lanczos [x]; [x][1:v]\
    paletteuse=dither=floyd_steinberg"\
    -y -loop 0 output.gif
```
![](https://raw.githubusercontent.com/yKesamaru/CLI-comparison_Video-to-GIF-conversion/master/img/3-3_START-END=14430.jpg)  
*14秒430, 6.9 MB, 一部領域を拡大*
![](https://raw.githubusercontent.com/yKesamaru/CLI-comparison_Video-to-GIF-conversion/master/img/case3-3-1.png)  
![](https://raw.githubusercontent.com/yKesamaru/CLI-comparison_Video-to-GIF-conversion/master/img/case3-3-2.png)  
## CASE4-1
サイズとても小さい。時間短い。コスト低い。画質が荒い。一時ファイルを大量に作るタイプ。  
- pngquant
  - `quality=0-5`
```bash
mkdir '.tmp'
ffmpeg -threads 0 -i "${FILE}" -vf "fps=${FPS},scale=${WIDTH}:(ow/a/2)*2:flags=lanczos" .tmp/%04d.png 
find .tmp/ -maxdepth 1 -type f -name '*.png' -not -name '*fs8.png' -print0 | parallel -0 pngquant --quality=0-5 {}
convert .tmp/*fs8.png -loop 0 output.gif
rm -r '.tmp'
```
![](https://raw.githubusercontent.com/yKesamaru/CLI-comparison_Video-to-GIF-conversion/master/img/4-1_START-END=5580.jpg)  
*5秒580, 3.5 MB, 一部領域を拡大*
![](https://raw.githubusercontent.com/yKesamaru/CLI-comparison_Video-to-GIF-conversion/master/img/case4-1-1.png)  
![](https://raw.githubusercontent.com/yKesamaru/CLI-comparison_Video-to-GIF-conversion/master/img/case4-1-2.png)  
## CASE4-2
過去記事にも書いた通り、ここらへんは良いと思ってました。速いしサイズも小さくてコストが低い。
- pngquant
  - `quality=0-20`
```bash
mkdir '.tmp'
ffmpeg -threads 0 -i "${FILE}" -vf "fps=${FPS},scale=${WIDTH}:(ow/a/2)*2:flags=lanczos" .tmp/%04d.png 
find .tmp/ -maxdepth 1 -type f -name '*.png' -not -name '*fs8.png' -print0 | parallel -0 pngquant --quality=0-20 {}
convert .tmp/*fs8.png -loop 0 output.gif
rm -r '.tmp'
```
![](https://raw.githubusercontent.com/yKesamaru/CLI-comparison_Video-to-GIF-conversion/master/img/4-2_START-END=6020.jpg)  
*6秒020, 4.6 MB, 一部領域を拡大*
![](https://raw.githubusercontent.com/yKesamaru/CLI-comparison_Video-to-GIF-conversion/master/img/case4-2-1.png)  
![](https://raw.githubusercontent.com/yKesamaru/CLI-comparison_Video-to-GIF-conversion/master/img/case4-2-2.png)  
## CASE4-3
おすすめ。画質・サイズ・速度・コスト全てにおいて良いバランスです。  
- pngquant
  - `quality=0-40`
```bash
mkdir '.tmp'
ffmpeg -threads 0 -i "${FILE}" -vf "fps=${FPS},scale=${WIDTH}:(ow/a/2)*2:flags=lanczos" .tmp/%04d.png 
find .tmp/ -maxdepth 1 -type f -name '*.png' -not -name '*fs8.png' -print0 | parallel -0 pngquant --quality=0-40 {}
convert .tmp/*fs8.png -loop 0 output.gif
rm -r '.tmp'
```
![](https://raw.githubusercontent.com/yKesamaru/CLI-comparison_Video-to-GIF-conversion/master/img/4-3_START-END=6260.jpg)  
*6秒260, 5.3 MB, 一部領域を拡大*
![](https://raw.githubusercontent.com/yKesamaru/CLI-comparison_Video-to-GIF-conversion/master/img/case4-3-1.png)  
![](https://raw.githubusercontent.com/yKesamaru/CLI-comparison_Video-to-GIF-conversion/master/img/case4-3-2.png)  
## CASE4-4
処理時間は全検証中真ん中くらい。画質は綺麗。サイズ大きめ。
- pngquant
  - `quality=0-60`
```bash
mkdir '.tmp'
ffmpeg -threads 0 -i "${FILE}" -vf "fps=${FPS},scale=${WIDTH}:(ow/a/2)*2:flags=lanczos" .tmp/%04d.png 
find .tmp/ -maxdepth 1 -type f -name '*.png' -not -name '*fs8.png' -print0 | parallel -0 pngquant --quality=0-60 {}
convert .tmp/*fs8.png -loop 0 output.gif
rm -r '.tmp'
```
![](https://raw.githubusercontent.com/yKesamaru/CLI-comparison_Video-to-GIF-conversion/master/img/4-4_START-END=7340.jpg)  
*7秒340, 6.6 MB, 一部領域を拡大*
![](https://raw.githubusercontent.com/yKesamaru/CLI-comparison_Video-to-GIF-conversion/master/img/case4-4-1.png)  
![](https://raw.githubusercontent.com/yKesamaru/CLI-comparison_Video-to-GIF-conversion/master/img/case4-4-2.png)  
## CASE5
convertコマンドに`layer optimize`をつけました。処理時間長い感じでサイズは大きくなります。コスト大きい。
- pngquant
  - `quality=0-60`
- convert
  - `layers optimize`
```bash
mkdir '.tmp'
ffmpeg -threads 0 -i "${FILE}" -vf "fps=${FPS},scale=${WIDTH}:(ow/a/2)*2:flags=lanczos" .tmp/%04d.png 
find .tmp/ -maxdepth 1 -type f -name '*.png' -not -name '*fs8.png' -print0 | parallel -0 pngquant --quality=0-60 {}
convert .tmp/*fs8.png -loop 0 -layers optimize output.gif
rm -r '.tmp'
```
![](https://raw.githubusercontent.com/yKesamaru/CLI-comparison_Video-to-GIF-conversion/master/img/5_START-END=10850.jpg)  
*10秒850, 7.8 MB, 一部領域を拡大*
![](https://raw.githubusercontent.com/yKesamaru/CLI-comparison_Video-to-GIF-conversion/master/img/case5-1.png)  
![](https://raw.githubusercontent.com/yKesamaru/CLI-comparison_Video-to-GIF-conversion/master/img/case5-2.png)  
## CASE6
処理速度は速い方。サイズ大きい。
- convert
  - `layers optimize`
```bash
ffmpeg -threads 0 -i "${FILE}" -vf "fps=${FPS},scale=${WIDTH}:(ow/a/2)*2:flags=lanczos" -c:v pam -f image2pipe - | convert -delay $((100 / ${FPS})) - -loop 0 -layers optimize output.gif
```
![](https://raw.githubusercontent.com/yKesamaru/CLI-comparison_Video-to-GIF-conversion/master/img/6_START-END=5330.jpg)  
*5秒330, 8.0 MB, 一部領域を拡大*
![](https://raw.githubusercontent.com/yKesamaru/CLI-comparison_Video-to-GIF-conversion/master/img/case6-1.png)  
![](https://raw.githubusercontent.com/yKesamaru/CLI-comparison_Video-to-GIF-conversion/master/img/case6-2.png)  
  
# 結果2: GIF動画の見た目比較
検証のため重いGIFを貼り付けています。ご了承ください。  
## CASE1
![](https://raw.githubusercontent.com/yKesamaru/CLI-comparison_Video-to-GIF-conversion/master/img/1_START-END=1310.gif) 
## CASE2
![](https://raw.githubusercontent.com/yKesamaru/CLI-comparison_Video-to-GIF-conversion/master/img/2_START-END=4310.gif)
## CASE3-1
![](https://raw.githubusercontent.com/yKesamaru/CLI-comparison_Video-to-GIF-conversion/master/img/3-1_START-END=13650.gif)
## CASE3-2
![](https://raw.githubusercontent.com/yKesamaru/CLI-comparison_Video-to-GIF-conversion/master/img/3-2_START-END=13940.gif)
## CASE3-3
![](https://raw.githubusercontent.com/yKesamaru/CLI-comparison_Video-to-GIF-conversion/master/img/3-3_START-END=14430.gif)
## CASE4-1
![](https://raw.githubusercontent.com/yKesamaru/CLI-comparison_Video-to-GIF-conversion/master/img/4-1_START-END=5580.gif)
## CASE4-2
![](https://raw.githubusercontent.com/yKesamaru/CLI-comparison_Video-to-GIF-conversion/master/img/4-2_START-END=6020.gif)
## CASE4-3
![](https://raw.githubusercontent.com/yKesamaru/CLI-comparison_Video-to-GIF-conversion/master/img/4-3_START-END=6260.gif)
## CASE4-4
![](https://raw.githubusercontent.com/yKesamaru/CLI-comparison_Video-to-GIF-conversion/master/img/4-4_START-END=7340.gif)
## CASE5
![](https://raw.githubusercontent.com/yKesamaru/CLI-comparison_Video-to-GIF-conversion/master/img/5_START-END=10850.gif)
## CASE6
![](https://raw.githubusercontent.com/yKesamaru/CLI-comparison_Video-to-GIF-conversion/master/img/6_START-END=5330.gif)


# 次点と思われるもの
case4-4、その次がcase2。case2はサイズが大きいので注意が必要です。
```bash:case4-4
#!/bin/bash

# 初期設定 ###########
FPS=10
WIDTH=600
FILE="input.mp4"
# ####################

mkdir '.tmp'
ffmpeg -threads 0 -i "${FILE}" -vf "fps=${FPS},scale=${WIDTH}:(ow/a/2)*2:flags=lanczos" .tmp/%04d.png 
find .tmp/ -maxdepth 1 -type f -name '*.png' -not -name '*fs8.png' -print0 | parallel -0 pngquant --quality=0-60 {}
convert .tmp/*fs8.png -loop 0 output.gif
rm .tmp/*.png
```
```bash:case2
ffmpeg -threads 0 -i "${FILE}" -vf "fps=${FPS},scale=${WIDTH}:(ow/a/2)*2:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse" -loop 0 -y output.gif
```

  
# 今後の改善点
- Gifsicle1.92以降の`-lossy`をつけた場合のサイズ・画質変化の調査
  
  
# Install
```bash:Ubuntu
sudo install gifsicle parallel ffmpeg imagemagick pngquant pulseaudio-utils libnotify-bin
```
https://github.com/yKesamaru/CLI-comparison_Video-to-GIF-conversion
# 全体のコード
:::details code
```bash
#!/bin/bash

# 初期設定 ###########
FPS=10
WIDTH=600
FILE="input.mp4"
# ####################


CASE="GIFSICLE1-1"
set_START() { local dummy; read START dummy < /proc/uptime; }; get_ELAPS() { local dummy; read END dummy < /proc/uptime; let ELAPS=${END/./}0-${START/./}0; }; time { set_START; }; START=$START;
ffmpeg -threads 0 -t 5 -i "${FILE}" -pix_fmt rgb8 -f gif - | gifsicle --loopcount=0 --resize-width ${WIDTH} --resize-method mix --optimize=3 > output.gif
time { get_ELAPS; }; END=$END; ELAPS=START-END=$ELAPS; mv output.gif ${CASE}_${ELAPS}.gif;
convert ${CASE}_${ELAPS}.gif[0] gif:- | convert -crop 200x100+200+50 gif:- ${CASE}_${ELAPS}.jpg; 


CASE="GIFSICLE1-2"
set_START() { local dummy; read START dummy < /proc/uptime; }; get_ELAPS() { local dummy; read END dummy < /proc/uptime; let ELAPS=${END/./}0-${START/./}0; }; time { set_START; }; START=$START;
ffmpeg -threads 0 -t 5 -i "${FILE}" -pix_fmt rgb8 -f gif - | gifsicle --loopcount=0 --resize-width ${WIDTH} --resize-method mix --optimize=2 > output.gif
time { get_ELAPS; }; END=$END; ELAPS=START-END=$ELAPS; mv output.gif ${CASE}_${ELAPS}.gif;
convert ${CASE}_${ELAPS}.gif[0] gif:- | convert -crop 200x100+200+50 gif:- ${CASE}_${ELAPS}.jpg; 


CASE="GIFSICLE1-3"
set_START() { local dummy; read START dummy < /proc/uptime; }; get_ELAPS() { local dummy; read END dummy < /proc/uptime; let ELAPS=${END/./}0-${START/./}0; }; time { set_START; }; START=$START;
ffmpeg -threads 0 -t 5 -i "${FILE}" -pix_fmt rgb8 -f gif - | gifsicle --loopcount=0 --resize-width ${WIDTH} --resize-method sample --optimize=1 > output.gif
time { get_ELAPS; }; END=$END; ELAPS=START-END=$ELAPS; mv output.gif ${CASE}_${ELAPS}.gif;
convert ${CASE}_${ELAPS}.gif[0] gif:- | convert -crop 200x100+200+50 gif:- ${CASE}_${ELAPS}.jpg; 


CASE="GIFSICLE1-4"
set_START() { local dummy; read START dummy < /proc/uptime; }; get_ELAPS() { local dummy; read END dummy < /proc/uptime; let ELAPS=${END/./}0-${START/./}0; }; time { set_START; }; START=$START;
ffmpeg -threads 0 -t 5 -i "${FILE}" -pix_fmt rgb8 -f gif - | gifsicle --loopcount=0 --resize-width ${WIDTH} --resize-method box --optimize=1 > output.gif
time { get_ELAPS; }; END=$END; ELAPS=START-END=$ELAPS; mv output.gif ${CASE}_${ELAPS}.gif;
convert ${CASE}_${ELAPS}.gif[0] gif:- | convert -crop 200x100+200+50 gif:- ${CASE}_${ELAPS}.jpg; 


CASE="GIFSICLE1-5"
set_START() { local dummy; read START dummy < /proc/uptime; }; get_ELAPS() { local dummy; read END dummy < /proc/uptime; let ELAPS=${END/./}0-${START/./}0; }; time { set_START; }; START=$START;
ffmpeg -threads 0 -t 5 -i "${FILE}" -pix_fmt rgb8 -f gif - | gifsicle --loopcount=0 --resize-width ${WIDTH} --resize-method lanczos3 --optimize=1 > output.gif
time { get_ELAPS; }; END=$END; ELAPS=START-END=$ELAPS; mv output.gif ${CASE}_${ELAPS}.gif;
convert ${CASE}_${ELAPS}.gif[0] gif:- | convert -crop 200x100+200+50 gif:- ${CASE}_${ELAPS}.jpg; 


CASE="GIFSICLE1-6"
set_START() { local dummy; read START dummy < /proc/uptime; }; get_ELAPS() { local dummy; read END dummy < /proc/uptime; let ELAPS=${END/./}0-${START/./}0; }; time { set_START; }; START=$START;
ffmpeg -threads 0 -t 5 -i "${FILE}" -pix_fmt rgb8 -f gif - | gifsicle --loopcount=0 --resize-width ${WIDTH} --resize-method mix --dither=floyd-steinberg --optimize=1 > output.gif
time { get_ELAPS; }; END=$END; ELAPS=START-END=$ELAPS; mv output.gif ${CASE}_${ELAPS}.gif;
convert ${CASE}_${ELAPS}.gif[0] gif:- | convert -crop 200x100+200+50 gif:- ${CASE}_${ELAPS}.jpg; 


CASE="GIFSICLE2-1"
set_START() { local dummy; read START dummy < /proc/uptime; }; get_ELAPS() { local dummy; read END dummy < /proc/uptime; let ELAPS=${END/./}0-${START/./}0; }; time { set_START; }; START=$START;
ffmpeg -threads 0 -t 5 -i "${FILE}" -vf "fps=${FPS},scale=${WIDTH}:(ow/a/2)*2:flags=lanczos" -pix_fmt rgb8 -f gif - | gifsicle --loopcount=0 --optimize=3 > output.gif
time { get_ELAPS; }; END=$END; ELAPS=START-END=$ELAPS; mv output.gif ${CASE}_${ELAPS}.gif;
convert ${CASE}_${ELAPS}.gif[0] gif:- | convert -crop 200x100+200+50 gif:- ${CASE}_${ELAPS}.jpg; 


CASE="GIFSICLE2-2"
set_START() { local dummy; read START dummy < /proc/uptime; }; get_ELAPS() { local dummy; read END dummy < /proc/uptime; let ELAPS=${END/./}0-${START/./}0; }; time { set_START; }; START=$START;
ffmpeg -threads 0 -t 5 -i "${FILE}" -vf "fps=${FPS},scale=${WIDTH}:(ow/a/2)*2:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse" -pix_fmt rgb8 -f gif - | gifsicle --loopcount=0 --optimize=3 > output.gif
time { get_ELAPS; }; END=$END; ELAPS=START-END=$ELAPS; mv output.gif ${CASE}_${ELAPS}.gif;
convert ${CASE}_${ELAPS}.gif[0] gif:- | convert -crop 200x100+200+50 gif:- ${CASE}_${ELAPS}.jpg; 


# CASE="TEST1"
# set_START() { local dummy; read START dummy < /proc/uptime; }; get_ELAPS() { local dummy; read END dummy < /proc/uptime; let ELAPS=${END/./}0-${START/./}0; }; time { set_START; }; START=$START;
# ffmpeg -threads 0 -t 5 -i $FILE -vf "palettegen=stats_mode=diff" -y palette.png
# ffmpeg -threads 0 -t 5 -i $FILE -i palette.png -lavfi "fps=${FPS},scale=${WIDTH}:(ow/a/2)*2:flags=lanczos [x]; [x][1:v]\
#     paletteuse=dither=bayer:bayer_scale=1:diff_mode=rectangle"\
#     -y -loop 0 output.gif
# gifsicle --loopcount=0 --optimize=3 output.gif
# time { get_ELAPS; }; END=$END; ELAPS=START-END=$ELAPS; mv output.gif ${CASE}_${ELAPS}.gif; 
# convert ${CASE}_${ELAPS}.gif[0] gif:- | convert -crop 200x100+200+50 gif:- ${CASE}_${ELAPS}.jpg; 


# Gifsicle other options ------------------------------- <Gifsicle1.91のコストが高いため検証から除外>
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
# ------------------------------------------------------


CASE="1"
set_START() { local dummy; read START dummy < /proc/uptime; }; get_ELAPS() { local dummy; read END dummy < /proc/uptime; let ELAPS=${END/./}0-${START/./}0; }; time { set_START; }; START=$START;
ffmpeg -threads 0 -t 5 -i "${FILE}" -vf "fps=${FPS},scale=${WIDTH}:(ow/a/2)*2:flags=lanczos" -loop 0 -y output.gif
time { get_ELAPS; }; END=$END; ELAPS=START-END=$ELAPS; mv output.gif ${CASE}_${ELAPS}.gif;
convert ${CASE}_${ELAPS}.gif[0] gif:- | convert -crop 200x100+200+50 gif:- ${CASE}_${ELAPS}.jpg; 


CASE="2"
set_START() { local dummy; read START dummy < /proc/uptime; }; get_ELAPS() { local dummy; read END dummy < /proc/uptime; let ELAPS=${END/./}0-${START/./}0; }; time { set_START; }; START=$START;
ffmpeg -threads 0 -t 5 -i "${FILE}" -vf "fps=${FPS},scale=${WIDTH}:(ow/a/2)*2:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse" -loop 0 -y output.gif
time { get_ELAPS; }; END=$END; ELAPS=START-END=$ELAPS; mv output.gif ${CASE}_${ELAPS}.gif;
convert ${CASE}_${ELAPS}.gif[0] gif:- | convert -crop 200x100+200+50 gif:- ${CASE}_${ELAPS}.jpg; 


CASE="3-1"
set_START() { local dummy; read START dummy < /proc/uptime; }; get_ELAPS() { local dummy; read END dummy < /proc/uptime; let ELAPS=${END/./}0-${START/./}0; }; time { set_START; }; START=$START;
ffmpeg -threads 0 -t 5 -i $FILE -vf "palettegen=stats_mode=diff" -y palette.png
ffmpeg -threads 0 -t 5 -i $FILE -i palette.png -lavfi "fps=${FPS},scale=${WIDTH}:(ow/a/2)*2:flags=lanczos [x]; [x][1:v]\
    paletteuse=dither=bayer:bayer_scale=1:diff_mode=rectangle"\
    -y -loop 0 output.gif
time { get_ELAPS; }; END=$END; ELAPS=START-END=$ELAPS; mv output.gif ${CASE}_${ELAPS}.gif; 
convert ${CASE}_${ELAPS}.gif[0] gif:- | convert -crop 200x100+200+50 gif:- ${CASE}_${ELAPS}.jpg; 


CASE="3-2"
set_START() { local dummy; read START dummy < /proc/uptime; }; get_ELAPS() { local dummy; read END dummy < /proc/uptime; let ELAPS=${END/./}0-${START/./}0; }; time { set_START; }; START=$START;
ffmpeg -threads 0 -t 5 -i $FILE -vf "palettegen=stats_mode=diff" -y palette.png
ffmpeg -threads 0 -t 5 -i $FILE -i palette.png -lavfi "fps=${FPS},scale=${WIDTH}:(ow/a/2)*2:flags=lanczos [x]; [x][1:v]\
    paletteuse=dither=bayer:bayer_scale=5:diff_mode=rectangle"\
    -y -loop 0 output.gif
time { get_ELAPS; }; END=$END; ELAPS=START-END=$ELAPS; mv output.gif ${CASE}_${ELAPS}.gif;
convert ${CASE}_${ELAPS}.gif[0] gif:- | convert -crop 200x100+200+50 gif:- ${CASE}_${ELAPS}.jpg; 


CASE="3-3"
set_START() { local dummy; read START dummy < /proc/uptime; }; get_ELAPS() { local dummy; read END dummy < /proc/uptime; let ELAPS=${END/./}0-${START/./}0; }; time { set_START; }; START=$START;
ffmpeg -threads 0 -t 5 -i $FILE -vf "palettegen=stats_mode=diff" -y palette.png
ffmpeg -threads 0 -t 5 -i $FILE -i palette.png -lavfi "fps=${FPS},scale=${WIDTH}:(ow/a/2)*2:flags=lanczos [x]; [x][1:v]\
    paletteuse=dither=floyd_steinberg"\
    -y -loop 0 output.gif
time { get_ELAPS; }; END=$END; ELAPS=START-END=$ELAPS; mv output.gif ${CASE}_${ELAPS}.gif; 
convert ${CASE}_${ELAPS}.gif[0] gif:- | convert -crop 200x100+200+50 gif:- ${CASE}_${ELAPS}.jpg; 


CASE="4-1"
set_START() { local dummy; read START dummy < /proc/uptime; }; get_ELAPS() { local dummy; read END dummy < /proc/uptime; let ELAPS=${END/./}0-${START/./}0; }; time { set_START; }; START=$START;
mkdir '.tmp'
ffmpeg -threads 0 -t 5 -i "${FILE}" -vf "fps=${FPS},scale=${WIDTH}:(ow/a/2)*2:flags=lanczos" .tmp/%04d.png 
find .tmp/ -maxdepth 1 -type f -name '*.png' -not -name '*fs8.png' -print0 | parallel -0 pngquant --quality=0-5 {}
convert .tmp/*fs8.png -loop 0 output.gif
rm .tmp/*.png
time { get_ELAPS; }; END=$END; ELAPS=START-END=$ELAPS; mv output.gif ${CASE}_${ELAPS}.gif;
convert ${CASE}_${ELAPS}.gif[0] gif:- | convert -crop 200x100+200+50 gif:- ${CASE}_${ELAPS}.jpg; 


CASE="4-2"
set_START() { local dummy; read START dummy < /proc/uptime; }; get_ELAPS() { local dummy; read END dummy < /proc/uptime; let ELAPS=${END/./}0-${START/./}0; }; time { set_START; }; START=$START;
mkdir '.tmp'
ffmpeg -threads 0 -t 5 -i "${FILE}" -vf "fps=${FPS},scale=${WIDTH}:(ow/a/2)*2:flags=lanczos" .tmp/%04d.png 
find .tmp/ -maxdepth 1 -type f -name '*.png' -not -name '*fs8.png' -print0 | parallel -0 pngquant --quality=0-20 {}
convert .tmp/*fs8.png -loop 0 output.gif
rm .tmp/*.png
time { get_ELAPS; }; END=$END; ELAPS=START-END=$ELAPS; mv output.gif ${CASE}_${ELAPS}.gif;
convert ${CASE}_${ELAPS}.gif[0] gif:- | convert -crop 200x100+200+50 gif:- ${CASE}_${ELAPS}.jpg; 


CASE="4-3"
set_START() { local dummy; read START dummy < /proc/uptime; }; get_ELAPS() { local dummy; read END dummy < /proc/uptime; let ELAPS=${END/./}0-${START/./}0; }; time { set_START; }; START=$START;
mkdir '.tmp'
ffmpeg -threads 0 -t 5 -i "${FILE}" -vf "fps=${FPS},scale=${WIDTH}:(ow/a/2)*2:flags=lanczos" .tmp/%04d.png 
find .tmp/ -maxdepth 1 -type f -name '*.png' -not -name '*fs8.png' -print0 | parallel -0 pngquant --quality=0-40 {}
convert .tmp/*fs8.png -loop 0 output.gif
rm .tmp/*.png
time { get_ELAPS; }; END=$END; ELAPS=START-END=$ELAPS; mv output.gif ${CASE}_${ELAPS}.gif;
convert ${CASE}_${ELAPS}.gif[0] gif:- | convert -crop 200x100+200+50 gif:- ${CASE}_${ELAPS}.jpg; 


CASE="4-4"
set_START() { local dummy; read START dummy < /proc/uptime; }; get_ELAPS() { local dummy; read END dummy < /proc/uptime; let ELAPS=${END/./}0-${START/./}0; }; time { set_START; }; START=$START;
mkdir '.tmp'
ffmpeg -threads 0 -t 5 -i "${FILE}" -vf "fps=${FPS},scale=${WIDTH}:(ow/a/2)*2:flags=lanczos" .tmp/%04d.png 
find .tmp/ -maxdepth 1 -type f -name '*.png' -not -name '*fs8.png' -print0 | parallel -0 pngquant --quality=0-60 {}
convert .tmp/*fs8.png -loop 0 output.gif
rm .tmp/*.png
time { get_ELAPS; }; END=$END; ELAPS=START-END=$ELAPS; mv output.gif ${CASE}_${ELAPS}.gif;
convert ${CASE}_${ELAPS}.gif[0] gif:- | convert -crop 200x100+200+50 gif:- ${CASE}_${ELAPS}.jpg; 


CASE="5"
set_START() { local dummy; read START dummy < /proc/uptime; }; get_ELAPS() { local dummy; read END dummy < /proc/uptime; let ELAPS=${END/./}0-${START/./}0; }; time { set_START; }; START=$START;
mkdir '.tmp'
ffmpeg -threads 0 -t 5 -i "${FILE}" -vf "fps=${FPS},scale=${WIDTH}:(ow/a/2)*2:flags=lanczos" .tmp/%04d.png 
find .tmp/ -maxdepth 1 -type f -name '*.png' -not -name '*fs8.png' -print0 | parallel -0 pngquant --quality=0-60 {}
convert .tmp/*fs8.png -loop 0 -layers optimize output.gif
rm .tmp/*.png
time { get_ELAPS; }; END=$END; ELAPS=START-END=$ELAPS; mv output.gif ${CASE}_${ELAPS}.gif; 
convert ${CASE}_${ELAPS}.gif[0] gif:- | convert -crop 200x100+200+50 gif:- ${CASE}_${ELAPS}.jpg; 


CASE="6"
set_START() { local dummy; read START dummy < /proc/uptime; }; get_ELAPS() { local dummy; read END dummy < /proc/uptime; let ELAPS=${END/./}0-${START/./}0; }; time { set_START; }; START=$START;
ffmpeg -threads 0 -t 5 -i "${FILE}" -vf "fps=${FPS},scale=${WIDTH}:(ow/a/2)*2:flags=lanczos" -c:v pam -f image2pipe - | convert -delay $((100 / ${FPS})) - -loop 0 -layers optimize output.gif
time { get_ELAPS; }; END=$END; ELAPS=START-END=$ELAPS; mv output.gif ${CASE}_${ELAPS}.gif;
convert ${CASE}_${ELAPS}.gif[0] gif:- | convert -crop 200x100+200+50 gif:- ${CASE}_${ELAPS}.jpg; 


paplay "Positive.ogg"
notify-send "Measurement test" "Done."
```
:::
# Reference
https://qiita.com/yoya/items/6bacfe84cd49237aea27
https://qiita.com/yusuga/items/ba7b5c2cac3f2928f040
https://nico-lab.net/optimized_256_colors_with_ffmpeg/
https://superuser.com/questions/556029/how-do-i-convert-a-video-to-gif-using-ffmpeg-with-reasonable-quality/556031#556031
https://ffmpeg.org/ffmpeg-filters.html
http://blog.pkh.me/p/21-high-quality-gif-with-ffmpeg.html
https://github.com/kohler/gifsicle
http://www.gnu.org/software/parallel/parallel.html#EXAMPLE:-Working-as-xargs--n1.-Argument-appending
FFmpegのリサイズで参考にさせて頂きました。
https://zenn.dev/mattak/articles/817ee679a6c080