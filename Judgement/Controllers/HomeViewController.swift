//
//  HomeViewController.swift
//  Judgement
//
//  Created by manan.goyal on 9/2/2024.
//

import UIKit
import FirebaseFirestore

class HomeViewController: UIViewController {
  
  let database = Firestore.firestore()
  
  private let scrollView: UIScrollView = {
    let scrollView = UIScrollView()
    scrollView.clipsToBounds = true
    return scrollView
  }()
  
  private let nameInputField: UITextField = {
    let field = UITextField()
    field.autocapitalizationType = .none
    field.autocorrectionType = .no
    field.returnKeyType = .continue
    field.layer.cornerRadius = 12
    field.layer.borderWidth = 1
    field.layer.borderColor = UIColor.lightGray.cgColor
    field.placeholder = "Enter Name"
    field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
    field.leftViewMode = .always
    field.backgroundColor = .clear
    return field
  }()
  
  private let nameErrorField: UILabel = {
    let label = UILabel()
    label.backgroundColor = .clear
    label.isHidden = true
    label.font = .systemFont(ofSize: 12, weight: .regular)
    label.textColor = .red
    return label
  }()
  
  private let roomInputField: UITextField = {
    let field = UITextField()
    field.keyboardType = .numberPad
    field.autocapitalizationType = .none
    field.autocorrectionType = .no
    field.returnKeyType = .continue
    field.layer.cornerRadius = 12
    field.layer.borderWidth = 1
    field.layer.borderColor = UIColor.lightGray.cgColor
    field.placeholder = "Enter Room Number..."
    field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
    field.leftViewMode = .always
    field.backgroundColor = .clear
    return field
  }()
  
  private let roomErrorField: UILabel = {
    let label = UILabel()
    label.backgroundColor = .clear
    label.isHidden = true
    label.font = .systemFont(ofSize: 12, weight: .regular)
    label.textColor = .red
    return label
  }()
  
  private let createRoomButton: UIButton = {
    let button = UIButton()
    button.setTitle("Create Room", for: .normal)
    button.backgroundColor = .link
    button.setTitleColor(.white, for: .normal)
    button.layer.cornerRadius = 12
    button.layer.masksToBounds = true
    button.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
    return button
  }()
  
  private let joinRoomButton: UIButton = {
    let button = UIButton()
    button.setTitle("Join Room", for: .normal)
    button.backgroundColor = .systemGreen
    button.setTitleColor(.white, for: .normal)
    button.layer.cornerRadius = 12
    button.layer.masksToBounds = true
    button.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
    return button
  }()
  
  @objc private func joinRoomButtonTappedWrapper() {
      Task {
          await joinRoomButtonTapped()
      }
  }
  
  @objc private func joinRoomButtonTapped() async {
    
    guard let playerName = nameInputField.text, !playerName.isEmpty else {
        handleNameError("Player name cannot be empty")
        return
    }
    
    guard let roomNumber = roomInputField.text, !roomNumber.isEmpty, roomNumber.count == 4 else {
      handleRoomError("Room number doesn't exist")
      return
    }
    
    if nameErrorField.isHidden == false {
      nameErrorField.isHidden = true
    }
    
    if roomErrorField.isHidden == false {
      roomErrorField.isHidden = true
    }
    
    let player = Player(name: playerName,
                        cardsInHand: [],
                        points: 0,
                        roundsJudged: 0,
                        roundsWon: 0,
                        hasToPlay: false)
    
    
    joinRoom(roomNo: Int(roomNumber) ?? 0, player: player, completion: {
      let waitingRoom = WaitingRoomViewController(roomNumber: Int(roomNumber) ?? 0, currentPlayer: player)
      self.navigationController?.pushViewController(waitingRoom, animated: true)
    })
  }
  
  @objc private func createRoomButtonTapped() {
    roomInputField.resignFirstResponder()
    let randomID = Int.random(in: 1000..<10000)
        
    guard let playerName = nameInputField.text, !playerName.isEmpty else {
        handleNameError("Player name cannot be empty")
        return
    }
    
    if nameErrorField.isHidden == false {
      nameErrorField.isHidden = true
    }
    
    let player = Player(name: playerName,
                        cardsInHand: [],
                        points: 0,
                        roundsJudged: 0,
                        roundsWon: 0,
                        hasToPlay: false)
    
    
    let success = createRoomAndAddPlayer(roomNo: randomID, player: player)
        
    if success {
      let waitingRoom = WaitingRoomViewController(roomNumber: randomID, currentPlayer: player)
      self.navigationController?.pushViewController(waitingRoom, animated: true)
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    joinRoomButton.addTarget(
      self,
      action: #selector(joinRoomButtonTappedWrapper),
      for: .touchUpInside
    )
    
    createRoomButton.addTarget(
      self,
      action: #selector(createRoomButtonTapped),
      for: .touchUpInside
    )
    
    view.addSubview(scrollView)
    scrollView.addSubview(nameInputField)
    scrollView.addSubview(nameErrorField)

    scrollView.addSubview(roomInputField)
    scrollView.addSubview(roomErrorField)

    scrollView.addSubview(joinRoomButton)
    scrollView.addSubview(createRoomButton)
    
    roomInputField.delegate = self
    
  }
  
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    scrollView.frame = view.bounds
    scrollView.backgroundColor = .white
    
    nameInputField.frame = CGRect(x: 30, 
                                  y: view.height/4,
                                  width: scrollView.width-60,
                                  height: 52)
    
    nameErrorField.frame = CGRect(x: 30, 
                                  y: nameInputField.bottom,
                                  width: scrollView.width-60,
                                  height: 20)

    roomInputField.frame = CGRect(x: 30, 
                                  y: nameInputField.bottom+50,
                                  width: scrollView.width-60,
                                  height: 52)
    
    roomErrorField.frame = CGRect(x: 30,
                                  y: roomInputField.bottom,
                                  width: scrollView.width-60,
                                  height: 20)
    
    joinRoomButton.frame = CGRect(x: 30,
                                  y: roomInputField.bottom+50,
                                  width: (scrollView.width/2) - 35,
                                  height: 52)
    
    createRoomButton.frame = CGRect(x: joinRoomButton.right+10,
                                    y: roomInputField.bottom+50,
                                    width: (scrollView.width/2) - 35,
                                    height: 52)
    }
}

// MARK: ERROR
extension HomeViewController {
  
  func handleNameError(_ errorString: String) {
    nameErrorField.text = errorString
    nameErrorField.isHidden = false
  }
  
  func handleRoomError(_ errorString: String) {
    roomErrorField.text = errorString
    roomErrorField.isHidden = false
  }
  
}


// MARK: FIRESTORE
extension HomeViewController {
  
  private func createRoomAndAddPlayer(roomNo: Int, player: Player) -> Bool {
    
    let roomDocRef = database.collection("rooms").document("\(roomNo)")
    var success = true
    roomDocRef.setData([
      "isRoomOpen": true,
      "players": FieldValue.arrayUnion([
        [
          "name": player.name,
          "cardsInHand": [],
          "points": player.points,
          "roundsJudged": player.roundsJudged,
          "roundsWon": player.roundsWon,
          "hasToPlay": player.hasToPlay
        ]
      ])
    ]) { err in
        if let err = err {
          print(err)
          let alertView = UIAlertController(title: "Cannot create room", message: "Something went wrong. Please try again", preferredStyle: .alert)
          let ok = UIAlertAction(title: "OK", style: .default) { _ in
          }
          alertView.addAction(ok)
          self.present(alertView, animated: true, completion: nil)
          success = false
        } else {
            print("Document successfully written!")
        }
    }
    return success
  }
  
  
  private func joinRoom(roomNo: Int, player: Player, completion: @escaping () -> Void) {
    let roomDocRef = database.collection("rooms").document("\(roomNo)")

    roomDocRef.getDocument { (document, error) in
      if let document = document, document.exists {
        // TODO: TESTING AND ADD ELSE FOR 289
//        if let isRoomOpen = document.data()?["isRoomOpen"] as? Bool, !isRoomOpen {
//          self.handleRoomError("Game already started by the host")
//        }
        
        if let players = document.data()?["players"] as? [[String: Any]],
          players.contains(where: { ($0["name"] as? String) == player.name }) {
          self.handleNameError("Player name already exists")
          return
        }
        
        else {
          roomDocRef.updateData([
            "players": FieldValue.arrayUnion([
              [
                "name": player.name,
                "cardsInHand": [],
                "points": player.points,
                "roundsJudged": player.roundsJudged,
                "roundsWon": player.roundsWon,
                "hasToPlay": player.hasToPlay
              ]
            ])
          ]) { err in
            if let err = err {
              print(err)
              let alertView = UIAlertController(title: "Cannot create room", message: "Something went wrong. Please try again", preferredStyle: .alert)
              let ok = UIAlertAction(title: "OK", style: .default) { _ in
              }
              alertView.addAction(ok)
              self.present(alertView, animated: true, completion: nil)
              
            } else {
              completion()
              print("Document successfully written!")
            }
          }
        }
      }
    }
  }
}


extension HomeViewController : UITextFieldDelegate {
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
          if textField == roomInputField {
              let allowedCharacters = CharacterSet.decimalDigits
              let characterSet = CharacterSet(charactersIn: string)
              return allowedCharacters.isSuperset(of: characterSet)
          }
          return true
      }
}
