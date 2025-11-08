// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'CodeBase';

  @override
  String get common_ok => 'OK';

  @override
  String get common_cancel => 'Cancel';

  @override
  String get common_save => 'Save';

  @override
  String get common_delete => 'Delete';

  @override
  String get common_edit => 'Edit';

  @override
  String get common_search => 'Search';

  @override
  String get common_loading => 'Loading...';

  @override
  String get common_error => 'Error';

  @override
  String get common_success => 'Success';

  @override
  String get common_warning => 'Warning';

  @override
  String get common_info => 'Information';

  @override
  String get common_yes => 'Yes';

  @override
  String get common_no => 'No';

  @override
  String get common_submit => 'Submit';

  @override
  String get common_back => 'Back';

  @override
  String get common_next => 'Next';

  @override
  String get common_skip => 'Skip';

  @override
  String get common_done => 'Done';

  @override
  String get common_retry => 'Retry';

  @override
  String get common_close => 'Close';

  @override
  String get auth_login => 'Login';

  @override
  String get auth_register => 'Register';

  @override
  String get auth_logout => 'Logout';

  @override
  String get auth_email => 'Email';

  @override
  String get auth_password => 'Password';

  @override
  String get auth_confirmPassword => 'Confirm Password';

  @override
  String get auth_forgotPassword => 'Forgot Password?';

  @override
  String get auth_dontHaveAccount => 'Don\'t have an account?';

  @override
  String get auth_alreadyHaveAccount => 'Already have an account?';

  @override
  String get auth_loginSuccess => 'Login successful';

  @override
  String get auth_loginFailed => 'Login failed';

  @override
  String get auth_registerSuccess => 'Registration successful';

  @override
  String get auth_registerFailed => 'Registration failed';

  @override
  String get dashboard_title => 'Dashboard';

  @override
  String get dashboard_welcome => 'Welcome back!';

  @override
  String get dashboard_stats => 'Statistics';

  @override
  String get profile_title => 'Profile';

  @override
  String get profile_editProfile => 'Edit Profile';

  @override
  String get profile_changePassword => 'Change Password';

  @override
  String get profile_name => 'Name';

  @override
  String get profile_phone => 'Phone';

  @override
  String get profile_address => 'Address';

  @override
  String get profile_updateSuccess => 'Profile updated successfully';

  @override
  String get profile_updateFailed => 'Failed to update profile';

  @override
  String get settings_title => 'Settings';

  @override
  String get settings_theme => 'Theme';

  @override
  String get settings_language => 'Language';

  @override
  String get settings_notifications => 'Notifications';

  @override
  String get settings_about => 'About';

  @override
  String get settings_privacy => 'Privacy Policy';

  @override
  String get settings_terms => 'Terms of Service';

  @override
  String get settings_light => 'Light';

  @override
  String get settings_dark => 'Dark';

  @override
  String get settings_system => 'System';

  @override
  String get error_network => 'No internet connection';

  @override
  String get error_timeout => 'Request timeout';

  @override
  String get error_server => 'Server error occurred';

  @override
  String get error_unknown => 'An unknown error occurred';

  @override
  String get error_unauthorized => 'Unauthorized access';

  @override
  String get field_default => 'This field';

  @override
  String validation_required(String field) {
    return '$field is required';
  }

  @override
  String get validation_emailInvalid => 'Please enter a valid email address';

  @override
  String validation_passwordTooShort(int min) {
    return 'Password must be at least $min characters';
  }

  @override
  String get validation_passwordMismatch => 'Passwords do not match';

  @override
  String validation_minLength(String field, int min) {
    return '$field must be at least $min characters';
  }

  @override
  String validation_maxLength(String field, int max) {
    return '$field must not exceed $max characters';
  }

  @override
  String get validation_phoneInvalid => 'Please enter a valid phone number';

  @override
  String get validation_urlInvalid => 'Please enter a valid URL';

  @override
  String get toast_success => 'Success!';

  @override
  String get toast_error => 'Error!';

  @override
  String get toast_warning => 'Warning!';

  @override
  String get toast_info => 'Info';

  @override
  String get empty_noData => 'No data available';

  @override
  String get empty_noResults => 'No results found';

  @override
  String get empty_noNotifications => 'No notifications';

  @override
  String get empty_tryAgain => 'Try again';

  @override
  String get error_retry => 'Retry';

  @override
  String get error_goBack => 'Go Back';

  @override
  String get auth_welcomeBack => 'Welcome Back';

  @override
  String get auth_loginToContinue => 'Login to continue';

  @override
  String get auth_createAccount => 'Create Account';

  @override
  String get auth_signUpToContinue => 'Sign up to get started';

  @override
  String get auth_fullName => 'Full Name';

  @override
  String get dashboard_overview => 'Overview';

  @override
  String get dashboard_recentActivity => 'Recent Activity';

  @override
  String get dashboard_viewAll => 'View All';

  @override
  String get profile_personalInfo => 'Personal Information';

  @override
  String get profile_accountSettings => 'Account Settings';

  @override
  String get profile_logout => 'Logout';

  @override
  String get profile_logoutConfirm => 'Are you sure you want to logout?';

  @override
  String get settings_appearance => 'Appearance';

  @override
  String get settings_general => 'General';

  @override
  String get settings_account => 'Account';

  @override
  String get settings_version => 'Version';

  @override
  String get action_apply => 'Apply';

  @override
  String get action_confirm => 'Confirm';

  @override
  String get action_discard => 'Discard';

  @override
  String get action_refresh => 'Refresh';

  @override
  String get action_filter => 'Filter';

  @override
  String get action_sort => 'Sort';

  @override
  String get action_share => 'Share';

  @override
  String get action_export => 'Export';

  @override
  String get action_import => 'Import';

  @override
  String get hint_search => 'Search...';

  @override
  String get hint_email => 'Enter your email';

  @override
  String get hint_password => 'Enter your password';

  @override
  String get hint_confirmPassword => 'Confirm your password';

  @override
  String get hint_fullName => 'Enter your full name';

  @override
  String get hint_phone => 'Enter your phone number';

  @override
  String get hint_address => 'Enter your address';

  @override
  String get hint_theme => 'Select a theme';

  @override
  String get hint_language => 'Select a language';
}
