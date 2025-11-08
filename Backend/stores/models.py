from django.db import models


class Store(models.Model):
    """Store/Pharmacy model."""
    
    name = models.CharField(max_length=255, db_index=True)
    phone = models.CharField(max_length=20, null=True, blank=True)
    address = models.CharField(max_length=512)
    rating = models.FloatField(null=True, blank=True)
    open_now = models.BooleanField(default=True)
    is_verified = models.BooleanField(default=False)
    latitude = models.DecimalField(max_digits=9, decimal_places=6)
    longitude = models.DecimalField(max_digits=9, decimal_places=6)
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        db_table = 'stores'
        
    def __str__(self):
        return self.name
