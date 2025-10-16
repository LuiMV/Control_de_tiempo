from django.urls import path, include
from rest_framework.routers import DefaultRouter
from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView

from apps.monitoring.views import (
    UsageRecordViewSet,
    register,
    login,
    set_app_limit, 
)

# Router para los endpoints de API basados en ViewSets
router = DefaultRouter()
router.register(r'usage', UsageRecordViewSet, basename='usage')

# URL patterns principales
urlpatterns = [
    # Rutas de autenticación con JWT
    path('api/auth/token/', TokenObtainPairView.as_view(), name='token_obtain_pair'),
    path('api/auth/token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),

    # Endpoints personalizados
    path('api/register/', register, name='register'),
    path('api/login/', login, name='login'),
    path('api/set_limit/', set_app_limit, name='set_app_limit'),

    # Endpoints del router (usage, summary, etc.)
    path('api/', include(router.urls)),
]



