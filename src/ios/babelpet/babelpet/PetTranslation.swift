import UIKit

private var possibleGenericEnglishTranslations =
    ["Why don't you play with me some more?",
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
      "Play with my!",
      "Go get my elephant toy.",
      "I wish I was a tiger.",
      "Give me some space! You are crowding my style!",
      "Chill! Before I catch a case!",
      "Give me all of your food!",]

private var possibleGenericJapaneseTranslations =
["こんにちは",
 "お腹すいた〜",
 "散歩に行こうよ",
 "お友だちと遊びたいな"
]

enum Language: Int, CustomStringConvertible
{
    case English = 0
    case 日本語 = 1

    static var count: Int { return Language.日本語.hashValue + 1}
    
    var description: String
    {
        switch self
        {
            case .English: return "English"
            case .日本語   : return "日本語"
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
        
        if transLanguage == Language.日本語
        {
            translationBank = possibleGenericJapaneseTranslations
        }
        else if transLanguage == Language.English
        {
            translationBank = possibleGenericEnglishTranslations
        }
        else
        {
            print("Unsupported language provided for translation")
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
