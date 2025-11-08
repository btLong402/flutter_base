// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(
      _current != null,
      'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(
      instance != null,
      'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `CodeBase`
  String get appName {
    return Intl.message(
      'CodeBase',
      name: 'appName',
      desc: 'The name of the application',
      args: [],
    );
  }

  /// `OK`
  String get common_ok {
    return Intl.message('OK', name: 'common_ok', desc: '', args: []);
  }

  /// `Cancel`
  String get common_cancel {
    return Intl.message('Cancel', name: 'common_cancel', desc: '', args: []);
  }

  /// `Save`
  String get common_save {
    return Intl.message('Save', name: 'common_save', desc: '', args: []);
  }

  /// `Delete`
  String get common_delete {
    return Intl.message('Delete', name: 'common_delete', desc: '', args: []);
  }

  /// `Edit`
  String get common_edit {
    return Intl.message('Edit', name: 'common_edit', desc: '', args: []);
  }

  /// `Search`
  String get common_search {
    return Intl.message('Search', name: 'common_search', desc: '', args: []);
  }

  /// `Loading...`
  String get common_loading {
    return Intl.message(
      'Loading...',
      name: 'common_loading',
      desc: '',
      args: [],
    );
  }

  /// `Error`
  String get common_error {
    return Intl.message('Error', name: 'common_error', desc: '', args: []);
  }

  /// `Success`
  String get common_success {
    return Intl.message('Success', name: 'common_success', desc: '', args: []);
  }

  /// `Warning`
  String get common_warning {
    return Intl.message('Warning', name: 'common_warning', desc: '', args: []);
  }

  /// `Information`
  String get common_info {
    return Intl.message('Information', name: 'common_info', desc: '', args: []);
  }

  /// `Yes`
  String get common_yes {
    return Intl.message('Yes', name: 'common_yes', desc: '', args: []);
  }

  /// `No`
  String get common_no {
    return Intl.message('No', name: 'common_no', desc: '', args: []);
  }

  /// `Submit`
  String get common_submit {
    return Intl.message('Submit', name: 'common_submit', desc: '', args: []);
  }

  /// `Back`
  String get common_back {
    return Intl.message('Back', name: 'common_back', desc: '', args: []);
  }

  /// `Next`
  String get common_next {
    return Intl.message('Next', name: 'common_next', desc: '', args: []);
  }

  /// `Skip`
  String get common_skip {
    return Intl.message('Skip', name: 'common_skip', desc: '', args: []);
  }

  /// `Done`
  String get common_done {
    return Intl.message('Done', name: 'common_done', desc: '', args: []);
  }

  /// `Retry`
  String get common_retry {
    return Intl.message('Retry', name: 'common_retry', desc: '', args: []);
  }

  /// `Close`
  String get common_close {
    return Intl.message('Close', name: 'common_close', desc: '', args: []);
  }

  /// `Login`
  String get auth_login {
    return Intl.message('Login', name: 'auth_login', desc: '', args: []);
  }

  /// `Register`
  String get auth_register {
    return Intl.message('Register', name: 'auth_register', desc: '', args: []);
  }

  /// `Logout`
  String get auth_logout {
    return Intl.message('Logout', name: 'auth_logout', desc: '', args: []);
  }

  /// `Email`
  String get auth_email {
    return Intl.message('Email', name: 'auth_email', desc: '', args: []);
  }

  /// `Password`
  String get auth_password {
    return Intl.message('Password', name: 'auth_password', desc: '', args: []);
  }

  /// `Confirm Password`
  String get auth_confirmPassword {
    return Intl.message(
      'Confirm Password',
      name: 'auth_confirmPassword',
      desc: '',
      args: [],
    );
  }

  /// `Forgot Password?`
  String get auth_forgotPassword {
    return Intl.message(
      'Forgot Password?',
      name: 'auth_forgotPassword',
      desc: '',
      args: [],
    );
  }

  /// `Don't have an account?`
  String get auth_dontHaveAccount {
    return Intl.message(
      'Don\'t have an account?',
      name: 'auth_dontHaveAccount',
      desc: '',
      args: [],
    );
  }

  /// `Already have an account?`
  String get auth_alreadyHaveAccount {
    return Intl.message(
      'Already have an account?',
      name: 'auth_alreadyHaveAccount',
      desc: '',
      args: [],
    );
  }

  /// `Login successful`
  String get auth_loginSuccess {
    return Intl.message(
      'Login successful',
      name: 'auth_loginSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Login failed`
  String get auth_loginFailed {
    return Intl.message(
      'Login failed',
      name: 'auth_loginFailed',
      desc: '',
      args: [],
    );
  }

  /// `Registration successful`
  String get auth_registerSuccess {
    return Intl.message(
      'Registration successful',
      name: 'auth_registerSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Registration failed`
  String get auth_registerFailed {
    return Intl.message(
      'Registration failed',
      name: 'auth_registerFailed',
      desc: '',
      args: [],
    );
  }

  /// `Dashboard`
  String get dashboard_title {
    return Intl.message(
      'Dashboard',
      name: 'dashboard_title',
      desc: '',
      args: [],
    );
  }

  /// `Welcome back!`
  String get dashboard_welcome {
    return Intl.message(
      'Welcome back!',
      name: 'dashboard_welcome',
      desc: '',
      args: [],
    );
  }

  /// `Statistics`
  String get dashboard_stats {
    return Intl.message(
      'Statistics',
      name: 'dashboard_stats',
      desc: '',
      args: [],
    );
  }

  /// `Profile`
  String get profile_title {
    return Intl.message('Profile', name: 'profile_title', desc: '', args: []);
  }

  /// `Edit Profile`
  String get profile_editProfile {
    return Intl.message(
      'Edit Profile',
      name: 'profile_editProfile',
      desc: '',
      args: [],
    );
  }

  /// `Change Password`
  String get profile_changePassword {
    return Intl.message(
      'Change Password',
      name: 'profile_changePassword',
      desc: '',
      args: [],
    );
  }

  /// `Name`
  String get profile_name {
    return Intl.message('Name', name: 'profile_name', desc: '', args: []);
  }

  /// `Phone`
  String get profile_phone {
    return Intl.message('Phone', name: 'profile_phone', desc: '', args: []);
  }

  /// `Address`
  String get profile_address {
    return Intl.message('Address', name: 'profile_address', desc: '', args: []);
  }

  /// `Profile updated successfully`
  String get profile_updateSuccess {
    return Intl.message(
      'Profile updated successfully',
      name: 'profile_updateSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Failed to update profile`
  String get profile_updateFailed {
    return Intl.message(
      'Failed to update profile',
      name: 'profile_updateFailed',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get settings_title {
    return Intl.message('Settings', name: 'settings_title', desc: '', args: []);
  }

  /// `Theme`
  String get settings_theme {
    return Intl.message('Theme', name: 'settings_theme', desc: '', args: []);
  }

  /// `Language`
  String get settings_language {
    return Intl.message(
      'Language',
      name: 'settings_language',
      desc: '',
      args: [],
    );
  }

  /// `Notifications`
  String get settings_notifications {
    return Intl.message(
      'Notifications',
      name: 'settings_notifications',
      desc: '',
      args: [],
    );
  }

  /// `About`
  String get settings_about {
    return Intl.message('About', name: 'settings_about', desc: '', args: []);
  }

  /// `Privacy Policy`
  String get settings_privacy {
    return Intl.message(
      'Privacy Policy',
      name: 'settings_privacy',
      desc: '',
      args: [],
    );
  }

  /// `Terms of Service`
  String get settings_terms {
    return Intl.message(
      'Terms of Service',
      name: 'settings_terms',
      desc: '',
      args: [],
    );
  }

  /// `Light`
  String get settings_light {
    return Intl.message('Light', name: 'settings_light', desc: '', args: []);
  }

  /// `Dark`
  String get settings_dark {
    return Intl.message('Dark', name: 'settings_dark', desc: '', args: []);
  }

  /// `System`
  String get settings_system {
    return Intl.message('System', name: 'settings_system', desc: '', args: []);
  }

  /// `No internet connection`
  String get error_network {
    return Intl.message(
      'No internet connection',
      name: 'error_network',
      desc: '',
      args: [],
    );
  }

  /// `Request timeout`
  String get error_timeout {
    return Intl.message(
      'Request timeout',
      name: 'error_timeout',
      desc: '',
      args: [],
    );
  }

  /// `Server error occurred`
  String get error_server {
    return Intl.message(
      'Server error occurred',
      name: 'error_server',
      desc: '',
      args: [],
    );
  }

  /// `An unknown error occurred`
  String get error_unknown {
    return Intl.message(
      'An unknown error occurred',
      name: 'error_unknown',
      desc: '',
      args: [],
    );
  }

  /// `Unauthorized access`
  String get error_unauthorized {
    return Intl.message(
      'Unauthorized access',
      name: 'error_unauthorized',
      desc: '',
      args: [],
    );
  }

  /// `This field`
  String get field_default {
    return Intl.message(
      'This field',
      name: 'field_default',
      desc: '',
      args: [],
    );
  }

  /// `{field} is required`
  String validation_required(String field) {
    return Intl.message(
      '$field is required',
      name: 'validation_required',
      desc: '',
      args: [field],
    );
  }

  /// `Please enter a valid email address`
  String get validation_emailInvalid {
    return Intl.message(
      'Please enter a valid email address',
      name: 'validation_emailInvalid',
      desc: '',
      args: [],
    );
  }

  /// `Password must be at least {min} characters`
  String validation_passwordTooShort(int min) {
    return Intl.message(
      'Password must be at least $min characters',
      name: 'validation_passwordTooShort',
      desc: '',
      args: [min],
    );
  }

  /// `Passwords do not match`
  String get validation_passwordMismatch {
    return Intl.message(
      'Passwords do not match',
      name: 'validation_passwordMismatch',
      desc: '',
      args: [],
    );
  }

  /// `{field} must be at least {min} characters`
  String validation_minLength(String field, int min) {
    return Intl.message(
      '$field must be at least $min characters',
      name: 'validation_minLength',
      desc: '',
      args: [field, min],
    );
  }

  /// `{field} must not exceed {max} characters`
  String validation_maxLength(String field, int max) {
    return Intl.message(
      '$field must not exceed $max characters',
      name: 'validation_maxLength',
      desc: '',
      args: [field, max],
    );
  }

  /// `Please enter a valid phone number`
  String get validation_phoneInvalid {
    return Intl.message(
      'Please enter a valid phone number',
      name: 'validation_phoneInvalid',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a valid URL`
  String get validation_urlInvalid {
    return Intl.message(
      'Please enter a valid URL',
      name: 'validation_urlInvalid',
      desc: '',
      args: [],
    );
  }

  /// `Success!`
  String get toast_success {
    return Intl.message('Success!', name: 'toast_success', desc: '', args: []);
  }

  /// `Error!`
  String get toast_error {
    return Intl.message('Error!', name: 'toast_error', desc: '', args: []);
  }

  /// `Warning!`
  String get toast_warning {
    return Intl.message('Warning!', name: 'toast_warning', desc: '', args: []);
  }

  /// `Info`
  String get toast_info {
    return Intl.message('Info', name: 'toast_info', desc: '', args: []);
  }

  /// `No data available`
  String get empty_noData {
    return Intl.message(
      'No data available',
      name: 'empty_noData',
      desc: '',
      args: [],
    );
  }

  /// `No results found`
  String get empty_noResults {
    return Intl.message(
      'No results found',
      name: 'empty_noResults',
      desc: '',
      args: [],
    );
  }

  /// `No notifications`
  String get empty_noNotifications {
    return Intl.message(
      'No notifications',
      name: 'empty_noNotifications',
      desc: '',
      args: [],
    );
  }

  /// `Try again`
  String get empty_tryAgain {
    return Intl.message(
      'Try again',
      name: 'empty_tryAgain',
      desc: '',
      args: [],
    );
  }

  /// `Retry`
  String get error_retry {
    return Intl.message('Retry', name: 'error_retry', desc: '', args: []);
  }

  /// `Go Back`
  String get error_goBack {
    return Intl.message('Go Back', name: 'error_goBack', desc: '', args: []);
  }

  /// `Welcome Back`
  String get auth_welcomeBack {
    return Intl.message(
      'Welcome Back',
      name: 'auth_welcomeBack',
      desc: '',
      args: [],
    );
  }

  /// `Login to continue`
  String get auth_loginToContinue {
    return Intl.message(
      'Login to continue',
      name: 'auth_loginToContinue',
      desc: '',
      args: [],
    );
  }

  /// `Create Account`
  String get auth_createAccount {
    return Intl.message(
      'Create Account',
      name: 'auth_createAccount',
      desc: '',
      args: [],
    );
  }

  /// `Sign up to get started`
  String get auth_signUpToContinue {
    return Intl.message(
      'Sign up to get started',
      name: 'auth_signUpToContinue',
      desc: '',
      args: [],
    );
  }

  /// `Full Name`
  String get auth_fullName {
    return Intl.message('Full Name', name: 'auth_fullName', desc: '', args: []);
  }

  /// `Overview`
  String get dashboard_overview {
    return Intl.message(
      'Overview',
      name: 'dashboard_overview',
      desc: '',
      args: [],
    );
  }

  /// `Recent Activity`
  String get dashboard_recentActivity {
    return Intl.message(
      'Recent Activity',
      name: 'dashboard_recentActivity',
      desc: '',
      args: [],
    );
  }

  /// `View All`
  String get dashboard_viewAll {
    return Intl.message(
      'View All',
      name: 'dashboard_viewAll',
      desc: '',
      args: [],
    );
  }

  /// `Personal Information`
  String get profile_personalInfo {
    return Intl.message(
      'Personal Information',
      name: 'profile_personalInfo',
      desc: '',
      args: [],
    );
  }

  /// `Account Settings`
  String get profile_accountSettings {
    return Intl.message(
      'Account Settings',
      name: 'profile_accountSettings',
      desc: '',
      args: [],
    );
  }

  /// `Logout`
  String get profile_logout {
    return Intl.message('Logout', name: 'profile_logout', desc: '', args: []);
  }

  /// `Are you sure you want to logout?`
  String get profile_logoutConfirm {
    return Intl.message(
      'Are you sure you want to logout?',
      name: 'profile_logoutConfirm',
      desc: '',
      args: [],
    );
  }

  /// `Appearance`
  String get settings_appearance {
    return Intl.message(
      'Appearance',
      name: 'settings_appearance',
      desc: '',
      args: [],
    );
  }

  /// `General`
  String get settings_general {
    return Intl.message(
      'General',
      name: 'settings_general',
      desc: '',
      args: [],
    );
  }

  /// `Account`
  String get settings_account {
    return Intl.message(
      'Account',
      name: 'settings_account',
      desc: '',
      args: [],
    );
  }

  /// `Version`
  String get settings_version {
    return Intl.message(
      'Version',
      name: 'settings_version',
      desc: '',
      args: [],
    );
  }

  /// `Apply`
  String get action_apply {
    return Intl.message('Apply', name: 'action_apply', desc: '', args: []);
  }

  /// `Confirm`
  String get action_confirm {
    return Intl.message('Confirm', name: 'action_confirm', desc: '', args: []);
  }

  /// `Discard`
  String get action_discard {
    return Intl.message('Discard', name: 'action_discard', desc: '', args: []);
  }

  /// `Refresh`
  String get action_refresh {
    return Intl.message('Refresh', name: 'action_refresh', desc: '', args: []);
  }

  /// `Filter`
  String get action_filter {
    return Intl.message('Filter', name: 'action_filter', desc: '', args: []);
  }

  /// `Sort`
  String get action_sort {
    return Intl.message('Sort', name: 'action_sort', desc: '', args: []);
  }

  /// `Share`
  String get action_share {
    return Intl.message('Share', name: 'action_share', desc: '', args: []);
  }

  /// `Export`
  String get action_export {
    return Intl.message('Export', name: 'action_export', desc: '', args: []);
  }

  /// `Import`
  String get action_import {
    return Intl.message('Import', name: 'action_import', desc: '', args: []);
  }

  /// `Search...`
  String get hint_search {
    return Intl.message('Search...', name: 'hint_search', desc: '', args: []);
  }

  /// `Enter your email`
  String get hint_email {
    return Intl.message(
      'Enter your email',
      name: 'hint_email',
      desc: '',
      args: [],
    );
  }

  /// `Enter your password`
  String get hint_password {
    return Intl.message(
      'Enter your password',
      name: 'hint_password',
      desc: '',
      args: [],
    );
  }

  /// `Confirm your password`
  String get hint_confirmPassword {
    return Intl.message(
      'Confirm your password',
      name: 'hint_confirmPassword',
      desc: '',
      args: [],
    );
  }

  /// `Enter your full name`
  String get hint_fullName {
    return Intl.message(
      'Enter your full name',
      name: 'hint_fullName',
      desc: '',
      args: [],
    );
  }

  /// `Enter your phone number`
  String get hint_phone {
    return Intl.message(
      'Enter your phone number',
      name: 'hint_phone',
      desc: '',
      args: [],
    );
  }

  /// `Enter your address`
  String get hint_address {
    return Intl.message(
      'Enter your address',
      name: 'hint_address',
      desc: '',
      args: [],
    );
  }

  /// `Select a theme`
  String get hint_theme {
    return Intl.message(
      'Select a theme',
      name: 'hint_theme',
      desc: '',
      args: [],
    );
  }

  /// `Select a language`
  String get hint_language {
    return Intl.message(
      'Select a language',
      name: 'hint_language',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'vi'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
