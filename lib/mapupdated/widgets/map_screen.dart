import 'package:flutter/material.dart';
import 'map_painter.dart';
import 'top_report_dialog.dart';
import '../providers/map_provider.dart';

class MapScreen extends StatefulWidget {
  final MapProvider provider;
  final String rawJson;

  const MapScreen({super.key, required this.provider, required this.rawJson});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  // Controller to allow resetting the zoom programmatically
  final TransformationController _transformationController =
      TransformationController();

  @override
  void initState() {
    super.initState();
    widget.provider.initializeMap(widget.rawJson);
  }

  void _resetZoom() {
    _transformationController.value = Matrix4.identity();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Digital Delta: Sylhet Mesh"),
        elevation: 2,
        backgroundColor: Colors.blueGrey[900],
        foregroundColor: Colors.white,
        actions: [
          // Helpful button to return to the original view
          IconButton(
            icon: const Icon(Icons.center_focus_strong),
            onPressed: _resetZoom,
            tooltip: "Reset View",
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: widget.provider,
        builder: (context, child) {
          final res = widget.provider.currentPathResult;

          return Column(
            children: [
              // Travel Mode Indicator (Road/Boat/Drone)
              if (res != null) _buildStatusBanner(res.travelMode),

              Expanded(
                child: Container(
                  color: Colors.blueGrey[50],
                  // INTERACTIVE VIEWER: This handles all pan and zoom
                  child: InteractiveViewer(
                    transformationController: _transformationController,
                    boundaryMargin: const EdgeInsets.all(
                      100,
                    ), // Allow panning slightly beyond map
                    minScale: 0.5,
                    maxScale: 10.0, // Allow deep zoom into specific nodes
                    child: SizedBox(
                      width: double.infinity,
                      height: double.infinity,
                      child: CustomPaint(
                        painter: MapPainter(
                          nodes: widget.provider.nodes,
                          edges: widget.provider.edges,
                          pathResult: res,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              _buildControls(),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.redAccent,
        child: const Icon(Icons.report_gmailerrorred, color: Colors.white),
        onPressed: () {
          showDialog(
            context: context,
            barrierColor: Colors.black45,
            builder: (context) => TopReportDialog(provider: widget.provider),
          );
        },
      ),
    );
  }

  Widget _buildStatusBanner(String mode) {
    Color color = Colors.green;
    String text = "Route Clear: Vehicles Supported";
    IconData icon = Icons.check_circle_outline;

    if (mode == "BOAT") {
      color = Colors.blue;
      text = "Route Flooded: Boat Required";
      icon = Icons.directions_boat_filled;
    } else if (mode == "DRONE") {
      color = Colors.deepOrange;
      text = "Route Collapsed: Drone Only";
      icon = Icons.precision_manufacturing_outlined;
    }

    return Container(
      width: double.infinity,
      color: color,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 12),
          Text(
            text.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Using Flexible instead of Expanded to give the Row more breathing room
          Flexible(child: _cityDropdown(true)),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
          ),
          Flexible(child: _cityDropdown(false)),
        ],
      ),
    );
  }

  Widget _cityDropdown(bool isStart) {
    return DropdownButtonFormField<String>(
      // CRITICAL: This prevents the internal Row from overflowing
      isExpanded: true,
      decoration: InputDecoration(
        labelText: isStart ? "Source" : "Dest",
        labelStyle: const TextStyle(fontSize: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      ),
      value: isStart
          ? widget.provider.selectedStart
          : widget.provider.selectedEnd,
      // We use a smaller font and ellipsis to handle long Sylhet location names
      items: widget.provider.nodes.map((n) {
        return DropdownMenuItem(
          value: n.id,
          child: Text(
            n.name,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12),
          ),
        );
      }).toList(),
      onChanged: (val) => widget.provider.setPoints(
        isStart ? val : widget.provider.selectedStart,
        isStart ? widget.provider.selectedEnd : val,
      ),
    );
  }
}
