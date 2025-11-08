from rest_framework import viewsets, filters
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticatedOrReadOnly
from django.db.models import Q
from .models import Medicine
from .serializers import MedicineSerializer


class MedicineViewSet(viewsets.ModelViewSet):
    """ViewSet for Medicine CRUD operations"""
    queryset = Medicine.objects.all()
    serializer_class = MedicineSerializer
    permission_classes = [IsAuthenticatedOrReadOnly]
    filter_backends = [filters.SearchFilter, filters.OrderingFilter]
    search_fields = ['name_en', 'name_te', 'brand']
    ordering_fields = ['name_en', 'created_at']
    ordering = ['name_en']
    
    @action(detail=False, methods=['get'])
    def search(self, request):
        """Search medicines by name (English or Telugu) or brand"""
        query = request.query_params.get('q', '')
        
        if not query:
            return Response({'results': []})
        
        medicines = Medicine.objects.filter(
            Q(name_en__icontains=query) |
            Q(name_te__icontains=query) |
            Q(brand__icontains=query)
        )[:20]  # Limit to 20 results
        
        serializer = self.get_serializer(medicines, many=True)
        return Response({'results': serializer.data})
