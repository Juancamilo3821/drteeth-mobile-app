import 'package:flutter/material.dart';
import 'package:front_end/Services/userService.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditInformationScreen extends StatefulWidget {
  final Map<String, dynamic> user;

  const EditInformationScreen({super.key, required this.user});

  @override
  State<EditInformationScreen> createState() => _EditInformationScreenState();
}

class _EditInformationScreenState extends State<EditInformationScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nombreController;
  late TextEditingController _correoController;
  late TextEditingController _telefonoController;
  late TextEditingController _tipoDocumentoController;
  late TextEditingController _numeroDocumentoController;

  final List<String> _avatars = [
    '',
    'Assets/1.png',
    'Assets/2.png',
    'Assets/3.png',
    'Assets/4.png',
    'Assets/5.png',
  ];
  int _selectedAvatar = 0;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(
        text: '${widget.user['nombre']} ${widget.user['apellidos']}');
    _correoController =
        TextEditingController(text: widget.user['correo'] ?? '');
    _telefonoController =
        TextEditingController(text: widget.user['telefono'] ?? '');
    _tipoDocumentoController =
        TextEditingController(text: widget.user['tipoDocumento'] ?? '');
    _numeroDocumentoController = TextEditingController(
        text: widget.user['numeroDocumento']?.toString() ?? '');
    _selectedAvatar = widget.user['avatar'] ?? 0;
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _correoController.dispose();
    _telefonoController.dispose();
    _tipoDocumentoController.dispose();
    _numeroDocumentoController.dispose();
    super.dispose();
  }

  void _guardarCambios() async {
    if (_formKey.currentState!.validate()) {
      final response = await UserService().updateUserAvatarWithToken(
        avatar: _selectedAvatar,
        telefono: _telefonoController.text.trim(),
        correo: _correoController.text.trim(),
      );

      if (response['success']) {
        if (response['token'] != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', response['token']);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cambios guardados correctamente')),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al guardar los cambios')),
        );
      }
    }
  }

  void _mostrarSelectorAvatar() {
    showModalBottomSheet(
      context: context,
      builder: (_) => Container(
        padding: const EdgeInsets.all(16),
        height: 140,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: _avatars.length,
          separatorBuilder: (_, __) => const SizedBox(width: 16),
          itemBuilder: (context, index) => GestureDetector(
            onTap: () {
              setState(() => _selectedAvatar = index);
              Navigator.pop(context);
            },
            child: CircleAvatar(
              radius: 40,
              backgroundColor: index == 0 ? Colors.teal : Colors.transparent,
              backgroundImage:
                  index == 0 ? null : AssetImage(_avatars[index]),
              child: index == 0
                  ? const Icon(Icons.person, color: Colors.white, size: 40)
                  : null,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEditableField({
    required String label,
    required TextEditingController controller,
    String? prefixText,
    bool enabled = true,
    bool requireValidation = true,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        enabled: enabled,
        decoration: InputDecoration(
          labelText: label,
          prefixText: prefixText,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: enabled ? Colors.white : const Color(0xFFF0F0F0),
        ),
        validator: (value) {
          if (!requireValidation) return null;
          return value == null || value.isEmpty
              ? 'Este campo es requerido'
              : null;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final avatarWidget = GestureDetector(
      onTap: _mostrarSelectorAvatar,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.transparent,
            child: ClipOval(
              child: _selectedAvatar == 0
                  ? Container(
                      color: Colors.teal,
                      width: 100,
                      height: 100,
                      child: const Icon(Icons.person, size: 50, color: Colors.white),
                    )
                  : Image.asset(
                      _avatars[_selectedAvatar],
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.teal,
                ),
                child: const Icon(Icons.edit, color: Colors.white, size: 16),
              ),
            ),
          ),
        ],
      ),
    );


    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        title: const Text('Editar perfil'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.teal,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              avatarWidget,
              const SizedBox(height: 24),
              _buildEditableField(
                label: 'Nombre completo',
                controller: _nombreController,
                enabled: false,
                requireValidation: false,
              ),
              _buildEditableField(
                label: 'Correo electrónico',
                controller: _correoController,
              ),
              _buildEditableField(
                label: 'Teléfono',
                controller: _telefonoController,
                prefixText: '+57 ',
              ),
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: _buildEditableField(
                      label: 'Tipo',
                      controller: _tipoDocumentoController,
                      enabled: false,
                      requireValidation: false,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: _buildEditableField(
                      label: 'Número',
                      controller: _numeroDocumentoController,
                      enabled: false,
                      requireValidation: false,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _guardarCambios,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Guardar cambios',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Cancelar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
