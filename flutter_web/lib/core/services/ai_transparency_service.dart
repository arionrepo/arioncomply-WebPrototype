// FILE PATH: lib/core/services/ai_transparency_service.dart
// AI Transparency Service - Logs AI decisions for explainable AI compliance
// Referenced in expert_personality_engine.dart for decision tracking

import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';

import '../constants/app_constants.dart';

/// AI Transparency Service for explainable AI and decision logging
/// Key differentiator: Full transparency in AI decision-making process
class AITransparencyService {
  static AITransparencyService? _instance;
  static AITransparencyService get instance => _instance ??= AITransparencyService._();
  AITransparencyService._();

  final List<AIDecisionLog> _decisionLogs = [];
  final StreamController<AIDecisionLog> _logStreamController = 
      StreamController<AIDecisionLog>.broadcast();
  
  int _traceIdCounter = 0;
  bool _loggingEnabled = AppConstants.logAllAIDecisions;
  String _transparencyLevel = AppConstants.aiTransparencyLevel;

  // Public streams for real-time monitoring
  Stream<AIDecisionLog> get decisionStream => _logStreamController.stream;
  List<AIDecisionLog> get allDecisions => List.unmodifiable(_decisionLogs);

  /// Start a new AI decision trace
  String startDecision(String operationType) {
    final traceId = 'trace_${++_traceIdCounter}_${DateTime.now().millisecondsSinceEpoch}';
    
    if (_loggingEnabled) {
      final log = AIDecisionLog(
        traceId: traceId,
        operationType: operationType,
        timestamp: DateTime.now(),
        status: DecisionStatus.started,
      );
      
      _addLogEntry(log);
      
      if (kDebugMode) {
        print('🧠 AI Decision Started: $operationType ($traceId)');
      }
    }
    
    return traceId;
  }

  /// Log an AI decision with reasoning
  void logDecision({
    required String traceId,
    required String decision,
    required String reasoning,
    required double confidence,
    Map<String, dynamic>? metadata,
    List<String>? alternativesConsidered,
  }) {
    if (!_loggingEnabled) return;
    
    final log = AIDecisionLog(
      traceId: traceId,
      operationType: _getOperationTypeForTrace(traceId),
      timestamp: DateTime.now(),
      status: DecisionStatus.completed,
      decision: decision,
      reasoning: reasoning,
      confidence: confidence,
      metadata: metadata,
      alternativesConsidered: alternativesConsidered,
    );
    
    _updateLogEntry(log);
    
    if (kDebugMode) {
      print('🧠 AI Decision Logged: $decision (confidence: ${(confidence * 100).toStringAsFixed(1)}%)');
      if (_transparencyLevel == 'full') {
        print('   Reasoning: $reasoning');
      }
    }
  }

  /// Log an error in AI decision-making
  void logError(String traceId, String error, {Map<String, dynamic>? context}) {
    if (!_loggingEnabled) return;
    
    final log = AIDecisionLog(
      traceId: traceId,
      operationType: _getOperationTypeForTrace(traceId),
      timestamp: DateTime.now(),
      status: DecisionStatus.error,
      error: error,
      metadata: context,
    );
    
    _updateLogEntry(log);
    
    if (kDebugMode) {
      print('❌ AI Decision Error: $error ($traceId)');
    }
  }

  /// Log reasoning step in complex decision process
  void logReasoningStep({
    required String traceId,
    required String step,
    required String reasoning,
    Map<String, dynamic>? stepData,
  }) {
    if (!_loggingEnabled || _transparencyLevel == 'minimal') return;
    
    final existingLog = _findLogByTraceId(traceId);
    if (existingLog != null) {
      final updatedSteps = [...existingLog.reasoningSteps];
      updatedSteps.add(ReasoningStep(
        step: step,
        reasoning: reasoning,
        timestamp: DateTime.now(),
        data: stepData,
      ));
      
      final updatedLog = existingLog.copyWith(reasoningSteps: updatedSteps);
      _updateLogEntry(updatedLog);
    }
    
    if (kDebugMode && _transparencyLevel == 'full') {
      print('🔍 Reasoning Step: $step - $reasoning');
    }
  }

  /// Get decision explanation for user transparency
  AIDecisionExplanation? getDecisionExplanation(String traceId) {
    final log = _findLogByTraceId(traceId);
    if (log == null || log.status != DecisionStatus.completed) {
      return null;
    }
    
    return AIDecisionExplanation(
      decision: log.decision ?? 'Unknown decision',
      reasoning: log.reasoning ?? 'No reasoning provided',
      confidence: log.confidence ?? 0.0,
      factors: _extractDecisionFactors(log),
      alternatives: log.alternativesConsidered ?? [],
      timestamp: log.timestamp,
      transparencyLevel: _determineExplanationLevel(log.confidence ?? 0.0),
    );
  }

  /// Get transparency report for a time period
  TransparencyReport getTransparencyReport({
    DateTime? startDate,
    DateTime? endDate,
    String? operationType,
  }) {
    final filteredLogs = _decisionLogs.where((log) {
      bool matchesDate = true;
      bool matchesOperation = true;
      
      if (startDate != null) {
        matchesDate = log.timestamp.isAfter(startDate);
      }
      if (endDate != null) {
        matchesDate = matchesDate && log.timestamp.isBefore(endDate);
      }
      if (operationType != null) {
        matchesOperation = log.operationType == operationType;
      }
      
      return matchesDate && matchesOperation;
    }).toList();
    
    return TransparencyReport(
      totalDecisions: filteredLogs.length,
      completedDecisions: filteredLogs.where((l) => l.status == DecisionStatus.completed).length,
      erroredDecisions: filteredLogs.where((l) => l.status == DecisionStatus.error).length,
      averageConfidence: _calculateAverageConfidence(filteredLogs),
      operationBreakdown: _getOperationBreakdown(filteredLogs),
      confidenceDistribution: _getConfidenceDistribution(filteredLogs),
      period: DateRange(
        start: startDate ?? _getEarliestLogDate(),
        end: endDate ?? _getLatestLogDate(),
      ),
    );
  }

  /// Get user-friendly explanation for a decision
  String getUserFriendlyExplanation(String traceId) {
    final explanation = getDecisionExplanation(traceId);
    if (explanation == null) {
      return "I couldn't find details about this decision.";
    }
    
    switch (_transparencyLevel) {
      case 'full':
        return _generateFullExplanation(explanation);
      case 'summary':
        return _generateSummaryExplanation(explanation);
      case 'minimal':
        return _generateMinimalExplanation(explanation);
      default:
        return explanation.reasoning;
    }
  }

  /// Configure transparency settings
  void configureTransparency({
    bool? enableLogging,
    String? transparencyLevel,
  }) {
    if (enableLogging != null) {
      _loggingEnabled = enableLogging;
    }
    
    if (transparencyLevel != null && 
        ['full', 'summary', 'minimal'].contains(transparencyLevel)) {
      _transparencyLevel = transparencyLevel;
    }
    
    if (kDebugMode) {
      print('🔧 AI Transparency configured: logging=$_loggingEnabled, level=$_transparencyLevel');
    }
  }

  /// Clear old decision logs (privacy maintenance)
  void clearOldLogs({Duration? olderThan}) {
    final cutoff = DateTime.now().subtract(olderThan ?? const Duration(days: 30));
    final initialCount = _decisionLogs.length;
    
    _decisionLogs.removeWhere((log) => log.timestamp.isBefore(cutoff));
    
    final removedCount = initialCount - _decisionLogs.length;
    if (kDebugMode && removedCount > 0) {
      print('🗑️ Cleared $removedCount old AI decision logs');
    }
  }

  // Private helper methods

  void _addLogEntry(AIDecisionLog log) {
    _decisionLogs.add(log);
    _logStreamController.add(log);
    
    // Prevent memory leaks by limiting log count
    if (_decisionLogs.length > 1000) {
      _decisionLogs.removeAt(0);
    }
  }

  void _updateLogEntry(AIDecisionLog updatedLog) {
    final index = _decisionLogs.indexWhere((log) => log.traceId == updatedLog.traceId);
    if (index != -1) {
      _decisionLogs[index] = updatedLog;
      _logStreamController.add(updatedLog);
    } else {
      _addLogEntry(updatedLog);
    }
  }

  AIDecisionLog? _findLogByTraceId(String traceId) {
    try {
      return _decisionLogs.firstWhere((log) => log.traceId == traceId);
    } catch (e) {
      return null;
    }
  }

  String _getOperationTypeForTrace(String traceId) {
    final log = _findLogByTraceId(traceId);
    return log?.operationType ?? 'unknown';
  }

  List<String> _extractDecisionFactors(AIDecisionLog log) {
    final factors = <String>[];
    
    if (log.metadata != null) {
      log.metadata!.forEach((key, value) {
        factors.add('$key: $value');
      });
    }
    
    return factors;
  }

  TransparencyLevel _determineExplanationLevel(double confidence) {
    if (confidence >= 0.8) return TransparencyLevel.high;
    if (confidence >= 0.6) return TransparencyLevel.medium;
    return TransparencyLevel.low;
  }

  double _calculateAverageConfidence(List<AIDecisionLog> logs) {
    final confidenceLogs = logs.where((l) => l.confidence != null).toList();
    if (confidenceLogs.isEmpty) return 0.0;
    
    final sum = confidenceLogs.fold(0.0, (sum, log) => sum + log.confidence!);
    return sum / confidenceLogs.length;
  }

  Map<String, int> _getOperationBreakdown(List<AIDecisionLog> logs) {
    final breakdown = <String, int>{};
    for (final log in logs) {
      breakdown[log.operationType] = (breakdown[log.operationType] ?? 0) + 1;
    }
    return breakdown;
  }

  Map<String, int> _getConfidenceDistribution(List<AIDecisionLog> logs) {
    final distribution = <String, int>{
      'High (80-100%)': 0,
      'Medium (60-79%)': 0,
      'Low (0-59%)': 0,
    };
    
    for (final log in logs) {
      if (log.confidence != null) {
        if (log.confidence! >= 0.8) {
          distribution['High (80-100%)'] = distribution['High (80-100%)']! + 1;
        } else if (log.confidence! >= 0.6) {
          distribution['Medium (60-79%)'] = distribution['Medium (60-79%)']! + 1;
        } else {
          distribution['Low (0-59%)'] = distribution['Low (0-59%)']! + 1;
        }
      }
    }
    
    return distribution;
  }

  DateTime _getEarliestLogDate() {
    if (_decisionLogs.isEmpty) return DateTime.now();
    return _decisionLogs.first.timestamp;
  }

  DateTime _getLatestLogDate() {
    if (_decisionLogs.isEmpty) return DateTime.now();
    return _decisionLogs.last.timestamp;
  }

  String _generateFullExplanation(AIDecisionExplanation explanation) {
    final buffer = StringBuffer();
    buffer.writeln('Here\'s how I made this decision:');
    buffer.writeln();
    buffer.writeln('**Decision**: ${explanation.decision}');
    buffer.writeln('**Reasoning**: ${explanation.reasoning}');
    buffer.writeln('**Confidence**: ${(explanation.confidence * 100).toStringAsFixed(1)}%');
    
    if (explanation.factors.isNotEmpty) {
      buffer.writeln('**Factors considered**:');
      for (final factor in explanation.factors) {
        buffer.writeln('  • $factor');
      }
    }
    
    if (explanation.alternatives.isNotEmpty) {
      buffer.writeln('**Alternatives I considered**:');
      for (final alt in explanation.alternatives) {
        buffer.writeln('  • $alt');
      }
    }
    
    return buffer.toString();
  }

  String _generateSummaryExplanation(AIDecisionExplanation explanation) {
    return 'I chose "${explanation.decision}" based on ${explanation.reasoning} '
           '(${(explanation.confidence * 100).toStringAsFixed(0)}% confidence).';
  }

  String _generateMinimalExplanation(AIDecisionExplanation explanation) {
    return explanation.reasoning;
  }

  /// Dispose resources
  void dispose() {
    _logStreamController.close();
  }
}

// Data models for AI transparency

enum DecisionStatus { started, completed, error }
enum TransparencyLevel { low, medium, high }

class AIDecisionLog {
  final String traceId;
  final String operationType;
  final DateTime timestamp;
  final DecisionStatus status;
  final String? decision;
  final String? reasoning;
  final double? confidence;
  final String? error;
  final Map<String, dynamic>? metadata;
  final List<String>? alternativesConsidered;
  final List<ReasoningStep> reasoningSteps;

  const AIDecisionLog({
    required this.traceId,
    required this.operationType,
    required this.timestamp,
    required this.status,
    this.decision,
    this.reasoning,
    this.confidence,
    this.error,
    this.metadata,
    this.alternativesConsidered,
    this.reasoningSteps = const [],
  });

  AIDecisionLog copyWith({
    String? traceId,
    String? operationType,
    DateTime? timestamp,
    DecisionStatus? status,
    String? decision,
    String? reasoning,
    double? confidence,
    String? error,
    Map<String, dynamic>? metadata,
    List<String>? alternativesConsidered,
    List<ReasoningStep>? reasoningSteps,
  }) {
    return AIDecisionLog(
      traceId: traceId ?? this.traceId,
      operationType: operationType ?? this.operationType,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      decision: decision ?? this.decision,
      reasoning: reasoning ?? this.reasoning,
      confidence: confidence ?? this.confidence,
      error: error ?? this.error,
      metadata: metadata ?? this.metadata,
      alternativesConsidered: alternativesConsidered ?? this.alternativesConsidered,
      reasoningSteps: reasoningSteps ?? this.reasoningSteps,
    );
  }
}

class ReasoningStep {
  final String step;
  final String reasoning;
  final DateTime timestamp;
  final Map<String, dynamic>? data;

  const ReasoningStep({
    required this.step,
    required this.reasoning,
    required this.timestamp,
    this.data,
  });
}

class AIDecisionExplanation {
  final String decision;
  final String reasoning;
  final double confidence;
  final List<String> factors;
  final List<String> alternatives;
  final DateTime timestamp;
  final TransparencyLevel transparencyLevel;

  const AIDecisionExplanation({
    required this.decision,
    required this.reasoning,
    required this.confidence,
    required this.factors,
    required this.alternatives,
    required this.timestamp,
    required this.transparencyLevel,
  });
}

class TransparencyReport {
  final int totalDecisions;
  final int completedDecisions;
  final int erroredDecisions;
  final double averageConfidence;
  final Map<String, int> operationBreakdown;
  final Map<String, int> confidenceDistribution;
  final DateRange period;

  const TransparencyReport({
    required this.totalDecisions,
    required this.completedDecisions,
    required this.erroredDecisions,
    required this.averageConfidence,
    required this.operationBreakdown,
    required this.confidenceDistribution,
    required this.period,
  });

  double get successRate => 
      totalDecisions > 0 ? completedDecisions / totalDecisions : 0.0;

  double get errorRate => 
      totalDecisions > 0 ? erroredDecisions / totalDecisions : 0.0;
}

class DateRange {
  final DateTime start;
  final DateTime end;

  const DateRange({
    required this.start,
    required this.end,
  });

  Duration get duration => end.difference(start);
}