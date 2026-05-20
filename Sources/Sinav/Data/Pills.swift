import Foundation

enum PillBank {
    static let all: [Pill] = [
        // MARK: Türev
        Pill(id: "p001", topic: .turev, title: "Kuvvet Kuralı", formula: "(xⁿ)′ = n·xⁿ⁻¹", note: "Üssü öne al, üssü 1 azalt.", example: "f(x)=x⁵ ⇒ f′(x)=5x⁴"),
        Pill(id: "p002", topic: .turev, title: "Sinüsün Türevi", formula: "(sin x)′ = cos x", note: "Sinüs gider, kosinüs gelir.", example: "(sin 2x)′ = 2·cos 2x"),
        Pill(id: "p003", topic: .turev, title: "Kosinüsün Türevi", formula: "(cos x)′ = −sin x", note: "Kosinüs türev alınca işaret değişir.", example: "(cos 3x)′ = −3·sin 3x"),
        Pill(id: "p004", topic: .turev, title: "e^x Sabit Kalır", formula: "(eˣ)′ = eˣ", note: "Üstel fonksiyonun türevi kendisi.", example: "(e^(2x))′ = 2·e^(2x)"),
        Pill(id: "p005", topic: .turev, title: "ln x", formula: "(ln x)′ = 1/x", note: "Doğal logaritmanın türevi 1/x.", example: "(ln x²)′ = 2/x"),
        Pill(id: "p006", topic: .turev, title: "Çarpım Kuralı", formula: "(u·v)′ = u′v + uv′", note: "İki fonksiyonun çarpımının türevi.", example: "(x·sin x)′ = sin x + x·cos x"),
        Pill(id: "p007", topic: .turev, title: "Bölüm Kuralı", formula: "(u/v)′ = (u′v − uv′)/v²", note: "Pay türev × payda − pay × payda türevi, hepsi payda kareye.", example: "(x/(x+1))′ = 1/(x+1)²"),
        Pill(id: "p008", topic: .turev, title: "Zincir Kuralı", formula: "(f(g(x)))′ = f′(g(x))·g′(x)", note: "Dıştaki türev × içtekinin türevi.", example: "((2x+1)⁵)′ = 5(2x+1)⁴·2"),
        Pill(id: "p009", topic: .turev, title: "tan x Türevi", formula: "(tan x)′ = sec²x = 1/cos²x", note: "Tanjantın türevi sekant kare.", example: "(tan 2x)′ = 2/cos²(2x)"),
        Pill(id: "p010", topic: .turev, title: "aˣ Türevi", formula: "(aˣ)′ = aˣ·ln a", note: "Tabanı e olmayan üstelin türevi.", example: "(2ˣ)′ = 2ˣ·ln 2"),
        Pill(id: "p011", topic: .turev, title: "Kritik Nokta", formula: "f′(x) = 0", note: "f′(x)=0 olan noktalar maks/min adayıdır.", example: "f(x)=x²−4x ⇒ f′=2x−4=0 ⇒ x=2"),
        Pill(id: "p012", topic: .turev, title: "Teğet Eğimi", formula: "m = f′(x₀)", note: "Bir noktadaki türev, teğetin eğimidir.", example: "y=x² eğrisinde x=1'de eğim=2"),

        // MARK: İntegral
        Pill(id: "p101", topic: .integral, title: "Kuvvet İntegrali", formula: "∫xⁿ dx = xⁿ⁺¹/(n+1) + C", note: "n ≠ −1. Üssü 1 artır, yeni üsse böl.", example: "∫x³ dx = x⁴/4 + C"),
        Pill(id: "p102", topic: .integral, title: "1/x İntegrali", formula: "∫(1/x) dx = ln|x| + C", note: "Mutlak değeri unutma!", example: "∫(2/x) dx = 2·ln|x| + C"),
        Pill(id: "p103", topic: .integral, title: "Üstel İntegral", formula: "∫eˣ dx = eˣ + C", note: "En kolay integral.", example: "∫e^(3x) dx = e^(3x)/3 + C"),
        Pill(id: "p104", topic: .integral, title: "Sinüs İntegrali", formula: "∫sin x dx = −cos x + C", note: "Türevin tersi: sin gider, −cos gelir.", example: "∫sin 2x dx = −cos 2x/2 + C"),
        Pill(id: "p105", topic: .integral, title: "Kosinüs İntegrali", formula: "∫cos x dx = sin x + C", note: "cos x → sin x.", example: "∫cos 5x dx = sin 5x/5 + C"),
        Pill(id: "p106", topic: .integral, title: "Kısmi İntegral", formula: "∫u dv = uv − ∫v du", note: "Çarpım ifadeleri için. LIATE kuralı.", example: "∫x·eˣ dx = x·eˣ − eˣ + C"),
        Pill(id: "p107", topic: .integral, title: "Yerine Koyma", formula: "u = g(x) ⇒ du = g′(x)dx", note: "İçinde iç fonksiyon × iç türevi varsa yerine koy.", example: "∫2x(x²+1)⁵ dx ⇒ u⁶/6+C"),
        Pill(id: "p108", topic: .integral, title: "Belirli İntegral", formula: "∫ₐᵇ f(x) dx = F(b) − F(a)", note: "Eğri altındaki alan.", example: "∫₀² x dx = 2"),
        Pill(id: "p109", topic: .integral, title: "İki Eğri Arası", formula: "A = ∫ₐᵇ |f(x) − g(x)| dx", note: "İki fonksiyon arasındaki alan.", example: "y=x ve y=x² arası: 1/6"),
        Pill(id: "p110", topic: .integral, title: "Dönel Cisim", formula: "V = π∫ₐᵇ [f(x)]² dx", note: "Disk yöntemi: x ekseni etrafında.", example: "y=√x, [0,4] için V = 8π"),
        Pill(id: "p111", topic: .integral, title: "sec²x İntegrali", formula: "∫sec²x dx = tan x + C", note: "Tanjantın türevinin tersi.", example: "∫(1/cos²x) dx = tan x + C"),

        // MARK: Limit
        Pill(id: "p201", topic: .limit, title: "Sinüs Limiti", formula: "lim_(x→0) sin x/x = 1", note: "En bilinen standart limit.", example: "lim_(x→0) sin 3x/x = 3"),
        Pill(id: "p202", topic: .limit, title: "1−cos x", formula: "lim_(x→0) (1−cos x)/x² = 1/2", note: "Belirsizliği giderme.", example: "lim (1−cos 2x)/x² = 2"),
        Pill(id: "p203", topic: .limit, title: "e Sayısı", formula: "lim_(x→∞) (1 + 1/x)ˣ = e", note: "Doğal logaritmanın tabanı.", example: "lim (1 + 2/x)ˣ = e²"),
        Pill(id: "p204", topic: .limit, title: "L'Hôpital", formula: "0/0 veya ∞/∞ ⇒ türev al", note: "Belirsizlikte pay/payda türevi.", example: "lim sin x/x = cos x/1 = 1"),
        Pill(id: "p205", topic: .limit, title: "Süreklilik", formula: "lim_(x→a) f(x) = f(a)", note: "Limit = fonksiyon değeri olmalı.", example: "f(x)=|x| sürekli, x=0'da türevsiz"),
        Pill(id: "p206", topic: .limit, title: "Sonsuzda Oran", formula: "Derece karşılaştır", note: "Pay > payda ⇒ ∞; küçük ⇒ 0; eşit ⇒ katsayı oranı.", example: "lim (3x²+1)/(x²−x) = 3"),

        // MARK: Trigonometri
        Pill(id: "p301", topic: .trigonometri, title: "Temel Özdeşlik", formula: "sin²x + cos²x = 1", note: "Trigonometrinin temel taşı.", example: "sin²30°+cos²30° = 1/4+3/4 = 1"),
        Pill(id: "p302", topic: .trigonometri, title: "Tanjant Özdeşliği", formula: "1 + tan²x = sec²x", note: "Temel özdeşliğin tan/cos hâli.", example: "x=45° ⇒ 1+1 = 2 = sec²45°"),
        Pill(id: "p303", topic: .trigonometri, title: "İki Kat Açı (Sin)", formula: "sin 2x = 2·sin x·cos x", note: "Açıyı iki katlama.", example: "sin 60° = 2·sin30°·cos30°"),
        Pill(id: "p304", topic: .trigonometri, title: "İki Kat Açı (Cos)", formula: "cos 2x = cos²x − sin²x", note: "Üç eşdeğer yazılış vardır.", example: "= 1 − 2sin²x = 2cos²x − 1"),
        Pill(id: "p305", topic: .trigonometri, title: "Toplam (Sin)", formula: "sin(a+b) = sin a cos b + cos a sin b", note: "İki açı toplamının sinüsü.", example: "sin 75° = (√6+√2)/4"),
        Pill(id: "p306", topic: .trigonometri, title: "Toplam (Cos)", formula: "cos(a+b) = cos a cos b − sin a sin b", note: "Çarpımları çıkar.", example: "cos 75° = (√6−√2)/4"),
        Pill(id: "p307", topic: .trigonometri, title: "Sinüs Teoremi", formula: "a/sinA = b/sinB = c/sinC = 2R", note: "Üçgende kenar-açı ilişkisi.", example: "R = çevrel çemberin yarıçapı"),
        Pill(id: "p308", topic: .trigonometri, title: "Kosinüs Teoremi", formula: "c² = a² + b² − 2ab·cos C", note: "Genelleştirilmiş Pisagor.", example: "C=90° ⇒ a²+b²=c²"),

        // MARK: Logaritma
        Pill(id: "p401", topic: .logaritma, title: "Çarpım", formula: "log(a·b) = log a + log b", note: "Çarpım toplama dönüşür.", example: "log 6 = log 2 + log 3"),
        Pill(id: "p402", topic: .logaritma, title: "Bölüm", formula: "log(a/b) = log a − log b", note: "Bölme çıkarmaya dönüşür.", example: "log(100/4) = 2 − log 4"),
        Pill(id: "p403", topic: .logaritma, title: "Üs", formula: "log(aⁿ) = n·log a", note: "Üs çarpan olarak öne çıkar.", example: "log 8 = 3·log 2"),
        Pill(id: "p404", topic: .logaritma, title: "Taban Değiştirme", formula: "log_a b = ln b/ln a", note: "Tabanı doğal log'a çevir.", example: "log₂ 8 = ln 8/ln 2 = 3"),
        Pill(id: "p405", topic: .logaritma, title: "Üs Çarpımı", formula: "aᵐ · aⁿ = aᵐ⁺ⁿ", note: "Aynı tabanda üsler toplanır.", example: "2³·2² = 2⁵ = 32"),
        Pill(id: "p406", topic: .logaritma, title: "Üssün Üssü", formula: "(aᵐ)ⁿ = aᵐⁿ", note: "Üslerin çarpımı.", example: "(2³)² = 2⁶ = 64"),

        // MARK: Polinomlar — 2026 müfredatı, ünite 2 (özdeşlikler + çarpanlar)
        Pill(id: "p501", topic: .polinomlar, title: "Kare Açılım", formula: "(a+b)² = a² + 2ab + b²", note: "Klasik. Eksili olunca −2ab.", example: "(x+3)² = x²+6x+9"),
        Pill(id: "p502", topic: .polinomlar, title: "İki Kare Farkı", formula: "a² − b² = (a−b)(a+b)", note: "En kullanışlı çarpanlara ayırma.", example: "x²−9 = (x−3)(x+3)"),
        Pill(id: "p503", topic: .polinomlar, title: "Küp Açılım", formula: "(a+b)³ = a³+3a²b+3ab²+b³", note: "Pascal: 1-3-3-1.", example: "(x+1)³ = x³+3x²+3x+1"),
        Pill(id: "p504", topic: .polinomlar, title: "Küp Toplamı", formula: "a³+b³ = (a+b)(a²−ab+b²)", note: "İki küpün toplamı çarpanları.", example: "x³+8 = (x+2)(x²−2x+4)"),
        Pill(id: "p505", topic: .polinomlar, title: "Diskriminant", formula: "Δ = b² − 4ac", note: "Δ>0 iki, Δ=0 bir, Δ<0 yok.", example: "x²−5x+6 ⇒ Δ=1 ⇒ 2 kök"),
        Pill(id: "p506", topic: .polinomlar, title: "Kalan Teoremi", formula: "P(x) ÷ (x−a) ⇒ kalan = P(a)", note: "Hızlı kalan bulma.", example: "P(x)=x²+3x, (x−2) ⇒ kalan=10"),
        Pill(id: "p507", topic: .polinomlar, title: "Çarpan Teoremi", formula: "P(a)=0 ⇒ (x−a) çarpan", note: "Kök = çarpan ipucu.", example: "P(1)=0 ⇒ (x−1) bölüyor"),
        Pill(id: "p508", topic: .polinomlar, title: "Köklerin Toplamı (Vieta)", formula: "x₁+x₂ = −b/a, x₁·x₂ = c/a", note: "ax²+bx+c'nin köklerinin ilişkisi.", example: "x²−7x+10 ⇒ toplam 7, çarpım 10"),

        // MARK: Diziler — 2026 müfredatı, ünite 4
        Pill(id: "p550", topic: .diziler, title: "Aritmetik Dizi", formula: "aₙ = a₁ + (n−1)·d", note: "Her terim öncekine sabit d ekler.", example: "3,7,11,… ⇒ d=4, a₅=19"),
        Pill(id: "p551", topic: .diziler, title: "Aritmetik Seri Toplamı", formula: "Sₙ = n·(a₁+aₙ)/2", note: "İlk+son'un yarısı × terim sayısı.", example: "1+2+…+100 = 5050"),
        Pill(id: "p552", topic: .diziler, title: "Geometrik Dizi", formula: "aₙ = a₁·rⁿ⁻¹", note: "Her terim önceki ile sabit r çarpılır.", example: "2,6,18,… ⇒ r=3, a₄=54"),
        Pill(id: "p553", topic: .diziler, title: "Geometrik Seri Toplamı", formula: "Sₙ = a₁·(rⁿ−1)/(r−1)", note: "r≠1. |r|<1 ⇒ sonsuz toplam = a₁/(1−r).", example: "1+½+¼+… = 2"),
        Pill(id: "p554", topic: .diziler, title: "Fibonacci", formula: "aₙ = aₙ₋₁ + aₙ₋₂", note: "İki önceki terimin toplamı: 1,1,2,3,5,8,…", example: "a₇ = 13"),
        Pill(id: "p555", topic: .diziler, title: "Genel Terim", formula: "aₙ = f(n)", note: "Diziyi tek bir fonksiyonla yaz.", example: "aₙ = 2n−1 ⇒ 1,3,5,7,…"),

        // MARK: Karmaşık Sayılar — 2026 müfredatı (11. sınıf devamı, AYT'de)
        Pill(id: "p580", topic: .karmasik, title: "Sanal Birim", formula: "i² = −1", note: "i = √(−1). Tüm karmaşık sayıların temeli.", example: "i³ = −i, i⁴ = 1"),
        Pill(id: "p581", topic: .karmasik, title: "Standart Form", formula: "z = a + b·i", note: "a: gerçek, b: sanal kısım.", example: "z=3+4i ⇒ Re=3, Im=4"),
        Pill(id: "p582", topic: .karmasik, title: "Eşleniği", formula: "z̄ = a − b·i", note: "Sanal kısmın işareti döner.", example: "z=2+5i ⇒ z̄=2−5i"),
        Pill(id: "p583", topic: .karmasik, title: "Modül", formula: "|z| = √(a² + b²)", note: "z'nin orijine uzaklığı.", example: "|3+4i| = 5"),
        Pill(id: "p584", topic: .karmasik, title: "Çarpma", formula: "(a+bi)(c+di) = (ac−bd) + (ad+bc)i", note: "i²=−1 hatırla.", example: "(1+i)(2−i) = 3+i"),
        Pill(id: "p585", topic: .karmasik, title: "Bölme", formula: "z₁/z₂ = z₁·z̄₂ / |z₂|²", note: "Payda reel olsun diye eşlenikle çarp.", example: "(1+i)/(1−i) = i"),
        Pill(id: "p586", topic: .karmasik, title: "Kutupsal Form", formula: "z = r·(cos θ + i·sin θ)", note: "r=|z|, θ=arg(z).", example: "1+i = √2·(cos45° + i·sin45°)"),

        // MARK: Analitik Geometri — 2026 müfredatı, ünite 6 (dönüşümler) + 13 (çember)
        Pill(id: "p610", topic: .analitik, title: "İki Nokta Arası", formula: "d = √((x₂−x₁)² + (y₂−y₁)²)", note: "Pisagor'un düzlemde hâli.", example: "A(1,2), B(4,6) ⇒ d=5"),
        Pill(id: "p611", topic: .analitik, title: "Doğru Eğimi", formula: "m = (y₂−y₁)/(x₂−x₁)", note: "Aynı x ise eğim tanımsız (dikey).", example: "A(1,3), B(4,9) ⇒ m=2"),
        Pill(id: "p612", topic: .analitik, title: "Doğru Denklemi", formula: "y − y₁ = m·(x − x₁)", note: "Bir nokta + eğim.", example: "m=2, P(1,3) ⇒ y=2x+1"),
        Pill(id: "p613", topic: .analitik, title: "Çember Denklemi", formula: "(x−a)² + (y−b)² = r²", note: "Merkez (a,b), yarıçap r.", example: "x²+y²=25 ⇒ (0,0), r=5"),
        Pill(id: "p614", topic: .analitik, title: "Paralellik / Diklik", formula: "Paralel: m₁=m₂   Dik: m₁·m₂=−1", note: "İki doğrunun ilişkisi eğimden.", example: "m=2 ile dik olan: m'=−½"),
        Pill(id: "p615", topic: .analitik, title: "Orta Nokta", formula: "M = ((x₁+x₂)/2, (y₁+y₂)/2)", note: "Doğru parçasının ortası.", example: "A(2,3), B(6,7) ⇒ M=(4,5)"),
        Pill(id: "p616", topic: .analitik, title: "Öteleme", formula: "(x,y) → (x+h, y+k)", note: "h, k kadar kaydırma.", example: "(1,2) → 3 sağ 2 yukarı ⇒ (4,4)"),
        Pill(id: "p617", topic: .analitik, title: "Yansıma", formula: "x ekseninde: (x, −y)", note: "Eksene göre simetri.", example: "(3,5) → (3,−5)"),

        // MARK: Geometri
        Pill(id: "p601", topic: .geometri, title: "Pisagor", formula: "a² + b² = c²", note: "Dik üçgende.", example: "3-4-5 üçgeni: 9+16=25"),
        Pill(id: "p602", topic: .geometri, title: "Üçgen Alanı", formula: "A = (taban·yükseklik)/2", note: "Klasik alan.", example: "Taban 6, yükseklik 4 ⇒ A=12"),
        Pill(id: "p603", topic: .geometri, title: "Daire Alanı", formula: "A = π·r²", note: "Yarıçap karesinin π katı.", example: "r=3 ⇒ A=9π"),
        Pill(id: "p604", topic: .geometri, title: "Daire Çevresi", formula: "Ç = 2π·r", note: "Yarıçapla orantılı.", example: "r=5 ⇒ Ç=10π"),
        Pill(id: "p605", topic: .geometri, title: "Küre Hacmi", formula: "V = (4/3)π·r³", note: "Yarıçap küpü ile orantılı.", example: "r=3 ⇒ V=36π"),
        Pill(id: "p606", topic: .geometri, title: "Silindir Hacmi", formula: "V = π·r²·h", note: "Daire alanı × yükseklik.", example: "r=2, h=5 ⇒ V=20π"),

        // MARK: Olasılık
        Pill(id: "p701", topic: .olasilik, title: "Birleşim", formula: "P(A∪B) = P(A) + P(B) − P(A∩B)", note: "Ortak kısmı bir kez say.", example: "Zar: çift∪>4 = 2/3"),
        Pill(id: "p702", topic: .olasilik, title: "Koşullu", formula: "P(A|B) = P(A∩B)/P(B)", note: "B gerçekleşmişken A.", example: "Kart torbası anahtarı"),
        Pill(id: "p703", topic: .olasilik, title: "Faktöriyel", formula: "n! = n·(n−1)·…·1", note: "Sıralı dizilim sayısı.", example: "5! = 120"),
        Pill(id: "p704", topic: .olasilik, title: "Kombinasyon", formula: "C(n,r) = n!/(r!·(n−r)!)", note: "Sırasız seçim sayısı.", example: "C(5,2) = 10"),
        Pill(id: "p705", topic: .olasilik, title: "Permütasyon", formula: "P(n,r) = n!/(n−r)!", note: "Sıralı seçim sayısı.", example: "P(5,2) = 20"),

        // MARK: Fonksiyonlar
        Pill(id: "p801", topic: .fonksiyonlar, title: "Tek Fonksiyon", formula: "f(−x) = −f(x)", note: "Grafiği orijine simetrik.", example: "f(x)=x³ tek fonksiyondur"),
        Pill(id: "p802", topic: .fonksiyonlar, title: "Çift Fonksiyon", formula: "f(−x) = f(x)", note: "Grafiği y eksenine simetrik.", example: "f(x)=x² çift fonksiyondur"),
        Pill(id: "p803", topic: .fonksiyonlar, title: "Ters Fonksiyon", formula: "f(f⁻¹(x)) = x", note: "Birebir+örten gerektirir.", example: "f(x)=2x+1 ⇒ f⁻¹(x)=(x−1)/2"),
        Pill(id: "p804", topic: .fonksiyonlar, title: "Birleşik", formula: "(f∘g)(x) = f(g(x))", note: "Önce g, sonra f.", example: "f(x)=x², g(x)=x+1 ⇒ (x+1)²")
    ]

    static func todayPill(offset: Int = 0) -> Pill {
        let daysSinceEpoch = Int(Date().timeIntervalSince1970 / 86400.0)
        let idx = ((daysSinceEpoch + offset) % all.count + all.count) % all.count
        return all[idx]
    }

    static func byTopic(_ topic: TopicID) -> [Pill] {
        all.filter { $0.topic == topic }
    }
}

enum AchievementBank {
    static let all: [Achievement] = [
        Achievement(id: "first_step", name: "İlk Adım", icon: "flag.fill",
                    description: "İlk testini çöz", test: { $0.totalSubmissions >= 1 }),
        Achievement(id: "perfect", name: "Kusursuz", icon: "checkmark.seal.fill",
                    description: "Bir testte tüm soruları doğru bil", test: { $0.hasPerfect }),
        Achievement(id: "fast", name: "Hız Canavarı", icon: "bolt.fill",
                    description: "Bir testi 5 dk altında bitir", test: { $0.hasFast }),
        Achievement(id: "marathon", name: "Maraton", icon: "flame.fill",
                    description: "7 gün üst üste pratik yap", test: { $0.streak >= 7 }),
        Achievement(id: "century", name: "Yüz Yıldız", icon: "star.fill",
                    description: "Toplam 100 doğru cevap", test: { $0.totalCorrect >= 100 }),
        Achievement(id: "brave", name: "Cesur Kalp", icon: "shield.fill",
                    description: "10 'Zor' soruyu doğru bil", test: { $0.hardCorrect >= 10 }),
        Achievement(id: "wise", name: "Bilge", icon: "brain.head.profile",
                    description: "Güven kalibrasyonu %80+", test: { $0.calibration >= 80 && $0.confidentCount >= 10 }),
        Achievement(id: "polymath", name: "Çok Yönlü", icon: "square.grid.3x3.fill",
                    description: "5 farklı konudan pratik", test: { $0.uniqueTopics >= 5 }),
        Achievement(id: "leader", name: "Lider", icon: "crown.fill",
                    description: "Sıralamada 1. ol", test: { $0.isRankOne })
    ]
}
