import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Políticas de privacidad'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.teal,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF7F9FC),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Última actualización: 23 de junio, 2025',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            _sectionTitle('1. Información que recopilamos'),
            _sectionBody(
              'Recopilamos información que nos proporcionas directamente, como cuando creas una cuenta, actualizas tu perfil o te comunicas con nosotros.\n\n'
              'Esta información puede incluir tu nombre, dirección de correo electrónico, número de teléfono, y cualquier otra información que elijas proporcionar.',
            ),
            const SizedBox(height: 16),
            _sectionTitle('2. Cómo usamos tu información'),
            _sectionBody(
              'Utilizamos la información que recopilamos para:',
            ),
            _bulletList([
              'Proporcionar, mantener y mejorar nuestros servicios',
              'Enviarte comunicaciones técnicas y actualizaciones',
              'Responder a tus comentarios y preguntas',
            ]),
            const SizedBox(height: 16),
            _sectionTitle('3. Compartir información'),
            _sectionBody(
              'No vendemos, intercambiamos ni transferimos tu información personal a terceros sin tu consentimiento, excepto en las circunstancias descritas en esta política.',
            ),
            const SizedBox(height: 16),
            _sectionTitle('4. Seguridad de datos'),
            _sectionBody(
              'Implementamos medidas de seguridad técnicas y organizativas apropiadas para proteger tu información personal contra el acceso no autorizado, alteración, divulgación o destrucción.',
            ),
            const SizedBox(height: 16),
            _sectionTitle('5. Tus derechos'),
            _sectionBody(
              'Tienes derecho a:',
            ),
            _bulletList([
              'Acceder a tu información personal',
              'Corregir información inexacta',
              'Solicitar la eliminación de tu información',
              'Oponerte al procesamiento de tu información',
            ]),
            const SizedBox(height: 16),
            _sectionTitle('6. Contacto'),
            _sectionBody(
              'Si tienes preguntas sobre esta política de privacidad, puedes contactarnos en:',
            ),
            GestureDetector(
              onTap: () async {
                final Uri emailUri = Uri(
                  scheme: 'mailto',
                  path: 'drteeth.soporte@gmail',
                  query: Uri.encodeFull('subject=Consulta sobre privacidad'),
                );
                if (await canLaunchUrl(emailUri)) {
                  await launchUrl(emailUri);
                }
              },
              child: const Text(
                'drteeth.soporte@gmail',
                style: TextStyle(color: Colors.teal, decoration: TextDecoration.underline),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
    );
  }

  Widget _sectionBody(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Text(
        text,
        style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.5),
      ),
    );
  }

  Widget _bulletList(List<String> items) {
    return Padding(
      padding: const EdgeInsets.only(top: 6, left: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: items
            .map((e) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• ', style: TextStyle(fontSize: 14)),
                      Expanded(child: Text(e, style: const TextStyle(fontSize: 14))),
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }
}
