// import 'package:flutter/material.dart';
// import 'package:portaria_condominio/controllers/morador_controller.dart';
// import '../../models/morador_model.dart';
// import '../../localizations/app_localizations.dart';

// class CadastroMoradoresView extends StatefulWidget {
//   final Morador? morador;
  
//   const CadastroMoradoresView({super.key, this.morador});

//   @override
//   State<CadastroMoradoresView> createState() => _CadastroMoradoresViewState();
// }

// class _CadastroMoradoresViewState extends State<CadastroMoradoresView> {
//   final _formKey = GlobalKey<FormState>();
//   final _controller = MoradorController();

//   final TextEditingController _nomeController = TextEditingController();
//   final TextEditingController _cpfController = TextEditingController();
//   final TextEditingController _telefoneController = TextEditingController();
//   final TextEditingController _enderecoController = TextEditingController();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _senhaController = TextEditingController();
//   final TextEditingController _numeroCasaController = TextEditingController();

//   bool _isLoading = false;

//   @override
//   void initState() {
//     super.initState();
//     if (widget.morador != null) {
//       _nomeController.text = widget.morador!.nome;
//       _cpfController.text = widget.morador!.cpf;
//       _telefoneController.text = widget.morador!.telefone;
//       _enderecoController.text = widget.morador!.endereco;
//       _emailController.text = widget.morador!.email;
//       _numeroCasaController.text = widget.morador!.numeroCasa;
//     }
//   }

//   @override
//   void dispose() {
//     _nomeController.dispose();
//     _cpfController.dispose();
//     _telefoneController.dispose();
//     _enderecoController.dispose();
//     _emailController.dispose();
//     _senhaController.dispose();
//     _numeroCasaController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final localizations = AppLocalizations.of(context);
//     final isEditing = widget.morador != null;

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(isEditing 
//           ? localizations.translate('edit_resident')
//           : localizations.translate('add_resident')),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: ListView(
//             children: [
//               _buildTextField(
//                 controller: _nomeController,
//                 label: localizations.translate('name'),
//                 prefixIcon: const Icon(Icons.person),
//                 validator: (value) => value!.isEmpty 
//                   ? localizations.translate('name_required') 
//                   : null,
//               ),
//               _buildTextField(
//                 controller: _cpfController,
//                 label: localizations.translate('cpf'),
//                 prefixIcon: const Icon(Icons.badge),
//                 validator: (value) => value!.isEmpty 
//                   ? localizations.translate('cpf_required') 
//                   : null,
//               ),
//               _buildTextField(
//                 controller: _telefoneController,
//                 label: localizations.translate('phone'),
//                 prefixIcon: const Icon(Icons.phone),
//                 validator: (value) => value!.isEmpty 
//                   ? localizations.translate('phone_required') 
//                   : null,
//               ),
//               _buildTextField(
//                 controller: _numeroCasaController,
//                 label: localizations.translate('house_number'),
//                 prefixIcon: const Icon(Icons.home),
//                 validator: (value) => value!.isEmpty 
//                   ? localizations.translate('house_number_required') 
//                   : null,
//               ),
//               _buildTextField(
//                 controller: _enderecoController,
//                 label: localizations.translate('address'),
//                 prefixIcon: const Icon(Icons.location_on),
//                 validator: (value) => value!.isEmpty 
//                   ? localizations.translate('address_required') 
//                   : null,
//               ),
//               _buildTextField(
//                 controller: _emailController,
//                 label: localizations.translate('email'),
//                 prefixIcon: const Icon(Icons.email),
//                 validator: (value) => value!.isEmpty 
//                   ? localizations.translate('email_required') 
//                   : null,
//               ),
//               if (!isEditing)
//                 _buildTextField(
//                   controller: _senhaController,
//                   label: localizations.translate('password'),
//                   prefixIcon: const Icon(Icons.lock),
//                   obscureText: true,
//                   validator: (value) => value!.isEmpty 
//                     ? localizations.translate('password_required') 
//                     : null,
//                 ),
//               const SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: _isLoading ? null : _submitForm,
//                 child: _isLoading
//                     ? const SizedBox(
//                         height: 20,
//                         width: 20,
//                         child: CircularProgressIndicator(strokeWidth: 2),
//                       )
//                     : Text(isEditing 
//                         ? localizations.translate('save_changes')
//                         : localizations.translate('register')),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildTextField({
//     required TextEditingController controller,
//     required String label,
//     required String? Function(String?) validator,
//     Widget? prefixIcon,
//     bool obscureText = false,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 16.0),
//       child: TextFormField(
//         controller: controller,
//         decoration: InputDecoration(
//           labelText: label,
//           border: const OutlineInputBorder(),
//           prefixIcon: prefixIcon,
//         ),
//         obscureText: obscureText,
//         validator: validator,
//       ),
//     );
//   }

//   Future<void> _submitForm() async {
//     if (!_formKey.currentState!.validate()) return;

//     setState(() => _isLoading = true);

//     try {
//       final morador = Morador(
//         id: widget.morador?.id ?? '',
//         nome: _nomeController.text,
//         cpf: _cpfController.text,
//         telefone: _telefoneController.text,
//         endereco: _enderecoController.text,
//         email: _emailController.text,
//         senha: widget.morador?.senha ?? _senhaController.text,
//         numeroCasa: _numeroCasaController.text,
//         role: widget.morador?.role ?? 'morador',
//       );

//       if (widget.morador != null) {
//         await _controller.atualizarMorador(morador);
//       } else {
//         await _controller.cadastrarMorador(morador);
//       }

//       if (mounted) {
//         Navigator.pop(context, true);
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(
//               widget.morador != null
//                   ? AppLocalizations.of(context).translate('resident_updated')
//                   : AppLocalizations.of(context).translate('resident_registered'),
//             ),
//           ),
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('${AppLocalizations.of(context).translate('error')}: $e'),
//             backgroundColor: Theme.of(context).colorScheme.error,
//           ),
//         );
//       }
//     } finally {
//       if (mounted) {
//         setState(() => _isLoading = false);
//       }
//     }
//   }
// }
