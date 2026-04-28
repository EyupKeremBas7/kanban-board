# 🔄 Son Değişiklikler ve AI Handoff Belgesi

> **Ajanlara Not (Agent Handoff):** Bu belge, token sınırına ulaşıldığında veya yeni bir oturum başladığında, projeye dahil olan yeni AI ajanına (agent) bağlam (context) sağlamak için oluşturulmuştur. Yeni bir oturuma başlarken lütfen önce `FLUTTER_KURALLARI.md`, ardından `EKSIK_FEATURELAR.md` ve en son bu `SON_DEGISIKLIKLER.md` dosyasını okuyun.

---

## 📅 Tarih: 28 Nisan 2026

### ✅ Tamamlanan Son İşler
- **Bildirimler (Notifications) Entegrasyonu:** `NotificationsViewModel` oluşturuldu ve tüm CRUD operasyonları (getirme, okundu işaretleme, silme) API'ye bağlandı. `inbox.dart` ekranı güncellenerek pull-to-refresh, swipe-to-delete ve okunmamış bildirim mantığı eklendi. `main.dart` dosyasına Provider olarak eklendi.
- **Card Detail Entegrasyonu:** `card_detail.dart` ekranı gerçek verilere bağlandı. Checklist işlemleri (ekleme, silme, işaretleme) ve Yorum işlemleri (ekleme, silme) tamamen çalışır hale getirildi. 
- **Workspace Yönetimi:** `workspaces.dart` ekranı oluşturuldu. Kullanıcıların çalışma alanlarını listelemesi, yeni çalışma alanı oluşturması, mevcutları düzenlemesi ve silmesi (CRUD) işlemleri `WorkspacesViewModel` üzerinden entegre edildi.

### 🚧 Şu Anki Durum (Current State)
Temel Kanban özellikleri ve Bildirimler tamamlandı. Ancak davetiyeler (invitations) ve çalışma alanlarındaki üye yönetimi (workspace members) gibi kritik ortak çalışma özellikleri mobilde henüz bulunmuyor.

### ⏭️ Bir Sonraki Adım (Next Steps)
`EKSIK_FEATURELAR.md` dosyasında belirlenen **Sprint 1 (Yüksek Öncelik)** görevlerine devam edilecek.
Gelecek ajanın yapması gereken ilk iş (Davetiyeler - Invitations):
1. `Invitation` domain modelini oluştur ve `enums.dart` içine `InvitationStatus` enum'ını ekle.
2. `InvitationsViewModel` oluştur ve API fonksiyonlarını yaz.
3. `inbox.dart` ekranına sekme (tab) sistemi kur ("Bildirimler" | "Davetler").
4. `workspaces.dart` ekranına "Üye Davet Et" özelliği (e-posta ile) ekle.
5. `main.dart` içerisine `InvitationsViewModel` provider olarak kaydet.

---

*Lütfen her önemli özelliğin tamamlanmasının ardından bu dosyayı (ve gerekiyorsa `EKSIK_FEATURELAR.md` dosyasındaki ilgili checkbox'ları) güncelleyin.*
