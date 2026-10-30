import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class TimerWidget extends StatefulWidget {
  const TimerWidget({super.key});

  @override
  State<TimerWidget> createState() => _TimerWidgetState();
}

class _TimerWidgetState extends State<TimerWidget> {
  int _minutes = 25;
  late int _remainingSeconds;
  bool _isRunning = false;
  Timer? _timer;
  final TextEditingController _minController = TextEditingController(text: '25');

  @override
  void initState() {
    super.initState();
    _remainingSeconds = _minutes * 60;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _minController.dispose();
    super.dispose();
  }

  void _toggleTimer() {
    if (_isRunning) {
      _timer?.cancel();
      setState(() => _isRunning = false);
    } else {
      if (_remainingSeconds <= 0) {
        _remainingSeconds = _minutes * 60;
      }
      setState(() => _isRunning = true);
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_remainingSeconds > 0) {
          setState(() => _remainingSeconds--);
        } else {
          _timer?.cancel();
          setState(() => _isRunning = false);
          _showDoneDialog();
        }
      });
    }
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _remainingSeconds = _minutes * 60;
    });
  }

  void _onMinutesChanged(String value) {
    final parsed = int.tryParse(value);
    if (parsed != null && parsed > 0 && parsed <= 180) {
      setState(() {
        _minutes = parsed;
        if (!_isRunning) {
          _remainingSeconds = _minutes * 60;
        }
      });
    }
  }

  void _showDoneDialog() {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.celebration, color: AppTheme.accent),
            SizedBox(width: 8),
            Text('Session Completed!'),
          ],
        ),
        content: const Text(
          'Great focus! Take a moment to relax before your next session.',
          style: TextStyle(color: AppTheme.textMuted),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Awesome'),
          ),
        ],
      ),
    );
  }

  String _formatTime(int totalSeconds) {
    final m = totalSeconds ~/ 60;
    final s = totalSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final totalInitial = _minutes * 60;
    final progress = totalInitial > 0 ? (_remainingSeconds / totalInitial).clamp(0.0, 1.0) : 0.0;

    return Center(
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        child: Column(
          children: [
            // Circular timer ring
            Stack(
              alignment: Alignment.center,
              children: [
                // Outer glow shadow
                Container(
                  width: 190,
                  height: 190,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primary.withOpacity(_isRunning ? 0.3 : 0.1),
                        blurRadius: 40,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
                // Progress circle indicator
                SizedBox(
                  width: 190,
                  height: 190,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 4,
                    backgroundColor: Colors.white.withOpacity(0.08),
                    valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.accent),
                  ),
                ),
                // Inner dark face
                Container(
                  width: 174,
                  height: 174,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Color(0xFF191E32),
                        Color(0xFF0C0F1C),
                      ],
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'FOCUS SESSION',
                        style: TextStyle(
                          color: AppTheme.textDim,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [Colors.white, Color(0xFFA5B4FC)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ).createShader(bounds),
                        child: Text(
                          _formatTime(_remainingSeconds),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                            fontWeight: FontWeight.w300,
                            fontFeatures: [FontFeature.tabularFigures()],
                          ),
                        ),
                      ),
                      Text(
                        _isRunning
                            ? 'Running'
                            : (_remainingSeconds == 0 ? 'Done' : 'Ready'),
                        style: TextStyle(
                          color: _isRunning ? AppTheme.runningGreen : AppTheme.textDim,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            // Controls row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Minute input
                Container(
                  width: 60,
                  height: 36,
                  alignment: Alignment.center,
                  child: TextField(
                    controller: _minController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.zero,
                      hintText: '25',
                      suffixText: 'm',
                      suffixStyle: const TextStyle(color: AppTheme.textDim, fontSize: 11),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onChanged: _onMinutesChanged,
                  ),
                ),
                const SizedBox(width: 8),
                // Start / Pause
                InkWell(
                  onTap: _toggleTimer,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTheme.primary, AppTheme.accent],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primary.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Text(
                      _isRunning ? 'Pause' : 'Start',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Reset
                InkWell(
                  onTap: _resetTimer,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: const Text(
                      'Reset',
                      style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

