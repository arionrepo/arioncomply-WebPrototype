// FILE PATH: lib/shared/utils/date_utils.dart
// Date Utilities - Timestamp formatting and date handling
// Referenced in conversation_history.dart and other components

import 'package:intl/intl.dart';

class DateUtils {
  // Common date formatters
  static final DateFormat _timeFormat = DateFormat('h:mm a');
  static final DateFormat _dateFormat = DateFormat('MMM d');
  static final DateFormat _fullDateFormat = DateFormat('MMM d, yyyy');
  static final DateFormat _timestampFormat = DateFormat('MMM d, h:mm a');
  static final DateFormat _isoFormat = DateFormat('yyyy-MM-ddTHH:mm:ss');

  /// Format time for conversation messages (e.g., "2:30 PM")
  static String formatMessageTime(DateTime dateTime) {
    return _timeFormat.format(dateTime);
  }

  /// Format date for conversation grouping (e.g., "Dec 15")
  static String formatMessageDate(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
    
    if (messageDate == today) {
      return 'Today';
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else if (now.difference(messageDate).inDays < 7) {
      return DateFormat('EEEE').format(dateTime); // Day of week
    } else {
      return _dateFormat.format(dateTime);
    }
  }

  /// Format full timestamp for conversation headers (e.g., "Dec 15, 2:30 PM")
  static String formatConversationTimestamp(DateTime dateTime) {
    return _timestampFormat.format(dateTime);
  }

  /// Format date for avatar status (e.g., "Dec 15, 2024")
  static String formatFullDate(DateTime dateTime) {
    return _fullDateFormat.format(dateTime);
  }

  /// Format duration for session length (e.g., "5 minutes", "1 hour 30 minutes")
  static String formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      final hours = duration.inHours;
      final minutes = duration.inMinutes.remainder(60);
      if (minutes > 0) {
        return '$hours hour${hours > 1 ? 's' : ''} $minutes minute${minutes > 1 ? 's' : ''}';
      } else {
        return '$hours hour${hours > 1 ? 's' : ''}';
      }
    } else if (duration.inMinutes > 0) {
      final minutes = duration.inMinutes;
      return '$minutes minute${minutes > 1 ? 's' : ''}';
    } else {
      final seconds = duration.inSeconds;
      return '$seconds second${seconds > 1 ? 's' : ''}';
    }
  }

  /// Format time ago (e.g., "2 minutes ago", "1 hour ago", "3 days ago")
  static String formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} days ago';
      } else {
        return _dateFormat.format(dateTime);
      }
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  /// Check if two dates are on the same day
  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  /// Check if date is today
  static bool isToday(DateTime date) {
    return isSameDay(date, DateTime.now());
  }

  /// Check if date is yesterday
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return isSameDay(date, yesterday);
  }

  /// Get start of day
  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Get end of day
  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }

  /// Format ISO string for API/storage
  static String formatIsoString(DateTime dateTime) {
    return _isoFormat.format(dateTime);
  }

  /// Parse ISO string from API/storage
  static DateTime? parseIsoString(String? isoString) {
    if (isoString == null || isoString.isEmpty) return null;
    
    try {
      return DateTime.parse(isoString);
    } catch (e) {
      return null;
    }
  }

  /// Get relative date for conversation contexts
  static String getRelativeDate(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years year${years > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months month${months > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  /// Format session duration for analytics
  static String formatSessionDuration(DateTime start, DateTime? end) {
    final endTime = end ?? DateTime.now();
    final duration = endTime.difference(start);
    
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes.remainder(60)}m';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m';
    } else {
      return '${duration.inSeconds}s';
    }
  }

  /// Get greeting based on time of day
  static String getTimeBasedGreeting() {
    final hour = DateTime.now().hour;
    
    if (hour < 12) {
      return 'Good morning';
    } else if (hour < 17) {
      return 'Good afternoon';
    } else if (hour < 21) {
      return 'Good evening';
    } else {
      return 'Good night';
    }
  }

  /// Check if timestamp should show in conversation
  static bool shouldShowTimestamp(DateTime current, DateTime? previous) {
    if (previous == null) return true;
    
    // Show timestamp if more than 5 minutes apart
    return current.difference(previous).inMinutes >= 5;
  }

  /// Format for conversation grouping header
  static String formatConversationGroup(DateTime dateTime) {
    final now = DateTime.now();
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
    final today = DateTime(now.year, now.month, now.day);
    
    if (messageDate == today) {
      return 'Today';
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else if (now.difference(messageDate).inDays < 7) {
      return DateFormat('EEEE, MMM d').format(dateTime);
    } else if (dateTime.year == now.year) {
      return DateFormat('EEEE, MMM d').format(dateTime);
    } else {
      return DateFormat('EEEE, MMM d, yyyy').format(dateTime);
    }
  }
}