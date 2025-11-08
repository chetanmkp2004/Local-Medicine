import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../providers/app_providers.dart';

class MapViewPage extends ConsumerStatefulWidget {
  const MapViewPage({super.key});

  @override
  ConsumerState<MapViewPage> createState() => _MapViewPageState();
}

class _MapViewPageState extends ConsumerState<MapViewPage> {
  GoogleMapController? _controller;
  dynamic _selectedStore;
  bool _didMoveToUserLocation = false;
  bool _isGettingLocation = false;
  double? _userLat;
  double? _userLng;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    if (_isGettingLocation) return;

    setState(() => _isGettingLocation = true);

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          _showSnack('Please enable location services');
        }
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (mounted) {
          _showSnack('Location permission denied');
        }
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (mounted) {
        setState(() {
          _userLat = position.latitude;
          _userLng = position.longitude;
        });

        if (_controller != null && _userLat != null && _userLng != null) {
          _moveToUserLocation();
        }
      }
    } catch (e) {
      if (mounted) {
        _showSnack('Unable to get location: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isGettingLocation = false);
      }
    }
  }

  void _moveToUserLocation() {
    if (_controller == null || _userLat == null || _userLng == null) return;

    final target = LatLng(_userLat!, _userLng!);
    _controller!.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: target, zoom: 16),
      ),
    );
    setState(() => _didMoveToUserLocation = true);
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  LatLngBounds _calculateBounds(List<dynamic> stores) {
    if (stores.isEmpty) {
      return LatLngBounds(
        southwest: const LatLng(0, 0),
        northeast: const LatLng(1, 1),
      );
    }

    double minLat = stores.first.latitude;
    double maxLat = stores.first.latitude;
    double minLng = stores.first.longitude;
    double maxLng = stores.first.longitude;

    for (var store in stores) {
      if (store.latitude < minLat) minLat = store.latitude;
      if (store.latitude > maxLat) maxLat = store.latitude;
      if (store.longitude < minLng) minLng = store.longitude;
      if (store.longitude > maxLng) maxLng = store.longitude;
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final storesAsync = ref.watch(
      nearbyStoresProvider((
        lat: _userLat ?? 0.0,
        lon: _userLng ?? 0.0,
        radius: 50.0,
      )),
    );

    return storesAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(
          title: const Text('Nearby Stores'),
          backgroundColor: const Color(0xFF6366F1),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stackTrace) => Scaffold(
        appBar: AppBar(
          title: const Text('Nearby Stores'),
          backgroundColor: const Color(0xFF6366F1),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Error loading stores',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
      data: (stores) {
        // Default initial position
        LatLng initialTarget = const LatLng(12.9716, 77.5946);
        if (stores.isNotEmpty) {
          initialTarget = LatLng(
            stores.first.latitude,
            stores.first.longitude,
          );
        } else if (_userLat != null && _userLng != null) {
          initialTarget = LatLng(_userLat!, _userLng!);
        }

        final markers = stores.map((store) {
          return Marker(
            markerId: MarkerId(store.id),
            position: LatLng(store.latitude, store.longitude),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueGreen,
            ),
            infoWindow: InfoWindow(
              title: store.name,
              snippet:
                  '${store.address}',
            ),
            onTap: () {
              setState(() {
                _selectedStore = store;
              });
            },
          );
        }).toSet();

        // Add user location marker if available
        if (_userLat != null && _userLng != null) {
          markers.add(
            Marker(
              markerId: const MarkerId('user_location'),
              position: LatLng(_userLat!, _userLng!),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueBlue,
              ),
              infoWindow: const InfoWindow(title: 'Your Location'),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Nearby Stores'),
            backgroundColor: const Color(0xFF6366F1),
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          body: Stack(
            children: [
              GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: initialTarget,
                  zoom: 13.5,
                ),
                markers: markers,
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                mapType: MapType.normal,
                onMapCreated: (controller) {
                  _controller = controller;
                  if (!_didMoveToUserLocation) {
                    _moveToUserLocation();
                  }
                },
              ),
              if (_selectedStore != null)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: _StoreBottomSheet(
                    store: _selectedStore,
                    onClose: () {
                      setState(() {
                        _selectedStore = null;
                      });
                    },
                  ),
                ),
            ],
          ),
          floatingActionButton: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FloatingActionButton(
                heroTag: 'current_location',
                backgroundColor: Theme.of(context).colorScheme.primary,
                onPressed: () {
                  if (_isGettingLocation) return;
                  _getCurrentLocation();
                },
                child: _isGettingLocation
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.my_location),
              ),
              const SizedBox(height: 12),
              FloatingActionButton.extended(
                heroTag: 'show_all_stores',
                onPressed: () {
                  if (_controller != null && stores.isNotEmpty) {
                    final bounds = _calculateBounds(stores);
                    _controller!.animateCamera(
                      CameraUpdate.newLatLngBounds(bounds, 50),
                    );
                  }
                },
                icon: const Icon(Icons.center_focus_strong),
                label: const Text('Show All'),
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StoreBottomSheet extends StatelessWidget {
  final dynamic store;
  final VoidCallback onClose;

  const _StoreBottomSheet({required this.store, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        store.name,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        store.address,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (store.phone != null)
                        Row(
                          children: [
                            Icon(
                              Icons.phone,
                              size: 16,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              store.phone,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                IconButton(icon: const Icon(Icons.close), onPressed: onClose),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Store details coming soon'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.info_outline),
                    label: const Text('View Details'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Opening directions...'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.directions),
                    label: const Text('Directions'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal.shade700,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
