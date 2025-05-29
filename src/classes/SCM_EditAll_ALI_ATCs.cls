/****************************************************
 * Purpose : To Edit Agreement Line Item in Bulk 
 * Modified By : Sandeep Kr Singhal 6 July 2012
*****************************************************/
public class SCM_EditAll_ALI_ATCs {
private String aLIId = '';
public List<wrapperClass> wrapList{get;set;}
public List<Agreement_Line_Item_ATCs__c> related_ALI_ATCS {get;set;}
    
    /*
    * Constructor 
    */
    public SCM_EditAll_ALI_ATCs()
    {   
        aLIId = '' ;
        aLIId = ApexPages.currentPage().getparameters().get('ALI_Id'); 
        /*
        * fetching all Agreement line item ATCs related to given ALI id
        */
        if(aLIId != null && aLIId != '')
        {
            List<Agreement_Line_Item_ATCs__c> related_ALI_ATCS = new List<Agreement_Line_Item_ATCs__c>();
            related_ALI_ATCS = [Select a.ATC_Code__c ,a.Termination_Date__c, a.Period_of_Non_Charge_Deliver_Start__c, a.Period_of_Non_Charge_Deliver_End__c, a.Non_Charge_deliver_of_ATC__c, a.Delivery_Frequency__c, 
                                a.Data_Period_Start__c, a.Data_Period_End__c From Agreement_Line_Item_ATCs__c a 
                                where a.Agreement_Line_Item__c = : aLIId order by ATC__r.ATC_Code__c ];
            
            wrapList = new List<wrapperClass>();                        
            for(Agreement_Line_Item_ATCs__c aliATC : related_ALI_ATCS)
            {
                wrapList.add( new wrapperClass(false,aliATC));  
            }
        }       
    }
    
    /*
    * to Update all changes made on Screen only if modify check box is checked against changes in Row 
    */
    public pageReference save()
    {   
        List<Agreement_Line_Item_ATCs__c> aliATStoUpdate = new List<Agreement_Line_Item_ATCs__c>(); 
        for(wrapperClass wrapObj : wrapList)
        {
            if(wrapObj.isSelected)
                {
                    aliATStoUpdate.add(wrapObj.aLI_ATC);
                }
        }
        try{
            if(aliATStoUpdate!= null && aliATStoUpdate.size()>0)
               update aliATStoUpdate;             
                      
        }                
        catch(Exception exp)
        {   ApexPages.addMessages(exp);
            return null;
            
        }
        return new PageReference('/'+aLIId);
    }
    
    public pageReference cancel()
    {
        return new PageReference('/'+aLIId); 
    }
    /*
    * To build Page Block Table of Agreement_Line_Item_ATCs object with check Box
    */
    public class wrapperClass
    {
        public boolean isSelected{get;set;}
        public Agreement_Line_Item_ATCs__c aLI_ATC {get;set;}
        
        public wrapperClass( boolean isChecked ,Agreement_Line_Item_ATCs__c aLIATC )
        {
            isSelected = isChecked;
            aLI_ATC = aLIATC;       
        }
         
    }
}