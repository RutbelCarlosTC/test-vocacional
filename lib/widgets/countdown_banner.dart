import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_colors.dart';

class CountdownBanner extends StatefulWidget {
  const CountdownBanner({super.key});

  @override
  State<CountdownBanner> createState() => _CountdownBannerState();
}

class _CountdownBannerState extends State<CountdownBanner> {
  Timer? _timer;
  Duration _timeLeft = Duration.zero;
  final DateTime _targetDate = DateTime(2026, 7, 27);
  bool _isFinished = false;

  @override
  void initState() {
    super.initState();
    _calculateTimeLeft();
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _calculateTimeLeft();
    });
  }

  void _calculateTimeLeft() {
    final now = DateTime.now();
    final difference = _targetDate.difference(now);
    
    if (mounted) {
      setState(() {
        _timeLeft = difference;
        if (_timeLeft.isNegative) {
          _isFinished = true;
          _timer?.cancel();
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url)) {
      debugPrint('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool showFinished = _isFinished;
    final String message = showFinished
        ? '¡Inscripciones Ciclo Quintos abiertas!'
        : 'CEPRUNSA Quintos: Faltan ${_timeLeft.inDays} días para inscripciones';
    
    final String url = showFinished
        ? 'https://sisadmision.unsa.edu.pe/pregrado/'
        : 'https://admision.unsa.edu.pe/cronograma-de-admision-2027/';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: AppColors.secondaryRed,
      child: Row(
        children: [
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () => _launchURL(url),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.secondaryRed,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
              minimumSize: const Size(0, 30),
              textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('VER MÁS'),
          ),
        ],
      ),
    );
  }
}
