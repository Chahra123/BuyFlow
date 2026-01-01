// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'BuyFlow';

  @override
  String get login => 'Connexion';

  @override
  String get register => 'Inscription';

  @override
  String get email => 'Email';

  @override
  String get password => 'Mot de passe';

  @override
  String get newPassword => 'Nouveau mot de passe';

  @override
  String get firstName => 'Prénom';

  @override
  String get lastName => 'Nom';

  @override
  String get welcomeBack => 'Bon retour !';

  @override
  String get createAccount => 'Créer un compte';

  @override
  String get forgotPassword => 'Mot de passe oublié ?';

  @override
  String get resetPassword => 'Réinitialiser le mot de passe';

  @override
  String get sendResetLink => 'Envoyer le lien';

  @override
  String get changePassword => 'Changer le mot de passe';

  @override
  String get profile => 'Profil';

  @override
  String get settings => 'Paramètres';

  @override
  String get logout => 'Déconnexion';

  @override
  String get searchUsers => 'Rechercher des utilisateurs...';

  @override
  String get adminDashboard => 'Tableau de bord Admin';

  @override
  String get users => 'Utilisateurs';

  @override
  String get errorGeneric => 'Une erreur est survenue';

  @override
  String get successGeneric => 'Opération réussie';

  @override
  String get fieldRequired => 'Ce champ est requis';

  @override
  String get enterValidEmail => 'Veuillez entrer un email valide';

  @override
  String get passwordTooShort =>
      'Le mot de passe doit contenir au moins 8 caractères';

  @override
  String get confirmPassword => 'Confirmer le mot de passe';

  @override
  String get passwordsDoNotMatch => 'Les mots de passe ne correspondent pas';

  @override
  String get updateProfile => 'Mettre à jour le profil';

  @override
  String get deleteUser => 'Supprimer l\'utilisateur';

  @override
  String get confirmDelete =>
      'Êtes-vous sûr de vouloir supprimer cet utilisateur ?';

  @override
  String get cancel => 'Annuler';

  @override
  String get delete => 'Supprimer';

  @override
  String get save => 'Enregistrer';

  @override
  String get signInWithGoogle => 'Se connecter avec Google';

  @override
  String get home => 'Accueil';
}
