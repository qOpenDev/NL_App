# NL_App
スマホアプリの本体

# ビルド方法

1. リポジトリから最新のmainブランチを取得します。
2. https://drive.google.com/drive/folders/1HwLJdS9TXSDC3DKI0HOzaqkgesXylu2L?usp=drive_link から以下のファイルをダウンロードしてFlutterプロジェクトルートにある `/assets/tflite/` にコピーします。
   
   - vgg16_9types.tflite
   - vgg16_9types_labels.txt
     
4. ビルドします。

Androidのターゲットバージョンは
- minSdkVersion 26
- targetSdkVersion 30

です。
