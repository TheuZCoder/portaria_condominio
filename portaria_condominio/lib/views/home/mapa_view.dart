// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart' as loc;
import 'package:provider/provider.dart';
import '../../controllers/configuracoes_controller.dart';
import '../../localizations/app_localizations.dart'; // Import das traduções
import '../../services/routing_service.dart';
import '../../controllers/morador_controller.dart';
import '../../models/morador_model.dart';

class MapaView extends StatefulWidget {
  const MapaView({super.key});

  @override
  State<MapaView> createState() => _MapaViewState();
}

class _MapaViewState extends State<MapaView> {
  final TextEditingController _searchController = TextEditingController();
  final MoradorController _moradorController = MoradorController();
  final MapController _mapController = MapController();

  final LatLng _currentLocation =
      const LatLng(-22.566451, -47.401524); // Centro de Limeira
  LatLng? _userLocation;
  LatLng? _destination;
  List<LatLng> _routePoints = [];
  List<Morador> _moradores = [];
  late loc.Location _locationService;

  @override
  void initState() {
    super.initState();
    _locationService = loc.Location();
    _loadMoradores();
    _getUserLocation();
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

  Future<void> _getUserLocation() async {
    try {
      bool serviceEnabled = await _locationService.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _locationService.requestService();
        if (!serviceEnabled) {
          throw Exception('O serviço de localização não está habilitado.');
        }
      }

      final hasPermission = await _locationService.hasPermission();
      if (hasPermission == loc.PermissionStatus.denied) {
        final permissionGranted = await _locationService.requestPermission();
        if (permissionGranted != loc.PermissionStatus.granted) {
          throw Exception('Permissão de localização não concedida.');
        }
      }

      final locationData = await _locationService.getLocation();
      setState(() {
        _userLocation = LatLng(locationData.latitude!, locationData.longitude!);
      });
      _mapController.move(_userLocation!, 15);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao obter localização: $e')),
      );
    }
  }

  Future<void> _searchAddress(String address) async {
    try {
      final locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        final location = locations.first;
        _destination = LatLng(location.latitude, location.longitude);

        if (_userLocation != null) {
          final routingService = RoutingService();
          final route =
              await routingService.getRoute(_userLocation!, _destination!);

          setState(() {
            _routePoints =
                route; // Atualiza os pontos da rota com os dados da API
          });
          _mapController.move(_destination!, 15);
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao buscar endereço: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final configController = context.watch<ConfiguracoesController>();
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.translate('map_title')),
      ),
      body: Column(
        children: [
          _buildSearchField(localizations),
          _buildMap(configController),
          _buildMoradorList(localizations, configController),
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

  Widget _buildMap(ConfiguracoesController configController) {
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
          ),
          if (_userLocation != null)
            MarkerLayer(
              markers: [
                Marker(
                  point: _userLocation!,
                  child: Icon(
                    Icons.my_location,
                    size: 40,
                    color: configController.iconColor,
                  ),
                ),
              ],
            ),
          if (_destination != null && _routePoints.isEmpty)
            MarkerLayer(
              markers: [
                Marker(
                  point: _destination!,
                  child: Icon(
                    Icons.location_on,
                    size: 40,
                    color: configController.iconColor,
                  ),
                ),
              ],
            ),
          if (_routePoints.isNotEmpty)
            PolylineLayer(
              polylines: [
                Polyline(
                  points: _routePoints,
                  color: configController.iconColor,
                  strokeWidth: 5.0,
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildMoradorList(
      AppLocalizations localizations, ConfiguracoesController configController) {
    return Expanded(
      child: _moradores.isEmpty
          ? Center(child: Text(localizations.translate('no_residents_found')))
          : ListView.builder(
              itemCount: _moradores.length,
              itemBuilder: (context, index) {
                final morador = _moradores[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    leading: Icon(
                      Icons.person,
                      color: configController.iconColor,
                    ),
                    title: Text(morador.nome),
                    subtitle: Text(morador.endereco),
                    trailing: IconButton(
                      icon: Icon(Icons.directions,
                          color: configController.iconColor),
                      onPressed: () => _startRouteToMorador(morador.endereco),
                    ),
                    onTap: () => _showMoradorLocation(morador.endereco),
                  ),
                );
              },
            ),
    );
  }

  Future<void> _showMoradorLocation(String address) async {
    try {
      final locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        final location = locations.first;
        setState(() {
          _destination = LatLng(location.latitude, location.longitude);
          _routePoints.clear(); // Limpa a rota
        });
        _mapController.move(_destination!, 18); // Move o mapa para o endereço
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao buscar localização: $e')),
      );
    }
  }

  Future<void> _startRouteToMorador(String address) async {
    try {
      final locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        final location = locations.first;
        _destination = LatLng(location.latitude, location.longitude);

        if (_userLocation != null) {
          final routingService = RoutingService();
          final route =
              await routingService.getRoute(_userLocation!, _destination!);

          setState(() {
            _routePoints = route; // Define os pontos da rota
          });
          _mapController.move(_userLocation!, 15); // Move para o ponto inicial
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao iniciar rota: $e')),
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
