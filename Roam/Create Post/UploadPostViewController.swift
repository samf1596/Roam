//
//  UploadPostViewController.swift
//  
//
//  Created by Samuel Fox on 11/3/18.
//

import UIKit
import Firebase
import Photos
import TLPhotoPicker
import MapKit

class UploadPostViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, TLPhotosPickerViewControllerDelegate, TravelDelegate, ExperiencesDelegate, UITextViewDelegate, ChooseLocationDelegate, UIScrollViewDelegate {
    
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var scrollView: UIScrollView!
    var slides = [ImageSlide]()
    
    func createSlides(_ images: [TLPHAsset]) -> [ImageSlide] {
        var slides = [ImageSlide]()
        
        for i in images {
            let slide:ImageSlide = Bundle.main.loadNibNamed("ImageSlide", owner: self, options: nil)?.first as! ImageSlide
            slide.imageView.image = i.fullResolutionImage
            if UserDefaults.standard.bool(forKey: "DarkMode") == false {
                slide.imageView.backgroundColor = .white
            }
            if UserDefaults.standard.bool(forKey: "DarkMode") == true {
                slide.imageView.backgroundColor = UIColor.darkGray
            }
            slides.append(slide)
        }
        
        return slides
    }
    
    func setupScrollView(_ imageSlides: [ImageSlide]) {
        scrollView.contentSize = CGSize(width: scrollView.frame.width * CGFloat(imageSlides.count), height: scrollView.frame.height)
        scrollView.isPagingEnabled = true
        
        for i in 0 ..< imageSlides.count {
            imageSlides[i].frame = CGRect(x: scrollView.frame.width * CGFloat(i), y: 0, width: view.frame.width, height: scrollView.frame.height)
            scrollView.addSubview(imageSlides[i])
        }
        
        pageControl.numberOfPages = imageSlides.count
        pageControl.currentPage = 0
        self.view.bringSubviewToFront(pageControl)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = round(scrollView.contentOffset.x/view.frame.width)
        pageControl.currentPage = Int(pageIndex)
    }
    
    var selectedLocations = [MKMapItem]()
    
    func saveChosenLocations(_ locations: [MKMapItem]) {
        selectedLocations = locations
    }

    static let uploadedImage = Notification.Name("uploadedImage")
    
    fileprivate var databaseRef : DatabaseReference!
    fileprivate var storageRef : StorageReference!
    fileprivate var uploadStorageTask: StorageUploadTask!
    fileprivate var imageStoragePath = ""
    
    @IBOutlet weak var addExperiences: UIButton!
    @IBOutlet weak var addFlightsAndStays: UIButton!
    @IBOutlet weak var postButton: UIButton!
    @IBOutlet weak var publicOrPrivateSegmentedControl: UISegmentedControl!
    
    var selectedPictures = [TLPHAsset]()
    var imageURLSforUpload = [String]()
    var uploadCount = 0
    var selectedImageCount = 0
    var textToUpload = "NOTEXT"
    
    @objc func onNotification(notification:Notification) {
        if notification.name == Notification.Name("settingsChanged") {
            if notification.userInfo!["theme"] as! String == Themes.Dark.rawValue {
                self.view.tintColor = UIColor.white
                self.view.backgroundColor = UIColor.darkGray
                self.navigationController?.navigationBar.tintColor = UIColor.init(red: 105/255, green: 196/255, blue: 250/255, alpha: 1.0)
                self.descriptionTextView.backgroundColor = UIColor.lightGray
                self.descriptionTextView.keyboardAppearance = .dark
                
                self.publicOrPrivateSegmentedControl.backgroundColor = UIColor.darkGray
                self.publicOrPrivateSegmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor:UIColor.white], for: .selected)
                self.publicOrPrivateSegmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor:UIColor.orange], for: .normal)
                self.publicOrPrivateSegmentedControl.tintColor = UIColor.orange
                scrollView.backgroundColor = UIColor.darkGray
            }
            else {
                self.view.tintColor = UIColor(red: 0.0, green: 122.0/255.0, blue: 1.0, alpha: 1.0)
                self.view.backgroundColor = UIColor.white
                self.navigationController?.navigationBar.tintColor = UIColor.init(red: 105/255, green: 196/255, blue: 250/255, alpha: 1.0)
                self.descriptionTextView.backgroundColor = UIColor(red: 0, green: 148.0/255.0, blue: 240.0/255.0, alpha: 0.1)
                self.descriptionTextView.isOpaque = true
                self.descriptionTextView.keyboardAppearance = .default
                
                self.publicOrPrivateSegmentedControl.backgroundColor = UIColor.white
                self.publicOrPrivateSegmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor:UIColor.white], for: .selected)
                self.publicOrPrivateSegmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor:UIColor.orange], for: .normal)
                self.publicOrPrivateSegmentedControl.tintColor = UIColor.orange
                scrollView.backgroundColor = UIColor.white
            }
        }
        
        if notification.name == UploadPostViewController.uploadedImage {
            uploadCount = uploadCount + 1
            if uploadCount >= selectedImageCount && imageURLSforUpload.count > 0 {
                self.uploadSuccess(self.imageURLSforUpload)
                self.showNetworkActivityIndicator = false
                resetScrollViewSlides()
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(UINotificationFeedbackGenerator.FeedbackType.success)
            }
        }
    }
    
    var imagePicker = UIImagePickerController()
    var imageToUpload = UIImage(named: "addPhoto")
    var travels = [""]
    var experiences = [""]
    var previousHeight : CGFloat = 25.0
    var kKeyboardSize : CGFloat = 0.0
    var keyboardVisible = false
    
    fileprivate var showNetworkActivityIndicator = false {
        didSet {
            UIApplication.shared.isNetworkActivityIndicatorVisible = showNetworkActivityIndicator
        }
    }
    
    @IBOutlet weak var descriptionTextView: UITextView!
    
    func resetScrollViewSlides() {
        let slide:ImageSlide = Bundle.main.loadNibNamed("ImageSlide", owner: self, options: nil)?.first as! ImageSlide
        slide.imageView.image = UIImage(named: "addPhoto")
        setupScrollView([slide])
        pageControl.numberOfPages = 1
        pageControl.currentPage = 0
        self.view.bringSubviewToFront(pageControl)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(onNotification(notification:)), name: UploadPostViewController.uploadedImage, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(onNotification(notification:)), name: SettingsViewController.settingsChanged, object: nil)
        
        if UserDefaults.standard.bool(forKey: "DarkMode") == false {
            NotificationCenter.default.post(name: SettingsViewController.settingsChanged, object: nil, userInfo:["theme": Themes.Light.rawValue])
        }
        if UserDefaults.standard.bool(forKey: "DarkMode") == true {
            NotificationCenter.default.post(name: SettingsViewController.settingsChanged, object: nil, userInfo:["theme": Themes.Dark.rawValue])
        }
        
        addExperiences.layer.cornerRadius = 4.0
        addExperiences.layer.shadowColor = UIColor.gray.cgColor
        addExperiences.layer.shadowOffset = CGSize(width: 2, height: 2)
        
        addFlightsAndStays.layer.cornerRadius = 4.0
        postButton.layer.cornerRadius = 4.0
        
        descriptionTextView.delegate = self
        descriptionTextView.returnKeyType = .done
        
        self.imagePicker.delegate = self
        databaseRef = Database.database().reference()
        storageRef = Storage.storage().reference()
        
        let addImageGesture = UITapGestureRecognizer(target: self, action: #selector(UploadPostViewController.selectImage(_:)))
        addImageGesture.numberOfTapsRequired = 1
        scrollView.addGestureRecognizer(addImageGesture)
        resetScrollViewSlides()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        previousHeight = self.view.frame.origin.y
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        
        switch photoAuthorizationStatus {
            
        case .authorized: print("Access is granted by user")
            
        case .notDetermined:
            
            PHPhotoLibrary.requestAuthorization({ (newStatus) in
                print("status is \(newStatus)")
                if newStatus == PHAuthorizationStatus.authorized {print("success")
                    
                } })
        case .restricted:
            print("User do not have access to photo album.")
                
        case .denied:
            print("User has denied the permission.")
            
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name:
            UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.text = self.textToUpload != "NOTEXT" ? self.textToUpload : ""
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        textView.resignFirstResponder()
        self.textToUpload = textView.text
    }
    
    @objc func keyboardWillShow(notification:Notification) {
        if !keyboardVisible && ( self.view.traitCollection.horizontalSizeClass != UIUserInterfaceSizeClass.regular ) {
            let userInfo = notification.userInfo!
            let keyboardSize = userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as? CGRect
            if self.view.frame.origin.y == previousHeight {
                kKeyboardSize = keyboardSize!.height
                self.view.frame.origin.y -= (keyboardSize!.height/2.0)
            }
        }
        
        keyboardVisible = true
    }
    
    @objc
    func keyboardWillHide(notification:Notification) {
        if keyboardVisible && ( self.view.traitCollection.horizontalSizeClass != UIUserInterfaceSizeClass.regular ) {
            if self.view.frame.origin.y != previousHeight {
                self.view.frame.origin.y = previousHeight
            }
        }
        keyboardVisible = false
    }
    
    @objc func selectImage(_ sender: UITapGestureRecognizer) {
        
        let viewController = TLPhotosPickerViewController()
        viewController.delegate = self
        var configure = TLPhotosPickerConfigure()
        configure.allowedVideo = false
        configure.allowedVideoRecording = false
        configure.muteAudio = true
        self.present(viewController, animated: true, completion: nil)
        
    }
    
    // TLPhotos delegate functions
    func dismissPhotoPicker(withTLPHAssets: [TLPHAsset]) {
        
        // MARK - TODO: What if no image selected or asset not recognized? handle here.
        
        // use selected order, fullresolution image
        self.selectedPictures = withTLPHAssets
        
        let slides = createSlides(selectedPictures)
        setupScrollView(slides)
        
        self.selectedImageCount = self.selectedPictures.count
    }
    func dismissPhotoPicker(withPHAssets: [PHAsset]) {
        // if you want to used phasset.
    }
    func photoPickerDidCancel() {
    }
    func dismissComplete() {
        // picker viewcontroller dismiss completion
    }

    func canSelectAsset(phAsset: PHAsset) -> Bool {
        //Custom Rules & Display
        //You can decide in which case the selection of the cell could be forbidden.
        return true
    }
    func didExceedMaximumNumberOfSelection(picker: TLPhotosPickerViewController) {
        // exceed max selection
    }
    func handleNoAlbumPermissions(picker: TLPhotosPickerViewController) {
        // handle denied albums permissions case
    }
    func handleNoCameraPermissions(picker: TLPhotosPickerViewController) {
        // handle denied camera permissions case
    }
    
    // This function is adapted from https://stackoverflow.com/questions/31314412/how-to-resize-image-in-swift
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        UIGraphicsBeginImageContext(newSize)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    @IBAction func submitPost(_ sender: Any) {
        
        self.textToUpload = self.descriptionTextView.text
        self.selectedImageCount = self.selectedPictures.count
        
        for selectedImage in self.selectedPictures {
            
            let imageToUploadResized = resizeImage(image: selectedImage.fullResolutionImage!, targetSize: CGSize(width: 800, height: 600))
            
            let image = imageToUploadResized.jpegData(compressionQuality: 0.65)
            let imagePath = "/\(Int(Date.timeIntervalSinceReferenceDate * 1000)).jpg"
            
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            showNetworkActivityIndicator = true
            
            let storage = storageRef.child("IMAGES/"+imagePath)
            
            storage.putData(image!).observe(.failure) { snapshot in
                if let error = snapshot.error as NSError? {
                    switch (StorageErrorCode(rawValue: error.code)!) {
                    case .objectNotFound:
                        print("File doesn't exist")
                        break
                    case .unauthorized:
                        print("User doesn't have permission to access file")
                        break
                    case .unknown:
                        print("Unknown Error")
                        let generator = UINotificationFeedbackGenerator()
                        generator.notificationOccurred(UINotificationFeedbackGenerator.FeedbackType.error)
                        break
                    default:
                        print("Unhandled Error")
                        let generator = UINotificationFeedbackGenerator()
                        generator.notificationOccurred(UINotificationFeedbackGenerator.FeedbackType.error)
                        break
                    }
                }
            }
            storage.putData(image!).observe(.success) { (snapshot) in
                storage.downloadURL(completion: { (url, error) in
                    if (error == nil) {
                        if let downloadUrl = url {
                            let downloadURL = downloadUrl.absoluteString
                            self.imageURLSforUpload.append(downloadURL)
                            NotificationCenter.default.post(name: UploadPostViewController.uploadedImage, object: nil)
                        }
                    } else {
                        print("Error:\(String(describing: error?.localizedDescription))")
                        let generator = UINotificationFeedbackGenerator()
                        generator.notificationOccurred(UINotificationFeedbackGenerator.FeedbackType.error)
                    }
                })

            }

        }

    }
    
    @IBAction func deletePost(_ sender: Any) {
        let alertController = UIAlertController(title: "Confirm", message: "Are you sure you want to cancel this post?", preferredStyle: .actionSheet)
 
        let yesAlert = UIAlertAction(title: "Yes", style: .default) { (action) in
            self.selectedPictures = []
            self.slides = []
            self.resetScrollViewSlides()
            self.descriptionTextView.text = "Add a description of your trip here..."
            self.textToUpload = "NOTEXT"
            self.selectedPictures = []
            self.imageURLSforUpload = []
            self.uploadCount = 0
            self.selectedImageCount = 0
            self.travels = [""]
            self.experiences = [""]
            self.publicOrPrivateSegmentedControl.selectedSegmentIndex = 0
            self.selectedLocations = []
        }
        alertController.addAction(yesAlert)
        
        let cancelAlert = UIAlertAction(title: "No", style: .cancel, handler: nil)
        alertController.addAction(cancelAlert)
        self.present(alertController, animated: true)
    }
    
    
    func uploadSuccess(_ imagePath : [String]) {
        var uploadLocations = [String: [String:Double]]()
        
        for location in selectedLocations {
            let name = location.name!.replacingOccurrences(of: ".", with: "")
            uploadLocations[name] = ["lat":location.placemark.coordinate.latitude]
            uploadLocations[name]!["long"] = location.placemark.coordinate.longitude
        }
        
        if selectedLocations.count < 1 {
            uploadLocations = ["NONE": ["NONE":0]]
        }
        
        print(uploadLocations)
        if self.textToUpload == "" {
            self.textToUpload = "NOTEXT"
        }
        
        var account : NewUser?
        databaseRef.child(FirebaseFields.Accounts.rawValue).child(Auth.auth().currentUser!.uid).observe(.value) { (snapshot) in
        account = NewUser(snapshot: snapshot)
        let postID = "\(Int(Date.timeIntervalSinceReferenceDate * 1000))"
            let isPublic = self.publicOrPrivateSegmentedControl.selectedSegmentIndex == 0 ? false : true
            let post = Post(addedByUser: (account?.firstname)! + " " + (account?.lastname)!, username: Auth.auth().currentUser!.uid, description: self.textToUpload, imagePath: imagePath, experiences: self.experiences, travels: self.travels, isPublic: isPublic, postID: postID, locations: uploadLocations)
        
        self.databaseRef.child(FirebaseFields.Posts.rawValue).child(postID).setValue(post.toObject())
            self.descriptionTextView.text = "Add a description of your trip here..."
            self.textToUpload = "NOTEXT"
            self.selectedPictures = [TLPHAsset]()
            self.imageURLSforUpload = [String]()
            self.uploadCount = 0
            self.selectedImageCount = 0
            self.travels = [""]
            self.experiences = [""]
            self.publicOrPrivateSegmentedControl.selectedSegmentIndex = 0
            self.selectedLocations = []
        }
    }
    
    func saveTravels(_ travels: [String]) {
        self.travels = travels
        if self.travels.count < 1 {
            self.travels = [""]
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.descriptionTextView.text = textToUpload != "NOTEXT" ? textToUpload : "Add a description of your trip here..."
    }
    
    func saveExperiences(_ experiences: [String]) {
        self.experiences = experiences
        if self.experiences.count < 1 {
            self.experiences = [""]
        }
    }
    // MARK: - Navigation

    @IBAction func unwindToUploadPost(segue:UIStoryboardSegue) {
        self.descriptionTextView.text = self.textToUpload != "NOTEXT" ? self.textToUpload : "Add a description of your trip here..."
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         switch segue.identifier {
         case "AddExperiences":
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
            self.textToUpload = self.textToUpload != "NOTEXT" ? self.descriptionTextView.text : "NOTEXT"
            let experiencesController = segue.destination as! ExperiencesTableViewController
            experiencesController.delegate = self
         case "AddTravel":
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
            self.textToUpload = self.textToUpload != "NOTEXT" ? self.descriptionTextView.text : "NOTEXT"
            let travelController = segue.destination as! FlightsStaysTableViewController
            travelController.delegate = self
         case "ChooseLocation":
            let backItem = UIBarButtonItem()
            backItem.title = "Done"
            navigationItem.backBarButtonItem = backItem
            let chooseLocationController = segue.destination as! ChooseLocationTableViewController
            chooseLocationController.configure(selectedLocations)
            chooseLocationController.delegate = self
         default:
            assert(false, "Unhandled Segue")
         }
     }

}
