import 'package:flutter/material.dart';
import '../../controllers/morador_controller.dart';
import '../../controllers/prestador_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../models/morador_model.dart';
import '../../models/prestador_model.dart';

class ContactsListView extends StatefulWidget {
  const ContactsListView({super.key});

  @override
  State<ContactsListView> createState() => _ContactsListViewState();
}

class _ContactsListViewState extends State<ContactsListView> {
  final MoradorController _moradorController = MoradorController();
  final PrestadorController _prestadorController = PrestadorController();

  List<Morador> _moradores = [];
  List<Prestador> _prestadores = [];

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    try {
      final moradores = await _moradorController.buscarTodosMoradores();
      final prestadores = await _prestadorController.buscarTodosPrestadores();
      setState(() {
        _moradores = moradores;
        _prestadores = prestadores;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar contatos: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ..._moradores.map((morador) => ListTile(
              leading: const Icon(Icons.person),
              title: Text(morador.nome),
              subtitle: const Text('Morador'),
              onTap: () {
                Navigator.pushNamed(context, '/chat', arguments: morador);
              },
            )),
        ..._prestadores.map((prestador) => ListTile(
              leading: const Icon(Icons.build),
              title: Text(prestador.nome),
              subtitle: const Text('Prestador'),
              onTap: () {
                Navigator.pushNamed(context, '/chat', arguments: prestador);
              },
            )),
      ],
    );
  }
}
