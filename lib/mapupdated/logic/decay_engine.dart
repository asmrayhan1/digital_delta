import 'package:tflite_flutter/tflite_flutter.dart';

class DecayEngine {
  Interpreter? _interpreter;
  bool _modelUsable = false;

  bool get isModelLoaded => _modelUsable;

  Future<void> init() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/decay_model.tflite');
      _modelUsable = true;
    } catch (e) {
      _interpreter = null;
      _modelUsable = false;
    }
  }

  void dispose() {
    _interpreter?.close();
    _interpreter = null;
    _modelUsable = false;
  }

  /// Risk of road condition worsening (0–1). Uses TFLite when available, else a rainfall heuristic.
  double predictRoadWorseningRisk(
    double rain,
    double cumRain,
    double elevation,
    double sat,
  ) {
    if (_interpreter != null && _modelUsable) {
      try {
        final input = [
          [rain, cumRain, elevation, sat],
        ];
        final output = List.generate(1, (_) => List<double>.filled(1, 0.0));
        _interpreter!.run(input, output);
        return output[0][0].clamp(0.0, 1.0);
      } catch (_) {
        // Wrong tensor layout / dtype — fall back so the UI still works.
      }
    }
    return _heuristicRisk(rain, cumRain, elevation, sat);
  }

  double _heuristicRisk(
    double rain,
    double cumRain,
    double elevation,
    double sat,
  ) {
    final lowGround = (1.0 - (elevation / 30.0).clamp(0.0, 1.0));
    final rainNorm = rain.clamp(0.0, 1.0);
    final cumNorm = (cumRain / 150.0).clamp(0.0, 1.0);
    final satNorm = sat.clamp(0.0, 1.0);
    final v =
        rainNorm * 0.45 + satNorm * 0.3 + cumNorm * 0.15 + lowGround * rainNorm * 0.35;
    return v.clamp(0.0, 1.0);
  }
}