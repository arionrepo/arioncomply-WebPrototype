// FILE PATH: lib/core/services/storage_service.dart
// Storage Service - Local data persistence for conversation context and user preferences
// Referenced in main.dart for demo data persistence

import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/avatar/models/conversation_context.dart';
import '../../features/avatar/models/expert_personality.dart';

/// Local storage service for conversation context and user data
/// Uses SharedPreferences for web/mobile compatibility
class StorageService {
  static StorageService? _instance;
  static StorageService get instance => _instance ??= StorageService._();
  StorageService._();

  SharedPreferences? _prefs;
  bool _initialized = false;

  // Storage keys
  static const String _conversationContextKey = 'conversation_context';
  static const String _userPreferencesKey = 'user_preferences';
  static const String _expertPersonalityKey = 'expert_personality';
  static const String _conversationHistoryKey = 'conversation_history';
  static const String _appSettingsKey = 'app_settings';
  static const String _demoDataKey = 'demo_data';

  /// Initialize storage service
  static Future<void> initialize() async {
    await instance._initialize();
  }

  Future<void> _initialize() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      _initialized = true;
      
      if (kDebugMode) {
        print('💾 Storage service initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Storage service initialization error: $e');
      }
      rethrow;
    }
  }

  /// Ensure service is initialized
  void _ensureInitialized() {
    if (!_initialized || _prefs == null) {
      throw StateError('StorageService not initialized. Call StorageService.initialize() first.');
    }
  }

  // Conversation Context Management

  /// Save conversation context
  Future<bool> saveConversationContext(ConversationContext context) async {
    _ensureInitialized();
    
    try {
      final json = jsonEncode(context.toJson());
      final success = await _prefs!.setString(_conversationContextKey, json);
      
      if (kDebugMode) {
        print('💾 Conversation context saved: ${context.userName ?? "anonymous"}');
      }
      
      return success;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error saving conversation context: $e');
      }
      return false;
    }
  }

  /// Load conversation context
  Future<ConversationContext?> loadConversationContext() async {
    _ensureInitialized();
    
    try {
      final jsonString = _prefs!.getString(_conversationContextKey);
      if (jsonString == null) return null;
      
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      final context = ConversationContext.fromJson(json);
      
      if (kDebugMode) {
        print('💾 Conversation context loaded: ${context.userName ?? "anonymous"}');
      }
      
      return context;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error loading conversation context: $e');
      }
      return null;
    }
  }

  /// Clear conversation context
  Future<bool> clearConversationContext() async {
    _ensureInitialized();
    
    try {
      final success = await _prefs!.remove(_conversationContextKey);
      
      if (kDebugMode) {
        print('💾 Conversation context cleared');
      }
      
      return success;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error clearing conversation context: $e');
      }
      return false;
    }
  }

  // Expert Personality Management

  /// Save expert personality preferences
  Future<bool> saveExpertPersonality(ExpertPersonalityType personalityType) async {
    _ensureInitialized();
    
    try {
      final success = await _prefs!.setString(_expertPersonalityKey, personalityType.toString());
      
      if (kDebugMode) {
        print('💾 Expert personality saved: $personalityType');
      }
      
      return success;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error saving expert personality: $e');
      }
      return false;
    }
  }

  /// Load expert personality preferences
  Future<ExpertPersonalityType?> loadExpertPersonality() async {
    _ensureInitialized();
    
    try {
      final personalityString = _prefs!.getString(_expertPersonalityKey);
      if (personalityString == null) return null;
      
      final personality = ExpertPersonalityType.values.firstWhere(
        (p) => p.toString() == personalityString,
        orElse: () => ExpertPersonalityType.professional,
      );
      
      if (kDebugMode) {
        print('💾 Expert personality loaded: $personality');
      }
      
      return personality;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error loading expert personality: $e');
      }
      return null;
    }
  }

  // User Preferences Management

  /// Save user preferences
  Future<bool> saveUserPreferences(Map<String, dynamic> preferences) async {
    _ensureInitialized();
    
    try {
      final json = jsonEncode(preferences);
      final success = await _prefs!.setString(_userPreferencesKey, json);
      
      if (kDebugMode) {
        print('💾 User preferences saved: ${preferences.keys.length} settings');
      }
      
      return success;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error saving user preferences: $e');
      }
      return false;
    }
  }

  /// Load user preferences
  Future<Map<String, dynamic>> loadUserPreferences() async {
    _ensureInitialized();
    
    try {
      final jsonString = _prefs!.getString(_userPreferencesKey);
      if (jsonString == null) return {};
      
      final preferences = Map<String, dynamic>.from(jsonDecode(jsonString));
      
      if (kDebugMode) {
        print('💾 User preferences loaded: ${preferences.keys.length} settings');
      }
      
      return preferences;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error loading user preferences: $e');
      }
      return {};
    }
  }

  /// Update specific user preference
  Future<bool> updateUserPreference(String key, dynamic value) async {
    final preferences = await loadUserPreferences();
    preferences[key] = value;
    return await saveUserPreferences(preferences);
  }

  // Conversation History Management

  /// Save conversation history
  Future<bool> saveConversationHistory(List<Map<String, dynamic>> messages) async {
    _ensureInitialized();
    
    try {
      final json = jsonEncode(messages);
      final success = await _prefs!.setString(_conversationHistoryKey, json);
      
      if (kDebugMode) {
        print('💾 Conversation history saved: ${messages.length} messages');
      }
      
      return success;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error saving conversation history: $e');
      }
      return false;
    }
  }

  /// Load conversation history
  Future<List<Map<String, dynamic>>> loadConversationHistory() async {
    _ensureInitialized();
    
    try {
      final jsonString = _prefs!.getString(_conversationHistoryKey);
      if (jsonString == null) return [];
      
      final List<dynamic> jsonList = jsonDecode(jsonString);
      final messages = jsonList.map((m) => Map<String, dynamic>.from(m)).toList();
      
      if (kDebugMode) {
        print('💾 Conversation history loaded: ${messages.length} messages');
      }
      
      return messages;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error loading conversation history: $e');
      }
      return [];
    }
  }

  /// Clear conversation history
  Future<bool> clearConversationHistory() async {
    _ensureInitialized();
    
    try {
      final success = await _prefs!.remove(_conversationHistoryKey);
      
      if (kDebugMode) {
        print('💾 Conversation history cleared');
      }
      
      return success;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error clearing conversation history: $e');
      }
      return false;
    }
  }

  // App Settings Management

  /// Save app settings
  Future<bool> saveAppSettings(Map<String, dynamic> settings) async {
    _ensureInitialized();
    
    try {
      final json = jsonEncode(settings);
      final success = await _prefs!.setString(_appSettingsKey, json);
      
      if (kDebugMode) {
        print('💾 App settings saved: ${settings.keys.length} settings');
      }
      
      return success;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error saving app settings: $e');
      }
      return false;
    }
  }

  /// Load app settings
  Future<Map<String, dynamic>> loadAppSettings() async {
    _ensureInitialized();
    
    try {
      final jsonString = _prefs!.getString(_appSettingsKey);
      if (jsonString == null) return {};
      
      final settings = Map<String, dynamic>.from(jsonDecode(jsonString));
      
      if (kDebugMode) {
        print('💾 App settings loaded: ${settings.keys.length} settings');
      }
      
      return settings;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error loading app settings: $e');
      }
      return {};
    }
  }

  // Demo Data Management

  /// Save demo data
  Future<bool> saveDemoData(String key, Map<String, dynamic> data) async {
    _ensureInitialized();
    
    try {
      final demoData = await loadAllDemoData();
      demoData[key] = data;
      
      final json = jsonEncode(demoData);
      final success = await _prefs!.setString(_demoDataKey, json);
      
      if (kDebugMode) {
        print('💾 Demo data saved: $key');
      }
      
      return success;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error saving demo data: $e');
      }
      return false;
    }
  }

  /// Load specific demo data
  Future<Map<String, dynamic>?> loadDemoData(String key) async {
    _ensureInitialized();
    
    try {
      final allDemoData = await loadAllDemoData();
      final data = allDemoData[key];
      
      if (kDebugMode && data != null) {
        print('💾 Demo data loaded: $key');
      }
      
      return data != null ? Map<String, dynamic>.from(data) : null;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error loading demo data: $e');
      }
      return null;
    }
  }

  /// Load all demo data
  Future<Map<String, dynamic>> loadAllDemoData() async {
    _ensureInitialized();
    
    try {
      final jsonString = _prefs!.getString(_demoDataKey);
      if (jsonString == null) return {};
      
      return Map<String, dynamic>.from(jsonDecode(jsonString));
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error loading all demo data: $e');
      }
      return {};
    }
  }

  // Utility Methods

  /// Get all stored keys for debugging
  Set<String> getAllKeys() {
    _ensureInitialized();
    return _prefs!.getKeys();
  }

  /// Clear all stored data
  Future<bool> clearAllData() async {
    _ensureInitialized();
    
    try {
      final success = await _prefs!.clear();
      
      if (kDebugMode) {
        print('💾 All stored data cleared');
      }
      
      return success;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error clearing all data: $e');
      }
      return false;
    }
  }

  /// Get storage usage statistics
  Future<StorageStats> getStorageStats() async {
    _ensureInitialized();
    
    final keys = _prefs!.getKeys();
    int totalSize = 0;
    final categorySizes = <String, int>{};
    
    for (final key in keys) {
      final value = _prefs!.get(key);
      final size = value.toString().length;
      totalSize += size;
      
      // Categorize by key prefix
      final category = _getCategoryForKey(key);
      categorySizes[category] = (categorySizes[category] ?? 0) + size;
    }
    
    return StorageStats(
      totalKeys: keys.length,
      totalSize: totalSize,
      categorySizes: categorySizes,
    );
  }

  String _getCategoryForKey(String key) {
    if (key.contains('conversation')) return 'Conversations';
    if (key.contains('user') || key.contains('preferences')) return 'User Data';
    if (key.contains('demo')) return 'Demo Data';
    if (key.contains('settings')) return 'Settings';
    return 'Other';
  }
}

/// Storage usage statistics
class StorageStats {
  final int totalKeys;
  final int totalSize;
  final Map<String, int> categorySizes;

  const StorageStats({
    required this.totalKeys,
    required this.totalSize,
    required this.categorySizes,
  });

  @override
  String toString() {
    return 'StorageStats(keys: $totalKeys, size: ${totalSize}B, categories: $categorySizes)';
  }
}