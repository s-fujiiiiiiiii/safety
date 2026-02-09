from rest_framework.views import APIView
from rest_framework.response import Response
from .models import Shelter
from .serializers import ShelterSerializer

class ShelterListView(APIView):
    def get(self, request):
        shelters = Shelter.objects.all()
        serializer = ShelterSerializer(shelters, many=True)
        return Response(serializer.data)
