import UIKit

private var possibleGenericEnglishTranslations =
    ["Why don't you play with me some more?",
     "Do you have any food?",
     "I'm dying to go on a walk!",
     "Please adopt a friend for me to hang out with."]

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

class PetTranslation
{
    // MARK: Properties
    var translatedText: String = ""
    var audioURL: NSURL?
    var transLanguage: Language!
    
    // MARK: Initialization
    init?(audioURL: NSURL, transLanguage: Language)
    {
        self.audioURL = audioURL
        self.transLanguage = transLanguage
        self.translatedText = getRandomTranslation()
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
}