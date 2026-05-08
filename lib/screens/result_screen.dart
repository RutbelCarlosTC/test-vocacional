import 'package:flutter/material.dart';
import '../models/question_model.dart';
import '../models/evaluation_result.dart';
import '../services/evaluation_service.dart';
import 'attempt_detail_screen.dart';

class ResultScreen extends StatefulWidget {
  final EvaluationArea area;
  final String profileId;
  final AreaAttempt? latestAttempt;

  const ResultScreen({
    super.key,
    required this.area,
    required this.profileId,
    this.latestAttempt,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final EvaluationService _evalService = EvaluationService();
  AreaProgress? _progress;

  @override
  void initState() {
    super.initState();
    _load();
    
    // Si venimos de completar un test, abrir el detalle automáticamente
    if (widget.latestAttempt != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _goToDetail(widget.latestAttempt!);
      });
    }
  }

  void _load() {
    setState(() {
      _progress = _evalService.getProgress(widget.profileId, widget.area);
    });
  }

  void _goToDetail(AreaAttempt attempt) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AttemptDetailScreen(
          attempt: attempt,
          area: widget.area,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final attempts = _progress?.attempts ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text('Historial – ${widget.area.label}'),
      ),
      body: attempts.isEmpty
          ? const Center(child: Text('No hay intentos registrados.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: attempts.length,
              itemBuilder: (context, index) {
                // Mostrar el más reciente primero
                final attempt = attempts[attempts.length - 1 - index];
                final dateStr =
                    '${attempt.date.day}/${attempt.date.month}/${attempt.date.year}';
                
                final bool isInvalid = !attempt.isValid;

                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    title: Text(
                      'Intento ${attempt.attemptNumber}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      isInvalid ? 'Prueba invalidada · $dateStr' : dateStr,
                      style: TextStyle(
                        color: isInvalid ? Colors.red.shade700 : Colors.grey.shade600,
                      ),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => _goToDetail(attempt),
                  ),
                );
              },
            ),
    );
  }
}
