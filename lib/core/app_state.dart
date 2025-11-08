import 'package:flutter/material.dart';
import 'models.dart';

class AppState {
  String languageCode; // 'en' or 'te'
  UserRole? role;

  // Mock data for MVP
  final List<Medicine> medicines;
  final List<Store> stores;
  final Map<String, Map<String, InventoryItem>>
  inventoryByStore; // storeId -> medId -> item

  AppState({
    required this.languageCode,
    required this.medicines,
    required this.stores,
    required this.inventoryByStore,
    this.role,
  });

  factory AppState.bootstrap() {
    final meds = <Medicine>[
      const Medicine(
        id: 'paracetamol',
        nameEn: 'Paracetamol',
        nameTe: 'పారాసెటమాల్',
        alternatives: ['acetaminophen'],
      ),
      const Medicine(
        id: 'acetaminophen',
        nameEn: 'Acetaminophen',
        nameTe: 'ఎసెటామినోఫెన్',
      ),
      const Medicine(
        id: 'azithromycin',
        nameEn: 'Azithromycin',
        nameTe: 'అజిత్రోమైసిన్',
      ),
      const Medicine(
        id: 'cetrizine',
        nameEn: 'Cetrizine',
        nameTe: 'సెటిరిజైన్',
      ),
    ];

    final stores = <Store>[
      Store(
        id: 's1',
        name: 'Sri Lakshmi Medicals',
        address: 'Main Road, Village Center',
        phone: '+91 90000 11111',
        mapUrl: 'https://maps.example/s1',
        hours: BusinessHours(
          const TimeOfDay(hour: 8, minute: 0),
          const TimeOfDay(hour: 21, minute: 0),
        ),
        distanceKm: 0.3,
        latitude: 17.4065,
        longitude: 78.4772,
      ),
      Store(
        id: 's2',
        name: 'Jan Aushadhi Kendra',
        address: 'Bus Stand Street',
        phone: '+91 90000 22222',
        mapUrl: 'https://maps.example/s2',
        hours: BusinessHours(
          const TimeOfDay(hour: 9, minute: 0),
          const TimeOfDay(hour: 20, minute: 0),
        ),
        distanceKm: 0.8,
        latitude: 17.4125,
        longitude: 78.4820,
      ),
      Store(
        id: 's3',
        name: 'Village Health Pharmacy',
        address: 'Temple Road',
        phone: '+91 90000 33333',
        mapUrl: 'https://maps.example/s3',
        hours: BusinessHours(
          const TimeOfDay(hour: 7, minute: 30),
          const TimeOfDay(hour: 22, minute: 0),
        ),
        distanceKm: 1.4,
        latitude: 17.4200,
        longitude: 78.4900,
      ),
    ];

    final inv = <String, Map<String, InventoryItem>>{
      's1': {
        'paracetamol': InventoryItem(
          medicineId: 'paracetamol',
          available: true,
        ),
        'azithromycin': InventoryItem(
          medicineId: 'azithromycin',
          available: false,
        ),
      },
      's2': {
        'paracetamol': InventoryItem(
          medicineId: 'paracetamol',
          available: true,
        ),
        'cetrizine': InventoryItem(medicineId: 'cetrizine', available: true),
      },
      's3': {
        'acetaminophen': InventoryItem(
          medicineId: 'acetaminophen',
          available: true,
        ),
      },
    };

    return AppState(
      languageCode: 'en',
      medicines: meds,
      stores: stores,
      inventoryByStore: inv,
    );
  }
}

class AppStateScope extends InheritedWidget {
  final AppState state;
  const AppStateScope({super.key, required this.state, required super.child});

  static AppState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppStateScope>();
    assert(scope != null, 'No AppStateScope found in context');
    return scope!.state;
  }

  @override
  bool updateShouldNotify(covariant AppStateScope oldWidget) =>
      oldWidget.state != state;
}
