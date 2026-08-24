class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email requerido';
    }
    if (!value.contains('@') || !value.contains('.')) {
      return 'Email inválido';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Contraseña requerida';
    }
    if (value.length < 6) {
      return 'Mínimo 6 caracteres';
    }
    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nombre requerido';
    }
    if (value.length < 2) {
      return 'Nombre demasiado corto';
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Teléfono requerido';
    }
    if (value.length < 10) {
      return 'Teléfono inválido';
    }
    return null;
  }

  static String? validatePin(String? value) {
    if (value == null || value.isEmpty) {
      return 'PIN requerido';
    }
    if (value.length != 6) {
      return 'PIN debe tener 6 dígitos';
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'Solo dígitos numéricos';
    }
    return null;
  }
}
