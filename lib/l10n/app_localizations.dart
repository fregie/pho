import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

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
    Locale('zh'),
    Locale('zh', 'TW')
  ];

  /// No description provided for @local.
  ///
  /// In en, this message translates to:
  /// **'Local'**
  String get local;

  /// No description provided for @cloud.
  ///
  /// In en, this message translates to:
  /// **'Cloud'**
  String get cloud;

  /// No description provided for @sync.
  ///
  /// In en, this message translates to:
  /// **'Sync'**
  String get sync;

  /// No description provided for @cloudSync.
  ///
  /// In en, this message translates to:
  /// **'Cloud sync'**
  String get cloudSync;

  /// No description provided for @localFolder.
  ///
  /// In en, this message translates to:
  /// **'Local folder'**
  String get localFolder;

  /// No description provided for @cloudStorage.
  ///
  /// In en, this message translates to:
  /// **'Cloud storage'**
  String get cloudStorage;

  /// No description provided for @backgroundSync.
  ///
  /// In en, this message translates to:
  /// **'Auto Sync'**
  String get backgroundSync;

  /// No description provided for @notSync.
  ///
  /// In en, this message translates to:
  /// **'not sync'**
  String get notSync;

  /// No description provided for @unsynchronizedPhotos.
  ///
  /// In en, this message translates to:
  /// **'Unsynchronized photos'**
  String get unsynchronizedPhotos;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @photos.
  ///
  /// In en, this message translates to:
  /// **'photos'**
  String get photos;

  /// No description provided for @deleteThisPhoto.
  ///
  /// In en, this message translates to:
  /// **'Delete this photo?'**
  String get deleteThisPhoto;

  /// No description provided for @deleteThisPhotos.
  ///
  /// In en, this message translates to:
  /// **'Delete this photos?'**
  String get deleteThisPhotos;

  /// No description provided for @cantBeUndone.
  ///
  /// In en, this message translates to:
  /// **'This action can\'t be undone'**
  String get cantBeUndone;

  /// No description provided for @download.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get download;

  /// No description provided for @upload.
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get upload;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'success'**
  String get success;

  /// No description provided for @pics.
  ///
  /// In en, this message translates to:
  /// **'pics'**
  String get pics;

  /// No description provided for @choose.
  ///
  /// In en, this message translates to:
  /// **'Choose'**
  String get choose;

  /// No description provided for @stop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stop;

  /// No description provided for @uploading.
  ///
  /// In en, this message translates to:
  /// **'Uploading'**
  String get uploading;

  /// No description provided for @downloading.
  ///
  /// In en, this message translates to:
  /// **'Downloading'**
  String get downloading;

  /// No description provided for @uploadFailed.
  ///
  /// In en, this message translates to:
  /// **'Upload failed'**
  String get uploadFailed;

  /// No description provided for @uploaded.
  ///
  /// In en, this message translates to:
  /// **'Uploaded'**
  String get uploaded;

  /// No description provided for @notUploaded.
  ///
  /// In en, this message translates to:
  /// **'Not uploaded'**
  String get notUploaded;

  /// No description provided for @chooseAlbum.
  ///
  /// In en, this message translates to:
  /// **'Choose album'**
  String get chooseAlbum;

  /// No description provided for @storageSetting.
  ///
  /// In en, this message translates to:
  /// **'Storage setting'**
  String get storageSetting;

  /// No description provided for @remoteStorageType.
  ///
  /// In en, this message translates to:
  /// **'Remote storage type'**
  String get remoteStorageType;

  /// No description provided for @samvbaServerAddress.
  ///
  /// In en, this message translates to:
  /// **'Samba server address'**
  String get samvbaServerAddress;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @rootPath.
  ///
  /// In en, this message translates to:
  /// **'Root path(Your photos will be uploaded to this path)'**
  String get rootPath;

  /// No description provided for @optional.
  ///
  /// In en, this message translates to:
  /// **'optional'**
  String get optional;

  /// No description provided for @testStorage.
  ///
  /// In en, this message translates to:
  /// **'Test storage'**
  String get testStorage;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @enableBackgroundSync.
  ///
  /// In en, this message translates to:
  /// **'Enable background sync'**
  String get enableBackgroundSync;

  /// No description provided for @syncOnlyOnWifi.
  ///
  /// In en, this message translates to:
  /// **'Sync only on WIFI'**
  String get syncOnlyOnWifi;

  /// No description provided for @syncInterval.
  ///
  /// In en, this message translates to:
  /// **'Sync interval'**
  String get syncInterval;

  /// No description provided for @minite.
  ///
  /// In en, this message translates to:
  /// **'minite'**
  String get minite;

  /// No description provided for @hour.
  ///
  /// In en, this message translates to:
  /// **'hour'**
  String get hour;

  /// No description provided for @day.
  ///
  /// In en, this message translates to:
  /// **'day'**
  String get day;

  /// No description provided for @week.
  ///
  /// In en, this message translates to:
  /// **'week'**
  String get week;

  /// No description provided for @month.
  ///
  /// In en, this message translates to:
  /// **'month'**
  String get month;

  /// No description provided for @year.
  ///
  /// In en, this message translates to:
  /// **'year'**
  String get year;

  /// No description provided for @chineseday.
  ///
  /// In en, this message translates to:
  /// **''**
  String get chineseday;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @permissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Permission denied'**
  String get permissionDenied;

  /// No description provided for @setLocalFirst.
  ///
  /// In en, this message translates to:
  /// **'Please set local folder first'**
  String get setLocalFirst;

  /// No description provided for @downloadFailed.
  ///
  /// In en, this message translates to:
  /// **'Download failed'**
  String get downloadFailed;

  /// No description provided for @storageNotSetted.
  ///
  /// In en, this message translates to:
  /// **'Remote storage is not setted,please set it first'**
  String get storageNotSetted;

  /// No description provided for @successfullyUpload.
  ///
  /// In en, this message translates to:
  /// **'Successfully upload'**
  String get successfullyUpload;

  /// No description provided for @testSuccess.
  ///
  /// In en, this message translates to:
  /// **'Test success,you can save now'**
  String get testSuccess;

  /// No description provided for @connectFailed.
  ///
  /// In en, this message translates to:
  /// **'Storage connection failed'**
  String get connectFailed;

  /// No description provided for @selectRoot.
  ///
  /// In en, this message translates to:
  /// **'Select root path'**
  String get selectRoot;

  /// No description provided for @currentPath.
  ///
  /// In en, this message translates to:
  /// **'Current path'**
  String get currentPath;

  /// No description provided for @refreshingPleaseWait.
  ///
  /// In en, this message translates to:
  /// **'Comparing your local and cloud photos, the process may take longer if it\'s the first time running or if there are a large number of photos. Please be patient and wait.......'**
  String get refreshingPleaseWait;

  /// No description provided for @setRemoteStroage.
  ///
  /// In en, this message translates to:
  /// **'Please set cloud storage first'**
  String get setRemoteStroage;

  /// No description provided for @needPermision.
  ///
  /// In en, this message translates to:
  /// **'Need permission to access photos'**
  String get needPermision;

  /// No description provided for @gotoSystemSetting.
  ///
  /// In en, this message translates to:
  /// **'To browse the system album, you need to grant access permissions to the photo library. If necessary, please go to system settings to grant permission for accessing the photo library.'**
  String get gotoSystemSetting;

  /// No description provided for @openSetting.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get openSetting;

  /// No description provided for @advancedSetting.
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get advancedSetting;

  /// No description provided for @goToSet.
  ///
  /// In en, this message translates to:
  /// **'Go to set'**
  String get goToSet;

  /// No description provided for @streamFallbackDownload.
  ///
  /// In en, this message translates to:
  /// **'Streaming failed, downloading for playback'**
  String get streamFallbackDownload;

  /// No description provided for @dataDirWarning.
  ///
  /// In en, this message translates to:
  /// **'Modifying the directory structure will only change files uploaded in the future, it will not modify files that have already been uploaded.'**
  String get dataDirWarning;

  /// No description provided for @dirType01.
  ///
  /// In en, this message translates to:
  /// **'Multilevel by date'**
  String get dirType01;

  /// No description provided for @dirType02.
  ///
  /// In en, this message translates to:
  /// **'Single level by date'**
  String get dirType02;

  /// No description provided for @tapToSet.
  ///
  /// In en, this message translates to:
  /// **'Tap to set'**
  String get tapToSet;

  /// No description provided for @longPressToCancel.
  ///
  /// In en, this message translates to:
  /// **'Long press to cancel'**
  String get longPressToCancel;

  /// No description provided for @jumpTo.
  ///
  /// In en, this message translates to:
  /// **'Jump to'**
  String get jumpTo;

  /// No description provided for @jumpToByDate.
  ///
  /// In en, this message translates to:
  /// **'Jump to'**
  String get jumpToByDate;

  /// No description provided for @onlyCamera.
  ///
  /// In en, this message translates to:
  /// **'Only camera'**
  String get onlyCamera;

  /// No description provided for @unlockAllAdvancedFeatures.
  ///
  /// In en, this message translates to:
  /// **'Unlock all features'**
  String get unlockAllAdvancedFeatures;

  /// No description provided for @browseInRecents.
  ///
  /// In en, this message translates to:
  /// **'You can browse in recents'**
  String get browseInRecents;

  /// No description provided for @failedTooMany.
  ///
  /// In en, this message translates to:
  /// **'Failed too many times,stop syncing'**
  String get failedTooMany;

  /// No description provided for @refreshing.
  ///
  /// In en, this message translates to:
  /// **'Refreshing photos,please wait...'**
  String get refreshing;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @desktopStorageSettingDesc.
  ///
  /// In en, this message translates to:
  /// **'Set up network storage to browse the photos you\'ve backed up using Pho'**
  String get desktopStorageSettingDesc;

  /// No description provided for @zoomIn.
  ///
  /// In en, this message translates to:
  /// **'Zoom in'**
  String get zoomIn;

  /// No description provided for @zoomOut.
  ///
  /// In en, this message translates to:
  /// **'Zoom out'**
  String get zoomOut;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'App version'**
  String get appVersion;

  /// No description provided for @releaseStorage.
  ///
  /// In en, this message translates to:
  /// **'Release storage'**
  String get releaseStorage;

  /// No description provided for @deleteSynced.
  ///
  /// In en, this message translates to:
  /// **'Delete synced photos'**
  String get deleteSynced;

  /// No description provided for @youHaveSynced.
  ///
  /// In en, this message translates to:
  /// **'You have synced'**
  String get youHaveSynced;

  /// No description provided for @photosInCloud.
  ///
  /// In en, this message translates to:
  /// **'photos or videos'**
  String get photosInCloud;

  /// No description provided for @canDeleteNow.
  ///
  /// In en, this message translates to:
  /// **'You can now delete them to save space'**
  String get canDeleteNow;

  /// No description provided for @canBrowserAnyTime.
  ///
  /// In en, this message translates to:
  /// **'You can browse them in original quality in cloud storage at any time'**
  String get canBrowserAnyTime;

  /// No description provided for @pleaseConfirmBeforeDelete.
  ///
  /// In en, this message translates to:
  /// **'Please make sure you have backed up these photos in cloud storage before deleting them, otherwise they will not be recoverable after deletion'**
  String get pleaseConfirmBeforeDelete;

  /// No description provided for @installHEVCExtention.
  ///
  /// In en, this message translates to:
  /// **'If HEIC or HEVC formats cannot be displayed correctly, please install \"HEVC Video Extension\" in the Microsoft Store'**
  String get installHEVCExtention;

  /// No description provided for @openMSStore.
  ///
  /// In en, this message translates to:
  /// **'Install'**
  String get openMSStore;

  /// No description provided for @clearCache.
  ///
  /// In en, this message translates to:
  /// **'Clear cache'**
  String get clearCache;

  /// No description provided for @clearCacheDescription.
  ///
  /// In en, this message translates to:
  /// **'This operation will only clear the image cache and will not delete any of your configurations. Are you sure you want to clear the cache?'**
  String get clearCacheDescription;

  /// No description provided for @clearCacheSuccess.
  ///
  /// In en, this message translates to:
  /// **'Clear cache success'**
  String get clearCacheSuccess;

  /// No description provided for @clearCacheFailed.
  ///
  /// In en, this message translates to:
  /// **'Clear cache failed'**
  String get clearCacheFailed;

  /// No description provided for @offline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get offline;

  /// No description provided for @noLocalPhotos.
  ///
  /// In en, this message translates to:
  /// **'No photos found'**
  String get noLocalPhotos;

  /// No description provided for @noCloudPhotos.
  ///
  /// In en, this message translates to:
  /// **'No cloud photos'**
  String get noCloudPhotos;

  /// No description provided for @refreshUnsynchronizedPhotos.
  ///
  /// In en, this message translates to:
  /// **'Refresh unsynchronized photos'**
  String get refreshUnsynchronizedPhotos;

  /// No description provided for @onboardingWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Pho'**
  String get onboardingWelcome;

  /// No description provided for @onboardingWelcomeDesc.
  ///
  /// In en, this message translates to:
  /// **'Your serverless photo sync tool'**
  String get onboardingWelcomeDesc;

  /// No description provided for @onboardingSyncTitle.
  ///
  /// In en, this message translates to:
  /// **'Sync to your storage'**
  String get onboardingSyncTitle;

  /// No description provided for @onboardingSyncDesc.
  ///
  /// In en, this message translates to:
  /// **'Supports SMB, WebDAV and NFS. Photos organized by date automatically'**
  String get onboardingSyncDesc;

  /// No description provided for @onboardingPrivacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your data, your control'**
  String get onboardingPrivacyTitle;

  /// No description provided for @onboardingPrivacyDesc.
  ///
  /// In en, this message translates to:
  /// **'No server, no database. Files stored directly in your network storage'**
  String get onboardingPrivacyDesc;

  /// No description provided for @onboardingSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardingSkip;

  /// No description provided for @onboardingNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboardingNext;

  /// No description provided for @onboardingGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get onboardingGetStarted;

  /// No description provided for @onboardingPermissionTitle.
  ///
  /// In en, this message translates to:
  /// **'Photo access needed'**
  String get onboardingPermissionTitle;

  /// No description provided for @onboardingPermissionDesc.
  ///
  /// In en, this message translates to:
  /// **'Pho needs access to your photo library to browse and sync photos'**
  String get onboardingPermissionDesc;

  /// No description provided for @onboardingGrantPermission.
  ///
  /// In en, this message translates to:
  /// **'Grant permission'**
  String get onboardingGrantPermission;

  /// No description provided for @onboardingLater.
  ///
  /// In en, this message translates to:
  /// **'Set up later'**
  String get onboardingLater;

  /// No description provided for @onboardingStorageTitle.
  ///
  /// In en, this message translates to:
  /// **'Set up cloud storage (optional)'**
  String get onboardingStorageTitle;

  /// No description provided for @onboardingStorageDesc.
  ///
  /// In en, this message translates to:
  /// **'You can set up now or later in Settings'**
  String get onboardingStorageDesc;

  /// No description provided for @onboardingSetupStorage.
  ///
  /// In en, this message translates to:
  /// **'Set up storage'**
  String get onboardingSetupStorage;

  /// No description provided for @onboardingComplete.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get onboardingComplete;

  /// No description provided for @settingsBasic.
  ///
  /// In en, this message translates to:
  /// **'Basic'**
  String get settingsBasic;

  /// No description provided for @settingsUtilities.
  ///
  /// In en, this message translates to:
  /// **'Utilities'**
  String get settingsUtilities;

  /// No description provided for @monthlyPlan.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthlyPlan;

  /// No description provided for @yearlyPlan.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get yearlyPlan;

  /// No description provided for @lifetimePlan.
  ///
  /// In en, this message translates to:
  /// **'Lifetime'**
  String get lifetimePlan;

  /// No description provided for @perMonth.
  ///
  /// In en, this message translates to:
  /// **'{price}/mo'**
  String perMonth(Object price);

  /// No description provided for @perYear.
  ///
  /// In en, this message translates to:
  /// **'{price}/yr'**
  String perYear(Object price);

  /// No description provided for @oneTime.
  ///
  /// In en, this message translates to:
  /// **'One-time'**
  String get oneTime;

  /// No description provided for @savePercent.
  ///
  /// In en, this message translates to:
  /// **'Save {percent}%'**
  String savePercent(Object percent);

  /// No description provided for @recommended.
  ///
  /// In en, this message translates to:
  /// **'Recommended'**
  String get recommended;

  /// No description provided for @bestValue.
  ///
  /// In en, this message translates to:
  /// **'Best value'**
  String get bestValue;

  /// No description provided for @mostFlexible.
  ///
  /// In en, this message translates to:
  /// **'Most flexible'**
  String get mostFlexible;

  /// No description provided for @subscribe.
  ///
  /// In en, this message translates to:
  /// **'Subscribe'**
  String get subscribe;

  /// No description provided for @termsOfUse.
  ///
  /// In en, this message translates to:
  /// **'Terms of Use'**
  String get termsOfUse;

  /// No description provided for @iosBackgroundSyncDescription.
  ///
  /// In en, this message translates to:
  /// **'iOS background sync is automatically scheduled by the system when charging, no manual interval setting required'**
  String get iosBackgroundSyncDescription;

  /// No description provided for @notificationDenied.
  ///
  /// In en, this message translates to:
  /// **'Notification permission not granted, sync works but no alerts'**
  String get notificationDenied;

  /// No description provided for @backgroundRefreshDisabledTitle.
  ///
  /// In en, this message translates to:
  /// **'Background App Refresh is off'**
  String get backgroundRefreshDisabledTitle;

  /// No description provided for @backgroundRefreshDisabledDesc.
  ///
  /// In en, this message translates to:
  /// **'Background sync cannot be triggered. Please go to Settings -> Pho to enable Background App Refresh, then go to Settings -> General -> Background App Refresh to confirm it\'s enabled globally'**
  String get backgroundRefreshDisabledDesc;

  /// No description provided for @backgroundRefreshDisabledAction.
  ///
  /// In en, this message translates to:
  /// **'Open Pho Settings'**
  String get backgroundRefreshDisabledAction;

  /// No description provided for @bgSyncSuccessNotificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Pho Background Sync'**
  String get bgSyncSuccessNotificationTitle;

  /// No description provided for @bgSyncSuccessNotificationBody.
  ///
  /// In en, this message translates to:
  /// **'Successfully synced {count} photos'**
  String bgSyncSuccessNotificationBody(int count);

  /// No description provided for @bgSyncSuccessNotificationBodyWithFailures.
  ///
  /// In en, this message translates to:
  /// **'Successfully synced {succeeded} photos ({failed} failed)'**
  String bgSyncSuccessNotificationBodyWithFailures(int succeeded, int failed);
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
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'zh':
      {
        switch (locale.countryCode) {
          case 'TW':
            return AppLocalizationsZhTw();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
