# 🔄 Son Değişiklikler ve AI Handoff Belgesi

> **Ajanlara Not (Agent Handoff):** Bu belge, token sınırına ulaşıldığında veya yeni bir oturum başladığında, projeye dahil olan yeni AI ajanına (agent) bağlam (context) sağlamak için oluşturulmuştur. Yeni bir oturuma başlarken lütfen önce `FLUTTER_KURALLARI.md`, ardından `EKSIK_FEATURELAR.md` ve en son bu `SON_DEGISIKLIKLER.md` dosyasını okuyun.

---

## 📅 Tarih: 28 Nisan 2026

### ✅ Tamamlanan Son İşler
- **Davetiyeler (Invitations) Entegrasyonu:** `Invitation` modeli ve `InvitationsViewModel` oluşturuldu. `inbox.dart` ekranı sekmeli yapıya çevrilerek "Davetler" kısmı eklendi (kabul/red/iptal işlemleriyle birlikte). `workspaces.dart` ekranına "Üye Davet Et" özelliği eklendi.
- **Hata Çözümü (Bugfix):** Yeni kullanıcıların (hiç çalışma alanı olmayanların) pano oluştururken karşılaştığı sonsuz yükleme ekranı hatası çözüldü. Artık kullanıcı, "Pano oluşturmak için önce bir Çalışma Alanı oluşturmalısınız" şeklinde yönlendiriliyor.
- **Bildirimler (Notifications) Entegrasyonu:** `NotificationsViewModel` oluşturuldu ve tüm CRUD operasyonları (getirme, okundu işaretleme, silme) API'ye bağlandı. `inbox.dart` ekranına eklendi.

### 🚧 Şu Anki Durum (Current State)
Temel Kanban özellikleri, Bildirimler ve Davetiyeler (Invitations) modülü tamamlandı. Sıradaki hedef, davet edilen üyelerin çalışma alanı içerisinde yönetilmesi (Workspace Member Management) sürecidir.

### ⏭️ Bir Sonraki Adım (Next Steps)
`EKSIK_FEATURELAR.md` dosyasında belirlenen **Sprint 1 (Yüksek Öncelik)** son görevlerine devam edilecek.
Gelecek ajanın yapması gereken ilk iş (Workspace Üye Yönetimi):
1. `WorkspaceMember` domain modeli oluştur.
2. `WorkspacesViewModel`'e üye metodlarını (fetchMembers, updateMemberRole, removeMember) ekle.
3. `workspaces.dart` ekranına üye listesi panelini (avatar, isim, rol badge) ve yönetim arayüzünü (rol değiştirme, üyeyi çıkarma) entegre et.

---

*Lütfen her önemli özelliğin tamamlanmasının ardından bu dosyayı (ve gerekiyorsa `EKSIK_FEATURELAR.md` dosyasındaki ilgili checkbox'ları) güncelleyin.*
