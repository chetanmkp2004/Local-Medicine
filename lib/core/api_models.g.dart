// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserRegisterRequest _$UserRegisterRequestFromJson(Map<String, dynamic> json) =>
    UserRegisterRequest(
      email: json['email'] as String,
      password: json['password'] as String,
      full_name: json['full_name'] as String?,
      phone: json['phone'] as String?,
      role: json['role'] as String,
    );

Map<String, dynamic> _$UserRegisterRequestToJson(
  UserRegisterRequest instance,
) => <String, dynamic>{
  'email': instance.email,
  'password': instance.password,
  'full_name': instance.full_name,
  'phone': instance.phone,
  'role': instance.role,
};

UserLoginRequest _$UserLoginRequestFromJson(Map<String, dynamic> json) =>
    UserLoginRequest(
      email: json['email'] as String,
      password: json['password'] as String,
    );

Map<String, dynamic> _$UserLoginRequestToJson(UserLoginRequest instance) =>
    <String, dynamic>{'email': instance.email, 'password': instance.password};

Token _$TokenFromJson(Map<String, dynamic> json) => Token(
  access_token: json['access_token'] as String,
  refresh_token: json['refresh_token'] as String?,
  token_type: json['token_type'] as String,
);

Map<String, dynamic> _$TokenToJson(Token instance) => <String, dynamic>{
  'access_token': instance.access_token,
  'refresh_token': instance.refresh_token,
  'token_type': instance.token_type,
};

UserRead _$UserReadFromJson(Map<String, dynamic> json) => UserRead(
  id: json['id'] as String,
  email: json['email'] as String,
  full_name: json['full_name'] as String?,
  phone: json['phone'] as String?,
  role: json['role'] as String,
  store_id: json['store_id'] as String?,
  is_active: json['is_active'] as bool,
  created_at: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$UserReadToJson(UserRead instance) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  'full_name': instance.full_name,
  'phone': instance.phone,
  'role': instance.role,
  'store_id': instance.store_id,
  'is_active': instance.is_active,
  'created_at': instance.created_at.toIso8601String(),
};

StoreRead _$StoreReadFromJson(Map<String, dynamic> json) => StoreRead(
  id: json['id'] as String,
  name: json['name'] as String,
  address: json['address'] as String,
  phone: json['phone'] as String?,
  latitude: (json['latitude'] as num).toDouble(),
  longitude: (json['longitude'] as num).toDouble(),
  is_verified: json['is_verified'] as bool,
  created_at: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  distance_km: (json['distance_km'] as num?)?.toDouble(),
);

Map<String, dynamic> _$StoreReadToJson(StoreRead instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'address': instance.address,
  'phone': instance.phone,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'is_verified': instance.is_verified,
  'created_at': instance.created_at?.toIso8601String(),
  'distance_km': instance.distance_km,
};

StoreCreate _$StoreCreateFromJson(Map<String, dynamic> json) => StoreCreate(
  name: json['name'] as String,
  address: json['address'] as String,
  phone: json['phone'] as String?,
  latitude: (json['latitude'] as num).toDouble(),
  longitude: (json['longitude'] as num).toDouble(),
);

Map<String, dynamic> _$StoreCreateToJson(StoreCreate instance) =>
    <String, dynamic>{
      'name': instance.name,
      'address': instance.address,
      'phone': instance.phone,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
    };

MedicineRead _$MedicineReadFromJson(Map<String, dynamic> json) => MedicineRead(
  id: json['id'] as String,
  name_en: json['name_en'] as String,
  name_te: json['name_te'] as String?,
  description: json['description'] as String?,
  alternatives: (json['alternatives'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$MedicineReadToJson(MedicineRead instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name_en': instance.name_en,
      'name_te': instance.name_te,
      'description': instance.description,
      'alternatives': instance.alternatives,
    };

MedicineCreate _$MedicineCreateFromJson(Map<String, dynamic> json) =>
    MedicineCreate(
      name_en: json['name_en'] as String,
      name_te: json['name_te'] as String?,
      description: json['description'] as String?,
      alternatives: (json['alternatives'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$MedicineCreateToJson(MedicineCreate instance) =>
    <String, dynamic>{
      'name_en': instance.name_en,
      'name_te': instance.name_te,
      'description': instance.description,
      'alternatives': instance.alternatives,
    };

InventoryItemRead _$InventoryItemReadFromJson(Map<String, dynamic> json) =>
    InventoryItemRead(
      store_id: json['store_id'] as String,
      medicine_id: json['medicine_id'] as String,
      available: json['available'] as bool,
      quantity: (json['quantity'] as num?)?.toInt(),
      price: (json['price'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$InventoryItemReadToJson(InventoryItemRead instance) =>
    <String, dynamic>{
      'store_id': instance.store_id,
      'medicine_id': instance.medicine_id,
      'available': instance.available,
      'quantity': instance.quantity,
      'price': instance.price,
    };

InventoryItemUpdate _$InventoryItemUpdateFromJson(Map<String, dynamic> json) =>
    InventoryItemUpdate(
      available: json['available'] as bool,
      quantity: (json['quantity'] as num?)?.toInt(),
      price: (json['price'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$InventoryItemUpdateToJson(
  InventoryItemUpdate instance,
) => <String, dynamic>{
  'available': instance.available,
  'quantity': instance.quantity,
  'price': instance.price,
};

RequestRead _$RequestReadFromJson(Map<String, dynamic> json) => RequestRead(
  id: json['id'] as String,
  customer_id: json['customer_id'] as String,
  medicine_id: json['medicine_id'] as String,
  store_id: json['store_id'] as String?,
  status: json['status'] as String,
  created_at: DateTime.parse(json['created_at'] as String),
  updated_at: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$RequestReadToJson(RequestRead instance) =>
    <String, dynamic>{
      'id': instance.id,
      'customer_id': instance.customer_id,
      'medicine_id': instance.medicine_id,
      'store_id': instance.store_id,
      'status': instance.status,
      'created_at': instance.created_at.toIso8601String(),
      'updated_at': instance.updated_at?.toIso8601String(),
    };

RequestCreate _$RequestCreateFromJson(Map<String, dynamic> json) =>
    RequestCreate(
      medicine_id: json['medicine_id'] as String,
      store_id: json['store_id'] as String?,
    );

Map<String, dynamic> _$RequestCreateToJson(RequestCreate instance) =>
    <String, dynamic>{
      'medicine_id': instance.medicine_id,
      'store_id': instance.store_id,
    };

RequestUpdate _$RequestUpdateFromJson(Map<String, dynamic> json) =>
    RequestUpdate(status: json['status'] as String);

Map<String, dynamic> _$RequestUpdateToJson(RequestUpdate instance) =>
    <String, dynamic>{'status': instance.status};
