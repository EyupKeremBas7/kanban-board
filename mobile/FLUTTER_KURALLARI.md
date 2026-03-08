# Flutter Geliştirme Kuralları — Ders Notları

> Bu dosya, Mobil Programlama dersi sırasında alınan notlardan oluşturulmuştur.  
> **Agent (AI asistan) ve geliştirici bu kurallara uymak zorundadır.**

---

## 🔴 0. CODEBASE TUTARLILIĞI (EN ÖNEMLİ KURAL)

- Geliştirme sürecinde **mevcut codebase ile tutarlı** şekilde kod yazılacak.
- Kod yazarken **acele edilmeyecek**, her adımda **mevcut codebase** kontrol edilecek.
- Süreç içersinde her adımda commitler ile sürecin ilerleyişi kaydedilecek ancak commitleri kullanıcı atıcak.
- Yeni bir pattern, paket, yapı veya mimari değişiklik eklenecekse **kullanıcı ekstra özenle bilgilendirilecek** ve onay alınacak.
- Agent (AI asistan) mevcut kodun stiline, isimlendirme kurallarına ve klasör yapısına uyacak.
- Mevcut codebase'de olmayan bir yaklaşım (yeni paket, farklı state management, farklı dosya yapısı vb.) önerilecekse **neden gerekli olduğu açıklanacak** ve kullanıcıya karar bırakılacak.

> ⚠️ **Kural:** Önce mevcut kodu oku, anla, ona uy. Değişiklik gerekiyorsa kullanıcıyı bilgilendir.

---

## 1. `const` ve `final` kullanımı

- Değişmeyecek widget'larda **`const` constructor** kullanılacak → Flutter rebuild'leri atlar, performans artar.
- Bir kez atanıp değişmeyecek değişkenlerde **`final`** kullanılacak.
- `var` sadece gerçekten değişecek değişkenlerde kullanılacak.

```dart
// ✅ Doğru
const SizedBox(height: 16);
final String userId = authService.currentUserId;

// ❌ Yanlış
SizedBox(height: 16);           // const yok
var userId = authService.currentUserId;  // değişmeyecekse final olmalı
```

---

## 2. Nullable değişkenler

- `?` operatörü bilinçli kullanılacak, gereksiz nullable yapılmayacak.
- API'den gelen nullable alanlar için **null check** veya **default değer** mutlaka verilecek.
- Fontlar ve tema değerleri **null dönebilir**, `?` ile erişilecek.

```dart
// ✅ Doğru
final String displayName = user.fullName ?? 'İsimsiz Kullanıcı';
final fontSize = Theme.of(context).textTheme.bodyMedium?.fontSize ?? 14.0;

// ❌ Yanlış
final String displayName = user.fullName;  // null gelirse patlak
```

---

## 3. Eski kütüphanelere dikkat

- `pubspec.yaml`'daki paketler güncel tutulacak.
- Deprecated API'ler kullanılmayacak.
- Paket seçerken **pub.dev puanı**, **son güncelleme tarihi** ve **null safety** desteği kontrol edilecek.

---

## 4. Asenkron işlemler (`Future`, `async/await`)

- API çağrıları ve DB işlemleri her zaman **asenkron** yapılacak.
- `FutureBuilder` veya state management ile yönetilecek.
- **Loading**, **error** ve **data** durumları ayrı ayrı handle edilecek.

```dart
// ✅ Doğru
Future<List<Board>> fetchBoards() async {
  try {
    final response = await apiService.getBoards();
    return response;
  } catch (e) {
    throw Exception('Board listesi alınamadı: $e');
  }
}

// Widget'ta:
FutureBuilder<List<Board>>(
  future: fetchBoards(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const CircularProgressIndicator();  // Loading
    }
    if (snapshot.hasError) {
      return Text('Hata: ${snapshot.error}');     // Error
    }
    final boards = snapshot.data!;
    return BoardListView(boards: boards);          // Data
  },
)
```

---

## 5. Mimari: MVVM + Dosya yapısı

Proje **MVVM (Model-View-ViewModel)** mimarisi ile geliştirilecek. State management için **Provider** (`ChangeNotifier`) kullanılacak.

| Katman | Klasör | Görevi |
|--------|--------|--------|
| **Model** | `domain/models/` + `services/` | Veri sınıfları ve API çağrıları |
| **View** | `screens/` + `widgets/` | Sadece UI, iş mantığı yok |
| **ViewModel** | `viewmodels/` | View ile Model arasında köprü, state yönetimi |

```
lib/
├── main.dart                         # App başlatma + Provider setup + routing
├── domain/
│   └── models/                       # MODEL — Veri sınıfları (Dart class'lar)
│       ├── user.dart
│       ├── workspace.dart
│       ├── board.dart
│       ├── board_list.dart
│       ├── card.dart
│       ├── checklist_item.dart
│       ├── comment.dart
│       └── notification.dart
├── services/                         # MODEL — API servisleri
│   ├── api_service.dart
│   └── auth_service.dart
├── viewmodels/                       # VIEWMODEL — State yönetimi ✨
│   ├── auth_viewmodel.dart
│   ├── boards_viewmodel.dart
│   ├── board_detail_viewmodel.dart
│   ├── card_detail_viewmodel.dart
│   ├── inbox_viewmodel.dart
│   ├── activity_viewmodel.dart
│   └── account_viewmodel.dart
├── screens/                          # VIEW — Sadece UI
│   ├── splash_screen.dart
│   ├── login_screen.dart
│   ├── signup_screen.dart
│   ├── boards_screen.dart
│   ├── board_detail_screen.dart
│   ├── card_detail_screen.dart
│   ├── inbox_screen.dart
│   ├── planner_screen.dart
│   ├── activity_screen.dart
│   └── account_screen.dart
├── widgets/                          # VIEW — Tekrar kullanılabilir widget'lar
└── utils/                            # Yardımcı fonksiyonlar, enum'lar, sabitler
```

**Kurallar:**
- `screens/` (View) **asla doğrudan** API çağırmayacak → her zaman ViewModel üzerinden
- `viewmodels/` iş mantığını ve state'i tutar → `ChangeNotifier` ile `notifyListeners()`
- `services/` API çağrılarını yapar → ViewModel tarafından çağrılır
- `main.dart` sadece app başlatma, `MultiProvider` setup ve routing içerecek

```dart
// ViewModel örneği
class BoardsViewModel extends ChangeNotifier {
  final ApiService _apiService;
  List<Board> boards = [];
  bool isLoading = false;
  String? error;

  BoardsViewModel(this._apiService);

  Future<void> fetchBoards() async {
    isLoading = true;
    notifyListeners();
    try {
      boards = await _apiService.getBoards();
      error = null;
    } catch (e) {
      error = e.toString();
    }
    isLoading = false;
    notifyListeners();
  }
}

// View — sadece UI, iş mantığı ViewModel'de
class BoardsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<BoardsViewModel>();
    if (vm.isLoading) return const CircularProgressIndicator();
    if (vm.error != null) return Text(vm.error!);
    return ListView.builder(
      itemCount: vm.boards.length,
      itemBuilder: (context, i) => BoardTile(board: vm.boards[i]),
    );
  }
}
```

---

## 6. Navigator ve veri taşıma

Navigator ile sayfa geçişlerinde veri, hedef widget'ın **constructor'ına** parametre olarak yollanır:

```dart
// Sayfa tanımı — constructor ile veri alır
class BoardDetailScreen extends StatelessWidget {
  final String boardId;  // Büyük veri değil, sadece ID!
  const BoardDetailScreen({super.key, required this.boardId});

  @override
  Widget build(BuildContext context) { ... }
}

// Navigasyon — constructor'a ID yollanır
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => BoardDetailScreen(boardId: board.id),
  ),
);
```

> ⚠️ **Önemli:** Pop/push ile **büyük veri taşınmayacak**. Veri büyükse sadece **ID** taşınıp hedef sayfada API'den çekilecek.

> ⚠️ **Type Safety:** Navigator varsayılan olarak type-safe değil. `go_router` paketi kullanılarak type-safe routing sağlanabilir.

---

## 7. Responsive tasarım — Overflow önleme

Sarı-siyah şerit (bottom overflow) hataları önlenecek:

- **`Expanded`** ve **`Flexible`** doğru kullanılacak.
- **`MediaQuery`** ile ekran boyutuna göre layout:

```dart
final screenWidth = MediaQuery.of(context).size.width;
final isTablet = screenWidth > 600;
```

- **`LayoutBuilder`** ile parent constraint'e göre widget boyutlandırma:

```dart
LayoutBuilder(
  builder: (context, constraints) {
    if (constraints.maxWidth > 600) {
      return WideLayout();
    }
    return NarrowLayout();
  },
)
```

---

## 8. ListView türleri

| Tür | Ne zaman | Örnek |
|-----|----------|-------|
| `ListView(children: [...])` | **Az sayıda** sabit öğe | Ayarlar menüsü (5-6 öğe) |
| `ListView.builder()` | **Çok sayıda** dinamik öğe | Kart listesi, yorum listesi |
| `ListView.separated()` | Builder + **ayırıcı (divider)** | Settings ekranları, listeleme + çizgi |

```dart
// ✅ Çok eleman → builder (sadece ekranda görünenler derlenir)
ListView.builder(
  itemCount: cards.length,
  itemBuilder: (context, index) => CardTile(card: cards[index]),
)

// ✅ Ayırıcılı liste → separated
ListView.separated(
  itemCount: settings.length,
  itemBuilder: (context, index) => SettingsTile(setting: settings[index]),
  separatorBuilder: (context, index) => const Divider(),
)
```

---

## 9. `.clamp()` ile sınır kontrolü

Kapasite/kontenjan gibi sınırlı değerlerde:

```dart
int currentCount = fetchedCount.clamp(0, maxCapacity);
double progress = (completed / total).clamp(0.0, 1.0);
```

---

## 10. Metin taşması — `TextOverflow.ellipsis`

Uzun metinler `...` ile kesilecek, layout bozulmayacak:

```dart
Text(
  card.title,
  overflow: TextOverflow.ellipsis,
  maxLines: 2,
)
```

---

## 11. Kaydırılabilir içerik — `SingleChildScrollView`

Form ekranları ve uzun içerikler kaydırılabilir olacak:

```dart
SingleChildScrollView(
  child: Column(
    children: [
      // Form alanları, uzun içerik...
    ],
  ),
)
```

---

## 12. Tema yönetimi — `.copyWith()`

Bir widget'ta farklı tema uygulanacaksa mevcut tema **kopyalanıp** üstüne yazılacak:

```dart
// ✅ Doğru — tema korunur, sadece renk değişir
Theme.of(context).textTheme.bodyMedium?.copyWith(
  color: Colors.red,
  fontWeight: FontWeight.bold,
)

// ❌ Yanlış — temayı tamamen bozar
const TextStyle(color: Colors.red, fontSize: 14)
```

Hazır temaların renkleri **gereksiz yere değiştirilmeyecek**.

---

## 13. Animasyonlar — `AlwaysStoppedAnimation`

Progress bar, loading gibi animasyonlu widget'larda:

```dart
CircularProgressIndicator(
  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
)
```

---

## 14. Stateful vs Stateless

| Widget Türü | Ne zaman |
|-------------|----------|
| `StatelessWidget` | Sabit UI, değişmeyen içerik |
| `StatefulWidget` | API'den veri çekme, form input, toggle gibi **değişen** state |

> ❌ Her şeyi StatefulWidget yapmak yanlış — sadece state değişen widget'lar Stateful olacak.

---

## 15. SnackBar ile bilgilendirme

Kullanıcıya geri bildirim **SnackBar** ile verilecek — ne az ne fazla:

```dart
ScaffoldMessenger.of(context).showSnackBar(
  const SnackBar(content: Text('Kart başarıyla oluşturuldu')),
);
```

---

## 16. Debug ve Hot Reload

- Agent (AI asistan) emin olmadığı durumlarda **kullanıcıdan debug sonuçlarını isteyecek**.
- Hot reload/restart sonuçları kullanıcı tarafından onaylanacak.
- Agent kendi başına varsayımla ilerlemeyecek, sorunlu durumlarda kullanıcıya danışacak.

---

## 17. Bool flag'ler ile kontrol

Durum kontrolleri için bool flag'ler kullanılacak:

```dart
bool isLoading = false;
bool isFormValid = false;
bool hasError = false;
```

---

## 18. Magic number'lardan kaçın — Enum kullan

Sabit değerler için magic number yerine enum veya sabit tanımları kullanılacak:

```dart
// ❌ Yanlış — magic number
if (role == 1) { ... }

// ✅ Doğru — enum
enum MemberRole { admin, member, observer }
if (role == MemberRole.admin) { ... }
```

---

## 19. Navigasyon — `go_router`

- `go_router` paketi kullanılabilir (type-safe routing).
- **BottomNavigationBar** mevcut yapıda kullanılıyor, öyle devam edilecek.

---

## 20. Özet Checklist

Kod yazarken/review ederken kontrol listesi:

- [ ] `const` kullanılabilecek widget'larda `const` var mı?
- [ ] `final` kullanılabilecek değişkenlerde `final` var mı?
- [ ] Nullable alanlar için null check veya default değer var mı?
- [ ] API çağrıları `async/await` ile mi yapılıyor?
- [ ] Loading/error/data durumları handle ediliyor mu?
- [ ] `ListView.builder` mı yoksa `children` mı — doğru tür mü?
- [ ] Uzun metinlerde `TextOverflow.ellipsis` var mı?
- [ ] Overflow hatası olabilecek yerlerde `Expanded`/`Flexible` var mı?
- [ ] Navigator ile büyük veri değil ID mi taşınıyor?
- [ ] Magic number yerine enum/constant mı kullanılıyor?
- [ ] Tema değişikliği `.copyWith()` ile mi yapılıyor?
- [ ] Gereksiz StatefulWidget var mı?
