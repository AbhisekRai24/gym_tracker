
import 'package:flutter/material.dart';
import 'package:gym_track/features/progress/models/exercise_progress.dart';


class ProgressChart extends StatelessWidget {
  final List<ExerciseProgress> data;

  const ProgressChart({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    if (data.length < 2) {
      return const SizedBox(
        height: 220,
        child: Center(
          child: Text('Log at least 2 records to see your progress chart'),
        ),
      );
    }

    return SizedBox(
      height: 220,
      child: CustomPaint(
        painter: _ProgressChartPainter(
          data: data,
          lineColor: Theme.of(context).colorScheme.primary,
          gridColor: Theme.of(context).dividerColor,
        ),
      ),
    );
  }
}

class _ProgressChartPainter extends CustomPainter {
  final List<ExerciseProgress> data;
  final Color lineColor;
  final Color gridColor;

  _ProgressChartPainter({
    required this.data,
    required this.lineColor,
    required this.gridColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const leftPadding = 45.0;
    const rightPadding = 16.0;
    const topPadding = 16.0;
    const bottomPadding = 30.0;

    final chartWidth = size.width - leftPadding - rightPadding;
    final chartHeight = size.height - topPadding - bottomPadding;

    final weights = data.map((item) => item.weight).toList();

    final minWeight = weights.reduce(
      (a, b) => a < b ? a : b,
    );

    final maxWeight = weights.reduce(
      (a, b) => a > b ? a : b,
    );

    final range = maxWeight - minWeight;

    final adjustedRange = range == 0 ? 10.0 : range;

    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;

    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final pointPaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.fill;

    // Draw horizontal grid lines.
    for (var i = 0; i <= 4; i++) {
      final y = topPadding + chartHeight * i / 4;

      canvas.drawLine(
        Offset(leftPadding, y),
        Offset(size.width - rightPadding, y),
        gridPaint,
      );
    }

    // Draw progress line.
    final path = Path();

    for (var i = 0; i < data.length; i++) {
      final x = data.length == 1
          ? leftPadding
          : leftPadding + chartWidth * i / (data.length - 1);

      final normalizedWeight =
          (data[i].weight - minWeight) / adjustedRange;

      final y = topPadding +
          chartHeight -
          normalizedWeight * chartHeight;

      final point = Offset(x, y);

      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }

    canvas.drawPath(path, linePaint);

    // Draw points.
    for (var i = 0; i < data.length; i++) {
      final x = data.length == 1
          ? leftPadding
          : leftPadding + chartWidth * i / (data.length - 1);

      final normalizedWeight =
          (data[i].weight - minWeight) / adjustedRange;

      final y = topPadding +
          chartHeight -
          normalizedWeight * chartHeight;

      canvas.drawCircle(
        Offset(x, y),
        5,
        pointPaint,
      );
    }

    // Draw minimum and maximum weight labels.
    final textStyle = TextStyle(
      color: Colors.grey.shade700,
      fontSize: 12,
    );

    final minTextPainter = TextPainter(
      text: TextSpan(
        text: '${minWeight.toStringAsFixed(0)} kg',
        style: textStyle,
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    minTextPainter.paint(
      canvas,
      Offset(0, topPadding + chartHeight - minTextPainter.height / 2),
    );

    final maxTextPainter = TextPainter(
      text: TextSpan(
        text: '${maxWeight.toStringAsFixed(0)} kg',
        style: textStyle,
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    maxTextPainter.paint(
      canvas,
      Offset(0, topPadding - maxTextPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant _ProgressChartPainter oldDelegate) {
    return oldDelegate.data != data ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.gridColor != gridColor;
  }
}
