import 'package:digital_delta/map/models/edge.dart';
import 'package:digital_delta/map/models/node.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class MapPainter extends CustomPainter {
  final List<Node> nodes;
  final List<Edge> edges;
  final List<String> pathIds; // The IDs from currentPath

  MapPainter({required this.nodes, required this.edges, required this.pathIds});

  @override
  void paint(Canvas canvas, Size size) {
    if (nodes.isEmpty) return;

    // 1. Calculate the boundaries of your dummy data
    double minLat = nodes.map((n) => n.lat).reduce(min);
    double maxLat = nodes.map((n) => n.lat).reduce(max);
    double minLng = nodes.map((n) => n.lng).reduce(min);
    double maxLng = nodes.map((n) => n.lng).reduce(max);

    // Helper to convert Lat/Lng to Screen X/Y
    Offset project(double lat, double lng) {
      double padding = 50.0;
      double w = size.width - (padding * 2);
      double h = size.height - (padding * 2);

      // Normalize coordinates
      double x = (lng - minLng) / (maxLng - minLng);
      // Flip Y because in Flutter, 0 is Top
      double y = 1.0 - ((lat - minLat) / (maxLat - minLat));

      return Offset((x * w) + padding, (y * h) + padding);
    }

    // 2. Draw ALL Edges first (Background)
    for (var edge in edges) {
      final startNode = nodes.firstWhere((n) => n.id == edge.source);
      final endNode = nodes.firstWhere((n) => n.id == edge.target);
      
      final p1 = project(startNode.lat, startNode.lng);
      final p2 = project(endNode.lat, endNode.lng);

      final paint = Paint()
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke;

      if (edge.isFlooded) {
        paint.color = Colors.red.withOpacity(0.5);
        // Draw dashed line for flooded/broken roads
        _drawDashedLine(canvas, p1, p2, paint);
      } else {
        paint.color = Colors.grey[400]!;
        canvas.drawLine(p1, p2, paint);
      }
    }

    // 3. Draw the ACTIVE Shortest Path (Highlight)
    final pathPaint = Paint()
      ..color = Colors.blueAccent
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < pathIds.length - 1; i++) {
      final u = nodes.firstWhere((n) => n.id == pathIds[i]);
      final v = nodes.firstWhere((n) => n.id == pathIds[i+1]);
      canvas.drawLine(project(u.lat, u.lng), project(v.lat, v.lng), pathPaint);
    }

    // 4. Draw Nodes
    for (var node in nodes) {
      final pos = project(node.lat, node.lng);
      
      // Node circle
      canvas.drawCircle(pos, 6, Paint()..color = Colors.black);
      
      // Label
      final textPainter = TextPainter(
        text: TextSpan(text: node.name, style: TextStyle(color: Colors.black, fontSize: 10)),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, pos + Offset(8, -8));
    }
  }

  void _drawDashedLine(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    double dashWidth = 5, dashSpace = 5, distance = 0;
    var dx = p2.dx - p1.dx;
    var dy = p2.dy - p1.dy;
    var totalDistance = sqrt(dx * dx + dy * dy);
    var udx = dx / totalDistance;
    var udy = dy / totalDistance;

    while (distance < totalDistance) {
      canvas.drawLine(
        p1 + Offset(udx * distance, udy * distance),
        p1 + Offset(udx * min(distance + dashWidth, totalDistance), udy * min(distance + dashWidth, totalDistance)),
        paint,
      );
      distance += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(MapPainter oldDelegate) => true;
}