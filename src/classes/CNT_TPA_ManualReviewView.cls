/**
 * Author: Neetu Bansal
 * Since: June 20, 2015
 * Name: CNT_TPA_ManualReviewView
 * Description: Controller class of TPA_ManualReviewView page
 *              Added by Neetu Bansal under Issue-07325
**/
global with sharing class CNT_TPA_ManualReviewView {
    // To store Vendor
    public Address__c vendor { get; set; }
    // To store Watch List records as JSON
    public String watches { get; set; }
    
    /**
     * Name: Default Constructor
     * Desc: To initialize values
    **/
    public CNT_TPA_ManualReviewView()
    {
        // To get the vendor Id
        String vendorId = ApexPages.currentPage().getParameters().get('vendorId');
        // Initialize list
        watches = JSON.serialize( new List<Watch_List__c>() );
        
        // Check if vendor id is not null
        if( vendorId != null && vendorId != '' )
        {
            // Get the vendor record
            List<Address__c> accounts = [ Select Id, Name, Vendor_Tier__c, Street__c, City__c, State__c, Country__c, PostalCode__c
                                        from Address__c where Id =: vendorId ];
            
            // Check if size > 0
            if( accounts.size() > 0 )
            {
                // Assign the record
                vendor = accounts[0];
                
                // Query all the watch list
                /*List<Watch_List__c> watchList = [ Select Id, Vendor_Address__r.Name, Always_Approved__c, Data_Asset_Category__c, Offering__c, Use__c, Vendor_Address__c, Country_of_Offering__c,
                                                    LastModifiedDate, LastModifiedBy.Name, TPA_Request__c from Watch_List__c where Vendor_Address__c =: vendor.Id
                                                    order by LastModifiedDate DESC ];
                // Store the JSON value
                watches = JSON.serialize( watchList );*/
            }
        }
    }
    
    /**
     * Name: getVendors
     * @param:
     * @return: String - Json of vendors
     * Desc: To get all the vendors
    **/
    public String getVendors()
    {
        // Get the vendor record
        List<Address__c> accounts = [ Select Id, Name, Vendor_Tier__c, Street__c, City__c, State__c, Country__c, PostalCode__c
                                    from Address__c where Is_TPA_Account__c = true
                                    AND (Vendor_Tier__c = 'Y' OR New_Vendor_Checklist__c = true) AND Primary_Vendor_Address__c = true order By Name ];
        
        // Return the JSON value
        return JSON.serialize( accounts );
    }
    
    /**
     * Name: searchWatchList
     * @param: selectedVendorId - Selected vendor Id
     * @return: List<Watch_List__c> - List of watch list for the vendor
     * Desc: To update all the watch list
    **/
    @remoteAction
    public static List<Watch_List__c> searchWatchList( List<String> selectedVendorId , String lastRecId)
    {
        /*Watch_List__c lastWatchListRecord;
        if(lastRecId != null)
            lastWatchListRecord = [Select Id,CreatedDate From Watch_List__c where Id =: lastRecId][0];
        */
        List<Watch_List__c> watchList;
        // Query all the watch list
        if(lastRecId != null){
            watchList = [ Select Id, Vendor_Address__r.Name, Always_Approved__c, Data_Asset_Category__c, Offering__c, Use__c, Vendor_Address__c, Country_of_Offering__c,
            LastModifiedDate, LastModifiedBy.Name,CreatedDate, TPA_Request__c from Watch_List__c where Vendor_Address__c IN : selectedVendorId 
            and Id >: lastRecId order by Id ASC Limit 5000 ];
        }
        else{
            watchList = [ Select Id, Vendor_Address__r.Name, Always_Approved__c, Data_Asset_Category__c, Offering__c, Use__c, Vendor_Address__c, Country_of_Offering__c,
            LastModifiedDate, LastModifiedBy.Name, TPA_Request__c from Watch_List__c where Vendor_Address__c IN : selectedVendorId order by Id ASC Limit 5000 ];
        }
        
        // Return the list
        return watchList;
    }
    
    /**
     * Name: submitApproval
     * @param: watchList - Json of watch list to be updated
     * @return:
     * Desc: To update all the watch list
    **/
    @remoteAction
    global static String submitApproval( String watchList)
    {
        // Deserialize the json to get watch list
        List<Watch_List__c> watches = (List<Watch_List__c>)JSON.deserialize( watchList, List<Watch_List__c>.Class );
        
        // To store vendor Id
        //String vendorId;
        System.debug(watches.size());
        // Check if watches.size() > 0
        if( watches.size() == 0 )
            return 'No Change';
            
        // Map to store old values
        // Key: Watch Id
        // Value: Watch Record
        /*Map<Id, Watch_List__c> watchMap = new Map<Id, Watch_List__c>([ Select Id, Always_Approved__c, Data_Asset_Category__c, Offering__c, Use__c, Country_of_Offering__c,
                                                                        LastModifiedDate, LastModifiedBy.Name, TPA_Request__c from Watch_List__c where Vendor_Address__c =: vendorId
                                                                        order by LastModifiedDate DESC ]);
        
        // List to be updated
        List<Watch_List__c> watchListToBeUpdated = new List<Watch_List__c>();
        
        // Iterate to check which records to be updated
        for( Watch_List__c watch : watches )
        {
            // Check if Map contains and old and new values are different
            if( watchMap.containsKey( watch.Id )
                && ( watchMap.get( watch.Id ).Always_Approved__c != watch.Always_Approved__c ))
            {
                // Add into list
                watchListToBeUpdated.add( watch );
            }
        }
        
        // Check if size > 0, update the list
        if( watchListToBeUpdated.size() > 0 )
        {
            update watchListToBeUpdated;
            return 'Success';
        }
        else
        {
            return 'No Change';
        }*/
        update watches;
        return 'Success';
    }
}
