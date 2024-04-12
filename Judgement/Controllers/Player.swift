//
//  Player.swift
//  Judgement
//
//  Created by manan.goyal on 1/3/2024.
//
import UIKit

class Player {
    var name: String
    var cardsInHand: [PlayingCard]
    var points: Int
    var roundsJudged: Int
    var roundsWon: Int
    var hasToPlay: Bool
    var cardHolder: UIImageView?
    var currentCard: PlayingCard?

    init(name: String, cardsInHand: [PlayingCard], points: Int, roundsJudged: Int, roundsWon: Int, hasToPlay: Bool) {
        self.name = name
        self.cardsInHand = cardsInHand
        self.points = points
        self.roundsJudged = roundsJudged
        self.roundsWon = roundsWon
        self.hasToPlay = hasToPlay
    }
}
