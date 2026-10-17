import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../theme/noor_theme.dart';
import 'noor_store.dart';

class LocationModel {
  const LocationModel({
    required this.city,
    required this.country,
    required this.latitude,
    required this.longitude,
    this.isLive = false,
  });

  final String city;
  final String country;
  final double latitude;
  final double longitude;
  final bool isLive;

  String get label => '$city, $country';

  Map<String, dynamic> toJson() => {
        'city': city,
        'country': country,
        'latitude': latitude,
        'longitude': longitude,
        'isLive': isLive,
      };

  factory LocationModel.fromJson(Map<String, dynamic> json) => LocationModel(
        city: json['city'] as String? ?? 'Karachi',
        country: json['country'] as String? ?? 'Pakistan',
        latitude: (json['latitude'] as num?)?.toDouble() ?? 24.8608,
        longitude: (json['longitude'] as num?)?.toDouble() ?? 67.0011,
        isLive: json['isLive'] as bool? ?? false,
      );

  static const LocationModel defaultLocation = LocationModel(
    city: 'Karachi',
    country: 'Pakistan',
    latitude: 24.8608,
    longitude: 67.0011,
    isLive: false,
  );
}

class LocationService {
  LocationService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  /// Detects real live location via secure IP-based geolocation.
  /// Works across Android, iOS, Windows, and Web with zero native permissions or GPS popups required.
  Future<LocationModel?> fetchLiveLocation() async {
    // 1. Primary: ip-api.com
    try {
      final uri = Uri.parse('http://ip-api.com/json/?fields=status,message,country,city,lat,lon');
      final res = await _client.get(uri).timeout(const Duration(seconds: 7));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        if (data['status'] == 'success') {
          final city = data['city'] as String? ?? '';
          final country = data['country'] as String? ?? '';
          final lat = (data['lat'] as num?)?.toDouble();
          final lon = (data['lon'] as num?)?.toDouble();
          if (city.isNotEmpty && lat != null && lon != null) {
            final model = LocationModel(
              city: city,
              country: country,
              latitude: lat,
              longitude: lon,
              isLive: true,
            );
            await saveLocation(model);
            return model;
          }
        }
      }
    } catch (e) {
      debugPrint('LocationService: ip-api detection failed: $e');
    }

    // 2. Fallback mirror: ipapi.co
    try {
      final uri = Uri.parse('https://ipapi.co/json/');
      final res = await _client.get(uri).timeout(const Duration(seconds: 7));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final city = data['city'] as String? ?? '';
        final country = data['country_name'] as String? ?? '';
        final lat = (data['latitude'] as num?)?.toDouble();
        final lon = (data['longitude'] as num?)?.toDouble();
        if (city.isNotEmpty && lat != null && lon != null) {
          final model = LocationModel(
            city: city,
            country: country,
            latitude: lat,
            longitude: lon,
            isLive: true,
          );
          await saveLocation(model);
          return model;
        }
      }
    } catch (e) {
      debugPrint('LocationService: ipapi.co fallback failed: $e');
    }

    return null;
  }

  /// Saves chosen or detected location to local persistent store.
  Future<void> saveLocation(LocationModel loc) async {
    await NoorStore.setCity(loc.city);
    await NoorStore.setCountry(loc.country);
    await NoorStore.cacheJson('location.current', jsonEncode(loc.toJson()));
  }

  /// Gets the currently saved location, or returns default Karachi.
  Future<LocationModel> getSavedLocation() async {
    try {
      final raw = await NoorStore.cachedJson('location.current');
      if (raw != null && raw.isNotEmpty) {
        final data = jsonDecode(raw) as Map<String, dynamic>;
        return LocationModel.fromJson(data);
      }
      final city = await NoorStore.getCity();
      final country = await NoorStore.getCountry();
      // Match from curated list if coordinates exist
      for (final c in popularCities) {
        if (c.city.toLowerCase() == city.toLowerCase()) {
          return c;
        }
      }
      return LocationModel(
        city: city,
        country: country,
        latitude: LocationModel.defaultLocation.latitude,
        longitude: LocationModel.defaultLocation.longitude,
        isLive: false,
      );
    } catch (_) {
      return LocationModel.defaultLocation;
    }
  }

  /// Popular cities for quick selection
  static const List<LocationModel> popularCities = [
    LocationModel(city: 'Karachi', country: 'Pakistan', latitude: 24.8608, longitude: 67.0011),
    LocationModel(city: 'Lahore', country: 'Pakistan', latitude: 31.5204, longitude: 74.3587),
    LocationModel(city: 'Islamabad', country: 'Pakistan', latitude: 33.6844, longitude: 73.0479),
    LocationModel(city: 'Rawalpindi', country: 'Pakistan', latitude: 33.5651, longitude: 73.0169),
    LocationModel(city: 'Faisalabad', country: 'Pakistan', latitude: 31.4504, longitude: 73.1350),
    LocationModel(city: 'Multan', country: 'Pakistan', latitude: 30.1575, longitude: 71.5249),
    LocationModel(city: 'Peshawar', country: 'Pakistan', latitude: 34.0151, longitude: 71.5249),
    LocationModel(city: 'Quetta', country: 'Pakistan', latitude: 30.1798, longitude: 66.9750),
    LocationModel(city: 'Makkah', country: 'Saudi Arabia', latitude: 21.4225, longitude: 39.8262),
    LocationModel(city: 'Madinah', country: 'Saudi Arabia', latitude: 24.5247, longitude: 39.5692),
    LocationModel(city: 'Riyadh', country: 'Saudi Arabia', latitude: 24.7136, longitude: 46.6753),
    LocationModel(city: 'Jeddah', country: 'Saudi Arabia', latitude: 21.5433, longitude: 39.1728),
    LocationModel(city: 'Dubai', country: 'United Arab Emirates', latitude: 25.2048, longitude: 55.2708),
    LocationModel(city: 'Abu Dhabi', country: 'United Arab Emirates', latitude: 24.4539, longitude: 54.3773),
    LocationModel(city: 'Doha', country: 'Qatar', latitude: 25.2854, longitude: 51.5310),
    LocationModel(city: 'Istanbul', country: 'Turkey', latitude: 41.0082, longitude: 28.9784),
    LocationModel(city: 'Cairo', country: 'Egypt', latitude: 30.0444, longitude: 31.2357),
    LocationModel(city: 'London', country: 'United Kingdom', latitude: 51.5074, longitude: -0.1278),
    LocationModel(city: 'Birmingham', country: 'United Kingdom', latitude: 52.4862, longitude: -1.8904),
    LocationModel(city: 'New York', country: 'United States', latitude: 40.7128, longitude: -74.0060),
    LocationModel(city: 'Toronto', country: 'Canada', latitude: 43.6532, longitude: -79.3832),
    LocationModel(city: 'Kuala Lumpur', country: 'Malaysia', latitude: 3.1390, longitude: 101.6869),
    LocationModel(city: 'Jakarta', country: 'Indonesia', latitude: -6.2088, longitude: 106.8456),
    LocationModel(city: 'Dhaka', country: 'Bangladesh', latitude: 23.8103, longitude: 90.4125),
  ];

  static Future<LocationModel> getCachedLocation() => LocationService().getSavedLocation();

  /// Displays an interactive modal sheet allowing the user to detect live location
  /// or pick any city.
  static Future<LocationModel?> showLocationPicker({
    required BuildContext context,
    LocationModel? current,
  }) async {
    return showModalBottomSheet<LocationModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _LocationPickerSheet(current: current),
    );
  }
}

class _LocationPickerSheet extends StatefulWidget {
  const _LocationPickerSheet({this.current});
  final LocationModel? current;

  @override
  State<_LocationPickerSheet> createState() => _LocationPickerSheetState();
}

class _LocationPickerSheetState extends State<_LocationPickerSheet> {
  bool _detecting = false;
  String _search = '';
  final TextEditingController _searchCtrl = TextEditingController();

  Future<void> _detectLiveLocation() async {
    setState(() => _detecting = true);
    final service = LocationService();
    final result = await service.fetchLiveLocation();
    if (!mounted) return;
    setState(() => _detecting = false);
    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Location updated: ${result.label}'),
          backgroundColor: NoorColors.emeraldDark,
          duration: const Duration(seconds: 2),
        ),
      );
      Navigator.of(context).pop(result);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not auto-detect location. Please select your city below.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filtered = LocationService.popularCities.where((c) {
      if (_search.isEmpty) return true;
      final q = _search.toLowerCase();
      return c.city.toLowerCase().contains(q) || c.country.toLowerCase().contains(q);
    }).toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.78,
      decoration: BoxDecoration(
        color: isDark ? NoorColors.darkCard : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            Center(
              child: Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: isDark ? NoorColors.darkBorder : NoorColors.hairline,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Select Location',
                      style: NoorType.screenTitle.copyWith(
                        color: isDark ? NoorColors.darkTextPrimary : NoorColors.ink,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            // Auto Detect Live Location Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [NoorColors.emeraldDark, NoorColors.emeraldMid],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: NoorShadows.card,
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: _detecting ? null : _detectLiveLocation,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      child: Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.16),
                            ),
                            child: _detecting
                                ? const Center(
                                    child: SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    ),
                                  )
                                : const Icon(Icons.my_location, color: Colors.white, size: 20),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _detecting ? 'Detecting your location...' : 'Use Live Location',
                                  style: NoorType.cardTitle.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Auto-detect city & prayer times via network',
                                  style: NoorType.meta.copyWith(
                                    color: Colors.white.withValues(alpha: 0.8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 14),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Search Input
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (val) => setState(() => _search = val),
                decoration: InputDecoration(
                  hintText: 'Search city or country...',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  suffixIcon: _search.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            _searchCtrl.clear();
                            setState(() => _search = '');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: isDark ? NoorColors.darkSurface : NoorColors.cream,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: isDark ? NoorColors.darkBorder : NoorColors.hairline,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: isDark ? NoorColors.darkBorder : NoorColors.hairline,
                    ),
                  ),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 10, 20, 4),
              child: Text(
                'POPULAR CITIES',
                style: NoorType.eyebrow,
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                itemCount: filtered.length,
                itemBuilder: (context, idx) {
                  final item = filtered[idx];
                  final isCurrent = widget.current?.city.toLowerCase() == item.city.toLowerCase();
                  return ListTile(
                    dense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                    leading: CircleAvatar(
                      radius: 16,
                      backgroundColor: isCurrent ? NoorColors.emeraldDark : (isDark ? NoorColors.darkSurface : NoorColors.cream),
                      child: Icon(
                        Icons.location_city,
                        size: 16,
                        color: isCurrent ? Colors.white : NoorColors.emeraldDark,
                      ),
                    ),
                    title: Text(
                      item.city,
                      style: TextStyle(
                        fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w600,
                        color: isCurrent ? NoorColors.emeraldDark : (isDark ? NoorColors.darkTextPrimary : NoorColors.ink),
                      ),
                    ),
                    subtitle: Text(
                      item.country,
                      style: NoorType.meta.copyWith(
                        color: isDark ? NoorColors.darkTextSecondary : NoorColors.muted,
                      ),
                    ),
                    trailing: isCurrent
                        ? const Icon(Icons.check_circle, color: NoorColors.emeraldDark, size: 18)
                        : null,
                    onTap: () async {
                      await LocationService().saveLocation(item);
                      if (context.mounted) {
                        Navigator.of(context).pop(item);
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
