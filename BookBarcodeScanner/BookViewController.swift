//
//  BookViewController.swift
//  BookBarcodeScanner
//
//  Created by Vikram Hegde on 5/16/18.
//  Copyright © 2018 Vikram Hegde. All rights reserved.
//

import UIKit

struct Book: Decodable {
    let totalItems: Int!
    let items: [Item]?
}

struct Item: Decodable {
    let volumeInfo: VolumeInfo?
    
}

struct VolumeInfo: Decodable {
    let title: String?
    let authors: [String]?
    let imageLinks: imageLink?
}

struct imageLink: Decodable {
    let thumbnail: String?
}

class BookViewController: UIViewController {

    var isbn: String! = ""
    var foundBook : Bool = false;
    
    @IBOutlet weak var coverImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var isbnLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("isbn: " + isbn)
        
        isbnLabel.text = isbn
        getBookInfo()
    }
    
    func getBookInfo(){
        // Link to Google Book API
        let jsonUrlString = "https://www.googleapis.com/books/v1/volumes?q=isbn:" + isbn
        
        self.titleLabel.text = "Searching"
        self.authorLabel.text = "Searching"
        
        guard let url = URL(string: jsonUrlString) else { return }
        
        // Fetch the JSON from Google Books API
        URLSession.shared.dataTask(with: url) { (data, response, err) in
            print("data: " + (data?.description)!)
            do {
                // Decode the JSON data pulled from above URL
                let bookData = try JSONDecoder().decode(Book.self, from: data!)
                print(bookData.totalItems)
                
                if(bookData.totalItems > 0){
                    DispatchQueue.main.async {
                        // Pull the properties from the Decodable structs above
                        self.authorLabel.text = bookData.items![0].volumeInfo!.authors![0]
                        self.titleLabel.text = bookData.items![0].volumeInfo!.title!
                        // Load the image from a URL
                        let imageUrl:URL = URL(string: bookData.items![0].volumeInfo!.imageLinks!.thumbnail!)!
                        let imageData:NSData = NSData(contentsOf: imageUrl)!
                        let image = UIImage(data: imageData as Data)
                        self.coverImage.image = image
                        self.coverImage.backgroundColor = UIColor.white
                    }
                }else{ // There has been an error with the barcode (scanned -- not a book)
                    DispatchQueue.main.async {
                        self.titleLabel.text = "Not a valid book"
                        self.authorLabel.text = ""
                        self.isbnLabel.text = ""
                    }
                }
                
            } catch _ { // Error with Extracting Data from JSON
                print("Error: \(err?.localizedDescription)")
            }
            }.resume()
    }
    

}
