import UIKit

private let possibleGenericEnglishTranslations =
[
    "Why don't you play with me some more?",
    "Do you have any food?",
    "I'm dying to go on a walk!",
    "Please adopt a friend for me to hang out with.",
    "I love you!",
    "Give me a banana.",
    "I wish my name was spaghetti.",
    "When you are away, I lick your toothbrush.",
    "You're my most favorite person in the world!",
    "Leave me alone I want to sleep.",
    "Never leave me alone!",
    "Where is your partner?",
    "I miss daddy.",
    "I miss mommy.",
    "I'm as happy as a clown!",
    "I'm as sad as a mime!",
    "I'm so angry that I could explode!",
    "I could eat a horse right now.",
    "Give me the food or there will be trouble.",
    "Where did my toy go?",
    "Quit pointing your phone at me.",
    "Your phone is annoying.",
    "Take me outside!",
    "Your phone says Apple... can I eat it?",
    "When you are away, I throw wild parties.",
    "That other pet next door is super cute.",
    "It's so boring right now. Amuse me human!",
    "I am plotting to take over the world... after eating.",
    "Yogurt is my favorite food.",
    "I have soiled myself. Please forgive me.",
    "All work no play makes me busy.",
    "Leave me alone! I'm busy.",
    "Yummy yummy yummy I've got love in my tummy.",
    "Give me a bunch of old socks!",
    "It's too dusty in here!",
    "Play with my belly!",
    "Go get my elephant toy.",
    "I wish I was a tiger.",
    "Give me some space! You are crowding my style!",
    "Chill! Before I catch a case!",
    "Give me all of your food!",
    "Leave me alone!",
    "Spend more time with me!",
    "Let's go for a drive!",
    "I hate going to the vet.",
    "Ball! Ball! Ball!",
    "The mailman is evil!",
    "Give me yogurt!",
    "Yvan Eht Nioj",
    "Where is your friend? They are cute!",
    "I like carpet a lot!",
    "I need to pee.",
    "I want to protect you",
    "I will love you forever",
    "Let's go poop!",
    "Build me a house to live in!",
    "I'm burning up in here!!",
    "I'm freezing!",
    "Bad luck and extreme misfortune will infest your pathetic soul for all eternity.",
    "Take me to the beach",
    "Let's pig out!",
    "What's in the box?",
    "How about them Cowboys?",
    "I don't know why I'm yelling!",
    "Please give me a treat!",
    "Nap! Nap! Nap!",
    "You leave me alone too often!",
    "I saw a bug over there!",
    "The sky is falling!",
    "Where did you go!?!?",
    "May I sleep with you?",
    "Baaaaaaaaaaah! Go away!",
    "Let's have a romantic date together",
    "I want to take a bath!",
    "Let's go swimming!",
    "Do you want to barbeque at the beach?",
    "Let's make bacon on the beach",
    "I'm mad at you!",
    "I'm just crazy about you!",
    "My breath smells like dog food.",
    "I like licking my butt.",
    "Toilet paper is a good toy!"
]

private var possibleGenericJapaneseTranslations =
[
    "遊ぼうよ～！",
    "お腹空いたよ～！！",
    "お散歩行きましょうよ～!",
    "お友だちと遊びたいわん♪",
    "大好きだよ!",
    "なんだかバナナを食べたい気分♪",
    "ここで問題です！私の大好物は何でしょう？",
    "ずっと一緒にいてくださいね！！",
    "世界で一番だーいすき！！",
    "急激に睡魔が…",
    "お留守番って結構寂しいんですよ…",
    "ご主人さまが一番好きなのは誰ですか？",
    "お父さんって呼んでもいいですか？",
    "お母さんって呼んでもいいですか？",
    "あ～！！幸せ！！！",
    "今ここでおやつタイムなんてどうですか？",
    "ワン！！！ダフル！！！",
    "ご主人様！ステーキ買いに行きましょうよ！！",
    "ぎゅーっとして！抱きしめて！！",
    "ここで問題です！私のお気に入りのおもちゃは何でしょう？",
    "携帯電話で何を見てるんですか？",
    "ご主人様の携帯電話にジェラシーです！！！",
    "お外で遊びたいな～！行きましょうよ～！",
    "一生ついて行きます！！！",
    "私の秘密を教えましょうか？ご主人様が留守の時に…",
    "お留守番の時何してるかって？もちろんパーティーパーティー！！！",
    "ご主人様！一発ギャグお願いします！！",
    "わん！わん！わん！",
    "私がヨーグルトが好きなこと知ってました？",
    "ご主人様の歌が聴きたいわん♪",
    "ご主人さまぁぁぁぁぁ！！",
    "ちょっと今忙しいんで！！",
    "私の体の中はご主人様への愛でいっぱいです！",
    "くんくんくん…いい匂いがするなぁ",
    "掃除！洗濯！料理！何でもお手伝いしますよ！！！",
    "お腹なでなでお願いしまーす！！！",
    "ボール遊びしたいっす！",
    "ご主人様が犬だったらなぁ…",
    "ちょっと吠えたい気分だったので…",
    "お肉！お肉！",
    "たまには贅沢させてくださいよぉ",
    "たまには一人になりたい日もあるんです…",
    "床って美味しいー！ご主人様も一緒にどうですか？",
    "ドライブ大好き！！",
    "寂しいから今日一緒に寝てもいい？",
    "ボール！！！",
    "え？今散歩って言いました？",
    "頭撫でてよ～！！！",
    "ご主人様！だっこして♡",
    "カーペットでゴロゴロ最高！一緒にどうですか？",
    "そういえばご主人様のお名前は？",
    "ご主人様のこと一生守りますからね！！",
    "これからもずっと大好き！！",
    "新しいニックネームを下さい",
    "ひざまくらお願いしま～す",
    "あ～！！暑い暑い！！！",
    "あ～！！寒い寒い！！！",
    "はろー♪",
    "ご主人様！虫がいます！！！",
    "今吠えてるのは他の犬が吠えてるからつい…",
    "あの箱の中身はなに？",
    "しりとりしましょうよ♪",
    "あれ？なんで吠えてたんだっけ？",
    "ご褒美もらえるんですか？ありがとうございます！！",
    "そろそろ寝ようかな…",
    "マッサージしてくださいよ～！！",
    "どう？私可愛いでしょ？",
    "くんくん…この匂いはもしや…",
    "さっき居なかったから寂しかったんですよ！",
    "今日はご主人様の布団で寝ます！",
    "ドッグラン行きたいっす！！",
    "かまって！かまって！",
    "遊んでくれないといたずらしちゃうよ！",
    "あーそーぼ♪",
    "週末はビーチでバーベキューなんてどうでしょう？",
    "てへっ♪",
    "ぷんぷん！！！怒っちゃうぞ！！",
    "こんにちわん♪",
    "今日の散歩まだなんですけどぉ",
    "今日のご飯まだなんですけどぉ",
    "トイレットペーパーで遊ぶのって楽しそうですよねフフフ",
]

private var possibleGenericSpanishTranslations =
    [
        "¿Por qué no juegas conmigo un poco más?",
    "¿Tienes algo de comida?",
    "¡Muero por ir a dar un paseo!",
    "Por favor, adopta un amigo para que pase el rato con él.",
    "¡Te amo!",
    "Dame un plátano.",
    "Desearía que mi nombre fuera Espagueti.",
    "Cuando estás fuera, lamo tu cepillo de dientes.",
    "¡Eres mi persona favorita en el mundo!",
    "Déjame solo, quiero dormir.",
    "¡Nunca me dejes solo!",
    "¿Dónde está tu pareja?",
    "Extraño a papi.",
    "Extraño a mami.",
    "¡Estoy tan feliz como un payaso!",
    "¡Estoy tan triste como un mimo!",
    "¡Estoy tan enojado que podría explotar!",
    "Podría comerme un caballo ahora mismo.",
    "Dame comida o habrá problemas.",
    "¿A dónde fue mi juguete?",
    "Deja de apuntar tu teléfono hacia mí.",
    "Tu teléfono es molesto.",
    "¡Llévame afuera!",
    "Tu teléfono dice Apple… ¿Puedo comerlo?",
    "Cuando estás fuera, hago fiestas salvajes.",
    "La otra mascota de al lado es súper linda",
    "Estoy muy aburrido en este momento. ¡Sorpréndeme, humano!",
    "Estoy conspirando para dominar el mundo… después de comer.",
    "El yogurt es mi comida favorita.",
    "Me he ensuciado. Perdóname, por favor.",
    "Todo es trabajo y nada de juego, me hace sentir ocupado.",
    "¡Déjame sólo! Estoy ocupado.",
    "Tengo amor en mi barriga.",
    "¡Dame un montón de calcetines viejos!",
    "¡Hay mucho polvo aquí!",
    "¡Juega con mi barriga!",
    "Ve por mi juguete de elefante.",
    "Desearía ser un tigre.",
    "¡Dame algo de espacio!, ¡Estás invadiendo mi espacio!",
    "¡Relájate!, ¡Antes de que presente un caso!",
    "¡Dame toda tu comida!",
    "¡Déjame en paz!",
    "¡Pasa más tiempo conmigo!",
    "¡Vamos a dar una vuelta!",
    "Odio ir al veterinario.",
    "¡Pelota!",
    "¡El cartero es malo!",
    "¡Dame yogurt!",
    "¿Dónde está tu amigo? ¡Son lindos!",
    "¡Me gusta mucho la alfombra!",
    "Necesito hacer pipí.",
    "Quiero protegerte.",
    "Te amaré por siempre.",
    "¡Vamos a hacer popó!",
    "Construye una casa para mí.",
    "¡¡Me estoy muriendo de calor aquí!!",
    "¡Me estoy congelando!",
    "Mala suerte y extrema desgracia infestarán tu patética alma por toda la eternidad.",
    "Llévame a la playa.",
    "¡Vamos a atragantarnos!",
    "¿Qué hay en la caja?",
    "¿Cómo van los ‘Cowboys’?",
    "¡No sé por qué estoy gritando!",
    "¡Dame un premio, por favor!",
    "¡Siesta!",
    "¡Me dejas solo muy a menudo!",
    "¡Vi un bicho por ahí!",
    "¡El cielo se está cayendo!",
    "¿¡¿¡A dónde fuiste!?!?",
    "¿Puedo dormir contigo?",
    "¡Baaaaaaaaah! ¡Vete!",
    "Tengamos una cita romántica juntos.",
    "¡Quiero darme un baño!",
    "¡Vamos a nadar!",
    "¿Quieres hacer una barbacoa en la playa?",
    "Hay que preparar tocino en la playa.",
    "¡Estoy enojado contigo!",
    "¡Estoy loco por ti!",
    "Mi aliento huele a comida de perro.",
    "Me gusta lamer mi trasero.",
    "¡El rollo de papel es un buen juguete!",
]

private var possibleGenericChineseTranslations =
[
    "你為什麼不跟我多玩一點點？",
    "你有任何食物嗎?",
    "我非常非常渴望去散步！",
    "請領養一個和我玩的朋友。",
    "我愛你！",
    "給我一隻香蕉。",
    "我希望我的名字叫意大利麵。",
    "當你不在的時候，我舔你的牙刷。",
    "你是我在世界上最喜歡的人!",
    "別管我, 我想睡覺。",
    "永遠不要離開我！",
    "你的夥伴在哪裡?",
    "我想念爸爸。",
    "我想念媽媽。",
    "我像一個小丑一樣快樂！",
    "我是一個悲哀的默劇!",
    "我快氣炸了！",
    "我現在可以吃一匹馬。",
    "給我吃東西要不然會有麻煩。",
    "我的玩具去了哪裡？",
    "別用你的電話指著我。",
    "你的電話很煩。",
    "帶我去外面！",
    "你的電話叫蘋果......我可以吃嗎？",
    "當你不在的時候，我舉辦瘋狂派對。",
    "隔壁那隻寵物超級可愛的。",
    "現在好無聊。娛樂我,人類！",
    "我正在密謀征服世界......等吃完飯侯 。",
    "優格是我最喜歡的食物。",
    "我已經弄髒自己。 請原諒我。",
    "只有工作沒有玩樂使得我很忙。",
    "別管我！ 我很忙。",
    "我的肚子裡有愛。",
    "給我一堆舊襪子！",
    "這裡有太多灰塵！",
    "玩我的肚子！",
    "去拿我的大象玩具。",
    "我希望我是一隻老虎。",
    "給我一些空間！你使我無法展現我的風格！",
    "冷靜點!別害我上法庭!",
    "給我你所有的食物！",
    "別管我！",
    "花多點時間陪我！",
    "我們去兜風！",
    "我討厭去看獸醫。",
    "球！",
    "郵差是邪惡的！",
    "優格！",
    "你的朋友在哪？ 他們很可愛！",
    "我非常喜歡地毯!",
    "我要尿尿。",
    "我要保護你",
    "我會永遠愛你",
    "我們去大便！",
    "給我建立一間房子住！",
    "我在這裡燒起來了！",
    "我快凍僵了！",
    "壞運和極端的不幸永遠將侵擾你可憐的靈魂",
    "帶我去海邊",
    "讓我們好像豬豬一樣懶洋洋！",
    "箱子裡有什麼?",
    "那些牛仔們如何?",
    "我不知道為什麼我大呼小叫！",
    "請給我一個獎樂！",
    "午睡!",
    "你太常留下我一個人!",
    "我在那裡看到了一隻蟲!",
    "天塌下來了！",
    "你去哪裡了！？！？",
    "我可以跟你睡嗎？",
    "叭啊啊啊！ 走開啦！",
    "讓我們有一個浪漫的約會",
    "我想要洗澡！",
    "我們去游泳吧！",
    "你想在沙灘上燒烤嗎？",
    "讓我們在沙灘上做培根",
    "我對你生氣!",
    "我為你而瘋狂！",
    "我的口氣聞起來像狗食。",
    "我喜歡舔我的屁股。",
    "衛生紙是個好玩具！",
]

private var possibleGenericKoreanTranslations =
[
    "저랑 더 놀아주세요!",
    "먹을거 없나요?",
    "산책가고싶어 죽겠어요!",
    "같이 놀 친구를 입양해주세요.",
    "사랑해요!",
    "바나나 좀 주세요.",
    "제 이름을 스파게티라고 했으면 좋겠어요.",
    "자리에 안 계실 때, 주인님 칫솔을 핥는답니다",
    "세상에서 당신을 가장 좋아해요!",
    "잠자고 싶어요 혼자 있게 해주세요..",
    "혼자 있고 싶지 않아요!",
    "제 짝은 어디에있나요?",
    "아빠가 보고 싶어요.",
    "엄마가 보고 싶어요.",
    "정말 행복해요!",
    "너무 너무 슬퍼요!",
    "너무 화가 나서 폭발할 것 같아요!",
    "지금 배가 고파 죽겠어요.",
    "지금 밥 안주면 큰일날꺼에요",
    "제 장난감 어디 있나요?",
    "전화기좀 그만 갖다대세요.",
    "전화기 짜증나요",
    "산책가고 싶어요!",
    "주인님 전화기에 ‘사과’라고 쓰여있는데…먹어도 되나요?",
    "주인님이 나가시면, 광란의 파티를 연답니다.",
    "옆집에사는 동물친구가 완전 귀여워요.",
    "너무 지루해요. 웃겨주세요!",
    "나는 세계를 정복할 거에요….. 밥좀먹구요.",
    "요구르트는 제가 좋아하는 음식이에요.",
    "응가를 했어요... 용서해주세요.",
    "일하느라고 놀지도 못하고 바빠요",
    "혼자 내버려 두세요! 저 바빠요.",
    "배불러서 행복해요.",
    "낡은 양말을 주세요!",
    "여기 너무 더러워요!",
    "제 배를 만져주세요!",
    "코끼리 장난감을 가져오세요.",
    "내가 호랑었으면 좋겠어요.",
    "귀찮게 하지말고 혼자있게 해주세요!",
    "제가 화내기전에 그만하세요!",
    "주인님 음식을 다 주세요!",
    "혼자 내버려 두세요!",
    "저와 함께 시간을 더 보내주세요!",
    "드라이브하러 가요!",
    "병원에 가기 싫어요.",
    "공 주세요!",
    "우편 배달부는 악마예요!",
    "요구르트 좀 주세요!",
    "주인님 친구들 귀엽던데,  어디 있나요? ",
    "저는 카펫이 너무 좋아요!",
    "쉬 마려워요",
    "주인님을 지켜주고 싶어요",
    "영원히 주인님을 사랑할 거예요",
    "응가 하러 가요!",
    "제가 살 집을 만들어주세요!",
    "여기 너무 더워요!!",
    "너무 추워요!",
    "불운과 불행이 주인님의 슬픈 영혼에 몰려들 거예요.",
    "바다에 데려가 주세요",
    "과식해 볼까요!",
    "그 박스에 무엇이 있나요?",
    "수원삼성블루윙즈 게임은 어떻게 되가나요?",
    "제가 크게 짖는 이유를 저도 모르겠어요!",
    "특별 간식을 주세요!",
    "낮잠잘래요!",
    "너무 자주 저를 혼자 내버려 두시는군요!",
    "저기서 벌레를 봤어요!",
    "하늘이 무너지는것 같아요.",
    "어디 갔었어요?!?",
    "같이 자도 될까요?",
    "흥! 가세요!",
    "함께 로맨틱한 데이트를 해요",
    "목욕하고 싶어요!",
    "수영 하러 가요!",
    "해변에서 바비큐 파티하고 싶지 않아요?",
    "해변에서 베이컨 만들어요!",
    "주인님께 화났어요!",
    "주인님께 푹 빠졌어요!",
    "제 입에서 개밥 냄새가 나요.",
    "저는 제 엉덩이를 핥는게 좋아요.",
    "화장지는 좋은 장난감이에요!"
]

enum Language: Int, CustomStringConvertible
{
    case English = 0
    case Spanish = 1
    case Japanese = 2
    case Chinese = 3
    case Korean = 4

    static var count: Int { return Language.Korean.hashValue + 1}
    
    var description: String
    {
        switch self
        {
            case .English: return "English"
            case .Japanese   : return "日本語"
            case .Spanish : return "Español"
            case.Korean : return "한국어"
            case .Chinese : return "中文"
        }
    }
}

class PetTranslation: NSObject, NSCoding
{
    // MARK: Properties
    var translatedText: String!
    var audioURL: NSURL?
    var transLanguage: Language!
    var dateRecorded: NSDate!
    var duration: Float!
    override var description: String
    {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy"
        let dateRecordedString = dateFormatter.stringFromDate(self.dateRecorded)
        return "\(dateRecordedString): \(translatedText)"
    }
    
    // MARK: Types
    struct PropertyKey
    {
        static let translatedText = "translationText"
        static let audioURLText = "audioURLText"
        static let transLanguageText = "transLanguageText"
        static let dateRecordedText = "dateRecordedText"
        static let durationText = "durationText"
    }
    
    
    // MARK: Initialization
    init?(audioURL: NSURL, transLanguage: Language, duration: Float,
          dateRecorded: NSDate)
    {
        super.init()
        
        self.audioURL = audioURL
        self.transLanguage = transLanguage
        self.dateRecorded = dateRecorded
        self.duration = duration
    }
    
    override init()
    {
        super.init()
        
        self.audioURL = nil
        self.transLanguage = Language.English
        self.translatedText = ""
    }
    
    // MARK: Functions
    func getRandomTranslation() -> String
    {
        var translationCount: UInt32
        var translationBank: [String]
        
        switch transLanguage.rawValue
        {
        case Language.Japanese.rawValue:
            translationBank = possibleGenericJapaneseTranslations
        case Language.English.rawValue:
            translationBank = possibleGenericEnglishTranslations
        case Language.Chinese.rawValue:
            translationBank = possibleGenericChineseTranslations
        case Language.Spanish.rawValue:
            translationBank = possibleGenericSpanishTranslations
        case Language.Korean.rawValue:
            translationBank = possibleGenericKoreanTranslations
        default:
            print("PetTranslation: ERROR - Unsupported Language!")
            return ""
        }
    
        translationCount = UInt32(translationBank.count)
        
        /* Return some random number */
        return translationBank[Int(arc4random_uniform(UInt32(translationCount)))]
    }
    
    func assignRandomTranslation()
    {
        self.translatedText = getRandomTranslation()
    }
    
    //MARK: NSCoding
    func encodeWithCoder(aCoder: NSCoder)
    {
        aCoder.encodeObject(audioURL, forKey: PropertyKey.audioURLText)
        aCoder.encodeInteger(transLanguage.rawValue, forKey: PropertyKey.transLanguageText)
        aCoder.encodeObject(translatedText, forKey: PropertyKey.translatedText)
        aCoder.encodeFloat(duration, forKey: PropertyKey.durationText)
        aCoder.encodeObject(dateRecorded, forKey: PropertyKey.dateRecordedText)
    }
    
    required convenience init?(coder aDecoder: NSCoder)
    {
        let decodedURL = aDecoder.decodeObjectForKey(PropertyKey.audioURLText) as! NSURL
        let decodedLanguage = aDecoder.decodeIntegerForKey(PropertyKey.transLanguageText)
        let decodededText = aDecoder.decodeObjectForKey(PropertyKey.translatedText) as! String
        let decodedDuration = aDecoder.decodeFloatForKey(PropertyKey.durationText)
        let decodedDate = aDecoder.decodeObjectForKey(PropertyKey.dateRecordedText) as! NSDate
        
        self.init(audioURL: decodedURL, transLanguage: Language.init(rawValue: decodedLanguage)!,
                  duration: decodedDuration, dateRecorded: decodedDate)
        
        self.translatedText = decodededText
    }
    
    // MARK: Archiving Paths:
    static let DocumentsDirectory = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.URLByAppendingPathComponent("petTranslations")
    
}
