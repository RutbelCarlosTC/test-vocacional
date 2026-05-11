import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../services/profile_manager.dart';
import 'create_profile_screen.dart';
import 'home_screen.dart';

class ProfileSelectionScreen extends StatefulWidget {
  const ProfileSelectionScreen({super.key});

  @override
  State<ProfileSelectionScreen> createState() => _ProfileSelectionScreenState();
}

class _ProfileSelectionScreenState extends State<ProfileSelectionScreen> {
  final ProfileManager _manager = ProfileManager();
  List<UserProfile> _profiles = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProfiles();
  }

  Future<void> _loadProfiles() async {
    final profiles = await _manager.getProfiles();
    setState(() {
      _profiles = profiles;
      _loading = false;
    });
  }

  Future<void> _selectProfile(UserProfile profile) async {
    await _manager.setActiveProfile(profile.id);
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  Future<void> _goToCreateProfile() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CreateProfileScreen()),
    );
    _loadProfiles(); // recargar tras crear
  }

  Future<void> _confirmDelete(UserProfile profile) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar perfil'),
        content: Text('¿Eliminar el perfil de ${profile.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await _manager.deleteProfile(profile.id);
      _loadProfiles();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EnrutaT'),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Center(
                  child: Image.asset(
                    'assets/ENRUTAT_LOGO.png',
                    height: 250,
                  ),
                ),
                const SizedBox(height: 24),
                const Center(
                  child: Text(
                    '¿Quién está usando la app?',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),
                const Center(
                  child: Text(
                    'Selecciona tu perfil o crea uno nuevo.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _goToCreateProfile,
                    icon: const Icon(Icons.add),
                    label: const Text('Crear nuevo perfil'),
                  ),
                ),
                const SizedBox(height: 20),
                if (_profiles.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: Text(
                        'No hay perfiles aún.\nCrea uno para comenzar.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  )
                else
                  ..._profiles.map(
                    (profile) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _ProfileCard(
                        profile: profile,
                        onTap: () => _selectProfile(profile),
                        onDelete: () => _confirmDelete(profile),
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
                Center(
                  child: Image.asset(
                    'assets/LOGO CEPRUNSA-03.png',
                    height: 50,
                  ),
                ),
              ],
            ),
    );
  }
}

// ──────────────────────────────────────────────
// Widget interno: tarjeta de perfil
// ──────────────────────────────────────────────
class _ProfileCard extends StatelessWidget {
  final UserProfile profile;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _ProfileCard({
    required this.profile,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          child: Text(profile.initials),
        ),
        title: Text(profile.name,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
          '${profile.academicStatus.label} · ${profile.age} años',
          style: const TextStyle(fontSize: 13),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: onDelete,
        ),
        onTap: onTap,
      ),
    );
  }
}