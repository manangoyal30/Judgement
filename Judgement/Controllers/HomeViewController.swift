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
  
  
  @objc private func createRoomButtonTapped() {
    roomInputField.resignFirstResponder()
    let randomID = Int.random(in: 1000..<10000)
        
        // Get the player's name from the text field
        guard let playerName = nameInputField.text, !playerName.isEmpty else {
            print("Player name is empty")
            return
        }
        
        // Create a new document with the random ID
    database.collection("rooms").document("\(randomID)").setData([
            "players": [playerName] // Add the player's name to the players list
            // Add any other room details here
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
            }
        }
    
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    createRoomButton.addTarget(
      self,
      action: #selector(createRoomButtonTapped),
      for: .touchUpInside
    )
    
    view.addSubview(scrollView)
    scrollView.addSubview(nameInputField)
    scrollView.addSubview(roomInputField)
    scrollView.addSubview(joinRoomButton)

    scrollView.addSubview(createRoomButton)
    
    roomInputField.delegate = self
    
  }
  
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    scrollView.frame = view.bounds
    scrollView.backgroundColor = .white
    
    nameInputField.frame = CGRect(x: 30, y: view.height/3,
                                   width: scrollView.width-60,
                                   height: 52)

    roomInputField.frame = CGRect(x: 30, y: nameInputField.bottom+50,
                                   width: scrollView.width-60,
                                   height: 52)
    
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
