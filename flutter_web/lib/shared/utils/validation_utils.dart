// lib/shared/utils/validation_utils.dart
// Validation utilities for forms and user input
// Provides consistent validation rules across the application

/// Comprehensive validation utilities for ArionComply forms
class ValidationUtils {
  // Private constructor to prevent instantiation
  ValidationUtils._();

  // Static regex patterns for validation
  static final RegExp _emailRegExp = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  static final RegExp _phoneRegExp = RegExp(
    r'^\+?[\d\s\-\(\)]{10,}$',
  );

  static final RegExp _urlRegExp = RegExp(
    r'^https?://[^\s/$.?#].[^\s]*$',
    caseSensitive: false,
  );

  static final RegExp _nameRegExp = RegExp(
    r'^[a-zA-Z\s\-\.\']{2,50}$',
  );

  static final RegExp _companyNameRegExp = RegExp(
    r'^[a-zA-Z0-9\s\-\.,&\']{2,100}$',
  );

  static final RegExp _passwordRegExp = RegExp(
    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$',
  );

  // Email validation
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }

    final trimmedValue = value.trim();
    
    if (trimmedValue.length > 254) {
      return 'Email is too long';
    }

    if (!_emailRegExp.hasMatch(trimmedValue)) {
      return 'Please enter a valid email address';
    }

    // Check for common email issues
    if (trimmedValue.contains('..') || 
        trimmedValue.startsWith('.') || 
        trimmedValue.endsWith('.')) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  // Phone number validation
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }

    final trimmedValue = value.trim();
    
    // Remove all non-digit characters for length check
    final digitsOnly = trimmedValue.replaceAll(RegExp(r'[^\d]'), '');
    
    if (digitsOnly.length < 10) {
      return 'Phone number must be at least 10 digits';
    }

    if (digitsOnly.length > 15) {
      return 'Phone number is too long';
    }

    if (!_phoneRegExp.hasMatch(trimmedValue)) {
      return 'Please enter a valid phone number';
    }

    return null;
  }

  // URL validation
  static String? validateUrl(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'URL is required';
    }

    final trimmedValue = value.trim();
    
    if (!_urlRegExp.hasMatch(trimmedValue)) {
      return 'Please enter a valid URL (must start with http:// or https://)';
    }

    return null;
  }

  // Name validation (first name, last name)
  static String? validateName(String? value, {String fieldName = 'Name'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }

    final trimmedValue = value.trim();
    
    if (trimmedValue.length < 2) {
      return '$fieldName must be at least 2 characters';
    }

    if (trimmedValue.length > 50) {
      return '$fieldName must be less than 50 characters';
    }

    if (!_nameRegExp.hasMatch(trimmedValue)) {
      return '$fieldName contains invalid characters';
    }

    // Check for numbers in name
    if (RegExp(r'\d').hasMatch(trimmedValue)) {
      return '$fieldName cannot contain numbers';
    }

    return null;
  }

  // Company name validation
  static String? validateCompanyName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Company name is required';
    }

    final trimmedValue = value.trim();
    
    if (trimmedValue.length < 2) {
      return 'Company name must be at least 2 characters';
    }

    if (trimmedValue.length > 100) {
      return 'Company name must be less than 100 characters';
    }

    if (!_companyNameRegExp.hasMatch(trimmedValue)) {
      return 'Company name contains invalid characters';
    }

    return null;
  }

  // Password validation
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }

    if (value.length > 128) {
      return 'Password is too long';
    }

    if (!_passwordRegExp.hasMatch(value)) {
      return 'Password must contain at least one uppercase letter, one lowercase letter, one number, and one special character';
    }

    return null;
  }

  // Confirm password validation
  static String? validateConfirmPassword(String? value, String? originalPassword) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }

    if (value != originalPassword) {
      return 'Passwords do not match';
    }

    return null;
  }

  // Required field validation
  static String? validateRequired(String? value, {String fieldName = 'Field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  // Minimum length validation
  static String? validateMinLength(String? value, int minLength, {String fieldName = 'Field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }

    if (value.trim().length < minLength) {
      return '$fieldName must be at least $minLength characters';
    }

    return null;
  }

  // Maximum length validation
  static String? validateMaxLength(String? value, int maxLength, {String fieldName = 'Field'}) {
    if (value != null && value.length > maxLength) {
      return '$fieldName must be less than $maxLength characters';
    }
    return null;
  }

  // Numeric validation
  static String? validateNumeric(String? value, {String fieldName = 'Field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }

    final numericValue = double.tryParse(value.trim());
    if (numericValue == null) {
      return '$fieldName must be a valid number';
    }

    return null;
  }

  // Positive number validation
  static String? validatePositiveNumber(String? value, {String fieldName = 'Field'}) {
    final numericValidation = validateNumeric(value, fieldName: fieldName);
    if (numericValidation != null) {
      return numericValidation;
    }

    final numericValue = double.parse(value!.trim());
    if (numericValue <= 0) {
      return '$fieldName must be a positive number';
    }

    return null;
  }

  // Industry validation (for compliance context)
  static String? validateIndustry(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Industry is required';
    }

    final validIndustries = [
      'Technology',
      'Healthcare',
      'Financial Services',
      'Manufacturing',
      'Education',
      'Government',
      'Retail',
      'Professional Services',
      'Non-profit',
      'Other',
    ];

    if (!validIndustries.contains(value.trim())) {
      return 'Please select a valid industry';
    }

    return null;
  }

  // Framework validation (for compliance frameworks)
  static String? validateFramework(List<String>? frameworks) {
    if (frameworks == null || frameworks.isEmpty) {
      return 'Please select at least one compliance framework';
    }

    final validFrameworks = [
      'SOC 2',
      'ISO 27001',
      'GDPR',
      'HIPAA',
      'PCI DSS',
      'NIST',
      'FedRAMP',
      'SOX',
    ];

    for (final framework in frameworks) {
      if (!validFrameworks.contains(framework)) {
        return 'Invalid framework selected: $framework';
      }
    }

    return null;
  }

  // Combined validation for contact forms
  static Map<String, String?> validateContactForm({
    required String? firstName,
    required String? lastName,
    required String? email,
    required String? companyName,
    String? phone,
    String? industry,
  }) {
    return {
      'firstName': validateName(firstName, fieldName: 'First name'),
      'lastName': validateName(lastName, fieldName: 'Last name'),
      'email': validateEmail(email),
      'companyName': validateCompanyName(companyName),
      'phone': phone != null && phone.isNotEmpty ? validatePhone(phone) : null,
      'industry': industry != null && industry.isNotEmpty ? validateIndustry(industry) : null,
    };
  }

  // Combined validation for registration forms
  static Map<String, String?> validateRegistrationForm({
    required String? firstName,
    required String? lastName,
    required String? email,
    required String? password,
    required String? confirmPassword,
    required String? companyName,
    String? industry,
    List<String>? frameworks,
  }) {
    return {
      'firstName': validateName(firstName, fieldName: 'First name'),
      'lastName': validateName(lastName, fieldName: 'Last name'),
      'email': validateEmail(email),
      'password': validatePassword(password),
      'confirmPassword': validateConfirmPassword(confirmPassword, password),
      'companyName': validateCompanyName(companyName),
      'industry': industry != null ? validateIndustry(industry) : null,
      'frameworks': frameworks != null ? validateFramework(frameworks) : null,
    };
  }

  // Utility method to check if form is valid
  static bool isFormValid(Map<String, String?> validationResults) {
    return validationResults.values.every((error) => error == null);
  }

  // Utility method to get first error from validation results
  static String? getFirstError(Map<String, String?> validationResults) {
    for (final error in validationResults.values) {
      if (error != null) {
        return error;
      }
    }
    return null;
  }
}