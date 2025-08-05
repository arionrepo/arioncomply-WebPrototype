// FILE PATH: lib/core/services/ai_transparency_service.dart
// AI Transparency Service - For logging AI decision making

import 'package:flutter/foundation.dart';

/// Service for logging AI interactions and decisions for transparency
class AITransparencyService {
  static final AITransparencyService _instance = AITransparencyService._internal();
  static AITransparencyService get instance => _instance;
  
  AITransparencyService._internal();

  final List<Map<String, dynamic>> _interactionLog = [];

  /// Log an AI interaction for transparency
  void logInteraction({
    required String type,
    required String input,
    required String output,
    required String reasoning,
    Map<String, dynamic>? metadata,
  }) {
    final logEntry = {
      'timestamp': DateTime.now().toIso8601String(),
      'type': type,
      'input': input,
      'output': output,
      'reasoning': reasoning,
      'metadata': metadata ?? {},
    };

    _interactionLog.add(logEntry);

    if (kDebugMode) {
      print('🔍 AI Interaction logged: $type');
    }

    // Keep only last 100 entries to prevent memory issues
    if (_interactionLog.length > 100) {
      _interactionLog.removeAt(0);
    }
  }

  /// Get interaction log
  List<Map<String, dynamic>> getInteractionLog() {
    return List.from(_interactionLog);
  }

  /// Clear interaction log
  void clearLog() {
    _interactionLog.clear();
    
    if (kDebugMode) {
      print('🧹 AI transparency log cleared');
    }
  }

  /// Get log statistics
  Map<String, dynamic> getLogStatistics() {
    final types = <String, int>{};
    
    for (final entry in _interactionLog) {
      final type = entry['type'] as String;
      types[type] = (types[type] ?? 0) + 1;
    }

    return {
      'total_interactions': _interactionLog.length,
      'interaction_types': types,
      'first_interaction': _interactionLog.isNotEmpty 
          ? _interactionLog.first['timestamp'] 
          : null,
      'last_interaction': _interactionLog.isNotEmpty 
          ? _interactionLog.last['timestamp'] 
          : null,
    };
  }

  /// Export log as JSON
  Map<String, dynamic> exportLog() {
    return {
      'metadata': {
        'export_timestamp': DateTime.now().toIso8601String(),
        'total_entries': _interactionLog.length,
      },
      'interactions': _interactionLog,
      'statistics': getLogStatistics(),
    };
  }
}