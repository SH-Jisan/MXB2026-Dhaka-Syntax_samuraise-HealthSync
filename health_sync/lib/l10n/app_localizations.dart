import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_bn.dart';
import 'app_localizations_en.dart';

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
    Locale('bn'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'HealthSync'**
  String get appTitle;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue'**
  String get loginSubtitle;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'LOG IN'**
  String get loginButton;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// No description provided for @signupLink.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signupLink;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @bangla.
  ///
  /// In en, this message translates to:
  /// **'Bangla'**
  String get bangla;

  /// No description provided for @bloodBank.
  ///
  /// In en, this message translates to:
  /// **'Blood Bank'**
  String get bloodBank;

  /// No description provided for @bloodBankSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Find donors & Request blood'**
  String get bloodBankSubtitle;

  /// No description provided for @aboutApp.
  ///
  /// In en, this message translates to:
  /// **'About App'**
  String get aboutApp;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong!'**
  String get somethingWentWrong;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @userNotFound.
  ///
  /// In en, this message translates to:
  /// **'User not found'**
  String get userNotFound;

  /// No description provided for @myMedicalHistory.
  ///
  /// In en, this message translates to:
  /// **'My Medical History'**
  String get myMedicalHistory;

  /// No description provided for @healthPlan.
  ///
  /// In en, this message translates to:
  /// **'Health Plan'**
  String get healthPlan;

  /// No description provided for @myProfile.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get myProfile;

  /// No description provided for @timeline.
  ///
  /// In en, this message translates to:
  /// **'Timeline'**
  String get timeline;

  /// No description provided for @doctorPanel.
  ///
  /// In en, this message translates to:
  /// **'Doctor Panel'**
  String get doctorPanel;

  /// No description provided for @myHealthPlan.
  ///
  /// In en, this message translates to:
  /// **'My Health Plan'**
  String get myHealthPlan;

  /// No description provided for @panel.
  ///
  /// In en, this message translates to:
  /// **'Panel'**
  String get panel;

  /// No description provided for @addHospital.
  ///
  /// In en, this message translates to:
  /// **'Add Hospital'**
  String get addHospital;

  /// No description provided for @hospitalName.
  ///
  /// In en, this message translates to:
  /// **'Hospital Name'**
  String get hospitalName;

  /// No description provided for @visitingHours.
  ///
  /// In en, this message translates to:
  /// **'Visiting Hours (e.g. 5-9 PM)'**
  String get visitingHours;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @addNewPatient.
  ///
  /// In en, this message translates to:
  /// **'Add New Patient'**
  String get addNewPatient;

  /// No description provided for @patientEmail.
  ///
  /// In en, this message translates to:
  /// **'Patient Email'**
  String get patientEmail;

  /// No description provided for @enterEmailSearch.
  ///
  /// In en, this message translates to:
  /// **'Enter email to search'**
  String get enterEmailSearch;

  /// No description provided for @patientAddedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Patient Added Successfully!'**
  String get patientAddedSuccess;

  /// No description provided for @alreadyAssignedOrError.
  ///
  /// In en, this message translates to:
  /// **'Already assigned or Error'**
  String get alreadyAssignedOrError;

  /// No description provided for @currentChambers.
  ///
  /// In en, this message translates to:
  /// **'Current Chambers'**
  String get currentChambers;

  /// No description provided for @noHospitalsAdded.
  ///
  /// In en, this message translates to:
  /// **'No hospitals added.'**
  String get noHospitalsAdded;

  /// No description provided for @underTreatment.
  ///
  /// In en, this message translates to:
  /// **'Under Treatment'**
  String get underTreatment;

  /// No description provided for @newPatient.
  ///
  /// In en, this message translates to:
  /// **'New Patient'**
  String get newPatient;

  /// No description provided for @addReport.
  ///
  /// In en, this message translates to:
  /// **'Add Report'**
  String get addReport;

  /// No description provided for @logoutConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get logoutConfirmation;

  /// No description provided for @personalInformation.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInformation;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @settingsActivity.
  ///
  /// In en, this message translates to:
  /// **'Settings & Activity'**
  String get settingsActivity;

  /// No description provided for @myAppointmentsHistory.
  ///
  /// In en, this message translates to:
  /// **'My Appointments & History'**
  String get myAppointmentsHistory;

  /// No description provided for @myBloodRequests.
  ///
  /// In en, this message translates to:
  /// **'My Blood Requests'**
  String get myBloodRequests;

  /// No description provided for @myAssociatedHospitals.
  ///
  /// In en, this message translates to:
  /// **'My Associated Hospitals'**
  String get myAssociatedHospitals;

  /// No description provided for @notAssignedToHospital.
  ///
  /// In en, this message translates to:
  /// **'Not assigned to any hospital yet.'**
  String get notAssignedToHospital;

  /// No description provided for @noAddress.
  ///
  /// In en, this message translates to:
  /// **'No address'**
  String get noAddress;

  /// No description provided for @patientHistory.
  ///
  /// In en, this message translates to:
  /// **'Patient History'**
  String get patientHistory;

  /// No description provided for @myPrescriptions.
  ///
  /// In en, this message translates to:
  /// **'My Prescriptions'**
  String get myPrescriptions;

  /// No description provided for @myReports.
  ///
  /// In en, this message translates to:
  /// **'My Reports'**
  String get myReports;

  /// No description provided for @viewPresc.
  ///
  /// In en, this message translates to:
  /// **'View Prescription'**
  String get viewPresc;

  /// No description provided for @viewReport.
  ///
  /// In en, this message translates to:
  /// **'View Report'**
  String get viewReport;

  /// No description provided for @myCareHistory.
  ///
  /// In en, this message translates to:
  /// **'My Care History'**
  String get myCareHistory;

  /// No description provided for @appointments.
  ///
  /// In en, this message translates to:
  /// **'Appointments'**
  String get appointments;

  /// No description provided for @prescriptions.
  ///
  /// In en, this message translates to:
  /// **'Prescriptions'**
  String get prescriptions;

  /// No description provided for @diagnostic.
  ///
  /// In en, this message translates to:
  /// **'Diagnostic'**
  String get diagnostic;

  /// No description provided for @hospitals.
  ///
  /// In en, this message translates to:
  /// **'Hospitals'**
  String get hospitals;

  /// No description provided for @noAppointmentsFound.
  ///
  /// In en, this message translates to:
  /// **'No appointments found.'**
  String get noAppointmentsFound;

  /// No description provided for @unknownDoctor.
  ///
  /// In en, this message translates to:
  /// **'Unknown Doctor'**
  String get unknownDoctor;

  /// No description provided for @unknownHospital.
  ///
  /// In en, this message translates to:
  /// **'Unknown Hospital'**
  String get unknownHospital;

  /// No description provided for @specialist.
  ///
  /// In en, this message translates to:
  /// **'Specialist'**
  String get specialist;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'PENDING'**
  String get pending;

  /// No description provided for @confirmed.
  ///
  /// In en, this message translates to:
  /// **'CONFIRMED'**
  String get confirmed;

  /// No description provided for @noPrescriptionsFound.
  ///
  /// In en, this message translates to:
  /// **'No prescriptions found.'**
  String get noPrescriptionsFound;

  /// No description provided for @rx.
  ///
  /// In en, this message translates to:
  /// **'Rx:'**
  String get rx;

  /// No description provided for @noDiagnosticRecords.
  ///
  /// In en, this message translates to:
  /// **'No diagnostic records.'**
  String get noDiagnosticRecords;

  /// No description provided for @saveLifeToday.
  ///
  /// In en, this message translates to:
  /// **'Save a Life Today'**
  String get saveLifeToday;

  /// No description provided for @chooseOption.
  ///
  /// In en, this message translates to:
  /// **'Choose an option below to proceed'**
  String get chooseOption;

  /// No description provided for @requestBlood.
  ///
  /// In en, this message translates to:
  /// **'Request for Blood'**
  String get requestBlood;

  /// No description provided for @findDonorsNearby.
  ///
  /// In en, this message translates to:
  /// **'Find donors nearby instantly'**
  String get findDonorsNearby;

  /// No description provided for @becomeDonor.
  ///
  /// In en, this message translates to:
  /// **'Become a Donor'**
  String get becomeDonor;

  /// No description provided for @registerToSaveLives.
  ///
  /// In en, this message translates to:
  /// **'Register to save lives'**
  String get registerToSaveLives;

  /// No description provided for @findBloodDonors.
  ///
  /// In en, this message translates to:
  /// **'Find Blood Donors'**
  String get findBloodDonors;

  /// No description provided for @searchByGroupLocation.
  ///
  /// In en, this message translates to:
  /// **'Search by group & location'**
  String get searchByGroupLocation;

  /// No description provided for @liveRequestsFeed.
  ///
  /// In en, this message translates to:
  /// **'Live Requests (Feed)'**
  String get liveRequestsFeed;

  /// No description provided for @seeWhoNeedsHelp.
  ///
  /// In en, this message translates to:
  /// **'See who needs help right now'**
  String get seeWhoNeedsHelp;

  /// No description provided for @myRequestsHistory.
  ///
  /// In en, this message translates to:
  /// **'My Requests & History'**
  String get myRequestsHistory;

  /// No description provided for @trackYourRequests.
  ///
  /// In en, this message translates to:
  /// **'Track your requests'**
  String get trackYourRequests;

  /// No description provided for @myRequests.
  ///
  /// In en, this message translates to:
  /// **'My Requests'**
  String get myRequests;

  /// No description provided for @couldNotLaunchDialer.
  ///
  /// In en, this message translates to:
  /// **'Could not launch dialer'**
  String get couldNotLaunchDialer;

  /// No description provided for @group.
  ///
  /// In en, this message translates to:
  /// **'Group'**
  String get group;

  /// No description provided for @districtHint.
  ///
  /// In en, this message translates to:
  /// **'District (e.g. Dhaka)'**
  String get districtHint;

  /// No description provided for @searchDonors.
  ///
  /// In en, this message translates to:
  /// **'SEARCH DONORS'**
  String get searchDonors;

  /// No description provided for @noDonorsFound.
  ///
  /// In en, this message translates to:
  /// **'No donors found'**
  String get noDonorsFound;

  /// No description provided for @tryChangingLocation.
  ///
  /// In en, this message translates to:
  /// **'Try changing the location or blood group.'**
  String get tryChangingLocation;

  /// No description provided for @unknownDonor.
  ///
  /// In en, this message translates to:
  /// **'Unknown Donor'**
  String get unknownDonor;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @lastDonated.
  ///
  /// In en, this message translates to:
  /// **'Last donated: '**
  String get lastDonated;

  /// No description provided for @thankYouHero.
  ///
  /// In en, this message translates to:
  /// **'Thank You, Hero! '**
  String get thankYouHero;

  /// No description provided for @acceptedDonationMessage.
  ///
  /// In en, this message translates to:
  /// **'You have accepted to donate blood. Please contact the patient immediately.'**
  String get acceptedDonationMessage;

  /// No description provided for @tapToCall.
  ///
  /// In en, this message translates to:
  /// **'Tap to call'**
  String get tapToCall;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'CLOSE'**
  String get close;

  /// No description provided for @alreadyAccepted.
  ///
  /// In en, this message translates to:
  /// **'You have already accepted this request!'**
  String get alreadyAccepted;

  /// No description provided for @unexpectedError.
  ///
  /// In en, this message translates to:
  /// **'Unexpected Error: '**
  String get unexpectedError;

  /// No description provided for @liveBloodRequests.
  ///
  /// In en, this message translates to:
  /// **'Live Blood Requests'**
  String get liveBloodRequests;

  /// No description provided for @postRequest.
  ///
  /// In en, this message translates to:
  /// **'Post Request'**
  String get postRequest;

  /// No description provided for @noPendingRequests.
  ///
  /// In en, this message translates to:
  /// **'No pending requests right now!'**
  String get noPendingRequests;

  /// No description provided for @caughtUp.
  ///
  /// In en, this message translates to:
  /// **'You are all caught up.'**
  String get caughtUp;

  /// No description provided for @criticalUrgency.
  ///
  /// In en, this message translates to:
  /// **'CRITICAL URGENCY'**
  String get criticalUrgency;

  /// No description provided for @requestedBy.
  ///
  /// In en, this message translates to:
  /// **'Requested by '**
  String get requestedBy;

  /// No description provided for @donorsFound.
  ///
  /// In en, this message translates to:
  /// **'Donors Found'**
  String get donorsFound;

  /// No description provided for @iCanDonate.
  ///
  /// In en, this message translates to:
  /// **'I CAN DONATE'**
  String get iCanDonate;

  /// No description provided for @myRequestsDonors.
  ///
  /// In en, this message translates to:
  /// **'My Requests & Donors'**
  String get myRequestsDonors;

  /// No description provided for @noRequestsYet.
  ///
  /// In en, this message translates to:
  /// **'No Requests Yet'**
  String get noRequestsYet;

  /// No description provided for @noRequestsPosted.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t posted any blood requests.'**
  String get noRequestsPosted;

  /// No description provided for @waitingForDonors.
  ///
  /// In en, this message translates to:
  /// **'Waiting for donors...'**
  String get waitingForDonors;

  /// No description provided for @donorsAccepted.
  ///
  /// In en, this message translates to:
  /// **'Donor(s) Accepted'**
  String get donorsAccepted;

  /// No description provided for @notifiedDonors.
  ///
  /// In en, this message translates to:
  /// **'We have notified nearby donors.'**
  String get notifiedDonors;

  /// No description provided for @willSeeDetails.
  ///
  /// In en, this message translates to:
  /// **'You will see their details here once they accept.'**
  String get willSeeDetails;

  /// No description provided for @unknownHero.
  ///
  /// In en, this message translates to:
  /// **'Unknown Hero'**
  String get unknownHero;

  /// No description provided for @heroDonor.
  ///
  /// In en, this message translates to:
  /// **'Hero Donor'**
  String get heroDonor;

  /// No description provided for @requestBloodTitle.
  ///
  /// In en, this message translates to:
  /// **'Request Blood'**
  String get requestBloodTitle;

  /// No description provided for @aiAutofillSuccess.
  ///
  /// In en, this message translates to:
  /// **'Form autofilled by AI! Please review.'**
  String get aiAutofillSuccess;

  /// No description provided for @aiError.
  ///
  /// In en, this message translates to:
  /// **'AI Error: '**
  String get aiError;

  /// No description provided for @selectBloodGroupError.
  ///
  /// In en, this message translates to:
  /// **'Please select Blood Group'**
  String get selectBloodGroupError;

  /// No description provided for @requestPostedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Request Posted! Notifying nearby donors... '**
  String get requestPostedSuccess;

  /// No description provided for @errorPostingRequest.
  ///
  /// In en, this message translates to:
  /// **'Error posting request: '**
  String get errorPostingRequest;

  /// No description provided for @quickAiFill.
  ///
  /// In en, this message translates to:
  /// **'Quick AI Fill'**
  String get quickAiFill;

  /// No description provided for @aiPrompt.
  ///
  /// In en, this message translates to:
  /// **'Type or speak your need naturally'**
  String get aiPrompt;

  /// No description provided for @aiHint.
  ///
  /// In en, this message translates to:
  /// **'Example: \"Urgent A+ blood needed at Dhaka Medical College for a road accident patient...\"'**
  String get aiHint;

  /// No description provided for @processing.
  ///
  /// In en, this message translates to:
  /// **'Processing...'**
  String get processing;

  /// No description provided for @autoFillWithAi.
  ///
  /// In en, this message translates to:
  /// **'Auto-Fill Form with AI'**
  String get autoFillWithAi;

  /// No description provided for @manualEntry.
  ///
  /// In en, this message translates to:
  /// **'Manual Entry'**
  String get manualEntry;

  /// No description provided for @bloodGroup.
  ///
  /// In en, this message translates to:
  /// **'Blood Group'**
  String get bloodGroup;

  /// No description provided for @selectGroup.
  ///
  /// In en, this message translates to:
  /// **'Select Group'**
  String get selectGroup;

  /// No description provided for @hospitalLocation.
  ///
  /// In en, this message translates to:
  /// **'Hospital / Location'**
  String get hospitalLocation;

  /// No description provided for @enterHospitalHelper.
  ///
  /// In en, this message translates to:
  /// **'Enter hospital name & area'**
  String get enterHospitalHelper;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// No description provided for @urgencyLevel.
  ///
  /// In en, this message translates to:
  /// **'Urgency Level'**
  String get urgencyLevel;

  /// No description provided for @selectUrgency.
  ///
  /// In en, this message translates to:
  /// **'Select Urgency'**
  String get selectUrgency;

  /// No description provided for @normal.
  ///
  /// In en, this message translates to:
  /// **'NORMAL'**
  String get normal;

  /// No description provided for @critical.
  ///
  /// In en, this message translates to:
  /// **'CRITICAL'**
  String get critical;

  /// No description provided for @patientConditionNote.
  ///
  /// In en, this message translates to:
  /// **'Patient Condition / Note'**
  String get patientConditionNote;

  /// No description provided for @describeSituation.
  ///
  /// In en, this message translates to:
  /// **'Describe the situation...'**
  String get describeSituation;

  /// No description provided for @postBloodRequest.
  ///
  /// In en, this message translates to:
  /// **'POST BLOOD REQUEST'**
  String get postBloodRequest;

  /// No description provided for @plan.
  ///
  /// In en, this message translates to:
  /// **'Your Plan'**
  String get plan;

  /// No description provided for @noPatientsAssigned.
  ///
  /// In en, this message translates to:
  /// **'No patients assigned yet.'**
  String get noPatientsAssigned;

  /// No description provided for @hospitalAdmissionHistory.
  ///
  /// In en, this message translates to:
  /// **'Hospital Admission History'**
  String get hospitalAdmissionHistory;

  /// No description provided for @aiHealthAssistant.
  ///
  /// In en, this message translates to:
  /// **'AI Health Assistant'**
  String get aiHealthAssistant;

  /// No description provided for @describeSymptomsHint.
  ///
  /// In en, this message translates to:
  /// **'Describe your symptoms (e.g., \'Severe chest pain on left side\')...'**
  String get describeSymptomsHint;

  /// No description provided for @consultAiDoctor.
  ///
  /// In en, this message translates to:
  /// **'CONSULT AI DOCTOR'**
  String get consultAiDoctor;

  /// No description provided for @aiDiagnosis.
  ///
  /// In en, this message translates to:
  /// **'AI Diagnosis'**
  String get aiDiagnosis;

  /// No description provided for @possibleCondition.
  ///
  /// In en, this message translates to:
  /// **'Possible Condition:'**
  String get possibleCondition;

  /// No description provided for @potentialCauses.
  ///
  /// In en, this message translates to:
  /// **'Potential Causes (Why?):'**
  String get potentialCauses;

  /// No description provided for @recommendedSpecialist.
  ///
  /// In en, this message translates to:
  /// **'Recommended Specialist:'**
  String get recommendedSpecialist;

  /// No description provided for @immediateAdvice.
  ///
  /// In en, this message translates to:
  /// **'Immediate Advice:'**
  String get immediateAdvice;

  /// No description provided for @findSpecialistNow.
  ///
  /// In en, this message translates to:
  /// **'FIND {specialty} NOW'**
  String findSpecialistNow(String specialty);

  /// No description provided for @reportDetails.
  ///
  /// In en, this message translates to:
  /// **'Report Details'**
  String get reportDetails;

  /// No description provided for @shareComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Share feature coming soon!'**
  String get shareComingSoon;

  /// No description provided for @typeLabel.
  ///
  /// In en, this message translates to:
  /// **'Type:'**
  String get typeLabel;

  /// No description provided for @aiAnalysisSummary.
  ///
  /// In en, this message translates to:
  /// **'AI Analysis Summary'**
  String get aiAnalysisSummary;

  /// No description provided for @generatedByAi.
  ///
  /// In en, this message translates to:
  /// **'Generated by HealthSync AI'**
  String get generatedByAi;

  /// No description provided for @noAttachment.
  ///
  /// In en, this message translates to:
  /// **'No attachment available'**
  String get noAttachment;

  /// No description provided for @severityHigh.
  ///
  /// In en, this message translates to:
  /// **'HIGH'**
  String get severityHigh;

  /// No description provided for @severityMedium.
  ///
  /// In en, this message translates to:
  /// **'MEDIUM'**
  String get severityMedium;

  /// No description provided for @severityNormal.
  ///
  /// In en, this message translates to:
  /// **'NORMAL'**
  String get severityNormal;
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
      <String>['bn', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'bn':
      return AppLocalizationsBn();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
