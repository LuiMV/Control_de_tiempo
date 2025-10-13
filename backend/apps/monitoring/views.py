from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import status
from django.contrib.auth.models import User
from django.contrib.auth import authenticate
from rest_framework.authtoken.models import Token
from rest_framework import viewsets, status
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from django.db.models import Sum
from rest_framework.decorators import action
from .models import UsageRecord
from .serializers import UsageRecordSerializer

# Vista para manejar los registros de uso
class UsageRecordViewSet(viewsets.ModelViewSet):
    permission_classes = [IsAuthenticated]
    serializer_class = UsageRecordSerializer

def get_queryset(self):
        return UsageRecord.objects.filter(user=self.request.user).order_by('-start_time')

def perform_create(self, serializer):
        serializer.save(user=self.request.user)

@action(detail=False, methods=['get'])
def summary(self, request):
    total = UsageRecord.objects.filter(user=request.user).aggregate(total_seconds=Sum('duration_seconds'))['total_seconds'] or 0
    return Response({'total_seconds': total})


# Vista para registrar un nuevo usuario
@api_view(['POST'])
def register(request):
    username = request.data.get('username')
    email = request.data.get('email')
    password = request.data.get('password')

    if not username or not password:
        return Response({'error': 'Username y password son requeridos'}, status=status.HTTP_400_BAD_REQUEST)

    if User.objects.filter(username=username).exists():
        return Response({'error': 'El usuario ya existe'}, status=status.HTTP_400_BAD_REQUEST)

    user = User.objects.create_user(username=username, email=email, password=password)
    return Response({'message': 'Usuario creado correctamente'}, status=status.HTTP_201_CREATED)

# Vista para autenticar un usuario y obtener un token
@api_view(['POST'])
def login(request): 
    
    username = request.data.get('username')
    password = request.data.get('password')

    if not username or not password:
        return Response({'error': 'Username y password son requeridos'}, status=status.HTTP_400_BAD_REQUEST)

    user = authenticate(username=username, password=password)
    if user is None or password is None:
        return Response({'error': 'Credenciales inválidas'}, status=status.HTTP_401_UNAUTHORIZED)

    token, created = Token.objects.get_or_create(user=user)
    return Response({'token': token.key}, status=status.HTTP_200_OK)

