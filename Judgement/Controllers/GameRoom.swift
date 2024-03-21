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
  
  private var totalRounds: Int = 0
  
  var collectionView: UICollectionView?
  
  let database = Firestore.firestore()
    
  lazy var doc = database.collection("rooms").document("\(roomNumber)")
  
  var playerList: [Player] = []
  var playerNameList: [String] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    doc.getDocument { (querySnapshot, error) in
      guard let document = querySnapshot else {
        print("No room number found")
        return
      }
      
      guard let data = document.data() else {
        print("Document data was empty.")
        return
      }
      
      if let totalRounds = data["totalRounds"] as? Int {
        self.totalRounds = totalRounds
      }
      
      if let players = data["players"] as? [[String: Any]] {
        self.mapPlayersFromFirestore(playerList: players)
        self.setUpLayout()
        self.setUpCardCollectionView()
        self.startGame()
      } else {
        let homeViewController = HomeViewController()
        self.navigationController?.popToViewController(homeViewController, animated: true)
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
    
    // Sort the players list cyclically with currentPlayer first
    var sortedPlayers = playerNameList
    if let index = sortedPlayers.firstIndex(of: currentPlayer.name) {
      sortedPlayers.rotateLeft(by: index)
    }
    
    let centerX = view.width / 2
    let centerY = view.height / 2
    let horizontalRadius: CGFloat = 150
    let verticalRadius: CGFloat = 250
    
    let horizontalCardRadius: CGFloat = 80
    let verticalCardRadius: CGFloat = 150

    // Create and position the labels
    for (index, player) in sortedPlayers.enumerated() {
      let angle = 2 * CGFloat.pi * CGFloat(index) / CGFloat(sortedPlayers.count)
      let x = centerX + horizontalRadius * sin(angle)
      let y = centerY + verticalRadius * cos(angle)
      
      let cardx = centerX + horizontalCardRadius * sin(angle)
      let cardy = centerY + verticalCardRadius * cos(angle)

      createLabel(at: CGPoint(x: x, y: y), text: "\(player)")
      createCardHolder(for: player, at: CGPoint(x: cardx, y: cardy))
    }
  }
  
  func createLabel(at position: CGPoint, text: String) {
      let label = UILabel(frame: CGRect(x: position.x - 50, y: position.y - 15, width: 100, height: 30))
      label.text = text
      label.textAlignment = .center
      label.backgroundColor = .lightGray
      view.addSubview(label)
  }
  
  func createCardHolder(for playerName: String, at position: CGPoint) {
    let cardHolder = UIImageView(frame: CGRect(x: position.x - 35, y: position.y - 50, width: 70, height: 100))
    playerList.first(where: {$0.name == playerName})?.cardHolder = cardHolder
    // TODO: TESTING
//      cardHolder.image = UIImage(named: "AS")
      cardHolder.backgroundColor = .red
      view.addSubview(cardHolder)
  }
  
  func setUpCardCollectionView() {
    let layout = UICollectionViewFlowLayout()
    layout.scrollDirection = .horizontal
    layout.itemSize = CGSize(width: 70, height: 100)  // This should match the size of your card holder
    layout.minimumLineSpacing = -35
    collectionView = UICollectionView(frame: CGRect(x: 10 , y: view.bottom - 200, width: 400, height: 100), collectionViewLayout: layout)
    guard let collectionView else { return }
    collectionView.dataSource = self
    collectionView.delegate = self
    collectionView.register(CardCell.self, forCellWithReuseIdentifier: "CardCell")
    self.view.addSubview(collectionView)

  }
}

extension GameRoom: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return currentPlayer.cardsInHand.count
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
      guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CardCell", for: indexPath) as? CardCell else {
          return UICollectionViewCell()
      }
    let imageName = currentPlayer.cardsInHand[indexPath.item].cardName()
      cell.imageView?.image = UIImage(named: imageName)
      return cell
  }

}

extension GameRoom {
  private func startGame() {
    for round in 1...totalRounds {
      print(round)
      startRound(round: round)
    }
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

extension GameRoom {
  private func startRound(round: Int) {
    let deck = CardDeck()
    deck.shuffleDeck()
    
    for player in playerList {
      for i in 1...10 {
        if let card = deck.drawCard() {
          player.cardsInHand.append(card)
        }
      }
    }
    currentPlayer.cardsInHand = playerList.first(where: {$0.name == currentPlayer.name})?.cardsInHand ?? []
  }
}
