//
//  ImageViewerView.swift
//  Chatter
//
//  Created by nader said on 14/07/2022.
//

import UIKit

class ImageViewerView: UIViewController
{

    //MARK: - IBOutlet(s)
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        imageView.image = image
    }

    init(img : UIImage)
    {
        image = img
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Var(s)
    var image : UIImage!
}
