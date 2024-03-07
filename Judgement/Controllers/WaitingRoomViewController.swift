//
//  WaitingRoomViewController.swift
//  Judgement
//
//  Created by manan.goyal on 28/2/2024.
//

import UIKit
import FirebaseFirestore

class WaitingRoomViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
  
  private let currentPlayer: Player
  
  private var roomNumber: Int
  
  private var nameTable: UITableView?
  
  let database = Firestore.firestore()
    
  lazy var doc = database.collection("rooms").document("\(roomNumber)")
  
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
  
  private let startButton: UIButton = {
    let button = UIButton()
    button.setTitle("Start game", for: .normal)
    button.backgroundColor = .link
    button.setTitleColor(.white, for: .normal)
    button.layer.cornerRadius = 12
    button.layer.masksToBounds = true
    button.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
    button.isHidden = true
    return button
  }()
  
  @objc private func startButtonTapped() {
    var scoreDictionary: [String: Int] = [:]
    for player in playerNameList {
      scoreDictionary[player] = 0
    }
    doc.updateData(["scoreBoard": scoreDictionary,
                    "isRoomOpen" : false
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
      } else {
        let gameRoomViewController = GameRoom(roomNumber: roomNumber, currentPlayer: currentPlayer)
        self.navigationController?.pushViewController(gameRoomViewController, animated: true)
      }
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    startButton.addTarget(
      self,
      action: #selector(startButtonTapped),
      for: .touchUpInside
    )
    
    guard let nameTable else { return }

    view.addSubview(scrollView)
    nameTable.layer.backgroundColor = .init(red: 0, green: 0, blue: 0, alpha: 1)
    nameTable.layer.borderWidth = 2.0
    scrollView.addSubview(nameTable)
    scrollView.addSubview(roomLabel)
    scrollView.addSubview(startButton)
    
    nameTable.dataSource = self
    nameTable.delegate = self
    nameTable.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    
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
          let playerNameList = players.compactMap { $0["name"] as? String }
          self.playerNameList = playerNameList
          self.nameTable?.reloadData()
          
          if playerNameList.count > 1 && self.currentPlayer.name == playerNameList[0] {
            self.startButton.isHidden = false
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
                             height: 300)
    
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
}
