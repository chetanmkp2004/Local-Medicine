from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import RequestViewSet

app_name = 'requests'

router = DefaultRouter()
router.register('', RequestViewSet, basename='request')

urlpatterns = [
    path('', include(router.urls)),
]
