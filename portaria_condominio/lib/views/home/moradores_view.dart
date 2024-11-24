import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:portaria_condominio/controllers/morador_controller.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../controllers/configuracoes_controller.dart';
import '../../models/morador_model.dart';
import '../../localizations/app_localizations.dart';
import 'cadastro_moradores_view.dart';
import '../../views/chat/chat_view.dart';

class MoradoresView extends StatefulWidget {
  const MoradoresView({super.key});

  @override
  _MoradoresViewState createState() => _MoradoresViewState();
}

class _MoradoresViewState extends State<MoradoresView> with TickerProviderStateMixin {
  final MoradorController _controller = MoradorController();
  int? expandedIndex;
  late Future<List<Morador>> _futureMoradores;
  final Map<int, AnimationController> _animationControllers = {};

  @override
  void initState() {
    super.initState();
    _futureMoradores = _controller.buscarTodosMoradores();
  }

  @override
  void dispose() {
    for (var controller in _animationControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  AnimationController _getAnimationController(int index) {
    if (!_animationControllers.containsKey(index)) {
      _animationControllers[index] = AnimationController(
        duration: const Duration(milliseconds: 300),
        vsync: this,
      );
    }
    return _animationControllers[index]!;
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.translate('residents')),
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
              child: Text(
                '${localizations.translate('error')}: ${snapshot.error}',
                style: TextStyle(color: colorScheme.error),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(localizations.translate('no_residents_found')),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final morador = snapshot.data![index];
              final isExpanded = index == expandedIndex;

              return AnimatedBuilder(
                animation: _getAnimationController(index),
                builder: (context, child) {
                  final controller = _getAnimationController(index);
                  final elevationAnimation = Tween<double>(begin: 1, end: 8).animate(
                    CurvedAnimation(
                      parent: controller,
                      curve: Curves.easeInOut,
                    ),
                  );
                  final expansionAnimation = CurvedAnimation(
                    parent: controller,
                    curve: Curves.easeInOut,
                  );

                  if (isExpanded) {
                    controller.forward();
                  } else {
                    controller.reverse();
                  }

                  return Card(
                    margin: const EdgeInsets.all(8.0),
                    elevation: elevationAnimation.value,
                    child: Column(
                      children: [
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                expandedIndex = isExpanded ? null : index;
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  Hero(
                                    tag: 'avatar_${morador.id}',
                                    child: CircleAvatar(
                                      backgroundColor: colorScheme.primary,
                                      child: Text(
                                        morador.nome[0].toUpperCase(),
                                        style: TextStyle(color: colorScheme.onPrimary),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          morador.nome,
                                          style: Theme.of(context).textTheme.titleMedium,
                                        ),
                                        Text(
                                          morador.apartamento,
                                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            color: colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  RotationTransition(
                                    turns: Tween(begin: 0.0, end: 0.5)
                                        .animate(expansionAnimation),
                                    child: Icon(
                                      Icons.expand_more,
                                      color: colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        ClipRect(
                          child: AnimatedSize(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            child: SizeTransition(
                              sizeFactor: expansionAnimation,
                              child: isExpanded
                                  ? Column(
                                      children: [
                                        const Divider(),
                                        Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              _buildInfoRow(
                                                localizations.translate('cpf'),
                                                morador.cpf,
                                                colorScheme,
                                              ),
                                              const SizedBox(height: 8),
                                              _buildInfoRow(
                                                localizations.translate('email'),
                                                morador.email,
                                                colorScheme,
                                              ),
                                              const SizedBox(height: 8),
                                              _buildInfoRow(
                                                localizations.translate('phone'),
                                                morador.telefone,
                                                colorScheme,
                                              ),
                                              const SizedBox(height: 16),
                                              _buildActionButtons(
                                                morador,
                                                localizations,
                                                colorScheme,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    )
                                  : const SizedBox.shrink(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, ColorScheme colorScheme) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: colorScheme.primary,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(color: colorScheme.onSurface),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(
    Morador morador,
    AppLocalizations localizations,
    ColorScheme colorScheme,
  ) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildActionButton(
              icon: Icons.phone,
              label: localizations.translate('call'),
              onPressed: () => _makePhoneCall(morador.telefone),
              colorScheme: colorScheme,
            ),
            _buildActionButton(
              icon: Icons.message,
              label: localizations.translate('message'),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatView(
                    receiverId: morador.id,
                    receiverName: morador.nome,
                  ),
                ),
              ),
              colorScheme: colorScheme,
            ),
            _buildActionButton(
              icon: FontAwesomeIcons.whatsapp,
              label: localizations.translate('whatsapp'),
              onPressed: () => _openWhatsApp(morador.telefone),
              colorScheme: colorScheme,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildActionButton(
              icon: Icons.edit,
              label: localizations.translate('edit'),
              onPressed: () => _editarMorador(morador),
              colorScheme: colorScheme,
            ),
            _buildActionButton(
              icon: Icons.delete,
              label: localizations.translate('delete'),
              onPressed: () => _confirmarExclusao(morador),
              colorScheme: colorScheme,
              isDestructive: true,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required ColorScheme colorScheme,
    bool isDestructive = false,
  }) {
    return TextButton.icon(
      icon: Icon(
        icon,
        color: isDestructive ? colorScheme.error : colorScheme.primary,
      ),
      label: Text(
        label,
        style: TextStyle(
          color: isDestructive ? colorScheme.error : colorScheme.primary,
        ),
      ),
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: isDestructive ? colorScheme.error : colorScheme.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri uri = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _sendSMS(String phoneNumber) async {
    final Uri uri = Uri.parse('sms:$phoneNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _openWhatsApp(String phoneNumber) async {
    String formattedNumber = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    if (!formattedNumber.startsWith('55')) {
      formattedNumber = '55$formattedNumber';
    }
    final url = 'https://wa.me/$formattedNumber';
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _editarMorador(Morador morador) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CadastroMoradoresView(morador: morador),
      ),
    );

    if (result == true) {
      setState(() {
        _futureMoradores = _controller.buscarTodosMoradores();
      });
    }
  }

  Future<void> _confirmarExclusao(Morador morador) async {
    final localizations = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations.translate('confirm_delete')),
        content: Text(localizations.translate('delete_resident_confirmation')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(localizations.translate('cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(localizations.translate('delete')),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _controller.excluirMorador(morador.id);
        setState(() {
          _futureMoradores = _controller.buscarTodosMoradores();
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(localizations.translate('resident_deleted')),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${localizations.translate('error_deleting_resident')}: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
