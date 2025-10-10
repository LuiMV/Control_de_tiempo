from django.db import models
from django.conf import settings

class UsageRecord(models.Model):
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='usage_records')
    app_package = models.CharField(max_length=255)
    app_name = models.CharField(max_length=255, null=True, blank=True)
    start_time = models.DateTimeField()
    end_time = models.DateTimeField()
    duration_seconds = models.IntegerField()
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        indexes = [
            models.Index(fields=['user', 'app_package', 'start_time']),
        ]
    def __str__(self):
        return f"{self.user} - {self.app_package} - {self.duration_seconds}s"
