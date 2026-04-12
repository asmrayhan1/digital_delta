import 'package:digital_delta/mapupdated/models/map_data_model.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import '../logic/path_finder.dart';

class MapPainter extends CustomPainter {
  final List<MapNode> nodes;
  final List<MapEdge> edges;
  final PathResult? pathResult;

  MapPainter({required this.nodes, required this.edges, this.pathResult});

  @override
  void paint(Canvas canvas, Size size) {
    if (nodes.isEmpty) return;

    // Boundary Calculation for Responsive Scaling
    double minLat = nodes.map((n) => n.lat).reduce(min);
    double maxLat = nodes.map((n) => n.lat).reduce(max);
    double minLng = nodes.map((n) => n.lng).reduce(min);
    double maxLng = nodes.map((n) => n.lng).reduce(max);

    Offset project(double lat, double lng) {
      double padding = 40.0;
      double w = size.width - (padding * 2);
      double h = size.height - (padding * 2);
      double x = (lng - minLng) / (maxLng - minLng);
      double y = 1.0 - ((lat - minLat) / (maxLat - minLat));
      return Offset((x * w) + padding, (y * h) + padding);
    }

    // 1. Draw All Background Edges
    for (var edge in edges) {
      final n1 = nodes.firstWhere((n) => n.id == edge.source);
      final n2 = nodes.firstWhere((n) => n.id == edge.target);
      final p1 = project(n1.lat, n1.lng);
      final p2 = project(n2.lat, n2.lng);

      final paint = Paint()
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke;

      if (edge.isCollapsed) {
        paint.color = Colors.red;
        paint.strokeWidth = 4.0;
        // Visualizing a "Broken" road with a bold red line
        canvas.drawLine(p1, p2, paint);
      } else if (edge.isFlooded) {
        paint.color = Colors.blue.withOpacity(0.5); // Flooded road
        _drawDashedLine(canvas, p1, p2, paint);
      } else if (edge.type == 'river') {
        paint.color = Colors.blue[200]!; // Natural river
        canvas.drawLine(p1, p2, paint);
      } else {
        paint.color = Colors.grey[300]!; // Normal road
        canvas.drawLine(p1, p2, paint);
      }
    }

    // 2. Draw the Calculated Path with Multi-Modal Colors
    if (pathResult != null && pathResult!.nodeIds.isNotEmpty) {
      final pathPaint = Paint()
        ..strokeWidth = 5.0
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      // Color based on Mode
      if (pathResult!.travelMode == "BOAT") {
        pathPaint.color = Colors.blueAccent;
      } else {
        pathPaint.color = Colors.greenAccent[700]!;
      }

      for (int i = 0; i < pathResult!.nodeIds.length - 1; i++) {
        final u = nodes.firstWhere((n) => n.id == pathResult!.nodeIds[i]);
        final v = nodes.firstWhere((n) => n.id == pathResult!.nodeIds[i + 1]);
        canvas.drawLine(
          project(u.lat, u.lng),
          project(v.lat, v.lng),
          pathPaint,
        );
      }
    }

    // 3. Draw Nodes and Labels
    for (var node in nodes) {
      final pos = project(node.lat, node.lng);
      canvas.drawCircle(pos, 5, Paint()..color = Colors.black);

      TextPainter(
          text: TextSpan(
            text: node.name,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
        )
        ..layout()
        ..paint(canvas, pos + const Offset(8, -12));
    }
  }

  void _drawDashedLine(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    double dashWidth = 4, dashSpace = 4, distance = 0;
    var dx = p2.dx - p1.dx;
    var dy = p2.dy - p1.dy;
    var totalDistance = sqrt(dx * dx + dy * dy);
    var udx = dx / totalDistance;
    var udy = dy / totalDistance;

    while (distance < totalDistance) {
      canvas.drawLine(
        p1 + Offset(udx * distance, udy * distance),
        p1 +
            Offset(
              udx * min(distance + dashWidth, totalDistance),
              udy * min(distance + dashWidth, totalDistance),
            ),
        paint,
      );
      distance += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(MapPainter oldDelegate) => true;
}
