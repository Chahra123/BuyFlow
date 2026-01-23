class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email requis';
    final emailRegex = RegExp(r'^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+$');
    if (!emailRegex.hasMatch(value)) return 'Format email invalide';
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Mot de passe requis';
    if (value.length < 8) return 'Minimum 8 caractères';
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Doit contenir une majuscule';
    }
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Doit contenir une minuscule';
    }
    if (!value.contains(RegExp(r'[0-9]'))) return 'Doit contenir un chiffre';
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Doit contenir un caractère spécial';
    }
    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.isEmpty) return 'Nom requis';
    if (value.length < 2) return 'Minimum 2 caractères';
    if (value.length > 50) return 'Maximum 50 caractères';
    final nameRegex = RegExp('^[a-zA-ZÀ-ÿ\\s-\']+\$');
    if (!nameRegex.hasMatch(value)) {
      return 'Caractères alphabétiques uniquement';
    }
    return null;
  }

  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Confirmation requise';
    }
    if (value != password) return 'Les mots de passe ne correspondent pas';
    return null;
  }

  static int getPasswordStrength(String password) {
    if (password.isEmpty) return 0;
    
    int strength = 0;
    if (password.length >= 8) strength++;
    if (password.contains(RegExp(r'[A-Z]'))) strength++;
    if (password.contains(RegExp(r'[a-z]'))) strength++;
    if (password.contains(RegExp(r'[0-9]'))) strength++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength++;
    
    return strength; // 0-5
  }

  static String getPasswordStrengthText(int strength) {
    switch (strength) {
      case 0:
      case 1:
        return 'Très faible';
      case 2:
        return 'Faible';
      case 3:
        return 'Moyen';
      case 4:
        return 'Fort';
      case 5:
        return 'Très fort';
      default:
        return '';
    }
  }

  static String? validateRequired(String? value, [String fieldName = 'Ce champ']) {
    if (value == null || value.isEmpty) return '$fieldName est requis';
    return null;
  }
}
