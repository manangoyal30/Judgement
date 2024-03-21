//
//  CardView.swift
//  Judgement
//
//  Created by manan.goyal on 20/3/2024.
//

import UIKit

class CardCell: UICollectionViewCell {
    var imageView: UIImageView?

    override init(frame: CGRect) {
        super.init(frame: frame)

        imageView = UIImageView(frame: self.contentView.bounds)
        imageView?.contentMode = .scaleAspectFit
        if let imageView = imageView {
            self.contentView.addSubview(imageView)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
