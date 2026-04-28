# 🔄 Son Değişiklikler ve AI Handoff Belgesi

> **Ajanlara Not (Agent Handoff):** Bu belge, token sınırına ulaşıldığında veya yeni bir oturum başladığında, projeye dahil olan yeni AI ajanına (agent) bağlam (context) sağlamak için oluşturulmuştur. Yeni bir oturuma başlarken lütfen önce `FLUTTER_KURALLARI.md`, ardından `EKSIK_FEATURELAR.md` ve en son bu `SON_DEGISIKLIKLER.md` dosyasını okuyun.

---

## 📅 Tarih: 28 Nisan 2026

### ✅ Tamamlanan Son İşler
- **Board Arka Plan Seçici:** Board AppBar'a "Arka Plan" butonu eklendi. BottomSheet ile 8 renk seçeneği (mor, mavi, yeşil, turuncu, pembe, turkuaz, sarı + varsayılan). `BoardsViewModel.updateBoard(backgroundImage: ...)` ile `PUT /boards/{id}` çağrısı yapıldı.
- **Aynı Liste İçi Kart Sıralama:** `moveCardToList()` methodunda aynı liste içi durumlar için position hesaplama eklendi. Kartlar artık aynı liste içinde yukarı/aşağı sürüklenebiliyor.

### 🚧 Şu Anki Durum (Current State)
**Sprint 1 + Sprint 2 İlk Portion -- TAMAMLANDI.** Temel Kanban (Boards, Lists, Cards + Drag-and-Drop), Bildirimler, Davetiyeler, Üye Yönetimi, Board Arka Plan Seçici, Kart İçi Sıralama tamamlandı.

### ⏭️ Bir Sonraki Adım (Next Steps)
**Sprint 2 Kalan Görevler:**
1. **Activity Log (Aktivite Akışı):** Board/workspace/card activity timeline
2. **Liste Güncelle/Sil UI:** board_detail.dart liste menüsü
3. **Dashboard:** planner.dart workspace grouping

Bu görevler `EKSIK_FEATURELAR.md`'de ayrıntılı olarak listelenir.

---

*Lütfen her önemli özelliğin tamamlanmasının ardından bu dosyayı (ve gerekiyorsa `EKSIK_FEATURELAR.md` dosyasındaki ilgili checkbox'ları) güncelleyin.*
