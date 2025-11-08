from rest_framework import viewsets, filters
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticatedOrReadOnly
from decimal import Decimal
import math
from .models import Store
from .serializers import StoreSerializer, StoreNearbySerializer


class StoreViewSet(viewsets.ModelViewSet):
    """ViewSet for Store CRUD operations"""
    queryset = Store.objects.all()
    serializer_class = StoreSerializer
    permission_classes = [IsAuthenticatedOrReadOnly]
    filter_backends = [filters.SearchFilter, filters.OrderingFilter]
    search_fields = ['name', 'address', 'phone']
    ordering_fields = ['name', 'rating', 'created_at']
    ordering = ['-rating']
    
    @action(detail=False, methods=['get'])
    def nearby(self, request):
        """Find stores near a given location using Haversine formula"""
        try:
            latitude = Decimal(request.query_params.get('latitude'))
            longitude = Decimal(request.query_params.get('longitude'))
            radius_km = Decimal(request.query_params.get('radius_km', '10'))
        except (TypeError, ValueError):
            return Response(
                {'error': 'Invalid latitude, longitude, or radius_km'},
                status=400
            )
        
        # Haversine formula to calculate distance
        # Convert to radians
        lat_rad = float(latitude) * math.pi / 180
        lon_rad = float(longitude) * math.pi / 180
        
        stores = []
        for store in Store.objects.all():
            store_lat_rad = float(store.latitude) * math.pi / 180
            store_lon_rad = float(store.longitude) * math.pi / 180
            
            # Haversine formula
            dlat = store_lat_rad - lat_rad
            dlon = store_lon_rad - lon_rad
            a = math.sin(dlat/2)**2 + math.cos(lat_rad) * math.cos(store_lat_rad) * math.sin(dlon/2)**2
            c = 2 * math.asin(math.sqrt(a))
            distance = 6371 * c  # Earth radius in km
            
            if distance <= float(radius_km):
                store.distance = round(distance, 2)
                stores.append(store)
        
        # Sort by distance
        stores.sort(key=lambda x: x.distance)
        
        serializer = StoreNearbySerializer(stores, many=True)
        return Response({'results': serializer.data})
