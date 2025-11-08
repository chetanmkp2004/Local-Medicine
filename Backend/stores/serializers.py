from rest_framework import serializers
from .models import Store


class StoreSerializer(serializers.ModelSerializer):
    """Serializer for Store model"""
    
    class Meta:
        model = Store
        fields = ['id', 'name', 'phone', 'address', 'latitude', 'longitude', 
                  'rating', 'open_now', 'is_verified', 'created_at']
        read_only_fields = ['id', 'created_at']


class StoreNearbySerializer(serializers.ModelSerializer):
    """Serializer for nearby stores with distance"""
    distance = serializers.DecimalField(max_digits=10, decimal_places=2, read_only=True)
    
    class Meta:
        model = Store
        fields = ['id', 'name', 'phone', 'address', 'latitude', 'longitude', 
                  'rating', 'open_now', 'is_verified', 'distance']
