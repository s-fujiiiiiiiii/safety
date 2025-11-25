import pandas as pd
from rest_framework.views import APIView
from rest_framework.response import Response
from .ai_analyzer import get_congestion_level
from django.conf import settings
import os

class ShelterStatusView(APIView):
    """SNSデータをAIで解析して避難所状況を返す"""

    def get(self, request):
        # 疑似SNSデータを読み込み
        file_path = os.path.join(settings.BASE_DIR, "sns_analyzer", "fake_sns_data.csv")
        df = pd.read_csv(file_path)

        result = []
        for _, row in df.iterrows():
            level = get_congestion_level(row["text"])
            result.append({
                "text": row["text"],
                "location": row["location"],
                "status": level
            })

        return Response(result)
