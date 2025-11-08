# Django Backend API Endpoints

Base URL: `http://localhost:8000/api/v1/`

## Authentication Endpoints

### Register
- **POST** `/api/v1/auth/register/`
- Body:
```json
{
  "email": "user@example.com",
  "phone": "9876543210",
  "full_name": "John Doe",
  "password": "password123",
  "password_confirm": "password123",
  "role": "customer"
}
```

### Login
- **POST** `/api/v1/auth/login/`
- Body:
```json
{
  "email": "shop@test.com",
  "password": "password123"
}
```

### Refresh Token
- **POST** `/api/v1/auth/refresh/`
- Body:
```json
{
  "refresh": "<refresh_token>"
}
```

### Get Current User
- **GET** `/api/v1/auth/me/`
- Headers: `Authorization: Bearer <access_token>`

### Register Device Token
- **POST** `/api/v1/auth/device-token/`
- Headers: `Authorization: Bearer <access_token>`
- Body:
```json
{
  "token": "device_fcm_token_here",
  "platform": "android"
}
```

## Medicine Endpoints

### List Medicines
- **GET** `/api/v1/medicines/`

### Search Medicines
- **GET** `/api/v1/medicines/search/?q=paracetamol`

### Get Medicine Details
- **GET** `/api/v1/medicines/{id}/`

### Create Medicine (Admin only)
- **POST** `/api/v1/medicines/`
- Body:
```json
{
  "name_en": "Medicine Name",
  "name_te": "మందు పేరు",
  "brand": "Brand Name",
  "form": "Tablet"
}
```

## Store Endpoints

### List Stores
- **GET** `/api/v1/stores/`

### Get Nearby Stores
- **GET** `/api/v1/stores/nearby/?latitude=17.4402&longitude=78.3490&radius_km=10`

### Get Store Details
- **GET** `/api/v1/stores/{id}/`

### Create Store (Admin only)
- **POST** `/api/v1/stores/`
- Body:
```json
{
  "name": "Store Name",
  "phone": "9876543210",
  "address": "Full Address",
  "latitude": "17.4402",
  "longitude": "78.3490",
  "rating": 4.5,
  "open_now": true,
  "is_verified": true
}
```

## Inventory Endpoints

### List Inventory
- **GET** `/api/v1/inventory/`
- Query params: `?store_id=1&medicine_id=2&available=true`

### Bulk Upsert Inventory (Shop owner only)
- **POST** `/api/v1/inventory/bulk_upsert/`
- Headers: `Authorization: Bearer <access_token>`
- Body:
```json
{
  "store_id": 1,
  "items": [
    {
      "medicine_id": 1,
      "price": "50.00",
      "available": true,
      "stock_qty": 100
    },
    {
      "medicine_id": 2,
      "price": "75.50",
      "available": true,
      "stock_qty": 50
    }
  ]
}
```

### Update Inventory Item
- **PATCH** `/api/v1/inventory/{id}/`
- Headers: `Authorization: Bearer <access_token>`
- Body:
```json
{
  "price": "60.00",
  "available": true,
  "stock_qty": 80
}
```

## Request Endpoints

### List Requests (Customer sees own, Shop/Admin see all)
- **GET** `/api/v1/requests/`
- Headers: `Authorization: Bearer <access_token>`

### Create Request (Customer)
- **POST** `/api/v1/requests/`
- Headers: `Authorization: Bearer <access_token>`
- Body:
```json
{
  "medicine_id": 1,
  "note": "Need urgently"
}
```

### Shop Requests (Shop owner view)
- **GET** `/api/v1/requests/shop/?status=pending`
- Headers: `Authorization: Bearer <access_token>`

### Approve/Reject Request (Shop owner only)
- **POST** `/api/v1/requests/{id}/approve/`
- Headers: `Authorization: Bearer <access_token>`
- Body:
```json
{
  "status": "accepted"
}
```
Status options: `pending`, `accepted`, `rejected`, `fulfilled`

## API Documentation

- **Swagger UI**: http://localhost:8000/api/docs/
- **OpenAPI Schema**: http://localhost:8000/api/schema/

## Test Credentials

### Shop Owner
- Email: `shop@test.com`
- Password: `password123`

### Customer
- Email: `customer@test.com`
- Password: `password123`

## Admin Panel

- URL: http://localhost:8000/admin/
- Create superuser: `python manage.py createsuperuser`
