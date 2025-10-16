from datetime import timedelta
from django.utils import timezone
from django.db.models import Sum
from django.contrib.auth import get_user_model, authenticate
from django.contrib.auth.hashers import make_password
from rest_framework import status, viewsets
from rest_framework.decorators import api_view, action
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.authtoken.models import Token

from .models import UsageRecord, AppLimit
from .serializers import UsageRecordSerializer

User = get_user_model()


# CONTROL DE USO Y LÍMITES
class UsageRecordViewSet(viewsets.ModelViewSet):
    permission_classes = [IsAuthenticated]
    serializer_class = UsageRecordSerializer

    def get_queryset(self):
        return UsageRecord.objects.filter(user=self.request.user).order_by('-start_time')

    def perform_create(self, serializer):
        """
        Guarda un registro de uso y valida si el usuario excedió el límite diario de esa app.
        """
        user = self.request.user
        record = serializer.save(user=user)

        # Buscar si existe un límite para la app
        app_limit = AppLimit.objects.filter(user=user, app_package=record.app_package).first()

        if app_limit:
            # Calcular el total de segundos usados hoy
            today = timezone.now().date()
            total_today = (
                UsageRecord.objects.filter(
                    user=user,
                    app_package=record.app_package,
                    start_time__date=today
                ).aggregate(total=Sum('duration_seconds'))['total'] or 0
            )

            if total_today > app_limit.limit_seconds:
                # Notificar que se superó el límite
                # (En una app real podrías enviar una alerta push o cortar el uso)
                print(f"Usuario {user.username} superó el límite diario de {record.app_name or record.app_package}")

        return record

    @action(detail=False, methods=['get'])
    def summary(self, request):
        """
        Devuelve el tiempo total de uso y el tiempo por app.
        """
        user = request.user

        total_seconds = (
            UsageRecord.objects.filter(user=user)
            .aggregate(total=Sum('duration_seconds'))
            .get('total', 0)
            or 0
        )

        apps = (
            UsageRecord.objects.filter(user=user)
            .values('app_name', 'app_package')
            .annotate(duration_seconds=Sum('duration_seconds'))
            .order_by('-duration_seconds')
        )

        return Response(
            {
                "total_seconds": total_seconds,
                "apps": list(apps),
            },
            status=status.HTTP_200_OK,
        )

    @action(detail=False, methods=['get', 'post'])
    def limits(self, request):
        """
        GET → Lista los límites del usuario.
        POST → Crea o actualiza un límite para una app.
        """
        user = request.user

        if request.method == 'GET':
            limits = AppLimit.objects.filter(user=user).values('app_name', 'app_package', 'limit_seconds')
            return Response(list(limits), status=status.HTTP_200_OK)

        if request.method == 'POST':
            app_package = request.data.get('app_package')
            app_name = request.data.get('app_name', app_package)
            limit_seconds = request.data.get('limit_seconds')

            if not app_package or not limit_seconds:
                return Response({'error': 'Faltan campos requeridos'}, status=status.HTTP_400_BAD_REQUEST)

            limit_seconds = int(limit_seconds)

            limit, created = AppLimit.objects.update_or_create(
                user=user,
                app_package=app_package,
                defaults={'app_name': app_name, 'limit_seconds': limit_seconds},
            )

            msg = "Límite creado" if created else "Límite actualizado"
            return Response({'message': msg, 'limit_seconds': limit.limit_seconds}, status=status.HTTP_200_OK)


# REGISTRO DE USUARIOS
@api_view(['POST'])
def register(request):
    username = request.data.get('username')
    email = request.data.get('email')
    password = request.data.get('password')

    if not username or not password:
        return Response({'error': 'Username y password son requeridos'}, status=status.HTTP_400_BAD_REQUEST)

    if User.objects.filter(username=username).exists():
        return Response({'error': 'El usuario ya existe'}, status=status.HTTP_400_BAD_REQUEST)

    user = User.objects.create(
        username=username,
        email=email,
        password=make_password(password)
    )

    return Response({'message': 'Usuario creado correctamente'}, status=status.HTTP_201_CREATED)


# LOGIN DE USUARIO
@api_view(['POST'])
def login(request):
    username = request.data.get('username')
    password = request.data.get('password')

    if not username or not password:
        return Response({'error': 'Username y password son requeridos'}, status=status.HTTP_400_BAD_REQUEST)

    user = authenticate(username=username, password=password)
    if user is None:
        return Response({'error': 'Credenciales inválidas'}, status=status.HTTP_401_UNAUTHORIZED)

    token, created = Token.objects.get_or_create(user=user)
    return Response({'token': token.key}, status=status.HTTP_200_OK)


@api_view(['POST'])
def set_app_limit(request):
    """
    Permite establecer un límite de tiempo (en minutos) para una app específica.
    """
    user = request.user
    app_name = request.data.get('app_name')
    limit_minutes = request.data.get('limit_minutes')

    if not app_name or limit_minutes is None:
        return Response(
            {"error": "Se requieren 'app_name' y 'limit_minutes'."},
            status=status.HTTP_400_BAD_REQUEST
        )

    try:
        # Actualiza o crea el límite de uso
        record, created = UsageRecord.objects.get_or_create(
            user=user, app_name=app_name,
            defaults={"duration_seconds": 0}
        )
        # Guardar el límite como campo adicional 
        record.limit_minutes = int(limit_minutes)
        record.save()

        return Response(
            {"message": f"Límite para {app_name} establecido en {limit_minutes} minutos."},
            status=status.HTTP_200_OK
        )
    except Exception as e:
        print("Error al establecer límite:", e)
        return Response(
            {"error": "No se pudo guardar el límite."},
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )


