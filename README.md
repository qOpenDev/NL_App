# NL_App
スマホアプリの本体

# ビルド方法

1. リポジトリから最新のmainブランチを取得します。
2. GoogleDriveで https://drive.google.com/drive/folders/1W7aBDtLzCBUIp_Wj_KEaQBjbfbXmJu3P?usp=drive_link を開きます。
3. 開いたGoogleDriveにある `assets` ディレクトリを、取得した `NL_App/noodlelens/` の配下に上書きコピーします。
4. これでアプリをビルド可能です。

`assets` ディレクトリに含まれるリソースは以下の通りです。

- `db/` : カップ麺の翻訳済み商品情報をデータベースに登録するためのjsonファイル。
- `noodle_image/` : `db/` から登録されたデータベースから参照されるカップ麺の画像。
- `tflite/` : 重み学習済み機械学習モデルと、学習済みカップ麺を識別するラベル。
