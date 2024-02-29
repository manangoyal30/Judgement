//
//  WaitingRoomViewController.swift
//  Judgement
//
//  Created by manan.goyal on 28/2/2024.
//

import UIKit
import FirebaseFirestore

class WaitingRoomViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
  
  private var roomNumber: Int
  
  private var nameList: UITableView?
  
  let database = Firestore.firestore()
    
  lazy var doc = database.collection("rooms").document("\(roomNumber)")
  
  var name: [String] = []
  
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
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    guard let nameList else { return }

    view.addSubview(scrollView)
    
    self.navigationItem.setHidesBackButton(true, animated: true)

    scrollView.addSubview(nameList)
    scrollView.addSubview(roomLabel)
    
    nameList.dataSource = self
    nameList.delegate = self
    nameList.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")

    doc.addSnapshotListener { (querySnapshot, error) in
      guard let document = querySnapshot else {
        print("No room number found")
        return
      }
      
      guard let data = document.data() else {
        print("Document data was empty.")
        return
      }
      
      self.name = data["players"] as? [String] ?? ["Empty list"]
      nameList.reloadData()

    }
  }
  
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    scrollView.frame = view.bounds
    
    roomLabel.text = String(roomNumber)
    roomLabel.frame = CGRect(x: scrollView.width/3 + 20,
                             y: view.height/6,
                             width: scrollView.width-60,
                             height: 52)
    
    nameList?.frame = CGRect(x: 30,
                             y: roomLabel.bottom + 20,
                             width: scrollView.width-60,
                             height: 200)
    scrollView.backgroundColor = .white
  }
  
  
  init(roomNumber: Int) {
    self.roomNumber = roomNumber
    self.nameList = UITableView()
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}

extension WaitingRoomViewController {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return name.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
    cell.textLabel?.text = name[indexPath.row]
    return cell
  }
}
