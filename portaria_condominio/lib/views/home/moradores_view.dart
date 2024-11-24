// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:portaria_condominio/controllers/morador_controller.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../controllers/configuracoes_controller.dart';
import '../../models/morador_model.dart';
import 'cadastro_moradores_view.dart';

class MoradoresView extends StatefulWidget {
  const MoradoresView({super.key});

  @override
  _MoradoresViewState createState() => _MoradoresViewState();
}

class _MoradoresViewState extends State<MoradoresView> {
  final MoradorController _controller = MoradorController();
  int? expandedIndex;
  late Future<List<Morador>> _futureMoradores;

  @override
  void initState() {
    super.initState();
    _futureMoradores = _controller.buscarTodosMoradores();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Moradores'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CadastroMoradoresView(),
                ),
              ).then((_) => setState(() {
                    _futureMoradores = _controller.buscarTodosMoradores();
                  }));
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Morador>>(
        future: _futureMoradores,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Erro: ${snapshot.error}'),
            );
          }
          final moradores = snapshot.data ?? [];
          if (moradores.isEmpty) {
            return const Center(child: Text('Nenhum morador cadastrado.'));
          }
          return ListView.builder(
            itemCount: moradores.length,
            itemBuilder: (context, index) {
              final morador = moradores[index];
              return _buildMoradorCard(morador, index);
            },
          );
        },
      ),
    );
  }

  Widget _buildMoradorCard(Morador morador, int index) {
    final bool isExpanded = expandedIndex == index;
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          children: [
            ListTile(
              leading: Icon(Icons.person, color: colorScheme.primary),
              title: Text(
                morador.nome,
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                morador.email,
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              onTap: () {
                setState(() {
                  expandedIndex = isExpanded ? null : index;
                });
              },
              trailing: Icon(
                isExpanded ? Icons.expand_less : Icons.expand_more,
                color: colorScheme.primary,
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) {
                return SizeTransition(sizeFactor: animation, child: child);
              },
              child: isExpanded ? _expandedDetails(morador) : const SizedBox(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _expandedDetails(Morador morador) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      key: const ValueKey('expandedDetails'),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _infoRow(label: 'CPF:', value: morador.cpf),
          const SizedBox(height: 8),
          _infoRow(label: 'Telefone:', value: morador.telefone),
          const SizedBox(height: 8),
          _infoRow(label: 'Endereço:', value: morador.endereco),
          const SizedBox(height: 8),
          _expandedButtons(morador),
        ],
      ),
    );
  }

  Widget _infoRow({required String label, required String value}) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label ',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: colorScheme.primary,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }

  Widget _expandedButtons(Morador morador) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _actionButton(
              icon: Icons.phone,
              label: 'Ligar',
              onTap: () => _callProvider(morador.telefone),
              color: colorScheme.primary,
            ),
            _actionButton(
              icon: Icons.message,
              label: 'Mensagem',
              onTap: () => _sendMessage(morador.telefone),
              color: colorScheme.primary,
            ),
            _actionButton(
              icon: FontAwesomeIcons.whatsapp,
              label: 'WhatsApp',
              onTap: () => openWhatsapp(
                  context: context,
                  text: "Olá, ${morador.nome}!",
                  number: morador.telefone),
              color: colorScheme.primary,
            ),
            _actionButton(
              icon: Icons.edit,
              label: 'Editar',
              onTap: () => _editResident(morador),
              color: colorScheme.primary,
            ),
            _actionButton(
              icon: Icons.delete,
              label: 'Excluir',
              onTap: () => _deleteResident(morador),
              color: colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(40),
          child: Container(
            width: 60,
            height: 60,
            margin: const EdgeInsets.symmetric(horizontal: 8.0),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: colorScheme.onPrimary, size: 30),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // Métodos associados aos botões
  void _callProvider(String phone) async {
    final Uri phoneUrl = Uri(scheme: 'tel', path: phone);
    try {
      if (await canLaunchUrl(phoneUrl)) {
        await launchUrl(phoneUrl);
      } else {
        throw 'Não foi possível realizar a ligação';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $e')),
      );
    }
  }

  void _sendMessage(String phoneNumber) async {
    final Uri smsUri = Uri(scheme: 'sms', path: phoneNumber);
    try {
      if (await canLaunchUrl(smsUri)) {
        await launchUrl(smsUri);
      } else {
        throw 'Não foi possível enviar a mensagem.';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $e')),
      );
    }
  }

  void openWhatsapp({
    required BuildContext context,
    required String text,
    required String number,
  }) async {
    final whatsappUrl =
        "https://wa.me/$number?text=${Uri.encodeComponent(text)}";
    try {
      if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
        await launchUrl(Uri.parse(whatsappUrl));
      } else {
        throw 'WhatsApp não está disponível.';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $e')),
      );
    }
  }

  void _editResident(Morador morador) async {
    final TextEditingController nomeController =
        TextEditingController(text: morador.nome);
    final TextEditingController cpfController =
        TextEditingController(text: morador.cpf);
    final TextEditingController telefoneController =
        TextEditingController(text: morador.telefone);
    final TextEditingController enderecoController =
        TextEditingController(text: morador.endereco);

    final colorScheme = Theme.of(context).colorScheme;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Editar Morador',
            style: TextStyle(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nomeController,
                  decoration: InputDecoration(
                    labelText: 'Nome',
                    labelStyle: TextStyle(color: colorScheme.primary),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: colorScheme.primary),
                    ),
                  ),
                ),
                TextField(
                  controller: cpfController,
                  decoration: InputDecoration(
                    labelText: 'CPF',
                    labelStyle: TextStyle(color: colorScheme.primary),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: colorScheme.primary),
                    ),
                  ),
                ),
                TextField(
                  controller: telefoneController,
                  decoration: InputDecoration(
                    labelText: 'Telefone',
                    labelStyle: TextStyle(color: colorScheme.primary),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: colorScheme.primary),
                    ),
                  ),
                ),
                TextField(
                  controller: enderecoController,
                  decoration: InputDecoration(
                    labelText: 'Endereço',
                    labelStyle: TextStyle(color: colorScheme.primary),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: colorScheme.primary),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancelar',
                style: TextStyle(color: colorScheme.primary),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
              ),
              onPressed: () async {
                try {
                  final atualizado = Morador(
                    id: morador.id,
                    nome: nomeController.text.trim(),
                    cpf: cpfController.text.trim(),
                    telefone: telefoneController.text.trim(),
                    email: morador.email,
                    senha: morador.senha,
                    endereco: enderecoController.text.trim(),
                    role: morador.role,
                  );
                  await _controller.atualizarMorador(atualizado);
                  setState(() {
                    _futureMoradores = _controller.buscarTodosMoradores();
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Morador atualizado com sucesso!'),
                      backgroundColor: colorScheme.primary,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erro ao atualizar morador: $e'),
                      backgroundColor: colorScheme.error,
                    ),
                  );
                }
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  void _deleteResident(Morador morador) async {
    final TextEditingController confirmController = TextEditingController();
    final colorScheme = Theme.of(context).colorScheme;

    final confirmation = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Confirmar Exclusão',
            style: TextStyle(
              color: colorScheme.error,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Digite "excluir" para confirmar a exclusão do morador ${morador.nome}.',
                style: TextStyle(color: colorScheme.onSurface),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: confirmController,
                decoration: InputDecoration(
                  hintText: 'Digite "excluir" para confirmar.',
                  hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: colorScheme.error),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                'Cancelar',
                style: TextStyle(color: colorScheme.primary),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.error,
                foregroundColor: colorScheme.onError,
              ),
              onPressed: () {
                if (confirmController.text.trim().toLowerCase() == 'excluir') {
                  Navigator.pop(context, true);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text(
                        'Você precisa digitar "excluir" para confirmar.',
                      ),
                      backgroundColor: colorScheme.error,
                    ),
                  );
                }
              },
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );

    if (confirmation == true) {
      try {
        await _controller.excluirMorador(morador.id);
        setState(() {
          _futureMoradores = _controller.buscarTodosMoradores();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Morador excluído com sucesso!'),
            backgroundColor: colorScheme.primary,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao excluir morador: $e'),
            backgroundColor: colorScheme.error,
          ),
        );
      }
    }
  }

  void _showAddress() {}
}
