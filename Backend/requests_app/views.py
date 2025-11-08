from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from .models import Request
from .serializers import RequestSerializer, RequestStatusUpdateSerializer


class RequestViewSet(viewsets.ModelViewSet):
    """ViewSet for Request CRUD operations"""
    serializer_class = RequestSerializer
    permission_classes = [IsAuthenticated]
    filterset_fields = ['status', 'medicine']
    ordering_fields = ['created_at', 'updated_at']
    ordering = ['-created_at']
    
    def get_queryset(self):
        """Filter requests based on user role"""
        user = self.request.user
        
        if user.role == 'admin':
            # Admin can see all requests
            return Request.objects.select_related('user', 'medicine').all()
        elif user.role == 'shop':
            # Shop owner can see all requests
            return Request.objects.select_related('user', 'medicine').all()
        else:
            # Customers can only see their own requests
            return Request.objects.filter(user=user).select_related('medicine')
    
    def perform_create(self, serializer):
        """Set the user to the current user when creating a request"""
        serializer.save(user=self.request.user)
    
    @action(detail=False, methods=['get'])
    def shop(self, request):
        """Get all requests for shop owners"""
        if request.user.role not in ['shop', 'admin']:
            return Response(
                {'error': 'Only shop owners can access this endpoint'},
                status=status.HTTP_403_FORBIDDEN
            )
        
        requests = Request.objects.select_related('user', 'medicine').all()
        
        # Filter by status if provided
        status_filter = request.query_params.get('status')
        if status_filter:
            requests = requests.filter(status=status_filter)
        
        page = self.paginate_queryset(requests)
        if page is not None:
            serializer = self.get_serializer(page, many=True)
            return self.get_paginated_response(serializer.data)
        
        serializer = self.get_serializer(requests, many=True)
        return Response(serializer.data)
    
    @action(detail=True, methods=['post'])
    def approve(self, request, pk=None):
        """Approve or reject a request (shop owners only)"""
        if request.user.role not in ['shop', 'admin']:
            return Response(
                {'error': 'Only shop owners can approve requests'},
                status=status.HTTP_403_FORBIDDEN
            )
        
        request_obj = self.get_object()
        serializer = RequestStatusUpdateSerializer(data=request.data)
        
        if serializer.is_valid():
            new_status = serializer.validated_data['status']
            request_obj.status = new_status
            request_obj.save()
            
            return Response(RequestSerializer(request_obj).data)
        
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
