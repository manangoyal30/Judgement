//
//  Card.swift
//  Judgement
//
//  Created by manan.goyal on 1/3/2024.
//

enum CardSuits: String, CaseIterable {
    
    case Hearts = "Hearts"
    case Spades = "Spades"
    case Clubs = "Clubs"
    case Diamonds = "Diamonds"
}

enum CardValue: Int, CaseIterable {
    case two = 2, three, four, five, six, seven, eight, nine, ten, jack, queen, king, ace
}

struct PlayingCard {

    var cardValue: CardValue
    var cardSuit: CardSuits
    
    init(value: CardValue, suit: CardSuits)
    {
        self.cardValue = value
        self.cardSuit = suit
    }
    
    func cardName() {
        print("\(cardValue) of \(cardSuit)")
    }
}

class CardDeck {
    
    var cardsRemaining: Int
    var deck: [PlayingCard]
    
    init() {
        cardsRemaining = 52
        deck = []
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
    
    func drawCard() {
        
      //  let cardDrawn = deck.randomElement()!
        guard let cardDrawn = deck.popLast() else {
            print("No cards left in deck!")
            return
        }
   //     deck.remove(at: cardDrawn)
        if self.cardsRemaining >= 1 {
         
            self.cardsRemaining -= 1
            
            print("You drew:")
            print(cardDrawn.cardName())
            print(cardsRemaining)
        }
        
        else {
            print("No cards left in deck!")
        }
    }
}
