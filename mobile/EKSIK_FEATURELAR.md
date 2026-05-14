# Kanban Board Mobile - Guncel Eksik Feature ve Sunum Notlari

> Guncelleme tarihi: 13 Mayis 2026
>
> Bu belge artik sadece "mobilde eksik ne var?" listesi degil; web, backend, mobil ve git gecmisi incelendikten sonra 18 Mayis sunumu oncesi durum fotografi, riskler ve son dokunus fikirlerini de icerir.

---

## Kisa Sonuc

Mobil taraf web'e ciddi sekilde yaklasmis durumda. Ilk plandaki temel eksiklerin cogu kapatilmis: bildirimler, davetler, workspace uye yonetimi, activity, dashboard, due date, assignee, kapak resmi, kart rozetleri ve ayni liste icinde siralama artik kodda var.

18 Mayis'a kadar ana hedef yeni buyuk feature acmak degil; demo akisini bozabilecek pürüzleri temizlemek olmali:

- UI metinleri ve localization hack'leri
- Realtime/socket akisini canli senaryoda dogrulama
- Activity log yazma akisini backend eventlerine baglama
- Mobilde performans/takilma hissini azaltma
- Backend test ortamini temizleme
- README/handoff belgelerini guncel durumla uyumlu hale getirme

---

## Son Inceleme Kaynaklari

Bakilan kaynaklar:

- `README.md`, `frontend/README.md`, `backend/README.md`
- `mobile/EKSIK_FEATURELAR.md`, `mobile/SON_DEGISIKLIKLER.md`
- `git log --oneline -n 25`
- `git status --short`
- Web board detayi: `frontend/src/routes/_layout/board.$boardId.tsx`
- Mobil ana ekranlar: `board_detail.dart`, `card_detail.dart`, `inbox.dart`, `activity.dart`, `workspaces.dart`, `planner.dart`
- Socket/realtime dosyalari: `backend/app/core/sockets.py`, `backend/app/events/socket_handler.py`, `frontend/src/hooks/useSocket.ts`, `mobile/lib/services/socket_service.dart`

Dogrulama:

- `frontend`: `npm run build` basarili.
- `mobile`: `flutter analyze` basarili, "No issues found".
- `backend`: `uv run pytest tests/unit_test -q` baslamadi; sebep kod hatasi degil, `.venv` permission sorunu:
  - `failed to remove file backend/.venv/.gitignore: Permission denied`

---

## 18 Mayis Oncesi En Kritik Son Dokunuslar

### 1. UI metinleri ve localization temizligi - yuksek oncelik

Mobilde bazi yerlerde dogru kelime yerine eldeki baska localization key'i kullanilmis. Bu analiz/testten gecse bile sunumda "yarim kalmis" hissi verir.

Ornekler:

- `board_detail.dart`: arama hint'i `cards + save` ile olusturulmus.
- `board_detail.dart`: board edit menu label'i `l10n.save` ile gosteriliyor.
- `planner.dart`: tekrar dene butonunda `l10n.save` kullaniliyor.
- `workspaces.dart`: silme aksiyonunda `l10n.logout.split(' ')[0]` gibi hack var.

Yapilacak:

- [ ] `app_tr.arb` ve `app_en.arb` icine net key'ler ekle:
  - `searchCards`
  - `edit`
  - `delete`
  - `retry`
  - `add`
  - `addItem`
  - `editBoard`
  - `deleteBoard`
  - `deleteList`
  - `updateFailed`
- [ ] `l10n.save` fallback olarak kullanilan yerleri temizle.
- [ ] `replaceAll(...)` ile metin uretme hack'lerini kaldir.
- [ ] Turkce/Ingizlice karisik kalan hard-coded metinleri azalt.

Benim fikrim: Sunum oncesi en cok degecek is bu. Cunku teknik olarak kucuk, etkisi buyuk.

---

### 2. Realtime/socket akisini dogrulama - yuksek oncelik

Calisma agacinda socket/realtime icin yeni degisiklikler var. Bu guzel bir sunum kozu olabilir: webde kart tasininca mobilde guncellenmesi, yorum eklenince diger client'a dusmesi gibi.

Yapilacak smoke test:

- [ ] Iki web client ac: kart olustur, tasi, guncelle, sil.
- [ ] Web + mobil ac: kart/list/yorum/checklist degisiklikleri karsi tarafa dusuyor mu bak.
- [ ] Mobil + mobil ac: ayni testleri tekrar et.
- [ ] Socket baglanti kopunca uygulama bozulmadan normal API refresh ile devam ediyor mu bak.
- [ ] Browser console ve backend loglarinda socket hata/uyari var mi kontrol et.

Kod notu:

- `backend/app/events/socket_handler.py` icinde `InvitationSentEvent` iki kez import edilmis. Zararsiz ama temizlenmeli.
- Socket event payload'lari UUID/string donusumu acisindan pratikte denenmeli.

Benim fikrim: Eger realtime stabilse sunumda mutlaka goster. Stabil degilse sunumda iddia etme; normal refresh akisi zaten yeterli.

---

### 3. Activity log yazma akisini tamamlama - yuksek oncelik

Activity ekrani ve API endpointleri var; fakat son incelemede kritik bir eksik gorundu: backend tarafinda `activity_repo.create_activity_log(...)` fonksiyonu tanimli olmasina ragmen uygulama akisinda hic cagrilmiyor.

Bu nedenle mobilde activity ekraninin bos veya eksik calismasi normal. Su an durum kabaca soyle:

- `GET /activity/board/{board_id}` var.
- `GET /activity/workspace/{workspace_id}` var.
- `GET /activity/card/{card_id}` var.
- `ActivityViewModel` bu endpointleri okuyabiliyor.
- `ActivityLog` modeli ve repository hazir.
- Ama card move, comment add, checklist toggle, card create/update/delete gibi olaylar activity tablosuna yazilmiyor.

Yapilacak:

- [ ] `handle_activity_log` benzeri bir event handler ekle.
- [ ] `EventDispatcher.initialize()` icinde activity handler'i ilgili eventlere register et.
- [ ] En azindan sunum icin su eventler log'a yazilsin:
  - Kart olusturuldu
  - Kart guncellendi
  - Kart tasindi
  - Kart silindi
  - Yorum eklendi
  - Checklist item tamamlandi/geri alindi
  - Karta kisi atandi
- [ ] Activity kaydinda `user_id`, `entity_type`, `entity_id`, `entity_name`, `board_id`, `workspace_id`, `details` alanlari dolsun.
- [ ] Card activity endpointi sadece `entity_type == card` ve `entity_id == card_id` kayitlarini degil, karta ait yorum/checklist hareketlerini de gosterecek sekilde dusunulsun.

Benim fikrim: Activity UI'ini yeniden yazmaya gerek yok. Asil eksik backend event -> activity_log baglantisi. Bu tamamlanirsa mobildeki activity ekrani cok daha anlamli hale gelir ve sunumda guzel gorunur.

---

### 4. Demo senaryosunu kilitleme - yuksek oncelik

Projede cok fazla ozellik var. Sunumda dagilmamak icin tek bir temiz hikaye lazim.

Onerilen demo akisi:

1. Login veya Google login.
2. Workspace olustur veya hazir workspace sec.
3. Board olustur.
4. Liste ve kart olustur.
5. Kartlari drag-drop ile tasi.
6. Card detail ac:
   - Aciklama
   - Due date
   - Assignee
   - Checklist
   - Yorum
   - Kapak resmi
7. Activity ekraninda yapilan islemleri goster.
8. Bildirim/davet ekranina gec.
9. Ayni datayi web ve mobilde goster.

Yapilacak:

- [ ] Demo icin temiz test kullanicilari hazirla.
- [ ] Demo datasini onceden olustur.
- [ ] Sunumda gosterilecek board/list/card isimlerini profesyonel sec.
- [ ] Calismayan veya yarim calisan butonlari demo sirasinda kullanma.

Benim fikrim: "Her seyi gosterelim" yerine "tek akisi kusursuz gosterelim" daha guclu durur.

---

### 5. Mobil takilma/performance hissi - orta/yuksek oncelik

Eski notlarda "hafif takilma var" denmis. Kodda kart uzerindeki yorum/checklist rozetleri icin cache/prefetch eklenmis; bu iyi. Yine de board ekraninda cok kart varsa performans bakilmali.

Bakilacak yerler:

- `board_detail.dart`: yatay listeler + dikey kartlar + drag-drop
- `cards_viewmodel.dart`: yorum sayisi ve checklist ilerleme cache'i
- `card_detail.dart`: detaydan geri donunce rozet refresh

Yapilacak:

- [ ] 5 liste, 30-50 kart ile mobil board ekranini dene.
- [ ] Kart tasirken frame drop belirgin mi bak.
- [ ] Board acilisinda gereksiz tum kartlari tekrar tekrar cekiyor mu kontrol et.
- [ ] Gerekirse demo board'unu makul sayida kartla tut.

Benim fikrim: Performans problemi kokten cozulmese bile demo datasini iyi ayarlamak sunum icin yeterli olabilir.

---

### 6. Backend test ortamini duzeltme - orta oncelik

Backend unit testleri calismadi; sebep `.venv` izin problemi. Bu sunumdan once cozulmeli.

Yapilacak:

- [ ] `backend/.venv` sahiplik/izin sorununu duzelt.
- [ ] Backend icin dogru Python surumunu sabitle.
- [ ] `UV_CACHE_DIR=/tmp/uv-cache uv run pytest tests/unit_test -q` veya proje standardi neyse onunla testleri calistir.
- [ ] Test sonucu README veya sunum notlarina eklenebilir.

Benim fikrim: Juri/test sorarsa "frontend build ve flutter analyze temiz, backend unit testleri de geciyor" demek guven verir.

---

## Eski Eksik Maddelerin Guncel Durumu

| # | Eski not | Guncel durum | Not |
|---|---------|--------------|-----|
| 1 | Kart aktiviteleri duzgun calismiyor | Dogru, hala eksik | Activity ekranlari ve endpointler var; fakat backend'de `create_activity_log(...)` hic cagrilmiyor. Event -> activity_log yazma handler'i eklenmeli. |
| 2 | Hafif takilma var | Devam eden risk | Buyuk board ile test edilmeli. Demo datasini makul tutmak mantikli. |
| 3 | Silinen workspace'e ait board/card kalmasi | Backend/veri modeli karari | Cascade delete isteniyorsa backend/migration konusu. Sunum oncesi buyuk riskli. |
| 4 | Davet dialog keyboard overflow | Muhtemelen fixlendi | Git gecmisinde keyboard overflow fix commit'i var. Mobil cihazda tekrar test edilmeli. |
| 5 | Hatali sifre mesaj vermiyor | Muhtemelen fixlendi | Login error handling fix commit'i var. Tekrar test edilmeli. |
| 6 | Mail yoksa signup'a yonlendirme | Muhtemelen fixlendi | Signup redirect fix commit'i var. Tekrar test edilmeli. |
| 7 | Davet mail/bildirim gitmiyor | Kontrol gerekli | Notification/invitation ve socket birlikte denenmeli. |
| 8 | Davetlerde List<dynamic> type hatasi | Muhtemelen fixlendi | Invitation type casting fix commit'i var. Tekrar test edilmeli. |
| 9 | Bildirim ayarlari calismiyor | Kontrol gerekli | Board detail'da notification settings aksiyonu var. Gercek etkisi test edilmeli. |
| 10 | Gorunum ayarlari calismiyor | Kontrol gerekli | Appearance screen var; tema/dil kaliciligi test edilmeli. |
| 11 | Dil eklenecek | Tamamlandi | Son commit: `feat(mobile): english translation was added`. |
| 12 | Kullanim kosullari/gizlilik mock metin | Dusuk oncelik | Sunumda account ekranindan acilacaksa doldurulmali. |
| 13 | Cache-first icin SQLite | Ertele | Sunum oncesi riskli. SharedPreferences recent boards icin yeterli. |
| 14 | Refresh/Stream yapisi | Kismen tamam | Pull-to-refresh ve socket/realtime calismalari var. |
| 15 | Activity constructor yapisi garip | Refactor opsiyonel | Calisiyorsa sunum oncesi buyuk refactor yapma. Sonra route argument modeli sadeleştirilebilir. |

---

## Mobilde Tamamlanan Ana Ozellikler

### Auth ve hesap

- [x] JWT login
- [x] Signup
- [x] Auto-login
- [x] Google auth
- [x] Profil goruntuleme
- [x] Profil duzenleme
- [x] Sifre degistirme
- [x] Sifre sifirlama
- [x] Hesap silme
- [x] Login hata yonetimi

### Board/list/card

- [x] Board listesi
- [x] Board olusturma
- [x] Board guncelleme/silme
- [x] Board arka plan secici
- [x] Board icinde kart arama/filtreleme
- [x] Liste olusturma
- [x] Liste guncelleme/silme
- [x] Kart CRUD
- [x] Listeler arasi drag-drop
- [x] Ayni liste icinde kart siralama
- [x] Kart detay ekrani
- [x] Due date secme/temizleme
- [x] Geciken kart uyarisi
- [x] Assignee secme/kaldirma
- [x] Kapak resmi yukleme
- [x] Checklist
- [x] Yorumlar
- [x] Kart ustunde checklist ve yorum rozetleri

### Workspace, davet, bildirim

- [x] Workspace CRUD
- [x] Workspace uye listesi
- [x] Uye rol guncelleme
- [x] Uye cikarma
- [x] Workspace'e davet gonderme
- [x] Gelen/giden davetler
- [x] Daveti kabul/reddet/iptal et
- [x] Bildirim listesi
- [x] Okunmamis bildirim sayisi
- [x] Tumunu okundu isaretleme
- [x] Bildirim silme

### Dashboard ve activity

- [x] Ana sayfa/dashboard
- [x] Workspace'e gore board gruplama
- [x] Hizli board olusturma
- [x] Son goruntulenen boardlar
- [x] Activity domain modeli
- [x] ActivityViewModel
- [x] Workspace/board/card activity ekrani
- [x] Card detail icinde activity bolumu

---

## Web ve Mobil Karsilastirmasi

| Alan | Web | Mobil | Sunum notu |
|------|-----|-------|------------|
| Auth | Var | Var | Mobilde Google auth yeni eklendi, demo oncesi OAuth config test edilmeli. |
| Board/list/card CRUD | Var | Var | Iki tarafta da ana akis gosterilebilir. |
| Drag-drop | Var | Var | Mobil drag-drop demo oncesi cihazda denenmeli. |
| Card detail | Var | Var | Mobilde due date, assignee, cover, checklist, yorum var. |
| Bildirim/davet | Var/API var | Var | Canli davet/bildirim akisi test edilmeli. |
| Activity | API/model var | UI/ViewModel var | Yazma tarafi eksik: eventler activity_log tablosuna baglanmali. |
| Realtime | Yeni ekleniyor | Yeni ekleniyor | Stabilse sunumda cok iyi etki yaratir. |
| Localization | Web daha stabil | Mobil yeni eklendi | Mobil metin polish'i gerekli. |
| Test/build | Web build geciyor | Analyze geciyor | Backend test ortami duzeltilmeli. |

---

## Ertelenmesi Daha Mantikli Isler

Sunum oncesi bu islere girilmesini onermiyorum:

- SQLite cache-first mimarisi
- Workspace silinince cascade delete davranisini degistirme
- Activity route/constructor mimarisini buyuk refactor etmek
- Profil avatar alanini backend modeliyle genisletmek
- Buyuk UI redesign
- Tum uygulama icin offline-first davranis

Bu isler degerli ama 18 Mayis oncesi risk/fayda dengesi zayif.

---

## Sunum Icin Kapanis Checklist'i

- [ ] `frontend` icin `npm run build` tekrar calistir.
- [ ] `mobile` icin `flutter analyze` tekrar calistir.
- [ ] Backend test ortamini duzeltip unit testleri calistir.
- [ ] Demo cihazinda mobil login, board, card detail, drag-drop test et.
- [ ] Web ve mobil ayni backend'e bagli mi kontrol et.
- [ ] Realtime calisiyorsa iki client ile canli dene.
- [ ] Activity icin card move/comment/checklist eventlerinin log'a dustugunu dogrula.
- [ ] Calismayan/yarim calisan butonlari demo sirasinda kullanma.
- [ ] Demo kullanicilari ve board datasi onceden hazir olsun.
- [ ] README ve handoff belgelerinde "tamamlandi" durumlarini guncelle.

---

## Codex Notu

Bence proje feature sayisi olarak sunuma yeterli. Bundan sonraki en akilli hamle "bir feature daha ekleyelim" degil, mevcut deneyimi daha guvenli ve temiz gostermek.

En yuksek etkiyi su sirayla alirsiniz:

1. Mobil localization/metin temizligi.
2. Activity log yazma handler'ini tamamlamak.
3. Realtime/socket smoke test.
4. Demo verisi ve demo akisini sabitleme.
5. Backend test ortamini duzeltme.
6. Kucuk UI polish.

Sunumda asil satilacak sey su olabilir: "Trello benzeri bir kanban sistemi; backend, web ve mobil ayni domain modeli uzerinden calisiyor; bildirim, davet, activity ve realtime senaryolariyla tam urun gibi davranıyor."
