import uuid
from django.db import models


class RequestStatus(models.TextChoices):
    PENDING = 'pending', 'Pending'
    ACCEPTED = 'accepted', 'Accepted'
    REJECTED = 'rejected', 'Rejected'
    FULFILLED = 'fulfilled', 'Fulfilled'


class Request(models.Model):
    """Customer medicine requests."""
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey('accounts.User', on_delete=models.CASCADE, related_name='requests')
    medicine = models.ForeignKey('medicines.Medicine', on_delete=models.CASCADE, related_name='requests')
    note = models.CharField(max_length=1024, null=True, blank=True)
    status = models.CharField(
        max_length=10,
        choices=RequestStatus.choices,
        default=RequestStatus.PENDING
    )
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        db_table = 'requests'
        ordering = ['-created_at']
        
    def __str__(self):
        return f"{self.user} - {self.medicine.name_en} - {self.status}"
