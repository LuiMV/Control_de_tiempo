from django.urls import path, include
from rest_framework.routers import DefaultRouter
from apps.monitoring.views import UsageRecordViewSet
from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView
from django.urls import path
from apps.monitoring.views import register
from apps.monitoring.views import login

router = DefaultRouter()
router.register(r'usage', UsageRecordViewSet, basename='usage')

urlpatterns = [
    path('api/auth/token/', TokenObtainPairView.as_view(), name='token_obtain_pair'),
    path('api/auth/token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    path('api/', include(router.urls)),
    #path('register/', register, name='register'),
    #path('login/', login, name='login'),
]


