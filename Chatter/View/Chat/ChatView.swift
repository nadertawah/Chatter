//
//  ChatView.swift
//  Chatter
//
//  Created by Nader Said on 12/07/2022.
//

import UIKit
import RxSwift

class ChatView: UIViewController
{
    //MARK: - IBOutlet(s)
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var sendBTN: UIButton!
    
    @IBOutlet weak var messageTF: UITextField!
    {
        didSet
        {
            messageTF.layer.cornerRadius = 15
            let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
            messageTF.leftViewMode = .always
            messageTF.leftView = paddingView
        }
    }
    
    @IBOutlet weak var cameraBtn: UIButton!
            
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        setUI()
    }
    
    init(chatWith : User)
    {
        VM = ChatVM(chatWith)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }

    
    //MARK: - IBAction(s)
    @objc private func avatarPressed()
    {
        
    }
    
    @IBAction func cameraBTNPressed(_ sender: UIButton)
    {
        present(imgController, animated: true)
    }
    
    @IBAction func sendBTNPressed(_ sender: UIButton)
    {
        VM.sendMessage(messageContent: messageTF.text ?? "",type: .text)
        messageTF.text = ""
        sendBTN.alpha = 0
        cameraBtn.alpha = 1
    }
   
    @IBAction func messageTFChanged(_ sender: UITextField)
    {
        if messageTF.text == ""
        {
            sendBTN.alpha = 0
            cameraBtn.alpha = 1

        }
        else
        {
            cameraBtn.alpha = 0
            sendBTN.alpha = 1

        }
    }
    
    //MARK: - Var(s)
    var VM : ChatVM!
    let bag = DisposeBag()
    let imgController = UIImagePickerController()
    
    
    //MARK: - Helper Funcs
    func setUI()
    {
        //set navBar
        setNavBar()
        
        //Register Cells
        tableView.register(UINib(nibName: MessageCell.reuseIdentfier, bundle: nil), forCellReuseIdentifier: MessageCell.reuseIdentfier)
        tableView.register(UINib(nibName: ImgMessageCell.reuseIdentfier, bundle: nil), forCellReuseIdentifier: ImgMessageCell.reuseIdentfier)
        
        //set image controller delegate
        imgController.delegate = self
        
        //Bind VM
        bindVM()
        
        //set did selcet row at
        tableView.rx.itemSelected.subscribe(onNext:
        {
            [weak self] indexPath in
            guard let self = self else {return}
            
            let message = self.VM.messages.value[indexPath.row]
            if message.type == .image
            {
                if let localFileURL = self.VM.imgFileUrl(index: indexPath.row)
                {
                    guard let img = UIImage(contentsOfFile: localFileURL.path) else {return}
                    let imgViewerVC = ImageViewerView(img: img)
                    self.navigationController?.pushViewController(imgViewerVC, animated: true)
                }
            }
            
            
        }).disposed(by: bag)
    }
    
    @objc private func back()
    {
        self.dismiss(animated: true)
    }
    
    func setNavBar()
    {
        self.navigationController?.navigationBar.prefersLargeTitles = false
        let backBtn = UIBarButtonItem(image: UIImage(systemName: "chevron.left")?.withTintColor(Constants.chatterGreyColor, renderingMode: .alwaysOriginal), style: .done, target: self, action: #selector(back))
        
        let height = self.navigationController!.navigationBar.frame.height
        let avatarView = UIButton(frame: CGRect(x: 0, y: 0, width: height, height: height))
        avatarView.layer.cornerRadius = height / 2
        avatarView.setImage(UIImage.imageFromString(imgSTR: VM.otherUser.avatar)?.resizeImageTo(size: CGSize(width: height, height: height))?.circleMasked, for: .normal)
        avatarView.addTarget(self, action: #selector(avatarPressed), for: .touchUpInside)
        
        let avatar = UIBarButtonItem(customView: avatarView)
        
        let friendName = UIBarButtonItem(title: VM.otherUser.fullName, style: .done, target: nil, action: nil)
        friendName.tintColor = Constants.chatterGreyColor
        
        self.navigationController?.navigationBar.topItem?.setLeftBarButtonItems([backBtn, avatar,friendName], animated: true)
    }
    
    func bindVM()
    {
        VM.messages.bind(to: tableView.rx.items)
        {
            [weak self] (tv, row, item) -> UITableViewCell in
            guard let self = self else {return UITableViewCell()}
            let isOutGoingMessage = self.VM.messages.value[row].senderId == Helper.getCurrentUserID()
            let message = self.VM.messages.value[row]
            
            switch message.type
            {
            case .text:
                
                guard let cell = self.tableView.dequeueReusableCell(withIdentifier: MessageCell.reuseIdentfier) as? MessageCell
                else {return UITableViewCell()}
                
                cell.msgLabel.text = message.message
                cell.timeStampLabel.text = message.date.chatterTimeStamp()
                
                if isOutGoingMessage
                {
                    cell.backView.backgroundColor = Constants.chatterGreyColor
                    cell.msgLabel.textColor = .white
                    cell.timeStampLabel.textColor = .white
                    cell.trailingBackView.isActive = true
                    cell.leadingBackView.isActive = false
                }
                else
                {
                    cell.backView.backgroundColor = .white
                    cell.msgLabel.textColor = Constants.chatterGreyColor
                    cell.timeStampLabel.textColor = Constants.chatterGreyColor
                    cell.trailingBackView.isActive = false
                    cell.leadingBackView.isActive = true
                }
                
                return cell
                
            case .image:
                
                guard let cell = self.tableView.dequeueReusableCell(withIdentifier: ImgMessageCell.reuseIdentfier) as? ImgMessageCell
                else {return UITableViewCell()}
                
                cell.timeStampLabel.text = message.date.chatterTimeStamp()
                
                if let localFileURL = self.VM.imgFileUrl(index: row)
                {
                    cell.imgView.image = UIImage(contentsOfFile: localFileURL.path)?.resizeImageTo(size: CGSize(width: 200, height: 200))
                    cell.progressBar.isHidden = true
                }
                else
                {
                    self.VM.downloadImg(index: row)
                    {
                        progress in
                        cell.progressBar.progress = progress
                    }
                    completion:
                    {
                        img in
                        cell.imgView.image = img
                        cell.progressBar.isHidden = true
                    }
                }
                
                if isOutGoingMessage
                {
                    cell.backView.backgroundColor = Constants.chatterGreyColor
                    cell.trailingBackView.isActive = true
                    cell.leadingBackView.isActive = false
                    cell.timeStampLabel.textColor = .white
                    self.indicator.stopAnimating()
                }
                else
                {
                    cell.backView.backgroundColor = .white
                    cell.trailingBackView.isActive = false
                    cell.leadingBackView.isActive = true
                    cell.timeStampLabel.textColor = Constants.chatterGreyColor
                }
                return cell
                
            default:
                return UITableViewCell()
            }
        }.disposed(by: bag)
        
        VM.messages.subscribe
        {
            [weak self] _ in
            guard let self = self else {return}
            DispatchQueue.main.async
            {
                if !self.VM.messages.value.isEmpty
                {
                    self.tableView.scrollToRow(at: IndexPath.init(row: (self.VM.messages.value.count) - 1, section: 0), at: .bottom, animated: false)
                }
            }
        }.disposed(by: bag)
    }
    
    
}

//MARK: - image picker delegate funcs
extension ChatView : UIImagePickerControllerDelegate ,UINavigationControllerDelegate
{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
    {
        if let imagePicked = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        {
            self.indicator.startAnimating()
            self.indicator.isHidden = false
            self.VM.uploadImage(image: imagePicked)
        }
        picker.dismiss(animated: true)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
        picker.dismiss(animated: true)
    }
    
}
