import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:portaria_condominio/controllers/morador_controller.dart';
import '../../models/morador_model.dart';
import '../../localizations/app_localizations.dart';
import '../photo_registration/photo_registration_screen.dart';

class CadastroMoradoresView extends StatefulWidget {
  final Morador? morador;
  
  const CadastroMoradoresView({super.key, this.morador});

  @override
  State<CadastroMoradoresView> createState() => _CadastroMoradoresViewState();
}

class _CadastroMoradoresViewState extends State<CadastroMoradoresView> {
  final _formKey = GlobalKey<FormState>();
  final _controller = MoradorController();
  
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _cpfController = TextEditingController();
  final TextEditingController _telefoneController = TextEditingController();
  final TextEditingController _enderecoController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  final TextEditingController _numeroCasaController = TextEditingController();

  String? _photoURL;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.morador != null) {
      _nomeController.text = widget.morador!.nome;
      _cpfController.text = widget.morador!.cpf;
      _telefoneController.text = widget.morador!.telefone;
      _enderecoController.text = widget.morador!.endereco;
      _emailController.text = widget.morador!.email;
      _numeroCasaController.text = widget.morador!.numeroCasa;
      _photoURL = widget.morador!.photoURL;
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _cpfController.dispose();
    _telefoneController.dispose();
    _enderecoController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _numeroCasaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.morador == null
              ? localizations.translate('add_resident')
              : localizations.translate('edit_resident'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Photo registration button
              Center(
                child: Column(
                  children: [
                    _buildAvatar(_photoURL),
                    const SizedBox(height: 10),
                    TextButton.icon(
                      onPressed: _isLoading ? null : _handlePhotoRegistration,
                      icon: const Icon(Icons.camera_alt),
                      label: Text(_photoURL == null
                          ? localizations.translate('add_photo')
                          : localizations.translate('change_photo')),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _nomeController,
                label: localizations.translate('name'),
                prefixIcon: const Icon(Icons.person),
                validator: (value) => value!.isEmpty 
                  ? localizations.translate('name_required') 
                  : null,
              ),
              _buildTextField(
                controller: _cpfController,
                label: localizations.translate('cpf'),
                prefixIcon: const Icon(Icons.badge),
                validator: (value) => value!.isEmpty 
                  ? localizations.translate('cpf_required') 
                  : null,
              ),
              _buildTextField(
                controller: _telefoneController,
                label: localizations.translate('phone'),
                prefixIcon: const Icon(Icons.phone),
                validator: (value) => value!.isEmpty 
                  ? localizations.translate('phone_required') 
                  : null,
              ),
              _buildTextField(
                controller: _numeroCasaController,
                label: localizations.translate('house_number'),
                prefixIcon: const Icon(Icons.home),
                validator: (value) => value!.isEmpty 
                  ? localizations.translate('house_number_required') 
                  : null,
              ),
              _buildTextField(
                controller: _enderecoController,
                label: localizations.translate('address'),
                prefixIcon: const Icon(Icons.location_on),
                validator: (value) => value!.isEmpty 
                  ? localizations.translate('address_required') 
                  : null,
              ),
              _buildTextField(
                controller: _emailController,
                label: localizations.translate('email'),
                prefixIcon: const Icon(Icons.email),
                validator: (value) => value!.isEmpty 
                  ? localizations.translate('email_required') 
                  : null,
              ),
              if (widget.morador == null)
                _buildTextField(
                  controller: _senhaController,
                  label: localizations.translate('password'),
                  prefixIcon: const Icon(Icons.lock),
                  obscureText: true,
                  validator: (value) => value!.isEmpty 
                    ? localizations.translate('password_required') 
                    : null,
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(widget.morador != null 
                        ? localizations.translate('save_changes')
                        : localizations.translate('register')),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(String? photoURL) {
    if (photoURL != null && photoURL.startsWith('data:image')) {
      try {
        final base64String = photoURL.split(',')[1];
        return Hero(
          tag: 'avatar_new_${DateTime.now().millisecondsSinceEpoch}',
          child: CircleAvatar(
            radius: 50,
            backgroundImage: MemoryImage(base64Decode(base64String)),
            backgroundColor: Colors.grey[300],
            onBackgroundImageError: (exception, stackTrace) {
              debugPrint('Erro ao carregar imagem: $exception');
              return;
            },
          ),
        );
      } catch (e) {
        debugPrint('Erro ao decodificar base64: $e');
        return _buildDefaultAvatar();
      }
    } else {
      return _buildDefaultAvatar();
    }
  }

  Widget _buildDefaultAvatar() {
    return Hero(
      tag: 'avatar_new_default_${DateTime.now().millisecondsSinceEpoch}',
      child: CircleAvatar(
        radius: 50,
        backgroundColor: Colors.grey[300],
        child: Icon(
          Icons.person,
          size: 50,
          color: Colors.grey[600],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required Widget prefixIcon,
    String? Function(String?)? validator,
    bool obscureText = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: prefixIcon,
          border: const OutlineInputBorder(),
        ),
        validator: validator,
      ),
    );
  }

  Future<void> _handlePhotoRegistration() async {
    final photoData = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => PhotoRegistrationScreen(
          userType: 'resident',
          userId: widget.morador?.id ?? '',
        ),
      ),
    );

    if (photoData != null) {
      setState(() {
        _photoURL = photoData;
      });

      // Se já existe um morador, atualiza a foto no banco
      if (widget.morador?.id != null) {
        try {
          await _controller.atualizarFotoMorador(widget.morador!.id, photoData);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Foto atualizada com sucesso!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Erro ao atualizar foto: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
      // Se for um novo morador, a foto será salva junto com os outros dados no _submitForm
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final morador = Morador(
        id: widget.morador?.id ?? '',
        nome: _nomeController.text,
        cpf: _cpfController.text,
        telefone: _telefoneController.text,
        endereco: _enderecoController.text,
        email: _emailController.text,
        senha: widget.morador?.senha ?? _senhaController.text,
        numeroCasa: _numeroCasaController.text,
        role: widget.morador?.role ?? 'morador',
        photoURL: _photoURL,
      );

      if (widget.morador != null) {
        await _controller.atualizarMorador(morador);
      } else {
        await _controller.cadastrarMorador(morador);
      }

      if (mounted) {
        final successMessage = widget.morador != null
            ? AppLocalizations.of(context).translate('resident_updated')
            : AppLocalizations.of(context).translate('resident_registered');

        if (widget.morador == null && _photoURL == null) {
          // If it's a new registration and no photo was added, prompt for photo
          final shouldAddPhoto = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(AppLocalizations.of(context).translate('add_photo_question')),
              content: Text(AppLocalizations.of(context).translate('add_photo_prompt')),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(AppLocalizations.of(context).translate('later')),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text(AppLocalizations.of(context).translate('add_now')),
                ),
              ],
            ),
          );

          if (shouldAddPhoto == true) {
            await _handlePhotoRegistration();
          }
        }

        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(successMessage)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
