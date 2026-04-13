import 'package:flutter/material.dart';
import 'map_painter.dart';
import 'top_report_dialog.dart';
import '../providers/map_provider.dart';

class MapScreen extends StatefulWidget {
  final MapProvider provider;
  final String rawJson;
  final String userRole;

  const MapScreen({super.key, required this.provider, required this.rawJson, required this.userRole});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final TransformationController _transformationController =
      TransformationController();

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  // Wrapper to load map and then start the ML decay simulation
  Future<void> _initializeData() async {
    await widget.provider.initializeMap(widget.rawJson);
    // Start the timer-based ML decay loop
    widget.provider.startDecaySimulation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Digital Delta"),
        elevation: 2,
        backgroundColor: Colors.blueGrey[900],
        foregroundColor: Colors.white,
        actions: [_buildMeshToggle()],
      ),
      body: ListenableBuilder(
        listenable: widget.provider,
        builder: (context, child) {
          final res = widget.provider.currentPathResult;

          return Column(
            children: [
              _buildMeshStatusIndicator(),
              if (res != null) _buildStatusBanner(res.travelMode),
              Expanded(
                child: Container(
                  color: Colors.blueGrey[50],
                  child: InteractiveViewer(
                    transformationController: _transformationController,
                    boundaryMargin: const EdgeInsets.all(100),
                    minScale: 0.5,
                    maxScale: 10.0,
                    child: SizedBox(
                      width: double.infinity,
                      height: double.infinity,
                      child: CustomPaint(
                        painter: MapPainter(
                          nodes: widget.provider.nodes,
                          edges: widget.provider.edges,
                          pathResult: res,
                          rainIntensity: widget.provider.globalRainIntensity,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              _buildControls(), // Contains the new ML simulation slider
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
            builder: (context) => TopReportDialog(provider: widget.provider, userRole: widget.userRole),
          );
        },
      ),
    );
  }

  Widget _buildMeshToggle() {
    return ListenableBuilder(
      listenable: widget.provider,
      builder: (context, child) {
        return Row(
          children: [
            const Icon(Icons.bluetooth, size: 16),
            Switch(
              activeColor: Colors.greenAccent,
              value: widget.provider.isMeshActive,
              onChanged: (val) => widget.provider.toggleMesh(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMeshStatusIndicator() {
    return Container(
      width: double.infinity,
      color: Colors.blueGrey[800],
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: Text(
        widget.provider.meshStatus,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ML SIMULATION SLIDER
          Row(
            children: [
              const Icon(Icons.umbrella, size: 18, color: Colors.blueAccent),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Rainfall Intensity: ${(widget.provider.globalRainIntensity * 100).toInt()}%",
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Slider(
                      value: widget.provider.globalRainIntensity,
                      min: 0.0,
                      max: 1.0,
                      activeColor: Colors.blueAccent,
                      onChanged: (val) {
                        widget.provider.globalRainIntensity = val;
                        setState(() {});
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(),
          // SOURCE AND DESTINATION DROPDOWNS
          Row(
            children: [
              Flexible(child: _cityDropdown(true)),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: Colors.grey,
                ),
              ),
              Flexible(child: _cityDropdown(false)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _cityDropdown(bool isStart) {
    return DropdownButtonFormField<String>(
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
