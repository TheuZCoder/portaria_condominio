// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MoradoresView extends StatefulWidget {
  const MoradoresView({super.key});

  @override
  _MoradoresViewState createState() => _MoradoresViewState();
}

class _MoradoresViewState extends State<MoradoresView> {
  int? expandedIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Moradores')),
      body: ListView.builder(
        itemCount: 10, // Simulação
        itemBuilder: (context, index) {
          return AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: Card(
              margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.person),
                    title: Text('Morador $index'),
                    subtitle: const Text('Detalhes do morador'),
                    onTap: () {
                      setState(() {
                        expandedIndex = (expandedIndex == index) ? null : index;
                      });
                    },
                  ),
                  if (expandedIndex == index) _expandedButtons(index),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _expandedButtons(int index) {
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
              onTap: () => _callProvider('55123456789'),
            ),
            _actionButton(
              icon: Icons.message,
              label: 'Mensagem',
              onTap: () => _sendMessage('55123456789'),
            ),
            _actionButton(
              icon: FontAwesomeIcons.whatsapp,
              label: 'WhatsApp',
              onTap: () => openWhatsapp(context: context, text: "Mensagem de teste", number: "+5511987654321"),
            ),
            _actionButton(
              icon: Icons.map,
              label: 'Mapa',
              onTap: () => _showAddress(index),
            ),
            _actionButton(
              icon: Icons.edit,
              label: 'Editar',
              onTap: () => _editResident(index),
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

  void _callProvider(String phone) async {
    final Uri phoneUrl = Uri(scheme: 'tel', path: phone);
    try {
      final bool launched = await launchUrl(phoneUrl);
      if (!launched) throw 'Não foi possível realizar a ligação';
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  void _sendMessage(String phoneNumber) async {
    final Uri smsUri = Uri(scheme: 'sms', path: phoneNumber);
    if (await canLaunchUrl(smsUri)) {
      await launchUrl(smsUri);
    } else {
      debugPrint('Não foi possível enviar a mensagem para $phoneNumber');
    }
  }

void openWhatsapp(
      {required BuildContext context,
      required String text,
      required String number}) async {
    var whatsapp = number; //+92xx enter like this
    var whatsappURlAndroid =
        "whatsapp://send?phone=$whatsapp&text=$text";
    var whatsappURLIos = "https://wa.me/$whatsapp?text=${Uri.tryParse(text)}";
    if (Platform.isIOS) {
      // for iOS phone only
      if (await canLaunchUrl(Uri.parse(whatsappURLIos))) {
        await launchUrl(Uri.parse(
          whatsappURLIos,
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Whatsapp not installed")));
      }
    } else {
      // android , web
      if (await canLaunchUrl(Uri.parse(whatsappURlAndroid))) {
        await launchUrl(Uri.parse(whatsappURlAndroid));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Whatsapp not installed")));
      }
    }
  }

  void _showAddress(int index) {
    // Simulação de exibição de endereço
    debugPrint('Exibindo endereço do morador $index');
  }

  void _editResident(int index) {
    // Simulação de edição
    debugPrint('Editando informações do morador $index');
  }
}
