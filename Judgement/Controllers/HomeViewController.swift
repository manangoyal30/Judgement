//
//  HomeViewController.swift
//  Judgement
//
//  Created by manan.goyal on 9/2/2024.
//

import UIKit

class HomeViewController: UIViewController {
  
  private let scrollView: UIScrollView = {
          let scrollView = UIScrollView()
          scrollView.clipsToBounds = true
          return scrollView
      }()
  
  private let roomInputField: UITextField = {
         let field = UITextField()
         field.autocapitalizationType = .none
         field.autocorrectionType = .no
         field.returnKeyType = .continue
         field.layer.cornerRadius = 12
         field.layer.borderWidth = 1
         field.layer.borderColor = UIColor.lightGray.cgColor
         field.placeholder = "Enter Room Number..."
         field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
         field.leftViewMode = .always
         field.backgroundColor = .secondarySystemBackground
         return field
     }()
  
  private let createRoomButton: UIButton = {
          let button = UIButton()
          button.setTitle("Create Room", for: .normal)
          button.backgroundColor = .link
          button.setTitleColor(.white, for: .normal)
          button.layer.cornerRadius = 12
          button.layer.masksToBounds = true
          button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
          return button
      }()

  override func viewDidLoad() {
    super.viewDidLoad()
    
  }

  loginButton.addTarget(
              self,
              action: #selector(loginButtonTapped),
              for: .touchUpInside
          )
  
  view.addSubview(scrollView)
  scrollView.addSubview(roomInputField)
  scrollView.addSubview(createRoomButton)
  

}
