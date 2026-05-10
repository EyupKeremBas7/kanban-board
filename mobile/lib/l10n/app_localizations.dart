import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

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
    Locale('tr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In tr, this message translates to:
  /// **'Kanban Board'**
  String get appTitle;

  /// No description provided for @login.
  ///
  /// In tr, this message translates to:
  /// **'Giriş Yap'**
  String get login;

  /// No description provided for @signup.
  ///
  /// In tr, this message translates to:
  /// **'Üye Ol'**
  String get signup;

  /// No description provided for @email.
  ///
  /// In tr, this message translates to:
  /// **'E-posta'**
  String get email;

  /// No description provided for @password.
  ///
  /// In tr, this message translates to:
  /// **'Şifre'**
  String get password;

  /// No description provided for @fullName.
  ///
  /// In tr, this message translates to:
  /// **'Ad Soyad'**
  String get fullName;

  /// No description provided for @forgotPassword.
  ///
  /// In tr, this message translates to:
  /// **'Şifremi Unuttum'**
  String get forgotPassword;

  /// No description provided for @noAccount.
  ///
  /// In tr, this message translates to:
  /// **'Hesabın yok mu? Kayıt ol'**
  String get noAccount;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In tr, this message translates to:
  /// **'Zaten hesabın var mı? Giriş yap'**
  String get alreadyHaveAccount;

  /// No description provided for @boards.
  ///
  /// In tr, this message translates to:
  /// **'Panolar'**
  String get boards;

  /// No description provided for @workspaces.
  ///
  /// In tr, this message translates to:
  /// **'Çalışma Alanları'**
  String get workspaces;

  /// No description provided for @activity.
  ///
  /// In tr, this message translates to:
  /// **'Etkinlik'**
  String get activity;

  /// No description provided for @account.
  ///
  /// In tr, this message translates to:
  /// **'Hesap'**
  String get account;

  /// No description provided for @settings.
  ///
  /// In tr, this message translates to:
  /// **'Ayarlar'**
  String get settings;

  /// No description provided for @logout.
  ///
  /// In tr, this message translates to:
  /// **'Çıkış Yap'**
  String get logout;

  /// No description provided for @deleteAccount.
  ///
  /// In tr, this message translates to:
  /// **'Hesabı Sil'**
  String get deleteAccount;

  /// No description provided for @editProfile.
  ///
  /// In tr, this message translates to:
  /// **'Profili Düzenle'**
  String get editProfile;

  /// No description provided for @changePassword.
  ///
  /// In tr, this message translates to:
  /// **'Şifre Değiştir'**
  String get changePassword;

  /// No description provided for @notifications.
  ///
  /// In tr, this message translates to:
  /// **'Bildirimler'**
  String get notifications;

  /// No description provided for @theme.
  ///
  /// In tr, this message translates to:
  /// **'Görünüm'**
  String get theme;

  /// No description provided for @language.
  ///
  /// In tr, this message translates to:
  /// **'Dil'**
  String get language;

  /// No description provided for @privacyPolicy.
  ///
  /// In tr, this message translates to:
  /// **'Gizlilik Politikası'**
  String get privacyPolicy;

  /// No description provided for @termsOfService.
  ///
  /// In tr, this message translates to:
  /// **'Kullanım Koşulları'**
  String get termsOfService;

  /// No description provided for @appInfo.
  ///
  /// In tr, this message translates to:
  /// **'Uygulama Bilgileri'**
  String get appInfo;

  /// No description provided for @save.
  ///
  /// In tr, this message translates to:
  /// **'Kaydet'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In tr, this message translates to:
  /// **'İptal'**
  String get cancel;

  /// No description provided for @add.
  ///
  /// In tr, this message translates to:
  /// **'Ekle'**
  String get add;

  /// No description provided for @appearanceAndLanguage.
  ///
  /// In tr, this message translates to:
  /// **'Görünüm ve Dil'**
  String get appearanceAndLanguage;

  /// No description provided for @systemDefault.
  ///
  /// In tr, this message translates to:
  /// **'Sistem Varsayılanı'**
  String get systemDefault;

  /// No description provided for @devicePreference.
  ///
  /// In tr, this message translates to:
  /// **'Cihazınızın tercihine göre'**
  String get devicePreference;

  /// No description provided for @lightTheme.
  ///
  /// In tr, this message translates to:
  /// **'Açık Tema'**
  String get lightTheme;

  /// No description provided for @darkTheme.
  ///
  /// In tr, this message translates to:
  /// **'Koyu Tema'**
  String get darkTheme;

  /// No description provided for @turkish.
  ///
  /// In tr, this message translates to:
  /// **'Türkçe'**
  String get turkish;

  /// No description provided for @english.
  ///
  /// In tr, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @accessibility.
  ///
  /// In tr, this message translates to:
  /// **'Erişilebilirlik'**
  String get accessibility;

  /// No description provided for @highContrast.
  ///
  /// In tr, this message translates to:
  /// **'Yüksek Kontrastlı Renkler'**
  String get highContrast;

  /// No description provided for @improveReadability.
  ///
  /// In tr, this message translates to:
  /// **'Okunabilirliği iyileştir'**
  String get improveReadability;

  /// No description provided for @currentPassword.
  ///
  /// In tr, this message translates to:
  /// **'Mevcut Şifre'**
  String get currentPassword;

  /// No description provided for @newPassword.
  ///
  /// In tr, this message translates to:
  /// **'Yeni Şifre'**
  String get newPassword;

  /// No description provided for @confirmPassword.
  ///
  /// In tr, this message translates to:
  /// **'Yeni Şifre (Tekrar)'**
  String get confirmPassword;

  /// No description provided for @passwordChangedSuccessfully.
  ///
  /// In tr, this message translates to:
  /// **'Şifre başarıyla değiştirildi'**
  String get passwordChangedSuccessfully;

  /// No description provided for @changePasswordFailed.
  ///
  /// In tr, this message translates to:
  /// **'Şifre değiştirme başarısız'**
  String get changePasswordFailed;

  /// No description provided for @passwordRequired.
  ///
  /// In tr, this message translates to:
  /// **'Şifre gerekli'**
  String get passwordRequired;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In tr, this message translates to:
  /// **'Şifreler eşleşmiyor'**
  String get passwordsDoNotMatch;

  /// No description provided for @passwordTooShort.
  ///
  /// In tr, this message translates to:
  /// **'Şifre en az 8 karakter olmalı'**
  String get passwordTooShort;

  /// No description provided for @passwordTooLong.
  ///
  /// In tr, this message translates to:
  /// **'Şifre en fazla 40 karakter olabilir'**
  String get passwordTooLong;

  /// No description provided for @passwordSameAsCurrent.
  ///
  /// In tr, this message translates to:
  /// **'Yeni şifre mevcut şifreyle aynı olamaz'**
  String get passwordSameAsCurrent;

  /// No description provided for @resetYourPassword.
  ///
  /// In tr, this message translates to:
  /// **'Şifrenizi sıfırlayın'**
  String get resetYourPassword;

  /// No description provided for @enterEmailToReset.
  ///
  /// In tr, this message translates to:
  /// **'E-posta adresinizi girin, size şifre sıfırlama bağlantısı gönderelim.'**
  String get enterEmailToReset;

  /// No description provided for @sendResetLink.
  ///
  /// In tr, this message translates to:
  /// **'Sıfırlama Bağlantısı Gönder'**
  String get sendResetLink;

  /// No description provided for @emailSent.
  ///
  /// In tr, this message translates to:
  /// **'E-posta gönderildi!'**
  String get emailSent;

  /// No description provided for @checkEmailForLink.
  ///
  /// In tr, this message translates to:
  /// **'{email} adresine şifre sıfırlama bağlantısı gönderildi. Lütfen e-postanızı kontrol edin.'**
  String checkEmailForLink(String email);

  /// No description provided for @backToLogin.
  ///
  /// In tr, this message translates to:
  /// **'Giriş Ekranına Dön'**
  String get backToLogin;

  /// No description provided for @invalidEmail.
  ///
  /// In tr, this message translates to:
  /// **'Geçerli bir e-posta adresi girin'**
  String get invalidEmail;

  /// No description provided for @emailRequired.
  ///
  /// In tr, this message translates to:
  /// **'E-posta adresi gerekli'**
  String get emailRequired;

  /// No description provided for @notificationSettings.
  ///
  /// In tr, this message translates to:
  /// **'Bildirim Ayarları'**
  String get notificationSettings;

  /// No description provided for @notificationTypes.
  ///
  /// In tr, this message translates to:
  /// **'Bildirim Türleri'**
  String get notificationTypes;

  /// No description provided for @pushNotifications.
  ///
  /// In tr, this message translates to:
  /// **'Push Bildirimleri'**
  String get pushNotifications;

  /// No description provided for @inAppAndDevice.
  ///
  /// In tr, this message translates to:
  /// **'Uygulama içi ve cihaz bildirimleri'**
  String get inAppAndDevice;

  /// No description provided for @emailNotifications.
  ///
  /// In tr, this message translates to:
  /// **'E-posta Bildirimleri'**
  String get emailNotifications;

  /// No description provided for @importantUpdatesEmail.
  ///
  /// In tr, this message translates to:
  /// **'Önemli güncellemelerin e-postası'**
  String get importantUpdatesEmail;

  /// No description provided for @notificationCategories.
  ///
  /// In tr, this message translates to:
  /// **'Bildirim Kategorileri'**
  String get notificationCategories;

  /// No description provided for @cardComments.
  ///
  /// In tr, this message translates to:
  /// **'Kart Yorumları'**
  String get cardComments;

  /// No description provided for @notifyOnComments.
  ///
  /// In tr, this message translates to:
  /// **'Kartlara yorum yapıldığında bilgilendir'**
  String get notifyOnComments;

  /// No description provided for @cardAssignments.
  ///
  /// In tr, this message translates to:
  /// **'Kart Atanması'**
  String get cardAssignments;

  /// No description provided for @notifyOnAssignments.
  ///
  /// In tr, this message translates to:
  /// **'Sana kart atandığında bilgilendir'**
  String get notifyOnAssignments;

  /// No description provided for @boardUpdates.
  ///
  /// In tr, this message translates to:
  /// **'Pano Güncellemeleri'**
  String get boardUpdates;

  /// No description provided for @importantBoardChanges.
  ///
  /// In tr, this message translates to:
  /// **'Panonuzdaki önemli değişiklikler'**
  String get importantBoardChanges;

  /// No description provided for @mentions.
  ///
  /// In tr, this message translates to:
  /// **'Anılan Bildirimler'**
  String get mentions;

  /// No description provided for @notifyOnMentions.
  ///
  /// In tr, this message translates to:
  /// **'Sizi anılanlar için bildirim al'**
  String get notifyOnMentions;

  /// No description provided for @profileUpdatedSuccessfully.
  ///
  /// In tr, this message translates to:
  /// **'Profil güncellendi'**
  String get profileUpdatedSuccessfully;

  /// No description provided for @fullNameRequired.
  ///
  /// In tr, this message translates to:
  /// **'Ad soyad gerekli'**
  String get fullNameRequired;

  /// No description provided for @membersOf.
  ///
  /// In tr, this message translates to:
  /// **'{workspaceName} Üyeleri'**
  String membersOf(String workspaceName);

  /// No description provided for @noMembersFound.
  ///
  /// In tr, this message translates to:
  /// **'Henüz üye bulunmuyor.'**
  String get noMembersFound;

  /// No description provided for @unknownUser.
  ///
  /// In tr, this message translates to:
  /// **'Bilinmeyen Kullanıcı'**
  String get unknownUser;

  /// No description provided for @me.
  ///
  /// In tr, this message translates to:
  /// **'Ben'**
  String get me;

  /// No description provided for @makeAdmin.
  ///
  /// In tr, this message translates to:
  /// **'Admin Yap'**
  String get makeAdmin;

  /// No description provided for @makeMember.
  ///
  /// In tr, this message translates to:
  /// **'Member Yap'**
  String get makeMember;

  /// No description provided for @makeObserver.
  ///
  /// In tr, this message translates to:
  /// **'Observer Yap'**
  String get makeObserver;

  /// No description provided for @removeMember.
  ///
  /// In tr, this message translates to:
  /// **'Üyeyi Çıkar'**
  String get removeMember;

  /// No description provided for @roleUpdateFailed.
  ///
  /// In tr, this message translates to:
  /// **'Rol güncellenemedi'**
  String get roleUpdateFailed;

  /// No description provided for @removeMemberConfirm.
  ///
  /// In tr, this message translates to:
  /// **'Bu üyeyi çalışma alanından çıkarmak istediğinize emin misiniz?'**
  String get removeMemberConfirm;

  /// No description provided for @removeMemberFailed.
  ///
  /// In tr, this message translates to:
  /// **'Üye çıkarılamadı'**
  String get removeMemberFailed;

  /// No description provided for @remove.
  ///
  /// In tr, this message translates to:
  /// **'Çıkar'**
  String get remove;

  /// No description provided for @tryAgain.
  ///
  /// In tr, this message translates to:
  /// **'Tekrar Dene'**
  String get tryAgain;

  /// No description provided for @noWorkspacesYet.
  ///
  /// In tr, this message translates to:
  /// **'Henüz çalışma alanı yok'**
  String get noWorkspacesYet;

  /// No description provided for @createFirstWorkspace.
  ///
  /// In tr, this message translates to:
  /// **'Yeni bir çalışma alanı oluşturun'**
  String get createFirstWorkspace;

  /// No description provided for @newWorkspace.
  ///
  /// In tr, this message translates to:
  /// **'Yeni Alan'**
  String get newWorkspace;

  /// No description provided for @createWorkspace.
  ///
  /// In tr, this message translates to:
  /// **'Yeni Çalışma Alanı'**
  String get createWorkspace;

  /// No description provided for @workspaceName.
  ///
  /// In tr, this message translates to:
  /// **'Alan Adı'**
  String get workspaceName;

  /// No description provided for @descriptionOptional.
  ///
  /// In tr, this message translates to:
  /// **'Açıklama (isteğe bağlı)'**
  String get descriptionOptional;

  /// No description provided for @nameRequired.
  ///
  /// In tr, this message translates to:
  /// **'Ad gerekli'**
  String get nameRequired;

  /// No description provided for @createFailed.
  ///
  /// In tr, this message translates to:
  /// **'Oluşturulamadı'**
  String get createFailed;

  /// No description provided for @workspaceCreatedSuccessfully.
  ///
  /// In tr, this message translates to:
  /// **'Çalışma alanı oluşturuldu'**
  String get workspaceCreatedSuccessfully;

  /// No description provided for @manageMembers.
  ///
  /// In tr, this message translates to:
  /// **'Üyeleri Yönet'**
  String get manageMembers;

  /// No description provided for @inviteMember.
  ///
  /// In tr, this message translates to:
  /// **'Üye Davet Et'**
  String get inviteMember;

  /// No description provided for @editWorkspace.
  ///
  /// In tr, this message translates to:
  /// **'Çalışma Alanını Düzenle'**
  String get editWorkspace;

  /// No description provided for @deleteWorkspaceTitle.
  ///
  /// In tr, this message translates to:
  /// **'Çalışma Alanını Sil'**
  String get deleteWorkspaceTitle;

  /// No description provided for @deleteWorkspaceConfirm.
  ///
  /// In tr, this message translates to:
  /// **'\"{workspaceName}\" çalışma alanı silinecektir. Bu işlem geri alınamaz.'**
  String deleteWorkspaceConfirm(String workspaceName);

  /// No description provided for @deleteFailed.
  ///
  /// In tr, this message translates to:
  /// **'Silme başarısız'**
  String get deleteFailed;

  /// No description provided for @inviteToWorkspace.
  ///
  /// In tr, this message translates to:
  /// **'{workspaceName} alanına yeni bir üye davet edin.'**
  String inviteToWorkspace(String workspaceName);

  /// No description provided for @adminRole.
  ///
  /// In tr, this message translates to:
  /// **'Yönetici (Admin)'**
  String get adminRole;

  /// No description provided for @memberRole.
  ///
  /// In tr, this message translates to:
  /// **'Üye (Member)'**
  String get memberRole;

  /// No description provided for @observerRole.
  ///
  /// In tr, this message translates to:
  /// **'Gözlemci (Observer)'**
  String get observerRole;

  /// No description provided for @invitationFailed.
  ///
  /// In tr, this message translates to:
  /// **'Davet gönderilemedi'**
  String get invitationFailed;

  /// No description provided for @invitationSentSuccessfully.
  ///
  /// In tr, this message translates to:
  /// **'Davet başarıyla gönderildi'**
  String get invitationSentSuccessfully;

  /// No description provided for @send.
  ///
  /// In tr, this message translates to:
  /// **'Gönder'**
  String get send;

  /// No description provided for @lastUpdated.
  ///
  /// In tr, this message translates to:
  /// **'Son Güncelleme: {date}'**
  String lastUpdated(String date);

  /// No description provided for @profileInfo.
  ///
  /// In tr, this message translates to:
  /// **'Profil Bilgileri'**
  String get profileInfo;

  /// No description provided for @profileInfoSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Ad, e-posta, profil fotoğrafı'**
  String get profileInfoSubtitle;

  /// No description provided for @manageWorkspaces.
  ///
  /// In tr, this message translates to:
  /// **'Çalışma Alanlarını Yönet'**
  String get manageWorkspaces;

  /// No description provided for @manageWorkspacesSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Oluştur, düzenle, sil'**
  String get manageWorkspacesSubtitle;

  /// No description provided for @light.
  ///
  /// In tr, this message translates to:
  /// **'Açık'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In tr, this message translates to:
  /// **'Koyu'**
  String get dark;

  /// No description provided for @system.
  ///
  /// In tr, this message translates to:
  /// **'Sistem'**
  String get system;

  /// No description provided for @about.
  ///
  /// In tr, this message translates to:
  /// **'Hakkında'**
  String get about;

  /// No description provided for @version.
  ///
  /// In tr, this message translates to:
  /// **'Sürüm {version}'**
  String version(String version);

  /// No description provided for @appDescription.
  ///
  /// In tr, this message translates to:
  /// **'Kanban Board uygulaması, projelerinizi ve görevlerinizi kolayca yönetmeniz için tasarlanmıştır. MVVM mimarisi ve Flutter kullanılarak geliştirilmiştir.'**
  String get appDescription;

  /// No description provided for @developerLabel.
  ///
  /// In tr, this message translates to:
  /// **'Geliştirici: {name}'**
  String developerLabel(String name);

  /// No description provided for @licenseLabel.
  ///
  /// In tr, this message translates to:
  /// **'Lisans: {license}'**
  String licenseLabel(String license);

  /// No description provided for @termsContent1.
  ///
  /// In tr, this message translates to:
  /// **'1. Uygulamayı kullanarak bu koşulları kabul etmiş sayılırsınız.'**
  String get termsContent1;

  /// No description provided for @termsContent2.
  ///
  /// In tr, this message translates to:
  /// **'2. Verilerinizin güvenliği bizim için önemlidir.'**
  String get termsContent2;

  /// No description provided for @termsContent3.
  ///
  /// In tr, this message translates to:
  /// **'3. Uygulamayı kötüye kullanmak yasaktır.'**
  String get termsContent3;

  /// No description provided for @termsContent4.
  ///
  /// In tr, this message translates to:
  /// **'4. Servis sağlayıcı, hizmette değişiklik yapma hakkını saklı tutar.'**
  String get termsContent4;

  /// No description provided for @termsFooter.
  ///
  /// In tr, this message translates to:
  /// **'Bu koşullar zaman zaman güncellenebilir.'**
  String get termsFooter;

  /// No description provided for @privacyContent.
  ///
  /// In tr, this message translates to:
  /// **'Gizliliğiniz bizim için önemlidir. Verileriniz üçüncü taraflarla paylaşılmaz. Uygulama içerisinde toplanan veriler sadece deneyiminizi iyileştirmek ve hesap güvenliğinizi sağlamak amacıyla kullanılır.'**
  String get privacyContent;

  /// No description provided for @whatDataCollect.
  ///
  /// In tr, this message translates to:
  /// **'Hangi verileri topluyoruz?'**
  String get whatDataCollect;

  /// No description provided for @dataEmail.
  ///
  /// In tr, this message translates to:
  /// **'- E-posta adresi'**
  String get dataEmail;

  /// No description provided for @dataFullName.
  ///
  /// In tr, this message translates to:
  /// **'- Ad Soyad'**
  String get dataFullName;

  /// No description provided for @dataContent.
  ///
  /// In tr, this message translates to:
  /// **'- Oluşturduğunuz içerikler'**
  String get dataContent;

  /// No description provided for @deleteAccountConfirm.
  ///
  /// In tr, this message translates to:
  /// **'Hesabınız kalıcı olarak silinecektir. Bu işlem geri alınamaz. Devam etmek istiyor musunuz?'**
  String get deleteAccountConfirm;

  /// No description provided for @deleteAccountFailed.
  ///
  /// In tr, this message translates to:
  /// **'Hesap silme başarısız'**
  String get deleteAccountFailed;

  /// No description provided for @card.
  ///
  /// In tr, this message translates to:
  /// **'Kart'**
  String get card;

  /// No description provided for @noActivity.
  ///
  /// In tr, this message translates to:
  /// **'Aktivite yok'**
  String get noActivity;

  /// No description provided for @noActivityFoundForSelection.
  ///
  /// In tr, this message translates to:
  /// **'Bu seçime ait aktivite kaydı bulunmuyor.'**
  String get noActivityFoundForSelection;

  /// No description provided for @noWorkspacesFound.
  ///
  /// In tr, this message translates to:
  /// **'Çalışma alanları bulunamadı.'**
  String get noWorkspacesFound;

  /// No description provided for @noBoardsFound.
  ///
  /// In tr, this message translates to:
  /// **'Panolar bulunamadı.'**
  String get noBoardsFound;

  /// No description provided for @noCardsFound.
  ///
  /// In tr, this message translates to:
  /// **'Kartlar bulunamadı.'**
  String get noCardsFound;

  /// No description provided for @before.
  ///
  /// In tr, this message translates to:
  /// **'Önce'**
  String get before;

  /// No description provided for @after.
  ///
  /// In tr, this message translates to:
  /// **'Sonra'**
  String get after;

  /// No description provided for @inbox.
  ///
  /// In tr, this message translates to:
  /// **'Gelen Kutusu'**
  String get inbox;

  /// No description provided for @invitations.
  ///
  /// In tr, this message translates to:
  /// **'Davetler'**
  String get invitations;

  /// No description provided for @markAllReadSuccess.
  ///
  /// In tr, this message translates to:
  /// **'Tümü okundu olarak işaretlendi'**
  String get markAllReadSuccess;

  /// No description provided for @noNotifications.
  ///
  /// In tr, this message translates to:
  /// **'Bildiriminiz yok'**
  String get noNotifications;

  /// No description provided for @noNotificationsSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Tüm gelişmelerden haberdar olduğunuzda burada görünecek.'**
  String get noNotificationsSubtitle;

  /// No description provided for @receivedInvitations.
  ///
  /// In tr, this message translates to:
  /// **'Gelen Davetler'**
  String get receivedInvitations;

  /// No description provided for @noReceivedInvitations.
  ///
  /// In tr, this message translates to:
  /// **'Bekleyen davetiniz bulunmuyor.'**
  String get noReceivedInvitations;

  /// No description provided for @sentInvitations.
  ///
  /// In tr, this message translates to:
  /// **'Gönderilen Davetler'**
  String get sentInvitations;

  /// No description provided for @noSentInvitations.
  ///
  /// In tr, this message translates to:
  /// **'Bekleyen gönderilmiş davetiniz bulunmuyor.'**
  String get noSentInvitations;

  /// No description provided for @invitedBy.
  ///
  /// In tr, this message translates to:
  /// **'Davet eden: {name}'**
  String invitedBy(String name);

  /// No description provided for @reject.
  ///
  /// In tr, this message translates to:
  /// **'Reddet'**
  String get reject;

  /// No description provided for @accept.
  ///
  /// In tr, this message translates to:
  /// **'Kabul Et'**
  String get accept;

  /// No description provided for @invitationRejected.
  ///
  /// In tr, this message translates to:
  /// **'Davet reddedildi'**
  String get invitationRejected;

  /// No description provided for @invitationAccepted.
  ///
  /// In tr, this message translates to:
  /// **'Davet kabul edildi'**
  String get invitationAccepted;

  /// No description provided for @cancelInvitation.
  ///
  /// In tr, this message translates to:
  /// **'Daveti İptal Et'**
  String get cancelInvitation;

  /// No description provided for @cancelInvitationConfirm.
  ///
  /// In tr, this message translates to:
  /// **'Bu daveti iptal etmek istediğinize emin misiniz?'**
  String get cancelInvitationConfirm;

  /// No description provided for @yesCancel.
  ///
  /// In tr, this message translates to:
  /// **'Evet, İptal Et'**
  String get yesCancel;

  /// No description provided for @invitationCancelled.
  ///
  /// In tr, this message translates to:
  /// **'Davet iptal edildi'**
  String get invitationCancelled;

  /// No description provided for @justNow.
  ///
  /// In tr, this message translates to:
  /// **'Az önce'**
  String get justNow;

  /// No description provided for @minutesAgo.
  ///
  /// In tr, this message translates to:
  /// **'{count} dakika önce'**
  String minutesAgo(int count);

  /// No description provided for @hoursAgo.
  ///
  /// In tr, this message translates to:
  /// **'{count} saat önce'**
  String hoursAgo(int count);

  /// No description provided for @daysAgo.
  ///
  /// In tr, this message translates to:
  /// **'{count} gün önce'**
  String daysAgo(int count);

  /// No description provided for @username.
  ///
  /// In tr, this message translates to:
  /// **'Kullanıcı'**
  String get username;

  /// No description provided for @role.
  ///
  /// In tr, this message translates to:
  /// **'Rol'**
  String get role;

  /// No description provided for @editList.
  ///
  /// In tr, this message translates to:
  /// **'Listeyi Düzenle'**
  String get editList;

  /// No description provided for @cardMoveFailed.
  ///
  /// In tr, this message translates to:
  /// **'Kart taşınamadı'**
  String get cardMoveFailed;

  /// No description provided for @allNotifications.
  ///
  /// In tr, this message translates to:
  /// **'Tüm Bildirimler'**
  String get allNotifications;

  /// No description provided for @notifyOnAllActivity.
  ///
  /// In tr, this message translates to:
  /// **'Bu panodaki tüm etkinlikler için bildirim al'**
  String get notifyOnAllActivity;

  /// No description provided for @notifyOnPersonal.
  ///
  /// In tr, this message translates to:
  /// **'Sadece bana atanan veya etiketlendiğim durumlarda'**
  String get notifyOnPersonal;

  /// No description provided for @editBoard.
  ///
  /// In tr, this message translates to:
  /// **'Panoyu Düzenle'**
  String get editBoard;

  /// No description provided for @boardName.
  ///
  /// In tr, this message translates to:
  /// **'Pano Adı'**
  String get boardName;

  /// No description provided for @boardUpdated.
  ///
  /// In tr, this message translates to:
  /// **'Pano güncellendi'**
  String get boardUpdated;

  /// No description provided for @deleteBoardConfirm.
  ///
  /// In tr, this message translates to:
  /// **'Bu panoyu silmek istediğinize emin misiniz? Bu işlem geri alınamaz.'**
  String get deleteBoardConfirm;

  /// No description provided for @listName.
  ///
  /// In tr, this message translates to:
  /// **'Liste Adı'**
  String get listName;

  /// No description provided for @deleteListConfirm.
  ///
  /// In tr, this message translates to:
  /// **'\"{listName}\" isimli listeyi silmek istediğinize emin misiniz?'**
  String deleteListConfirm(String listName);

  /// No description provided for @cardTitle.
  ///
  /// In tr, this message translates to:
  /// **'Kart Başlığı'**
  String get cardTitle;

  /// No description provided for @titleRequired.
  ///
  /// In tr, this message translates to:
  /// **'Başlık gerekli'**
  String get titleRequired;

  /// No description provided for @boardBackground.
  ///
  /// In tr, this message translates to:
  /// **'Pano Arka Planı'**
  String get boardBackground;

  /// No description provided for @defaultOption.
  ///
  /// In tr, this message translates to:
  /// **'Varsayılan'**
  String get defaultOption;

  /// No description provided for @green.
  ///
  /// In tr, this message translates to:
  /// **'Yeşil'**
  String get green;

  /// No description provided for @yellow.
  ///
  /// In tr, this message translates to:
  /// **'Sarı'**
  String get yellow;

  /// No description provided for @backgroundUpdateFailed.
  ///
  /// In tr, this message translates to:
  /// **'Arka plan güncellenemedi'**
  String get backgroundUpdateFailed;

  /// No description provided for @loginFailed.
  ///
  /// In tr, this message translates to:
  /// **'Giriş başarısız'**
  String get loginFailed;

  /// No description provided for @emailNotFoundSignup.
  ///
  /// In tr, this message translates to:
  /// **'E-posta bulunmadı. Lütfen kayıt olun.'**
  String get emailNotFoundSignup;

  /// No description provided for @loginError.
  ///
  /// In tr, this message translates to:
  /// **'Giriş Hatası'**
  String get loginError;

  /// No description provided for @loginWithGoogle.
  ///
  /// In tr, this message translates to:
  /// **'Google ile Giriş Yap'**
  String get loginWithGoogle;

  /// No description provided for @purple.
  ///
  /// In tr, this message translates to:
  /// **'Mor'**
  String get purple;

  /// No description provided for @blue.
  ///
  /// In tr, this message translates to:
  /// **'Mavi'**
  String get blue;

  /// No description provided for @orange.
  ///
  /// In tr, this message translates to:
  /// **'Turuncu'**
  String get orange;

  /// No description provided for @pink.
  ///
  /// In tr, this message translates to:
  /// **'Pembe'**
  String get pink;

  /// No description provided for @teal.
  ///
  /// In tr, this message translates to:
  /// **'Turkuaz'**
  String get teal;

  /// No description provided for @colors.
  ///
  /// In tr, this message translates to:
  /// **'Renkler'**
  String get colors;

  /// No description provided for @signupFailed.
  ///
  /// In tr, this message translates to:
  /// **'Kayıt başarısız'**
  String get signupFailed;

  /// No description provided for @bySigningUp.
  ///
  /// In tr, this message translates to:
  /// **'Kayıt olarak '**
  String get bySigningUp;

  /// No description provided for @youAccept.
  ///
  /// In tr, this message translates to:
  /// **'\'nı kabul etmiş olursunuz.'**
  String get youAccept;

  /// No description provided for @termsOfServiceContent.
  ///
  /// In tr, this message translates to:
  /// **'Kullanım koşulları metni buraya gelecek...'**
  String get termsOfServiceContent;

  /// No description provided for @privacyPolicyContent.
  ///
  /// In tr, this message translates to:
  /// **'Gizlilik politikası metni buraya gelecek...'**
  String get privacyPolicyContent;

  /// No description provided for @ok.
  ///
  /// In tr, this message translates to:
  /// **'Tamam'**
  String get ok;

  /// No description provided for @and.
  ///
  /// In tr, this message translates to:
  /// **'ve'**
  String get and;

  /// No description provided for @error.
  ///
  /// In tr, this message translates to:
  /// **'Hata'**
  String get error;

  /// No description provided for @cards.
  ///
  /// In tr, this message translates to:
  /// **'Kartlar'**
  String get cards;

  /// No description provided for @createBoard.
  ///
  /// In tr, this message translates to:
  /// **'Pano Oluştur'**
  String get createBoard;

  /// No description provided for @newBoard.
  ///
  /// In tr, this message translates to:
  /// **'Yeni Pano'**
  String get newBoard;

  /// No description provided for @createBoardToWorkspace.
  ///
  /// In tr, this message translates to:
  /// **'{workspaceName} için Pano Oluştur'**
  String createBoardToWorkspace(String workspaceName);

  /// No description provided for @mustCreateWorkspaceFirst.
  ///
  /// In tr, this message translates to:
  /// **'Pano oluşturmak için önce bir Çalışma Alanı oluşturmalısınız.'**
  String get mustCreateWorkspaceFirst;

  /// No description provided for @boardCreatedSuccessfully.
  ///
  /// In tr, this message translates to:
  /// **'Pano oluşturuldu'**
  String get boardCreatedSuccessfully;

  /// No description provided for @boardCreateFailed.
  ///
  /// In tr, this message translates to:
  /// **'Pano oluşturulamadı'**
  String get boardCreateFailed;

  /// No description provided for @unknownWorkspace.
  ///
  /// In tr, this message translates to:
  /// **'Bilinmeyen Çalışma Alanı'**
  String get unknownWorkspace;

  /// No description provided for @createBoardTitle.
  ///
  /// In tr, this message translates to:
  /// **'Yeni Pano Oluştur'**
  String get createBoardTitle;
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
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
