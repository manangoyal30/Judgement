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
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.addSubview(scrollView)
    
    guard let nameList else { return }
    scrollView.addSubview(nameList)
    
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
    nameList?.frame = scrollView.bounds
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
