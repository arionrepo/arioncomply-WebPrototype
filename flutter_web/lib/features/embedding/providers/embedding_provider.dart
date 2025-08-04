// FILE PATH: lib/features/embedding/providers/embedding_provider.dart
// Embedding Provider - State management for marketing widget embedding
// Referenced in embedded_widget_screen.dart for embedding functionality

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';

import '../../../core/services/storage_service.dart';

/// Embedding state for marketing widgets
class EmbeddingState {
  final bool showLeadCapture;
  final bool hasInteracted;
  final String? source;
  final String? framework;
  final bool isMinimal;
  final Map<String, dynamic> analyticsData;
  final DateTime? firstInteraction;
  final DateTime? lastActivity;

  const EmbeddingState({
    this.showLeadCapture = false,
    this.hasInteracted = false,
    this.source,
    this.framework,
    this.isMinimal = false,
    this.analyticsData = const {},
    this.firstInteraction,
    this.lastActivity,
  });

  EmbeddingState copyWith({
    bool? showLeadCapture,
    bool? hasInteracted,
    String? source,
    String? framework,
    bool? isMinimal,
    Map<String, dynamic>? analyticsData,
    DateTime? firstInteraction,
    DateTime? lastActivity,
  }) {
    return EmbeddingState(
      showLeadCapture: showLeadCapture ?? this.showLeadCapture,
      hasInteracted: hasInteracted ?? this.hasInteracted,
      source: source ?? this.source,
      framework: framework ?? this.framework,
      isMinimal: isMinimal ?? this.isMinimal,
      analyticsData: analyticsData ?? this.analyticsData,
      firstInteraction: firstInteraction ?? this.firstInteraction,
      lastActivity: lastActivity ?? this.lastActivity,
    );
  }

  /// Get engagement score (0.0 to 1.0)
  double get engagementScore {
    double score = 0.0;
    
    if (hasInteracted) score += 0.3;
    if (firstInteraction != null) {
      final duration = DateTime.now().difference(firstInteraction!);
      if (duration.inMinutes > 1) score += 0.2;
      if (duration.inMinutes > 5) score += 0.3;
    }
    if (analyticsData.isNotEmpty) score += 0.2;
    
    return score.clamp(0.0, 1.0);
  }

  /// Check if user is qualified for lead capture
  bool get isQualifiedLead => engagementScore >= 0.5;
}

/// Embedding state notifier for marketing widgets
class EmbeddingNotifier extends StateNotifier<EmbeddingState> {
  final StorageService _storageService;

  EmbeddingNotifier(this._storageService) : super(const EmbeddingState());

  /// Track embedding load event
  void trackEmbedLoad({
    String? framework,
    String? source,
    bool minimal = false,
  }) {
    state = state.copyWith(
      framework: framework,
      source: source,
      isMinimal: minimal,
      lastActivity: DateTime.now(),
      analyticsData: {
        ...state.analyticsData,
        'load_time': DateTime.now().toIso8601String(),
        'framework': framework,
        'source': source,
        'minimal': minimal,
      },
    );

    _logAnalyticsEvent('embed_loaded', {
      'framework': framework,
      'source': source,
      'minimal': minimal,
    });

    if (kDebugMode) {
      print('📊 Embed loaded: $framework from $source (minimal: $minimal)');
    }
  }

  /// Track first user interaction
  void trackFirstInteraction() {
    if (state.hasInteracted) return;

    state = state.copyWith(
      hasInteracted: true,
      firstInteraction: DateTime.now(),
      lastActivity: DateTime.now(),
      analyticsData: {
        ...state.analyticsData,
        'first_interaction': DateTime.now().toIso8601String(),
      },
    );

    _logAnalyticsEvent('first_interaction', {
      'framework': state.framework,
      'source': state.source,
    });

    if (kDebugMode) {
      print('👆 First interaction tracked');
    }
  }

  /// Track branding click (opens full app)
  void trackBrandingClick() {
    state = state.copyWith(
      lastActivity: DateTime.now(),
      analyticsData: {
        ...state.analyticsData,
        'branding_click': DateTime.now().toIso8601String(),
      },
    );

    _logAnalyticsEvent('branding_clicked', {
      'framework': state.framework,
      'source': state.source,
    });

    if (kDebugMode) {
      print('🔗 Branding click tracked');
    }
  }

  /// Track embed completion
  void trackEmbedComplete(Map<String, dynamic> result) {
    state = state.copyWith(
      lastActivity: DateTime.now(),
      analyticsData: {
        ...state.analyticsData,
        'embed_completed': DateTime.now().toIso8601String(),
        'completion_result': result,
      },
    );

    _logAnalyticsEvent('embed_completed', {
      'framework': state.framework,
      'source': state.source,
      'result': result,
    });

    if (kDebugMode) {
      print('✅ Embed completion tracked: $result');
    }
  }

  /// Show lead capture form
  void showLeadCapture() {
    if (!state.isQualifiedLead) {
      if (kDebugMode) {
        print('⚠️ User not qualified for lead capture (score: ${state.engagementScore})');
      }
      return;
    }

    state = state.copyWith(
      showLeadCapture: true,
      lastActivity: DateTime.now(),
      analyticsData: {
        ...state.analyticsData,
        'lead_capture_shown': DateTime.now().toIso8601String(),
        'engagement_score': state.engagementScore,
      },
    );

    _logAnalyticsEvent('lead_capture_shown', {
      'framework': state.framework,
      'source': state.source,
      'engagement_score': state.engagementScore,
    });

    if (kDebugMode) {
      print('💼 Lead capture shown (score: ${state.engagementScore})');
    }
  }

  /// Submit lead information
  Future<void> submitLead(Map<String, dynamic> leadData) async {
    try {
      // Save lead data locally
      await _storageService.saveDemoData('lead_data', {
        ...leadData,
        'framework': state.framework,
        'source': state.source,
        'engagement_score': state.engagementScore,
        'submitted_at': DateTime.now().toIso8601String(),
      });

      state = state.copyWith(
        lastActivity: DateTime.now(),
        analyticsData: {
          ...state.analyticsData,
          'lead_submitted': DateTime.now().toIso8601String(),
          'lead_data': leadData,
        },
      );

      _logAnalyticsEvent('lead_submitted', {
        'framework': state.framework,
        'source': state.source,
        'email': leadData['email'],
        'company': leadData['company'],
      });

      if (kDebugMode) {
        print('💼 Lead submitted: ${leadData['email']}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error submitting lead: $e');
      }
    }
  }

  /// Skip lead capture
  void skipLeadCapture() {
    state = state.copyWith(
      showLeadCapture: false,
      lastActivity: DateTime.now(),
      analyticsData: {
        ...state.analyticsData,
        'lead_capture_skipped': DateTime.now().toIso8601String(),
      },
    );

    _logAnalyticsEvent('lead_capture_skipped', {
      'framework': state.framework,
      'source': state.source,
    });

    if (kDebugMode) {
      print('🚫 Lead capture skipped');
    }
  }

  /// Track custom event
  void trackCustomEvent(String eventName, Map<String, dynamic> data) {
    state = state.copyWith(
      lastActivity: DateTime.now(),
      analyticsData: {
        ...state.analyticsData,
        eventName: {
          'timestamp': DateTime.now().toIso8601String(),
          'data': data,
        },
      },
    );

    _logAnalyticsEvent(eventName, {
      'framework': state.framework,
      'source': state.source,
      ...data,
    });

    if (kDebugMode) {
      print('📊 Custom event tracked: $eventName');
    }
  }

  /// Get analytics summary for reporting
  Map<String, dynamic> getAnalyticsSummary() {
    final now = DateTime.now();
    final sessionDuration = state.firstInteraction != null
        ? now.difference(state.firstInteraction!)
        : const Duration();

    return {
      'framework': state.framework,
      'source': state.source,
      'is_minimal': state.isMinimal,
      'has_interacted': state.hasInteracted,
      'show_lead_capture': state.showLeadCapture,
      'engagement_score': state.engagementScore,
      'session_duration_minutes': sessionDuration.inMinutes,
      'first_interaction': state.firstInteraction?.toIso8601String(),
      'last_activity': state.lastActivity?.toIso8601String(),
      'total_events': state.analyticsData.length,
      'is_qualified_lead': state.isQualifiedLead,
    };
  }

  /// Export analytics data for external systems
  Future<Map<String, dynamic>> exportAnalyticsData() async {
    try {
      final summary = getAnalyticsSummary();
      
      // Save analytics summary
      await _storageService.saveDemoData('analytics_summary', summary);
      
      return {
        'summary': summary,
        'events': state.analyticsData,
        'exported_at': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error exporting analytics: $e');
      }
      return {};
    }
  }

  // Private helper methods

  void _logAnalyticsEvent(String eventName, Map<String, dynamic> data) {
    if (kDebugMode) {
      print('📊 Analytics Event: $eventName');
      print('   Data: $data');
    }
    
    // In production, this would send to analytics service
    // For demo, we just log locally
  }
}

/// Provider for embedding state
final embeddingProvider = StateNotifierProvider<EmbeddingNotifier, EmbeddingState>((ref) {
  return EmbeddingNotifier(StorageService.instance);
});

/// Provider for checking if lead capture should be shown
final shouldShowLeadCaptureProvider = Provider<bool>((ref) {
  final embedding = ref.watch(embeddingProvider);
  return embedding.showLeadCapture && embedding.isQualifiedLead;
});

/// Provider for engagement score
final engagementScoreProvider = Provider<double>((ref) {
  final embedding = ref.watch(embeddingProvider);
  return embedding.engagementScore;
});

/// Provider for analytics summary
final analyticsSummaryProvider = Provider<Map<String, dynamic>>((ref) {
  final embedding = ref.watch(embeddingProvider);
  return ref.read(embeddingProvider.notifier).getAnalyticsSummary();
});