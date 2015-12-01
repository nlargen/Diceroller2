import UIKit
import WatchConnectivity
import Parse

class UserHomepageVC: UIViewController, WCSessionDelegate, UITableViewDataSource, UITableViewDelegate
{
    @IBOutlet weak var UserLabel: UILabel!
    @IBOutlet weak var theTableView: UITableView!
    var session : WCSession!
    override func viewDidLoad()
    {
        UserLabel.text = PFUser.currentUser()?.objectId
            super.viewDidLoad()
        
        if WCSession.isSupported()
        {
            self.session = WCSession.defaultSession()
            session.delegate = self
            session.activateSession()
        }
        
        //get the current rolls associated with this user
        let query = PFQuery(className:"Roll")
        query.whereKey("owner_id", equalTo: PhoneCore.currentUser)
        query.findObjectsInBackgroundWithBlock { (objects : [PFObject]?, error: NSError?) -> Void in
            if(objects != nil)
            {
                PhoneCore.theRowData = objects!
                self.theTableView.reloadData()
            }
            else
            {
                print("None Found")
            }
        }
        
        
    }
    
    
    func session(session: WCSession, didReceiveMessage message: [String : AnyObject])
    {
        let theMessage = message["aRoll"]!
        let parts = theMessage.componentsSeparatedByString(" -> ")
        print(theMessage)
        let roll = PFObject(className:"Roll")
        roll["owner_id"] = PhoneCore.currentUser
        roll["total"] = Int(parts[1])
        roll["Details"] = parts[0]
        roll.saveInBackgroundWithBlock
            {
                (success: Bool, error: NSError?) -> Void in
                if (success) {
                    print("error")
                } else {
                    // There was a problem, check error.description
                }
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return PhoneCore.theRowData.count

    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! customRollCell
        // Configure the cell...
        //update this code to fill the labels with the proper values
        cell.qtyLabel.text = " Quantity: \(PhoneCore.theRowData[indexPath.row].objectForKey("total")!)"
        cell.detailLabel.text = "Roll Details: \(PhoneCore.theRowData[indexPath.row].objectForKey("Details")!)"
        
        return cell
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
}
