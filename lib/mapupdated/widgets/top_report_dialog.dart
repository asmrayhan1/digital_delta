import 'package:digital_delta/mapupdated/models/map_data_model.dart';
import 'package:flutter/material.dart';
import '../providers/map_provider.dart';

class TopReportDialog extends StatelessWidget {
  final MapProvider provider;

  const TopReportDialog({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      alignment: Alignment.topCenter,
      insetPadding: const EdgeInsets.fromLTRB(10, 50, 10, 0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context),
            const Divider(),
            Expanded(
              child: ListenableBuilder(
                listenable: provider,
                builder: (context, child) {
                  return ListView.separated(
                    shrinkWrap: true,
                    itemCount: provider.edges.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final edge = provider.edges[index];
                      final sourceName = provider.getNodeName(edge.source);
                      final targetName = provider.getNodeName(edge.target);

                      return _buildReportItem(edge, sourceName, targetName);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.emergency_share, color: Colors.redAccent),
        const SizedBox(width: 10),
        const Text(
          "Field Intelligence Report",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  Widget _buildReportItem(MapEdge edge, String source, String target) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$source ➔ $target",
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _conditionChip(
                  edge,
                  "Normal",
                  Colors.green,
                  !edge.isFlooded && !edge.isCollapsed,
                ),
                const SizedBox(width: 8),
                _conditionChip(edge, "Flooded", Colors.blue, edge.isFlooded),
                const SizedBox(width: 8),
                _conditionChip(edge, "Collapsed", Colors.red, edge.isCollapsed),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _conditionChip(
    MapEdge edge,
    String label,
    Color color,
    bool isSelected,
  ) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: color.withOpacity(0.2),
      labelStyle: TextStyle(
        color: isSelected ? color : Colors.grey[600],
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      onSelected: (selected) {
        if (selected) {
          provider.updateEdgeCondition(edge.id, label);
        }
      },
    );
  }
}
