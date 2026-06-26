import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';

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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
    Locale('hi')
  ];

  /// No description provided for @helloWorld.
  ///
  /// In en, this message translates to:
  /// **'Hello World!'**
  String get helloWorld;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome To Green Collar'**
  String get welcome;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language:'**
  String get selectLanguage;

  /// No description provided for @continueText.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueText;

  /// No description provided for @pleaseLogin.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get pleaseLogin;

  /// No description provided for @farmer.
  ///
  /// In en, this message translates to:
  /// **'Farmer'**
  String get farmer;

  /// No description provided for @labour.
  ///
  /// In en, this message translates to:
  /// **'Worker'**
  String get labour;

  /// No description provided for @enterMobile.
  ///
  /// In en, this message translates to:
  /// **'Enter your number'**
  String get enterMobile;

  /// No description provided for @emptyMobileValidation.
  ///
  /// In en, this message translates to:
  /// **'Please enter a phone number'**
  String get emptyMobileValidation;

  /// No description provided for @mobileDigitValidation.
  ///
  /// In en, this message translates to:
  /// **'Phone number must be 10 digits'**
  String get mobileDigitValidation;

  /// No description provided for @emptyPasswordValidation.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get emptyPasswordValidation;

  /// No description provided for @passwordCharValidation.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordCharValidation;

  /// No description provided for @passwordHintText.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get passwordHintText;

  /// No description provided for @regno.
  ///
  /// In en, this message translates to:
  /// **'Registration Number'**
  String get regno;

  /// No description provided for @emptyfield.
  ///
  /// In en, this message translates to:
  /// **'Please fill out this field'**
  String get emptyfield;

  /// No description provided for @yearofestb.
  ///
  /// In en, this message translates to:
  /// **'Established Year'**
  String get yearofestb;

  /// No description provided for @repasserro.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get repasserro;

  /// No description provided for @projectDetails.
  ///
  /// In en, this message translates to:
  /// **'Project Details'**
  String get projectDetails;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get city;

  /// No description provided for @cityEmpty.
  ///
  /// In en, this message translates to:
  /// **'Please select a city'**
  String get cityEmpty;

  /// No description provided for @state.
  ///
  /// In en, this message translates to:
  /// **'State'**
  String get state;

  /// No description provided for @stateEmpty.
  ///
  /// In en, this message translates to:
  /// **'Please select a state'**
  String get stateEmpty;

  /// No description provided for @forgetPassword.
  ///
  /// In en, this message translates to:
  /// **'Forget Password?'**
  String get forgetPassword;

  /// No description provided for @registernow.
  ///
  /// In en, this message translates to:
  /// **'Register Now'**
  String get registernow;

  /// No description provided for @registerSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Registration Successful!'**
  String get registerSuccessful;

  /// No description provided for @registerError.
  ///
  /// In en, this message translates to:
  /// **'Registration failed. Try again.'**
  String get registerError;

  /// No description provided for @registerform.
  ///
  /// In en, this message translates to:
  /// **'Registration Form'**
  String get registerform;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @individual.
  ///
  /// In en, this message translates to:
  /// **'Individual'**
  String get individual;

  /// No description provided for @agency.
  ///
  /// In en, this message translates to:
  /// **'Agency'**
  String get agency;

  /// No description provided for @agencyName.
  ///
  /// In en, this message translates to:
  /// **'Agency Name'**
  String get agencyName;

  /// No description provided for @enterAgencyName.
  ///
  /// In en, this message translates to:
  /// **'Please enter agency name'**
  String get enterAgencyName;

  /// No description provided for @numberOfEmployees.
  ///
  /// In en, this message translates to:
  /// **'Number of Employees'**
  String get numberOfEmployees;

  /// No description provided for @employeevalidation.
  ///
  /// In en, this message translates to:
  /// **'Please enter number of employees'**
  String get employeevalidation;

  /// No description provided for @employeecountvalidation.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid number greater than 0'**
  String get employeecountvalidation;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @nameValidation.
  ///
  /// In en, this message translates to:
  /// **'Please enter your name'**
  String get nameValidation;

  /// No description provided for @age.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get age;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Select Gender'**
  String get gender;

  /// No description provided for @emptyAgeError.
  ///
  /// In en, this message translates to:
  /// **'Please enter your age'**
  String get emptyAgeError;

  /// No description provided for @validAgeError.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid number'**
  String get validAgeError;

  /// No description provided for @pincode.
  ///
  /// In en, this message translates to:
  /// **'Pincode'**
  String get pincode;

  /// No description provided for @emptyPinError.
  ///
  /// In en, this message translates to:
  /// **'Please enter your pin code'**
  String get emptyPinError;

  /// No description provided for @validPinError.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid 6-digit pin code'**
  String get validPinError;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @emptyAddress.
  ///
  /// In en, this message translates to:
  /// **'Please enter your address'**
  String get emptyAddress;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @registerAs.
  ///
  /// In en, this message translates to:
  /// **'Register As'**
  String get registerAs;

  /// No description provided for @workingAs.
  ///
  /// In en, this message translates to:
  /// **'Working As'**
  String get workingAs;

  /// No description provided for @requiredSkills.
  ///
  /// In en, this message translates to:
  /// **'Required Skills:'**
  String get requiredSkills;

  /// No description provided for @negativeAgeError.
  ///
  /// In en, this message translates to:
  /// **'Age cannot be negative'**
  String get negativeAgeError;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @validEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get validEmail;

  /// No description provided for @aadhar.
  ///
  /// In en, this message translates to:
  /// **'Aadhar Card Number'**
  String get aadhar;

  /// No description provided for @emptygovError.
  ///
  /// In en, this message translates to:
  /// **'Please enter your Aadhar card number'**
  String get emptygovError;

  /// No description provided for @validgovtError.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid 12-digit Aadhar card number'**
  String get validgovtError;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phone;

  /// No description provided for @phoneEmpty.
  ///
  /// In en, this message translates to:
  /// **'Please enter your phone number'**
  String get phoneEmpty;

  /// No description provided for @validPhoneError.
  ///
  /// In en, this message translates to:
  /// **'Phone number must be 10 digits'**
  String get validPhoneError;

  /// No description provided for @termsAndCondition.
  ///
  /// In en, this message translates to:
  /// **'By agreeing here, you acknowledge that you have read our '**
  String get termsAndCondition;

  /// No description provided for @termsAndCondition2.
  ///
  /// In en, this message translates to:
  /// **'Terms, Conditions, and Privacy Policy'**
  String get termsAndCondition2;

  /// No description provided for @male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// No description provided for @female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @purnViram.
  ///
  /// In en, this message translates to:
  /// **'.'**
  String get purnViram;

  /// No description provided for @jobtypes.
  ///
  /// In en, this message translates to:
  /// **'Job Types'**
  String get jobtypes;

  /// No description provided for @search_by.
  ///
  /// In en, this message translates to:
  /// **'Search by pincode, city, or state'**
  String get search_by;

  /// No description provided for @jobtype.
  ///
  /// In en, this message translates to:
  /// **'Job Type'**
  String get jobtype;

  /// No description provided for @workTitle.
  ///
  /// In en, this message translates to:
  /// **'Work Title'**
  String get workTitle;

  /// No description provided for @homepage.
  ///
  /// In en, this message translates to:
  /// **'Homepage'**
  String get homepage;

  /// No description provided for @nearbylabours.
  ///
  /// In en, this message translates to:
  /// **'Nearby Workers'**
  String get nearbylabours;

  /// No description provided for @nearbyFarmers.
  ///
  /// In en, this message translates to:
  /// **'Nearby Farmers'**
  String get nearbyFarmers;

  /// No description provided for @nearbyProjects.
  ///
  /// In en, this message translates to:
  /// **'Nearby Projects'**
  String get nearbyProjects;

  /// No description provided for @filter_projects.
  ///
  /// In en, this message translates to:
  /// **'Filter Projects'**
  String get filter_projects;

  /// No description provided for @select_job_type.
  ///
  /// In en, this message translates to:
  /// **'Select Job Type'**
  String get select_job_type;

  /// No description provided for @select_payment_type.
  ///
  /// In en, this message translates to:
  /// **'Select Payment Type'**
  String get select_payment_type;

  /// No description provided for @search_placeholder.
  ///
  /// In en, this message translates to:
  /// **'Search by pincode, city, or state'**
  String get search_placeholder;

  /// No description provided for @select_budget_range.
  ///
  /// In en, this message translates to:
  /// **'Select Budget Range'**
  String get select_budget_range;

  /// No description provided for @daily_wage.
  ///
  /// In en, this message translates to:
  /// **'Daily Wage'**
  String get daily_wage;

  /// No description provided for @contract.
  ///
  /// In en, this message translates to:
  /// **'Contract'**
  String get contract;

  /// No description provided for @apply_filters.
  ///
  /// In en, this message translates to:
  /// **'Apply Filters'**
  String get apply_filters;

  /// No description provided for @reset_filters.
  ///
  /// In en, this message translates to:
  /// **'Reset Filters'**
  String get reset_filters;

  /// No description provided for @searchlabour.
  ///
  /// In en, this message translates to:
  /// **'Search Worker by pincode, city, or state'**
  String get searchlabour;

  /// No description provided for @searchBy.
  ///
  /// In en, this message translates to:
  /// **'Search by title, budget, city, or state'**
  String get searchBy;

  /// No description provided for @noProjectsFound.
  ///
  /// In en, this message translates to:
  /// **'No projects found'**
  String get noProjectsFound;

  /// No description provided for @viewApplications.
  ///
  /// In en, this message translates to:
  /// **'View Applications'**
  String get viewApplications;

  /// No description provided for @projectType.
  ///
  /// In en, this message translates to:
  /// **'Project Type'**
  String get projectType;

  /// No description provided for @noOfLaboursRequired.
  ///
  /// In en, this message translates to:
  /// **'Number of Required Workers'**
  String get noOfLaboursRequired;

  /// No description provided for @budget.
  ///
  /// In en, this message translates to:
  /// **'Budget'**
  String get budget;

  /// No description provided for @estimatedDays.
  ///
  /// In en, this message translates to:
  /// **'Estimated Days'**
  String get estimatedDays;

  /// No description provided for @experienceRequired.
  ///
  /// In en, this message translates to:
  /// **'Experience Required'**
  String get experienceRequired;

  /// No description provided for @qualification.
  ///
  /// In en, this message translates to:
  /// **'Qualification'**
  String get qualification;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @paymentType.
  ///
  /// In en, this message translates to:
  /// **'Payment Type'**
  String get paymentType;

  /// No description provided for @milestoneBasis.
  ///
  /// In en, this message translates to:
  /// **'Milestone Basis'**
  String get milestoneBasis;

  /// No description provided for @descriptionColumn.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get descriptionColumn;

  /// No description provided for @amountColumn.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amountColumn;

  /// No description provided for @yourprojects.
  ///
  /// In en, this message translates to:
  /// **'My Project'**
  String get yourprojects;

  /// No description provided for @addProject.
  ///
  /// In en, this message translates to:
  /// **'Post Job'**
  String get addProject;

  /// No description provided for @find_Work.
  ///
  /// In en, this message translates to:
  /// **'Find Work'**
  String get find_Work;

  /// No description provided for @enterQualification.
  ///
  /// In en, this message translates to:
  /// **'Enter your Qualification'**
  String get enterQualification;

  /// No description provided for @experience.
  ///
  /// In en, this message translates to:
  /// **'Experience'**
  String get experience;

  /// No description provided for @selectCity.
  ///
  /// In en, this message translates to:
  /// **'Select City'**
  String get selectCity;

  /// No description provided for @selectCityError.
  ///
  /// In en, this message translates to:
  /// **'Please select a city'**
  String get selectCityError;

  /// No description provided for @selectedQualification.
  ///
  /// In en, this message translates to:
  /// **'Selected Qualification'**
  String get selectedQualification;

  /// No description provided for @selectExperienceError.
  ///
  /// In en, this message translates to:
  /// **'Please select an experience'**
  String get selectExperienceError;

  /// No description provided for @selectCityHindi.
  ///
  /// In en, this message translates to:
  /// **'Select City'**
  String get selectCityHindi;

  /// No description provided for @actions.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get actions;

  /// No description provided for @projectApplications.
  ///
  /// In en, this message translates to:
  /// **'Project Applications'**
  String get projectApplications;

  /// No description provided for @noApplicationsFound.
  ///
  /// In en, this message translates to:
  /// **'No applications found'**
  String get noApplicationsFound;

  /// No description provided for @labourName.
  ///
  /// In en, this message translates to:
  /// **'Worker Name'**
  String get labourName;

  /// No description provided for @comment.
  ///
  /// In en, this message translates to:
  /// **'Comment'**
  String get comment;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @notAssigned.
  ///
  /// In en, this message translates to:
  /// **'Not Assigned'**
  String get notAssigned;

  /// No description provided for @assigned.
  ///
  /// In en, this message translates to:
  /// **'Assigned'**
  String get assigned;

  /// No description provided for @workStarted.
  ///
  /// In en, this message translates to:
  /// **'Work Started'**
  String get workStarted;

  /// No description provided for @workStart.
  ///
  /// In en, this message translates to:
  /// **'Work Start'**
  String get workStart;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @cancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get cancelled;

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get viewDetails;

  /// No description provided for @applicationDetails.
  ///
  /// In en, this message translates to:
  /// **'Application Details'**
  String get applicationDetails;

  /// No description provided for @proposalDuration.
  ///
  /// In en, this message translates to:
  /// **'Proposal Duration'**
  String get proposalDuration;

  /// No description provided for @remarks.
  ///
  /// In en, this message translates to:
  /// **'Remarks'**
  String get remarks;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @proposalAmount.
  ///
  /// In en, this message translates to:
  /// **'Proposal Amount'**
  String get proposalAmount;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @submitted.
  ///
  /// In en, this message translates to:
  /// **'Submitted'**
  String get submitted;

  /// No description provided for @proceed.
  ///
  /// In en, this message translates to:
  /// **'Proceed'**
  String get proceed;

  /// No description provided for @assignProject.
  ///
  /// In en, this message translates to:
  /// **'Assign Project'**
  String get assignProject;

  /// No description provided for @cancelAssignment.
  ///
  /// In en, this message translates to:
  /// **'Cancel Assignment'**
  String get cancelAssignment;

  /// No description provided for @cancelWork.
  ///
  /// In en, this message translates to:
  /// **'Cancel Work'**
  String get cancelWork;

  /// No description provided for @cancelledRequested.
  ///
  /// In en, this message translates to:
  /// **'Cancelled Requested'**
  String get cancelledRequested;

  /// No description provided for @completedRequested.
  ///
  /// In en, this message translates to:
  /// **'Completed Requested'**
  String get completedRequested;

  /// No description provided for @completedDate.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completedDate;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @apply_now.
  ///
  /// In en, this message translates to:
  /// **'Apply Now'**
  String get apply_now;

  /// No description provided for @applied.
  ///
  /// In en, this message translates to:
  /// **'Applied'**
  String get applied;

  /// No description provided for @working_days.
  ///
  /// In en, this message translates to:
  /// **'Working Days'**
  String get working_days;
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
      <String>['en', 'hi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
