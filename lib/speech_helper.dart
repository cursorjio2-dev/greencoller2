import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:greencollar/main.dart'; // for LanguageProvider
import 'package:greencollar/constants.dart' as Constants;

class SpeechHelper {
  static final FlutterTts _flutterTts = FlutterTts();
  static String? _currentlySpeakingText;
  static VoidCallback? _onSpeakingStoppedCallback;

  static FlutterTts get tts => _flutterTts;

  static Future<void> speak(String text, String language, {required VoidCallback onStart, required VoidCallback onComplete, required VoidCallback onError}) async {
    try {
      if (_currentlySpeakingText == text) {
        await stop();
        return;
      }
      
      // Stop any existing speaking first
      await stop();

      _currentlySpeakingText = text;
      _onSpeakingStoppedCallback = onComplete;

      String localeId = language == 'en' ? 'en-US' : 'hi-IN';
      await _flutterTts.setLanguage(localeId);
      await _flutterTts.setPitch(1.0);
      await _flutterTts.setSpeechRate(0.5);

      _flutterTts.setStartHandler(() {
        onStart();
      });

      _flutterTts.setCompletionHandler(() {
        _currentlySpeakingText = null;
        if (_onSpeakingStoppedCallback != null) {
          final cb = _onSpeakingStoppedCallback;
          _onSpeakingStoppedCallback = null;
          cb!();
        }
      });

      _flutterTts.setErrorHandler((msg) {
        _currentlySpeakingText = null;
        if (_onSpeakingStoppedCallback != null) {
          final cb = _onSpeakingStoppedCallback;
          _onSpeakingStoppedCallback = null;
          cb!();
        }
      });

      await _flutterTts.speak(text);
    } catch (e) {
      debugPrint("TTS speak error: $e");
      onError();
    }
  }

  static Future<void> stop() async {
    try {
      await _flutterTts.stop();
      if (_onSpeakingStoppedCallback != null) {
        final cb = _onSpeakingStoppedCallback;
        _onSpeakingStoppedCallback = null;
        cb!();
      }
      _currentlySpeakingText = null;
    } catch (e) {
      debugPrint("TTS stop error: $e");
    }
  }

  static bool isSpeaking(String text) {
    return _currentlySpeakingText == text;
  }
}

class MicIconButton extends StatefulWidget {
  final TextEditingController controller;
  final String? tooltip;
  final double size;

  const MicIconButton({
    Key? key,
    required this.controller,
    this.tooltip,
    this.size = 24.0,
  }) : super(key: key);

  @override
  State<MicIconButton> createState() => _MicIconButtonState();
}

class _MicIconButtonState extends State<MicIconButton> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _initialText = '';

  @override
  void dispose() {
    if (_isListening) {
      _speech.stop();
    }
    super.dispose();
  }

  void _toggleListening() async {
    if (_isListening) {
      _stopListening();
    } else {
      _startListening();
    }
  }

  void _startListening() async {
    try {
      final language = Provider.of<LanguageProvider>(context, listen: false).selectedLanguage;
      String localeId = language == 'en' ? 'en_US' : 'hi_IN';

      bool available = await _speech.initialize(
        onError: (val) {
          debugPrint('Speech init error: $val');
          _stopListening();
        },
        onStatus: (val) {
          if (val == 'done' || val == 'notListening') {
            _stopListening();
          }
        },
      );

      if (available) {
        setState(() {
          _isListening = true;
          _initialText = widget.controller.text;
        });

        _speech.listen(
          localeId: localeId,
          onResult: (result) {
            setState(() {
              String recognized = result.recognizedWords;
              if (_initialText.isEmpty) {
                widget.controller.text = recognized;
              } else {
                widget.controller.text = "$_initialText $recognized";
              }
              // Position cursor at the end of text
              widget.controller.selection = TextSelection.fromPosition(
                TextPosition(offset: widget.controller.text.length),
              );
            });
          },
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Speech recognition not available')),
        );
      }
    } catch (e) {
      debugPrint("STT start listening error: $e");
      _stopListening();
    }
  }

  void _stopListening() {
    if (mounted) {
      setState(() {
        _isListening = false;
      });
    }
    _speech.stop();
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        _isListening ? Icons.mic : Icons.mic_none,
        color: _isListening ? Colors.red : Constants.AppColors.inkSoft,
        size: widget.size,
      ),
      tooltip: widget.tooltip ?? (Provider.of<LanguageProvider>(context).selectedLanguage == 'en' ? 'Speak' : 'बोलें'),
      onPressed: _toggleListening,
    );
  }
}

class SpeakerIconButton extends StatefulWidget {
  final String text;
  final double size;

  const SpeakerIconButton({
    Key? key,
    required this.text,
    this.size = 24.0,
  }) : super(key: key);

  @override
  State<SpeakerIconButton> createState() => _SpeakerIconButtonState();
}

class _SpeakerIconButtonState extends State<SpeakerIconButton> {
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _isPlaying = SpeechHelper.isSpeaking(widget.text);
  }

  @override
  void didUpdateWidget(covariant SpeakerIconButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _isPlaying = SpeechHelper.isSpeaking(widget.text);
    }
  }

  void _toggleSpeak() async {
    if (_isPlaying) {
      await SpeechHelper.stop();
    } else {
      final language = Provider.of<LanguageProvider>(context, listen: false).selectedLanguage;
      await SpeechHelper.speak(
        widget.text,
        language,
        onStart: () {
          if (mounted) {
            setState(() {
              _isPlaying = true;
            });
          }
        },
        onComplete: () {
          if (mounted) {
            setState(() {
              _isPlaying = false;
            });
          }
        },
        onError: () {
          if (mounted) {
            setState(() {
              _isPlaying = false;
            });
          }
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      decoration: BoxDecoration(
        color: _isPlaying
            ? Constants.AppColors.button.withOpacity(0.15)
            : Constants.AppColors.buttonBg,
        shape: BoxShape.circle,
        border: Border.all(
          color: _isPlaying
              ? Constants.AppColors.button
              : Constants.AppColors.buttonBorder,
          width: 1.0,
        ),
        boxShadow: _isPlaying
            ? [
                BoxShadow(
                  color: Constants.AppColors.button.withOpacity(0.3),
                  blurRadius: 6,
                  spreadRadius: 1,
                )
              ]
            : null,
      ),
      child: IconButton(
        icon: Icon(
          _isPlaying ? Icons.volume_up : Icons.volume_down_outlined,
          color: _isPlaying ? Constants.AppColors.button : Constants.AppColors.button,
          size: widget.size,
        ),
        constraints: const BoxConstraints(),
        padding: EdgeInsets.all(widget.size * 0.3),
        tooltip: Provider.of<LanguageProvider>(context).selectedLanguage == 'en' ? 'Listen' : 'सुनें',
        onPressed: widget.text.isEmpty ? null : _toggleSpeak,
      ),
    );
  }
}


