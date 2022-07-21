//
//  ChatView.swift
//  Chatter
//
//  Created by Nader Said on 12/07/2022.
//

import UIKit
import RxSwift
import AVFAudio
import AVFoundation

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
    
    @IBOutlet weak var keyboardConstriant: NSLayoutConstraint!
    
    @IBOutlet weak var navBar: UINavigationBar!
    
    @IBOutlet weak var voiceNoteTimerLabel: UILabel!
    
    @IBOutlet weak var flashingMicImgView: UIImageView!
    
    @IBOutlet weak var textMsgViewTrailingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var micBtn: UIButton!
    
    @IBOutlet weak var textMsgViewWidth: NSLayoutConstraint!
    
    @IBOutlet weak var textFieldTrailingConstraint: NSLayoutConstraint!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        setUI()
        checkRecordPermission()
    }
    override func viewWillAppear(_ animated: Bool)
    {
        //add keyboard observer to apply animation
        NotificationCenter.default.addObserver(self,selector: #selector(keyboardWillShow),name: UIResponder.keyboardWillShowNotification,object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        //set navBar
        setNavBar()
        
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        //remove the observers
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification , object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification , object: nil)
        
        //revert navbar and tabbar changes
        self.tabBarController?.tabBar.isHidden = false
        self.navigationController?.navigationBar.isHidden = false
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
        guard let img = UIImage.imageFromString(imgSTR:VM.otherUser.value.avatar)  else {return}
        
        let imgViewerVC = ImageViewerView(img: img)
        
        self.navigationController?.pushViewController(imgViewerVC, animated: true)
    }
    
    @IBAction func cameraBTNPressed(_ sender: UIButton)
    {
        present(imgController, animated: true)
    }
    
    @IBAction func sendBTNPressed(_ sender: UIButton)
    {
        VM.sendMessage(messageContent: messageTF.text ?? "",type: .text)
        messageTF.text = ""
        updateBottomViewUi()
    }
   
    
    @IBAction func messageTFChanged(_ sender: UITextField)
    {
        updateBottomViewUi()
    }
   
    @IBAction func recordDragedToLock(_ sender: UIButton)
    {
        recorderIsLocked = true
    }
    
    @IBAction func stopVoiceRecord(_ sender: UIButton)
    {
        stopRecord()
        recorderIsLocked = false
    }
        
    @IBAction func startVoiceRecord(_ sender: UIButton)
    {
        if !recorderIsLocked
        {
            record()
        }
    }
    
    //MARK: - Var(s)
    var VM : ChatVM!
    let bag = DisposeBag()
    let imgController = UIImagePickerController()
    var audioRecorder: AVAudioRecorder?
    var audioPlayer = AVAudioPlayer()
    var isAudioRecordingGranted : Bool = false
    var timer : Timer!
    var currentPlayingCellIndex : Int!
    var recorderIsLocked = false
    var recordPulseAnimationLayer : CAShapeLayer!
    
    //MARK: - Helper Funcs
    func setUI()
    {
        //set image controller presentation style
        imgController.modalPresentationStyle = .overFullScreen
        
        //hide keyboard
        self.hideKeyboardWhenTappedAround()
               
        //Register Cells
        tableView.register(UINib(nibName: MessageCell.reuseIdentfier, bundle: nil), forCellReuseIdentifier: MessageCell.reuseIdentfier)
        tableView.register(UINib(nibName: ImgMessageCell.reuseIdentfier, bundle: nil), forCellReuseIdentifier: ImgMessageCell.reuseIdentfier)
        tableView.register(UINib(nibName: VoiceNoteMessageCell.reuseIdentfier, bundle: nil), forCellReuseIdentifier: VoiceNoteMessageCell.reuseIdentfier)
        tableView.register(UINib(nibName: SystemMessageCell.reuseIdentfier, bundle: nil), forCellReuseIdentifier: SystemMessageCell.reuseIdentfier)

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
                if let localFileURL = self.VM.imgFileUrl(message: message)
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
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func keyboardWillShow(_ notification: Notification)
    {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
        {
            DispatchQueue.main.async
            {[weak self] in
                guard let self = self else {return}
                self.keyboardConstriant.constant = keyboardFrame.cgRectValue.height - self.view.safeAreaInsets.bottom
                self.view.layoutIfNeeded()
                self.scrollToBottom()
            }
        }
    }
    
    @objc func keyboardWillDisappear(notification: NSNotification?)
    {
        DispatchQueue.main.async
        {[weak self] in
            guard let self = self else {return}
            self.keyboardConstriant.constant = 0.0
        }
    }
    
    func setNavBar()
    {
        //hide tabbar
        self.tabBarController?.tabBar.isHidden = true
        
        //hide navbar
        self.navigationController?.navigationBar.isHidden = true

        //set nav btns
        let height = navBar.frame.height

        //back button
        let backBtn = UIBarButtonItem(image: UIImage(systemName: "chevron.left")?.withTintColor(UIColor.chatterGreyColor, renderingMode: .alwaysOriginal), style: .done, target: self, action: #selector(back))
        
        //avatar image
        let avatarView = UIButton(frame: CGRect(x: 0, y: 0, width: height, height: height))
        avatarView.layer.cornerRadius = height / 2
        avatarView.addTarget(self, action: #selector(avatarPressed), for: .touchUpInside)
        let avatar = UIBarButtonItem(customView: avatarView)
        
        //name and online status
        let onlineView = OnlineStatusView(frame: CGRect(x: 0, y: 0, width: 200, height: height))
        onlineView.setName(VM.otherUser.value.fullName)
        let friendNameBtn = UIBarButtonItem(customView: onlineView)
        
        navBar.topItem?.setLeftBarButtonItems([backBtn, avatar,friendNameBtn], animated: true)
        
        //bind friend avatar
        VM.otherUser.subscribe
        {
            guard let friend = $0.element else {return}
            let img = UIImage.imageFromString(imgSTR: friend.avatar)?.resizeImageTo(size: CGSize(width: height, height: height))?.circleMasked
            avatar.changeCustomBarBtnImage(img:  img)
        }.disposed(by: bag)
        
        //bind online status
        VM.isOnline.subscribe
        { isOnline in
            UIView.animate(withDuration: 0.5)
            {
                onlineView.onlineLabel.alpha = isOnline ? 1 : 0
            }
        }.disposed(by: bag)
    }
    
    func bindVM()
    {
        VM.messages.bind(to: tableView.rx.items)
        {
            [weak self] (tv, row, item) -> UITableViewCell in
            guard let self = self else {return UITableViewCell()}
            let message = self.VM.messages.value[row]
            
            switch message.type
            {
            case .text:
                return self.configureTextMessageCell(message)
                
            case .image:
                return self.configureImgMessageCell(message)
                
            case .audio:
                return self.configureVoiceNoteMessageCell(row)
            
            case .system:
                return self.configureSystemMessageCell(message)
                
            default:
                return UITableViewCell()
            }
        }.disposed(by: bag)
        
        VM.messages.subscribe
        {
            [weak self] _ in
            guard let self = self else {return}
            self.scrollToBottom()
        }.disposed(by: bag)
    }
    func configureSystemMessageCell(_ message : Message) -> SystemMessageCell
    {
        guard let cell = self.tableView.dequeueReusableCell(withIdentifier: SystemMessageCell.reuseIdentfier) as? SystemMessageCell
        else {return SystemMessageCell()}
        
        let str = NSAttributedString(string: message.message, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12)])
        
        cell.msgBtn.setAttributedTitle(str, for: .normal)
        return cell
    }
    func configureTextMessageCell(_ message : Message) -> MessageCell
    {
        guard let cell = self.tableView.dequeueReusableCell(withIdentifier: MessageCell.reuseIdentfier) as? MessageCell
        else {return MessageCell()}
        
        cell.msgLabel.text = message.message
        cell.timeStampLabel.text = message.date.chatterTimeStamp()
        
        if message.isOutgoing
        {
            cell.backView.backgroundColor = UIColor.chatterGreyColor
            cell.msgLabel.textColor = .white
            cell.timeStampLabel.textColor = .white
            cell.trailingBackView.isActive = true
            cell.leadingBackView.isActive = false
        }
        else
        {
            cell.backView.backgroundColor = .white
            cell.msgLabel.textColor = UIColor.chatterGreyColor
            cell.timeStampLabel.textColor = UIColor.chatterGreyColor
            cell.trailingBackView.isActive = false
            cell.leadingBackView.isActive = true
        }
        return cell
    }
    
    func configureImgMessageCell(_ message : Message) -> ImgMessageCell
    {
        guard let cell = self.tableView.dequeueReusableCell(withIdentifier: ImgMessageCell.reuseIdentfier) as? ImgMessageCell
        else {return ImgMessageCell()}
        
        cell.timeStampLabel.text = message.date.chatterTimeStamp()
        
        if let localFileURL = self.VM.imgFileUrl(message: message)
        {
            cell.imgView.image = UIImage(contentsOfFile: localFileURL.path)?.resizeImageTo(size: CGSize(width: 200, height: 200))
            cell.progressBar.isHidden = true
        }
        else
        {
            self.VM.downloadImg(message: message)
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
        
        if message.isOutgoing
        {
            cell.backView.backgroundColor = UIColor.chatterGreyColor
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
            cell.timeStampLabel.textColor = UIColor.chatterGreyColor
        }
        return cell
    }
    
    func configureVoiceNoteMessageCell(_ row : Int) -> VoiceNoteMessageCell
    {
        guard let cell = self.tableView.dequeueReusableCell(withIdentifier: VoiceNoteMessageCell.reuseIdentfier) as? VoiceNoteMessageCell
        else {return VoiceNoteMessageCell()}
        
        cell.playPauseBtn.tag = row
        cell.playPauseBtn.addTarget(self, action: #selector(voiceNotePlayPauseBtnPressed(_:)), for: .touchUpInside)
        cell.durationLabel.text = self.VM.messages.value[row].duration?.timeString
        
        if VM.messages.value[row].isOutgoing
        {
            cell.backView.backgroundColor = UIColor.chatterGreyColor
            cell.backViewTrailingConstraint.isActive = true
            cell.backViewLeadingConstraint.isActive = false
        }
        else
        {
            cell.backView.backgroundColor = .white
            cell.backViewTrailingConstraint.isActive = false
            cell.backViewLeadingConstraint.isActive = true
        }
        return cell
    }
    
    func scrollToBottom()
    {
        DispatchQueue.main.async
        {
            if !self.VM.messages.value.isEmpty
            {
                self.tableView.scrollToRow(at: IndexPath.init(row: (self.VM.messages.value.count) - 1, section: 0), at: .bottom, animated: false)
            }
        }
    }
    
    func updateLayoutWithAnimation()
    {
        UIView.animate(withDuration: 0.5)
        {[weak self] in
            guard let self = self else { return }
            self.view.layoutIfNeeded()
        }
    }
    
    func updateBottomViewUi()
    {
        //update bottom view ui
        UIView.animate(withDuration: 0.5, delay: 0)
        {
            [weak self] in
            guard let self = self else { return }
            
            if self.messageTF.text == ""
            {
                self.sendBTN.alpha = 0
                self.cameraBtn.alpha = 1
                self.micBtn.alpha = 1
                self.textFieldTrailingConstraint.isActive = false
            }
            else
            {
                self.micBtn.alpha = 0
                self.cameraBtn.alpha = 0
                self.sendBTN.alpha = 1
                self.textFieldTrailingConstraint.isActive = true
            }
            self.view.layoutIfNeeded()
        }
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

//MARK: - Audio section
extension ChatView
{
    func checkRecordPermission()
    {
        switch AVAudioSession.sharedInstance().recordPermission
        {
        case AVAudioSession.RecordPermission.granted :
            isAudioRecordingGranted = true
            break
        case AVAudioSession.RecordPermission.denied :
            isAudioRecordingGranted = false
            break
        default:
            break
        }
    }
    
    func record()
    {
        do
        {
            if isAudioRecordingGranted
            {
                let audioSession = AVAudioSession.sharedInstance()
                try audioSession.setCategory(.record)
                try audioSession.setActive(true)

                let url = FileManager.tempVoiceNoteDir()

                let recordSettings =
                [
                    AVFormatIDKey : kAudioFormatMPEG4AAC as NSNumber,
                    AVSampleRateKey : AVAudioSession.sharedInstance().sampleRate as NSNumber,
                    AVNumberOfChannelsKey : 1 as NSNumber,
                    AVEncoderBitRatePerChannelKey : 96 * 1_000 as NSNumber,
                    AVEncoderAudioQualityKey: AVAudioQuality.max.rawValue as NSNumber
                ] as [String : Any]

                audioRecorder = try AVAudioRecorder(url: url, settings: recordSettings)
                audioRecorder?.record()
                
                showRecorderView()
            }
            else
            {
                AVAudioSession.sharedInstance().requestRecordPermission({[weak self] in self?.isAudioRecordingGranted = $0})
            }
        }
        catch
        {
            print("Failed to record!")
        }
    }
    
    func stopRecord()
    {
        if audioRecorder?.isRecording == true
        {
            if let duration = audioRecorder?.currentTime
            {
                audioRecorder?.stop()
                audioRecorder = nil
                hideRecorderView()
                
                VM.uploadVoiceNote(duration:duration )
            }
        }
    }
    
    func showRecorderView()
    {
        
        //show recording view
        self.textMsgViewTrailingConstraint.constant = textMsgViewWidth.constant  + Constants.screenWidth
        updateLayoutWithAnimation()
        
        //show stop button
        micBtn.setImage(UIImage(systemName: "stop.fill"), for: .normal)
        micBtn.tintColor = .red
        
        //set flashing mic animation
        UIView.animate(withDuration: 1, delay: 0, options: [.repeat,.autoreverse])
        {
            [weak self] in
            guard let self = self else { return }
            self.flashingMicImgView.alpha = 0
        }
        
        //start timer
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateRecordingTimer), userInfo: nil, repeats: true)
        
        //show pulse animation
        createRecorderPulseAnimation()
    }
    
    @objc func updateRecordingTimer()
    {
        if audioRecorder?.isRecording == true
        {
            let min = Int((self.audioRecorder?.currentTime ?? 0) / 60)
            let sec = Int(self.audioRecorder?.currentTime.truncatingRemainder(dividingBy: 60) ?? 0)
            let totalTimeString = String(format: "%02d:%02d", min, sec)
            self.voiceNoteTimerLabel.text = totalTimeString
        }
    }
    
    func hideRecorderView()
    {
        //reset text msg view to it's original place
        self.textMsgViewTrailingConstraint.constant = 0
        updateLayoutWithAnimation()
        
        //remove animation and reset flashing mic state
        self.flashingMicImgView.layer.removeAllAnimations()
        self.flashingMicImgView.alpha = 1
        
        //hide stop button
        micBtn.setImage(UIImage(systemName: "mic.fill"), for: .normal)
        micBtn.tintColor = UIColor.chatterGreenColor
        
        //stop timer
        timer.invalidate()
        voiceNoteTimerLabel.text = "00:00"
        
        //remove pulse animation
        recordPulseAnimationLayer.removeAllAnimations()
        recordPulseAnimationLayer.removeFromSuperlayer()
    }
    
    @objc func voiceNotePlayPauseBtnPressed(_ sender: UIButton)
    {
        //toggle button
        if audioPlayer.isPlaying
        {
            stopAudioPlayer(sender)
        }
        else if !audioPlayer.isPlaying
        {
            //play voice note
            if let url = URL(string: self.VM.messages.value[sender.tag].message)
            {
               do
               {
                   try AVAudioSession.sharedInstance().setCategory(.playback)
                   self.audioPlayer = try AVAudioPlayer(data: Data(contentsOf: url))
                   self.audioPlayer.volume = 1
                   self.audioPlayer.prepareToPlay()
                   
                   //get cell
                   currentPlayingCellIndex = sender.tag
                   guard let cell = self.tableView.cellForRow(at: IndexPath(row: currentPlayingCellIndex, section: 0)) as? VoiceNoteMessageCell else {return}

                   self.audioPlayer.currentTime = TimeInterval(cell.timeSlider.value) * self.audioPlayer.duration
                   self.audioPlayer.play()
                   
                   //change image
                   sender.setImage(UIImage(systemName: "pause.fill"), for: .normal)
                   
                   //start timer
                   timer = Timer(timeInterval: 1, repeats: true)
                   {
                       [weak self] _ in
                       guard let self = self else { return }
                       cell.timeSlider.value = Float(self.audioPlayer.currentTime / self.audioPlayer.duration)
                       if !self.audioPlayer.isPlaying
                       {
                           self.stopAudioPlayer(sender)
                       }
                   }
                   
                   RunLoop.main.add(timer, forMode: .common)
               }
                catch let error
                {
                    print("error occured while audio downloading")
                    print(error.localizedDescription)
                }
            }
        }
        
    }
    
    func stopAudioPlayer(_ sender: UIButton)
    {
        audioPlayer.stop()
        
        //stop timer
        timer.invalidate()
        
        //change image
        if sender.tag == currentPlayingCellIndex
        {
            sender.setImage(UIImage(systemName: "play.fill"), for: .normal)
        }
        else
        {
            guard let cell = self.tableView.cellForRow(at: IndexPath(row: currentPlayingCellIndex, section: 0)) as? VoiceNoteMessageCell else {return}
            cell.playPauseBtn.setImage(UIImage(systemName: "play.fill"), for: .normal)
            voiceNotePlayPauseBtnPressed(sender)
        }
    }
    
    func createRecorderPulseAnimation()
    {
        let position = CGPoint(x: micBtn.bounds.width + 5, y: micBtn.bounds.height + 5)

        let circularPath = UIBezierPath(arcCenter: position, radius: UIScreen.main.bounds.size.width / 3, startAngle: 0, endAngle: 2 * .pi , clockwise: true)
        
        recordPulseAnimationLayer = CAShapeLayer()
        recordPulseAnimationLayer.path = circularPath.cgPath
        recordPulseAnimationLayer.lineWidth = 10
        recordPulseAnimationLayer.fillColor = UIColor.chatterGreenColor.cgColor
        recordPulseAnimationLayer.lineCap = .round
        recordPulseAnimationLayer.strokeColor = UIColor.clear.cgColor
        
        micBtn.layer.insertSublayer(recordPulseAnimationLayer, at:0)
        
        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleAnimation.duration = 0.5
        scaleAnimation.fromValue = 1.2
        scaleAnimation.toValue = 1.1
        scaleAnimation.repeatCount = .greatestFiniteMagnitude
        recordPulseAnimationLayer.add(scaleAnimation, forKey: "scale")

        let opacityAnimation = CABasicAnimation(keyPath: #keyPath(CALayer.opacity))
        opacityAnimation.duration = 2.0
        opacityAnimation.fromValue = 0.9
        opacityAnimation.toValue = 0.3
        opacityAnimation.autoreverses = true
        opacityAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        opacityAnimation.repeatCount = .greatestFiniteMagnitude
        recordPulseAnimationLayer.add(opacityAnimation, forKey: "opacity")
    }
}
