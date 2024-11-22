// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:portaria_condominio/controllers/morador_controller.dart';
import 'package:url_launcher/url_launcher.dart';
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

    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.person),
              title: Text(morador.nome),
              subtitle: Text(morador.email),
              onTap: () {
                setState(() {
                  expandedIndex = isExpanded ? null : index;
                });
              },
              trailing: Icon(
                isExpanded ? Icons.expand_less : Icons.expand_more,
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
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label ',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: theme.textTheme.bodyLarge?.color,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: theme.textTheme.bodyLarge?.color?.withOpacity(0.7),
            ),
          ),
        ),
      ],
    );
  }

  Widget _expandedButtons(Morador morador) {
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
            ),
            _actionButton(
              icon: Icons.message,
              label: 'Mensagem',
              onTap: () => _sendMessage(morador.telefone),
            ),
            _actionButton(
              icon: FontAwesomeIcons.whatsapp,
              label: 'WhatsApp',
              onTap: () => openWhatsapp(
                  context: context,
                  text: "Olá, ${morador.nome}!",
                  number: morador.telefone),
            ),
            _actionButton(
              icon: Icons.edit,
              label: 'Editar',
              onTap: () => _editResident(morador),
            ),
            _actionButton(
              icon: Icons.delete,
              label: 'Excluir',
              onTap: () => _deleteResident(morador),
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
  }) {
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
              color: Theme.of(context).primaryColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 30),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
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

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Editar Morador'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nomeController,
                  decoration: const InputDecoration(labelText: 'Nome'),
                ),
                TextField(
                  controller: cpfController,
                  decoration: const InputDecoration(labelText: 'CPF'),
                ),
                TextField(
                  controller: telefoneController,
                  decoration: const InputDecoration(labelText: 'Telefone'),
                ),
                TextField(
                  controller: enderecoController,
                  decoration: const InputDecoration(labelText: 'Endereço'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  final atualizado = Morador(
                    id: morador.id,
                    nome: nomeController.text.trim(),
                    cpf: cpfController.text.trim(),
                    telefone: telefoneController.text.trim(),
                    email: morador.email, // Não editável
                    senha: morador.senha, // Não editável
                    endereco: enderecoController.text.trim(),
                    role: morador.role, // Mantém o mesmo papel
                  );
                  await _controller.atualizarMorador(atualizado);
                  setState(() {}); // Atualiza a lista
                  Navigator.pop(context); // Fecha o diálogo
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Morador atualizado com sucesso!')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erro ao atualizar morador: $e')),
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

    final confirmation = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmar Exclusão'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                  'Digite "excluir" para confirmar a exclusão do morador ${morador.nome}.'),
              const SizedBox(height: 8),
              TextField(
                controller: confirmController,
                decoration: const InputDecoration(
                    hintText: 'Digite "excluir" para confirmar.'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (confirmController.text.trim().toLowerCase() == 'excluir') {
                  Navigator.pop(context, true);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(
                            'Você precisa digitar "excluir" para confirmar.')),
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
        setState(() {}); // Atualizar lista após exclusão
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Morador excluído com sucesso!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao excluir morador: $e')),
        );
      }
    }
  }

  void _showAddress() {}
}
