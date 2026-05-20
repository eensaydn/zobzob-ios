# ZoB ZoB 🍊

12. sınıf matematik · YKS hazırlık · öğretmen–öğrenci akıllı sınıf takibi.

Native iOS app — SwiftUI, Swift Charts, iOS 17+. AYT 2026 müfredatına göre konular, günlük hap bilgi, motivasyon sözleri, gerçek psikometrik analiz (kalibrasyon, ayırt edicilik), ısı haritası, sıralama, rozet sistemi.

---

## Özellikler

### Öğrenci tarafı
- **Bugün** — selamlama, ilerleme halkası, günün ilhamı (motivasyon peek), günün konusu, günün hap bilgisi (formül), bekleyen görevler.
- **Ödevler** — atanmış testler, segmented filtre (tümü/yapılacak/tamamlanan).
- **Motivasyon** ✨ — günlük dönen söz (47 alıntı; matematikçiler, Türk düşünürleri, azim, zihniyet, bilgelik).
- **Sıralama** — podium (🥇🥈🥉) + tam liste, sezgi/streak/doğru cevap sayıları.
- **Profilim** — seviye, XP, doğru cevap, **Sezgi** (öz-değerlendirme), ilerleme sparkline'ı, 9 rozet, konu profili bar'ları.
- **Test çözme** — A–E 5 şıklı sorular, güven seçimi (eminim / kararsızım / tahmin), zaman ölçümü, %70+ skorda konfeti 🎉.
- **Konular kütüphanesi** — 9 konu × 60+ formül kartı; arama, modal detay (formül + püf noktası + örnek).

### Öğretmen tarafı
- **Panel** — 4 KPI (sınıf ort., teslim, sezgi, katılım) ile son 7g/önceki 7g delta. Otomatik **uyarılar** (geçmiş ödevler, zayıf konu, zorlanan öğrenci). **Destek gereken** + **yükseliyor** öğrenci grupları.
- **Testler** — oluştur/düzenle/sil (Form ile). A–E şıklı, zorluk seçimi, alt-konu etiketi, son tarih.
- **Sınıf** — öğrenci ara, sırala, sil. Tıkla → detay.
- **Program** — haftalık konu planı düzenleyici.
- **Analiz** — Swift Charts grafikler:
  - Sınıf yörüngesi (line + area)
  - Teslim hızı (bar)
  - Konu bazlı başarı
  - Güven sezgisi (calibration scatter + ECE)
  - Zorluk vs gerçek başarı (scatter; verdiğin zorluk etiketi tutturuyor mu?)
  - Öğrenci × Konu ısı haritası
  - Soru bazlı analiz: discrimination index (DI), güven dağılımı, tıkla → detay sheet.

### Diğer
- **Şirin mascot** (göz kırpan ZoB) — Welcome ekranı.
- **AYT 2026 müfredatı** — Türev, İntegral, Limit & Süreklilik, Trigonometri, Üstel & Logaritma, Diziler, Polinomlar, Karmaşık Sayılar, Olasılık & Sayma, Fonksiyonlar, Analitik Geometri, Geometri.
- **Yerli & offline** — tüm veri cihazda (`Documents/zobzob-state.json`).
- Türkçe locale (`tr_TR`), açık turuncu palet, dark mode safe.

---

## Mimari

```
Sources/Sinav/
├── SinavApp.swift              # @main + ContentView (rol router)
├── Models/Models.swift         # Codable: Topic, Student, Test, Question, Submission, …
├── Theme/Theme.swift           # Renkler, font, haptics, tarih helper'ları
├── Data/
│   ├── Pills.swift             # 60+ formül bankası (konuya göre)
│   ├── Motivation.swift        # 47 motivasyon alıntısı
│   └── SampleData.swift        # 30 günlük sentetik teslimler (seeded RNG)
├── Store/
│   ├── AppStore.swift          # @Observable, JSON dosya kalıcılık
│   └── Analytics.swift         # KPI, kalibrasyon, DI, outlier, heatmap
├── Components/
│   ├── Components.swift        # Avatar, BadgePill, StatCard, ProgressRing, Sparkline, …
│   ├── Charts.swift            # Swift Charts components (line, bar, scatter, heatmap)
│   └── Mascot.swift            # ZobMascot + sparkles + confetti
├── Welcome/WelcomeView.swift
├── Student/                    # 7 view (Bugün, Ödevler, Library, Sıralama, Profilim, TakeTest, Result, Motivation)
└── Teacher/                    # 8 view (Panel, Tests, Editor, Detail, Class, StudentDetail, Program, Insights)
```

---

## Kurulum

Gereksinimler: Xcode 16+, iOS 17+ SDK, [xcodegen](https://github.com/yonaskolb/XcodeGen).

```bash
# 1. xcodegen ile .xcodeproj üret
brew install xcodegen   # ilk kez
cd ZoB-ZoB
xcodegen

# 2. simulator'a build
xcodebuild -project Sinav.xcodeproj -scheme Sinav \
  -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  -derivedDataPath build \
  CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO build

# 3. simulator'a yükle + çalıştır
xcrun simctl install booted build/Build/Products/Debug-iphonesimulator/Sinav.app
xcrun simctl launch booted com.zobzob.app
```

Veya `Sinav.xcodeproj`'i Xcode'da açıp ⌘R.

**Öğretmen demo PIN:** `1234`

---

## Yol haritası

- [ ] Spaced repetition: yanlış cevaplanan soruları 1g/3g/7g/16g sonra otomatik tekrar listesine ekle.
- [ ] CloudKit sync — birden fazla cihaz arası.
- [ ] Push notifications — yeni ödev / yaklaşan deadline.
- [ ] iPad layout (split view).
- [ ] App Store ikon seti (tüm boyutlar).
- [ ] TestFlight dağıtımı.

---

## Lisans

Henüz belirsiz. Şahsi proje.
