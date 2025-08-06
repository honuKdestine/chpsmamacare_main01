import 'package:chpsmamacare_main01/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:chpsmamacare_main01/services/speech_service.dart';

class VoiceDangerSignButton extends StatefulWidget {
  final Function(List<String>) onDangerSignsDetected;

  const VoiceDangerSignButton({super.key, required this.onDangerSignsDetected});

  @override
  State<VoiceDangerSignButton> createState() => _VoiceDangerSignButtonState();
}

class _VoiceDangerSignButtonState extends State<VoiceDangerSignButton>
    with SingleTickerProviderStateMixin {
  final SpeechService _speechService = SpeechService();
  late AnimationController _animationController;
  String _transcription = '';
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _initializeSpeech();
  }

  Future<void> _initializeSpeech() async {
    final available = await _speechService.initialize();
    setState(() {
      _isInitialized = available;
    });

    if (!available) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Speech recognition not available on this device'),
        ),
      );
    }
  }

  void _startListening() {
    setState(() {
      _transcription = '';
    });

    _speechService.startListening(
      onResult: (text) {
        setState(() {
          _transcription = text;
        });
      },
      onListeningComplete: () {
        _processTranscription();
        setState(() {});
      },
      localeId: 'en_US', // Default to English
    );
  }

  void _stopListening() {
    _speechService.stopListening();
    _processTranscription();
  }

  void _processTranscription() {
    if (_transcription.isNotEmpty) {
      final detectedSigns = _speechService.detectDangerSigns(_transcription);
      if (detectedSigns.isNotEmpty) {
        widget.onDangerSignsDetected(detectedSigns);
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: _isInitialized
              ? (_speechService.isListening ? _stopListening : _startListening)
              : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: _speechService.isListening ? 80 : 60,
            height: _speechService.isListening ? 80 : 60,
            decoration: BoxDecoration(
              color: _speechService.isListening
                  ? AppColors.danger
                  : AppColors.primary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color:
                      (_speechService.isListening
                              ? AppColors.danger
                              : AppColors.primary)
                          .withOpacity(0.3),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Icon(
                  _speechService.isListening ? Icons.mic : Icons.mic_none,
                  color: Colors.white,
                  size: _speechService.isListening
                      ? 36 + (_animationController.value * 4)
                      : 30,
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _speechService.isListening
              ? 'Listening...'
              : 'Tap to report danger signs by voice',
          style: TextStyle(
            fontSize: 12,
            color: _speechService.isListening
                ? AppColors.danger
                : Colors.grey[600],
            fontWeight: _speechService.isListening
                ? FontWeight.bold
                : FontWeight.normal,
          ),
        ),
        if (_transcription.isNotEmpty && _speechService.isListening)
          Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _transcription,
              style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
            ),
          ),
      ],
    );
  }
}
