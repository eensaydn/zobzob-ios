import Foundation

struct Motivation: Codable, Identifiable, Hashable {
    let id: String
    let quote: String
    let author: String
    let theme: Theme

    enum Theme: String, Codable {
        case math       // matematik / bilim
        case effort     // azim / çalışma
        case mindset    // büyüme zihniyeti
        case wisdom     // bilgelik / hayat
        case turkish    // Türk büyükleri

        var icon: String {
            switch self {
            case .math: return "function"
            case .effort: return "flame.fill"
            case .mindset: return "brain.head.profile"
            case .wisdom: return "leaf.fill"
            case .turkish: return "flag.fill"
            }
        }

        var label: String {
            switch self {
            case .math: return "Matematik"
            case .effort: return "Azim"
            case .mindset: return "Zihniyet"
            case .wisdom: return "Bilgelik"
            case .turkish: return "Türk Düşünürleri"
            }
        }
    }
}

enum MotivationBank {
    static let all: [Motivation] = [
        // Matematik / Bilim
        .init(id: "m001", quote: "Matematik, doğanın yazıldığı dildir.", author: "Galileo Galilei", theme: .math),
        .init(id: "m002", quote: "Saf matematik, kendi tarzında, mantıksal düşüncelerin şiiridir.", author: "Albert Einstein", theme: .math),
        .init(id: "m003", quote: "Bir problemi çözemiyorsan, daha kolay bir problem var demektir: onu bul.", author: "George Pólya", theme: .math),
        .init(id: "m004", quote: "Matematikçi olmadan önce, problem yapacak kadar inatçı olmalısın.", author: "Paul Erdős", theme: .math),
        .init(id: "m005", quote: "Matematik korkuyu yenmenin sanatıdır.", author: "Cahit Arf", theme: .turkish),
        .init(id: "m006", quote: "Matematik, hiçbir şeye benzemeyen tek dildir.", author: "Bertrand Russell", theme: .math),
        .init(id: "m007", quote: "Matematik, evrenin yapı taşıdır; onu öğrenen kuralı öğrenir.", author: "Pisagor", theme: .math),
        .init(id: "m008", quote: "Hesaplayabildiğin her şey, mucize olmaktan çıkar.", author: "Henri Poincaré", theme: .math),
        .init(id: "m009", quote: "Sayılar evrenin gizli müziğidir.", author: "Pythagoras", theme: .math),
        .init(id: "m010", quote: "Bilimin gerçeği güzelliktir; güzelliği de gerçeği.", author: "Bertrand Russell", theme: .math),

        // Türk büyükleri
        .init(id: "m020", quote: "Hayatta en hakiki mürşit ilimdir.", author: "Mustafa Kemal Atatürk", theme: .turkish),
        .init(id: "m021", quote: "Öğretmenler, yeni nesli sizler yetiştireceksiniz.", author: "Mustafa Kemal Atatürk", theme: .turkish),
        .init(id: "m022", quote: "İlimden, fenden ayrı olan din, hurafelerin kümesidir.", author: "Mustafa Kemal Atatürk", theme: .turkish),
        .init(id: "m023", quote: "İlim, kâbus mu? Hayır; bizi karanlıktan aydınlığa çıkaran rehber.", author: "Mustafa Kemal Atatürk", theme: .turkish),
        .init(id: "m024", quote: "Sen kendini bil yâ Hû.", author: "Yunus Emre", theme: .turkish),
        .init(id: "m025", quote: "Ya olduğun gibi görün, ya göründüğün gibi ol.", author: "Mevlana Celaleddin-i Rumi", theme: .turkish),
        .init(id: "m026", quote: "Aklını kullan, içine doğanı dinle.", author: "Mevlana", theme: .turkish),
        .init(id: "m027", quote: "Aramakla bulunmaz; bulunduğu zaman bilinir.", author: "Mevlana", theme: .turkish),
        .init(id: "m028", quote: "Bilim teknik yön gösterir; bilgelik nereye gideceğini söyler.", author: "İsmet İnönü", theme: .turkish),
        .init(id: "m029", quote: "Matematik, halkımızın geleceğine açılan en sağlam kapıdır.", author: "Cahit Arf", theme: .turkish),

        // Azim / Çalışma
        .init(id: "m040", quote: "Başarı tesadüf değildir; çalışma, ısrar, fedakârlık ve en önemlisi yaptığın işi sevmektir.", author: "Pelé", theme: .effort),
        .init(id: "m041", quote: "Yavaş gitmekten korkma; durmaktan kork.", author: "Çin atasözü", theme: .effort),
        .init(id: "m042", quote: "Bin millik yolculuk tek bir adımla başlar.", author: "Lao Tzu", theme: .effort),
        .init(id: "m043", quote: "Damlaya damlaya göl olur.", author: "Türk atasözü", theme: .turkish),
        .init(id: "m044", quote: "Sabırla koruk helva olur.", author: "Türk atasözü", theme: .turkish),
        .init(id: "m045", quote: "Bugün yapmadığın çalışma, yarın yapmak zorunda kaldığın iki çalışmadır.", author: "Anonim", theme: .effort),
        .init(id: "m046", quote: "Dehâ %1 ilham, %99 ter dökmektir.", author: "Thomas Edison", theme: .effort),
        .init(id: "m047", quote: "Pes etmek, başarmaktan bir nefes uzakta durmaktır.", author: "Anonim", theme: .effort),
        .init(id: "m048", quote: "Her uzman, bir zamanlar acemiydi.", author: "Helen Hayes", theme: .effort),
        .init(id: "m049", quote: "Çalışmadan, hiçbir şey başarılmaz.", author: "Sofokles", theme: .effort),
        .init(id: "m050", quote: "Yorulduğunda dinlenmeyi öğren, vazgeçmeyi değil.", author: "Anonim", theme: .effort),
        .init(id: "m051", quote: "Yapamayacağını düşünenlere, yapanlar tarafından engel olunmamalıdır.", author: "Bernard Shaw", theme: .effort),

        // Zihniyet
        .init(id: "m070", quote: "Hayatta sahip olduğun en güçlü silah, vazgeçmemektir.", author: "Anonim", theme: .mindset),
        .init(id: "m071", quote: "Henüz bilmiyorsun — anahtar kelime 'henüz'.", author: "Carol Dweck", theme: .mindset),
        .init(id: "m072", quote: "Akıllı insan kendi hatalarından öğrenir; bilge ise başkalarınınkinden.", author: "Otto von Bismarck", theme: .mindset),
        .init(id: "m073", quote: "Başarısızlık, başarmaya bir adım daha yakın olmaktır.", author: "Thomas Edison", theme: .mindset),
        .init(id: "m074", quote: "Düşündüğün gibi olursun.", author: "Marcus Aurelius", theme: .mindset),
        .init(id: "m075", quote: "Zor olan değil, sürdürülebilir olan kazanır.", author: "Anonim", theme: .mindset),
        .init(id: "m076", quote: "Disiplin, hedef ile başarı arasındaki köprüdür.", author: "Jim Rohn", theme: .mindset),
        .init(id: "m077", quote: "Karşılaştığın engel, yolundan geri çevirmek için değil; ne kadar istediğini sınamak için.", author: "Randy Pausch", theme: .mindset),
        .init(id: "m078", quote: "İnandığın anda yarısını başardın demektir.", author: "Theodore Roosevelt", theme: .mindset),
        .init(id: "m079", quote: "Kendini, dünün senden daha iyi bir versiyon ol — başkalarıyla değil.", author: "Jordan Peterson", theme: .mindset),
        .init(id: "m080", quote: "Bir tohumun toprağa kavuşması, ışığı görmesi için karanlıktan geçmesidir.", author: "Anonim", theme: .mindset),
        .init(id: "m081", quote: "İmkânsız sadece daha uzun süren mümkündür.", author: "Anonim", theme: .mindset),

        // Bilgelik
        .init(id: "m100", quote: "Eğitim, hayatın hazırlığı değildir; eğitim hayatın kendisidir.", author: "John Dewey", theme: .wisdom),
        .init(id: "m101", quote: "Hiçbir şey bilmediğimi biliyorum.", author: "Sokrates", theme: .wisdom),
        .init(id: "m102", quote: "Söyle bana, unutayım. Göster bana, hatırlayayım. Beni dâhil et, öğreneyim.", author: "Benjamin Franklin", theme: .wisdom),
        .init(id: "m103", quote: "Bildiğini bilmek; bilmediğini bilmek; gerçek bilgi budur.", author: "Konfüçyüs", theme: .wisdom),
        .init(id: "m104", quote: "Hayat, gerçekleştirdiğin bir hayalin yarısı, plan yaptığın diğer yarısıdır.", author: "Anonim", theme: .wisdom),
        .init(id: "m105", quote: "Ne kadar bilirsen bil, söylediklerin karşındakinin anlayacağı kadardır.", author: "Mevlana", theme: .turkish),
        .init(id: "m106", quote: "Eğer bir öğretmenseniz, ölümsüzsünüz; öğrencileriniz sizi yaşatır.", author: "Anonim", theme: .wisdom),
        .init(id: "m107", quote: "Bir milletin geleceği için iki müthiş kelime: eğitim ve emek.", author: "Anonim", theme: .wisdom),
        .init(id: "m108", quote: "Bilgi, beraberinde sorumluluk getirir.", author: "Anonim", theme: .wisdom),
        .init(id: "m109", quote: "Bildiğin şeyleri öğretmek, en iyi öğrenme yoludur.", author: "Lucius Annaeus Seneca", theme: .wisdom),

        // Matematik özelinde modern + ek
        .init(id: "m120", quote: "Türev bir noktadaki anlık değişimdir — hayat da öyle, her an küçük adımlarla şekillenir.", author: "Anonim", theme: .math),
        .init(id: "m121", quote: "İntegral toplamdır — her küçük çabanın hesabı tutulur, hiçbiri kaybolmaz.", author: "Anonim", theme: .math),
        .init(id: "m122", quote: "Limit, ulaşamadığın değere ne kadar yaklaştığındır. Hedefe bir adım kalsa bile, yön doğrudur.", author: "Anonim", theme: .math),
        .init(id: "m123", quote: "Matematik bir keşif; doğanın hâli hazırda var olan kanunlarını okumaktır.", author: "Roger Bacon", theme: .math),
        .init(id: "m124", quote: "İki şey sonsuzdur: evren ve insan aptallığı; ilkinden emin değilim.", author: "Albert Einstein", theme: .math),
        .init(id: "m125", quote: "Bir formül, bin kelimeden değerlidir — anlamını kavradığında.", author: "Anonim", theme: .math),
        .init(id: "m126", quote: "Logaritma; çok büyük ya da çok küçük şeyleri görmek için takılan bir gözlük gibidir.", author: "Anonim", theme: .math)
    ]

    /// Gün indeksine göre deterministic seçim.
    static func today(offset: Int = 0) -> Motivation {
        let daysSinceEpoch = Int(Date().timeIntervalSince1970 / 86400.0)
        let idx = ((daysSinceEpoch + offset) % all.count + all.count) % all.count
        return all[idx]
    }

    static func byTheme(_ t: Motivation.Theme) -> [Motivation] {
        all.filter { $0.theme == t }
    }
}
