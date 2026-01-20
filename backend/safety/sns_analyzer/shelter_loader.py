import pandas as pd
import os
from django.conf import settings

def load_shelter_master():
    """
    自治体オープンデータ（避難所基本情報）を取得
    """
    file_path = os.path.join(
        settings.BASE_DIR,
        "sns_analyzer",
        "shelters_master.csv"
    )

    df = pd.read_csv(file_path)
    return df.to_dict(orient="records")
