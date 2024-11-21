import 'package:flutter/material.dart';
import '../../controllers/morador_controller.dart';
import '../../controllers/prestador_controller.dart';
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
  bool _isLoading = true;

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
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar contatos: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_moradores.isEmpty && _prestadores.isEmpty) {
      return const Center(
        child: Text('Nenhum contato encontrado.'),
      );
    }

    return ListView(
      children: [
        if (_moradores.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Moradores',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ..._moradores.map((morador) => ListTile(
                leading: const Icon(Icons.person),
                title: Text(morador.nome),
                subtitle: Text(morador.email), // Mostra o e-mail do morador
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/chat',
                    arguments: {
                      'id': morador.id,
                      'nome': morador.nome,
                    },
                  );
                },
              )),
        ],
        if (_prestadores.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Prestadores',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ..._prestadores.map((prestador) => ListTile(
                leading: const Icon(Icons.build),
                title: Text(prestador.nome),
                subtitle: Text(prestador.empresa), // Mostra a empresa associada
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/chat',
                    arguments: {
                      'id': prestador.id,
                      'nome': prestador.nome,
                    },
                  );
                },
              )),
        ],
      ],
    );
  }
}
