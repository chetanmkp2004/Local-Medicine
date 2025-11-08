from django.db import models


class Medicine(models.Model):
    """Medicine model."""
    
    name_en = models.CharField(max_length=255, db_index=True)
    name_te = models.CharField(max_length=255, null=True, blank=True)
    brand = models.CharField(max_length=255, null=True, blank=True)
    form = models.CharField(max_length=100, null=True, blank=True)
    
    class Meta:
        db_table = 'medicines'
        
    def __str__(self):
        return self.name_en
