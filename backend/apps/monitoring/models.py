from django.db import models
from django.conf import settings


class UsageRecord(models.Model):
    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='usage_records'

    )
    app_package = models.CharField(max_length=255)
    app_name = models.CharField(max_length=255, null=True, blank=True)
    start_time = models.DateTimeField()
    end_time = models.DateTimeField()
    duration_seconds = models.IntegerField()
    created_at = models.DateTimeField(auto_now_add=True)
    limit_minutes = models.IntegerField(null=True, blank=True)

    class Meta:
        indexes = [
            models.Index(fields=['user', 'app_package', 'start_time']),
        ]

    def __str__(self):
        display_name = self.app_name or self.app_package
        return f"{self.user} - {display_name} - {self.duration_seconds}s"


class AppLimit(models.Model):
    """
    Modelo para definir límites diarios de uso por aplicación.
    """
    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='app_limits'
    )
    app_package = models.CharField(max_length=255)
    app_name = models.CharField(max_length=255, null=True, blank=True)
    limit_seconds = models.PositiveIntegerField(
        help_text="Tiempo máximo diario permitido (en segundos)."
    )

    class Meta:
        unique_together = ('user', 'app_package')
        indexes = [
            models.Index(fields=['user', 'app_package']),
        ]

    def __str__(self):
        display_name = self.app_name or self.app_package
        return f"{self.user} - {display_name}: {self.limit_seconds}s por día"

