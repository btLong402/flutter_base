// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en';

  static String m0(field, max) => "${field} must not exceed ${max} characters";

  static String m1(field, min) => "${field} must be at least ${min} characters";

  static String m2(min) => "Password must be at least ${min} characters";

  static String m3(field) => "${field} is required";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "action_apply": MessageLookupByLibrary.simpleMessage("Apply"),
    "action_confirm": MessageLookupByLibrary.simpleMessage("Confirm"),
    "action_discard": MessageLookupByLibrary.simpleMessage("Discard"),
    "action_export": MessageLookupByLibrary.simpleMessage("Export"),
    "action_filter": MessageLookupByLibrary.simpleMessage("Filter"),
    "action_import": MessageLookupByLibrary.simpleMessage("Import"),
    "action_refresh": MessageLookupByLibrary.simpleMessage("Refresh"),
    "action_share": MessageLookupByLibrary.simpleMessage("Share"),
    "action_sort": MessageLookupByLibrary.simpleMessage("Sort"),
    "appName": MessageLookupByLibrary.simpleMessage("CodeBase"),
    "auth_alreadyHaveAccount": MessageLookupByLibrary.simpleMessage(
      "Already have an account?",
    ),
    "auth_confirmPassword": MessageLookupByLibrary.simpleMessage(
      "Confirm Password",
    ),
    "auth_createAccount": MessageLookupByLibrary.simpleMessage(
      "Create Account",
    ),
    "auth_dontHaveAccount": MessageLookupByLibrary.simpleMessage(
      "Don\'t have an account?",
    ),
    "auth_email": MessageLookupByLibrary.simpleMessage("Email"),
    "auth_forgotPassword": MessageLookupByLibrary.simpleMessage(
      "Forgot Password?",
    ),
    "auth_fullName": MessageLookupByLibrary.simpleMessage("Full Name"),
    "auth_login": MessageLookupByLibrary.simpleMessage("Login"),
    "auth_loginFailed": MessageLookupByLibrary.simpleMessage("Login failed"),
    "auth_loginSuccess": MessageLookupByLibrary.simpleMessage(
      "Login successful",
    ),
    "auth_loginToContinue": MessageLookupByLibrary.simpleMessage(
      "Login to continue",
    ),
    "auth_logout": MessageLookupByLibrary.simpleMessage("Logout"),
    "auth_password": MessageLookupByLibrary.simpleMessage("Password"),
    "auth_register": MessageLookupByLibrary.simpleMessage("Register"),
    "auth_registerFailed": MessageLookupByLibrary.simpleMessage(
      "Registration failed",
    ),
    "auth_registerSuccess": MessageLookupByLibrary.simpleMessage(
      "Registration successful",
    ),
    "auth_signUpToContinue": MessageLookupByLibrary.simpleMessage(
      "Sign up to get started",
    ),
    "auth_welcomeBack": MessageLookupByLibrary.simpleMessage("Welcome Back"),
    "common_back": MessageLookupByLibrary.simpleMessage("Back"),
    "common_cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
    "common_close": MessageLookupByLibrary.simpleMessage("Close"),
    "common_delete": MessageLookupByLibrary.simpleMessage("Delete"),
    "common_done": MessageLookupByLibrary.simpleMessage("Done"),
    "common_edit": MessageLookupByLibrary.simpleMessage("Edit"),
    "common_error": MessageLookupByLibrary.simpleMessage("Error"),
    "common_info": MessageLookupByLibrary.simpleMessage("Information"),
    "common_loading": MessageLookupByLibrary.simpleMessage("Loading..."),
    "common_next": MessageLookupByLibrary.simpleMessage("Next"),
    "common_no": MessageLookupByLibrary.simpleMessage("No"),
    "common_ok": MessageLookupByLibrary.simpleMessage("OK"),
    "common_retry": MessageLookupByLibrary.simpleMessage("Retry"),
    "common_save": MessageLookupByLibrary.simpleMessage("Save"),
    "common_search": MessageLookupByLibrary.simpleMessage("Search"),
    "common_skip": MessageLookupByLibrary.simpleMessage("Skip"),
    "common_submit": MessageLookupByLibrary.simpleMessage("Submit"),
    "common_success": MessageLookupByLibrary.simpleMessage("Success"),
    "common_warning": MessageLookupByLibrary.simpleMessage("Warning"),
    "common_yes": MessageLookupByLibrary.simpleMessage("Yes"),
    "dashboard_overview": MessageLookupByLibrary.simpleMessage("Overview"),
    "dashboard_recentActivity": MessageLookupByLibrary.simpleMessage(
      "Recent Activity",
    ),
    "dashboard_stats": MessageLookupByLibrary.simpleMessage("Statistics"),
    "dashboard_title": MessageLookupByLibrary.simpleMessage("Dashboard"),
    "dashboard_viewAll": MessageLookupByLibrary.simpleMessage("View All"),
    "dashboard_welcome": MessageLookupByLibrary.simpleMessage("Welcome back!"),
    "empty_noData": MessageLookupByLibrary.simpleMessage("No data available"),
    "empty_noNotifications": MessageLookupByLibrary.simpleMessage(
      "No notifications",
    ),
    "empty_noResults": MessageLookupByLibrary.simpleMessage("No results found"),
    "empty_tryAgain": MessageLookupByLibrary.simpleMessage("Try again"),
    "error_goBack": MessageLookupByLibrary.simpleMessage("Go Back"),
    "error_network": MessageLookupByLibrary.simpleMessage(
      "No internet connection",
    ),
    "error_retry": MessageLookupByLibrary.simpleMessage("Retry"),
    "error_server": MessageLookupByLibrary.simpleMessage(
      "Server error occurred",
    ),
    "error_timeout": MessageLookupByLibrary.simpleMessage("Request timeout"),
    "error_unauthorized": MessageLookupByLibrary.simpleMessage(
      "Unauthorized access",
    ),
    "error_unknown": MessageLookupByLibrary.simpleMessage(
      "An unknown error occurred",
    ),
    "field_default": MessageLookupByLibrary.simpleMessage("This field"),
    "hint_address": MessageLookupByLibrary.simpleMessage("Enter your address"),
    "hint_confirmPassword": MessageLookupByLibrary.simpleMessage(
      "Confirm your password",
    ),
    "hint_email": MessageLookupByLibrary.simpleMessage("Enter your email"),
    "hint_fullName": MessageLookupByLibrary.simpleMessage(
      "Enter your full name",
    ),
    "hint_language": MessageLookupByLibrary.simpleMessage("Select a language"),
    "hint_password": MessageLookupByLibrary.simpleMessage(
      "Enter your password",
    ),
    "hint_phone": MessageLookupByLibrary.simpleMessage(
      "Enter your phone number",
    ),
    "hint_search": MessageLookupByLibrary.simpleMessage("Search..."),
    "hint_theme": MessageLookupByLibrary.simpleMessage("Select a theme"),
    "profile_accountSettings": MessageLookupByLibrary.simpleMessage(
      "Account Settings",
    ),
    "profile_address": MessageLookupByLibrary.simpleMessage("Address"),
    "profile_changePassword": MessageLookupByLibrary.simpleMessage(
      "Change Password",
    ),
    "profile_editProfile": MessageLookupByLibrary.simpleMessage("Edit Profile"),
    "profile_logout": MessageLookupByLibrary.simpleMessage("Logout"),
    "profile_logoutConfirm": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to logout?",
    ),
    "profile_name": MessageLookupByLibrary.simpleMessage("Name"),
    "profile_personalInfo": MessageLookupByLibrary.simpleMessage(
      "Personal Information",
    ),
    "profile_phone": MessageLookupByLibrary.simpleMessage("Phone"),
    "profile_title": MessageLookupByLibrary.simpleMessage("Profile"),
    "profile_updateFailed": MessageLookupByLibrary.simpleMessage(
      "Failed to update profile",
    ),
    "profile_updateSuccess": MessageLookupByLibrary.simpleMessage(
      "Profile updated successfully",
    ),
    "settings_about": MessageLookupByLibrary.simpleMessage("About"),
    "settings_account": MessageLookupByLibrary.simpleMessage("Account"),
    "settings_appearance": MessageLookupByLibrary.simpleMessage("Appearance"),
    "settings_dark": MessageLookupByLibrary.simpleMessage("Dark"),
    "settings_general": MessageLookupByLibrary.simpleMessage("General"),
    "settings_language": MessageLookupByLibrary.simpleMessage("Language"),
    "settings_light": MessageLookupByLibrary.simpleMessage("Light"),
    "settings_notifications": MessageLookupByLibrary.simpleMessage(
      "Notifications",
    ),
    "settings_privacy": MessageLookupByLibrary.simpleMessage("Privacy Policy"),
    "settings_system": MessageLookupByLibrary.simpleMessage("System"),
    "settings_terms": MessageLookupByLibrary.simpleMessage("Terms of Service"),
    "settings_theme": MessageLookupByLibrary.simpleMessage("Theme"),
    "settings_title": MessageLookupByLibrary.simpleMessage("Settings"),
    "settings_version": MessageLookupByLibrary.simpleMessage("Version"),
    "toast_error": MessageLookupByLibrary.simpleMessage("Error!"),
    "toast_info": MessageLookupByLibrary.simpleMessage("Info"),
    "toast_success": MessageLookupByLibrary.simpleMessage("Success!"),
    "toast_warning": MessageLookupByLibrary.simpleMessage("Warning!"),
    "validation_emailInvalid": MessageLookupByLibrary.simpleMessage(
      "Please enter a valid email address",
    ),
    "validation_maxLength": m0,
    "validation_minLength": m1,
    "validation_passwordMismatch": MessageLookupByLibrary.simpleMessage(
      "Passwords do not match",
    ),
    "validation_passwordTooShort": m2,
    "validation_phoneInvalid": MessageLookupByLibrary.simpleMessage(
      "Please enter a valid phone number",
    ),
    "validation_required": m3,
    "validation_urlInvalid": MessageLookupByLibrary.simpleMessage(
      "Please enter a valid URL",
    ),
  };
}
