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
        self.playerNameList = players.compactMap { $0["name"] as? String }
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
  
}
