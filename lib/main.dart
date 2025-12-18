import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../audio/equalizer_state.dart';

class AudioSettingsPage extends StatelessWidget {
  const AudioSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final eq = context.watch<EqualizerState>();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text("Audio Settings")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _slider("Bass", eq.bass, eq.isPremium,
                (v) => eq.setBass(v)),
            _slider("Mid", eq.mid, eq.isPremium,
                (v) => eq.setMid(v)),
            _slider("Treble", eq.treble, eq.isPremium,
                (v) => eq.setTreble(v)),

            if (!eq.isPremium)
              const Padding(
                padding: EdgeInsets.only(top: 20),
                child: Text(
                  "Premium only",
                  style: TextStyle(color: Colors.red),
                ),
              )
          ],
        ),
      ),
    );
  }

  Widget _slider(String label, double value, bool enabled,
      Function(double) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white)),
        Slider(
          value: value,
          min: -10,
          max: 10,
          onChanged: enabled ? onChanged : null,
        ),
      ],
    );
  }
}
