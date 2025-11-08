import 'package:json_annotation/json_annotation.dart';

part 'api_models.g.dart';

// ============ Auth Models ============
@JsonSerializable()
class UserRegisterRequest {
  final String email;
  final String password;
  final String? full_name;
  final String? phone;
  final String role; // 'customer', 'shop', or 'admin'

  UserRegisterRequest({
    required this.email,
    required this.password,
    this.full_name,
    this.phone,
    required this.role,
  });

  factory UserRegisterRequest.fromJson(Map<String, dynamic> json) =>
      _$UserRegisterRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UserRegisterRequestToJson(this);
}

@JsonSerializable()
class UserLoginRequest {
  final String email;
  final String password;

  UserLoginRequest({required this.email, required this.password});

  factory UserLoginRequest.fromJson(Map<String, dynamic> json) =>
      _$UserLoginRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UserLoginRequestToJson(this);
}

@JsonSerializable()
class Token {
  final String access_token;
  final String? refresh_token;
  final String token_type;

  Token({
    required this.access_token,
    this.refresh_token,
    required this.token_type,
  });

  factory Token.fromJson(Map<String, dynamic> json) => _$TokenFromJson(json);

  Map<String, dynamic> toJson() => _$TokenToJson(this);
}

@JsonSerializable()
class UserRead {
  final String id;
  final String email;
  final String? full_name;
  final String? phone;
  final String role;
  final String? store_id;
  final bool is_active;
  final DateTime created_at;

  UserRead({
    required this.id,
    required this.email,
    this.full_name,
    this.phone,
    required this.role,
    this.store_id,
    required this.is_active,
    required this.created_at,
  });

  factory UserRead.fromJson(Map<String, dynamic> json) =>
      _$UserReadFromJson(json);

  Map<String, dynamic> toJson() => _$UserReadToJson(this);
}

// ============ Store Models ============
@JsonSerializable()
class StoreRead {
  final String id;
  final String name;
  final String address;
  final String? phone;
  final double latitude;
  final double longitude;
  final bool is_verified;
  final DateTime? created_at;
  final double? distance_km;

  StoreRead({
    required this.id,
    required this.name,
    required this.address,
    this.phone,
    required this.latitude,
    required this.longitude,
    required this.is_verified,
    this.created_at,
    this.distance_km,
  });

  factory StoreRead.fromJson(Map<String, dynamic> json) =>
      _$StoreReadFromJson(json);

  Map<String, dynamic> toJson() => _$StoreReadToJson(this);
}

@JsonSerializable()
class StoreCreate {
  final String name;
  final String address;
  final String? phone;
  final double latitude;
  final double longitude;

  StoreCreate({
    required this.name,
    required this.address,
    this.phone,
    required this.latitude,
    required this.longitude,
  });

  factory StoreCreate.fromJson(Map<String, dynamic> json) =>
      _$StoreCreateFromJson(json);

  Map<String, dynamic> toJson() => _$StoreCreateToJson(this);
}

// ============ Medicine Models ============
@JsonSerializable()
class MedicineRead {
  final String id;
  final String name_en;
  final String? name_te;
  final String? description;
  final List<String>? alternatives;

  MedicineRead({
    required this.id,
    required this.name_en,
    this.name_te,
    this.description,
    this.alternatives,
  });

  factory MedicineRead.fromJson(Map<String, dynamic> json) =>
      _$MedicineReadFromJson(json);

  Map<String, dynamic> toJson() => _$MedicineReadToJson(this);
}

@JsonSerializable()
class MedicineCreate {
  final String name_en;
  final String? name_te;
  final String? description;
  final List<String>? alternatives;

  MedicineCreate({
    required this.name_en,
    this.name_te,
    this.description,
    this.alternatives,
  });

  factory MedicineCreate.fromJson(Map<String, dynamic> json) =>
      _$MedicineCreateFromJson(json);

  Map<String, dynamic> toJson() => _$MedicineCreateToJson(this);
}

// ============ Inventory Models ============
@JsonSerializable()
class InventoryItemRead {
  final String store_id;
  final String medicine_id;
  final bool available;
  final int? quantity;
  final double? price;

  InventoryItemRead({
    required this.store_id,
    required this.medicine_id,
    required this.available,
    this.quantity,
    this.price,
  });

  factory InventoryItemRead.fromJson(Map<String, dynamic> json) =>
      _$InventoryItemReadFromJson(json);

  Map<String, dynamic> toJson() => _$InventoryItemReadToJson(this);
}

@JsonSerializable()
class InventoryItemUpdate {
  final bool available;
  final int? quantity;
  final double? price;

  InventoryItemUpdate({required this.available, this.quantity, this.price});

  factory InventoryItemUpdate.fromJson(Map<String, dynamic> json) =>
      _$InventoryItemUpdateFromJson(json);

  Map<String, dynamic> toJson() => _$InventoryItemUpdateToJson(this);
}

// ============ Request Models ============
@JsonSerializable()
class RequestRead {
  final String id;
  final String customer_id;
  final String medicine_id;
  final String? store_id;
  final String status; // 'pending', 'approved', 'rejected', 'completed'
  final DateTime created_at;
  final DateTime? updated_at;

  RequestRead({
    required this.id,
    required this.customer_id,
    required this.medicine_id,
    this.store_id,
    required this.status,
    required this.created_at,
    this.updated_at,
  });

  factory RequestRead.fromJson(Map<String, dynamic> json) =>
      _$RequestReadFromJson(json);

  Map<String, dynamic> toJson() => _$RequestReadToJson(this);
}

@JsonSerializable()
class RequestCreate {
  final String medicine_id;
  final String? store_id;

  RequestCreate({required this.medicine_id, this.store_id});

  factory RequestCreate.fromJson(Map<String, dynamic> json) =>
      _$RequestCreateFromJson(json);

  Map<String, dynamic> toJson() => _$RequestCreateToJson(this);
}

@JsonSerializable()
class RequestUpdate {
  final String status;

  RequestUpdate({required this.status});

  factory RequestUpdate.fromJson(Map<String, dynamic> json) =>
      _$RequestUpdateFromJson(json);

  Map<String, dynamic> toJson() => _$RequestUpdateToJson(this);
}
