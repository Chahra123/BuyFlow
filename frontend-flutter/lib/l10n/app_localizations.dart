import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In fr, this message translates to:
  /// **'BuyFlow'**
  String get appTitle;

  /// No description provided for @login.
  ///
  /// In fr, this message translates to:
  /// **'Connexion'**
  String get login;

  /// No description provided for @register.
  ///
  /// In fr, this message translates to:
  /// **'Inscription'**
  String get register;

  /// No description provided for @email.
  ///
  /// In fr, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe'**
  String get password;

  /// No description provided for @newPassword.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau mot de passe'**
  String get newPassword;

  /// No description provided for @firstName.
  ///
  /// In fr, this message translates to:
  /// **'Prénom'**
  String get firstName;

  /// No description provided for @lastName.
  ///
  /// In fr, this message translates to:
  /// **'Nom'**
  String get lastName;

  /// No description provided for @welcomeBack.
  ///
  /// In fr, this message translates to:
  /// **'Bon retour !'**
  String get welcomeBack;

  /// No description provided for @createAccount.
  ///
  /// In fr, this message translates to:
  /// **'Créer un compte'**
  String get createAccount;

  /// No description provided for @forgotPassword.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe oublié ?'**
  String get forgotPassword;

  /// No description provided for @resetPassword.
  ///
  /// In fr, this message translates to:
  /// **'Réinitialiser le mot de passe'**
  String get resetPassword;

  /// No description provided for @sendResetLink.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer le lien'**
  String get sendResetLink;

  /// No description provided for @changePassword.
  ///
  /// In fr, this message translates to:
  /// **'Changer le mot de passe'**
  String get changePassword;

  /// No description provided for @profile.
  ///
  /// In fr, this message translates to:
  /// **'Profil'**
  String get profile;

  /// No description provided for @settings.
  ///
  /// In fr, this message translates to:
  /// **'Paramètres'**
  String get settings;

  /// No description provided for @logout.
  ///
  /// In fr, this message translates to:
  /// **'Déconnexion'**
  String get logout;

  /// No description provided for @searchUsers.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher des utilisateurs...'**
  String get searchUsers;

  /// No description provided for @adminDashboard.
  ///
  /// In fr, this message translates to:
  /// **'Tableau de bord Admin'**
  String get adminDashboard;

  /// No description provided for @users.
  ///
  /// In fr, this message translates to:
  /// **'Utilisateurs'**
  String get users;

  /// No description provided for @errorGeneric.
  ///
  /// In fr, this message translates to:
  /// **'Une erreur est survenue'**
  String get errorGeneric;

  /// No description provided for @successGeneric.
  ///
  /// In fr, this message translates to:
  /// **'Opération réussie'**
  String get successGeneric;

  /// No description provided for @fieldRequired.
  ///
  /// In fr, this message translates to:
  /// **'Ce champ est requis'**
  String get fieldRequired;

  /// No description provided for @enterValidEmail.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez entrer un email valide'**
  String get enterValidEmail;

  /// No description provided for @passwordTooShort.
  ///
  /// In fr, this message translates to:
  /// **'Le mot de passe doit contenir au moins 8 caractères'**
  String get passwordTooShort;

  /// No description provided for @confirmPassword.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer le mot de passe'**
  String get confirmPassword;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In fr, this message translates to:
  /// **'Les mots de passe ne correspondent pas'**
  String get passwordsDoNotMatch;

  /// No description provided for @updateProfile.
  ///
  /// In fr, this message translates to:
  /// **'Mettre à jour le profil'**
  String get updateProfile;

  /// No description provided for @deleteUser.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer l\'utilisateur'**
  String get deleteUser;

  /// No description provided for @confirmDelete.
  ///
  /// In fr, this message translates to:
  /// **'Êtes-vous sûr de vouloir supprimer cet utilisateur ?'**
  String get confirmDelete;

  /// No description provided for @cancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get delete;

  /// No description provided for @save.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get save;

  /// No description provided for @signInWithGoogle.
  ///
  /// In fr, this message translates to:
  /// **'Se connecter avec Google'**
  String get signInWithGoogle;

  /// No description provided for @home.
  ///
  /// In fr, this message translates to:
  /// **'Accueil'**
  String get home;

  /// No description provided for @boutique.
  ///
  /// In fr, this message translates to:
  /// **'Boutique'**
  String get boutique;

  /// No description provided for @panier.
  ///
  /// In fr, this message translates to:
  /// **'Panier'**
  String get panier;

  /// No description provided for @panierVide.
  ///
  /// In fr, this message translates to:
  /// **'Votre panier est vide'**
  String get panierVide;

  /// No description provided for @total.
  ///
  /// In fr, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @commander.
  ///
  /// In fr, this message translates to:
  /// **'Commander'**
  String get commander;

  /// No description provided for @rechercherProduit.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher un produit...'**
  String get rechercherProduit;

  /// No description provided for @favoris.
  ///
  /// In fr, this message translates to:
  /// **'Favoris'**
  String get favoris;

  /// No description provided for @aucunProduit.
  ///
  /// In fr, this message translates to:
  /// **'Aucun produit trouvé'**
  String get aucunProduit;

  /// No description provided for @tnd.
  ///
  /// In fr, this message translates to:
  /// **'TND'**
  String get tnd;

  /// No description provided for @livraisonPaiement.
  ///
  /// In fr, this message translates to:
  /// **'Livraison & Paiement'**
  String get livraisonPaiement;

  /// No description provided for @adresseLivraison.
  ///
  /// In fr, this message translates to:
  /// **'Adresse de livraison'**
  String get adresseLivraison;

  /// No description provided for @instructions.
  ///
  /// In fr, this message translates to:
  /// **'Instructions (optionnel)'**
  String get instructions;

  /// No description provided for @veuillezSaisirAdresse.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez saisir une adresse.'**
  String get veuillezSaisirAdresse;

  /// No description provided for @erreurCommande.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors de la commande'**
  String get erreurCommande;

  /// No description provided for @mesCommandes.
  ///
  /// In fr, this message translates to:
  /// **'Mes commandes'**
  String get mesCommandes;

  /// No description provided for @aucuneCommande.
  ///
  /// In fr, this message translates to:
  /// **'Aucune commande'**
  String get aucuneCommande;

  /// No description provided for @commandeNum.
  ///
  /// In fr, this message translates to:
  /// **'Commande #'**
  String get commandeNum;

  /// No description provided for @statut.
  ///
  /// In fr, this message translates to:
  /// **'Statut'**
  String get statut;

  /// No description provided for @adresse.
  ///
  /// In fr, this message translates to:
  /// **'Adresse'**
  String get adresse;

  /// No description provided for @articles.
  ///
  /// In fr, this message translates to:
  /// **'Articles'**
  String get articles;

  /// No description provided for @quantite.
  ///
  /// In fr, this message translates to:
  /// **'Quantité'**
  String get quantite;

  /// No description provided for @qrLivraison.
  ///
  /// In fr, this message translates to:
  /// **'QR de livraison'**
  String get qrLivraison;

  /// No description provided for @facturePdf.
  ///
  /// In fr, this message translates to:
  /// **'Facture PDF'**
  String get facturePdf;

  /// No description provided for @reclamation.
  ///
  /// In fr, this message translates to:
  /// **'Réclamation'**
  String get reclamation;

  /// No description provided for @commandeAnnulee.
  ///
  /// In fr, this message translates to:
  /// **'Commande annulée'**
  String get commandeAnnulee;

  /// No description provided for @welcomeToBuyFlow.
  ///
  /// In fr, this message translates to:
  /// **'Bienvenue dans BuyFlow'**
  String get welcomeToBuyFlow;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Le meilleur endroit pour acheter et gérer votre flux.'**
  String get welcomeSubtitle;

  /// No description provided for @joinBuyFlow.
  ///
  /// In fr, this message translates to:
  /// **'Rejoindre BuyFlow'**
  String get joinBuyFlow;

  /// No description provided for @adventureStart.
  ///
  /// In fr, this message translates to:
  /// **'Commencez votre aventure maintenant.'**
  String get adventureStart;

  /// No description provided for @loginSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Connectez-vous pour accéder à votre espace.'**
  String get loginSubtitle;

  /// No description provided for @noAccount.
  ///
  /// In fr, this message translates to:
  /// **'Pas encore de compte ?'**
  String get noAccount;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In fr, this message translates to:
  /// **'Déjà un compte ?'**
  String get alreadyHaveAccount;

  /// No description provided for @ou.
  ///
  /// In fr, this message translates to:
  /// **'OU'**
  String get ou;

  /// No description provided for @continuerAvecGoogle.
  ///
  /// In fr, this message translates to:
  /// **'Continuer avec Google'**
  String get continuerAvecGoogle;

  /// No description provided for @apercuActivite.
  ///
  /// In fr, this message translates to:
  /// **'Aperçu de l\'Activité'**
  String get apercuActivite;

  /// No description provided for @totalUtilisateurs.
  ///
  /// In fr, this message translates to:
  /// **'Total Utilisateurs'**
  String get totalUtilisateurs;

  /// No description provided for @comptesActifs.
  ///
  /// In fr, this message translates to:
  /// **'Comptes Actifs'**
  String get comptesActifs;

  /// No description provided for @administrateurs.
  ///
  /// In fr, this message translates to:
  /// **'Administrateurs'**
  String get administrateurs;

  /// No description provided for @nouveaux24h.
  ///
  /// In fr, this message translates to:
  /// **'Nouveaux (24h)'**
  String get nouveaux24h;

  /// No description provided for @actionsRapides.
  ///
  /// In fr, this message translates to:
  /// **'Actions Rapides'**
  String get actionsRapides;

  /// No description provided for @creerUtilisateur.
  ///
  /// In fr, this message translates to:
  /// **'Créer un utilisateur'**
  String get creerUtilisateur;

  /// No description provided for @ajouterManuellement.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter manuellement un compte'**
  String get ajouterManuellement;

  /// No description provided for @gererCommandes.
  ///
  /// In fr, this message translates to:
  /// **'Gérer les Commandes'**
  String get gererCommandes;

  /// No description provided for @voirAssignerLivreurs.
  ///
  /// In fr, this message translates to:
  /// **'Voir et assigner des livreurs'**
  String get voirAssignerLivreurs;

  /// No description provided for @retourApp.
  ///
  /// In fr, this message translates to:
  /// **'Retour à l\'App'**
  String get retourApp;

  /// No description provided for @dashboard.
  ///
  /// In fr, this message translates to:
  /// **'Tableau de bord'**
  String get dashboard;

  /// No description provided for @stockDashboard.
  ///
  /// In fr, this message translates to:
  /// **'Tableau de bord Stock'**
  String get stockDashboard;

  /// No description provided for @actualiser.
  ///
  /// In fr, this message translates to:
  /// **'Actualiser'**
  String get actualiser;

  /// No description provided for @pasDonnees.
  ///
  /// In fr, this message translates to:
  /// **'Pas de données disponibles'**
  String get pasDonnees;

  /// No description provided for @analyseSante.
  ///
  /// In fr, this message translates to:
  /// **'Analyse de Santé'**
  String get analyseSante;

  /// No description provided for @dernieresActivites.
  ///
  /// In fr, this message translates to:
  /// **'Dernières Activités'**
  String get dernieresActivites;

  /// No description provided for @totalStocks.
  ///
  /// In fr, this message translates to:
  /// **'Total Stocks'**
  String get totalStocks;

  /// No description provided for @produits.
  ///
  /// In fr, this message translates to:
  /// **'Produits'**
  String get produits;

  /// No description provided for @alertesBas.
  ///
  /// In fr, this message translates to:
  /// **'Alertes Bas'**
  String get alertesBas;

  /// No description provided for @tauxSante.
  ///
  /// In fr, this message translates to:
  /// **'Taux de Santé'**
  String get tauxSante;

  /// No description provided for @entrepotsGeres.
  ///
  /// In fr, this message translates to:
  /// **'Entrepôts gérés'**
  String get entrepotsGeres;

  /// No description provided for @articlesCatalogue.
  ///
  /// In fr, this message translates to:
  /// **'Articles catalogue'**
  String get articlesCatalogue;

  /// No description provided for @aReapprovisionner.
  ///
  /// In fr, this message translates to:
  /// **'À réapprovisionner'**
  String get aReapprovisionner;

  /// No description provided for @disponibiliteGlobale.
  ///
  /// In fr, this message translates to:
  /// **'Disponibilité globale'**
  String get disponibiliteGlobale;

  /// No description provided for @optimal.
  ///
  /// In fr, this message translates to:
  /// **'Optimal'**
  String get optimal;

  /// No description provided for @alerte.
  ///
  /// In fr, this message translates to:
  /// **'Alerte'**
  String get alerte;

  /// No description provided for @etatsStocks.
  ///
  /// In fr, this message translates to:
  /// **'États des stocks'**
  String get etatsStocks;

  /// No description provided for @aucunMouvement.
  ///
  /// In fr, this message translates to:
  /// **'Aucun mouvement récent'**
  String get aucunMouvement;

  /// No description provided for @quis.
  ///
  /// In fr, this message translates to:
  /// **'Requis'**
  String get quis;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
