import 'dart:convert';

/// Vector Clock Service (M2.2)
///
/// Every mutation carries a vector clock. Causal history is preserved.
/// Supports: increment, merge, causality comparison.
class VectorClockService {
  /// The local node's ID
  final String nodeId;

  /// Current vector clock state: nodeId → counter
  Map<String, int> _clock = {};

  VectorClockService({required this.nodeId});

  /// Get the current clock as a map
  Map<String, int> get clock => Map.unmodifiable(_clock);

  /// Initialize from a persisted state
  void loadFromJson(String json) {
    final Map<String, dynamic> decoded = jsonDecode(json);
    _clock = decoded.map((k, v) => MapEntry(k, v as int));
  }

  /// Serialize for persistence
  String toJson() => jsonEncode(_clock);

  /// Increment our own counter (called before every local mutation)
  Map<String, int> increment() {
    _clock[nodeId] = (_clock[nodeId] ?? 0) + 1;
    return Map.from(_clock);
  }

  /// Merge a remote clock into ours (element-wise max)
  /// Called when receiving data from a peer.
  Map<String, int> merge(Map<String, int> remote) {
    for (final entry in remote.entries) {
      _clock[entry.key] = (_clock[entry.key] ?? 0) > entry.value
          ? _clock[entry.key]!
          : entry.value;
    }
    // Also increment our own counter to advance past the merge point
    _clock[nodeId] = (_clock[nodeId] ?? 0) + 1;
    return Map.from(_clock);
  }

  /// Check if clock A happened-before clock B
  /// A < B iff ∀k: A[k] ≤ B[k] and ∃k: A[k] < B[k]
  static bool isAfter(Map<String, int> a, Map<String, int> b) {
    final allKeys = {...a.keys, ...b.keys};
    bool atLeastOneGreater = false;

    for (final k in allKeys) {
      final av = a[k] ?? 0;
      final bv = b[k] ?? 0;
      if (av < bv) return false; // a has a smaller component → not after
      if (av > bv) atLeastOneGreater = true;
    }
    return atLeastOneGreater;
  }

  /// Check if two clocks are concurrent (neither happened-before the other)
  static bool isConcurrent(Map<String, int> a, Map<String, int> b) {
    return !isAfter(a, b) && !isAfter(b, a) && !_isEqual(a, b);
  }

  static bool _isEqual(Map<String, int> a, Map<String, int> b) {
    final allKeys = {...a.keys, ...b.keys};
    for (final k in allKeys) {
      if ((a[k] ?? 0) != (b[k] ?? 0)) return false;
    }
    return true;
  }

  /// Convert protobuf VectorClock map (String,Int64) to Dart map
  static Map<String, int> fromProtoMap(Map<String, dynamic> protoMap) {
    return protoMap.map((k, v) => MapEntry(k, (v is int) ? v : (v as dynamic).toInt()));
  }

  /// Convert Dart map to protobuf-compatible map
  static Map<String, int> toProtoMap(Map<String, int> dartMap) {
    return Map.from(dartMap);
  }
}
