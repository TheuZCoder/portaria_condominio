import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapaView extends StatefulWidget {
  const MapaView({super.key});

  @override
  State<MapaView> createState() => _MapaViewState();
}

class _MapaViewState extends State<MapaView> {
  final TextEditingController _searchController = TextEditingController();
  final LatLng _condominioLocation =
      const LatLng(-22.566451, -47.401524); // Centro de Limeira

  final List<String> _moradores = [
    "João Silva - Bloco A, Ap. 101",
    "Maria Oliveira - Bloco B, Ap. 202",
    "Carlos Santos - Bloco C, Ap. 303",
    "Ana Costa - Bloco A, Ap. 102",
    "Fernanda Lima - Bloco B, Ap. 204",
  ];

  void _searchAddress(String address) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Buscando endereço: $address')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mapa')),
      body: Column(
        children: [
          _buildSearchField(),
          _buildMap(),
          _buildMoradorList(),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Buscar endereço...',
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
        options: MapOptions(
          initialCenter: _condominioLocation,
          initialZoom: 15,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: const ['a', 'b', 'c'],
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: _condominioLocation,
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

  Widget _buildMoradorList() {
    return Expanded(
      child: ListView.builder(
        itemCount: _moradores.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: const Icon(Icons.person),
            title: Text(_moradores[index]),
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