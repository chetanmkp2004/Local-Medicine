from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from django.db import transaction
from .models import Inventory
from .serializers import InventorySerializer, InventoryBulkUpdateSerializer


class InventoryViewSet(viewsets.ModelViewSet):
    """ViewSet for Inventory CRUD operations"""
    queryset = Inventory.objects.select_related('store', 'medicine').all()
    serializer_class = InventorySerializer
    permission_classes = [IsAuthenticated]
    filterset_fields = ['store', 'medicine', 'available']
    ordering_fields = ['price', 'stock_qty', 'last_updated']
    ordering = ['-last_updated']
    
    def get_queryset(self):
        """Filter inventory by store if store_id is provided"""
        queryset = super().get_queryset()
        store_id = self.request.query_params.get('store_id')
        medicine_id = self.request.query_params.get('medicine_id')
        
        if store_id:
            queryset = queryset.filter(store_id=store_id)
        if medicine_id:
            queryset = queryset.filter(medicine_id=medicine_id)
            
        return queryset
    
    @action(detail=False, methods=['post'])
    def bulk_upsert(self, request):
        """Bulk create or update inventory items for a store"""
        store_id = request.data.get('store_id')
        items = request.data.get('items', [])
        
        if not store_id:
            return Response(
                {'error': 'store_id is required'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        serializer = InventoryBulkUpdateSerializer(data=items, many=True)
        if not serializer.is_valid():
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
        
        # Bulk upsert
        created_count = 0
        updated_count = 0
        
        with transaction.atomic():
            for item_data in serializer.validated_data:
                inventory, created = Inventory.objects.update_or_create(
                    store_id=store_id,
                    medicine_id=item_data['medicine_id'],
                    defaults={
                        'price': item_data['price'],
                        'available': item_data['available'],
                        'stock_qty': item_data['stock_qty'],
                    }
                )
                if created:
                    created_count += 1
                else:
                    updated_count += 1
        
        return Response({
            'message': 'Bulk upsert successful',
            'created': created_count,
            'updated': updated_count
        }, status=status.HTTP_200_OK)
