import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';
import '../../controllers/morador_controller.dart';
import '../../models/morador_model.dart';
import '../../localizations/app_localizations.dart'; // Import das traduções

class MapaView extends StatefulWidget {
  const MapaView({super.key});

  @override
  State<MapaView> createState() => _MapaViewState();
}

class _MapaViewState extends State<MapaView> {
  final TextEditingController _searchController = TextEditingController();
  final MoradorController _moradorController = MoradorController();
  final MapController _mapController = MapController();

  LatLng _currentLocation =
      const LatLng(-22.566451, -47.401524); // Centro de Limeira
  List<Morador> _moradores = [];

  @override
  void initState() {
    super.initState();
    _loadMoradores();
  }

  Future<void> _loadMoradores() async {
    try {
      final moradores = await _moradorController.buscarTodosMoradores();
      setState(() {
        _moradores = moradores;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar moradores: $e')),
      );
    }
  }

  Future<void> _searchAddress(String address) async {
    try {
      final locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        final location = locations.first;
        setState(() {
          _currentLocation = LatLng(location.latitude, location.longitude);
        });
        _mapController.move(_currentLocation, 15);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao buscar endereço: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations =
        AppLocalizations.of(context); // Instância de traduções

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.translate('map_title')),
      ),
      body: Column(
        children: [
          _buildSearchField(localizations),
          _buildMap(),
          _buildMoradorList(localizations),
        ],
      ),
    );
  }

  Widget _buildSearchField(AppLocalizations localizations) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: localizations.translate('search_address'),
          suffixIcon: IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _searchAddress(_searchController.text),
          ),
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildMap() {
    return Expanded(
      flex: 2,
      child: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: _currentLocation,
          initialZoom: 15,
        ),
        children: [
          TileLayer(
            urlTemplate:
                'https://api.maptiler.com/maps/basic/{z}/{x}/{y}.png?key=F6GzFLzm4QzPil3r48OC',
            subdomains: const ['a', 'b', 'c'],
            userAgentPackageName: 'portaria_condominio',
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: _currentLocation,
                child: const Icon(
                  Icons.location_on,
                  size: 40,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMoradorList(AppLocalizations localizations) {
    return Expanded(
      child: _moradores.isEmpty
          ? Center(
              child: Text(localizations.translate('no_residents_found')),
            )
          : ListView.builder(
              itemCount: _moradores.length,
              itemBuilder: (context, index) {
                final morador = _moradores[index];
                return ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(morador.nome),
                  // subtitle: Text(morador.endereco),
                  // onTap: () => _searchAddress(morador.endereco),
                );
              },
            ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
