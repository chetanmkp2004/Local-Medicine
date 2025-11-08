import 'package:flutter/material.dart';

enum UserRole { citizen, shopkeeper }

class Medicine {
  final String id;
  final String nameEn;
  final String nameTe;
  final List<String> alternatives; // medicine ids

  const Medicine({
    required this.id,
    required this.nameEn,
    required this.nameTe,
    this.alternatives = const [],
  });

  String nameFor(String lang) => lang == 'te' ? nameTe : nameEn;
}

class BusinessHours {
  final TimeOfDay open;
  final TimeOfDay close;
  const BusinessHours(this.open, this.close);

  bool isOpenNow(DateTime now) {
    final minutes = now.hour * 60 + now.minute;
    final openM = open.hour * 60 + open.minute;
    final closeM = close.hour * 60 + close.minute;
    if (closeM > openM) {
      return minutes >= openM && minutes < closeM;
    }
    // overnight wrap
    return minutes >= openM || minutes < closeM;
  }
}

class Store {
  final String id;
  final String name;
  final String address;
  final String phone;
  final String mapUrl;
  final BusinessHours hours;
  final double distanceKm; // mock distance for MVP
  final double latitude;
  final double longitude;
  final bool isVerified; // Verified pharmacy badge
  final String availability; // 'in_stock', 'low_stock', 'out_of_stock'

  const Store({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.mapUrl,
    required this.hours,
    required this.distanceKm,
    required this.latitude,
    required this.longitude,
    this.isVerified = false,
    this.availability = 'in_stock',
  });

  bool get isOpen => hours.isOpenNow(DateTime.now());

  Color get availabilityColor {
    switch (availability) {
      case 'in_stock':
        return const Color(0xFF4CAF50); // Healthy Green
      case 'low_stock':
        return const Color(0xFFFF9800); // Warning Orange
      case 'out_of_stock':
        return const Color(0xFFEF4444); // Error Red
      default:
        return const Color(0xFF6B7280); // Gray
    }
  }

  String get availabilityText {
    switch (availability) {
      case 'in_stock':
        return 'In Stock';
      case 'low_stock':
        return 'Low Stock';
      case 'out_of_stock':
        return 'Out of Stock';
      default:
        return 'Unknown';
    }
  }
}

class InventoryItem {
  final String medicineId;
  bool available;
  DateTime lastUpdated;

  InventoryItem({
    required this.medicineId,
    required this.available,
    DateTime? lastUpdated,
  }) : lastUpdated = lastUpdated ?? DateTime.now();
}

class OutOfStockReport {
  final String medicineId;
  final String storeId;
  final DateTime time;
  final String? comment;
  OutOfStockReport({
    required this.medicineId,
    required this.storeId,
    this.comment,
  }) : time = DateTime.now();
}
