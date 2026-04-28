# Flutter Geliştirme Kuralları — Kanban Board

> Bu dosya, Kanban Board (Mobil) projesinin geliştirme standartlarını ve kurallarını içerir.
> **Agent (AI asistan) ve geliştirici istisnasız olarak bu kurallara uymak zorundadır.**

---

## 🏗️ A. Temel İlkeler ve Güvenlik
1. **Codebase Tutarlılığı:** Mevcut kod stiline, isimlendirme kurallarına ve klasör yapısına harfiyen uyulacak. 
2. **Infrastructure Kilidi:** Kullanıcı izni olmadan environment, docker, port veya veritabanı (silme/değiştirme) ayarları KESİNLİKLE değiştirilmeyecek.
3. **Immutable Stack:** Kullanıcı onayı alınmadan `pubspec.yaml` dosyasına asla yeni bir paket eklenmeyecek.
4. **Kesinlikle Düşürmeme (Never Downgrade):** Herhangi bir hatayı çözmek için asla mevcut bir özellik silinmeyecek, gereksinimler esnetilip düşürülmeyecek ve sistem (veya LLM versiyonu) izinsiz küçültülmeyecek.

## 🏛 B. Mimari Tasarım
5. **Mimari Seçimi:** Proje, **Feature-Based MVVM** ve **Clean Architecture** (Presentation, Domain, Data, Core) katman kombinasyonuna sadık kalınarak geliştirilecek.
6. **Domain İzolasyonu:** Domain katmanı tamamen saf Dart (*pure Dart*) kodlarından oluşacak, `package:flutter/...` içeren hiçbir UI bağımlılığı import edilmeyecek.
7. **Repository Deseni:** UI tarafını yöneten `ViewModel` modülleri, veritabanına veya API'ye (Data katmanı) doğrudan istek atmayacak; sadece `abstract Repository` arayüzleri (interfaces) üzerinden veri isteyecek.
8. **Offline-First Stratejisi:** Veriler öncelikle yerel veritabanından / önbellekten (SQLite / Cache) okunacak, ardından arka planda uzak sunucudan (API / Firebase) güncellenerek yenilenecek.
9. **Pagination:** Büyük listeleri içeren veri kümeleri hiçbir zaman tek seferde çekilmeyecek. Her zaman offset/limit mantığı ve Sonsuz Kaydırma (*Infinite Scroll*) mantığı kullanılarak parça parça çekilecek.
10. **Asenkron Yapı:** Auth işlemleri ve uzak sunucu/veritabanı işlemleri (örn. Google Auth, REST/Firestore) sadece `async/await` pattern ile işlenecek. Bu işlemlerin durumları (`isLoading`, `error`) tümüyle `ViewModel` tarafında kontrol edilip UI'a bildirilecek.

## 🎨 C. UI / Tema Seçimi ve Tasarım
11. **Global Widget Önceliği:** UI geliştirirken tekerleği yeniden icat etme. Öncelikle `lib/widget` veya `lib/core/widgets` klasörlerindeki mevcut base bileşenleri (appbar, button, textfield) kullanmaya çalış. Sistemin karşılamadığı özel bir widget'a kesinlikle ihtiyaç duyarsan, bu bileşeni o anki spesifik sayfanın içine gömmek yerine, herkesin kullanabileceği modüler ve global bir yapı olarak oluştur ve Widget klasörüne (*global*) ekle.
12. **Tasarım Sabitleri:** UI içerisindeki renk paleti, font, margin/padding ve radius değerleri asla *hardcoded* (sabit yazılarak) dosya içine girilmeyecek. KESİNLİKLE sadece `lib/constant` klasörü altındaki tema dosyalarından çekilerek kullanılacak.
13. **İkon Standartları:** Projenin ikonografik bütünlüğünü korumak için sadece `flutter_tabler_icons` paketi kullanılacak, farklı ikon setleri karıştırılmayacak.

## ⚙️ D. UX ve Stabilite
14. **Responsive Layout:** Göz kanatan sarı-siyah ekran taşma (*overflow*) hatalarından kaçınmak için; `Expanded`, `Flexible`, `LayoutBuilder`, `SingleChildScrollView` ve `MediaQuery` bileşenleri aktif bir şekilde kullanılacak. Kullanıcı cihazının dar veya geniş ekranlı olması her zaman hesaplanacak.
15. **Optimizasyon ve Performans:** Ekranda değişiklik göstermeyecek statik widget'lar `const` keyword'ü eklenerek, tek bir sefer değer alıp değişmeyecek değişkenler ise `final` ile tanımlanarak memory-leak / rebuild kayıplarından tasarruf edilecek.
16. **Null Safety ve Çökme Kontrolü:** Sunucudan (API'den) dönen verilerin içeriğinde daima null ihtimali gözetilecek. `?` ile nullable tanım yapılacak ve `??` (*fallback*) operatörü kullanılarak varsayılan değerler verilecek. Force unwrap işlemi (`!`) uygulamayı çökertebileceği için kullanılmaktan şiddetle kaçınılacak.
17. **Dinamik Liste Yönetimi:** Birden fazla verinin döngü ile ekrana yansıtılacağı çoklu veri (liste, grid vb) durumlarında; RAM tasarrufu sağlamak için sadece ekrandaki kısımları render eden `ListView.builder` veya `ListView.separated` metodları kullanılacak.
18. **Güvenli Navigasyon (Routing):** Sayfalar arası geçişlerde (`push` veya `pop`) modelin devasa objeleri doğrudan bir sonrakine parametre olarak geçilmeyecek (belleği şişirmemek adına) sadece objenin/ürünün `ID`'si taşınacak. Gittiği sayfada o id ile State / Cache üzerinden veri tekrar okunacak.
19. **Limit ve Taşma Kontrolü:** Sayısal veya matematiksel kapasite sınırlamalarında her zaman `.clamp()` metodu, uzun metinlerin ekrana sığmaması durumlarında ise estetiği bozmamak adına `TextOverflow.ellipsis` (`...` ile kesme) kullanılacak.
20. **Magic Number Yasakları:** Kod akışı veya logic içinde anlık sayılar veya anlamsız textler ('magic string') (`role == 1`, `status == "pending"`) kullanılmayacak. Tüm mantıksal ayrımlar ve sabit tipler için `Enum` veya global constant objeler tercih edilecek.

---
> *Tarih: Nisan 2026 itibariyle geçerlidir.*
