import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/user_profile.dart';
import '../services/profile_manager.dart';
import '../theme/app_colors.dart';
import 'home_screen.dart';

class CreateProfileScreen extends StatefulWidget {
  const CreateProfileScreen({super.key});

  @override
  State<CreateProfileScreen> createState() => _CreateProfileScreenState();
}

class _CreateProfileScreenState extends State<CreateProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final ProfileManager _manager = ProfileManager();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final List<TextEditingController> _careerControllers = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];

  String _gender = 'Masculino';
  String _schoolType = 'Nacional'; // Nacional, Parroquial, Particular
  DateTime? _birthDate;
  AcademicStatus? _academicStatus;
  bool _saving = false;

  List<String> _allCareers = [];

  @override
  void initState() {
    super.initState();
    _loadCareers();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    for (var controller in _careerControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadCareers() async {
    try {
      final String response =
          await rootBundle.loadString('assets/data/carreras.json');
      final data = await json.decode(response) as List;
      setState(() {
        _allCareers = data.map((e) => e['carrera'] as String).toList();
      });
    } catch (e) {
      debugPrint('Error cargando carreras: $e');
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 16),
      firstDate: DateTime(now.year - 60),
      lastDate: DateTime(now.year - 10),
      helpText: 'Selecciona tu fecha de nacimiento',
    );
    if (picked != null) {
      setState(() => _birthDate = picked);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_birthDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Por favor selecciona tu fecha de nacimiento.')),
      );
      return;
    }

    if (_academicStatus == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Por favor selecciona tu estado académico actual.')),
      );
      return;
    }

    setState(() => _saving = true);

    final profile = UserProfile(
      id: _manager.generateId(),
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      gender: _gender,
      birthDate: _birthDate!,
      academicStatus: _academicStatus!,
      schoolType: _schoolType,
      possibleCareers: _careerControllers
          .map((c) => c.text.trim())
          .where((t) => t.isNotEmpty)
          .toList(),
    );

    await _manager.saveProfile(profile);
    await _manager.setActiveProfile(profile.id);

    if (!mounted) return;
    setState(() => _saving = false);

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (route) => false,
    );
  }

  Widget _buildLabel(String label, {bool required = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: RichText(
        text: TextSpan(
          text: label,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.black,
            fontSize: 14,
          ),
          children: [
            if (required)
              const TextSpan(
                text: ' *',
                style: TextStyle(color: Colors.red),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear perfil'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Datos personales',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Nombre
              _buildLabel('Nombre completo'),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  hintText: 'Ej. Juan Pérez',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Ingresa tu nombre'
                    : null,
              ),
              const SizedBox(height: 14),

              // Correo
              _buildLabel('Correo electrónico'),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  hintText: 'ejemplo@correo.com',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Ingresa tu correo';
                  if (!v.contains('@')) return 'Correo inválido';
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Género
              _buildLabel('Género'),
              _GenderSelector(
                selected: _gender,
                onChanged: (val) => setState(() => _gender = val),
              ),
              const SizedBox(height: 14),

              // Fecha de nacimiento
              _buildLabel('Fecha de nacimiento'),
              InkWell(
                onTap: _pickDate,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.accentGray),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined,
                          color: Colors.grey),
                      const SizedBox(width: 12),
                      Text(
                        _birthDate == null
                            ? 'Seleccionar fecha'
                            : '${_birthDate!.day.toString().padLeft(2, '0')}/'
                                '${_birthDate!.month.toString().padLeft(2, '0')}/'
                                '${_birthDate!.year}',
                        style: TextStyle(
                          color:
                              _birthDate == null ? Colors.grey : Colors.black,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                'Educación de Procedencia',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              // Tipo de colegio
              _buildLabel('Tipo de colegio de procedencia'),
              DropdownButtonFormField<String>(
                value: _schoolType,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 12),
                ),
                items: ['Nacional', 'Parroquial', 'Particular']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (val) => setState(() => _schoolType = val!),
              ),
              const SizedBox(height: 14),

              const Text(
                'Posibles Carreras',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Text('Selecciona hasta 3 carreras de tu interés',
                  style: TextStyle(fontSize: 13, color: Colors.grey)),
              const SizedBox(height: 12),

              // Carreras autocompletables
              ...List.generate(3, (index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Autocomplete<String>(
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      if (textEditingValue.text == '') {
                        return const Iterable<String>.empty();
                      }
                      return _allCareers.where((String option) {
                        return option
                            .toLowerCase()
                            .contains(textEditingValue.text.toLowerCase());
                      });
                    },
                    onSelected: (String selection) {
                      _careerControllers[index].text = selection;
                    },
                    fieldViewBuilder:
                        (context, controller, focusNode, onFieldSubmitted) {
                      // Sincronizar con nuestro controlador
                      controller.text = _careerControllers[index].text;
                      controller.addListener(() {
                         _careerControllers[index].text = controller.text;
                      });
                      
                      return TextFormField(
                        controller: controller,
                        focusNode: focusNode,
                        decoration: InputDecoration(
                          labelText: 'Opción ${index + 1}${index == 0 ? " *" : ""}',
                          labelStyle: index == 0 ? const TextStyle(color: Colors.black) : null,
                          prefixIcon: const Icon(Icons.school_outlined),
                        ),
                        validator: (v) {
                          if (index == 0 && (v == null || v.isEmpty)) {
                            return 'Al menos una carrera es requerida';
                          }
                          return null;
                        },
                      );
                    },
                  ),
                );
              }),

              const SizedBox(height: 20),

              // Academic status
              _buildLabel('Estado académico actual'),
              ...AcademicStatus.values
                  .map((status) => RadioListTile<AcademicStatus>(
                        title: Text(status.label),
                        value: status,
                        groupValue: _academicStatus,
                        onChanged: (val) =>
                            setState(() => _academicStatus = val!),
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                      )),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Guardar y continuar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Widget interno: selector de género
// ──────────────────────────────────────────────
class _GenderSelector extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const _GenderSelector({
    required this.selected,
    required this.onChanged,
  });

  Widget _buildLabel(String label, {bool required = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: RichText(
        text: TextSpan(
          text: label,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.black,
            fontSize: 14,
          ),
          children: [
            if (required)
              const TextSpan(
                text: ' *',
                style: TextStyle(color: Colors.red),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const options = ['Masculino', 'Femenino'];
    return Row(
      children: options
          .map(
            (g) => Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: OutlinedButton(
                  onPressed: () => onChanged(g),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: selected == g
                        ? Theme.of(context).colorScheme.primary
                        : null,
                    foregroundColor: selected == g ? Colors.white : null,
                  ),
                  child: Text(g, style: const TextStyle(fontSize: 13)),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
