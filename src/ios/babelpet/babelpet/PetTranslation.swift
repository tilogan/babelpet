import UIKit

private var possibleGenericTranslations =
    ["Why don't you play with me some more?",
     "Do you have any food?",
     "I'm dying to go on a walk!",
     "Please adopt a friend for me to hang out with."]

class PetTranslation
{
    // MARK: Properties
    var translatedText: String = ""
    var audioURL: NSURL?
    
    // MARK: Initialization
    init?(audioURL: NSURL)
    {
        self.audioURL = audioURL
        self.translatedText = getRandomTranslation()
    }
    
    // MARK: Functions
    func getRandomTranslation() -> String
    {
        var translationCount: UInt32
        
        translationCount = UInt32(possibleGenericTranslations.count)
        
        /* Return some random number */
        return possibleGenericTranslations[Int(arc4random_uniform(UInt32(translationCount)))]
    }
}