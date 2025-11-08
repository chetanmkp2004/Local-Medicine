from rest_framework import serializers
from .models import Inventory
from medicines.serializers import MedicineSerializer
from stores.serializers import StoreSerializer


class InventorySerializer(serializers.ModelSerializer):
    """Serializer for Inventory model with nested data"""
    medicine = MedicineSerializer(read_only=True)
    store = StoreSerializer(read_only=True)
    medicine_id = serializers.IntegerField(write_only=True)
    store_id = serializers.IntegerField(write_only=True)
    
    class Meta:
        model = Inventory
        fields = ['id', 'store', 'store_id', 'medicine', 'medicine_id', 
                  'price', 'available', 'stock_qty', 'last_updated']
        read_only_fields = ['id', 'last_updated']


class InventoryBulkUpdateSerializer(serializers.Serializer):
    """Serializer for bulk inventory updates"""
    medicine_id = serializers.IntegerField()
    price = serializers.DecimalField(max_digits=10, decimal_places=2)
    available = serializers.BooleanField()
    stock_qty = serializers.IntegerField()
