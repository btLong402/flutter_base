import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

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
    Locale('vi'),
  ];

  /// The name of the application
  ///
  /// In en, this message translates to:
  /// **'CodeBase'**
  String get appName;

  /// No description provided for @common_ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get common_ok;

  /// No description provided for @common_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get common_cancel;

  /// No description provided for @common_save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get common_save;

  /// No description provided for @common_delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get common_delete;

  /// No description provided for @common_edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get common_edit;

  /// No description provided for @common_search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get common_search;

  /// No description provided for @common_loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get common_loading;

  /// No description provided for @common_error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get common_error;

  /// No description provided for @common_success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get common_success;

  /// No description provided for @common_warning.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get common_warning;

  /// No description provided for @common_info.
  ///
  /// In en, this message translates to:
  /// **'Information'**
  String get common_info;

  /// No description provided for @common_yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get common_yes;

  /// No description provided for @common_no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get common_no;

  /// No description provided for @common_submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get common_submit;

  /// No description provided for @common_back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get common_back;

  /// No description provided for @common_next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get common_next;

  /// No description provided for @common_skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get common_skip;

  /// No description provided for @common_done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get common_done;

  /// No description provided for @common_retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get common_retry;

  /// No description provided for @common_close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get common_close;

  /// No description provided for @auth_login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get auth_login;

  /// No description provided for @auth_register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get auth_register;

  /// No description provided for @auth_logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get auth_logout;

  /// No description provided for @auth_email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get auth_email;

  /// No description provided for @auth_password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get auth_password;

  /// No description provided for @auth_confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get auth_confirmPassword;

  /// No description provided for @auth_forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get auth_forgotPassword;

  /// No description provided for @auth_dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get auth_dontHaveAccount;

  /// No description provided for @auth_alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get auth_alreadyHaveAccount;

  /// No description provided for @auth_loginSuccess.
  ///
  /// In en, this message translates to:
  /// **'Login successful'**
  String get auth_loginSuccess;

  /// No description provided for @auth_loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed'**
  String get auth_loginFailed;

  /// No description provided for @auth_registerSuccess.
  ///
  /// In en, this message translates to:
  /// **'Registration successful'**
  String get auth_registerSuccess;

  /// No description provided for @auth_registerFailed.
  ///
  /// In en, this message translates to:
  /// **'Registration failed'**
  String get auth_registerFailed;

  /// No description provided for @dashboard_title.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard_title;

  /// No description provided for @dashboard_welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome back!'**
  String get dashboard_welcome;

  /// No description provided for @dashboard_stats.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get dashboard_stats;

  /// No description provided for @profile_title.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile_title;

  /// No description provided for @profile_editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get profile_editProfile;

  /// No description provided for @profile_changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get profile_changePassword;

  /// No description provided for @profile_name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get profile_name;

  /// No description provided for @profile_phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get profile_phone;

  /// No description provided for @profile_address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get profile_address;

  /// No description provided for @profile_updateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get profile_updateSuccess;

  /// No description provided for @profile_updateFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to update profile'**
  String get profile_updateFailed;

  /// No description provided for @settings_title.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings_title;

  /// No description provided for @settings_theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settings_theme;

  /// No description provided for @settings_language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settings_language;

  /// No description provided for @settings_notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settings_notifications;

  /// No description provided for @settings_about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settings_about;

  /// No description provided for @settings_privacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get settings_privacy;

  /// No description provided for @settings_terms.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get settings_terms;

  /// No description provided for @settings_light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settings_light;

  /// No description provided for @settings_dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settings_dark;

  /// No description provided for @settings_system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settings_system;

  /// No description provided for @error_network.
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get error_network;

  /// No description provided for @error_timeout.
  ///
  /// In en, this message translates to:
  /// **'Request timeout'**
  String get error_timeout;

  /// No description provided for @error_server.
  ///
  /// In en, this message translates to:
  /// **'Server error occurred'**
  String get error_server;

  /// No description provided for @error_unknown.
  ///
  /// In en, this message translates to:
  /// **'An unknown error occurred'**
  String get error_unknown;

  /// No description provided for @error_unauthorized.
  ///
  /// In en, this message translates to:
  /// **'Unauthorized access'**
  String get error_unauthorized;

  /// No description provided for @field_default.
  ///
  /// In en, this message translates to:
  /// **'This field'**
  String get field_default;

  /// No description provided for @validation_required.
  ///
  /// In en, this message translates to:
  /// **'{field} is required'**
  String validation_required(String field);

  /// No description provided for @validation_emailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get validation_emailInvalid;

  /// No description provided for @validation_passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least {min} characters'**
  String validation_passwordTooShort(int min);

  /// No description provided for @validation_passwordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get validation_passwordMismatch;

  /// No description provided for @validation_minLength.
  ///
  /// In en, this message translates to:
  /// **'{field} must be at least {min} characters'**
  String validation_minLength(String field, int min);

  /// No description provided for @validation_maxLength.
  ///
  /// In en, this message translates to:
  /// **'{field} must not exceed {max} characters'**
  String validation_maxLength(String field, int max);

  /// No description provided for @validation_phoneInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid phone number'**
  String get validation_phoneInvalid;

  /// No description provided for @validation_urlInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid URL'**
  String get validation_urlInvalid;

  /// No description provided for @toast_success.
  ///
  /// In en, this message translates to:
  /// **'Success!'**
  String get toast_success;

  /// No description provided for @toast_error.
  ///
  /// In en, this message translates to:
  /// **'Error!'**
  String get toast_error;

  /// No description provided for @toast_warning.
  ///
  /// In en, this message translates to:
  /// **'Warning!'**
  String get toast_warning;

  /// No description provided for @toast_info.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get toast_info;

  /// No description provided for @empty_noData.
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get empty_noData;

  /// No description provided for @empty_noResults.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get empty_noResults;

  /// No description provided for @empty_noNotifications.
  ///
  /// In en, this message translates to:
  /// **'No notifications'**
  String get empty_noNotifications;

  /// No description provided for @empty_tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get empty_tryAgain;

  /// No description provided for @error_retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get error_retry;

  /// No description provided for @error_goBack.
  ///
  /// In en, this message translates to:
  /// **'Go Back'**
  String get error_goBack;

  /// No description provided for @auth_welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get auth_welcomeBack;

  /// No description provided for @auth_loginToContinue.
  ///
  /// In en, this message translates to:
  /// **'Login to continue'**
  String get auth_loginToContinue;

  /// No description provided for @auth_createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get auth_createAccount;

  /// No description provided for @auth_signUpToContinue.
  ///
  /// In en, this message translates to:
  /// **'Sign up to get started'**
  String get auth_signUpToContinue;

  /// No description provided for @auth_fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get auth_fullName;

  /// No description provided for @dashboard_overview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get dashboard_overview;

  /// No description provided for @dashboard_recentActivity.
  ///
  /// In en, this message translates to:
  /// **'Recent Activity'**
  String get dashboard_recentActivity;

  /// No description provided for @dashboard_viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get dashboard_viewAll;

  /// No description provided for @profile_personalInfo.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get profile_personalInfo;

  /// No description provided for @profile_accountSettings.
  ///
  /// In en, this message translates to:
  /// **'Account Settings'**
  String get profile_accountSettings;

  /// No description provided for @profile_logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get profile_logout;

  /// No description provided for @profile_logoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get profile_logoutConfirm;

  /// No description provided for @settings_appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settings_appearance;

  /// No description provided for @settings_general.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get settings_general;

  /// No description provided for @settings_account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get settings_account;

  /// No description provided for @settings_version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get settings_version;

  /// No description provided for @action_apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get action_apply;

  /// No description provided for @action_confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get action_confirm;

  /// No description provided for @action_discard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get action_discard;

  /// No description provided for @action_refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get action_refresh;

  /// No description provided for @action_filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get action_filter;

  /// No description provided for @action_sort.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get action_sort;

  /// No description provided for @action_share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get action_share;

  /// No description provided for @action_export.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get action_export;

  /// No description provided for @action_import.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get action_import;

  /// No description provided for @hint_search.
  ///
  /// In en, this message translates to:
  /// **'Search...'**
  String get hint_search;

  /// No description provided for @hint_email.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get hint_email;

  /// No description provided for @hint_password.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get hint_password;

  /// No description provided for @hint_confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm your password'**
  String get hint_confirmPassword;

  /// No description provided for @hint_fullName.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get hint_fullName;

  /// No description provided for @hint_phone.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number'**
  String get hint_phone;

  /// No description provided for @hint_address.
  ///
  /// In en, this message translates to:
  /// **'Enter your address'**
  String get hint_address;

  /// No description provided for @hint_theme.
  ///
  /// In en, this message translates to:
  /// **'Select a theme'**
  String get hint_theme;

  /// No description provided for @hint_language.
  ///
  /// In en, this message translates to:
  /// **'Select a language'**
  String get hint_language;
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
      <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
