import 'dart:async';

import 'package:digital_delta/map/services/map_provider.dart';
import 'package:flutter/material.dart';
import 'map_painter.dart'; // Make sure this file exists from previous step

class MapScreen extends StatefulWidget {
  final MapProvider provider;

  const MapScreen({super.key, required this.provider});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Initial fetch
    widget.provider.fetchStatus();
    
    // Start polling the server every 5 seconds
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      widget.provider.fetchStatus();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Digital Delta: Sylhet Flood Map"),
        backgroundColor: Colors.blueGrey[900],
        foregroundColor: Colors.white,
      ),
      body: ListenableBuilder(
        listenable: widget.provider,
        builder: (context, child) {
          return Column(
            children: [
              // 1. The Map Visualization Area
              Expanded(
                child: Container(
                  width: double.infinity,
                  color: Colors.blueGrey[50],
                  child: widget.provider.nodes.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : CustomPaint(
                          painter: MapPainter(
                            nodes: widget.provider.nodes,
                            edges: widget.provider.edges,
                            pathIds: widget.provider.currentPath,
                          ),
                        ),
                ),
              ),

              // 2. Control Panel
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
                ),
                child: Column(
                  children: [
                    const Text("Simulation Controls", 
                      style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(child: _buildDropdown(true)),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: Icon(Icons.compare_arrows),
                        ),
                        Expanded(child: _buildDropdown(false)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDropdown(bool isStart) {
    return DropdownButton<String>(
      isExpanded: true,
      hint: Text(isStart ? "Source" : "Destination"),
      value: isStart ? widget.provider.selectedStart : widget.provider.selectedEnd,
      items: widget.provider.nodes.map((node) {
        return DropdownMenuItem(
          value: node.id,
          child: Text(node.name, style: const TextStyle(fontSize: 12)),
        );
      }).toList(),
      onChanged: (val) {
        if (val == null) return;
        if (isStart) {
          widget.provider.setStart(val);
        } else {
          widget.provider.setEnd(val);
        }
      },
    );
  }
}