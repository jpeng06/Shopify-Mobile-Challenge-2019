//
//  ListTableViewController.swift
//  ShopiList
//
//  Created by John Peng on 2018-09-12.
//  Copyright © 2018 Junhao Peng. All rights reserved.
//

import UIKit

class ListTableViewController: UITableViewController, SectionHeaderViewDelegate {
    
    private let SectionHeaderViewIdentifier = "SectionHeader"
    private let token = "c32313df0d0ef512ca64d5b336a0d7c6"
    private let rawURL = "https://shopicruit.myshopify.com/admin/products.json?"
    

    typealias objectJSON = [Any]
    typealias arrayJSON = [String: Any]
    private var productInfoArray: NSMutableArray = []
    private var sectionInfoArray: NSMutableArray = []
    var list: [String: NSMutableArray] = [:]
    
    private let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.light))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let sectionHeaderNib: UINib = UINib(nibName: "ListSectionHeaderView", bundle: nil)
        self.tableView.register(sectionHeaderNib, forHeaderFooterViewReuseIdentifier: SectionHeaderViewIdentifier)
        
        self.tableView.sectionHeaderHeight = 70
        
        fetchData(page: 1)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return sectionInfoArray.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.sectionInfoArray.count > 0 {
            let sectionInfo: SectionInfo = sectionInfoArray[section] as! SectionInfo
            if sectionInfo.open {
                return sectionInfo.itemsInSection.count
            }
        }
        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:ListTableViewCell = tableView.dequeueReusableCell(withIdentifier: "ListCell") as! ListTableViewCell
        
        let sectionInfo: SectionInfo = sectionInfoArray[indexPath.section] as! SectionInfo
        let item = sectionInfo.itemsInSection[indexPath.row] as! ProductInfo
        
        cell.productImg.imageFromURL(urlString: item.image)    // UIImage(named: "r")
        cell.productName.text = item.title
        var subtitle = ""
        for element in item.variants {
            if let title = element["title"], let count = element["inventory_quantity"] {
                subtitle += "\(title)(\(count))  "
            }
        }
        cell.productInventory.text = subtitle
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionHeaderView: ListSectionHeaderView! = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: SectionHeaderViewIdentifier) as! ListSectionHeaderView
        let sectionInfo: SectionInfo = sectionInfoArray[section] as! SectionInfo
        
        sectionHeaderView.disclosureButton.isSelected = !sectionInfo.open
        sectionHeaderView.titleLabel.text = sectionInfo.sectionTitle
        sectionHeaderView.section = section
        sectionHeaderView.delegate = self
        return sectionHeaderView
    }
    
    
    func sectionHeaderView(sectionHeaderView: ListSectionHeaderView, section: Int) {
        let sectionInfo: SectionInfo = sectionInfoArray[section] as! SectionInfo
        let rowCount = sectionInfo.itemsInSection.count
        
        if sectionInfo.open {
            sectionInfo.open = false
            if rowCount > 0 {
                let indexPathToDelete: NSMutableArray = NSMutableArray()
                for i in 0..<rowCount {
                    indexPathToDelete.add(NSIndexPath(row: i, section: section))
                }
                self.tableView.deleteRows(at:indexPathToDelete as! [IndexPath] , with: .top)
            }
        } else {
            sectionInfo.open = true
            let indexPathToInsert: NSMutableArray = NSMutableArray()
            for i in 0..<rowCount {
                indexPathToInsert.add(NSIndexPath(row: i, section: section))
            }
            self.tableView.insertRows(at: indexPathToInsert as! [IndexPath], with: .top)
        }
    }
    
    func fetchData(page: Int) {
        
        let sv = UIViewController.displaySpinner(onView: view)
        if let url = URL(string: "\(rawURL)page=\(page)&access_token=\(token)") {
            
            let session = URLSession.shared
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            
            let task = session.dataTask(with: request as URLRequest, completionHandler: { data, _, error in
                
                guard error == nil else {
                    return
                }
                
                guard let data = data else {
                    return
                }
                
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? arrayJSON {
                        print(json.count)
                        if let products = json["products"] as? objectJSON {
                            for element in products {
                                
                                if let content = element as? arrayJSON {
                                    
                                    if let title = content["title"] as? String,
                                       let tags = content["tags"] as? String,
                                       let image = content["image"] as? arrayJSON,
                                       let img_link = image["src"] as? String,
                                       let variants = content["variants"] as? [[String: Any]] {
                                        
                                            let tagsArray = tags.components(separatedBy: ",")
                                            let productInfo = ProductInfo(productTile: title, productTags: tagsArray, productImg: img_link, productVariants: variants)
                                        
                                            self.productInfoArray.add(productInfo)
                                        
                                    }
                                }
                            }
                        }
                    }

                    DispatchQueue.main.sync {
                        self.populateData()
                        UIViewController.removeSpinner(spinner: sv)
                        self.tableView.reloadData()
                    }
                    
                } catch let error {
                    UIViewController.removeSpinner(spinner: sv)
                    print(error.localizedDescription)
                }
            })
            task.resume()
        }
    }
    
    func populateData() {
        
        for element in productInfoArray {
            
            if let product = element as? ProductInfo {
                for tag in product.tags {
                    if (!list.keys.contains(tag)) {
                        list[tag] = NSMutableArray()
                    }
                    list[tag]?.add(product)
                }
            }
        }
        
        for (key,value) in list {
            sectionInfoArray.add(SectionInfo(itemsInSection: value, sectionTitle: key))
        }
    }
}

extension UIViewController {
    class func displaySpinner(onView: UIView) -> UIView {
        let spinnerView = UIView(frame: onView.bounds)
        spinnerView.backgroundColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1)
        let ai = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        ai.startAnimating()
        ai.center = spinnerView.center
        
        DispatchQueue.main.async {
            spinnerView.addSubview(ai)
            onView.addSubview(spinnerView)
        }
        
        return spinnerView
    }
    
    class func removeSpinner(spinner: UIView) {
        DispatchQueue.main.async {
            spinner.removeFromSuperview()
        }
    }
}

extension UIImageView {
    public func imageFromURL(urlString: String) {
        
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        activityIndicator.frame = CGRect.init(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
        activityIndicator.startAnimating()
        if self.image == nil {
            self.addSubview(activityIndicator)
        }
        
        URLSession.shared.dataTask(with: NSURL(string: urlString)! as URL, completionHandler: { (data, response, error) -> Void in
            
            if error != nil {
                print(error ?? "No Error")
                return
            }
            
            DispatchQueue.main.async(execute: { () -> Void in
                let image = UIImage(data: data!)
                activityIndicator.removeFromSuperview()
                self.image = image
            })
            
        }).resume()
    }
}
