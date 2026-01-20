from transformers import pipeline

# シンプルな感情分析モデル（英語中心でも日本語もある程度対応可）
classifier = pipeline("sentiment-analysis")

def get_congestion_level(text):
    """SNS投稿から混雑度を推定"""
    result = classifier(text[:200])[0]  # テキスト長制限
    label = result["label"]
    score = result["score"]

    # シンプルな分類ロジック
    if "NEGATIVE" in label or "悪い" in text or "混んで" in text:
        return "混雑"
    elif "POSITIVE" in label or "空き" in text or "余裕" in text:
        return "空いている"
    else:
        return "普通"
