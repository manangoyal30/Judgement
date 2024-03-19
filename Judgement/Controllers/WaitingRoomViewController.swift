//
//  WaitingRoomViewController.swift
//  Judgement
//
//  Created by manan.goyal on 28/2/2024.
//

import UIKit
import FirebaseFirestore

class WaitingRoomViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, 
                                 UIPickerViewDelegate, UIPickerViewDataSource {
  
  private let currentPlayer: Player
  
  private var roomNumber: Int
  
  private var nameTable: UITableView?
  
  private var totalRounds: Int = 1
  
  let database = Firestore.firestore()
    
  lazy var doc = database.collection("rooms").document("\(roomNumber)")
  
  var firestoreListener: ListenerRegistration?
  
  var playerNameList: [String] = []
  
  private let scrollView: UIScrollView = {
    let scrollView = UIScrollView()
    scrollView.clipsToBounds = true
    return scrollView
  }()
  
  private let roomLabel: UILabel = {
    let label = UILabel()
    label.backgroundColor = .clear
    label.isHidden = false
    label.font = .systemFont(ofSize: 32, weight: .bold)
    label.textColor = .blue
    return label
  }()
  
  private let roundLabel: UILabel = {
    let label = UILabel()
    label.backgroundColor = .clear
    label.isHidden = false
    label.font = .systemFont(ofSize: 16, weight: .bold)
    label.textColor = .systemGreen
    label.text = "Number of rounds"
    return label
  }()
  
  private var roundPicker: UIPickerView?
  
  var pickerData: [Int] = [1]
  
  private let startButton: UIButton = {
    let button = UIButton()
    button.setTitle("Start game", for: .normal)
    button.backgroundColor = .link
    button.setTitleColor(.white, for: .normal)
    button.layer.cornerRadius = 12
    button.layer.masksToBounds = true
    button.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
    // TODO: TESTING
    button.isHidden = false
    return button
  }()
  
  @objc private func startButtonTapped() {
    var scoreDictionary: [String: Int] = [:]
    for player in playerNameList {
      scoreDictionary[player] = 0
    }
    doc.updateData(["scoreBoard": scoreDictionary,
                    "isRoomOpen": false,
                    "totalRounds": totalRounds
                   ]
    ) { [weak self] error in
      guard let self else { return }
      if let error = error {
        print(error)
        let alertView = UIAlertController(title: "Cannot start game", message: "Something went wrong. Please try again", preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default) { _ in
        }
        alertView.addAction(ok)
        self.present(alertView, animated: true, completion: nil)
      }
    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    startButton.addTarget(
      self,
      action: #selector(startButtonTapped),
      for: .touchUpInside
    )
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    removeFirestoreListener()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupFirestoreListener()

    guard let nameTable, let roundPicker else { return }
    
    view.addSubview(scrollView)
    nameTable.layer.backgroundColor = .init(red: 0, green: 0, blue: 0, alpha: 1)
    nameTable.layer.borderWidth = 2.0
    scrollView.addSubview(roomLabel)
    scrollView.addSubview(nameTable)
    scrollView.addSubview(roundLabel)
    scrollView.addSubview(roundPicker)
    scrollView.addSubview(startButton)
    
    roundPicker.delegate = self
    roundPicker.dataSource = self
    
    nameTable.dataSource = self
    nameTable.delegate = self
    nameTable.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    scrollView.frame = view.bounds
    
    roomLabel.text = String(roomNumber)
    roomLabel.frame = CGRect(x: scrollView.width/3 + 20,
                             y: (view.height/6) - 100,
                             width: scrollView.width-60,
                             height: 52)
    
    nameTable?.frame = CGRect(x: 30,
                             y: roomLabel.bottom + 20,
                             width: scrollView.width-60,
                             height: 250)
    
    roundLabel.frame = CGRect(x: (scrollView.width/3) - 10,
                             y: roomLabel.bottom + 300,
                             width: scrollView.width-60,
                             height: 24)
    
    roundPicker?.frame = CGRect(x: (scrollView.width/3) - 10,
                             y: roomLabel.bottom + 300,
                             width: scrollView.width-240,
                             height: 100)
    
    
    startButton.frame = CGRect(x: 80,
                               y: roomLabel.bottom+450,
                               width: (scrollView.width/2)+20,
                               height: 52)
    
    scrollView.backgroundColor = .white
  }
  
  
  init(roomNumber: Int, currentPlayer: Player) {
    self.roomNumber = roomNumber
    self.currentPlayer = currentPlayer
    self.nameTable = UITableView()
    self.roundPicker = UIPickerView()
    self.roundPicker?.isHidden = true
    self.roundLabel.isHidden = true
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

extension WaitingRoomViewController {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return playerNameList.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
    cell.textLabel?.text = playerNameList[indexPath.row]
    return cell
  }
  
  func setupFirestoreListener() {
      // Register the Firestore listener
      firestoreListener = Firestore.firestore().collection("rooms").document("\(roomNumber)")
          .addSnapshotListener { querySnapshot, error in
            guard let document = querySnapshot else {
                print("No room number found")
                return
            }
            guard let data = document.data() else {
                print("Document data was empty.")
                return
            }
            if let players = data["players"] as? [[String: Any]] {
              let playerNameList = players.compactMap { $0["name"] as? String }
              self.playerNameList = playerNameList
              let maxPickerValue = min(Int(floor(51.0 / Double(playerNameList.count))), 10)
              self.pickerData = Array(1...maxPickerValue)
              self.roundPicker?.reloadAllComponents()
              self.nameTable?.reloadData()
              
              if playerNameList.count > 1 && self.currentPlayer.name == playerNameList[0] {
                self.startButton.isHidden = false
                self.roundPicker?.isHidden = false
                self.roundLabel.isHidden = false
                self.view.layoutIfNeeded()
              }
            } else {
              self.playerNameList = ["No players found"]
            }
            if let isRoomOpen = data["isRoomOpen"] as? Bool, !isRoomOpen {
              let gameRoomViewController = GameRoom(roomNumber: self.roomNumber, currentPlayer: self.currentPlayer)
              self.navigationController?.pushViewController(gameRoomViewController, animated: true)
            }
          }
      }
  
  func removeFirestoreListener() {
          // Remove the Firestore listener
          firestoreListener?.remove()
      }
}

extension WaitingRoomViewController {
  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 1 // We're using a single column
  }

  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return pickerData.count
  }
  
  func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    return "\(pickerData[row])"
  }

  func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    totalRounds = pickerData[row]
  }
}
