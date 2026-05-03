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

## 📅 Tarih: 3 Mayıs 2026

### ✅ Tamamlanan Son İşler
- **Dashboard Son Görüntülenenler Kalıcılığı:** `RecentBoardsService` eklendi (`SharedPreferences` tabanlı). Son ziyaret edilen pano ID'leri kalıcı tutuluyor.
- **Global Son Gezilene Yazma:** `board_detail.dart` açıldığında pano otomatik olarak son görüntülenenlere yazılıyor.
- **Planner Ekranı Entegrasyonu:** `planner.dart` açılışta kalıcı son gezilen pano listesini yükleyip “Son Görüntülenenler” panelinde gösteriyor.
- **Eksik Feature Planı Güncellemesi:** `EKSIK_FEATURELAR.md` içinde Dashboard/Ana Ekran ve Liste Güncelleme-Silme maddeleri tamamlandı olarak işaretlendi.

### 🚧 Şu Anki Durum (Current State)
- Dashboard tarafı (workspace gruplama + hızlı pano oluşturma + son gezilenler) tamam.
- Liste düzenle/sil akışı board detay ekranında tamam.
- Sıradaki mantıklı düşük/orta öncelik işleri: profil fotoğrafı yükleme, karta atama, due date düzenleme.

---

## 📅 Tarih: 3 Mayıs 2026 (Devam)

### ✅ Tamamlanan Son İşler
- **Due Date Düzenleme Tamamlandı:** `card_detail.dart` içindeki `_DueDateTile` gerçek tarih seçici (`showDatePicker`) ile güncelleme akışına bağlandı.
- **Kırmızı Gecikme Uyarısı:** Geçmiş tarihler için due date alanında kırmızı renk ve `Gecikti` etiketi eklendi.
- **Due Date Temizleme:** Kartın mevcut bitiş tarihini kaldırma (clear due date) işlemi hata yönetimi ile güncellendi.
- **Plan Dokümanı Güncellemesi:** `EKSIK_FEATURELAR.md` içinde Due Date maddesi tamamlandı olarak işaretlendi.

### 🚧 Güncel Sıradaki İşler
- Kart atama akışının UX iyileştirmesi (üyeleri arama/filtreleme)
- Kart ön yüzünde checklist/yorum rozetlerinin gerçek veriyle gösterimi

---

## 📅 Tarih: 3 Mayıs 2026 (Devam 2)

### ✅ Tamamlanan Son İşler
- **Kart Rozetleri Gerçek Veriye Bağlandı:** `board_detail.dart` kart tile üzerinde checklist ilerleme (`x/y`) ve yorum sayısı rozetleri eklendi.
- **Stats Cache Altyapısı:** `cards_viewmodel.dart` içine kart bazlı yorum sayısı + checklist ilerleme cache/prefetch mekanizması eklendi.
- **Geri Dönüşte Tazeleme:** Kart detay ekranından dönüldüğünde ilgili kartın rozet verisi force-refresh ediliyor.
- **Plan Dokümanı Güncellemesi:** `EKSIK_FEATURELAR.md` içinde “Kart Üzerinde Özet Bilgiler” maddesi tamamlandı olarak işaretlendi.

### 🚧 Güncel Sıradaki İşler
- Kart atama UX iyileştirmesi (üyelerde arama/filtreleme + daha net seçim deneyimi)

---

*Lütfen her önemli özelliğin tamamlanmasının ardından bu dosyayı (ve gerekiyorsa `EKSIK_FEATURELAR.md` dosyasındaki ilgili checkbox'ları) güncelleyin.*
