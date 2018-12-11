//
//  File.swift
//  Roam
//
//  Created by Samuel Fox on 11/3/18.
//  Copyright © 2018 sof5207. All rights reserved.
//

import Foundation
import Firebase
import CoreData

// MARK: - ENUMS for attributes
enum FirebaseFields: String {
    case Posts
    case Users
    case Accounts
}

enum PostAttributes: String {
    case addedByUser
    case username
    case description
    case imagePath
    case experiences
    case travels
    case isPublic
    case postID
}

enum UserAttributes: String {
    case firstname
    case lastname
    case username
    case uid
    case email
}

enum Themes: String {
    case Dark
    case Light
}

// MARK: - User Struct
struct NewUser {
    let firstname: String
    let lastname: String
    let username: String
    let uid: String
    let email: String
    
    init(firstname: String, lastname: String, username: String, uid: String, email: String){
        self.firstname = firstname
        self.lastname = lastname
        self.username = username
        self.uid = uid
        self.email = email
    }
    
    init(snapshot: DataSnapshot) {
        let snapshotValue = snapshot.value as! [String: AnyObject]
        self.firstname = snapshotValue[UserAttributes.firstname.rawValue] as! String
        self.lastname = snapshotValue[UserAttributes.lastname.rawValue] as! String
        self.username = snapshotValue[UserAttributes.username.rawValue] as! String
        self.uid = snapshotValue[UserAttributes.uid.rawValue] as! String
        self.email = snapshotValue[UserAttributes.email.rawValue] as! String
    }
    
    func toObject() -> Any {
        return [
            UserAttributes.firstname.rawValue: self.firstname,
            UserAttributes.lastname.rawValue: self.lastname,
            UserAttributes.username.rawValue: self.username,
            UserAttributes.uid.rawValue: self.uid,
            UserAttributes.email.rawValue: self.email
        ]
    }
}

// MARK: - Post Struct
struct Post :  Codable  {
    let addedByUser: String
    let username: String
    let description: String
    let imagePath: [String]
    let experiences: [String]
    let travels: [String]
    let isPublic: Bool
    let postID : String
    var cachedImage: UIImage? = nil
    
    var firstname : String {return addedByUser}
    var fullname : String {return addedByUser}
    
    enum CodingKeys : String, CodingKey {
        case addedByUser
        case username
        case description
        case imagePath
        case experiences
        case travels
        case isPublic
        case postID
    }
    
    init(addedByUser: String, username: String, description: String, imagePath: [String], experiences: [String], travels: [String], isPublic: Bool, postID: String){
        self.addedByUser = addedByUser
        self.username = username
        self.description = description
        self.imagePath = imagePath
        self.experiences = experiences
        self.travels = travels
        self.isPublic = isPublic
        self.postID = postID
    }
    
    init(snapshot: DataSnapshot) {
        let snapshotValue = snapshot.value as! [String: AnyObject]
        self.addedByUser = snapshotValue[PostAttributes.addedByUser.rawValue] as! String
        self.username = snapshotValue[PostAttributes.username.rawValue] as! String
        self.description = snapshotValue[PostAttributes.description.rawValue] as! String
        self.imagePath = snapshotValue[PostAttributes.imagePath.rawValue] as! [String]
        self.experiences = snapshotValue[PostAttributes.experiences.rawValue] as! [String]
        self.travels = snapshotValue[PostAttributes.travels.rawValue] as! [String]
        self.isPublic = snapshotValue[PostAttributes.isPublic.rawValue] as! Bool
        self.postID = snapshotValue[PostAttributes.postID.rawValue] as! String
    }
    
    func toObject() -> Any {
        return [
            PostAttributes.addedByUser.rawValue: self.addedByUser,
            PostAttributes.username.rawValue: self.username,
            PostAttributes.description.rawValue: self.description,
            PostAttributes.imagePath.rawValue: self.imagePath,
            PostAttributes.experiences.rawValue: self.experiences,
            PostAttributes.travels.rawValue: self.travels,
            PostAttributes.isPublic.rawValue: self.isPublic,
            PostAttributes.postID.rawValue: self.postID,
        ]
    }
}

// MARK: - Model to save Posts to cache and to load them
class PostsModel {
    
    static let sharedInstance = PostsModel()
    
    fileprivate var posts = [Post]()
    fileprivate var cachedPosts = [Post]()
    fileprivate var followingPosts = [Post]()
    fileprivate var bookmarkedPosts = [Post]()
    fileprivate var usersPosts = [Post]()
    fileprivate var ref : DatabaseReference!
    fileprivate var storageRef : StorageReference!
    fileprivate let fileManager = FileManager()
    fileprivate let imageCache = NSCache<AnyObject, AnyObject>()
    fileprivate var following = [String]()
    
    var cachedPostsCount : Int {return cachedPosts.count}
    var cachedFollowingPostsCount : Int {return followingPosts.count}
    var cachedBookmarkedPostsCount : Int {return bookmarkedPosts.count}
    var cachedUsersPostsCount : Int {return usersPosts.count}
    func postForSection(_ section: Int) -> Post{
        return cachedPosts[section]
    }
    func postForFollowingSection(_ section: Int) -> Post{
        return followingPosts[section]
    }
    func postForBookmarkedSection(_ section: Int) -> Post {
        return bookmarkedPosts[section]
    }
    func postForUsersSection(_ section: Int) -> Post {
        return usersPosts[section]
    }
    
    func imagePathForPost(_ section: Int, _ imageIndex: Int) -> String {
        return cachedPosts[section].imagePath[imageIndex]
    }
    func imagePathForFollowingPost(_ section: Int, _ imageIndex: Int) -> String {
        return followingPosts[section].imagePath[imageIndex]
    }
    func imagePathForBookmarkedPost(_ section: Int, _ imageIndex: Int) -> String {
        return bookmarkedPosts[section].imagePath[imageIndex]
    }
    func imagePathForUsersPost(_ section: Int, _ imageIndex: Int) -> String {
        return usersPosts[section].imagePath[imageIndex]
    }
    
    func cacheImage(_ imageURL: String, _ image: UIImage) {
        let imageToCache = image
        imageCache.setObject(imageToCache, forKey: imageURL as AnyObject)
    }
    
    func getCachedImage(_ imageURL: String) -> UIImage? {
        return imageCache.object(forKey: imageURL+".jpg" as AnyObject) as? UIImage
    }
    
    fileprivate init(){
        ref = Database.database().reference()
        storageRef = Storage.storage().reference()
        downloadPosts()
    }
    
    func downloadPosts() {
        ref.child(FirebaseFields.Posts.rawValue).observe(.value) { (snapshot) in
            var posts = [Post]()
            for postSnapshot in snapshot.children {
                let post = Post(snapshot: postSnapshot as! DataSnapshot)
                posts.append(post)
            }
            self.posts = posts
            let block = {
                self.cachedPosts = self.posts.reversed()
                self.findBookmarkedPosts()
                self.findFollowingPosts()
                self.findUsersPosts()
            }
            DispatchQueue.main.async(execute: block)
        }
    }
    
    func refreshContent(for tableView: UITableView, with refreshControl: UIRefreshControl?) {
        let block = {
            self.cachedPosts = self.posts.reversed()
            tableView.reloadData()
            refreshControl?.endRefreshing()
        }
        DispatchQueue.main.async(execute: block)
    }
    
    func saveImageInDirectory(_ image: UIImage, _ imageURL: String) {
        let directoryPath = NSHomeDirectory().appending("/Library/Caches/")
        if !fileManager.fileExists(atPath: directoryPath) {
            do {
                try fileManager.createDirectory(at: NSURL.fileURL(withPath: directoryPath), withIntermediateDirectories: true, attributes: nil)
            } catch {
                print(error)
            }
        }
        let filePath = directoryPath.appending(imageURL)
        let url = NSURL.fileURL(withPath: filePath)
        do {
            try image.jpegData(compressionQuality: 1.0)?.write(to: url, options: .atomic)
            
        } catch {
            print("file cant not be save at path \(filePath), with error : \(error)");
        }
    }
    
    func getImageFromDirectory(_ imageURL: String) -> UIImage? {
        let directoryPath = NSHomeDirectory().appending("/Library/Caches/")
        let filePath = directoryPath.appending(imageURL)
        let url = NSURL.fileURL(withPath: filePath)
        
        let image = UIImage(contentsOfFile: url.path)
        return image
    }
    
    
    func downloadImage(_ indexPath: IndexPath, _ imageURL: String, _ postID: String) {
        let numberOfImages = cachedPosts[indexPath.section].imagePath.count
        for index in 0..<numberOfImages {
            
            if getCachedImage(postID+"\(index).jpg") == nil && getImageFromDirectory(postID+"\(index).jpg") == nil {
                let storage = storageRef.storage.reference(forURL: cachedPosts[indexPath.section].imagePath[index])
                storage.getData(maxSize: 2*1024*1024) { (data, error) in
                    if error == nil {
                        //self.cachedPosts[indexPath.section].cachedImage = UIImage(data: data!)
                        let image = UIImage(data: data!)
                        self.cacheImage(postID+"\(index).jpg", image!)
                        self.saveImageInDirectory(image!, postID+"\(index).jpg")
                    }
                    else {
                        print("Error:\(error ?? "" as! Error)")
                    }
                }
            }
            else {
                let image = getImageFromDirectory(postID+"\(index).jpg")!
                self.cacheImage(postID+"\(index).jpg", image)
            }
            
        }
    }
    func downloadFollowingImage(_ indexPath: IndexPath, _ imageURL: String, _ postID: String) {
        let numberOfImages = followingPosts[indexPath.section].imagePath.count
        for index in 0..<numberOfImages {
            
            if getCachedImage(postID+"\(index).jpg") == nil && getImageFromDirectory(postID+"\(index).jpg") == nil {
                let storage = storageRef.storage.reference(forURL: followingPosts[indexPath.section].imagePath[index])
                storage.getData(maxSize: 2*1024*1024) { (data, error) in
                    if error == nil {
                        //self.cachedPosts[indexPath.section].cachedImage = UIImage(data: data!)
                        let image = UIImage(data: data!)
                        self.cacheImage(postID+"\(index).jpg", image!)
                        self.saveImageInDirectory(image!, postID+"\(index).jpg")
                    }
                    else {
                        print("Error:\(error ?? "" as! Error)")
                    }
                }
            }
            else {
                let image = getImageFromDirectory(postID+"\(index).jpg")!
                self.cacheImage(postID+"\(index).jpg", image)
            }
        }
    }
    func downloadBookmarkedImage(_ postIndex: Int, _ imageURL: String, _ postID: String) {
        let numberOfImages = bookmarkedPosts[postIndex].imagePath.count
        
        for index in 0..<numberOfImages {
            if getCachedImage(postID+"\(index).jpg") == nil && getImageFromDirectory(postID+"\(index).jpg") == nil {
                let storage = storageRef.storage.reference(forURL: bookmarkedPosts[postIndex].imagePath[index])
                storage.getData(maxSize: 2*1024*1024) { (data, error) in
                    if error == nil {
                        //self.cachedPosts[indexPath.section].cachedImage = UIImage(data: data!)
                        let image = UIImage(data: data!)
                        self.cacheImage(postID+"\(index).jpg", image!)
                        self.saveImageInDirectory(image!, postID+"\(index).jpg")
                    }
                    else {
                        print("Error:\(error ?? "" as! Error)")
                    }
                }
            }
            else {
                let image = getImageFromDirectory(postID+"\(index).jpg")!
                self.cacheImage(postID+"\(index).jpg", image)
            }
        }
    }
    func downloadUsersPostImage(_ postIndex: Int, _ imageURL: String, _ postID: String) {
        let numberOfImages = usersPosts[postIndex].imagePath.count
        
        for index in 0..<numberOfImages {
            if getCachedImage(postID+"\(index).jpg") == nil && getImageFromDirectory(postID+"\(index).jpg") == nil {
                let storage = storageRef.storage.reference(forURL: usersPosts[postIndex].imagePath[index])
                storage.getData(maxSize: 2*1024*1024) { (data, error) in
                    if error == nil {
                        //self.cachedPosts[indexPath.section].cachedImage = UIImage(data: data!)
                        let image = UIImage(data: data!)
                        self.cacheImage(postID+"\(index).jpg", image!)
                        self.saveImageInDirectory(image!, postID+"\(index).jpg")
                    }
                    else {
                        print("Error:\(error ?? "" as! Error)")
                    }
                }
            }
            else {
                let image = getImageFromDirectory(postID+"\(index).jpg")!
                self.cacheImage(postID+"\(index).jpg", image)
            }
        }
    }
    
    func findBookmarkedPosts() {
        if Auth.auth().currentUser != nil {
            ref.child(FirebaseFields.Users.rawValue).child(Auth.auth().currentUser!.uid).child("Bookmarks").observe(.value) { (snapshot) in
                var bookmarks = [String]()
                self.bookmarkedPosts = []
                
                for user in snapshot.children {
                    let temp = user as! DataSnapshot
                    bookmarks.append(temp.key)
                }
                for post in self.cachedPosts {
                    if bookmarks.contains(post.postID){
                        self.bookmarkedPosts.append(post)
                    }
                }
            }
        }
    }
    
    func findFollowingPosts() {
        if Auth.auth().currentUser != nil {
            ref.child(FirebaseFields.Users.rawValue).child(Auth.auth().currentUser!.uid).child("following").observe(.value) { (snapshot) in
                self.following = []
                self.followingPosts = []
                for user in snapshot.children {
                    let temp = user as! DataSnapshot
                    self.following.append(temp.key)
                }
                for post in self.cachedPosts {
                    if self.following.contains(post.username){
                        self.followingPosts.append(post)
                    }
                }
            }
        }
    }
    
    func findUsersPosts() {
        if Auth.auth().currentUser != nil {
            ref.child(FirebaseFields.Accounts.rawValue).child(Auth.auth().currentUser!.uid).observe(.value) { (snapshot) in
                self.usersPosts = []
                let user = NewUser(snapshot: snapshot)
                for post in self.cachedPosts {
                    if post.username == user.username {
                        self.usersPosts.append(post)
                    }
                }
            }
        }
    }
    
    func clearFollowingUsersAndBookmarks() {
        self.usersPosts = []
        self.followingPosts = []
        self.following = []
        self.bookmarkedPosts = []
    }
}


// MARK: - Experiences
class Experiences {
    static let sharedExperiencesInstance = Experiences()
    
    var experiences = [String]()
    
    func addExperience(_ experience: String) {
        experiences.append(experience)
    }
    
    func removeExperience(_ experience: String) {
        let index = experiences.firstIndex(of: experience)
        
        if let indexOfExperience = index {
            experiences.remove(at: indexOfExperience)
        }
    }
    
    func deleteExperienceAtIndex(_ index: Int) {
        experiences.remove(at: index)
    }
    
    func experienceAtIndex(_ index: Int) -> String{
        return experiences[index]
    }
    
    var experiencesCount: Int {return experiences.count}
    
}

// MARK: - Travel Info
class TravelInfo {
    static let sharedTravelsInstance = TravelInfo()
    
    var travels = [String]()
    
    func addTravel(_ travel: String) {
        travels.append(travel)
    }
    
    func removeTravel(_ travel: String) {
        let index = travels.firstIndex(of: travel)
        
        if let indexOfTravel = index {
            travels.remove(at: indexOfTravel)
        }
    }
    
    func deleteTravelAtIndex(_ index: Int) {
        travels.remove(at: index)
    }
    
    func travelAtIndex(_ index: Int) -> String{
        return travels[index]
    }
    
    var travelsCount: Int {return travels.count}
    
}

// MARK: - Class for caching images
class CachedImages {
    let imageCache = NSCache<AnyObject, AnyObject>()
    
    func cacheImage(_ imageURL: String, _ image: UIImage) {
        let imageToCache = image
        imageCache.setObject(imageToCache, forKey: imageURL as AnyObject)
    }
    
    func getCachedImage(_ imageURL: String) -> UIImage? {
        return imageCache.object(forKey: imageURL as AnyObject) as? UIImage
    }
}
