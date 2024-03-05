//
//  GameRoom.swift
//  Judgement
//
//  Created by manan.goyal on 5/3/2024.
//

import UIKit
import FirebaseFirestore

class GameRoom: UIViewController {
  private let currentPlayer: Player
  
  private let roomNumber: Int
  
  let database = Firestore.firestore()
    
  lazy var doc = database.collection("rooms").document("\(roomNumber)")
  
  var playerList: [Player] = []
  var playerNameList: [String] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    doc.addSnapshotListener { (querySnapshot, error) in
      guard let document = querySnapshot else {
        print("No room number found")
        return
      }
      
      guard let data = document.data() else {
        print("Document data was empty.")
        return
      }
      
      if let players = data["players"] as? [[String: Any]] {
        self.mapPlayersFromFirestore(playerList: players)
        self.setUpLayout()
      } else {
        self.playerNameList = []
      }
    }
  }
  
  init(roomNumber: Int, currentPlayer: Player) {
    self.roomNumber = roomNumber
    self.currentPlayer = currentPlayer
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setUpLayout() {
    view.backgroundColor = .white
    let totalPlayers = playerNameList.count
    
    // Sort the players list cyclically with currentPlayer first
    var sortedPlayers = playerNameList
    if let index = sortedPlayers.firstIndex(of: currentPlayer.name) {
      sortedPlayers.rotateLeft(by: index)
    }
    
    let centerX = view.width / 2
    let centerY = view.height / 2
    let horizontalRadius: CGFloat = 150
    let verticalRadius: CGFloat = 250

    // Create and position the labels
    for (index, player) in sortedPlayers.enumerated() {
      let angle = 2 * CGFloat.pi * CGFloat(index) / CGFloat(sortedPlayers.count)
      let x = centerX + horizontalRadius * sin(angle)
      let y = centerY + verticalRadius * cos(angle)

      createLabel(at: CGPoint(x: x, y: y), text: "\(player)")
    }
  }
  
  func createLabel(at position: CGPoint, text: String) {
      let label = UILabel(frame: CGRect(x: position.x - 50, y: position.y - 15, width: 100, height: 30))
      label.text = text
      label.textAlignment = .center
      label.backgroundColor = .lightGray
      view.addSubview(label)
  }
}

extension GameRoom {
  func mapPlayersFromFirestore(playerList: [[String: Any]]) {
    for player in playerList {
      if let name = player["name"] as? String,
         let cardsInHand = player["cardsInHand"] as? [PlayingCard],
         let points = player["points"] as? Int,
         let roundsJudged = player["roundsJudged"] as? Int,
         let roundsWon = player["roundsWon"] as? Int,
         let hasToPlay = player["hasToPlay"] as? Bool {
        
        let player = Player(name: name,
                            cardsInHand: cardsInHand,
                            points: points,
                            roundsJudged: roundsJudged,
                            roundsWon: roundsWon,
                            hasToPlay: hasToPlay)
        self.playerNameList.append(name)
        self.playerList.append(player)
      }
    }
  }
}
