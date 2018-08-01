# poling-reservation-status

マイルで特典航空券を予約するとき、指定の便の日時に空きが出たらメールで知らせるプログラム

## Setup

### 環境変数の設定

```
JAL_ID: jalログインID
JAL_PW: jalログインパスワード
GMAIL_USER_NAME: メール送信用のgmailアドレス
GMAIL_PW: メール送信用のgmailアプリパスワード
```

### packageのインストール

```
bundle install
```

seleniumエラーが発生するとき
```
bundle update
```

## Usage
```
ruby main.rb 10 28 '東京(羽田)' 10 31 '沖縄(那覇)' 'chngng0103@gmail.com'
```
