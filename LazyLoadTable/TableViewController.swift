//
//  TableViewController.swift
//  LazyLoadTable
//
//  Created by Baidyanath on 1/9/15.
//  Copyright (c) 2015 Baidyanath. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {
    
    var numberOfRecordsPerAPICall:NSInteger=10// Pass number of record you API call.
    var lastObjectIndex:Int = 0// var used for pagination
    var arrayRecordsForTableView:NSMutableArray = NSMutableArray()
    var isApiCalling:Bool = true // Bool to check api calling is currently in process or not
    var activityIndicator : UIActivityIndicatorView!
    
    var APIURL:NSString = "" // Pass your api URL here and make json format for repsonse <Now lets test using the local JSON>
    
    var isTableViewScrollToBotton:Bool = false // Bool to check scroll of table view upto bottom
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        isApiCalling = false
        isTableViewScrollToBotton = false
        
        self.tableView.separatorColor = UIColor.darkGrayColor()
        self.tableView.separatorInset = UIEdgeInsetsZero
        
        // Refresh Controll For Refresh Data From Server
        self.refreshControl = UIRefreshControl(frame: CGRectMake(0, 0, self.view.frame.width, 40))
        self.refreshControl?.frame = CGRectMake(0, 0, 320, 40)
        self.refreshControl?.backgroundColor = UIColor.blackColor()
        self.refreshControl?.alpha=0.5
        self.refreshControl?.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        
        self.getDataUsingLocalJSONFile()
    }
    
    func refresh(sender:AnyObject)
    {
        // Method called when user pull table view down
        
        arrayRecordsForTableView.removeAllObjects()
        lastObjectIndex=0
        self.getDataUsingLocalJSONFile()
        
        // Code to refresh table view ( API CALL )
        // Use below function to display data via api call
        //self.callApi()
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Fetch Data from local json file
    func getDataUsingLocalJSONFile(){
        
        isApiCalling = true
        // You can find "response.json" file under JSON File Folder
        var jsonFilePath:NSString = NSBundle.mainBundle().pathForResource("test", ofType: "json")!
        
        // Convert JSON file data to NSData
        var jsonData:NSData = NSData(contentsOfFile: jsonFilePath)
        
        // Storing Responce Data in Dictionary
        var dicResponce:NSDictionary = NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions.MutableContainers, error: nil) as NSDictionary
        
        var arryResponceArray: NSMutableArray = dicResponce.objectForKey("data") as NSMutableArray
        
        // Loop will begin from lastObjectIndex
        var counter:Int = lastObjectIndex
        
        // Max Data To Download
        var dataLimit:Int = numberOfRecordsPerAPICall + lastObjectIndex
        
        // check whether datalimit does not exits total number of data.
        if(dataLimit>arryResponceArray.count){
            dataLimit = arryResponceArray.count
        }
        
        for (counter; counter<dataLimit; counter++) {
            arrayRecordsForTableView.addObject(arryResponceArray.objectAtIndex(counter))
        }
        
        self.refreshControl?.endRefreshing()
        lastObjectIndex += numberOfRecordsPerAPICall
        isApiCalling = false
        isTableViewScrollToBotton = false
        self.tableView.reloadData()
    }
    
    // MARK: - API Calling Methods
    func callApi() {
        
        self.isApiCalling = true
        // isApiCalling is used to determaine whether api call is running or not.
        
        var apiUrl:NSURL = NSURL(string: String(format: "%@&lastid=%d&limit=%d",APIURL, lastObjectIndex,numberOfRecordsPerAPICall)) // Make sure you have added your api url in "APIURL" before calling this function
        
        lastObjectIndex+=numberOfRecordsPerAPICall
        
        var request:NSURLRequest = NSURLRequest(URL: apiUrl, cachePolicy: NSURLRequestCachePolicy.UseProtocolCachePolicy, timeoutInterval: 30) as NSURLRequest
        
        let queue:NSOperationQueue = NSOperationQueue()
        
        NSURLConnection.sendAsynchronousRequest(request, queue: queue, completionHandler:{ (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            /* Your code */
            if((error) == nil){
                // Got API Responce
                var responceDic:NSDictionary = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers, error: nil) as NSDictionary
                
                if((responceDic.objectForKey("success") as NSString).isEqualToString("1")){
                    // API Positive Responce
                    
                    if (responceDic.objectForKey("data") != nil){
                        self.arrayRecordsForTableView.addObjectsFromArray(responceDic.objectForKey("data") as NSMutableArray)
                    }
                    self.refreshControl?.endRefreshing()
                    self.isTableViewScrollToBotton = false
                    self.tableView.reloadData()
                    self.isApiCalling = false
                }
            }else{
                // if error occured while downloading data.
                var alertFailedToDownloadData:UIAlertView = UIAlertView(title: "Error", message: "Failed To Donwload Data From Server. Please Try Again Later.", delegate: nil, cancelButtonTitle: "Ok", otherButtonTitles: "")
                alertFailedToDownloadData.show()
            }
        })
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        // Return the number of sections.
        
        // if we have no data availabel to display show message like below and return section 0
        if(arrayRecordsForTableView.count==0){
            let messageLabel = UILabel(frame: CGRectMake(0, 0, self.view.frame.width, self.view.frame.height))
            
            messageLabel.text = "No data is currently available. Please pull down to refresh.";
            messageLabel.textColor = UIColor.blackColor();
            messageLabel.numberOfLines = 2;
            messageLabel.textAlignment = NSTextAlignment.Center;
            messageLabel.font = UIFont.systemFontOfSize(20)
            messageLabel.sizeToFit()
            
            self.tableView.backgroundView = messageLabel;
            self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None;
            return 0
        }else{
            // Else Data available to display. So return 1
            self.tableView.backgroundView = nil;
            self.tableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
            return 1
        }
    }
    
    override func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if((scrollView.contentOffset.y+scrollView.frame.size.height)==scrollView.contentSize.height){
            
            if(isApiCalling==false){
                // while api Call is not in process
                isTableViewScrollToBotton = true
                self.tableView.reloadData()
                self.getDataUsingLocalJSONFile()
            }
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return arrayRecordsForTableView.count
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        // Return the Height For Row.
        return 100;
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell:TableViewCell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as TableViewCell
        
        cell.separatorInset = UIEdgeInsetsZero
        
        var currentData:NSDictionary = arrayRecordsForTableView.objectAtIndex(indexPath.row) as NSDictionary
        
        if (currentData.objectForKey("title") != nil){
            cell.txtLabel.text = currentData.objectForKey("title") as NSString
        }else{
            cell.txtLabel.text = "Failed To Download Data"
        }
        
        cell.lazyImageView.image = UIImage(named: currentData.objectForKey("image") as NSString)
        
        // Uncomment This code to download image Async
        /*
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
        if (currentData.objectForKey("image") != nil){
        var url:NSURL = NSURL(string: currentData.objectForKey("image") as NSString)! // pass your image url here
        
        var imageData :NSData = NSData(contentsOfURL: url)!
        
        cell.imgImageView.image = UIImage(data: imageData)
        }
        })
        */
        
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if(isTableViewScrollToBotton){
            // if tableview scroll to bottom then show footer view
            return 50
        }else{
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        var footerView:UIView = UIView(frame: CGRectMake(0, 0, self.tableView.frame.size.width, 50))
        
        footerView.backgroundColor = UIColor.clearColor()
        
        if(isTableViewScrollToBotton == true){
            footerView.backgroundColor = UIColor.blackColor()
            footerView.alpha = 0.5
            activityIndicator = UIActivityIndicatorView(frame: CGRectMake(footerView.frame.width/2-25,0, 50, 50)) as UIActivityIndicatorView
            activityIndicator.hidden=false
            activityIndicator.hidesWhenStopped = true
            activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.White
            activityIndicator.tintColor = UIColor.whiteColor()
            activityIndicator.startAnimating()
            footerView.addSubview(activityIndicator)
        }
        return footerView
    }
    /*
    override func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath) as UITableViewCell

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView!, canEditRowAtIndexPath indexPath: NSIndexPath!) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView!, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath!) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView!, moveRowAtIndexPath fromIndexPath: NSIndexPath!, toIndexPath: NSIndexPath!) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView!, canMoveRowAtIndexPath indexPath: NSIndexPath!) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
