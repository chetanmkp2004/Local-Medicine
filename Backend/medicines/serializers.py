from rest_framework import serializers
from .models import Medicine


class MedicineSerializer(serializers.ModelSerializer):
    """Serializer for Medicine model"""
    
    class Meta:
        model = Medicine
        fields = ['id', 'name_en', 'name_te', 'brand', 'form']
        read_only_fields = ['id']
