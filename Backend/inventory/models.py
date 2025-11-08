from django.db import models


class Inventory(models.Model):
    """Store inventory for medicines."""
    
    store = models.ForeignKey('stores.Store', on_delete=models.CASCADE, related_name='inventory_items')
    medicine = models.ForeignKey('medicines.Medicine', on_delete=models.CASCADE, related_name='inventory_items')
    price = models.DecimalField(max_digits=10, decimal_places=2, null=True, blank=True)
    available = models.BooleanField(default=False)
    stock_qty = models.IntegerField(null=True, blank=True)
    last_updated = models.DateTimeField(auto_now=True)
    
    class Meta:
        db_table = 'inventory'
        unique_together = ('store', 'medicine')
        
    def __str__(self):
        return f"{self.store.name} - {self.medicine.name_en}"
