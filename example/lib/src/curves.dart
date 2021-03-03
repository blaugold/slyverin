import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Extends the [Cubic] curve class to allow for more precise calculation of
/// the curve.
class PreciseCubic extends Cubic {
  /// Creates a precise cubic curve.
  const PreciseCubic(
    double a,
    double b,
    double c,
    double d, {
    double? errorBound,
  })  : errorBound = errorBound ?? 0.00000001,
        super(a, b, c, d);

  factory PreciseCubic.fromCubic(Cubic cubic, {double? errorBound}) =>
      PreciseCubic(
        cubic.a,
        cubic.b,
        cubic.c,
        cubic.d,
        errorBound: errorBound,
      );

  final double errorBound;

  double _evaluateCubic(double a, double b, double m) {
    return 3 * a * (1 - m) * (1 - m) * m + 3 * b * (1 - m) * m * m + m * m * m;
  }

  @override
  double transformInternal(double t) {
    double start = 0.0;
    double end = 1.0;
    while (true) {
      final double midpoint = (start + end) / 2;
      final double estimate = _evaluateCubic(a, c, midpoint);
      if ((t - estimate).abs() < errorBound)
        return _evaluateCubic(b, d, midpoint);
      if (estimate < t)
        start = midpoint;
      else
        end = midpoint;
    }
  }

  @override
  String toString() {
    return '${objectRuntimeType(this, 'PreciseCubic')}(${a.toStringAsFixed(2)}, '
        '${b.toStringAsFixed(2)}, ${c.toStringAsFixed(2)}, '
        '${d.toStringAsFixed(2)}, errorBound: ${errorBound})';
  }
}
