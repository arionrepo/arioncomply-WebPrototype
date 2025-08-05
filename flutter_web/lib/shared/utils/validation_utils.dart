// FILE PATH: lib/shared/utils/validation_utils.dart
// Validation Utilities - Form validation and input sanitization
// Referenced in lead capture forms and user input components

class ValidationUtils {
  // Regular expressions for validation
  static final RegExp _emailRegExp = RegExp(
    r'^[a-zA-Z0-9.!#$%&'"'"'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$',
  );
  
  static final RegExp _phoneRegExp = RegExp(
    r'^\+?[\d\s\-\(\)\.]{10,}$',
  );
  
  static final RegExp _urlRegExp = RegExp(
    r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
  );

  /// Validate email address
  static String? validateEmail(String? email) {
    if (email == null || email.trim().isEmpty) {
      return 'Email is required';
    }
    
    final trimmedEmail = email.trim();
    
    if (!_emailRegExp.hasMatch(trimmedEmail)) {
      return 'Please enter a valid email address';
    }
    
    if (trimmedEmail.length > 254) {
      return 'Email address is too long';
    }
    
    return null; // Valid
  }

  /// Validate company name
  static String? validateCompanyName(String? companyName) {
    if (companyName == null || companyName.trim().isEmpty) {
      return 'Company name is required';
    }
    
    final trimmed = companyName.trim();
    
    if (trimmed.length < 2) {
      return 'Company name must be at least 2 characters';
    }
    
    if (trimmed.length > 100) {
      return 'Company name must be less than 100 characters';
    }
    
    // Check for valid characters (letters, numbers, spaces, basic punctuation)
    if (!RegExp(r'^[a-zA-Z0-9\s\.\-&,\(\)]+$').hasMatch(trimmed)) {
      return 'Company name contains invalid characters';
    }
    
    return null; // Valid
  }

  /// Validate user name (first name, last name, or full name)
  static String? validateName(String? name, {String fieldName = 'Name'}) {
    if (name == null || name.trim().isEmpty) {
      return '$fieldName is required';
    }
    
    final trimmed = name.trim();
    
    if (trimmed.length < 2) {
      return '$fieldName must be at least 2 characters';
    }
    
    if (trimmed.length > 50) {
      return '$fieldName must be less than 50 characters';
    }
    
    // Allow letters, spaces, hyphens, apostrophes
    if (!RegExp(r'^[a-zA-Z\s\-\'\.]+$').hasMatch(trimmed)) {
      return '$fieldName can only contain letters, spaces, hyphens, and apostrophes';
    }
    
    return null; // Valid
  }

  /// Validate job title/role
  static String? validateJobTitle(String? jobTitle) {
    if (jobTitle == null || jobTitle.trim().isEmpty) {
      return null; // Optional field
    }
    
    final trimmed = jobTitle.trim();
    
    if (trimmed.length > 100) {
      return 'Job title must be less than 100 characters';
    }
    
    // Allow letters, numbers, spaces, basic punctuation
    if (!RegExp(r'^[a-zA-Z0-9\s\.\-&,\(\)\/]+$').hasMatch(trimmed)) {
      return 'Job title contains invalid characters';
    }
    
    return null; // Valid
  }

  /// Validate phone number
  static String? validatePhone(String? phone) {
    if (phone == null || phone.trim().isEmpty) {
      return null; // Optional field
    }
    
    final trimmed = phone.trim();
    
    if (!_phoneRegExp.hasMatch(trimmed)) {
      return 'Please enter a valid phone number';
    }
    
    return null; // Valid
  }

  /// Validate URL
  static String? validateUrl(String? url) {
    if (url == null || url.trim().isEmpty) {
      return null; // Optional field
    }
    
    final trimmed = url.trim();
    
    if (!_urlRegExp.hasMatch(trimmed)) {
      return 'Please enter a valid URL (including http:// or https://)';
    }
    
    return null; // Valid
  }

  /// Validate framework selection
  static String? validateFramework(String? framework) {
    if (framework == null || framework.trim().isEmpty) {
      return 'Please select a compliance framework';
    }
    
    final validFrameworks = [
      'SOC 2',
      'ISO 27001',
      'GDPR',
      'HIPAA',
      'PCI DSS',
      'CCPA',
      'NIST',
      'FedRAMP',
    ];
    
    if (!validFrameworks.contains(framework)) {
      return 'Please select a valid compliance framework';
    }
    
    return null; // Valid
  }

  /// Validate industry selection
  static String? validateIndustry(String? industry) {
    if (industry == null || industry.trim().isEmpty) {
      return null; // Optional field
    }
    
    final validIndustries = [
      'Technology',
      'Healthcare',
      'Financial Services',
      'Education',
      'Government',
      'Manufacturing',
      'Retail',
      'Professional Services',
      'Non-profit',
      'Other',
    ];
    
    if (!validIndustries.contains(industry)) {
      return 'Please select a valid industry';
    }
    
    return null; // Valid
  }

  /// Validate company size
  static String? validateCompanySize(String? size) {
    if (size == null || size.trim().isEmpty) {
      return null; // Optional field
    }
    
    final validSizes = [
      '1-10 employees',
      '11-50 employees',
      '51-200 employees',
      '201-1000 employees',
      '1000+ employees',
    ];
    
    if (!validSizes.contains(size)) {
      return 'Please select a valid company size';
    }
    
    return null; // Valid
  }

  /// Validate message content
  static String? validateMessage(String? message, {int minLength = 1, int maxLength = 1000}) {
    if (message == null || message.trim().isEmpty) {
      return 'Message cannot be empty';
    }
    
    final trimmed = message.trim();
    
    if (trimmed.length < minLength) {
      return 'Message must be at least $minLength character${minLength > 1 ? 's' : ''}';
    }
    
    if (trimmed.length > maxLength) {
      return 'Message must be less than $maxLength characters';
    }
    
    return null; // Valid
  }

  /// Validate assessment response
  static String? validateAssessmentResponse(String? response) {
    if (response == null || response.trim().isEmpty) {
      return 'Please provide a response';
    }
    
    final validResponses = ['Yes', 'No', 'Partial', 'N/A', 'Unknown'];
    
    if (!validResponses.contains(response)) {
      return 'Please select a valid response';
    }
    
    return null; // Valid
  }

  /// Sanitize user input for safe storage/display
  static String sanitizeInput(String input) {
    return input
        .trim()
        .replaceAll(RegExp(r'<[^>]*>'), '') // Remove HTML tags
        .replaceAll(RegExp(r'[^\w\s\.\-@,\(\)&]'), '') // Remove special chars except safe ones
        .replaceAll(RegExp(r'\s+'), ' '); // Normalize whitespace
  }

  /// Check if string contains profanity or inappropriate content
  static bool containsInappropriateContent(String text) {
    final inappropriate = [
      // Add inappropriate words/phrases as needed
      'spam',
      'scam',
      'phishing',
    ];
    
    final lowerText = text.toLowerCase();
    return inappropriate.any((word) => lowerText.contains(word));
  }

  /// Validate that required fields are filled
  static Map<String, String> validateRequiredFields(Map<String, String?> fields) {
    final errors = <String, String>{};
    
    fields.forEach((fieldName, value) {
      if (value == null || value.trim().isEmpty) {
        errors[fieldName] = '$fieldName is required';
      }
    });
    
    return errors;
  }

  /// Validate form data for lead capture
  static Map<String, String> validateLeadCaptureForm({
    required String? email,
    required String? companyName,
    String? firstName,
    String? lastName,
    String? jobTitle,
    String? phone,
  }) {
    final errors = <String, String>{};
    
    // Email validation
    final emailError = validateEmail(email);
    if (emailError != null) {
      errors['email'] = emailError;
    }
    
    // Company name validation
    final companyError = validateCompanyName(companyName);
    if (companyError != null) {
      errors['companyName'] = companyError;
    }
    
    // Optional field validations
    if (firstName != null) {
      final firstNameError = validateName(firstName, fieldName: 'First name');
      if (firstNameError != null) {
        errors['firstName'] = firstNameError;
      }
    }
    
    if (lastName != null) {
      final lastNameError = validateName(lastName, fieldName: 'Last name');
      if (lastNameError != null) {
        errors['lastName'] = lastNameError;
      }
    }
    
    if (jobTitle != null) {
      final jobTitleError = validateJobTitle(jobTitle);
      if (jobTitleError != null) {
        errors['jobTitle'] = jobTitleError;
      }
    }
    
    if (phone != null) {
      final phoneError = validatePhone(phone);
      if (phoneError != null) {
        errors['phone'] = phoneError;
      }
    }
    
    return errors;
  }

  /// Check if email domain is from a common business domain
  static bool isBusinessEmail(String email) {
    final domain = email.split('@').last.toLowerCase();
    
    // Common personal email domains to exclude
    final personalDomains = [
      'gmail.com',
      'yahoo.com',
      'hotmail.com',
      'outlook.com',
      'aol.com',
      'icloud.com',
      'protonmail.com',
      'mail.com',
    ];
    
    return !personalDomains.contains(domain);
  }

  /// Validate compliance framework configuration
  static String? validateFrameworkConfig(Map<String, dynamic> config) {
    final requiredFields = ['name', 'version', 'scope'];
    
    for (final field in requiredFields) {
      if (!config.containsKey(field) || config[field] == null) {
        return 'Missing required field: $field';
      }
    }
    
    return null; // Valid
  }

  /// Format and validate user input for consistent storage
  static String formatUserInput(String input) {
    return input
        .trim()
        .split(' ')
        .where((word) => word.isNotEmpty)
        .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }

  /// Check if input is likely to be test/dummy data
  static bool isTestData(String input) {
    final testPatterns = [
      RegExp(r'^test', caseSensitive: false),
      RegExp(r'^demo', caseSensitive: false),
      RegExp(r'^sample', caseSensitive: false),
      RegExp(r'^example', caseSensitive: false),
      RegExp(r'@test\.com$', caseSensitive: false),
      RegExp(r'@example\.com$', caseSensitive: false),
    ];
    
    return testPatterns.any((pattern) => pattern.hasMatch(input));
  }
}