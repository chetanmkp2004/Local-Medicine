from rest_framework import serializers
from .models import Request
from accounts.serializers import UserSerializer
from medicines.serializers import MedicineSerializer


class RequestSerializer(serializers.ModelSerializer):
    """Serializer for Request model with nested data"""
    user = UserSerializer(read_only=True)
    medicine = MedicineSerializer(read_only=True)
    medicine_id = serializers.IntegerField(write_only=True)
    
    class Meta:
        model = Request
        fields = ['id', 'user', 'medicine', 'medicine_id', 'note', 
                  'status', 'created_at', 'updated_at']
        read_only_fields = ['id', 'user', 'created_at', 'updated_at']


class RequestStatusUpdateSerializer(serializers.Serializer):
    """Serializer for updating request status"""
    status = serializers.ChoiceField(choices=['pending', 'accepted', 'rejected', 'fulfilled'])
