import 'package:flutter/material.dart';
import 'dart:async';

class CountdownTimerWidget extends StatefulWidget {
  final DateTime expiryTime;
  final VoidCallback onExpired;

  const CountdownTimerWidget({super.key, required this.expiryTime, required this.onExpired});

  @override State<CountdownTimerWidget> createState() => _CountdownTimerWidgetState();
}

class _CountdownTimerWidgetState extends State<CountdownTimerWidget> {
  late Timer _timer;
  int _secondsRemaining = 0;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _updateSeconds();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateSeconds();
      if (_secondsRemaining <= 0) {
        _timer.cancel();
        widget.onExpired();
      }
    });
  }

  void _updateSeconds() {
    setState(() {
      _secondsRemaining = widget.expiryTime.difference(DateTime.now()).inSeconds;
      if (_secondsRemaining < 0) _secondsRemaining = 0;
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = _secondsRemaining / 120;
    final color = _secondsRemaining > 30 ? Colors.green : (_secondsRemaining > 10 ? Colors.orange : Colors.red);
    
    return Column(
      children: [
        LinearProgressIndicator(value: progress, backgroundColor: Colors.grey.shade300, valueColor: AlwaysStoppedAnimation<Color>(color)),
        const SizedBox(height: 8),
        Text(
          '⏰ Expira em: ${_secondsRemaining ~/ 60}:${(_secondsRemaining % 60).toString().padLeft(2, '0')}',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }
}
