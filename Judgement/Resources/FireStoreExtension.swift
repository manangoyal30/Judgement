//
//  FireStoreExtension.swift
//  Judgement
//
//  Created by manan.goyal on 5/3/2024.
//

import FirebaseFirestore

extension DocumentReference {
    func fetchPlayerNames(completion: @escaping ([String]) -> Void) {
        self.addSnapshotListener { (querySnapshot, error) in
            guard let document = querySnapshot else {
                print("No room number found")
                completion([])
                return
            }

            guard let data = document.data() else {
                print("Document data was empty.")
                completion([])
                return
            }

            if let players = data["players"] as? [[String: Any]] {
                let playerNameList = players.compactMap { $0["name"] as? String }
                completion(playerNameList)
            } else {
                completion(["No players found"])
            }
        }
    }
  
  func isRoomClosed(completion: @escaping (Bool) -> Void) {
    self.addSnapshotListener { (querySnapshot, error) in
      guard let document = querySnapshot else {
          print("No room number found")
          completion(false)
          return
      }

      guard let data = document.data() else {
          print("Document data was empty.")
          completion(false)
          return
      }

      if let isRoomOpen = data["isRoomOpen"] as? Bool, !isRoomOpen {
          completion(true)
      } else {
          completion(false)
      }
      
    }
  }
}
