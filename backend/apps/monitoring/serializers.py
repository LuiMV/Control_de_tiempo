from rest_framework import serializers
from .models import UsageRecord

class UsageRecordSerializer(serializers.ModelSerializer):
    class Meta:
        model = UsageRecord
        fields = '__all__'
        read_only_fields = ('user',)
