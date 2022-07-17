//
//  LoginRegisterView.swift
//  Chatter
//
//  Created by Nader Said on 12/07/2022.
//

import UIKit

class LoginRegisterView: UIViewController
{

    //MARK: - IBOutlet(s)
    @IBOutlet weak var avatarIMG: UIImageView!
    
    @IBOutlet weak var NameTF: UITextField!
    
    @IBOutlet weak var EmailTF: UITextField!
    
    @IBOutlet weak var PasswordTF: UITextField!
    
    @IBOutlet weak var loginRegisterBtn: UIButton!
    {
        didSet
        {loginRegisterBtn.layer.cornerRadius = 5}
    }
    
    @IBOutlet weak var SwipeLBL: UILabel!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        setUI()
    }
    
    //MARK: - IBAction(s)
    
    @IBAction func emailTfChanged(_ sender: UITextField)
    {
        sender.text = sender.text?.lowercased()
    }
    
    @IBAction func loginRegisterBtnPressed(_ sender: UIButton)
    {
        if !EmailTF.text!.isEmpty && !PasswordTF.text!.isEmpty
                {
                    if SwipeLBL.text == "Swipe to Login"
                    {
                        if NameTF.text!.isEmpty || selectedImg == nil
                        {
                            self.showAlert(title: "Error", msg: "All fields are required including the picture!")
                        }
                        else
                        {
                            //Register new user
                            VM.register(name: NameTF.text!, email: EmailTF.text!, password: PasswordTF.text!, avatar: selectedImg ?? UIImage())
                            { [weak self]
                                result , error in
                                if result != nil
                                {
                                    self?.showAlert(title: "Success", msg: "Registerd! Swipe to Login.")
                                }
                                else
                                {
                                    self?.showAlert(title: "Error", msg:  error!.localizedDescription)
                                }
                            }
                        }
                    }
                    else
                    {
                        //Login
                        VM.login(EmailTF.text!, PasswordTF.text!)
                        { [weak self]
                            result , error in
                            guard let self = self else {return}
                            if result != nil
                            {
                                let vc = BaseTabBar()
                                vc.modalPresentationStyle = .fullScreen
                                self.present(vc, animated: true)
                            }
                            else
                            {
                                self.showAlert(title: "Error", msg: error!.localizedDescription)
                            }
                        }
                        
                    }
                }
               else
               {
                   self.showAlert(title: "Error", msg: "All fields are required including the picture!")
               }
    }
    
    
    //MARK: - Var(s)
    var VM = LoginRegisterVM()
    var selectedImg : UIImage?
    var avatarTapGestureRecogniser = UITapGestureRecognizer()
    let imgController = UIImagePickerController()
    
    //MARK: - Helper Funcs
    private func setUI()
    {
        //set textfields placeholders
        NameTF.attributedPlaceholder = placeHolderString(str: "Name")
        EmailTF.attributedPlaceholder = placeHolderString(str: "Email")
        PasswordTF.attributedPlaceholder = placeHolderString(str: "Password")
        
        //set textfields corner raduis
        NameTF.layer.cornerRadius = 5
        EmailTF.layer.cornerRadius = 5
        PasswordTF.layer.cornerRadius = 5
        
        //swipe to login/register
        let rightSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(self.swipe))
        rightSwipeGesture.direction = .right
        
        let lefttSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(self.swipe))
        lefttSwipeGesture.direction = .left
        
        //add gestures recogniser
        self.view.addGestureRecognizer(rightSwipeGesture)
        self.view.addGestureRecognizer(lefttSwipeGesture)
        self.hideKeyboardWhenTappedAround()
        
        //tap to choose avatar image
        avatarIMG.isUserInteractionEnabled = true
        avatarTapGestureRecogniser = UITapGestureRecognizer(target: self, action: #selector(self.avatarPressed))
        self.avatarIMG.addGestureRecognizer(avatarTapGestureRecogniser)
        
        imgController.delegate = self
    }
    
    private func placeHolderString(str: String) -> NSAttributedString
    {
        NSAttributedString(string: str , attributes: [NSAttributedString.Key.foregroundColor : UIColor.white.withAlphaComponent(0.7)])
    }
    
    @objc func swipe()
    {
        if SwipeLBL.text == "Swipe to Login"
        {
            UIView.transition(with: self.view, duration: 0.5, options: [.transitionFlipFromLeft], animations: {
                [weak self] in
                self?.NameTF.alpha = 0
                self?.loginRegisterBtn.setTitle("Sign In", for: .normal)
                self?.SwipeLBL.text = "Swipe to Register"
                self?.avatarIMG.alpha = 0
            })
        }
        else
        {
            UIView.transition(with: self.view, duration: 0.5, options: [.transitionFlipFromRight], animations: {
                [weak self] in
                self?.loginRegisterBtn.setTitle("Sign Up", for: .normal)
                self?.NameTF.alpha = 1
                self?.SwipeLBL.text = "Swipe to Login"
                self?.avatarIMG.alpha = 1
            })
        }
    }
    
    @objc func avatarPressed()
    {
        present(imgController, animated: true)
    }
}

//MARK: - Image Picker delegate funcs
extension LoginRegisterView : UIImagePickerControllerDelegate , UINavigationControllerDelegate
{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let imagePicked = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        {
            avatarIMG.image = imagePicked.circleMasked
            selectedImg = imagePicked
        }
        picker.dismiss(animated: true)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
        picker.dismiss(animated: true)
    }
}
