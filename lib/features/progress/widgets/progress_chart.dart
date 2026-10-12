import 'package:flutter/material.dart';
import 'package:gym_track/features/progress/models/exercise_progress.dart';

class ProgressChart extends StatelessWidget {
  final List<ExerciseProgress> data;

  const ProgressChart({super.key, required this.data});

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

    final primaryColor = Theme.of(context).colorScheme.primary;
    final gridColor = Theme.of(context).dividerColor;

    return SizedBox(
      height: 220,
      child: CustomPaint(
        painter: _ProgressChartPainter(
          data: data,
          lineColor: primaryColor,
          gridColor: gridColor,
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
    const leftPadding = 50.0;
    const rightPadding = 16.0;
    const topPadding = 20.0;
    const bottomPadding = 25.0;

    final chartWidth = size.width - leftPadding - rightPadding;
    final chartHeight = size.height - topPadding - bottomPadding;

    final weights = data.map((item) => item.weight).toList();
    final minWeight = weights.reduce((a, b) => a < b ? a : b);
    final maxWeight = weights.reduce((a, b) => a > b ? a : b);

    // Add safety margin to min/max so curve doesn't clip top/bottom bounds
    final range = maxWeight - minWeight;
    final paddingMargin = range == 0 ? 5.0 : range * 0.15;
    final adjustedMin = minWeight - paddingMargin;
    final adjustedMax = maxWeight + paddingMargin;
    final adjustedRange = adjustedMax - adjustedMin;

    final gridPaint = Paint()
      ..color = gridColor.withValues(alpha: 0.15)
      ..strokeWidth = 1;

    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final pointPaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.fill;

    final pointInnerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Draw horizontal grid lines (4 rows)
    for (var i = 0; i <= 4; i++) {
      final y = topPadding + chartHeight * i / 4;
      canvas.drawLine(
        Offset(leftPadding, y),
        Offset(size.width - rightPadding, y),
        gridPaint,
      );
    }

    // Generate path points
    final path = Path();
    final fillPath = Path();

    for (var i = 0; i < data.length; i++) {
      final x = data.length == 1
          ? leftPadding
          : leftPadding + chartWidth * i / (data.length - 1);

      final normalizedWeight = (data[i].weight - adjustedMin) / adjustedRange;
      final y = topPadding + chartHeight - (normalizedWeight * chartHeight);

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, topPadding + chartHeight);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }

      if (i == data.length - 1) {
        fillPath.lineTo(x, topPadding + chartHeight);
      }
    }

    fillPath.close();

    // Draw Smooth Gradient Fill Underneath Line
    final fillPaint = Paint()
      ..shader =
          LinearGradient(
            colors: [
              lineColor.withValues(alpha: 0.35),
              lineColor.withValues(alpha: 0.0),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(
            Rect.fromLTWH(leftPadding, topPadding, chartWidth, chartHeight),
          );

    canvas.drawPath(fillPath, fillPaint);

    // Draw Main Line
    canvas.drawPath(path, linePaint);

    // Draw Outer/Inner Data Points
    for (var i = 0; i < data.length; i++) {
      final x = data.length == 1
          ? leftPadding
          : leftPadding + chartWidth * i / (data.length - 1);

      final normalizedWeight = (data[i].weight - adjustedMin) / adjustedRange;
      final y = topPadding + chartHeight - (normalizedWeight * chartHeight);

      canvas.drawCircle(Offset(x, y), 6, pointPaint);
      canvas.drawCircle(Offset(x, y), 2.5, pointInnerPaint);
    }

    // Draw Min/Max Weight Reference Labels
    final textStyle = TextStyle(
      color: Colors.grey.shade500,
      fontSize: 11,
      fontWeight: FontWeight.w600,
    );

    final maxTextPainter = TextPainter(
      text: TextSpan(
        text: '${maxWeight.toStringAsFixed(0)}kg',
        style: textStyle,
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    maxTextPainter.paint(
      canvas,
      Offset(0, topPadding - maxTextPainter.height / 2),
    );

    final minTextPainter = TextPainter(
      text: TextSpan(
        text: '${minWeight.toStringAsFixed(0)}kg',
        style: textStyle,
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    minTextPainter.paint(
      canvas,
      Offset(0, topPadding + chartHeight - minTextPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant _ProgressChartPainter oldDelegate) {
    return oldDelegate.data != data ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.gridColor != gridColor;
  }
}
