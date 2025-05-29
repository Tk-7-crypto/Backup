/*
Class is Used to show Multi Invoice BNF for Opportunity
Create By : Himanshu Parashar
Date: 12 sep 2011 
*/

public with sharing class MI_BNF_Extension {
    //  -------------------------------------------------------------------------------
    //  Member variables
    //  -------------------------------------------------------------------------------
    //  MIBNF2__c record displayed on VF page
    private MIBNF2__c MasterBnf{get;set;}
    
    private set<Id> JoOppLineItemidSet;
    private set<Id> MIBNF_CompSet;
    
    //
    public List<MIBNF_Component__c> itemList{get; private set;}
    public List<OpportunityLineItem> oppAvailableProductsList{get;private set;}
    public String DeleteMIBNFCompID{get;set;}
    public Boolean isRevisedBNF{get;private set;}
    public User CurrentUser {get;private set;}
    private ApexPages.StandardController StandardController;
    public Boolean UserIsSysAdmin {get;private set;}
    public List<OpportunityLineItem> OLIItemList{get;private set;}    
    public List<MI_BNF_LineItem__c> MIBNFLineItemList{get;private set;}
    public Map<id,String> ProcessInstanceWorkitemMap{get;private set;}
    public Boolean isError{get;private set;} // Added By Himanshu Parashar : 15 Feb 2013
    PageReference oppView;
    public Map<String,AddressWrapper> MapAddressWrapper{get;set;}
    public Boolean ShowBillingScheduleButton {get; private set;}
    public Boolean isNewBnf {get; private set;}
    public String EditProductPageUrl {get; private set;}
    // updated by dheeraj kumar 20 April 2017
    private Map<id,boolean> mibnfCompIdtoisOwnerQueueMap {get;set;}
    public String mibnfCompIdtoisOwnerQueueMapJSON {get;private set;}
    private Set<String> excludedProducts;
    Public Integer noOfRecords{get; set;}
    Public Integer size{get;set;}
    Public Boolean displayPagination{get;set;}
    Public Boolean showMassUpdatePopUp{get;set;}
    public Boolean wbsCodeCheck {get; private set;}
    public Boolean isPrebillingOrgCode {get; private set;}
    public ApexPages.StandardSetController setCon {
        get{
            if(setCon == null){
                string queryString = 'Select Name,urgent_handling__c, MIBNF__c,MIBNF__r.Opportunity__c,  Id, Contract_Value__c,LastModifiedById,CreatedById,No_Pricing_Date_Update__c,'+ 
                                      'Comments__c, Bill_To__c, Sold_To__c, Sold_To_Local__c, Sold_To_SAP_Base_Code__c, BNF_Status__c,BNFName__c,Manual_Handling_in_SAP__c,Billing_Frequency__c,Revised_BNF_Date__c,'+
                                      'X2nd_Copy__c,Payment_Terms__c,Additional_Delivery_Date_Information__c,Addendum__c,Revised_BNF_Reason__c,Carbon_Copy_SAP_Contact__c,'+
                                      'X2nd_Copy_SAP_Base_Code__c,X2nd_Copy_SAP_Contact__c,Bill_To_SAP_Contact__c,Delivery_Date__c,Client_PO_Number__c,Is_PO_Required__c,'+
                                      'Additional_Billing_Date_Information__c,Ship_To_SAP_Contact__c,Ship_To__c,Cover_Sheet_SAP_Contact__c,Bill_To_SAP_Base_Code__c,Revised_BNF_Comment__c,'+
                                      'Ship_To_SAP_Base_Code__c,Invoice_Header_Text__c,Billing_Currency__c,Carbon_Copy_SAP_Base_Code__c,SAP_Contract__c,'+
                                      'cover_Sheet__c,Cover_Sheet_SAP_Base_Code__c,Carbon_Copy__c,Invoice_Default_Day__c,SAP_SD_Error_Message__c,CreatedDate,LastModifiedDate,BNF_Description__c,'+
                                      'MIBNF__r.Sales_Org_code__c,MIBNF__r.Revenue_Analyst__r.User__r.Id,Bill_To_Local__c,Ship_To_Local__c,X2nd_Copy_Local__c,'+
                                      'Cover_Sheet_Local__c,Carbon_Copy_Local__c,Bill_To_SAP_Contact_Local__c,Ship_To_SAP_Contact_Local__c,X2nd_Copy_SAP_Contact_Local__c,Cover_Sheet_SAP_Contact_Local__c,'+
                                      'Sales_Org_Code__c,Local_Printing__c, Comp_Revenue_Analyst__r.owner.type,Enabled_PaymentTerms_Bill_To__c, Revenue_Analyst__c From MIBNF_Component__c where MIBNF__c=\''+ MasterBNF.Id +'\'order by name';
                setCon = new ApexPages.StandardSetController(Database.getQueryLocator(queryString));
                noOfRecords = setCon.getResultSize(); 
                showMassUpdatePopUp = false;
                if(BNF_Settings__c.getInstance() != null && BNF_Settings__c.getInstance().No_Of_Records__c != null && noOfRecords > BNF_Settings__c.getInstance().No_Of_Records__c){
                    displayPagination = true; 
                    size = BNF_Settings__c.getInstance().No_Of_Records__c.intValue();
                }else{
                    displayPagination = false;
                    size = noOfRecords;
                }
                 setCon.setPageSize(size);
            }
            return setCon;
        }set;
    }
    
    /*Public List<Account> getAccounts(){
        List<Account> accList = new List<Account>();
        for(Account a : (List<Account>)setCon.getRecords())
            accList.add(a);
        return accList;
    }*/
    
    public pageReference refresh() {
        setCon = null;
        getMIBNFItems();
        setCon.setPageNumber(1);
        return null;
    }
    
    public Integer pageNumber {
        get {
            return setCon.getPageNumber();
        }
        set;
    }
  
    public void first() {
        setCon.first();
        getMIBNFItems();
    }
  
    public void last() {
        setCon.last();
        getMIBNFItems();
    }
  
    public void previous() {
        setCon.previous();
        getMIBNFItems();
    }
  
    public void next() {
        setCon.next();
        getMIBNFItems();
    }
    
    public void displayMassUpdate(){
        showMassUpdatePopUp = true;
    }
    
    //  -------------------------------------------------------------------------------
    //  Constructor function
    //  -------------------------------------------------------------------------------   
    public MI_BNF_Extension (ApexPages.StandardController controller) 
    {       
        this.StandardController = controller;
        this.MasterBNF = (MIBNF2__c)controller.getRecord();
        BNF_Settings__c bnfSetting = BNF_Settings__c.getInstance();
        excludedProducts = new Set<String>();
        if(bnfSetting.Excluded_Products__c != null) {
            excludedProducts = new Set<String>(bnfSetting.Excluded_Products__c.split('\\|'));
        }
        // updated by dheeraj kumar 20 April 2017
           this.mibnfCompIdtoisOwnerQueueMap = new Map<id,boolean>();
        // Check for revised bnf
        /*  if(MasterBNF.Addendum__c==true)
            isRevisedBNF=true;
        else
            isRevisedBNF=false;
        */    
        this.CurrentUser = [select Id,Profile.Name from User where Id = :userInfo.getUserId()];
        this.UserIsSysAdmin = this.CurrentUser.Profile.Name.toUpperCase().contains('SYSTEM ADMINISTRATOR');
        isNewBnf = false;
        EditProductPageUrl = '/apex/MI_BNFOpptyListLockedGridOld';
        try {
            if(BNF_Settings__c.getInstance().BNF_Opportunity_Threshold__c != null) 
            {                   
                if(Integer.valueOf(this.MasterBNF.Opportunity_Number__c) > BNF_Settings__c.getInstance().BNF_Opportunity_Threshold__c) 
                {
                    isNewBnf = true;
                    EditProductPageUrl = '/apex/MI_BNFOpptyListLockedGrid';
                } 
            } 
        } catch(Exception exp) {
             isNewBnf = false;
        }
        MIBNFLineItemDetails();
        getMIBNFItems();
      
        MIBNFCompAddressDetails();

 
    }
    
    public MI_BNF_Extension () 
    {  
        BNF_Settings__c bnfSetting = BNF_Settings__c.getInstance();
        excludedProducts = new Set<String>();
        if(bnfSetting.Excluded_Products__c != null) {
            excludedProducts = new Set<String>(bnfSetting.Excluded_Products__c.split('\\|'));
        }
        this.mibnfCompIdtoisOwnerQueueMap = new Map<id,boolean>();     
        MasterBNF = [select id,Opportunity__c,Opportunity_Number__c, Sales_Org_Code__c from MIBNF2__c where id=: ApexPages.currentPage().getParameters().get('id')];
        isNewBnf = false;
        try {
                if(BNF_Settings__c.getInstance().BNF_Opportunity_Threshold__c != null) 
                {                   
                    if(Integer.valueOf(this.MasterBNF.Opportunity_Number__c) > BNF_Settings__c.getInstance().BNF_Opportunity_Threshold__c) 
                    {
                        isNewBnf = true;
                    } 
                } 
        } catch(Exception exp) {
            isNewBnf = false;
        }
        Set<String> prebillingSalesOrgSet = new Set<String>{'MX02', 'GT01', 'CO01', 'CO71'};
        if(prebillingSalesOrgSet.Contains(this.MasterBNF.Sales_Org_Code__c)) {
            isPrebillingOrgCode = true;
        }
        MIBNFLineItemDetails();
        getMIBNFItems();     
        
    }
    
  
    
    //Get All the details
    public PageReference getMIBNFItems() {         
        itemList = new List<MIBNF_Component__c>();        
        //List<Account> accList = new List<Account>();
        for(MIBNF_Component__c a : (List<MIBNF_Component__c>)setCon.getRecords()) {
            itemList.add(a);
            System.debug(a.Name);
        }
            
        oppAvailableProductsList = new List<OpportunityLineItem>();
        //List<OpportunityLineItem> oliList=new List<OpportunityLineItem>();
        // updated by dheeraj kumar 20 april 2017
        /*itemList = new List<MIBNF_Component__c>([Select Name,urgent_handling__c, MIBNF__c,MIBNF__r.Opportunity__c,  Id, Contract_Value__c,LastModifiedById,CreatedById,No_Pricing_Date_Update__c,  
                                                 Comments__c, Bill_To__c, Sold_To__c, Sold_To_Local__c, Sold_To_SAP_Base_Code__c, BNF_Status__c,BNFName__c,Manual_Handling_in_SAP__c,Billing_Frequency__c,Revised_BNF_Date__c, 
                                                 X2nd_Copy__c,Payment_Terms__c,Additional_Delivery_Date_Information__c,Addendum__c,Revised_BNF_Reason__c,Carbon_Copy_SAP_Contact__c,
                                                  X2nd_Copy_SAP_Base_Code__c,X2nd_Copy_SAP_Contact__c,Bill_To_SAP_Contact__c,Delivery_Date__c,Client_PO_Number__c,
                                                  Additional_Billing_Date_Information__c,Ship_To_SAP_Contact__c,Ship_To__c,Cover_Sheet_SAP_Contact__c,Bill_To_SAP_Base_Code__c,Revised_BNF_Comment__c,
                                                  Ship_To_SAP_Base_Code__c,Invoice_Header_Text__c,Billing_Currency__c,Carbon_Copy_SAP_Base_Code__c,SAP_Contract__c, 
                                                  cover_Sheet__c,Cover_Sheet_SAP_Base_Code__c,Carbon_Copy__c,Invoice_Default_Day__c,SAP_SD_Error_Message__c,CreatedDate,LastModifiedDate,BNF_Description__c,
                                                  MIBNF__r.Sales_Org_code__c,MIBNF__r.Revenue_Analyst__r.User__r.Id,Bill_To_Local__c,Ship_To_Local__c,X2nd_Copy_Local__c,
                                                  Cover_Sheet_Local__c,Carbon_Copy_Local__c,Bill_To_SAP_Contact_Local__c,
                                                  Ship_To_SAP_Contact_Local__c,X2nd_Copy_SAP_Contact_Local__c,Cover_Sheet_SAP_Contact_Local__c,Sales_Org_Code__c,Local_Printing__c, Comp_Revenue_Analyst__r.owner.type 
                                                   From MIBNF_Component__c where MIBNF__c=:MasterBNF.Id order by name]);*/
        
        MIBNF_CompSet = new set<Id>();
         // updated by dheeraj kumar 20 april 2017
        for(MIBNF_Component__c MIBNF_Comp : itemList)
        {
            MIBNF_CompSet.add(MIBNF_Comp.id);
            mibnfCompIdtoisOwnerQueueMap.put(MIBNF_Comp.id, MIBNF_Comp.Comp_Revenue_Analyst__r.owner.type == 'Queue');            
        }
        
        mibnfCompIdtoisOwnerQueueMapJSON = JSON.serialize(mibnfCompIdtoisOwnerQueueMap);
        
        //get the list of junction objects      
        List<MI_BNF_LineItem__c> lstJo = [Select Id, Opportunity_Line_Itemid__c,MIBNF_Component__c From MI_BNF_LineItem__c 
                                          where MIBNF_Component__c in :MIBNF_CompSet];
        
        
        
        //put all the opplineitem ids in a set from the list of JO 
        JoOppLineItemidSet = new set<Id>();
        for (MI_BNF_LineItem__c master :lstJo)
        {
            JoOppLineItemidSet.add(master.Opportunity_Line_Itemid__c);
        }
        
         //show Available Products list 
         //Update by: Sneha Rathi Date: 21 Dec, 2012 - ER:0303 -- Added Therapy Area field
         oppAvailableProductsList =  new List<OpportunityLineItem>([Select Id,PricebookEntry.Name,Book_No__c,CurrencyISOCode,TotalPrice,Surcharge_Text__c,
                                                 Delivery_Media__c,PricebookEntry.ProductCode,Billing_Frequency__c,Proj_Rpt_Frequency__c,
                                                 Discount_Percentage_Formula__c,Product_Start_Date__c,Product_End_Date__c,Product_Invoice_Text__c,
                                                 Nbr_of_Users__c, Delivery_Country__c, Discount_Reason__c,PO_line_item_number__c, Invoice_Date__c, Revised_Price__c, Prebilling__c,
                                                 Cancel_Text__c, Sales_Text__c,MIBNF_Cancel__c, Therapy_Area__c, Project_Start_Date__c, Project_End_Date__c, PricebookEntry.Product2.Material_Type__c,Other_Ship_To_Address__r.Name, WBS_R_Element__c From OpportunityLineItem where opportunityid=:MasterBnf.Opportunity__c
                                                 and id not in:JoOppLineItemidSet and Product_Material_Type__c NOT IN :excludedProducts order by PricebookEntry.ProductCode asc, Product_Start_Date__c asc]);
        for(OpportunityLineItem oli : oppAvailableProductsList) {
            if(oli.PricebookEntry.Product2.Material_Type__c=='ZREP' && oli.Project_Start_Date__c != null && oli.Project_End_Date__c != null) {
                oli.Product_Start_Date__c = oli.Project_Start_Date__c;
                oli.Product_End_Date__c = oli.Project_End_Date__c;            
            }               
        }
        
        for(Integer i = 0 ; i < oppAvailableProductsList.size() ; i++) {
            if(!String.isEmpty(oppAvailableProductsList[i].WBS_R_Element__c)) {
                wbsCodeCheck = true;
            }
        }
        //Ghanshyam
        sortOLIList();
        return null;
    }
    
    //Ghanshyam
    public List<OLIWrapper> oliWrapperLst;
    private void sortOLIList(){
        
            oliWrapperLst = new List<OLIWrapper>();
            for(OpportunityLineItem oli : oppAvailableProductsList){
                oliWrapperLst.add(new OLIWrapper(oli));
            }
                
            oliWrapperLst.sort();
            oppAvailableProductsList.clear();
            for(OLIWrapper objWrapper : oliWrapperLst){
                oppAvailableProductsList.add(objWrapper.oli);
            }
    }
    
    //Ghanshyam
    public Class OLIWrapper implements Comparable{
        
        public OpportunityLineItem oli{get;set;}
        public OLIWrapper(OpportunityLineItem oli){
            this.oli = oli;
        }
        
        public Integer compareTo(Object objToCompare) {             
                                            
            if ((oli.PricebookEntry.ProductCode + oli.Product_Start_Date__c) > (((OLIWrapper)objToCompare).oli.PricebookEntry.ProductCode + ((OLIWrapper)objToCompare).oli.Product_Start_Date__c)) {            
            return 1; 
            } 
            if ((oli.PricebookEntry.ProductCode + oli.Product_Start_Date__c) < (((OLIWrapper)objToCompare).oli.PricebookEntry.ProductCode + ((OLIWrapper)objToCompare).oli.Product_Start_Date__c)) { 
            return -1; 
            } 
            return 0;
        }       
    }
    
    /* This Method Send User to new Invoice from MIBNF View Page */
    public PageReference NewCBNF()
    {
          
           oppView = new pageReference('/apex/MI_BNF_wiz_step2?mibnfid='+ MasterBNF.Id + '&oppid=' + MasterBNF.Opportunity__c + '&wz=1');
           
           oppView.setRedirect(true);
           return oppView;
     
        
    }
    
    /*//  Method to edit MIBNF
    public pageReference EditMIBNF()
    {
         Boolean IsEditable = true;
         for (MIBNF_Component__c MIBNF_Comp:itemList)
         {
             if (MIBNF_Comp.BNF_Status__c.toUpperCase().contains('PENDING') || 
                 MIBNF_Comp.BNF_Status__c == MDM_Defines.BnfStatus_Map.get('ACCEPTED') ||
                 MIBNF_Comp.BNF_Status__c == MDM_Defines.BnfStatus_Map.get('SAP_CONTRACT_CONFIRMED'))
             {
                 IsEditable = false;
             }
         }
         if (!IsEditable && !this.UserIsSysAdmin)
         {
             ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Multi Invoice Header cannot be edited once related BNF\'s have been approved.');
             ApexPages.addMessage(errMsg); 
             return null;
         }
         else
         {
             return this.StandardController.Edit();
         }
    }*/
    
    
    // This Method Delete Invoice
    public PageReference DeleteInvoice()
    {
           
           MIBNF_Component__c MIBNF_Comp= new MIBNF_Component__c(id=DeleteMIBNFCompID);
           
          try {
                delete MIBNF_Comp;
                getMIBNFItems();
                
                             
           } catch (Exception ex) {
               //show a message on page
              isError=true;
              ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Error Occurred while deleting BNF.');
              ApexPages.addMessage(errMsg); 
             return null;
              
               
           }

           return null;
        
    }
    
     // This Method Delete MIBNF
     public PageReference DeleteMIBNF()
     {
           
           MIBNF2__c MIBNF= new MIBNF2__c(id=this.MasterBnf.id);
           String MIBNFID=this.MasterBnf.id;            
          try {
                delete MIBNF;
                oppView = new pageReference('/' + MIBNFID.substring(0,3) + '/o');
           
                oppView.setRedirect(true);
                return oppView;
           } catch (Exception ex) {
               //show a message on page
           }

           return null;
        
    }
  
    /* Getter for the Delete MIBNFComp value */
    public String getDeleteMIBNFCompID() { return this.DeleteMIBNFCompID; }
    
    /* Setter for the Delete MIBNFComp value */
    public void setDeleteMIBNFCompID(String s) { this.DeleteMIBNFCompID = s;}
  
   public void MIBNFLineItemDetails()
   {
        set<Id> JoOppLineItemidSet = new set<Id>();
       Map<Id, MI_BNF_LineItem__c> MIBNFLineItemMap = new Map<Id, MI_BNF_LineItem__c>([Select Id, Opportunity_Line_Itemid__c,MIBNF_Component__c,CurrencyIsoCode 
                                       From MI_BNF_LineItem__c where MIBNF_Component__r.MIBNF__c = :this.MasterBnf.id]);
       MIBNFLineItemList=MIBNFLineItemMap.values();
       for (Id id : MIBNFLineItemMap.keySet()) {
                JoOppLineItemidSet.add(MIBNFLineItemMap.get(id).Opportunity_Line_Itemid__c);


       }


       // Show Product Details from OpportunityLineItem
      //Added By Sneha Rathi : 21 dec 2012 : Adding Therapy_Area__c field in query - Er-0303

       OLIItemList=[Select Id,PricebookEntry.Name,Book_No__c,CurrencyIsoCode,TotalPrice,Delivery_Media__c,PricebookEntry.ProductCode,Surcharge_Text__c,
                                                 Billing_Frequency__c,Proj_Rpt_Frequency__c, Discount_Percentage_Formula__c,Product_Start_Date__c,Product_End_Date__c,Sales_Text__c,
                                                 Product_Invoice_Text__c,Nbr_of_Users__c, Delivery_Country__c, Discount_Reason__c,PO_line_item_number__c, Invoice_Date__c, Revised_Price__c,Cancel_Text__c,
                                                 MIBNF_Cancel__c, Therapy_Area__c,PricebookEntry.Product2.Enabled_Sales_Orgs__c,PricebookEntry.Product2.Material_Type__c, Prebilling__c,
                                                 PricebookEntry.Product2.Item_Category_Group__c,PricebookEntry.Product2.ProductCode,Other_Ship_To_Address__r.Name, WBS_R_Element__c From OpportunityLineItem where id in:JoOppLineItemidSet order by PricebookEntry.Name ASC];  // Ghanshyam : Issue-07785 : sorting
       ShowBillingScheduleButton = false;
       if (isNewBnf)
       {
           for (OpportunityLineItem OLI:OLIItemList)
           {
               if(OLI.PricebookEntry.Product2.material_type__c == 'ZREP' || (OLI.PricebookEntry.Product2.Material_Type__c =='ZPUB' && OLI.PricebookEntry.Product2.Item_Category_Group__c == 'ZLIC'))
               {
                    ShowBillingScheduleButton = true;
               } 
           }
       }
   }
   
   
   public void MIBNFCompAddressDetails()
   {
        MapAddressWrapper=new Map<String,AddressWrapper>();
        set<id> AddressId_Set =new set<id>();
       
        //Get All the child comp
        Map<id,MIBNF_Component__c> MIBNF_comp=new Map<id,MIBNF_Component__c>([select id,name,bill_to__c,ship_to__c,cover_sheet__c,x2nd_copy__c,Carbon_Copy__c from MIBNF_Component__c where MIBNF__c= :this.MasterBnf.id]);
        
        ProcessInstanceWorkitemMap=new Map<id,String>();
        
        //Get All Process instance item
        for(ProcessInstanceWorkitem P_array : [select Id, ProcessInstance.TargetObjectId,ActorId from ProcessInstanceWorkitem where ProcessInstance.Status = 'Pending' and ProcessInstance.TargetObjectId in : MIBNF_comp.keyset()])
        { 
            if(ProcessInstanceWorkitemMap.containsKey(P_array.ProcessInstance.TargetObjectId))
            {
                String lstTemp='';
                lstTemp=ProcessInstanceWorkitemMap.get(P_array.ProcessInstance.TargetObjectId);
                lstTemp=lstTemp + ':' + P_array.ActorId;
                ProcessInstanceWorkitemMap.put(P_array.ProcessInstance.TargetObjectId,lstTemp);
            }
            else
            {
                String lstTemp ='';
                lstTemp=P_array.ActorId + ':';
                ProcessInstanceWorkitemMap.put(P_array.ProcessInstance.TargetObjectId,lstTemp);

            }
        }
        
        for(MIBNF_Component__c objMIBNF_Comp : MIBNF_comp.values())
        {
            if(!ProcessInstanceWorkitemMap.containskey(objMIBNF_Comp.id))
            {
                ProcessInstanceWorkitemMap.put(objMIBNF_Comp.id,'');
            }
            
            //Create set to Fetch Address Details.
            if(objMIBNF_Comp .Bill_To__c!=null)
                AddressId_Set.add(objMIBNF_Comp .Bill_To__c);
            if(objMIBNF_Comp .Ship_To__c!=null)
                AddressId_Set.add(objMIBNF_Comp .Ship_To__c);
            if(objMIBNF_Comp .Cover_Sheet__c!=null)
                AddressId_Set.add(objMIBNF_Comp .Cover_Sheet__c);
            if(objMIBNF_Comp .X2nd_Copy__c!=null)
                AddressId_Set.add(objMIBNF_Comp .X2nd_Copy__c);
            if(objMIBNF_Comp .Carbon_Copy__c!=null)
                AddressId_Set.add(objMIBNF_Comp .Carbon_Copy__c);

        }
        //Get All Address item
        Map<id,Address__c> AddressMap= new Map<id,Address__c>( [select Id,Name,SAP_Reference__c,Enabled_Sales_Orgs__c from Address__c where Id in :AddressId_Set]);
         //Iterate Component
        for(MIBNF_Component__c objMIBNF_Comp : MIBNF_comp.values())
        {
            Map<String,Address__c> map_Filled_Addresses = new Map<String,Address__c>();
            
            if(objMIBNF_Comp .Bill_To__c!=null && AddressMap.containskey(objMIBNF_Comp .Bill_To__c))
                map_Filled_Addresses.put('Bill To',AddressMap.get(objMIBNF_Comp .Bill_To__c));
       
            if(objMIBNF_Comp .ship_To__c!=null && AddressMap.containskey(objMIBNF_Comp .ship_To__c))
                map_Filled_Addresses.put('Ship To',AddressMap.get(objMIBNF_Comp .Ship_To__c));
            
            if(objMIBNF_Comp .X2nd_Copy__c!=null && AddressMap.containskey(objMIBNF_Comp .X2nd_Copy__c))
                 map_Filled_Addresses.put('Second Copy',AddressMap.get(objMIBNF_Comp .X2nd_Copy__c));
            
            if(objMIBNF_Comp .Carbon_Copy__c!=null && AddressMap.containskey(objMIBNF_Comp .Carbon_Copy__c))
                map_Filled_Addresses.put('Carbon Copy',AddressMap.get(objMIBNF_Comp .Carbon_Copy__c));

            if(objMIBNF_Comp .Cover_Sheet__c!=null && AddressMap.containskey(objMIBNF_Comp .Cover_Sheet__c))
                map_Filled_Addresses.put('Cover Sheet',AddressMap.get(objMIBNF_Comp .Cover_Sheet__c));
        
            MapAddressWrapper.put(objMIBNF_Comp .id,new Addresswrapper(map_Filled_Addresses));
     
        
        }
   }
    public void revenueAnalystField()
    {
		MIBNF2__c MasterBNF = [select id,Opportunity__c,Opportunity_Number__c, Sales_Org_Code__c from MIBNF2__c where id=: ApexPages.currentPage().getParameters().get('id')];
        for (MIBNF_Component__c mIBNF : [select Id, MIBNF__c, Revenue_Analyst__c from MIBNF_Component__c where MIBNF__c =:MasterBNF.Id])
        {
            ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Revenue Analyst is required when you submit BNF');
            ApexPages.addMessage(errMsg);
        }
        
    }
  
                  
}