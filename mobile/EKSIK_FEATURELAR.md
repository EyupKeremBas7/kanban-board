# 📋 Kanban Board Mobile — Eksik Feature Planı

> **⚠️ KURAL: Web/frontend kodu (`frontend/`) ve backend kodu (`backend/`) KESİNLİKLE değiştirilemez.**
> Bu belge yalnızca web uygulamasındaki mevcut özellikleri tespit edip, bunları mobil Flutter uygulamasına **taşıma** planını içerir.

---

## 🔍 Metodoloji

Aşağıdaki kaynaklar incelendi:
- `backend/app/api/routes/` — mevcut tüm API endpointleri
- `frontend/src/routes/` — web'deki tüm sayfalar ve bileşenler
- `mobile/` git geçmişi (tüm `feat(mobile):` commitleri)

---

## ✅ Mobilde Mevcut Olan Özellikler (Git Geçmişinden)

| # | Commit | Özellik |
|---|--------|---------|
| 1 | `e90c66c` | JWT login, signup, auto-login (ApiService + AuthViewModel) |
| 2 | `adcbe32` | Auth ekranları (splash, login, signup) |
| 3 | `56369f8` | Account ekranı — gerçek profil ve logout |
| 4 | `0fc7a06` | Profil düzenleme — `PATCH /users/me` |
| 5 | `65f7a13` | Şifre değiştirme — `PATCH /users/me/password` |
| 6 | `b1f1fa5` | Şifre sıfırlama — `POST /password-recovery/{email}` |
| 7 | `e5bb526` | Hesap silme — `DELETE /users/me` |
| 8 | `750b809` | Board listesi — `GET /boards` + pull-to-refresh |
| 9 | `b891c65` | Board oluşturma — `POST /boards` + workspace seçimi |
| 10 | `eab70ae` | Board güncelleme ve silme |
| 11 | `5409ffa` | Liste yönetimi — `GET/POST /lists` |
| 12 | `212d83a` | Kart CRUD — tam UI entegrasyonu |
| 13 | 5895d04 | Sürükle-bırak kart taşıma (sadece listeler arası çalışıyor) |
| 14 | d538964 | Card detail ekranında checklist + yorum entegrasyonu |
| 15 | `d538964` | Workspace yönetim ekranı (CRUD) |

---

## ❌ Mobilde Eksik Olan Özellikler

---

### 1. 🔔 Bildirimler (Notifications) — `YÜKSEK ÖNCELİK`

**Web'deki durum:** Backend tam API'ye sahip. `inbox.dart` ekranı mevcut ama tamamen stub (placeholder).

**Backend API:** `GET /api/v1/notifications/`
```
GET  /notifications/              → Bildirim listesi (skip, limit, unread_only)
GET  /notifications/unread-count  → Okunmamış sayısı
GET  /notifications/{id}          → Tek bildirim
PUT  /notifications/{id}/read     → Okundu işaretle
PUT  /notifications/read-all      → Tümünü okundu işaretle
DELETE /notifications/{id}        → Bildirim sil
```

**Yapılacaklar:**
- [x] `AppNotification` domain modeli (`lib/domain/models/notification.dart` içinde zaten mevcut)
- [x] `NotificationsViewModel` oluştur (tüm CRUD)
- [x] `inbox.dart` ekranını gerçek veriyle doldur
  - Okunmamış badge sayısı (bottom nav'a ekle)
  - Liste: avatar + mesaj + zaman + okundu/okunmadı ikonu
  - Swipe to delete
  - "Tümünü okundu işaretle" butonu
- [x] `main.dart`'a `NotificationsViewModel` Provider kaydı

---

### 2. 📨 Davetiyeler (Invitations) — `YÜKSEK ÖNCELİK`

**Web'deki durum:** Backend tam. Frontend workspace içinde üye davet edebiliyor. Mobilde hiç yok.

**Backend API:** `GET /api/v1/invitations/`
```
GET  /invitations/              → Bana gelen davetler (status filtresi)
GET  /invitations/sent          → Benim gönderdiğim davetler
POST /invitations/              → Davet gönder (invitee_email veya invitee_id)
POST /invitations/{id}/respond  → Kabul et / Reddet
DELETE /invitations/{id}        → Daveti iptal et
```

**Yapılacaklar:**
- [x] `Invitation` domain modeli ve `InvitationStatus` enum'ı (`enums.dart`'a eklenecek)
- [x] `InvitationsViewModel` oluştur
- [x] `inbox.dart` ekranına tab sistemi: "Bildirimler" | "Davetler"
  - Gelen davetler: workspace adı, davet eden kişi, rol, kabul/reddet butonları
  - Gönderilen davetler: bekleyen davetleri iptal etme
- [x] `workspaces.dart` ekranına davet gönderme özelliği
  - "Üye Davet Et" butonu → e-posta gir + rol seç dialog
- [x] `main.dart`'a `InvitationsViewModel` Provider kaydı

---

### 3. 👥 Workspace Üye Yönetimi — `YÜKSEK ÖNCELİK` ✅ **TAMAMLANDI**

**Web'deki durum:** `workspaces.tsx` genişletildiğinde üyeleri gösterir, ekler, rolünü değiştirir, çıkarır.

**Backend API:**
```
GET    /workspaces/{id}/members              → Üye listesi
POST   /workspaces/{id}/members             → Üye ekle (user_id + role)
POST   /workspaces/{id}/invite              → E-posta ile davet et
PUT    /workspaces/{id}/members/{member_id} → Rol güncelle
DELETE /workspaces/{id}/members/{member_id} → Üyeyi çıkar
```

**Tamamlanan İşler:**
- [x] `WorkspaceMember` domain modeli (`lib/domain/models/workspace_member.dart`)
- [x] `WorkspacesViewModel`'e üye metodları:
  - `fetchWorkspaceMembers(workspaceId)` ✅
  - `updateMemberRole(workspaceId, memberId, role)` ✅
  - `removeMember(workspaceId, memberId)` ✅
- [x] `workspace_members.dart` ekranı (full CRUD UI):
  - Üye avatarları + isim + rol badge ✅
  - Rol değiştirme (Admin/Member/Observer) ✅
  - Üyeyi çıkar (confirmation dialog ile) ✅
  - "Ben" göstergesi ✅
- [x] `workspaces.dart`'ta "Üyeleri Yönet" ve "Üye Davet Et" menüleri ✅

---

### 4. 📊 Activity Log (Aktivite Akışı) — `ORTA ÖNCELİK`

**Web'deki durum:** `activity.dart` stub ekran mevcut. Backend tam API var.

**Backend API:**
```
GET /activity/board/{board_id}        → Board aktiviteleri
GET /activity/workspace/{workspace_id} → Workspace aktiviteleri
GET /activity/card/{card_id}          → Kart aktiviteleri
```

**Yapılacaklar:**
- [ ] `ActivityLog` domain modeli
- [ ] `ActivityViewModel` oluştur
- [ ] `activity.dart` ekranını gerçek veriyle doldur
  - Tab: "Tüm Aktiviteler" / "Boards" / "Workspace"
  - Timeline stili liste: ikon + kullanıcı + eylem + zaman
  - Pull-to-refresh
  - Pagination (infinite scroll)
- [ ] `board_detail.dart`'ta board başlığına yanına aktivite ikonuna tıklanınca board aktiviteleri
- [ ] `card_detail.dart`'ta "Aktivite" bölümü ekle (card activity log)
- [ ] `main.dart`'a `ActivityViewModel` Provider kaydı

---

### 5. 🎨 Board Arka Plan Seçici — `ORTA ÖNCELİK` ✅ **TAMAMLANDI**

**Tamamlanan İşler:**
- [x] `board_detail.dart` AppBar'a "Arka Plan" aksiyonu ✅
- [x] `_showBackgroundPicker()` BottomSheet — 8 renk seçeneği ✅
- [x] `BoardsViewModel.updateBoard(backgroundImage: ...)` PUT /boards/{id} ✅

---

### 6. 🏠 Dashboard / Ana Ekran — `ORTA ÖNCELİK`

**Web'deki durum:** `index.tsx` — Workspace'e göre gruplandırılmış board listesi, "Son Görüntülenenler" paneli.

**Mevcut mobil:** `planner.dart` stub ekranı var.

**Yapılacaklar:**
- [ ] `planner.dart`'ı gerçek Dashboard ekranına dönüştür:
  - Workspace'e göre gruplandırılmış board grid'i
  - Her workspace için "+" ile hızlı board oluşturma
  - Son gezilen boardlar (local state veya SharedPreferences)
- [ ] Bottom nav'daki "Planner" sekmesini "Ana Sayfa" olarak yeniden adlandır

---

### 7. 📋 Liste Güncelleme ve Silme — `ORTA ÖNCELİK`

**Web'deki durum:** `lists.tsx` sayfasında liste CRUD tam. Board detay ekranında listenin `⋯` butonu var ama sadece UI'da.

**Backend API:**
```
PUT    /lists/{id} → Liste adı / sırası güncelle
DELETE /lists/{id} → Liste sil
```

**Mevcut mobil:** `lists_viewmodel.dart` zaten `updateList` ve `deleteList` metodları var ama `board_detail.dart`'ta `⋯` butonu bağlı değil.

**Yapılacaklar:**
- [ ] `board_detail.dart`'ta her listenin üstündeki `⋯` butonuna PopupMenu ekle:
  - "Listeyi Düzenle" → ad değiştirme dialogu
  - "Listeyi Sil" → onay dialogu

---

### 8. 🖼️ Profil Fotoğrafı / Resim Yükleme — `DÜŞÜK ÖNCELİK`

**Web'deki durum:** `POST /uploads/image` endpoint var. Profil fotoğrafı yükleme destekleniyor.

**Backend API:**
```
POST /uploads/image        → Resim yükle (multipart/form-data)
GET  /uploads/files/{filename} → Resmi al
```

**Yapılacaklar:**
- [ ] `pubspec.yaml`'a `image_picker` paketi ekle (kullanıcı onayı gerekli!)
- [ ] `profile_edit.dart`'ta avatar'a tıklanınca fotoğraf seçici
- [ ] Upload işlemi → dönen URL'yi `PATCH /users/me` ile kaydet

---

### 9. 🔗 Card — Atama (Assign to Member) — `DÜŞÜK ÖNCELİK`

**Web'deki durum:** Kart detay modalında `assigned_to` alanı düzenlenebiliyor.

**Backend API:**
```
PUT /cards/{id} → { assigned_to: "user_id" }
```

**Mevcut mobil:** `BoardCard` modelinde `assignedTo` alanı var ama UI'da düzenlenemiyor.

**Yapılacaklar:**
- [ ] `card_detail.dart`'ta "Atanan Kişi" bölümü ekle
  - Workspace üyelerini listele
  - Seçilen üyeyi karta ata / atamayı kaldır

---

### 10. 📅 Bitiş Tarihi (Due Date) Düzenleme — `DÜŞÜK ÖNCELİK`

**Web'deki durum:** Kart detayda due date seçici mevcut.

**Backend API:**
```
PUT /cards/{id} → { due_date: "ISO 8601 string" }
```

**Mevcut mobil:** `card_detail.dart`'ta `_DueDateTile` stub olarak "Belirlenmemiş" yazıyor.

**Yapılacaklar:**
- [ ] `card_detail.dart`'ta `_DueDateTile`'ı tıklanabilir yap
  - `showDatePicker` ile tarih seçici
  - Seçilen tarihi `CardsViewModel.updateCard(dueDate: ...)` ile kaydet
  - Geçmiş tarihse kırmızı renk uyarısı

---

### 11. 🔄 Aynı Liste İçinde Kart Sıralama (Drag & Drop) — `YÜKSEK ÖNCELİK` ✅ **TAMAMLANDI**

**Tamamlanan İşler:**
- [x] DragTarget `onWillAcceptWithDetails` aynı liste engeli kaldırıldı ✅
- [x] `CardsViewModel.moveCardToList()` aynı liste position hesaplama ✅
- [x] Kartlar aynı liste içinde sürüklenebiliyor ✅

---

### 12. 📊 Kart Üzerinde Özet Bilgiler (Checklist & Yorum Sayısı) — `ORTA ÖNCELİK`

**Mevcut mobil:** Kart detayına girildiğinde Checklist ve Yorumlar çalışıyor ancak Board görünümünde (kartların ön yüzünde) bu veriler sahte (mock) olarak duruyor (`commentCount = 0`, `checklistProgress = '0/0'`).

**Yapılacaklar:**
- [ ] `BoardCard` modeli için backend'den bu istatistikler gelmiyorsa UI'da sakla veya backend'den bu verileri çekecek/hesaplayacak bir yapı kur.
- [ ] Kart ön yüzünde (Board ekranı) checklist ilerlemesini (örn: 2/5) ve yorum sayısını gösteren küçük rozetler (badges) ekle.

---

## 📊 Öncelik Özeti

| Özellik | Öncelik | API Hazır | ViewModel Hazır |
|---------|---------|-----------|-----------------|
| Bildirimler | 🔴 Yüksek | ✅ | ❌ |
| Davetiyeler | 🔴 Yüksek | ✅ | ❌ |
| Workspace Üye Yönetimi | 🔴 Yüksek | ✅ | ⚠️ Kısmi |
| Aynı Liste İçi Kart Sıralama | 🔴 Yüksek | ✅ | ⚠️ Kısmi |
| Activity Log | 🟡 Orta | ✅ | ❌ |
| Board Arka Plan Seçici | 🟡 Orta | ✅ | ⚠️ Kısmi |
| Dashboard / Ana Ekran | 🟡 Orta | ✅ | ✅ |
| Liste Güncelle/Sil UI | 🟡 Orta | ✅ | ✅ |
| Kart Üzerinde Özet Bilgiler | 🟡 Orta | ⚠️ | ❌ |
| Profil Fotoğrafı Upload | 🟢 Düşük | ✅ | ❌ |
| Kart Atama | 🟢 Düşük | ✅ | ⚠️ Kısmi |
| Bitiş Tarihi Düzenleme | 🟢 Düşük | ✅ | ⚠️ Kısmi |

---

## 🏁 Önerilen Geliştirme Sırası

```
Sprint 1 (Yüksek Öncelik):
  1. NotificationsViewModel + inbox.dart
  2. InvitationsViewModel + inbox.dart'a tab
  3. Workspace üye yönetimi (workspaces.dart genişletme)

Sprint 2 (Orta Öncelik):
  4. Activity Log — activity.dart + card_detail bölümü
  5. Board arka plan seçici — board_detail.dart
  6. Liste güncelle/sil — board_detail.dart ⋯ menüsü
  7. Dashboard — planner.dart dönüşümü

Sprint 3 (Düşük Öncelik):
  8. Due date düzenleme — card_detail.dart
  9. Kart atama — card_detail.dart
  10. Profil fotoğrafı upload (pubspec değişikliği gerektirir)
```

---

> *Son güncelleme: Nisan 2026*
> *Kaynak: `git log --oneline` + `backend/app/api/routes/` + `frontend/src/routes/` analizi*
