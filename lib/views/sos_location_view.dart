import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart'; // For implicit intent

class SosLocationView extends StatefulWidget {
  const SosLocationView({super.key});

  @override
  State<SosLocationView> createState() => _SosLocationViewState();
}

class _SosLocationViewState extends State<SosLocationView> {
  late GoogleMapController mapController;
  LatLng? _currentLocation;
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied.');
    }

    Position position = await Geolocator.getCurrentPosition();

    setState(() {
      _currentLocation = LatLng(position.latitude, position.longitude);
      _setMarkers();
    });
  }

  void _setMarkers() {
    if (_currentLocation == null) return;

    _markers.add(
      Marker(
        markerId: const MarkerId('my_location'),
        position: _currentLocation!,
        infoWindow: const InfoWindow(title: 'My Location'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      ),
    );

    final List<Map<String, dynamic>> clinics = [
      {
        'id': 'clinic1',
        'name': 'PUSAT KESIHATAN PELAJAR',
        'position': const LatLng(3.548616125203025, 103.43424808374591),
      },
      {
        'id': 'clinic2',
        'name': 'KLINIK KESIHATAN PERAMU JAYA',
        'position': const LatLng(3.546481845659516, 103.38309689533548),
      },
      {
        'id': 'clinic3',
        'name': 'KLINIK KESIHATAN BANDAR PEKAN',
        'position': const LatLng(3.4898744305982987, 103.39350976966534),
      },
    ];

    for (var clinic in clinics) {
      _markers.add(
        Marker(
          markerId: MarkerId(clinic['id']),
          position: clinic['position'],
          infoWindow: InfoWindow(title: clinic['name']),
        ),
      );
    }
  }

  // This function uses url_launcher to call the mental health helpline
  Future<void> _callHelpline() async {
    final Uri phoneUri = Uri(scheme: 'tel', path: '15999');
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open dialer')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SOS Location'),
        backgroundColor: Colors.redAccent,
      ),
      body: _currentLocation == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: GoogleMap(
                    onMapCreated: (controller) => mapController = controller,
                    initialCameraPosition: CameraPosition(
                      target: _currentLocation!,
                      zoom: 14,
                    ),
                    markers: _markers,
                    myLocationEnabled: true,
                    myLocationButtonEnabled: true,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: ElevatedButton.icon(
                    onPressed: _callHelpline,
                    icon: const Icon(Icons.phone),
                    label: const Text('Call Mental Health Helpline'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      minimumSize: const Size.fromHeight(50),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
