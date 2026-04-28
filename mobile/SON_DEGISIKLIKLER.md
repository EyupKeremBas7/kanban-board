# 🔄 Son Değişiklikler ve AI Handoff Belgesi

> **Ajanlara Not (Agent Handoff):** Bu belge, token sınırına ulaşıldığında veya yeni bir oturum başladığında, projeye dahil olan yeni AI ajanına (agent) bağlam (context) sağlamak için oluşturulmuştur. Yeni bir oturuma başlarken lütfen önce `FLUTTER_KURALLARI.md`, ardından `EKSIK_FEATURELAR.md` ve en son bu `SON_DEGISIKLIKLER.md` dosyasını okuyun.

---

## 📅 Tarih: 28 Nisan 2026

### ✅ Tamamlanan Son İşler
- **Drag-and-Drop Kart Taşıma:** Kartlar uzun bas ile sürükle-bırak destekli, farklı listeler arasında taşınabiliyor. `CardsViewModel`'e `moveCardToList()` metodu eklendi. `board_detail.dart`'ta `DragTarget` + `LongPressDraggable` UI integration tamamlandı.
- **Workspace Üye Yönetimi (Sprint 1 Tamamlanış):** `WorkspaceMember` domain modeli + `WorkspacesViewModel` üye metodları (`fetchWorkspaceMembers`, `updateMemberRole`, `removeMember`) zaten mevcut durumdaydı. `workspace_members.dart` ekranı, tam CRUD + UI (role badges, member list, remove dialog) ile tamamlandı. `workspaces.dart`'ta "Üyeleri Yönet" ve "Üye Davet Et" menüleri entegre edildi.

### 🚧 Şu Anki Durum (Current State)
**Sprint 1 -- TAMAMLANDI.** Tüm temel Kanban özellikleri (Boards, Lists, Cards + Drag-and-Drop), Bildirimler, Davetiyeler, Üye Yönetimi hayata geçti. Kullanıcılar workspace oluştur, üye davet et, pano/liste/kart CRUD yapabilir, kartları taşıyabilir, bildirim ve davet yönetebilir.

### ⏭️ Bir Sonraki Adım (Next Steps)
**Sprint 2 (Orta Öncelik)** başlanabilir:
1. **Activity Log (Aktivite Akışı):** Board/workspace/card activity timeline
2. **Board Arka Plan Seçici:** Renk gradyası + fotoğraf background
3. **Çevrimdışı Desteği Temel:** LocalStorage/Cache layer

Bu görevler `EKSIK_FEATURELAR.md`'de ayrıntılı olarak listelenir.

---

*Lütfen her önemli özelliğin tamamlanmasının ardından bu dosyayı (ve gerekiyorsa `EKSIK_FEATURELAR.md` dosyasındaki ilgili checkbox'ları) güncelleyin.*
