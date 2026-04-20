import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../services/profile_manager.dart';
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

  String _gender = 'Masculino';
  DateTime? _birthDate;
  AcademicStatus _academicStatus = AcademicStatus.egresado;
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
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
        const SnackBar(content: Text('Por favor selecciona tu fecha de nacimiento.')),
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
      academicStatus: _academicStatus,
    );

    await _manager.saveProfile(profile);
    await _manager.setActiveProfile(profile.id);

    if (!mounted) return;
    setState(() => _saving = false);

    // Si llegamos desde ProfileSelection, reemplazamos toda la pila
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (route) => false,
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
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre completo',
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Ingresa tu nombre' : null,
              ),
              const SizedBox(height: 14),

              // Correo
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Correo electrónico',
                  prefixIcon: Icon(Icons.email_outlined),
                  border: OutlineInputBorder(),
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
              const Text('Género', style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 6),
              _GenderSelector(
                selected: _gender,
                onChanged: (val) => setState(() => _gender = val),
              ),
              const SizedBox(height: 14),

              // Fecha de nacimiento
              const Text('Fecha de nacimiento',
                  style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 6),
              InkWell(
                onTap: _pickDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4),
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
                          color: _birthDate == null ? Colors.grey : Colors.black,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                'Nivel académico',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              // Academic status
              ...AcademicStatus.values.map((status) => RadioListTile<AcademicStatus>(
                    title: Text(status.label),
                    value: status,
                    groupValue: _academicStatus,
                    onChanged: (val) =>
                        setState(() => _academicStatus = val!),
                    contentPadding: EdgeInsets.zero,
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

  @override
  Widget build(BuildContext context) {
    const options = ['Masculino', 'Femenino', 'Otro'];
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