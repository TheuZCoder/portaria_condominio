import 'package:flutter/material.dart';
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

  static final Map<String, WidgetBuilder> routes = {
    login: (context) => const LoginView(),
    cadastro: (context) => const CadastroView(),
    home: (context) => const HomeView(),
    moradores: (context) => const MoradoresView(),
    prestadores: (context) => const PrestadoresView(),
    visitas: (context) => const VisitasView(),
    pedidos: (context) => const PedidosView(),
    notificacoes: (context) => const NotificacoesView(),
    mapa: (context) => const MapaView(),
    configuracoes: (context) => const ConfiguracoesView(),
  };
}
