import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';

class QuranVerse {
  final String text;
  final String sura;

  const QuranVerse({required this.text, required this.sura});
}

class QuranCarouselWidget extends StatefulWidget {
  const QuranCarouselWidget({super.key});

  @override
  State<QuranCarouselWidget> createState() => _QuranCarouselWidgetState();
}

class _QuranCarouselWidgetState extends State<QuranCarouselWidget> {
  static const List<QuranVerse> verses = [
    QuranVerse(
      text:
          'And Allah increases those who were guided, in guidance, and the enduring good deeds are better to your Lord for reward and better for recourse.',
      sura: '[Al Quran Sura Muryam:76]',
    ),
    QuranVerse(
      text: 'And will drive the criminals to Hell in thirst',
      sura: '[Al Quran Sura Muryam:86]',
    ),
    QuranVerse(
      text: 'And He found you lost and guided [you],',
      sura: '[Al Quran Sura Duha:7]',
    ),
    QuranVerse(
      text:
          'So have they not traveled through the earth and have hearts by which to reason and ears by which to hear? For indeed, it is not eyes that are blinded, but blinded are the hearts which are within the breasts.',
      sura: '[Al Quran Sura Hajj:46]',
    ),
    QuranVerse(
      text:
          'The example of Paradise, which the righteous have been promised, is [that] beneath it rivers flow. Its fruit is lasting, and its shade. That is the consequence for the righteous, and the consequence for the disbelievers is the Fire.t',
      sura: '[Al Quran Sura Ar Rad:35]',
    ),
  ];

  int _currentIndex = 0;
  Timer? _timer;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 9), (timer) {
      if (!_isHovered && mounted) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % verses.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _prevSlide() {
    setState(() {
      _currentIndex = (_currentIndex - 1 + verses.length) % verses.length;
    });
  }

  void _nextSlide() {
    setState(() {
      _currentIndex = (_currentIndex + 1) % verses.length;
    });
  }

  Future<void> _openQuranLink() async {
    final uri = Uri.parse('https://quranmazid.com/');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final current = verses[_currentIndex];

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xBA161B31),
              Color(0xE00D1020),
            ],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: _isHovered
                ? AppTheme.accent.withOpacity(0.4)
                : AppTheme.primary.withOpacity(0.25),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.35),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
            if (_isHovered)
              BoxShadow(
                color: AppTheme.primary.withOpacity(0.12),
                blurRadius: 25,
                spreadRadius: 2,
              ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header: Badge + Counter + Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.accent.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppTheme.accent.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.auto_stories, color: AppTheme.accent, size: 13),
                      SizedBox(width: 5),
                      Text(
                        'DAILY QURAN INSPIRATION',
                        style: TextStyle(
                          color: AppTheme.accent,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Text(
                      '${_currentIndex + 1} / ${verses.length}',
                      style: const TextStyle(
                        color: AppTheme.textDim,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 10),
                    InkWell(
                      onTap: _prevSlide,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.05),
                          border: Border.all(color: Colors.white.withOpacity(0.1)),
                        ),
                        child: const Icon(Icons.chevron_left, size: 16, color: Colors.white70),
                      ),
                    ),
                    const SizedBox(width: 6),
                    InkWell(
                      onTap: _nextSlide,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.05),
                          border: Border.all(color: Colors.white.withOpacity(0.1)),
                        ),
                        child: const Icon(Icons.chevron_right, size: 16, color: Colors.white70),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Verse content with smooth animated transition
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
              child: Padding(
                key: ValueKey<int>(_currentIndex),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                child: Column(
                  children: [
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          height: 1.55,
                          fontFamily: 'Segoe UI',
                        ),
                        children: [
                          TextSpan(text: current.text),
                          const TextSpan(text: ' '),
                          TextSpan(
                            text: current.sura,
                            style: const TextStyle(
                              color: Color(0xFFC4B5FD),
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: const TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 12,
                          fontFamily: 'Segoe UI',
                        ),
                        children: [
                          const TextSpan(text: '(to read the quran go buy one or for free go here '),
                          TextSpan(
                            text: 'https://quranmazid.com/',
                            style: const TextStyle(
                              color: AppTheme.accent,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()..onTap = _openQuranLink,
                          ),
                          const TextSpan(text: ')'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            // Dots indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(verses.length, (idx) {
                final isActive = idx == _currentIndex;
                return GestureDetector(
                  onTap: () => setState(() => _currentIndex = idx),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: isActive ? 18 : 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: isActive ? AppTheme.accent : Colors.white24,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

