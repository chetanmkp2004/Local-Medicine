"""
Seed script to populate the database with test data
Run with: python scripts/seed_data.py
"""
import os
import sys
import django
from decimal import Decimal

# Add parent directory to path
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
django.setup()

from accounts.models import User
from medicines.models import Medicine
from stores.models import Store
from inventory.models import Inventory

def seed_data():
    print("Starting database seeding...")
    
    # Create medicines
    medicines_data = [
        {'name_en': 'Paracetamol', 'name_te': 'పారాసెటమాల్', 'brand': 'Crocin', 'form': 'Tablet'},
        {'name_en': 'Aspirin', 'name_te': 'ఆస్పిరిన్', 'brand': 'Disprin', 'form': 'Tablet'},
        {'name_en': 'Ibuprofen', 'name_te': 'ఐబుప్రొఫెన్', 'brand': 'Brufen', 'form': 'Tablet'},
        {'name_en': 'Amoxicillin', 'name_te': 'అమోక్సిసిల్లిన్', 'brand': 'Amoxil', 'form': 'Capsule'},
        {'name_en': 'Metformin', 'name_te': 'మెట్‌ఫార్మిన్', 'brand': 'Glycomet', 'form': 'Tablet'},
        {'name_en': 'Cetirizine', 'name_te': 'సెటిరిజైన్', 'brand': 'Cetrizet', 'form': 'Tablet'},
        {'name_en': 'Azithromycin', 'name_te': 'అజితోమైసిన్', 'brand': 'Azithral', 'form': 'Tablet'},
        {'name_en': 'Pantoprazole', 'name_te': 'పాంటొప్రజోల్', 'brand': 'Pan', 'form': 'Tablet'},
    ]
    
    medicines = []
    for med_data in medicines_data:
        medicine, created = Medicine.objects.get_or_create(
            name_en=med_data['name_en'],
            defaults=med_data
        )
        medicines.append(medicine)
        print(f"{'Created' if created else 'Found'} medicine: {medicine.name_en}")
    
    # Create stores
    stores_data = [
        {
            'name': 'Apollo Pharmacy',
            'phone': '9876543210',
            'address': 'Gachibowli, Hyderabad',
            'latitude': Decimal('17.4402'),
            'longitude': Decimal('78.3490'),
            'rating': 4.5,
            'open_now': True,
            'is_verified': True,
        },
        {
            'name': 'MedPlus',
            'phone': '9876543211',
            'address': 'Kukatpally, Hyderabad',
            'latitude': Decimal('17.4923'),
            'longitude': Decimal('78.3938'),
            'rating': 4.2,
            'open_now': True,
            'is_verified': True,
        },
        {
            'name': 'Wellness Forever',
            'phone': '9876543212',
            'address': 'KPHB, Hyderabad',
            'latitude': Decimal('17.4886'),
            'longitude': Decimal('78.3912'),
            'rating': 4.3,
            'open_now': False,
            'is_verified': True,
        },
        {
            'name': 'Local Medical Store',
            'phone': '9876543213',
            'address': 'Miyapur, Hyderabad',
            'latitude': Decimal('17.4973'),
            'longitude': Decimal('78.3583'),
            'rating': 4.0,
            'open_now': True,
            'is_verified': False,
        },
    ]
    
    stores = []
    for store_data in stores_data:
        store, created = Store.objects.get_or_create(
            name=store_data['name'],
            defaults=store_data
        )
        stores.append(store)
        print(f"{'Created' if created else 'Found'} store: {store.name}")
    
    # Create shop user and link to first store
    shop_user, created = User.objects.get_or_create(
        email='shop@test.com',
        defaults={
            'full_name': 'Shop Owner',
            'phone': '9876543210',
            'role': 'shop',
            'store': stores[0],
        }
    )
    if created:
        shop_user.set_password('password123')
        shop_user.save()
        print(f"Created shop user: {shop_user.email}")
    else:
        print(f"Found shop user: {shop_user.email}")
    
    # Create customer user
    customer_user, created = User.objects.get_or_create(
        email='customer@test.com',
        defaults={
            'full_name': 'Test Customer',
            'phone': '9876543214',
            'role': 'customer',
        }
    )
    if created:
        customer_user.set_password('password123')
        customer_user.save()
        print(f"Created customer user: {customer_user.email}")
    else:
        print(f"Found customer user: {customer_user.email}")
    
    # Create inventory for stores
    print("\nCreating inventory...")
    import random
    for store in stores:
        for medicine in medicines:
            # Randomly decide if this store has this medicine
            if random.random() > 0.3:  # 70% chance of having the medicine
                inventory, created = Inventory.objects.get_or_create(
                    store=store,
                    medicine=medicine,
                    defaults={
                        'price': Decimal(random.randint(50, 500)),
                        'available': random.choice([True, True, True, False]),  # 75% available
                        'stock_qty': random.randint(0, 100),
                    }
                )
                if created:
                    print(f"  Added {medicine.name_en} to {store.name}")
    
    print("\nDatabase seeding completed!")
    print(f"Total medicines: {Medicine.objects.count()}")
    print(f"Total stores: {Store.objects.count()}")
    print(f"Total users: {User.objects.count()}")
    print(f"Total inventory items: {Inventory.objects.count()}")

if __name__ == '__main__':
    seed_data()
