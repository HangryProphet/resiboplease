import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fil.dart';

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
    Locale('fil'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Resibo, Please'**
  String get appTitle;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose the language used throughout the game.'**
  String get languageDescription;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'Device language'**
  String get languageSystem;

  /// No description provided for @languageSystemDescription.
  ///
  /// In en, this message translates to:
  /// **'Use your phone or browser language when supported.'**
  String get languageSystemDescription;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageEnglishDescription.
  ///
  /// In en, this message translates to:
  /// **'Play using English text.'**
  String get languageEnglishDescription;

  /// No description provided for @languageFilipino.
  ///
  /// In en, this message translates to:
  /// **'Filipino'**
  String get languageFilipino;

  /// No description provided for @languageFilipinoDescription.
  ///
  /// In en, this message translates to:
  /// **'Maglaro gamit ang tekstong Filipino.'**
  String get languageFilipinoDescription;

  /// No description provided for @accessibility.
  ///
  /// In en, this message translates to:
  /// **'Accessibility'**
  String get accessibility;

  /// No description provided for @reduceMotion.
  ///
  /// In en, this message translates to:
  /// **'Reduce motion'**
  String get reduceMotion;

  /// No description provided for @reduceMotionDescription.
  ///
  /// In en, this message translates to:
  /// **'Use simpler transitions and stop decorative movement. Device reduced-motion settings are always respected.'**
  String get reduceMotionDescription;

  /// No description provided for @highContrast.
  ///
  /// In en, this message translates to:
  /// **'High contrast'**
  String get highContrast;

  /// No description provided for @highContrastDescription.
  ///
  /// In en, this message translates to:
  /// **'Strengthen text, border, and surface contrast for easier reading.'**
  String get highContrastDescription;

  /// No description provided for @deviceTextSize.
  ///
  /// In en, this message translates to:
  /// **'Text size follows your device'**
  String get deviceTextSize;

  /// No description provided for @deviceTextSizeDescription.
  ///
  /// In en, this message translates to:
  /// **'Resibo, Please respects the font size selected in your device accessibility settings.'**
  String get deviceTextSizeDescription;

  /// No description provided for @information.
  ///
  /// In en, this message translates to:
  /// **'Information'**
  String get information;

  /// No description provided for @aboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About Resibo, Please'**
  String get aboutTitle;

  /// No description provided for @aboutBody.
  ///
  /// In en, this message translates to:
  /// **'Resibo, Please is a fictional civic decision simulation about evidence, policy tradeoffs, and the consequences of voting choices. It does not endorse real candidates or parties.'**
  String get aboutBody;

  /// No description provided for @creditsTitle.
  ///
  /// In en, this message translates to:
  /// **'Credits'**
  String get creditsTitle;

  /// No description provided for @creditsBody.
  ///
  /// In en, this message translates to:
  /// **'Created as an independent educational game prototype. Design, writing, programming, and original fictional content by the Resibo, Please project team.'**
  String get creditsBody;

  /// No description provided for @disclaimerTitle.
  ///
  /// In en, this message translates to:
  /// **'Disclaimer'**
  String get disclaimerTitle;

  /// No description provided for @disclaimerBody.
  ///
  /// In en, this message translates to:
  /// **'Every city, candidate, party, media outlet, and event is fictional. This game is not official election guidance and must not replace verified information about real elections.'**
  String get disclaimerBody;

  /// No description provided for @privacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy notice'**
  String get privacyTitle;

  /// No description provided for @privacyBody.
  ///
  /// In en, this message translates to:
  /// **'This prototype stores settings and fictional city runs on your device so they survive app restarts. It does not require an account or transmit personal information or city saves to a game server. Clearing site or app storage may remove local saves. This notice must be reviewed before any online features are released.'**
  String get privacyBody;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'App version'**
  String get appVersion;

  /// No description provided for @appVersionValue.
  ///
  /// In en, this message translates to:
  /// **'1.0.0 (1)'**
  String get appVersionValue;

  /// No description provided for @resetSettings.
  ///
  /// In en, this message translates to:
  /// **'Reset settings'**
  String get resetSettings;

  /// No description provided for @resetSettingsDescription.
  ///
  /// In en, this message translates to:
  /// **'Restore device language, standard contrast, and normal in-game motion. City files are not deleted.'**
  String get resetSettingsDescription;

  /// No description provided for @resetSettingsQuestion.
  ///
  /// In en, this message translates to:
  /// **'Reset all settings?'**
  String get resetSettingsQuestion;

  /// No description provided for @resetSettingsConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Language and accessibility preferences will return to their defaults. City files will stay untouched.'**
  String get resetSettingsConfirmation;

  /// No description provided for @settingsResetNotice.
  ///
  /// In en, this message translates to:
  /// **'Settings restored to defaults.'**
  String get settingsResetNotice;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @understood.
  ///
  /// In en, this message translates to:
  /// **'Understood'**
  String get understood;

  /// No description provided for @gotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get gotIt;

  /// No description provided for @on.
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get on;

  /// No description provided for @off.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get off;

  /// No description provided for @standard.
  ///
  /// In en, this message translates to:
  /// **'Standard'**
  String get standard;

  /// No description provided for @enabled.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get enabled;

  /// No description provided for @disabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get disabled;

  /// No description provided for @mainMenu.
  ///
  /// In en, this message translates to:
  /// **'Main menu'**
  String get mainMenu;

  /// No description provided for @backToMainMenu.
  ///
  /// In en, this message translates to:
  /// **'Back to Main Menu'**
  String get backToMainMenu;

  /// No description provided for @startNewCity.
  ///
  /// In en, this message translates to:
  /// **'Start New City'**
  String get startNewCity;

  /// No description provided for @continueCity.
  ///
  /// In en, this message translates to:
  /// **'Continue City'**
  String get continueCity;

  /// No description provided for @howToPlay.
  ///
  /// In en, this message translates to:
  /// **'How to Play'**
  String get howToPlay;

  /// No description provided for @visitCities.
  ///
  /// In en, this message translates to:
  /// **'Visit Cities'**
  String get visitCities;

  /// No description provided for @fictionalDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'A fictional civic decision simulation.\nNot official election guidance.'**
  String get fictionalDisclaimer;

  /// No description provided for @visitCitiesBody.
  ///
  /// In en, this message translates to:
  /// **'City visits use safe, asynchronous snapshots—not live multiplayer. This space is reserved while local snapshot publishing is built.'**
  String get visitCitiesBody;

  /// No description provided for @menuBackgroundSemantics.
  ///
  /// In en, this message translates to:
  /// **'A civic hall, neighborhoods, clinic, school, drainage canal, and waterfront.'**
  String get menuBackgroundSemantics;

  /// No description provided for @candidateGroupSemantics.
  ///
  /// In en, this message translates to:
  /// **'Mayoral candidates Julian Pratt, Maya Vargas, and Victor Chen.'**
  String get candidateGroupSemantics;

  /// No description provided for @logoSemantics.
  ///
  /// In en, this message translates to:
  /// **'Resibo, Please'**
  String get logoSemantics;

  /// No description provided for @splash1.
  ///
  /// In en, this message translates to:
  /// **'Find the receipts.'**
  String get splash1;

  /// No description provided for @splash2.
  ///
  /// In en, this message translates to:
  /// **'Style or platform?'**
  String get splash2;

  /// No description provided for @splash3.
  ///
  /// In en, this message translates to:
  /// **'Facts before fanfare.'**
  String get splash3;

  /// No description provided for @splash4.
  ///
  /// In en, this message translates to:
  /// **'Check the source first.'**
  String get splash4;

  /// No description provided for @splash5.
  ///
  /// In en, this message translates to:
  /// **'The city remembers.'**
  String get splash5;

  /// No description provided for @splash6.
  ///
  /// In en, this message translates to:
  /// **'Popularity is not proof.'**
  String get splash6;

  /// No description provided for @splash7.
  ///
  /// In en, this message translates to:
  /// **'Read the fine print.'**
  String get splash7;

  /// No description provided for @splash8.
  ///
  /// In en, this message translates to:
  /// **'No receipt, less trust.'**
  String get splash8;

  /// No description provided for @splash9.
  ///
  /// In en, this message translates to:
  /// **'Promises are easy to say.'**
  String get splash9;

  /// No description provided for @splash10.
  ///
  /// In en, this message translates to:
  /// **'Vote now, consequences later.'**
  String get splash10;

  /// No description provided for @splash11.
  ///
  /// In en, this message translates to:
  /// **'Not all noise is policy.'**
  String get splash11;

  /// No description provided for @splash12.
  ///
  /// In en, this message translates to:
  /// **'A plan—or only a slogan?'**
  String get splash12;

  /// No description provided for @voterPocketGuide.
  ///
  /// In en, this message translates to:
  /// **'The voter\'s pocket guide'**
  String get voterPocketGuide;

  /// No description provided for @youAreTheVoter.
  ///
  /// In en, this message translates to:
  /// **'You are the voter'**
  String get youAreTheVoter;

  /// No description provided for @youAreTheVoterBody.
  ///
  /// In en, this message translates to:
  /// **'Help a fictional city, one election at a time. Look for good evidence, make a choice, and live with the result.'**
  String get youAreTheVoterBody;

  /// No description provided for @guideReadCity.
  ///
  /// In en, this message translates to:
  /// **'Read the city'**
  String get guideReadCity;

  /// No description provided for @guideReadCityBody.
  ///
  /// In en, this message translates to:
  /// **'See what is going wrong and which problems need attention first.'**
  String get guideReadCityBody;

  /// No description provided for @guideCheckCandidates.
  ///
  /// In en, this message translates to:
  /// **'Check the candidates'**
  String get guideCheckCandidates;

  /// No description provided for @guideCheckCandidatesBody.
  ///
  /// In en, this message translates to:
  /// **'Open their files. Compare promises, records, and sources. Noise is not proof.'**
  String get guideCheckCandidatesBody;

  /// No description provided for @guideChoose.
  ///
  /// In en, this message translates to:
  /// **'Choose for yourself'**
  String get guideChoose;

  /// No description provided for @guideChooseBody.
  ///
  /// In en, this message translates to:
  /// **'Cast your vote. The game will not tell you who is best.'**
  String get guideChooseBody;

  /// No description provided for @guideWatchTerm.
  ///
  /// In en, this message translates to:
  /// **'Watch the term'**
  String get guideWatchTerm;

  /// No description provided for @guideWatchTermBody.
  ///
  /// In en, this message translates to:
  /// **'Your choice governs. Plans, skill, honesty, money, and surprise events shape the city.'**
  String get guideWatchTermBody;

  /// No description provided for @guideFindReceipts.
  ///
  /// In en, this message translates to:
  /// **'Find the receipts'**
  String get guideFindReceipts;

  /// No description provided for @guideFindReceiptsBody.
  ///
  /// In en, this message translates to:
  /// **'See what improved, what got worse, and why. Then carry that city into the next election.'**
  String get guideFindReceiptsBody;

  /// No description provided for @remember.
  ///
  /// In en, this message translates to:
  /// **'Remember'**
  String get remember;

  /// No description provided for @guideRememberBody.
  ///
  /// In en, this message translates to:
  /// **'There is no perfect candidate and no hidden match score. Compare the evidence, decide what matters, and own the tradeoffs.'**
  String get guideRememberBody;

  /// No description provided for @cityHallRecords.
  ///
  /// In en, this message translates to:
  /// **'City hall records'**
  String get cityHallRecords;

  /// No description provided for @cityArchive.
  ///
  /// In en, this message translates to:
  /// **'City archive'**
  String get cityArchive;

  /// No description provided for @newCityPermit.
  ///
  /// In en, this message translates to:
  /// **'New city permit'**
  String get newCityPermit;

  /// No description provided for @recordsWarning.
  ///
  /// In en, this message translates to:
  /// **'Records division warning'**
  String get recordsWarning;

  /// No description provided for @configureNewCity.
  ///
  /// In en, this message translates to:
  /// **'Configure New City'**
  String get configureNewCity;

  /// No description provided for @deleteCityQuestion.
  ///
  /// In en, this message translates to:
  /// **'Delete City?'**
  String get deleteCityQuestion;

  /// No description provided for @backToSaveSlots.
  ///
  /// In en, this message translates to:
  /// **'Back to save slots'**
  String get backToSaveSlots;

  /// No description provided for @backToMainMenuTooltip.
  ///
  /// In en, this message translates to:
  /// **'Back to main menu'**
  String get backToMainMenuTooltip;

  /// No description provided for @startCityIntro.
  ///
  /// In en, this message translates to:
  /// **'Choose an empty file. Your new city will be kept in that save slot.'**
  String get startCityIntro;

  /// No description provided for @continueCityIntro.
  ///
  /// In en, this message translates to:
  /// **'Choose a city file to continue, or use the red button to delete it.'**
  String get continueCityIntro;

  /// No description provided for @emptyCityFile.
  ///
  /// In en, this message translates to:
  /// **'Empty city file'**
  String get emptyCityFile;

  /// No description provided for @tapToRegisterCity.
  ///
  /// In en, this message translates to:
  /// **'Tap to register a new city.'**
  String get tapToRegisterCity;

  /// No description provided for @noSavedCityHere.
  ///
  /// In en, this message translates to:
  /// **'No saved city here yet.'**
  String get noSavedCityHere;

  /// No description provided for @occupied.
  ///
  /// In en, this message translates to:
  /// **'Occupied'**
  String get occupied;

  /// No description provided for @current.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get current;

  /// No description provided for @slot.
  ///
  /// In en, this message translates to:
  /// **'Slot'**
  String get slot;

  /// No description provided for @saveSlotNumber.
  ///
  /// In en, this message translates to:
  /// **'Save slot {number}'**
  String saveSlotNumber(int number);

  /// No description provided for @allSlotsOccupied.
  ///
  /// In en, this message translates to:
  /// **'All five files are occupied. Open Continue City and delete a file before starting another.'**
  String get allSlotsOccupied;

  /// No description provided for @startANewCity.
  ///
  /// In en, this message translates to:
  /// **'Start a New City'**
  String get startANewCity;

  /// No description provided for @electionBriefProgress.
  ///
  /// In en, this message translates to:
  /// **'Election brief'**
  String get electionBriefProgress;

  /// No description provided for @termInProgressProgress.
  ///
  /// In en, this message translates to:
  /// **'Term in progress'**
  String get termInProgressProgress;

  /// No description provided for @termReportReadyProgress.
  ///
  /// In en, this message translates to:
  /// **'Term report ready'**
  String get termReportReadyProgress;

  /// No description provided for @caseTermLabel.
  ///
  /// In en, this message translates to:
  /// **'{scenario} case • Term {term}'**
  String caseTermLabel(String scenario, int term);

  /// No description provided for @shredCityQuestion.
  ///
  /// In en, this message translates to:
  /// **'Shred “{city}”?'**
  String shredCityQuestion(String city);

  /// No description provided for @deleteCityBody.
  ///
  /// In en, this message translates to:
  /// **'This removes the city from Save Slot {slot}. Its election history and progress cannot be recovered.'**
  String deleteCityBody(int slot);

  /// No description provided for @cannotBeUndone.
  ///
  /// In en, this message translates to:
  /// **'This cannot be undone'**
  String get cannotBeUndone;

  /// No description provided for @keepCityFile.
  ///
  /// In en, this message translates to:
  /// **'Keep City File'**
  String get keepCityFile;

  /// No description provided for @deleteForever.
  ///
  /// In en, this message translates to:
  /// **'Delete Forever'**
  String get deleteForever;

  /// No description provided for @cityRemovedNotice.
  ///
  /// In en, this message translates to:
  /// **'{city} was removed from Save Slot {slot}.'**
  String cityRemovedNotice(String city, int slot);

  /// No description provided for @cityRegistrationForm.
  ///
  /// In en, this message translates to:
  /// **'City registration form'**
  String get cityRegistrationForm;

  /// No description provided for @cityRegistrationIntro.
  ///
  /// In en, this message translates to:
  /// **'Complete all seven entries. Every choice changes the city file or how you investigate it.'**
  String get cityRegistrationIntro;

  /// No description provided for @cityName.
  ///
  /// In en, this message translates to:
  /// **'City name'**
  String get cityName;

  /// No description provided for @cityNameDescription.
  ///
  /// In en, this message translates to:
  /// **'Name the city file that voters will carry through a term.'**
  String get cityNameDescription;

  /// No description provided for @cityNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Mabuhay City'**
  String get cityNameHint;

  /// No description provided for @cityNameError.
  ///
  /// In en, this message translates to:
  /// **'Enter at least 2 characters.'**
  String get cityNameError;

  /// No description provided for @startingPressure.
  ///
  /// In en, this message translates to:
  /// **'Starting pressure'**
  String get startingPressure;

  /// No description provided for @startingPressureDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose how much strain the city faces on day one.'**
  String get startingPressureDescription;

  /// No description provided for @mainConcerns.
  ///
  /// In en, this message translates to:
  /// **'Main concerns'**
  String get mainConcerns;

  /// No description provided for @mainConcernsDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose one to three urgent issues for this election.'**
  String get mainConcernsDescription;

  /// No description provided for @selectedConcernCount.
  ///
  /// In en, this message translates to:
  /// **'{count} of 3 selected'**
  String selectedConcernCount(int count);

  /// No description provided for @keepOneConcern.
  ///
  /// In en, this message translates to:
  /// **'Keep at least one main concern.'**
  String get keepOneConcern;

  /// No description provided for @removeConcernFirst.
  ///
  /// In en, this message translates to:
  /// **'Remove one concern before choosing another.'**
  String get removeConcernFirst;

  /// No description provided for @candidateField.
  ///
  /// In en, this message translates to:
  /// **'Candidate field'**
  String get candidateField;

  /// No description provided for @candidateFieldDescription.
  ///
  /// In en, this message translates to:
  /// **'Set the general governing experience of the ballot.'**
  String get candidateFieldDescription;

  /// No description provided for @assistanceMode.
  ///
  /// In en, this message translates to:
  /// **'Assistance mode'**
  String get assistanceMode;

  /// No description provided for @assistanceModeDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose whether Resi offers neutral learning reminders.'**
  String get assistanceModeDescription;

  /// No description provided for @campaignNoise.
  ///
  /// In en, this message translates to:
  /// **'Campaign noise'**
  String get campaignNoise;

  /// No description provided for @campaignNoiseDescription.
  ///
  /// In en, this message translates to:
  /// **'Control how much weak or distracting material appears.'**
  String get campaignNoiseDescription;

  /// No description provided for @investigationTime.
  ///
  /// In en, this message translates to:
  /// **'Investigation time'**
  String get investigationTime;

  /// No description provided for @investigationTimeDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose how many evidence files may be opened this run.'**
  String get investigationTimeDescription;

  /// No description provided for @cityFileSummary.
  ///
  /// In en, this message translates to:
  /// **'City file summary'**
  String get cityFileSummary;

  /// No description provided for @configurationSummaryLine.
  ///
  /// In en, this message translates to:
  /// **'{pressure} pressure • {candidates} candidates • {noise} campaign'**
  String configurationSummaryLine(
    String pressure,
    String candidates,
    String noise,
  );

  /// No description provided for @configurationConcerns.
  ///
  /// In en, this message translates to:
  /// **'Concerns: {concerns}'**
  String configurationConcerns(String concerns);

  /// No description provided for @configurationModes.
  ///
  /// In en, this message translates to:
  /// **'{assistance} assistance • {investigation} investigation'**
  String configurationModes(String assistance, String investigation);

  /// No description provided for @openCityFile.
  ///
  /// In en, this message translates to:
  /// **'Open City File'**
  String get openCityFile;

  /// No description provided for @pressureStable.
  ///
  /// In en, this message translates to:
  /// **'Stable'**
  String get pressureStable;

  /// No description provided for @pressureStableDescription.
  ///
  /// In en, this message translates to:
  /// **'Services are holding, but important weaknesses still need attention.'**
  String get pressureStableDescription;

  /// No description provided for @pressureStrained.
  ///
  /// In en, this message translates to:
  /// **'Strained'**
  String get pressureStrained;

  /// No description provided for @pressureStrainedDescription.
  ///
  /// In en, this message translates to:
  /// **'Several systems are under pressure and difficult choices are already due.'**
  String get pressureStrainedDescription;

  /// No description provided for @pressureCrisis.
  ///
  /// In en, this message translates to:
  /// **'Crisis'**
  String get pressureCrisis;

  /// No description provided for @pressureCrisisDescription.
  ///
  /// In en, this message translates to:
  /// **'The city begins with severe problems, low breathing room, and urgent risks.'**
  String get pressureCrisisDescription;

  /// No description provided for @concernFood.
  ///
  /// In en, this message translates to:
  /// **'Food security'**
  String get concernFood;

  /// No description provided for @concernFoodDescription.
  ///
  /// In en, this message translates to:
  /// **'Food prices and access'**
  String get concernFoodDescription;

  /// No description provided for @concernPoverty.
  ///
  /// In en, this message translates to:
  /// **'Poverty'**
  String get concernPoverty;

  /// No description provided for @concernPovertyDescription.
  ///
  /// In en, this message translates to:
  /// **'Families falling behind'**
  String get concernPovertyDescription;

  /// No description provided for @concernHealth.
  ///
  /// In en, this message translates to:
  /// **'Public health'**
  String get concernHealth;

  /// No description provided for @concernHealthDescription.
  ///
  /// In en, this message translates to:
  /// **'Clinics and community care'**
  String get concernHealthDescription;

  /// No description provided for @concernEducation.
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get concernEducation;

  /// No description provided for @concernEducationDescription.
  ///
  /// In en, this message translates to:
  /// **'Schools and learning access'**
  String get concernEducationDescription;

  /// No description provided for @concernWater.
  ///
  /// In en, this message translates to:
  /// **'Water'**
  String get concernWater;

  /// No description provided for @concernWaterDescription.
  ///
  /// In en, this message translates to:
  /// **'Safe and reliable water'**
  String get concernWaterDescription;

  /// No description provided for @concernJobs.
  ///
  /// In en, this message translates to:
  /// **'Jobs'**
  String get concernJobs;

  /// No description provided for @concernJobsDescription.
  ///
  /// In en, this message translates to:
  /// **'Employment and working conditions'**
  String get concernJobsDescription;

  /// No description provided for @concernServices.
  ///
  /// In en, this message translates to:
  /// **'Housing & transport'**
  String get concernServices;

  /// No description provided for @concernServicesDescription.
  ///
  /// In en, this message translates to:
  /// **'Neighborhood and infrastructure strain'**
  String get concernServicesDescription;

  /// No description provided for @concernClimate.
  ///
  /// In en, this message translates to:
  /// **'Climate'**
  String get concernClimate;

  /// No description provided for @concernClimateDescription.
  ///
  /// In en, this message translates to:
  /// **'Flood, heat, and disaster readiness'**
  String get concernClimateDescription;

  /// No description provided for @candidateUnproven.
  ///
  /// In en, this message translates to:
  /// **'Unproven'**
  String get candidateUnproven;

  /// No description provided for @candidateUnprovenDescription.
  ///
  /// In en, this message translates to:
  /// **'Candidates have less governing experience and more uncertain delivery.'**
  String get candidateUnprovenDescription;

  /// No description provided for @candidateMixed.
  ///
  /// In en, this message translates to:
  /// **'Mixed'**
  String get candidateMixed;

  /// No description provided for @candidateMixedDescription.
  ///
  /// In en, this message translates to:
  /// **'The field contains a broad mix of experience and operating skill.'**
  String get candidateMixedDescription;

  /// No description provided for @candidateSeasoned.
  ///
  /// In en, this message translates to:
  /// **'Seasoned'**
  String get candidateSeasoned;

  /// No description provided for @candidateSeasonedDescription.
  ///
  /// In en, this message translates to:
  /// **'Candidates are generally more experienced, but still carry real tradeoffs.'**
  String get candidateSeasonedDescription;

  /// No description provided for @assistanceGuided.
  ///
  /// In en, this message translates to:
  /// **'Guided'**
  String get assistanceGuided;

  /// No description provided for @assistanceGuidedDescription.
  ///
  /// In en, this message translates to:
  /// **'Resi introduces new screens and offers neutral civic-learning reminders.'**
  String get assistanceGuidedDescription;

  /// No description provided for @assistanceStandard.
  ///
  /// In en, this message translates to:
  /// **'Standard'**
  String get assistanceStandard;

  /// No description provided for @assistanceStandardDescription.
  ///
  /// In en, this message translates to:
  /// **'No automatic guidance. The Guide button remains available whenever needed.'**
  String get assistanceStandardDescription;

  /// No description provided for @noiseClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get noiseClear;

  /// No description provided for @noiseClearDescription.
  ///
  /// In en, this message translates to:
  /// **'Official records and accountable sources are easier to find first.'**
  String get noiseClearDescription;

  /// No description provided for @noiseTypical.
  ///
  /// In en, this message translates to:
  /// **'Typical'**
  String get noiseTypical;

  /// No description provided for @noiseTypicalDescription.
  ///
  /// In en, this message translates to:
  /// **'Campaign material, records, posts, and fact-checks arrive in a normal mix.'**
  String get noiseTypicalDescription;

  /// No description provided for @noiseNoisy.
  ///
  /// In en, this message translates to:
  /// **'Noisy'**
  String get noiseNoisy;

  /// No description provided for @noiseNoisyDescription.
  ///
  /// In en, this message translates to:
  /// **'Extra rumors and attention-grabbing posts compete with stronger evidence.'**
  String get noiseNoisyDescription;

  /// No description provided for @investigationRelaxed.
  ///
  /// In en, this message translates to:
  /// **'Relaxed'**
  String get investigationRelaxed;

  /// No description provided for @investigationRelaxedDescription.
  ///
  /// In en, this message translates to:
  /// **'Open as many evidence files as you want.'**
  String get investigationRelaxedDescription;

  /// No description provided for @investigationStandard.
  ///
  /// In en, this message translates to:
  /// **'Standard'**
  String get investigationStandard;

  /// No description provided for @investigationStandardDescription.
  ///
  /// In en, this message translates to:
  /// **'You have 12 investigation points. Candidate profiles are free.'**
  String get investigationStandardDescription;

  /// No description provided for @investigationLimited.
  ///
  /// In en, this message translates to:
  /// **'Limited'**
  String get investigationLimited;

  /// No description provided for @investigationLimitedDescription.
  ///
  /// In en, this message translates to:
  /// **'You have 7 investigation points. Candidate profiles are free.'**
  String get investigationLimitedDescription;

  /// No description provided for @electionBrief.
  ///
  /// In en, this message translates to:
  /// **'Election brief'**
  String get electionBrief;

  /// No description provided for @cityBeforeVote.
  ///
  /// In en, this message translates to:
  /// **'The city before the vote'**
  String get cityBeforeVote;

  /// No description provided for @guidedReminderTitle.
  ///
  /// In en, this message translates to:
  /// **'Resi\'s neutral reminder'**
  String get guidedReminderTitle;

  /// No description provided for @guidedReminderBody.
  ///
  /// In en, this message translates to:
  /// **'Start with the city\'s urgent files, then compare candidate evidence before deciding.'**
  String get guidedReminderBody;

  /// No description provided for @urgentCaseFiles.
  ///
  /// In en, this message translates to:
  /// **'Urgent case files'**
  String get urgentCaseFiles;

  /// No description provided for @cityCondition.
  ///
  /// In en, this message translates to:
  /// **'City condition'**
  String get cityCondition;

  /// No description provided for @meetCandidates.
  ///
  /// In en, this message translates to:
  /// **'Meet the candidates'**
  String get meetCandidates;

  /// No description provided for @cityImageSemantics.
  ///
  /// In en, this message translates to:
  /// **'An illustrated civic hall, waterfront, water infrastructure, clinic, school, and market district.'**
  String get cityImageSemantics;

  /// No description provided for @cityHubTitle.
  ///
  /// In en, this message translates to:
  /// **'City brief'**
  String get cityHubTitle;

  /// No description provided for @preElectionSnapshot.
  ///
  /// In en, this message translates to:
  /// **'Pre-election snapshot'**
  String get preElectionSnapshot;

  /// No description provided for @preElectionFrozenNote.
  ///
  /// In en, this message translates to:
  /// **'Background context only. The city does not advance and consequential events do not begin until your vote is confirmed.'**
  String get preElectionFrozenNote;

  /// No description provided for @cityPulse.
  ///
  /// In en, this message translates to:
  /// **'City pulse'**
  String get cityPulse;

  /// No description provided for @fictionalCityEstimate.
  ///
  /// In en, this message translates to:
  /// **'Fictional city estimate derived from the starting scenario'**
  String get fictionalCityEstimate;

  /// No description provided for @urgentConcerns.
  ///
  /// In en, this message translates to:
  /// **'Concerns on the ballot'**
  String get urgentConcerns;

  /// No description provided for @affectedResidentsEstimate.
  ///
  /// In en, this message translates to:
  /// **'{percent}% estimated residents affected'**
  String affectedResidentsEstimate(int percent);

  /// No description provided for @severityValue.
  ///
  /// In en, this message translates to:
  /// **'Severity: {value}'**
  String severityValue(String value);

  /// No description provided for @urgencyValue.
  ///
  /// In en, this message translates to:
  /// **'Urgency: {value}'**
  String urgencyValue(String value);

  /// No description provided for @openCaseFile.
  ///
  /// In en, this message translates to:
  /// **'Open case file'**
  String get openCaseFile;

  /// No description provided for @caseFileDetails.
  ///
  /// In en, this message translates to:
  /// **'Concern details'**
  String get caseFileDetails;

  /// No description provided for @relatedIndicators.
  ///
  /// In en, this message translates to:
  /// **'Related city systems'**
  String get relatedIndicators;

  /// No description provided for @currentCondition.
  ///
  /// In en, this message translates to:
  /// **'Current condition'**
  String get currentCondition;

  /// No description provided for @latestChronicle.
  ///
  /// In en, this message translates to:
  /// **'Latest from the Chronicle'**
  String get latestChronicle;

  /// No description provided for @openChronicle.
  ///
  /// In en, this message translates to:
  /// **'Open Chronicle'**
  String get openChronicle;

  /// No description provided for @chronicleTitle.
  ///
  /// In en, this message translates to:
  /// **'City Chronicle'**
  String get chronicleTitle;

  /// No description provided for @chronicleIntro.
  ///
  /// In en, this message translates to:
  /// **'Background reporting and sampled resident voices describe the city at the start of the election. This feed is not an advancing simulation.'**
  String get chronicleIntro;

  /// No description provided for @cityNews.
  ///
  /// In en, this message translates to:
  /// **'City news'**
  String get cityNews;

  /// No description provided for @communityVoices.
  ///
  /// In en, this message translates to:
  /// **'Community voices'**
  String get communityVoices;

  /// No description provided for @voiceSampleNote.
  ///
  /// In en, this message translates to:
  /// **'These are fictional sampled perspectives, not a scientific poll or the voice of the entire city.'**
  String get voiceSampleNote;

  /// No description provided for @backgroundContextLabel.
  ///
  /// In en, this message translates to:
  /// **'Background context'**
  String get backgroundContextLabel;

  /// No description provided for @unverifiedClaim.
  ///
  /// In en, this message translates to:
  /// **'Unverified community claim'**
  String get unverifiedClaim;

  /// No description provided for @navCity.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get navCity;

  /// No description provided for @navDossiers.
  ///
  /// In en, this message translates to:
  /// **'Dossiers'**
  String get navDossiers;

  /// No description provided for @navChronicle.
  ///
  /// In en, this message translates to:
  /// **'Chronicle'**
  String get navChronicle;

  /// No description provided for @cityMapHint.
  ///
  /// In en, this message translates to:
  /// **'Tap a city marker to open its concern file.'**
  String get cityMapHint;

  /// No description provided for @candidateRoster.
  ///
  /// In en, this message translates to:
  /// **'Candidate roster'**
  String get candidateRoster;

  /// No description provided for @candidateRosterHeading.
  ///
  /// In en, this message translates to:
  /// **'Three imperfect choices'**
  String get candidateRosterHeading;

  /// No description provided for @candidateRosterIntro.
  ///
  /// In en, this message translates to:
  /// **'No score is shown and no candidate is recommended. Open every dossier, compare evidence, and decide which tradeoffs you can defend.'**
  String get candidateRosterIntro;

  /// No description provided for @visibleStrengths.
  ///
  /// In en, this message translates to:
  /// **'Visible strengths'**
  String get visibleStrengths;

  /// No description provided for @visibleConcerns.
  ///
  /// In en, this message translates to:
  /// **'Visible concerns'**
  String get visibleConcerns;

  /// No description provided for @openDossier.
  ///
  /// In en, this message translates to:
  /// **'Open dossier'**
  String get openDossier;

  /// No description provided for @proceedElection.
  ///
  /// In en, this message translates to:
  /// **'Proceed to election day'**
  String get proceedElection;

  /// No description provided for @dossier.
  ///
  /// In en, this message translates to:
  /// **'Dossier'**
  String get dossier;

  /// No description provided for @electionDay.
  ///
  /// In en, this message translates to:
  /// **'Election day'**
  String get electionDay;

  /// No description provided for @documentedStrengths.
  ///
  /// In en, this message translates to:
  /// **'Documented strengths'**
  String get documentedStrengths;

  /// No description provided for @questionsToInvestigate.
  ///
  /// In en, this message translates to:
  /// **'Questions to investigate'**
  String get questionsToInvestigate;

  /// No description provided for @campaignPlatform.
  ///
  /// In en, this message translates to:
  /// **'Campaign platform'**
  String get campaignPlatform;

  /// No description provided for @evidenceDesk.
  ///
  /// In en, this message translates to:
  /// **'Evidence desk'**
  String get evidenceDesk;

  /// No description provided for @bookmarkedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} bookmarked'**
  String bookmarkedCount(int count);

  /// No description provided for @evidenceDeskHint.
  ///
  /// In en, this message translates to:
  /// **'A source can be reputable yet incomplete. Open the item before deciding what weight it deserves.'**
  String get evidenceDeskHint;

  /// No description provided for @investigationPointsRemaining.
  ///
  /// In en, this message translates to:
  /// **'{count} investigation points remaining'**
  String investigationPointsRemaining(int count);

  /// No description provided for @roster.
  ///
  /// In en, this message translates to:
  /// **'Roster'**
  String get roster;

  /// No description provided for @reviewBallot.
  ///
  /// In en, this message translates to:
  /// **'Review ballot'**
  String get reviewBallot;

  /// No description provided for @noInvestigationPoints.
  ///
  /// In en, this message translates to:
  /// **'No investigation points left'**
  String get noInvestigationPoints;

  /// No description provided for @noInvestigationPointsBody.
  ///
  /// In en, this message translates to:
  /// **'You have used the investigation time chosen for this city. Previously opened evidence remains available.'**
  String get noInvestigationPointsBody;

  /// No description provided for @sourceCue.
  ///
  /// In en, this message translates to:
  /// **'Source cue: {cue}'**
  String sourceCue(String cue);

  /// No description provided for @factCheckFinding.
  ///
  /// In en, this message translates to:
  /// **'Fact-check finding: {finding}'**
  String factCheckFinding(String finding);

  /// No description provided for @bookmark.
  ///
  /// In en, this message translates to:
  /// **'Bookmark'**
  String get bookmark;

  /// No description provided for @removeBookmark.
  ///
  /// In en, this message translates to:
  /// **'Remove bookmark'**
  String get removeBookmark;

  /// No description provided for @reliabilityStrong.
  ///
  /// In en, this message translates to:
  /// **'strong documentary support'**
  String get reliabilityStrong;

  /// No description provided for @reliabilityModerate.
  ///
  /// In en, this message translates to:
  /// **'useful but verify context'**
  String get reliabilityModerate;

  /// No description provided for @reliabilityWeak.
  ///
  /// In en, this message translates to:
  /// **'weak or interested source'**
  String get reliabilityWeak;

  /// No description provided for @overviewTab.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overviewTab;

  /// No description provided for @platformTab.
  ///
  /// In en, this message translates to:
  /// **'Platform'**
  String get platformTab;

  /// No description provided for @evidenceTab.
  ///
  /// In en, this message translates to:
  /// **'Evidence'**
  String get evidenceTab;

  /// No description provided for @allEvidence.
  ///
  /// In en, this message translates to:
  /// **'All files'**
  String get allEvidence;

  /// No description provided for @recordsEvidence.
  ///
  /// In en, this message translates to:
  /// **'Records'**
  String get recordsEvidence;

  /// No description provided for @campaignEvidence.
  ///
  /// In en, this message translates to:
  /// **'Campaign'**
  String get campaignEvidence;

  /// No description provided for @publicClaimsEvidence.
  ///
  /// In en, this message translates to:
  /// **'Public claims'**
  String get publicClaimsEvidence;

  /// No description provided for @factChecksEvidence.
  ///
  /// In en, this message translates to:
  /// **'Fact-checks'**
  String get factChecksEvidence;

  /// No description provided for @debateEvidence.
  ///
  /// In en, this message translates to:
  /// **'Debate'**
  String get debateEvidence;

  /// No description provided for @questionsEvidence.
  ///
  /// In en, this message translates to:
  /// **'Questions'**
  String get questionsEvidence;

  /// No description provided for @bookmarkedEvidence.
  ///
  /// In en, this message translates to:
  /// **'Bookmarked'**
  String get bookmarkedEvidence;

  /// No description provided for @fileOpened.
  ///
  /// In en, this message translates to:
  /// **'Opened'**
  String get fileOpened;

  /// No description provided for @fileUnopened.
  ///
  /// In en, this message translates to:
  /// **'Unopened'**
  String get fileUnopened;

  /// No description provided for @fileFree.
  ///
  /// In en, this message translates to:
  /// **'Free profile'**
  String get fileFree;

  /// No description provided for @filePointCost.
  ///
  /// In en, this message translates to:
  /// **'1 point'**
  String get filePointCost;

  /// No description provided for @filesReviewed.
  ///
  /// In en, this message translates to:
  /// **'{opened} / {total} files reviewed'**
  String filesReviewed(int opened, int total);

  /// No description provided for @candidateForMayor.
  ///
  /// In en, this message translates to:
  /// **'For mayor'**
  String get candidateForMayor;

  /// No description provided for @biography.
  ///
  /// In en, this message translates to:
  /// **'Biography'**
  String get biography;

  /// No description provided for @platformReminder.
  ///
  /// In en, this message translates to:
  /// **'Promises show intent. Check records, funding, and delivery before giving them weight.'**
  String get platformReminder;

  /// No description provided for @noEvidenceInFilter.
  ///
  /// In en, this message translates to:
  /// **'No files match this filter yet.'**
  String get noEvidenceInFilter;

  /// No description provided for @sourceCheckTitle.
  ///
  /// In en, this message translates to:
  /// **'Check the receipt'**
  String get sourceCheckTitle;

  /// No description provided for @sourceCheckBody.
  ///
  /// In en, this message translates to:
  /// **'Ask who produced this, what proof it gives, what context may be missing, and whether another source confirms it.'**
  String get sourceCheckBody;

  /// No description provided for @openEvidence.
  ///
  /// In en, this message translates to:
  /// **'Open file'**
  String get openEvidence;

  /// No description provided for @unlimitedInvestigation.
  ///
  /// In en, this message translates to:
  /// **'Unlimited investigation'**
  String get unlimitedInvestigation;

  /// No description provided for @previousCandidate.
  ///
  /// In en, this message translates to:
  /// **'Previous candidate'**
  String get previousCandidate;

  /// No description provided for @nextCandidate.
  ///
  /// In en, this message translates to:
  /// **'Next candidate'**
  String get nextCandidate;

  /// No description provided for @recordSnapshot.
  ///
  /// In en, this message translates to:
  /// **'Record snapshot'**
  String get recordSnapshot;

  /// No description provided for @publicServiceExperience.
  ///
  /// In en, this message translates to:
  /// **'Public-service experience'**
  String get publicServiceExperience;

  /// No description provided for @evidenceRecordDepth.
  ///
  /// In en, this message translates to:
  /// **'Documented record'**
  String get evidenceRecordDepth;

  /// No description provided for @experienceEmerging.
  ///
  /// In en, this message translates to:
  /// **'Emerging record'**
  String get experienceEmerging;

  /// No description provided for @experiencePracticed.
  ///
  /// In en, this message translates to:
  /// **'Practiced record'**
  String get experiencePracticed;

  /// No description provided for @experienceEstablished.
  ///
  /// In en, this message translates to:
  /// **'Established record'**
  String get experienceEstablished;

  /// No description provided for @evidenceDepthLimited.
  ///
  /// In en, this message translates to:
  /// **'Limited documentation'**
  String get evidenceDepthLimited;

  /// No description provided for @evidenceDepthMixed.
  ///
  /// In en, this message translates to:
  /// **'Mixed documentation'**
  String get evidenceDepthMixed;

  /// No description provided for @evidenceDepthDocumented.
  ///
  /// In en, this message translates to:
  /// **'Broad documentation'**
  String get evidenceDepthDocumented;

  /// No description provided for @accountableRecordsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} accountable records'**
  String accountableRecordsCount(int count);

  /// No description provided for @unresolvedFilesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} unresolved files'**
  String unresolvedFilesCount(int count);

  /// No description provided for @distinctSourcesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} distinct sources'**
  String distinctSourcesCount(int count);

  /// No description provided for @electionDayHeading.
  ///
  /// In en, this message translates to:
  /// **'Choose without a match score'**
  String get electionDayHeading;

  /// No description provided for @ballotInstruction.
  ///
  /// In en, this message translates to:
  /// **'Review the evidence, choose one imperfect candidate, and record what shaped your decision.'**
  String get ballotInstruction;

  /// No description provided for @ballotCandidateInstruction.
  ///
  /// In en, this message translates to:
  /// **'Select a candidate for mayor'**
  String get ballotCandidateInstruction;

  /// No description provided for @ballotSelected.
  ///
  /// In en, this message translates to:
  /// **'Selected for your ballot'**
  String get ballotSelected;

  /// No description provided for @choosePriority.
  ///
  /// In en, this message translates to:
  /// **'Choose the issue that mattered most'**
  String get choosePriority;

  /// No description provided for @confidenceReflection.
  ///
  /// In en, this message translates to:
  /// **'Confidence is a reflection, not a score.'**
  String get confidenceReflection;

  /// No description provided for @evidenceOpenedCount.
  ///
  /// In en, this message translates to:
  /// **'{opened} of {total} evidence items opened. Investigation completeness is context, not a score.'**
  String evidenceOpenedCount(int opened, int total);

  /// No description provided for @viewDossier.
  ///
  /// In en, this message translates to:
  /// **'Dossier'**
  String get viewDossier;

  /// No description provided for @topIssueQuestion.
  ///
  /// In en, this message translates to:
  /// **'Which city problem matters most to your decision?'**
  String get topIssueQuestion;

  /// No description provided for @confidenceQuestion.
  ///
  /// In en, this message translates to:
  /// **'How confident are you in this choice?'**
  String get confidenceQuestion;

  /// No description provided for @confidenceValue.
  ///
  /// In en, this message translates to:
  /// **'{value}%'**
  String confidenceValue(int value);

  /// No description provided for @confidenceLow.
  ///
  /// In en, this message translates to:
  /// **'Still uncertain'**
  String get confidenceLow;

  /// No description provided for @confidenceHigh.
  ///
  /// In en, this message translates to:
  /// **'Very confident'**
  String get confidenceHigh;

  /// No description provided for @castVote.
  ///
  /// In en, this message translates to:
  /// **'Cast vote'**
  String get castVote;

  /// No description provided for @sealBallotQuestion.
  ///
  /// In en, this message translates to:
  /// **'Seal this ballot?'**
  String get sealBallotQuestion;

  /// No description provided for @sealBallotBody.
  ///
  /// In en, this message translates to:
  /// **'You are choosing {candidate}. The term simulation will reveal consequences, not a verdict about the correct vote.'**
  String sealBallotBody(String candidate);

  /// No description provided for @keepReviewing.
  ///
  /// In en, this message translates to:
  /// **'Keep reviewing'**
  String get keepReviewing;

  /// No description provided for @confirmVote.
  ///
  /// In en, this message translates to:
  /// **'Confirm vote'**
  String get confirmVote;

  /// No description provided for @winnerDeclared.
  ///
  /// In en, this message translates to:
  /// **'Election result'**
  String get winnerDeclared;

  /// No description provided for @nowGovernsCity.
  ///
  /// In en, this message translates to:
  /// **'{candidate} now governs {city}.'**
  String nowGovernsCity(String candidate, String city);

  /// No description provided for @beginTerm.
  ///
  /// In en, this message translates to:
  /// **'Begin the term'**
  String get beginTerm;

  /// No description provided for @returnToBallot.
  ///
  /// In en, this message translates to:
  /// **'Return to ballot'**
  String get returnToBallot;

  /// No description provided for @termInProgress.
  ///
  /// In en, this message translates to:
  /// **'Term in progress'**
  String get termInProgress;

  /// No description provided for @termTimeline.
  ///
  /// In en, this message translates to:
  /// **'Administration timeline'**
  String get termTimeline;

  /// No description provided for @phaseProgress.
  ///
  /// In en, this message translates to:
  /// **'{current} of {total} phases revealed'**
  String phaseProgress(int current, int total);

  /// No description provided for @currentCityCondition.
  ///
  /// In en, this message translates to:
  /// **'Current city condition'**
  String get currentCityCondition;

  /// No description provided for @majorEvent.
  ///
  /// In en, this message translates to:
  /// **'Major city event'**
  String get majorEvent;

  /// No description provided for @cityUpdate.
  ///
  /// In en, this message translates to:
  /// **'City update'**
  String get cityUpdate;

  /// No description provided for @eventImpact.
  ///
  /// In en, this message translates to:
  /// **'Recorded impact'**
  String get eventImpact;

  /// No description provided for @advanceTerm.
  ///
  /// In en, this message translates to:
  /// **'Advance the term'**
  String get advanceTerm;

  /// No description provided for @termReady.
  ///
  /// In en, this message translates to:
  /// **'The term record is complete'**
  String get termReady;

  /// No description provided for @termSimulationHeading.
  ///
  /// In en, this message translates to:
  /// **'One term, four explainable phases'**
  String get termSimulationHeading;

  /// No description provided for @termSimulationIntro.
  ///
  /// In en, this message translates to:
  /// **'The same seed and candidate always produce the same result. Each change identifies the factors that shaped it.'**
  String get termSimulationIntro;

  /// No description provided for @phaseNumber.
  ///
  /// In en, this message translates to:
  /// **'Phase {number}'**
  String phaseNumber(int number);

  /// No description provided for @changeValue.
  ///
  /// In en, this message translates to:
  /// **'{indicator}: {change}'**
  String changeValue(String indicator, String change);

  /// No description provided for @viewTermReport.
  ///
  /// In en, this message translates to:
  /// **'View term report'**
  String get viewTermReport;

  /// No description provided for @termReport.
  ///
  /// In en, this message translates to:
  /// **'Term report'**
  String get termReport;

  /// No description provided for @administrationOf.
  ///
  /// In en, this message translates to:
  /// **'The {candidate} administration'**
  String administrationOf(String candidate);

  /// No description provided for @before.
  ///
  /// In en, this message translates to:
  /// **'Before'**
  String get before;

  /// No description provided for @after.
  ///
  /// In en, this message translates to:
  /// **'After'**
  String get after;

  /// No description provided for @change.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get change;

  /// No description provided for @whyThisHappened.
  ///
  /// In en, this message translates to:
  /// **'Why this happened'**
  String get whyThisHappened;

  /// No description provided for @modelExplanation.
  ///
  /// In en, this message translates to:
  /// **'The deterministic model selected major events from the city seed, active concerns, and starting weaknesses. Their impact combined relevant policy knowledge, implementation, crisis response, integrity, coalition support, budget feasibility, and a logged ±10% seeded variation. Hidden scores were never used as pre-election hints.'**
  String get modelExplanation;

  /// No description provided for @yourDecisionContext.
  ///
  /// In en, this message translates to:
  /// **'Your decision context'**
  String get yourDecisionContext;

  /// No description provided for @decisionContextBody.
  ///
  /// In en, this message translates to:
  /// **'Top issue: {issue} • Confidence: {confidence}% • Evidence opened: {evidence}'**
  String decisionContextBody(String issue, int confidence, int evidence);

  /// No description provided for @notRecorded.
  ///
  /// In en, this message translates to:
  /// **'Not recorded'**
  String get notRecorded;

  /// No description provided for @replaySeed.
  ///
  /// In en, this message translates to:
  /// **'Replay seed {seed}'**
  String replaySeed(int seed);

  /// No description provided for @caseFileMissing.
  ///
  /// In en, this message translates to:
  /// **'That case file could not be found.'**
  String get caseFileMissing;

  /// No description provided for @returnHome.
  ///
  /// In en, this message translates to:
  /// **'Return home'**
  String get returnHome;

  /// No description provided for @indicatorFoodSecurity.
  ///
  /// In en, this message translates to:
  /// **'Food security'**
  String get indicatorFoodSecurity;

  /// No description provided for @indicatorPovertyReduction.
  ///
  /// In en, this message translates to:
  /// **'Poverty reduction'**
  String get indicatorPovertyReduction;

  /// No description provided for @indicatorPublicHealth.
  ///
  /// In en, this message translates to:
  /// **'Public health'**
  String get indicatorPublicHealth;

  /// No description provided for @indicatorEducationQuality.
  ///
  /// In en, this message translates to:
  /// **'Education quality'**
  String get indicatorEducationQuality;

  /// No description provided for @indicatorWaterSecurity.
  ///
  /// In en, this message translates to:
  /// **'Water security'**
  String get indicatorWaterSecurity;

  /// No description provided for @indicatorEmploymentQuality.
  ///
  /// In en, this message translates to:
  /// **'Employment quality'**
  String get indicatorEmploymentQuality;

  /// No description provided for @indicatorUrbanResilience.
  ///
  /// In en, this message translates to:
  /// **'Urban resilience'**
  String get indicatorUrbanResilience;

  /// No description provided for @indicatorClimateResilience.
  ///
  /// In en, this message translates to:
  /// **'Climate resilience'**
  String get indicatorClimateResilience;

  /// No description provided for @indicatorBudgetHealth.
  ///
  /// In en, this message translates to:
  /// **'Budget health'**
  String get indicatorBudgetHealth;

  /// No description provided for @indicatorPublicTrust.
  ///
  /// In en, this message translates to:
  /// **'Public trust'**
  String get indicatorPublicTrust;

  /// No description provided for @indicatorCorruptionPressure.
  ///
  /// In en, this message translates to:
  /// **'Corruption pressure'**
  String get indicatorCorruptionPressure;

  /// No description provided for @stateCritical.
  ///
  /// In en, this message translates to:
  /// **'Critical'**
  String get stateCritical;

  /// No description provided for @statePoor.
  ///
  /// In en, this message translates to:
  /// **'Poor'**
  String get statePoor;

  /// No description provided for @stateUnstable.
  ///
  /// In en, this message translates to:
  /// **'Unstable'**
  String get stateUnstable;

  /// No description provided for @stateFunctional.
  ///
  /// In en, this message translates to:
  /// **'Functional'**
  String get stateFunctional;

  /// No description provided for @stateStrong.
  ///
  /// In en, this message translates to:
  /// **'Strong'**
  String get stateStrong;

  /// No description provided for @trendImproving.
  ///
  /// In en, this message translates to:
  /// **'Improving'**
  String get trendImproving;

  /// No description provided for @trendStable.
  ///
  /// In en, this message translates to:
  /// **'Stable'**
  String get trendStable;

  /// No description provided for @trendWorsening.
  ///
  /// In en, this message translates to:
  /// **'Worsening'**
  String get trendWorsening;

  /// No description provided for @trendRapidlyWorsening.
  ///
  /// In en, this message translates to:
  /// **'Rapidly worsening'**
  String get trendRapidlyWorsening;

  /// No description provided for @evidenceProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get evidenceProfile;

  /// No description provided for @evidencePlatform.
  ///
  /// In en, this message translates to:
  /// **'Platform'**
  String get evidencePlatform;

  /// No description provided for @evidenceCampaignAd.
  ///
  /// In en, this message translates to:
  /// **'Campaign ad'**
  String get evidenceCampaignAd;

  /// No description provided for @evidencePublicRecord.
  ///
  /// In en, this message translates to:
  /// **'Public record'**
  String get evidencePublicRecord;

  /// No description provided for @evidenceBudgetDocument.
  ///
  /// In en, this message translates to:
  /// **'Budget document'**
  String get evidenceBudgetDocument;

  /// No description provided for @evidenceSocialPost.
  ///
  /// In en, this message translates to:
  /// **'Social post'**
  String get evidenceSocialPost;

  /// No description provided for @evidenceFactCheck.
  ///
  /// In en, this message translates to:
  /// **'Fact-check'**
  String get evidenceFactCheck;

  /// No description provided for @evidenceControversy.
  ///
  /// In en, this message translates to:
  /// **'Controversy'**
  String get evidenceControversy;

  /// No description provided for @evidenceDebateAnswer.
  ///
  /// In en, this message translates to:
  /// **'Debate answer'**
  String get evidenceDebateAnswer;

  /// No description provided for @truthVerified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get truthVerified;

  /// No description provided for @truthMostlyTrue.
  ///
  /// In en, this message translates to:
  /// **'Mostly true'**
  String get truthMostlyTrue;

  /// No description provided for @truthPartiallyTrue.
  ///
  /// In en, this message translates to:
  /// **'Partially true'**
  String get truthPartiallyTrue;

  /// No description provided for @truthMisleading.
  ///
  /// In en, this message translates to:
  /// **'Misleading'**
  String get truthMisleading;

  /// No description provided for @truthUnverified.
  ///
  /// In en, this message translates to:
  /// **'Unverified'**
  String get truthUnverified;

  /// No description provided for @truthFalse.
  ///
  /// In en, this message translates to:
  /// **'False'**
  String get truthFalse;

  /// No description provided for @truthMissingContext.
  ///
  /// In en, this message translates to:
  /// **'Missing context'**
  String get truthMissingContext;

  /// No description provided for @selectedCandidateEffectTitle.
  ///
  /// In en, this message translates to:
  /// **'Your selected candidate becomes the administration.'**
  String get selectedCandidateEffectTitle;

  /// No description provided for @selectedCandidateEffectBody.
  ///
  /// In en, this message translates to:
  /// **'The report explains consequences; it will not label your vote right or wrong.'**
  String get selectedCandidateEffectBody;

  /// No description provided for @administrationReceipt.
  ///
  /// In en, this message translates to:
  /// **'Administration receipt'**
  String get administrationReceipt;

  /// No description provided for @administrationTimeline.
  ///
  /// In en, this message translates to:
  /// **'What happened during the term'**
  String get administrationTimeline;

  /// No description provided for @strongestGains.
  ///
  /// In en, this message translates to:
  /// **'Strongest gains'**
  String get strongestGains;

  /// No description provided for @hardestSetbacks.
  ///
  /// In en, this message translates to:
  /// **'Hardest setbacks'**
  String get hardestSetbacks;

  /// No description provided for @outcomeNotVerdict.
  ///
  /// In en, this message translates to:
  /// **'This is a record of consequences, not a verdict that your vote was right or wrong.'**
  String get outcomeNotVerdict;

  /// No description provided for @noMajorChange.
  ///
  /// In en, this message translates to:
  /// **'No major movement'**
  String get noMajorChange;

  /// No description provided for @whatChanged.
  ///
  /// In en, this message translates to:
  /// **'What changed'**
  String get whatChanged;

  /// No description provided for @whatChangedBody.
  ///
  /// In en, this message translates to:
  /// **'Labels show final condition. Signed values show movement during the term; corruption pressure is healthier when it falls.'**
  String get whatChangedBody;

  /// No description provided for @advanceToPhase.
  ///
  /// In en, this message translates to:
  /// **'Advance to phase {number}'**
  String advanceToPhase(int number);

  /// No description provided for @savedOnDevice.
  ///
  /// In en, this message translates to:
  /// **'Saved on this device'**
  String get savedOnDevice;

  /// No description provided for @savingCityFiles.
  ///
  /// In en, this message translates to:
  /// **'Saving city files…'**
  String get savingCityFiles;

  /// No description provided for @citySaveProblem.
  ///
  /// In en, this message translates to:
  /// **'City files could not be saved. Your current session remains open.'**
  String get citySaveProblem;

  /// No description provided for @retrySave.
  ///
  /// In en, this message translates to:
  /// **'Retry saving'**
  String get retrySave;
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
      <String>['en', 'fil'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fil':
      return AppLocalizationsFil();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
