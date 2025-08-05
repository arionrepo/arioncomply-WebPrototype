// FILE PATH: lib/shared/utils/validation_utils.dart
// ValidationUtils - Fixed syntax errors and proper class structure

class ValidationUtils {
  // Email validation regex
  static final RegExp _emailRegExp = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  // Phone validation regex
  static final RegExp _phoneRegExp = RegExp(
    r'^\+?[1-9]\d{1,14}$',
  );

  // URL validation regex
  static final RegExp _urlRegExp = RegExp(
    r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
  );

  /// Validates email format
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    
    if (!_emailRegExp.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    
    return null;
  }

  /// Validates phone number format
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    
    if (!_phoneRegExp.hasMatch(value)) {
      return 'Please enter a valid phone number';
    }
    
    return null;
  }

  /// Validates URL format
  static String? validateUrl(String? value) {
    if (value == null || value.isEmpty) {
      return 'URL is required';
    }
    
    if (!_urlRegExp.hasMatch(value)) {
      return 'Please enter a valid URL';
    }
    
    return null;
  }

  /// Validates required field
  static String? validateRequired(String? value, [String? fieldName]) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }
    return null;
  }

  /// Validates minimum length
  static String? validateMinLength(String? value, int minLength, [String? fieldName]) {
    if (value == null || value.length < minLength) {
      return '${fieldName ?? 'This field'} must be at least $minLength characters';
    }
    return null;
  }

  /// Validates maximum length
  static String? validateMaxLength(String? value, int maxLength, [String? fieldName]) {
    if (value != null && value.length > maxLength) {
      return '${fieldName ?? 'This field'} must not exceed $maxLength characters';
    }
    return null;
  }

  /// Validates name (only letters and spaces)
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
      return 'Name can only contain letters and spaces';
    }
    
    return null;
  }

  /// Validates company name
  static String? validateCompanyName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Company name is required';
    }
    
    if (value.length < 2) {
      return 'Company name must be at least 2 characters';
    }
    
    return null;
  }

  /// Validates password strength
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    
    if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(value)) {
      return 'Password must contain at least one uppercase letter, one lowercase letter, and one number';
    }
    
    return null;
  }

  /// Validates confirm password
  static String? validateConfirmPassword(String? value, String? originalPassword) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    
    if (value != originalPassword) {
      return 'Passwords do not match';
    }
    
    return null;
  }

  /// Combined validation for forms
  static String? validateField(String? value, {
    bool required = false,
    int? minLength,
    int? maxLength,
    String? fieldName,
    String? pattern,
  }) {
    if (required) {
      final requiredError = validateRequired(value, fieldName);
      if (requiredError != null) return requiredError;
    }
    
    if (value != null && value.isNotEmpty) {
      if (minLength != null) {
        final minError = validateMinLength(value, minLength, fieldName);
        if (minError != null) return minError;
      }
      
      if (maxLength != null) {
        final maxError = validateMaxLength(value, maxLength, fieldName);
        if (maxError != null) return maxError;
      }
      
      if (pattern != null) {
        if (!RegExp(pattern).hasMatch(value)) {
          return '${fieldName ?? 'This field'} format is invalid';
        }
      }
    }
    
    return null;
  }
}