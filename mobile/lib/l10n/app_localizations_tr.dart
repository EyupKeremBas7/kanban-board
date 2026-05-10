// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'Kanban Board';

  @override
  String get login => 'Giriş Yap';

  @override
  String get signup => 'Üye Ol';

  @override
  String get email => 'E-posta';

  @override
  String get password => 'Şifre';

  @override
  String get fullName => 'Ad Soyad';

  @override
  String get forgotPassword => 'Şifremi Unuttum';

  @override
  String get noAccount => 'Hesabın yok mu? Kayıt ol';

  @override
  String get alreadyHaveAccount => 'Zaten hesabın var mı? Giriş yap';

  @override
  String get boards => 'Panolar';

  @override
  String get workspaces => 'Çalışma Alanları';

  @override
  String get activity => 'Etkinlik';

  @override
  String get account => 'Hesap';

  @override
  String get settings => 'Ayarlar';

  @override
  String get logout => 'Çıkış Yap';

  @override
  String get deleteAccount => 'Hesabı Sil';

  @override
  String get editProfile => 'Profili Düzenle';

  @override
  String get changePassword => 'Şifre Değiştir';

  @override
  String get notifications => 'Bildirimler';

  @override
  String get theme => 'Görünüm';

  @override
  String get language => 'Dil';

  @override
  String get privacyPolicy => 'Gizlilik Politikası';

  @override
  String get termsOfService => 'Kullanım Koşulları';

  @override
  String get appInfo => 'Uygulama Bilgileri';

  @override
  String get save => 'Kaydet';

  @override
  String get cancel => 'İptal';

  @override
  String get add => 'Ekle';

  @override
  String get appearanceAndLanguage => 'Görünüm ve Dil';

  @override
  String get systemDefault => 'Sistem Varsayılanı';

  @override
  String get devicePreference => 'Cihazınızın tercihine göre';

  @override
  String get lightTheme => 'Açık Tema';

  @override
  String get darkTheme => 'Koyu Tema';

  @override
  String get turkish => 'Türkçe';

  @override
  String get english => 'English';

  @override
  String get accessibility => 'Erişilebilirlik';

  @override
  String get highContrast => 'Yüksek Kontrastlı Renkler';

  @override
  String get improveReadability => 'Okunabilirliği iyileştir';

  @override
  String get currentPassword => 'Mevcut Şifre';

  @override
  String get newPassword => 'Yeni Şifre';

  @override
  String get confirmPassword => 'Yeni Şifre (Tekrar)';

  @override
  String get passwordChangedSuccessfully => 'Şifre başarıyla değiştirildi';

  @override
  String get changePasswordFailed => 'Şifre değiştirme başarısız';

  @override
  String get passwordRequired => 'Şifre gerekli';

  @override
  String get passwordsDoNotMatch => 'Şifreler eşleşmiyor';

  @override
  String get passwordTooShort => 'Şifre en az 8 karakter olmalı';

  @override
  String get passwordTooLong => 'Şifre en fazla 40 karakter olabilir';

  @override
  String get passwordSameAsCurrent => 'Yeni şifre mevcut şifreyle aynı olamaz';

  @override
  String get resetYourPassword => 'Şifrenizi sıfırlayın';

  @override
  String get enterEmailToReset =>
      'E-posta adresinizi girin, size şifre sıfırlama bağlantısı gönderelim.';

  @override
  String get sendResetLink => 'Sıfırlama Bağlantısı Gönder';

  @override
  String get emailSent => 'E-posta gönderildi!';

  @override
  String checkEmailForLink(String email) {
    return '$email adresine şifre sıfırlama bağlantısı gönderildi. Lütfen e-postanızı kontrol edin.';
  }

  @override
  String get backToLogin => 'Giriş Ekranına Dön';

  @override
  String get invalidEmail => 'Geçerli bir e-posta adresi girin';

  @override
  String get emailRequired => 'E-posta adresi gerekli';

  @override
  String get notificationSettings => 'Bildirim Ayarları';

  @override
  String get notificationTypes => 'Bildirim Türleri';

  @override
  String get pushNotifications => 'Push Bildirimleri';

  @override
  String get inAppAndDevice => 'Uygulama içi ve cihaz bildirimleri';

  @override
  String get emailNotifications => 'E-posta Bildirimleri';

  @override
  String get importantUpdatesEmail => 'Önemli güncellemelerin e-postası';

  @override
  String get notificationCategories => 'Bildirim Kategorileri';

  @override
  String get cardComments => 'Kart Yorumları';

  @override
  String get notifyOnComments => 'Kartlara yorum yapıldığında bilgilendir';

  @override
  String get cardAssignments => 'Kart Atanması';

  @override
  String get notifyOnAssignments => 'Sana kart atandığında bilgilendir';

  @override
  String get boardUpdates => 'Pano Güncellemeleri';

  @override
  String get importantBoardChanges => 'Panonuzdaki önemli değişiklikler';

  @override
  String get mentions => 'Anılan Bildirimler';

  @override
  String get notifyOnMentions => 'Sizi anılanlar için bildirim al';

  @override
  String get profileUpdatedSuccessfully => 'Profil güncellendi';

  @override
  String get fullNameRequired => 'Ad soyad gerekli';

  @override
  String membersOf(String workspaceName) {
    return '$workspaceName Üyeleri';
  }

  @override
  String get noMembersFound => 'Henüz üye bulunmuyor.';

  @override
  String get unknownUser => 'Bilinmeyen Kullanıcı';

  @override
  String get me => 'Ben';

  @override
  String get makeAdmin => 'Admin Yap';

  @override
  String get makeMember => 'Member Yap';

  @override
  String get makeObserver => 'Observer Yap';

  @override
  String get removeMember => 'Üyeyi Çıkar';

  @override
  String get roleUpdateFailed => 'Rol güncellenemedi';

  @override
  String get removeMemberConfirm =>
      'Bu üyeyi çalışma alanından çıkarmak istediğinize emin misiniz?';

  @override
  String get removeMemberFailed => 'Üye çıkarılamadı';

  @override
  String get remove => 'Çıkar';

  @override
  String get tryAgain => 'Tekrar Dene';

  @override
  String get noWorkspacesYet => 'Henüz çalışma alanı yok';

  @override
  String get createFirstWorkspace => 'Yeni bir çalışma alanı oluşturun';

  @override
  String get newWorkspace => 'Yeni Alan';

  @override
  String get createWorkspace => 'Yeni Çalışma Alanı';

  @override
  String get workspaceName => 'Alan Adı';

  @override
  String get descriptionOptional => 'Açıklama (isteğe bağlı)';

  @override
  String get nameRequired => 'Ad gerekli';

  @override
  String get createFailed => 'Oluşturulamadı';

  @override
  String get workspaceCreatedSuccessfully => 'Çalışma alanı oluşturuldu';

  @override
  String get manageMembers => 'Üyeleri Yönet';

  @override
  String get inviteMember => 'Üye Davet Et';

  @override
  String get editWorkspace => 'Çalışma Alanını Düzenle';

  @override
  String get deleteWorkspaceTitle => 'Çalışma Alanını Sil';

  @override
  String deleteWorkspaceConfirm(String workspaceName) {
    return '\"$workspaceName\" çalışma alanı silinecektir. Bu işlem geri alınamaz.';
  }

  @override
  String get deleteFailed => 'Silme başarısız';

  @override
  String inviteToWorkspace(String workspaceName) {
    return '$workspaceName alanına yeni bir üye davet edin.';
  }

  @override
  String get adminRole => 'Yönetici (Admin)';

  @override
  String get memberRole => 'Üye (Member)';

  @override
  String get observerRole => 'Gözlemci (Observer)';

  @override
  String get invitationFailed => 'Davet gönderilemedi';

  @override
  String get invitationSentSuccessfully => 'Davet başarıyla gönderildi';

  @override
  String get send => 'Gönder';

  @override
  String lastUpdated(String date) {
    return 'Son Güncelleme: $date';
  }

  @override
  String get profileInfo => 'Profil Bilgileri';

  @override
  String get profileInfoSubtitle => 'Ad, e-posta, profil fotoğrafı';

  @override
  String get manageWorkspaces => 'Çalışma Alanlarını Yönet';

  @override
  String get manageWorkspacesSubtitle => 'Oluştur, düzenle, sil';

  @override
  String get light => 'Açık';

  @override
  String get dark => 'Koyu';

  @override
  String get system => 'Sistem';

  @override
  String get about => 'Hakkında';

  @override
  String version(String version) {
    return 'Sürüm $version';
  }

  @override
  String get appDescription =>
      'Kanban Board uygulaması, projelerinizi ve görevlerinizi kolayca yönetmeniz için tasarlanmıştır. MVVM mimarisi ve Flutter kullanılarak geliştirilmiştir.';

  @override
  String developerLabel(String name) {
    return 'Geliştirici: $name';
  }

  @override
  String licenseLabel(String license) {
    return 'Lisans: $license';
  }

  @override
  String get termsContent1 =>
      '1. Uygulamayı kullanarak bu koşulları kabul etmiş sayılırsınız.';

  @override
  String get termsContent2 =>
      '2. Verilerinizin güvenliği bizim için önemlidir.';

  @override
  String get termsContent3 => '3. Uygulamayı kötüye kullanmak yasaktır.';

  @override
  String get termsContent4 =>
      '4. Servis sağlayıcı, hizmette değişiklik yapma hakkını saklı tutar.';

  @override
  String get termsFooter => 'Bu koşullar zaman zaman güncellenebilir.';

  @override
  String get privacyContent =>
      'Gizliliğiniz bizim için önemlidir. Verileriniz üçüncü taraflarla paylaşılmaz. Uygulama içerisinde toplanan veriler sadece deneyiminizi iyileştirmek ve hesap güvenliğinizi sağlamak amacıyla kullanılır.';

  @override
  String get whatDataCollect => 'Hangi verileri topluyoruz?';

  @override
  String get dataEmail => '- E-posta adresi';

  @override
  String get dataFullName => '- Ad Soyad';

  @override
  String get dataContent => '- Oluşturduğunuz içerikler';

  @override
  String get deleteAccountConfirm =>
      'Hesabınız kalıcı olarak silinecektir. Bu işlem geri alınamaz. Devam etmek istiyor musunuz?';

  @override
  String get deleteAccountFailed => 'Hesap silme başarısız';

  @override
  String get card => 'Kart';

  @override
  String get noActivity => 'Aktivite yok';

  @override
  String get noActivityFoundForSelection =>
      'Bu seçime ait aktivite kaydı bulunmuyor.';

  @override
  String get noWorkspacesFound => 'Çalışma alanları bulunamadı.';

  @override
  String get noBoardsFound => 'Panolar bulunamadı.';

  @override
  String get noCardsFound => 'Kartlar bulunamadı.';

  @override
  String get before => 'Önce';

  @override
  String get after => 'Sonra';

  @override
  String get inbox => 'Gelen Kutusu';

  @override
  String get invitations => 'Davetler';

  @override
  String get markAllReadSuccess => 'Tümü okundu olarak işaretlendi';

  @override
  String get noNotifications => 'Bildiriminiz yok';

  @override
  String get noNotificationsSubtitle =>
      'Tüm gelişmelerden haberdar olduğunuzda burada görünecek.';

  @override
  String get receivedInvitations => 'Gelen Davetler';

  @override
  String get noReceivedInvitations => 'Bekleyen davetiniz bulunmuyor.';

  @override
  String get sentInvitations => 'Gönderilen Davetler';

  @override
  String get noSentInvitations => 'Bekleyen gönderilmiş davetiniz bulunmuyor.';

  @override
  String invitedBy(String name) {
    return 'Davet eden: $name';
  }

  @override
  String get reject => 'Reddet';

  @override
  String get accept => 'Kabul Et';

  @override
  String get invitationRejected => 'Davet reddedildi';

  @override
  String get invitationAccepted => 'Davet kabul edildi';

  @override
  String get cancelInvitation => 'Daveti İptal Et';

  @override
  String get cancelInvitationConfirm =>
      'Bu daveti iptal etmek istediğinize emin misiniz?';

  @override
  String get yesCancel => 'Evet, İptal Et';

  @override
  String get invitationCancelled => 'Davet iptal edildi';

  @override
  String get justNow => 'Az önce';

  @override
  String minutesAgo(int count) {
    return '$count dakika önce';
  }

  @override
  String hoursAgo(int count) {
    return '$count saat önce';
  }

  @override
  String daysAgo(int count) {
    return '$count gün önce';
  }

  @override
  String get username => 'Kullanıcı';

  @override
  String get role => 'Rol';

  @override
  String get editList => 'Listeyi Düzenle';

  @override
  String get cardMoveFailed => 'Kart taşınamadı';

  @override
  String get allNotifications => 'Tüm Bildirimler';

  @override
  String get notifyOnAllActivity =>
      'Bu panodaki tüm etkinlikler için bildirim al';

  @override
  String get notifyOnPersonal =>
      'Sadece bana atanan veya etiketlendiğim durumlarda';

  @override
  String get editBoard => 'Panoyu Düzenle';

  @override
  String get boardName => 'Pano Adı';

  @override
  String get boardUpdated => 'Pano güncellendi';

  @override
  String get deleteBoardConfirm =>
      'Bu panoyu silmek istediğinize emin misiniz? Bu işlem geri alınamaz.';

  @override
  String get listName => 'Liste Adı';

  @override
  String deleteListConfirm(String listName) {
    return '\"$listName\" isimli listeyi silmek istediğinize emin misiniz?';
  }

  @override
  String get cardTitle => 'Kart Başlığı';

  @override
  String get titleRequired => 'Başlık gerekli';

  @override
  String get boardBackground => 'Pano Arka Planı';

  @override
  String get defaultOption => 'Varsayılan';

  @override
  String get green => 'Yeşil';

  @override
  String get yellow => 'Sarı';

  @override
  String get backgroundUpdateFailed => 'Arka plan güncellenemedi';

  @override
  String get loginFailed => 'Giriş başarısız';

  @override
  String get emailNotFoundSignup => 'E-posta bulunmadı. Lütfen kayıt olun.';

  @override
  String get loginError => 'Giriş Hatası';

  @override
  String get loginWithGoogle => 'Google ile Giriş Yap';

  @override
  String get purple => 'Mor';

  @override
  String get blue => 'Mavi';

  @override
  String get orange => 'Turuncu';

  @override
  String get pink => 'Pembe';

  @override
  String get teal => 'Turkuaz';

  @override
  String get colors => 'Renkler';

  @override
  String get signupFailed => 'Kayıt başarısız';

  @override
  String get bySigningUp => 'Kayıt olarak ';

  @override
  String get youAccept => '\'nı kabul etmiş olursunuz.';

  @override
  String get termsOfServiceContent =>
      'Kullanım koşulları metni buraya gelecek...';

  @override
  String get privacyPolicyContent =>
      'Gizlilik politikası metni buraya gelecek...';

  @override
  String get ok => 'Tamam';

  @override
  String get and => 've';

  @override
  String get error => 'Hata';

  @override
  String get cards => 'Kartlar';

  @override
  String get createBoard => 'Pano Oluştur';

  @override
  String get newBoard => 'Yeni Pano';

  @override
  String createBoardToWorkspace(String workspaceName) {
    return '$workspaceName için Pano Oluştur';
  }

  @override
  String get mustCreateWorkspaceFirst =>
      'Pano oluşturmak için önce bir Çalışma Alanı oluşturmalısınız.';

  @override
  String get boardCreatedSuccessfully => 'Pano oluşturuldu';

  @override
  String get boardCreateFailed => 'Pano oluşturulamadı';

  @override
  String get unknownWorkspace => 'Bilinmeyen Çalışma Alanı';

  @override
  String get createBoardTitle => 'Yeni Pano Oluştur';
}
