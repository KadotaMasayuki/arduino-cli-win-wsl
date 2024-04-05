# arduino-cli-win-wsl

## 結論

windows上でarduino-cli.exeを実行すると遅い。
wsl内にarduino-cli実行ファイルとライブラリ一式と生成物置き場を完結させると速い！
wsl上でarduino-cliを実行しても、ライブラリや生成物置き場がwindowsにあると遅い。

```
(wsl) arduino-cli
(wsl) ~/Arduino/library/
(wsl) ~/Arduino/build/
(windows) c:\Users\XXXXX\Arduino\src
```

ソースファイルをwindows上に置いている理由は、単にwindows上でのアクセスのしやすさを考慮しただけ。
windows上にあるソースファイルへのアクセスの遅延はさほど気にならなかったので、windows上に置いた。
wsl上に置いても良い。


M5Stackのサンプルであるfloppybirdをコンパイルした結果

```
$ arduino-cli compile --fqbn m5stack:esp32:m5stack_core2 --build-path build
```

| arduino-cliの所在 | libraryの所在 | buildの所在 | 1回目の所要時間 | touch後2回目の所要時間 |
| --- | --- | --- | --- | --- |
| windows | windows | windows | 140秒 | 95秒 |
| wsl | windows | windows | 147秒 | 60秒 |
| wsl  | wsl | windows | 40.0秒 | 16.9秒 |
| wsl | wsl | wsl | 26.8秒 | 4.2秒 |

wslだとビルドが圧倒的に高速化！

書き込みはwindows上のarduino-cliで行う。

## arduino-cli

```
(windows)$ arduino-cli.exe verion
arduino-cli  Version: 0.35.2 Commit: 01de174c Date: 2024-01-24T11:33:02Z
```

```
(wsl)$ arduino-cli version
arduino-cli  Version: 0.35.3 Commit: 95cfd654 Date: 2024-02-19T13:24:24Z
```

## wsl環境

```
$ cat /etc/os-release
PRETTY_NAME="Debian GNU/Linux 12 (bookworm)"
NAME="Debian GNU/Linux"
VERSION_ID="12"
VERSION="12 (bookworm)"
VERSION_CODENAME=bookworm
ID=debian
HOME_URL="https://www.debian.org/"
SUPPORT_URL="https://www.debian.org/support"
BUG_REPORT_URL="https://bugs.debian.org/"
```

## やりかた(for M5Stack Core2)

### 1. wslを準備

### 2. wslの日時を合わせておく

4月30日20蒔45分なら、

```
(wsl)$ sudo date 04302045
```

 とする。

### 3. wslに環境変数 $http_proxy と $https_proxy を設定しておく

```
cat << EOS >> ~/.profile

export http_proxy=http://12.3.45.67:9999
export https_proxy=http://1.23.45.67.8901
EOS
source .profile
```

### 4. 必要なツールをインストールしておく

```
sudo apt-get update
sudo apt-get install ca-certificates curl gnupg
```

### 5. 以下のコマンドを実施

```
mkdir tmp
cd tmp
curl -fsSL https://raw.githubusercontent.com/arduino/arduino-cli/master/install.sh | sh
chmod 0555 bin/arduino-cli/
sudo mv bin/arduino-cli /usr/local/bin/
arduino-cli config init
arduino-cli config add board_manager.additional_urls https://m5stack.oss-cn-shenzhen.aliyuncs.com/resource/arduino/package_m5stack_index.json
arduino-cli config set network.proxy $http_proxy
arduino-cli config dump
arduino-cli core update-index
arduino-cli core list
arduino-cli core search m5
arduino-cli core install m5stack:esp32
arduino-cli core list
arduino-cli board list
arduino-cli board listall
arduino-cli lib list
arduino-cli lib update-index
arduino-cli lib search m5core2
arduino-cli lib install m5core2@0.1.9
arduino-cli lib search tof4m
arduino-cli lib install m5unit-tof4m@1.0.0
```

### 6. コンパイルはwsl上で。生成物はwsl上のbuildディレクトリに出来るようにする

```
(wsl)$ arduino-cli compile --fqbn m5stack:esp32:m5stack_core2 --build-path ~/Arduino/build/SOME-PROJECT SOME-PROJECT
```

bashスクリプトあり。wslのbashで実行。

### 7. 書き込みはwindows上で。wsl上の生成物ディレクトリを指定する

```
(windows)$ arduino-cli upload --port com5 --fqbn m5stack:esp32:m5stack_core2 --input-dir \\wsl.localhost\Debian\home\XXXXX\Arduino\build\SOME-PROJECT
```

batファイルあり。windows上でダブルクリックして実行。
