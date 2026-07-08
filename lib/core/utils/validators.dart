/// Form field validators used across all features
class Validators {
  Validators._();

  static String? email(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    final regex = RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$');
    if (!regex.hasMatch(value)) return 'Enter a valid email address';
    return null;
  }

  /// Login password — backend only requires @NotBlank (no length minimum).
  /// Accepts any non-empty string, e.g. "123456".
  static String? loginPassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    return null;
  }

  /// Registration password — backend enforces @Size(min = 8).
  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 8) return 'Password must be at least 8 characters';
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    if (value == null || value.isEmpty) return 'Please confirm your password';
    if (value != original) return 'Passwords do not match';
    return null;
  }

  static String? required(String? value, {String fieldName = 'This field'}) {
    if (value == null || value.trim().isEmpty) return '$fieldName is required';
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.isEmpty) return null; // optional field
    final regex = RegExp(r'^\+?[\d\s\-\(\)]{7,15}$');
    if (!regex.hasMatch(value)) return 'Enter a valid phone number';
    return null;
  }

  static String? amount(String? value) {
    if (value == null || value.isEmpty) return 'Amount is required';
    final parsed = double.tryParse(value);
    if (parsed == null || parsed <= 0) return 'Enter a valid amount';
    return null;
  }

  static String? minLength(String? value, int min, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }
    if (value.length < min) {
      return '${fieldName ?? 'This field'} must be at least $min characters';
    }
    return null;
  }

  static String? pin(String? value) {
    if (value == null || value.isEmpty) return 'PIN is required';
    if (value.length != 4) return 'PIN must be 4 digits';
    if (!RegExp(r'^\d{4}$').hasMatch(value)) return 'PIN must contain only digits';
    return null;
  }

  static String? otp(String? value) {
    if (value == null || value.isEmpty) return 'OTP is required';
    if (value.length != 6) return 'OTP must be 6 digits';
    return null;
  }
}
