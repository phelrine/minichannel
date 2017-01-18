//
//  ViewController.swift
//  minichannel
//
//  Created by nagasaka.shogo on 1/18/17.
//  Copyright © 2017 jp.ne.donuts. All rights reserved.
//

import UIKit
import MobileCoreServices
import Firebase
import FirebaseStorage
import FirebaseDatabase
import AVFoundation
import AVKit
import ObjectMapper

class MovieInfo: Mappable {
    var uid: String?
    var userName: String?
    var moviePath: String?
    var thumbnailPath: String?

    /// This function can be used to validate JSON prior to mapping. Return nil to cancel mapping at this point
    public required init?(map: Map) {
        uid <- map["uid"]
        userName <- map["user_name"]
        moviePath <- map["movie_path"]
        thumbnailPath <- map["thumbnail_path"]
    }

    /// This function is where all variable mappings should occur. It is executed by Mapper during the mapping (serialization and deserialization) process.
    public func mapping(map: Map) {
    }
}

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet var movieTableView: UITableView?

    let databaseRef = FIRDatabase.database().reference()
    let refreshControl = UIRefreshControl()
    var movies = [MovieInfo]()
    var playMovie: MovieInfo?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        refreshControl.addTarget(self, action: #selector(reload(_:)), for: .valueChanged)
        let nib = UINib(nibName: "MovieTableViewCell", bundle: nil)
        movieTableView?.register(nib, forCellReuseIdentifier: "MovieCell")
        movieTableView?.rowHeight = UITableViewAutomaticDimension
        movieTableView?.estimatedRowHeight = 340
        movieTableView?.dataSource = self
        movieTableView?.delegate = self
        movieTableView?.refreshControl = refreshControl
        reload(nil)
        navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.1529197991, green: 0.1529534459, blue: 0.1529176831, alpha: 1)
        navigationItem.titleView = UIImageView(image: UIImage(named: "TitleLogo"))
    }

    func reload(_ sender: Any?) {
        databaseRef.child("movies").queryLimited(toLast: 20).observeSingleEvent(of: .value, with: { (snapshot) in
            let movies = snapshot.children.flatMap{ ($0 as? FIRDataSnapshot)?.value as? [String: Any] }.flatMap{ MovieInfo(JSON: $0) }
            self.movies = movies.reversed()
            DispatchQueue.main.async {
                self.movieTableView?.reloadData()
                self.refreshControl.endRefreshing()
            }
        }, withCancel: { (error) in

        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func postButtonDidTouch(sender: UIButton) {
        print("tapped")
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.mediaTypes = [kUTTypeMovie as String]
        vc.delegate = self
        self.present(vc, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let url = info[UIImagePickerControllerMediaURL] as? URL {
            let asset = AVURLAsset(url: url)
            let imageGenerator = AVAssetImageGenerator(asset: asset)
            let time = CMTimeMakeWithSeconds(asset.duration.seconds / 2, 30)
            if let cgImage = try? imageGenerator.copyCGImage(at: time, actualTime: nil), let thumbnailData = UIImageJPEGRepresentation(UIImage(cgImage: cgImage), 1) {

                let storageRef = FIRStorage.storage().reference()
                let moviePath = "movies/\(NSUUID().uuidString).MOV"
                let movieRef = storageRef.child(moviePath)
                movieRef.putFile(url, metadata: nil) { (metadata, error) in
                    let thumbnailPath = "thumbnail/\(NSUUID().uuidString).jpg"
                    let thumbnailRef = storageRef.child(thumbnailPath)
                    thumbnailRef.put(thumbnailData, metadata: nil) { (thumbnailMetadata, error) in
                        if let user = FIRAuth.auth()?.currentUser, error == nil {
                            let uid = user.uid
                            var movieData = [
                                "uid": uid,
                                "movie_path": moviePath,
                                "thumbnail_path": thumbnailPath
                            ]
                            if let userName = user.displayName {
                                movieData["user_name"] = userName
                            }
                            let databaseRef = FIRDatabase.database().reference()
                            let moviesRef = databaseRef.child("movies")
                            let key = moviesRef.childByAutoId().key
                            moviesRef.child(key).setValue(movieData)
                        }
                        picker.dismiss(animated: true, completion: nil)
                    }
                }
            }
        }
    }
}

extension ViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath)
        if let movieCell = cell as? MovieTableViewCell {
            let movie = movies[indexPath.row]
            movieCell.nameLabel.text = movie.userName
            if let thumbnailPath = movie.thumbnailPath {
                let storageRef = FIRStorage.storage().reference()
                storageRef.child(thumbnailPath).data(withMaxSize: 1024 * 1024 * 5) { (data, error) in
                    if error != nil {
                        return
                    }
                    if let data = data, let image = UIImage(data: data, scale: 1) {
                        DispatchQueue.main.async {
                            movieCell.thumbnailView.image = image
                            movieCell.setNeedsUpdateConstraints()
                        }
                    }
                }
            }
        }
        return cell
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let movie = movies[indexPath.row]
        playMovie = movie
        let playerViewController = MoviePlayerViewController()
        if let moviePath = self.playMovie?.moviePath {
            let storageRef = FIRStorage.storage().reference()
            storageRef.child(moviePath).downloadURL{ (url, error) in
                guard error == nil, let url = url else {
                    return
                }
                playerViewController.loadMovie(url)
                self.navigationController?.pushViewController(playerViewController, animated: true)
            }
        }
    }
}
