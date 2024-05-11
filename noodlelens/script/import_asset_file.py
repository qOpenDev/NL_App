import os
from pathlib import Path

HOME_DIR = Path(__file__).resolve().parent
BASE_DIR = Path(__file__).resolve().parent.parent
ASSET_DIR = os.path.join(BASE_DIR, 'assets/')
NOODLE_IMAGE_DIR = os.path.join(ASSET_DIR, 'noodle_images/')
TFLITE_DIR = os.path.join(ASSET_DIR, 'tflite/')
DB_DIR = os.path.join(ASSET_DIR, 'db/')


def create_directory():
    """
    assetディレクトリを作成
    :return:
    """
    if not os.path.exists(ASSET_DIR):
        try:
            os.mkdir(ASSET_DIR)
        except Exception as ex:
            error(f'{ASSET_DIR}を作成できません. {ex}')

    if not os.path.exists(NOODLE_IMAGE_DIR):
        try:
            os.mkdir(NOODLE_IMAGE_DIR)
        except Exception as ex:
            error(f'{NOODLE_IMAGE_DIR}を作成できません. {ex}')

    if not os.path.exists(TFLITE_DIR):
        try:
            os.mkdir(TFLITE_DIR)
        except Exception as ex:
            error(f'{TFLITE_DIR}を作成できません. {ex}')

    if not os.path.exists(DB_DIR):
        try:
            os.mkdir(DB_DIR)
        except Exception as ex:
            error(f'{DB_DIR}を作成できません. {ex}')


def copy_image():
    """
    カップ麺商品画像をコピー
    :return:
    """


def error(msg):
    print(f'[ERROR] {msg}')


if __name__ == '__main__':
    os.chdir(HOME_DIR)

    create_directory()

