import 'package:flutter/material.dart';
import '../views/chat/chat_view.dart';
import '../views/home/configuracoes_view.dart';
import '../views/home/home_view.dart';
import '../views/home/mapa_view.dart';
import '../views/home/moradores_view.dart';
import '../views/home/notificacoes_view.dart';
import '../views/home/pedidos_view.dart';
import '../views/home/prestadores_view.dart';
import '../views/home/visitas_view.dart';
import '../views/login/cadastro_view.dart';
import '../views/login/login_view.dart';

class AppRoutes {
  static const String login = '/login';
  static const String cadastro = '/cadastro';
  static const String home = '/home';
  static const String moradores = '/moradores';
  static const String prestadores = '/prestadores';
  static const String visitas = '/visitas';
  static const String pedidos = '/pedidos';
  static const String notificacoes = '/notificacoes';
  static const String mapa = '/mapa';
  static const String configuracoes = '/configuracoes';
  static const String chat = '/chat';

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginView());
      case cadastro:
        return MaterialPageRoute(builder: (_) => const CadastroView());
      case home:
        return MaterialPageRoute(builder: (_) => const HomeView());
      case moradores:
        return MaterialPageRoute(builder: (_) => const MoradoresView());
      case prestadores:
        return MaterialPageRoute(builder: (_) => const PrestadoresView());
      case visitas:
        return MaterialPageRoute(builder: (_) => const VisitasView());
      case pedidos:
        return MaterialPageRoute(builder: (_) => const PedidosView());
      case notificacoes:
        return MaterialPageRoute(builder: (_) => const NotificacoesView());
      case mapa:
        return MaterialPageRoute(builder: (_) => const MapaView());
      case configuracoes:
        return MaterialPageRoute(builder: (_) => const ConfiguracoesView());
      case chat:
        if (settings.arguments is Map) {
          final args = settings.arguments as Map<String, dynamic>;
          final receiverId = args['id'] as String;
          final receiverName = args['nome'] as String;
          return MaterialPageRoute(
            builder: (_) => ChatView(receiverId: receiverId, receiverName: receiverName),
          );
        }
        return _errorRoute();
      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(
      builder: (_) => const Scaffold(
        body: Center(child: Text('Rota não encontrada')),
      ),
    );
  }
}
