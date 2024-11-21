import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class RoutingService {
  final String _mapboxApiKey =
      'pk.eyJ1IjoibWF5Y29uY29ycmVhIiwiYSI6ImNtM3J5MHR3bDBiaWgyeHEyZml3OW5uMHYifQ.5c2LE-oEK6ec8mWjuRcspQ'; // Substitua pela sua chave

  Future<List<LatLng>> getRoute(LatLng start, LatLng end) async {
    final url =
        'https://api.mapbox.com/directions/v5/mapbox/driving/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?geometries=geojson&access_token=$_mapboxApiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> coordinates =
          data['routes'][0]['geometry']['coordinates'];

      return coordinates
          .map((coord) =>
              LatLng(coord[1], coord[0])) // Inverte latitude e longitude
          .toList();
    } else {
      throw Exception('Erro ao obter rota: ${response.reasonPhrase}');
    }
  }
}
