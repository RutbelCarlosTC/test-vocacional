import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/app_drawer.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Acerca de..'),
      ),
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '¿Qué es el CEPRUNSA?',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            const SizedBox(height: 10),
            const Text(
              'El CEPRUNSA es el Centro Preuniversitario de la Universidad Nacional de San Agustín de Arequipa, encargado de brindar una preparación académica de calidad para los postulantes a las diversas carreras profesionales que ofrece la universidad.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 15),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                'assets/comision/Ceprunsa-foto.JPG',
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 30),
            Text(
              'Comisión:',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            const SizedBox(height: 20),
            _buildDoctorCard(
              context,
              'Dra. Maria Elena Rojas Zegarra',
              'Directora CEPRUNSA',
              'assets/comision/Maria Elena Rojas Zegarra.jpg',
              'https://pe.linkedin.com/in/maria-elena-rojas-zegarra-685312243',
              //'https://dina.concytec.gob.pe/appDirectorioCTI/VerDatosInvestigador.do?id_investigador=20316',
            ),
            const SizedBox(height: 10),
            _buildDoctorCard(
              context,
              'Dr. Jose Miguel Rojas Hualpa',
              'Coordinador Administrativo',
              'assets/comision/Jose Miguel Rojas Hualpa.jpg',
              'https://www.linkedin.com/search/results/all/?keywords=Jose%20Miguel%20Rojas%20Hualpa',
              //'https://dina.concytec.gob.pe/appDirectorioCTI/VerDatosInvestigador.do?id_investigador=150092',

            ),
            const SizedBox(height: 10),
            _buildDoctorCard(
              context,
              'Mg. Arnaldo Humberto Valdivia Loaiza',
              'Coordinador Académico',
              'assets/comision/Arnaldo Humbero Valdivia Loaiza.jpg',
              'https://www.linkedin.com/search/results/all/?keywords=Arnaldo%20Humberto%20Valdivia%20Loaiza',
              //'https://dina.concytec.gob.pe/appDirectorioCTI/VerDatosInvestigador.do?id_investigador=63640',
            ),
            const SizedBox(height: 40),
            Center(
              child: Image.asset(
                'assets/LOGO CEPRUNSA-03.png',
                height: 60,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorCard(BuildContext context, String name, String role,
      String imagePath, String linkedinUrl) {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: AssetImage(imagePath),
        ),
        title: Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          role,
          style: TextStyle(
            color: Theme.of(context).colorScheme.secondary,
            fontSize: 13,
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.link, color: Colors.blue),
          onPressed: () => _launchUrl(linkedinUrl),
          tooltip: 'Ver LinkedIn',
        ),
        onTap: () => _launchUrl(linkedinUrl),
      ),
    );
  }
}
