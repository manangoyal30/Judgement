//
//  Card.swift
//  Judgement
//
//  Created by manan.goyal on 1/3/2024.
//

enum CardSuits: String, CaseIterable {
    
    case Hearts = "H"
    case Spades = "S"
    case Clubs = "C"
    case Diamonds = "D"
}

enum CardValue: String, CaseIterable {
    case two = "2",
         three = "3",
         four = "4",
         five = "5",
         six = "6",
         seven = "7",
         eight = "8",
         nine = "9",
         ten = "10",
         jack = "J",
         queen = "Q",
         king = "K",
         ace = "A"
}

struct PlayingCard {

    var cardValue: CardValue
    var cardSuit: CardSuits
    
    init(value: CardValue, suit: CardSuits)
    {
        self.cardValue = value
        self.cardSuit = suit
    }
    
    func cardName() -> String {
      "\(cardValue.rawValue)\(cardSuit.rawValue)"
    }
}

class CardDeck {
    
    var cardsRemaining: Int
    var deck: [PlayingCard]
    
    init() {
      cardsRemaining = 52
      deck = []
      createDeck()
    }
    
    func createDeck() {
    
        for suit in CardSuits.allCases {
            
            for value in CardValue.allCases {
    
                deck.append(PlayingCard(value: value, suit: suit))
            }
        }
    }
    
    func listDeck() {
        
        var count = 0
        
        for card in deck {
        print(card)
        count += 1
        }
        print(count)
    }
    
    func shuffleDeck() {
        
        deck.shuffle()
        
    }
    
    func drawCard() -> PlayingCard? {
        
      //  let cardDrawn = deck.randomElement()!
        guard let cardDrawn = deck.popLast() else {
            print("No cards left in deck!")
            return nil
        }
   //     deck.remove(at: cardDrawn)
        if self.cardsRemaining >= 1 {
         
            self.cardsRemaining -= 1
            
           return cardDrawn
        }
        
        else {
          print("No cards left in deck!")
          return nil
        }
    }
}
