public class BNFProductController {
    
    public Map<id,List<SelectOption>> DeliveryMedia_Map{get;private set;} // Added by Himanshu Parashar : 22 nov 2012 : Show only selected Delivery media for user
    public Map<id,List<SelectOption>> DeliveryFrequency_Map{get;private set;} // Added by Sam Duncan : 29 nov 2012 : Show only selected Delivery frequency for user
    public Map<id,List<SelectOption>> oliIdToTherapyAreaOptionsMap{get;private set;} // Added by Dheeraj -- Issue-11063 -- 10 July 2017
    
    // Added by Dheeraj -- Issue-10593 -- 23 march 2017 -- Start
    public String isProfitCenterReadOnlyListJSON {get; private set;}
    private List<Boolean> isProfitCenterReadOnlyList;
    public String revenueCountryMapJSON{get;set;}
    public List<SelectOption> profitCenterOptions {get;set;}
    public List<SelectOption> SaleTypePickListOptions {get;private set;}
    public List<SelectOption> RevenueTypePickListOption {get;private set;}
    private BNF_Settings__c bnfSetting;
    Boolean isTriggerExecuted = false;
    private Set<String> excludedProducts;
    Integer POValueCount=0;
    Integer PONullCount=0;
    public Id glossaryDocumentId{get; set;}
    private void setRevenueCountryList() {
       Map<String, Id> revenueCountryToRevenueCountryIdMap = new Map<String, Id>();
       List<Profit_Centre__c> regionList = [select id, name, (select id from Profit_Centres__r) from Profit_Centre__c where Profit_Center_Code_Chain__c like '%(TOTGEO)%' order by name];
       profitCenterOptions = new List<Selectoption>();
       profitCenterOptions.add(new Selectoption('', ''));
       for(Profit_Centre__c region : regionList) {
            if(region.Profit_Centres__r.size() == 0) {
               revenueCountryToRevenueCountryIdMap.put(region.name, region.id);
               profitCenterOptions.add(new Selectoption(region.id,region.name));
               
            }
       }
       if(revenueCountryToRevenueCountryIdMap.size() > 0) {
           revenueCountryMapJSON = JSON.serialize(revenueCountryToRevenueCountryIdMap);
       }      
    }
   // Added by Dheeraj -- Issue-10593 -- 23 march 2017 -- End
  
    public BNFProductController() {
        bnfSetting = BNF_Settings__c.getInstance();
        if(Trigger.isExecuting){
            isTriggerExecuted = true;
        }
    }

    public List <OpportunityLineItem> opptyLineItem2{get;set;}

    public BNFProductController(ApexPages.StandardController controller) {
        bnfSetting = BNF_Settings__c.getInstance();
        excludedProducts = new Set<String>();
        if(bnfSetting.Excluded_Products__c != null) {
            excludedProducts = new Set<String>(bnfSetting.Excluded_Products__c.split('\\|'));
        }
        // Added by Dheeraj -- Issue-10593 -- 23 march 2017 -- Start  
        List<Document> glossaryDocumentList = [SELECT Id FROM Document where DeveloperName = : MDM_Defines.Document_Dev_Name_IMSSFDCGlossary];
        if(glossaryDocumentList.size() > 0){
            glossaryDocumentId = glossaryDocumentList[0].Id;
        }
        setRevenueCountryList();
        isProfitCenterReadOnlyList = new List<boolean>();
        // Added by Dheeraj -- Issue-10593 -- 23 march 2017 -- End  
      
       String newid= System.currentPageReference().getParameters().get('newid');
       if( newid != null){
       
           bnf = [Select Name, X2nd_Address__c, Comments__c,Sales_Org_Code__c,RecordTypeId, Addendum__c from BNF2__c where id = :newid]; //--- add Comments by ej. temporary solution --->
           
        }else{
            bnf = [Select Name, X2nd_Address__c, Comments__c,Sales_Org_Code__c,RecordTypeId, Addendum__c from BNF2__c where id = :System.currentPageReference().getParameters().get('bnfid')];
        }   
        Id id = System.currentPageReference().getParameters().get('id');
        this.US_SalesOrg = (bnf.RecordTypeId !=  MDM_Defines.SAP_SD_Integrated_Record_Type_Id) ? true : false;      
        
        //Update by: Sneha Date: 21 Dec, 2012 : Added Therapy Area to query
        // Added by Himanshu Parashar : 13 march 2013 : querying Therapy_Area field
        // Added by Ritesh Gupta : Issue :07072 : add field Audit_Subscription_Status__c
        // Added by Dheeraj -- Issue-10593 -- 29 march 2017 -- ProfitCenter__c, PricebookEntry.Product2.Material_Group_1__c
        // Added by Dheeraj -- Issue-11063 -- 10 July 2017  -- PricebookEntry.Product2.Therapy_Class__c
        opptyLineItem2 = [Select ProfitCenter__c, PricebookEntry.Product2.Material_Group_1__c, Audit_Subscription_Status__c, Opportunity.Therapy_Area__c,PriceBookEntry.Product2.Delivery_Frequency__c ,PriceBookEntry.Product2.Delivery_Media__c,Opportunity.CEQActiveRelease__c,Discount_Percentage_Formula__c,Therapy_Area__c, PricebookEntry.Name, PricebookEntry.Product2.Material_Type__c,PricebookEntry.Product2.Offering_Group__c , PricebookEntry.Product2.Offering_Type__c , List_Price__c, Nbr_of_Users__c, Book_No__c,CurrencyISOCode,TotalPrice,Delivery_Media__c, Product_Invoice_Text__c, PricebookEntry.ProductCode,Billing_Frequency__c,Product_Start_Date__c,Product_End_Date__c, Proj_Rpt_Frequency__c,Discount_Reason__c,PO_line_item_number__c, Discount_Amount_Formula__c, Other_Ship_To__c, Billing_Date__c, Sale_Type__c, Revenue_Type__c, Invoice_Lag_to_Data_Period__c, Revised_Price__c, Cancel__c,Business_Type__c, Delivery_Date__c,PO_Number__c,Sales_Text__c, PricebookEntry.Product2.Therapy_Class__c,Delivery_Country__c, WBS_R_Element__c from OpportunityLineItem where OpportunityId = :id  and Product_Material_Type__c  NOT IN :excludedProducts order by PricebookEntry.ProductCode asc, Product_Start_Date__c asc];

        /*****************************************************************************************/
        // Added by Himanshu Parashar : 22 nov 2012 : Show only selected Delivery media for user
        DeliveryMedia_Map = new Map<id,List<SelectOption>>();
        DeliveryFrequency_Map = new Map<id,List<SelectOption>>();
        
        // Added by Dheeraj -- Issue-11063 -- 10 July 2017 
        oliIdToTherapyAreaOptionsMap = new Map<Id, List<SelectOption>>();
        // Delivery media default values from the OLI
        Schema.DescribeFieldResult fieldResultDeliveryMedia = OpportunityLineItem.Delivery_Media__c.getDescribe();
        List<Schema.PicklistEntry> pleDeliveryMedia = fieldResultDeliveryMedia.getPicklistValues();
        
        Schema.DescribeFieldResult fieldResultProj_Rpt_Frequency = OpportunityLineItem.Proj_Rpt_Frequency__c.getDescribe();
        List<Schema.PicklistEntry> pleProj_Rpt_Frequency = fieldResultProj_Rpt_Frequency.getPicklistValues();        
        
        // Added by Dheeraj -- Issue-11063 -- 10 July 2017
        Schema.DescribeFieldResult fieldResultTherapyArea = OpportunityLineItem.Therapy_Area__c.getDescribe();
        List<Schema.PicklistEntry> therapyAreaPickEntryList = fieldResultTherapyArea.getPicklistValues();              
        
        Schema.DescribeFieldResult fieldResultSaleType = OpportunityLineItem.Sale_Type__c.getDescribe();
        List<Schema.PicklistEntry> saleTypePicklistEntryList = fieldResultSaleType.getPicklistValues();
        
        Schema.DescribeFieldResult fieldResultrevenueType = OpportunityLineItem.Revenue_Type__c.getDescribe();
        List<Schema.PicklistEntry> revenueTypePicklistEntryList = fieldResultrevenueType.getPicklistValues();
        
        SaleTypePickListOptions = new List<SelectOption>();
        RevenueTypePickListOption = new List<SelectOption>();
        for(Schema.PicklistEntry f : saleTypePicklistEntryList){
            SaleTypePickListOptions.add(new SelectOption(f.getLabel(), f.getValue()));
        }
        
        for(Schema.PicklistEntry f : revenueTypePicklistEntryList){
            RevenueTypePickListOption.add(new SelectOption(f.getLabel(), f.getValue()));
        }
            
        for(OpportunityLineItem oli : opptyLineItem2)
        {
        	// Added by Dheeraj Kumar Issue-10593 -- 25 April 2017
            isProfitCenterReadOnlyList.add(oli.PricebookEntry.Product2.Material_Group_1__c != 'MAN');
            
            // Added by Himanshu Parashar : 13 march 2013 : Issue-01645 :: setting up default value to Opportunity therapy area    
            if(oli.Therapy_Area__c==null && oli.Opportunity.Therapy_Area__c!=null)
                        oli.Therapy_Area__c=oli.Opportunity.Therapy_Area__c;
                        
	        // Added by Dheeraj -- Issue-11063 -- 10 July 2017 -- Start 
	        List<SelectOption> therapyAreaoptionList = new List<SelectOption>();
	        therapyAreaoptionList.add(new SelectOption('','--None--'));
	        Set<String> therapyAreavaluesSet = new Set<String>();
	        if(oli.PricebookEntry.Product2.Therapy_Class__c == null || oli.PricebookEntry.Product2.Therapy_Class__c == '')
	        {
	            for(Schema.PicklistEntry pickEntry : therapyAreaPickEntryList)
	            {
	                therapyAreaoptionList.add(new SelectOption(pickEntry.getLabel(), pickEntry.getValue())); 
	            }
	        }
	        else
	        {
	            Map<String, String> therapyAreaKeyToValueMap = new Map<String, String>();                
	            for(Schema.PicklistEntry pickEntry : therapyAreaPickEntryList)
	            {
	               therapyAreaKeyToValueMap.put(pickEntry.getValue().substringBetween('[',']'), pickEntry.getValue()); 
	            }
	            
	            List<String> supportedTherapyAreaList = oli.PricebookEntry.Product2.Therapy_Class__c.split(':');
	            for (String therapyAreaOption : supportedTherapyAreaList)
	            {
	                if(therapyAreaKeyToValueMap.containsKey(therapyAreaOption)){
	                    therapyAreaoptionList.add(new SelectOption(therapyAreaKeyToValueMap.get(therapyAreaOption), therapyAreaKeyToValueMap.get(therapyAreaOption)));
	                    therapyAreavaluesSet.add(therapyAreaKeyToValueMap.get(therapyAreaOption));
	                }
	            }
	            if(oli.Therapy_Area__c != null && !therapyAreavaluesSet.contains(oli.Therapy_Area__c)) {
			    	therapyAreaoptionList.add(new SelectOption(oli.Therapy_Area__c, oli.Therapy_Area__c));
			    }
	        }
	        oliIdToTherapyAreaOptionsMap.put(oli.id,therapyAreaoptionList);
	        // Added by Dheeraj -- Issue-11063 -- 10 July 2017 -- End 
        
            List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption('','--None--'));       
            
            if (oli.PricebookEntry.Product2.Delivery_Media__c == null || oli.PricebookEntry.Product2.Delivery_Media__c == '')
            {
                for(Schema.PicklistEntry f : pleDeliveryMedia)
                {
                    options.add(new SelectOption(f.getLabel(), f.getValue())); 
                }
            }
            else
            {
                // Added by Himanshu parashar : 12 dec 2012 : Delivery frequencies from SAP
                Map<String,String> FieldsvaluesMap=new Map<String,String>();                
                for(Schema.PicklistEntry f : pleDeliveryMedia)
                {
                   FieldsvaluesMap.put(f.getValue().substringBetween('[',']'), f.getValue()); 
                }
                
                List<String> SupportedDeliveryMedia = oli.PricebookEntry.Product2.Delivery_Media__c.split(':');
                for (String DeliveryMediaOption : SupportedDeliveryMedia)
                {
                    if(FieldsvaluesMap.containsKey(DeliveryMediaOption))
                        options.add(new SelectOption(FieldsvaluesMap.get(DeliveryMediaOption),FieldsvaluesMap.get(DeliveryMediaOption)));
                }
            }
            DeliveryMedia_Map.put(oli.id,options);
            
            
            
            List<SelectOption> DeliveryFrequencyOptions = new List<SelectOption>();
            DeliveryFrequencyOptions .add(new SelectOption('','--None--'));       
            if (oli.PricebookEntry.Product2.Delivery_Frequency__c == null || oli.PricebookEntry.Product2.Delivery_Frequency__c == '')
            {
                 for(Schema.PicklistEntry f : pleProj_Rpt_Frequency)
                {
                    DeliveryFrequencyOptions.add(new SelectOption(f.getLabel(), f.getValue())); 
                }
            }
            else
            {
                // Added by Himanshu parashar : 12 dec 2012 : Delivery frequencies from SAP
                Map<String,String> FieldsvaluesMap=new Map<String,String>();                
                for(Schema.PicklistEntry f : pleProj_Rpt_Frequency)
                {
                     if(f.getLabel()!='Other')
                          FieldsvaluesMap.put(f.getLabel().substringBetween('[',']'), f.getLabel()); 
                }
                
                List<String> SupportedDeliveryFrequencies = oli.PricebookEntry.Product2.Delivery_Frequency__c.split(':');
                for (String DeliveryFrequencyOption : SupportedDeliveryFrequencies)
                {
                    if(FieldsvaluesMap.containsKey(DeliveryFrequencyOption))                    
                        DeliveryFrequencyOptions.add(new SelectOption(FieldsvaluesMap.get(DeliveryFrequencyOption),FieldsvaluesMap.get(DeliveryFrequencyOption)));
                }
            }
            DeliveryFrequency_Map.put(oli.id,DeliveryFrequencyOptions);
        }
        /*************************************************************************************/
        // Added by Dheeraj Kumar Issue-10593 -- 25 April 2017
		isProfitCenterReadOnlyListJSON = json.serialize(isProfitCenterReadOnlyList);

    }

     Static boolean validationError = false;
     BNF2__c bnf;
     boolean bDeliveryMedia;
     boolean testCheckbox;
     public boolean US_SalesOrg {get;private set;}
     
     
     
    // mine
     String Temp;
     //boolean Flag;
     static String RevType;
     
     public String getTemp()
     {
         return Temp;
     }
     
     public void setTemp(String Temp)
     {
        this.Temp=Temp;
     }
     

    /*
    public Boolean getFlag()
    {
        return this.Flag;
    }*/
    

    
    // -------------------------
    
    public PageReference testCheck() {
        testCheckbox =true;
        return null;
    }

    /*public PageReference setDeliveryMediaAll() {
           //this.opptyLineItem[0].TotalPrice = 00000.0;
          //opptyLineItem[1].Book_No__c = 'Test';
          bnf.Comments__c = 'Duh';
          
         //PageReference reload = new PageReference('/apex/BNFOpptyList?id=006T0000003niSn&bnfid=a06T0000000nmlX');
         //reload.setRedirect(true); 

        //setDeliveryMediaOpt(true);
        
        return null;
    }*/


    public PageReference cancel() {
       String newid = System.currentPageReference().getParameters().get('newid');

       if(newid == null){
           newid= System.currentPageReference().getParameters().get('bnfid');

       }
       
        PageReference cancel = new PageReference('/' + newid);
        //cancel.setRedirect(true); 
                validationError = false;
        return cancel;
    }
    
    public PageReference savePartial(){
        try{
            update opptyLineItem2;
            validationError = false;
        }
        catch(DmlException ex){
            ApexPages.addMessages(ex);
            validationError = true;
            return null;
            
        }
        
        //get Newid
        String newid= System.currentPageReference().getParameters().get('newid');
        String url;
      
        if(newid != null){
            url = '/' + newid;
        }else{
            String bnfid= System.currentPageReference().getParameters().get('bnfid');            
            url = '/' + bnfid;       
        }  
        
        PageReference submitForApproval = new PageReference(url);             
        submitForApproval.setRedirect(true);  
        return submitForApproval;
    }

      public PageReference save() {
          //update Opportunity Line Item
          /**
          if(bDeliveryMedia == true){
              opptyLineItem[0].Delivery_Media__c = 'Email';
          
          }
          */
          
          
          if(uiRequiredFieldChck()){
              return null;
          } 

          /*for (OpportunityLineItem ol:opptyLineItem){
            ol.Product_End_Date__c = date.today();
            ol.Product_Start_Date__c = date.today();
          }*/
          boolean Val = true;
          boolean BillingDateError = false;
          boolean DeliveryDateError = false;
          boolean ListPriceError=false; // List Price Validation :: Date : 29 Dec 2011 :: Update By: Himanshu Parashar
          boolean profitCenterError = false; //updated by Dheeraj Kumar Issue-10593
          
          for(Integer i=0;i<opptyLineItem2.size();i++)
          {
              if((opptyLineItem2[i].Revenue_Type__c=='Ad Hoc')&&(opptyLineItem2[i].Billing_Date__c==null))
              {
                  Val = false;
                 // Temp[i]='Please enter a Value.';
                  //opptyLineItem[i].Billing_Date__c.addError('Check');
                  //return null;
//                  opptyLineItem                  
              }                  
              if((opptyLineItem2[i].Billing_Frequency__c=='Once')&&(opptyLineItem2[i].Billing_Date__c==null))
              {
                  BillingDateError = true;                  
              }      
              if((opptyLineItem2[i].Proj_Rpt_Frequency__c=='Once [O]')&&(opptyLineItem2[i].Delivery_Date__c==null) && bnf.RecordTypeId==MDM_Defines.SAP_SD_Integrated_Record_Type_Id)
              {
                  DeliveryDateError = true;                  
              }
              
               // List Price Validation
              // Date : 18 jan 2012
              // Update By: Himanshu Parashar
              //if((opptyLineItem2[i].List_Price__c<opptyLineItem2[i].TotalPrice) && bnf.RecordTypeId==MDM_Defines.SAP_SD_Integrated_Record_Type_Id)
              if(opptyLineItem2[i].List_Price__c!=null && (opptyLineItem2[i].Opportunity.CEQActiveRelease__c == null || opptyLineItem2[i].Opportunity.CEQActiveRelease__c == 0) && (opptyLineItem2[i].List_Price__c.setScale(2, system.roundingMode.HALF_UP)<opptyLineItem2[i].TotalPrice.setScale(2, system.roundingMode.HALF_UP) ) && bnf.RecordTypeId==MDM_Defines.SAP_SD_Integrated_Record_Type_Id)
              {
                  ListPriceError = true;                  
              }
              // updated by Dheeraj Kumar Issue-10593
              if(!Trigger.isExecuting && opptyLineItem2[i].PricebookEntry.Product2.Material_Group_1__c =='MAN' && opptyLineItem2[i].ProfitCenter__c == null) {
              		profitCenterError = true;
              		opptyLineItem2[i].ProfitCenter__c.addError('Please Enter Profit Center');
        	  }           
          }
          
          if (BillingDateError && !isTriggerExecuted)
          {
              ApexPages.Message myMsg2 = new ApexPages.Message(ApexPages.Severity.ERROR,'Billing date is mandatory when billing frequency "Once" is selected.');
              ApexPages.addMessage(myMsg2);                       
              PageReference pageRef = ApexPages.currentPage();
          }      
          if (DeliveryDateError && !isTriggerExecuted)
          {
              ApexPages.Message myMsg2 = new ApexPages.Message(ApexPages.Severity.ERROR,'Delivery date is mandatory when delivery frequency "Once" is selected.');
              ApexPages.addMessage(myMsg2);                       
              PageReference pageRef = ApexPages.currentPage();
          }                    
          if(Val==false && !isTriggerExecuted)
          {          
              ApexPages.Message myMsg2 = new ApexPages.Message(ApexPages.Severity.ERROR,'Please enter Billing Date for Ad Hoc Product');
              ApexPages.addMessage(myMsg2);                       
              PageReference pageRef = ApexPages.currentPage();                    
             // Flag=True;
        //      return null;
          }
          
              
          // List Price Validation
          // Date : 29 Dec 2011
          // Update By: Himanshu Parashar
          if (ListPriceError && !isTriggerExecuted)
          {
              ApexPages.Message myMsg2 = new ApexPages.Message(ApexPages.Severity.ERROR,'List price cannot be less than sales price.');
              ApexPages.addMessage(myMsg2);                       
              return null;
             
          } 
          // updated by Dheeraj Kumar Issue-10593
          if (Val==false || BillingDateError || DeliveryDateError || profitCenterError)
          {
              return null;
          }
          if(!isTriggerExecuted){
              try{
                  update opptyLineItem2;
                  validationError = false;
              }
              catch(DmlException ex){
                  ApexPages.addMessages(ex);
                  validationError = true;
                  return null;
                  
              }

              //get Newid
              String newid= System.currentPageReference().getParameters().get('newid');
              String url;
              
              
              if(newid != null){
                  //url = '/servlet/servlet.Integration?lid=01N70000000DMjzEAG' + '&newid=' + newid;
                  url = '/' + newid;
                  
              }else{
                  String bnfid= System.currentPageReference().getParameters().get('bnfid');            
                  url = '/' + bnfid;       
              }  
              
              PageReference submitForApproval = new PageReference(url);
              //  PageReference submitForApproval = new PageReference('yahoo.com');               
              submitForApproval.setRedirect(true); 
              
              return submitForApproval;
          }
          else{
              return new PageReference('/');
          }
    }
    
    public Boolean uiRequiredFieldChck(){
        Boolean isError = false;
        for(OpportunityLineItem oli : opptyLineItem2){
            if(oli.PricebookEntry.Product2.Material_Type__c=='ZPUB'){
                if(oli.Product_Start_Date__c == Null){
                    isError = true;
                    if(!isTriggerExecuted)
                        oli.Product_Start_Date__c.addError('You must enter a value');
                }
                if(oli.Product_End_Date__c == Null){
                    isError = true;
                    if(!isTriggerExecuted)
                        oli.Product_End_Date__c.addError('You must enter a value');
                }
            }
            if(oli.Delivery_Media__c == Null){
                isError = true;
                if(!isTriggerExecuted)
                    oli.Delivery_Media__c.addError('Value is required'); 
            }
            if(oli.Proj_Rpt_Frequency__c == Null){
                isError = true;
                if(!isTriggerExecuted)
                    oli.Proj_Rpt_Frequency__c.addError('Value is required');
            }
            if(oli.Billing_Frequency__c == Null){
                isError = true;
                if(!isTriggerExecuted)
                    oli.Billing_Frequency__c.addError('You must enter a value'); 
            }
            if(oli.List_Price__c == Null && oli.PricebookEntry.Product2.Offering_Type__c !='Management Consulting' && 
               oli.PricebookEntry.Product2.Offering_Type__c != System.Label.CES_TOT_Offering_Type && US_SalesOrg == false ){
                   isError = true;
                   if(!isTriggerExecuted)
                       oli.List_Price__c.addError('You must enter a value');                                 
               }
            if(oli.Billing_Date__c == Null && oli.Revenue_Type__c == 'Ad Hoc'){
                isError = true;
                if(!isTriggerExecuted)
                    oli.Billing_Date__c.addError('You must enter a value');
            }
            if(oli.Sale_Type__c == Null){
                isError = true;
                if(!isTriggerExecuted)
                    oli.Sale_Type__c.addError('You must enter a value');
            }
            if(oli.Revenue_Type__c == Null){
                isError = true;
                if(!isTriggerExecuted)
                    oli.Revenue_Type__c.addError('You must enter a value'); 
            }
            if(oli.Therapy_Area__c == Null){
                isError = true;
                if(!isTriggerExecuted)
                    oli.Therapy_Area__c.addError('You must enter a value');  
            }
            if(oli.Audit_Subscription_Status__c == Null && oli.PricebookEntry.Product2.Offering_Type__c == 'National Tracking'){
                isError = true;
                if(!isTriggerExecuted)
                    oli.Audit_Subscription_Status__c.addError('You must enter a value');  
            }
            //13742 - PO Line item number must be a number and values to either be null or have a value on all records
            if(oli.PO_line_item_number__c != Null ){
                POValueCount++;
                if(!oli.PO_line_item_number__c.isNumeric()){
                    isError = true;
                    if(!isTriggerExecuted)
                        oli.PO_line_item_number__c.addError('PO Line Item Number should be filled Numbers only');
                }
            }else{
               PONullCount++;
            }
            if(POValueCount > 0 && PONullCount > 0){
                isError = true;
                if(!isTriggerExecuted)
                    oli.PO_line_item_number__c.addError('PO Line Item Number should be filled or blank on all Products');
            } 
        }
        POValueCount=0;
        PONullCount=0;
        return isError;
    }
    
    public void seteBNF(Id eBNFId){
        bnf = [Select Name, X2nd_Address__c, Comments__c,Sales_Org_Code__c,RecordTypeId, Addendum__c from BNF2__c where id = :eBNFId];
    }
    

      public void setDeliveryMediaOpt(boolean bArg){
          bDeliveryMedia = bArg;               
      }
      
      public boolean getDeliveryMediaOpt(){

              return bDeliveryMedia;
          
      }
       public BNF2__c getBNF(){
            return bnf;
        }   
        
       public void setOpportunityLineItem(List<OpportunityLineItem> lineItems){
           opptyLineItem2 = lineItems;
       }
       
       public List<OpportunityLineItem> getOpportunityLineItem2() {
       

        
        return opptyLineItem2;
    }
    // COde is commented as it is already separated out in TEST Class
/*
public static testMethod void testMyController() {
        
        Id bnfid = [select id from BNF2__c limit 1].Id;
        
        
        
        PageReference pageRef = new PageReference('Page.BNFProductController');
        pageRef.getParameters().put('bnfid', bnfid);
        Test.setCurrentPage(pageRef);
        ApexPages.standardController controller = new ApexPages.standardController(new BNF2__c());
        BNFProductController extension = new BNFProductController(controller);
        
        extension.testCheck();
        
        
        
        ApexPages.currentPage().getParameters().put('bnfid',bnfid);
        extension = new BNFProductController(controller);
        extension.setOpportunityLineItem([Select o.WBS__c, o.UnitPrice, o.TotalPrice, o.Territory__c, o.SystemModstamp, o.SubPractice_Area__c, o.SortOrder, o.Service_Line__c, o.ServiceDate, o.Revenue_Comments__c, o.Quantity, o.Proj_Rpt_Frequency__c, o.Product_Invoice_Text__c, o.PricebookEntryId, o.Practice_Area__c, o.Other_Ship_To__c, o.OpportunityId, o.Net_Price__c, o.Nbr_of_Users__c, o.List_Price__c, o.ListPrice, o.Legacy_Opportunity_LineItemId__c, o.LastModifiedDate, o.LastModifiedById, o.IsDeleted, o.Invoice_Date__c, o.Id, o.HasSchedule, o.HasRevenueSchedule, o.HasQuantitySchedule, o.Gross_Q4_Value__c, o.Gross_Q3_Value__c, o.Gross_Q2_Value__c, o.Gross_Q2_NY_Value__c, o.Gross_Q1_Value__c, o.Gross_Q1_NY_Value__c, o.Discount_Reason__c, o.Discount_Percentage_Formula__c, o.Discount_Amount_Formula__c, o.Description, o.Delivery_Media__c, o.Product_Start_Date__c, o.Product_End_Date__c, o.CurrencyIsoCode, o.CreatedDate, o.CreatedById, o.Business_Type__c, o.Business_Line__c, o.Book_No__c, o.Billing_Frequency__c, Billing_Date__c, Sale_Type__c, Revenue_Type__c, Invoice_Lag_to_Data_Period__c,Delivery_Date__c From OpportunityLineItem o Limit 20]);
        PageReference dummy = extension.save();
        List<OpportunityLineItem> dummyList = extension.getOpportunityLineItem2();
     //   extension.setDeliveryMediaAll();
        dummy = extension.cancel();
        extension.setDeliveryMediaOpt(true);
        
        extension.setTemp('Temp');
        String temp = extension.getTemp();
        
        


        

    }
    
public static testmethod void t1()
{
  CLS_ProductionReference Convertor = new CLS_ProductionReference();
  Integer iTest = Convertor.CalculateElapsedMinsThisYear();
  system.debug('Mins this year: '+ iTest.format());
  String sOutput = Convertor.ConvertToRadix34(364883);
  system.debug('Output: '+ sOutput);
  system.assertEquals('AAMV',sOutput);
}

public static testmethod void t2() 
  {
    Datetime strDate = System.now();  
    //  Create a test account
  Account acct1 = new Account(Name='SPO BT Test Account');
  insert acct1;
  List<Opportunity> InsertOppList = new List<Opportunity>();
  List<OpportunityLineItem> InsertOLIList = new List<OpportunityLineItem>();
  List<OpportunityLineItemSchedule> InsertOLISList = new List<OpportunityLineItemSchedule>();
  Map<String,Double> Revenue_Map = new Map<String,Double>();
  //  Setup test parameters
  Integer NumTestOpps = 10;
  Integer iNumSchedules = 18;
  for (Integer i=0;i<NumTestOpps;i++)
  {
    //  Create a test opportunity
    Opportunity oppty1 = new Opportunity(Name = 'SPO BT Test Oppty');
    oppty1.StageName = '1. Identifying Opportunity';
    oppty1.CloseDate = System.today();
    oppty1.AccountId = acct1.Id;
    oppty1.Budget_Available__c = 'Yes';
    oppty1.CurrencyIsoCode = 'USD';
    InsertOppList.add(oppty1);
  }
  insert InsertOppList;
  
  //****Jeganmohan N 09-25-11, to resolve 'Too many SOQL queries: 101' error while PROD migration
  Set<Id> Opp_Id_Set = new Set<Id>();
  PricebookEntry PE1 = [select Id, CurrencyIsoCode from PricebookEntry where CurrencyIsoCode = 'USD' and IsActive = true limit 1][0];
  for (Opportunity NewOpp:InsertOppList)
  {
    Id opptyId = NewOpp.Id;
    Opp_Id_Set.add(opptyId);
    //  Add a line item to the opportunity
    OpportunityLineItem add1_oli = new OpportunityLineItem();
    add1_oli.OpportunityId = opptyId;    
    add1_oli.PricebookEntryId = PE1.Id;
    add1_oli.Quantity = 1.00;
    add1_oli.UnitPrice = 10000;
    InsertOLIList.add(add1_oli);
  }
  insert InsertOLIList;
  for (OpportunityLineItem OLI:InsertOLIList)
  {
    //  Create 18 schedules to cover 18 months from the first month of the current year
    Integer RevFactor = 1;
    Double dRevenueAmount = RevFactor*1000.00;
    Revenue_Map.put(OLI.Id,dRevenueAmount);
    RevFactor = RevFactor + 2;
    Date strScheduleDate = Date.valueOf(String.valueOf(strDate.year())+'-01-15 00:00:00');    
    for (Integer i = 0; i < iNumSchedules; i++) 
    {
      OpportunityLineItemSchedule OliSched = new OpportunityLineItemSchedule();
      OliSched.OpportunityLineItemId = OLI.Id;
      OliSched.Type = 'Revenue';
      OliSched.Revenue = dRevenueAmount;
      OliSched.ScheduleDate = strScheduleDate;
      strScheduleDate = strScheduleDate.addMonths(1);
      InsertOLISList.add(OliSched); 
    }
  }
  insert InsertOLISList;
  
  //****Jeganmohan N 09-25-11, to resolve 'Too many SOQL queries: 101' error while PROD migration
  List<Opportunity> Opp_Array_All = new List<Opportunity>([select Id, Amount from Opportunity where Id in : Opp_Id_Set]);
  
  for (OpportunityLineItem NewOLI:InsertOLIList)
  {
    //  Retrieve the OpportunityLineItem which should now have been touched by the workflow
    //  which modifies the OpportunityLineItem.Schedule_Update_Dummy__c field
    OpportunityLineItem TestOli = [select Id,OpportunityId, Gross_Q1_Value__c,Gross_Q2_Value__c,Gross_Q3_Value__c,Gross_Q4_Value__c,Gross_Q1_NY_Value__c,Gross_Q2_NY_Value__c, Delivery_Date__c from OpportunityLineItem where Id = :NewOLI.Id][0];
    //Opportunity TestOpp = [select Id, Amount from Opportunity where Id = :TestOli.OpportunityId][0];
    //  Check that the quarterly values have all been calculated after the workflow has touched the OpportunityLineItem
    Double Revenue = Revenue_Map.get(TestOli.Id);
    for (Opportunity TestOppty:Opp_Array_All)
    {
        if(TestOli.OpportunityId == TestOppty.Id)
        {
            System.assertEquals(TestOppty.Amount,Revenue*iNumSchedules);
        }
    }
    System.assertEquals(Revenue*3,TestOli.Gross_Q1_Value__c);
    System.assertEquals(Revenue*3,TestOli.Gross_Q2_Value__c);
    System.assertEquals(Revenue*3,TestOli.Gross_Q3_Value__c);
    System.assertEquals(Revenue*3,TestOli.Gross_Q4_Value__c);
    System.assertEquals(Revenue*3,TestOli.Gross_Q1_NY_Value__c);
    System.assertEquals(Revenue*3,TestOli.Gross_Q2_NY_Value__c);
  }
  //  Test that line items whose schedules have been deleted have the correct values in the summary fields
  /*delete InsertOLISList;
  for (OpportunityLineItem NewOLI:InsertOLIList)
  {
    OpportunityLineItem TestOli = [select Id,OpportunityId, Gross_Q1_Value__c,Gross_Q2_Value__c,Gross_Q3_Value__c,Gross_Q4_Value__c,Gross_Q1_NY_Value__c,Gross_Q2_NY_Value__c from OpportunityLineItem where Id = :NewOLI.Id][0];
    System.assertEquals(0,TestOli.Gross_Q1_Value__c);
    System.assertEquals(0,TestOli.Gross_Q2_Value__c);
    System.assertEquals(0,TestOli.Gross_Q3_Value__c);
    System.assertEquals(0,TestOli.Gross_Q4_Value__c);
    System.assertEquals(0,TestOli.Gross_Q1_NY_Value__c);
    System.assertEquals(0,TestOli.Gross_Q2_NY_Value__c);  
  }*/
  /*}  */  
     // Commented by Sandeep Date 8 August for Task ( to delete Classes& triggers of CAM ) Assigned By Sam
   /* @future(callout=true)
    public static void CAM_Callout(Set<Id> OppId_Set)
    {
        for (Opportunity O:[select Id, From_Opportunity__c,CEQActiveRelease__c from Opportunity where Id in :OppId_Set])
        {
            if (O.From_Opportunity__c != null && O.CEQActiveRelease__c != null && O.CEQActiveRelease__c > 0)
            {
                //  Newly cloned opportunity Id = O.Id
                //  Id of opportunity from which clone was created = O.From_Opportunity__c
                 
                    Blob b = Blob.valueOf('');      
          //   String release=String.valueOf (opp2.CEQActiveRelease__c);
             String release='1';
             String operationType='copyCart';
                String soapUrl='';
                String startconfiguration='';
                 String xmlData = EncodingUtil.base64Encode(b);
                CAMWS.cartSOAP cart= new CAMWS.cartSOAP();
                String resultXML=getCartSessionXML( O.From_Opportunity__c, O.Id,release,operationType,soapUrl,startconfiguration);
                String url= cart.runUI(resultXML,xmlData); 
                  
         
            }
         }
    }
    */
public static String getCartSessionXml(Id opportunityId, Id newOpportunityId, String release, String operationType, String soapUrl,String startconfiguration) {
          //Opportunity opp = [SELECT Description, AccountId FROM Opportunity where Id = :opportunityId];
            Opportunity opp = [SELECT Name,Description, AccountId, OwnerId,LastModifiedById, Type, CurrencyIsoCode, StageName, Discount_Approval_Requested__c, Discount_Approval_Status__c, Main_Delivery_Country__c, Test_Oppty__c FROM Opportunity where Id = :opportunityId];
            Account acc;
            User usr;
          String a = '';
          String profile = '';
          if (opp.AccountId!=null)
              acc = [SELECT Id, Name, Client_Segment__c, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, ShippingCountry From Account where Id = :opp.AccountId];

          if(opp.OwnerId !=null)
              usr = [SELECT Configurator_User_Access_Commerce__c,Country,Discount_Approver__c,LanguageLocaleKey,LocaleSidKey FROM User where Id = :opp.LastModifiedById];
            
          //set user profile based on custom user attributes  
          if(usr.Configurator_User_Access_Commerce__c == true && usr.Discount_Approver__c == true){
            profile='APRVCONF'; 
          }else if(usr.Configurator_User_Access_Commerce__c == false && usr.Discount_Approver__c == true){
            profile='APRVNONCONF';
          }else if(usr.Configurator_User_Access_Commerce__c == false && usr.Discount_Approver__c == false){
            profile='SALESNONCONF';
          }else if(usr.Configurator_User_Access_Commerce__c == true && usr.Discount_Approver__c == false){
            profile='SALESCONF';
          }
          String status='DRAFT';
          
          //set status based on approval status
          if(opp.Discount_Approval_Status__c != null){
              if(opp.Discount_Approval_Status__c.equals('Approved')){
                  status = 'APRVD';
               }else if(opp.Discount_Approval_Status__c.equals('Pending') || opp.Discount_Approval_Status__c.equals('Approved') || opp.Discount_Approval_Status__c.equals('New') || opp.Discount_Approval_Status__c.equals('Reassigned')){
                  status = 'AWA';
                }
          }
          if(opp.Test_Oppty__c)
              status='TEST';
          
        //  Default settings for modelName and model Release 
        // These may change depending on the user info object in salesforce
          
          //String defaultModel='SFDCModel';
         // String modelRelease='1';
         // String themename='Salesforce';
         // String cartDomain='-';
    
          String l = '\n';
          XmlStreamWriter w = new XmlStreamWriter();
          w.writeStartElement(null, 'cartSession', null);

          // Cart session standard settings
          
       
          
          w.writeCharacters(l);
          w.writeStartElement(null, 'cartSessionSettings', null);
          w.writeCharacters(l);
          w.writeStartElement(null, 'operationType', null);
          w.writeCharacters(operationType);
          w.writeEndElement();
          w.writeCharacters(l);
          w.writeStartElement(null, 'lazyLoading', null);
          w.writeCharacters('yes');
          w.writeEndElement();
          w.writeCharacters(l);
          w.writeStartElement(null, 'cartId', null);
          w.writeCharacters(opportunityId);
  
          w.writeEndElement();
          w.writeCharacters(l);
          // change for opportunity cloning 
          
          w.writeStartElement(null,'targetCartId', null);
          w.writeCharacters(newOpportunityId);
          w.writeEndElement();
          w.writeCharacters(l);
          // chage for Opp Clonin ends here
    
       
          w.writeStartElement(null, 'cartRelease', null);
          w.writeCharacters(release);
          w.writeEndElement();
          w.writeCharacters(l);
          w.writeStartElement(null, 'modelName', null);
          w.writeCharacters('');
          w.writeEndElement();
          w.writeCharacters(l);
         
        
          w.writeStartElement(null, 'modelRelease', null);
          w.writeCharacters('');
          w.writeEndElement();
          w.writeCharacters(l);
          w.writeStartElement(null, 'theme', null);
          w.writeCharacters('');
          w.writeEndElement();
          w.writeCharacters(l);
          w.writeStartElement(null, 'language', null);
 
      w.writeCharacters(UserInfo.getLanguage()!=null ? 'US': 'US');
          w.writeEndElement();
          w.writeCharacters(l);
          w.writeStartElement(null, 'currency', null);
          w.writeCharacters(opp.CurrencyIsoCode != null ? opp.CurrencyIsoCode : '');
          w.writeEndElement();
          w.writeCharacters(l);
          w.writeStartElement(null, 'cartDomainId', null);
          w.writeCharacters('');
          w.writeEndElement();
          w.writeCharacters(l);

          w.writeStartElement(null, 'userGroup', null);
          w.writeCharacters(profile);
          w.writeEndElement();
          w.writeCharacters(l);
          w.writeStartElement(null, 'userId', null);
          
          w.writeCharacters(UserInfo.getUserId());
          w.writeEndElement();
          w.writeCharacters(l);
          w.writeStartElement(null, 'userName', null);
          w.writeCharacters(UserInfo.getUserName());
          w.writeEndElement();
          w.writeCharacters(l);
      
      // Here Code comes for product Selector 
      if(startconfiguration!=null && startconfiguration.equals('yes')){
      
     w.writeStartElement(null, 'initAction', null);
     w.writeAttribute(null, null, 'name', 'AddProduct');
     w.writeCharacters(l);
     w.writeEmptyElement(null, 'param', null);
     w.writeAttribute(null, null, 'id', '');
     w.writeAttribute(null, null, 'value', 'cpCatalog');
     w.writeCharacters(l);
     w.writeEndElement();
     w.writeCharacters(l);

      }
          w.writeEndElement();
          w.writeCharacters(l);
     
          // Cart session custom settings
          w.writeStartElement(null, 'customSettings', null);
          w.writeCharacters(l);
          w.writeEmptyElement(null, 'setting', null);
         // w.writeAttribute(null, null, 'id', 'SFDC_SESSIONID');
         // System.debug('##############################'+UserInfo.getSessionId());
         // w.writeAttribute(null, null, 'value', UserInfo.getSessionId());
         // w.writeCharacters(l);
          w.writeEmptyElement(null, 'setting', null);
          w.writeAttribute(null, null, 'id', 'SFDC_SOAPURL');
          w.writeAttribute(null, null, 'value', soapUrl);
          w.writeCharacters(l);
           
          
          w.writeEmptyElement(null, 'setting', null);
          w.writeAttribute(null, null, 'id', 'SFDC_OPPNAME');
          w.writeAttribute(null, null, 'value',opp.Name);
          w.writeCharacters(l);
          
          w.writeEmptyElement(null, 'setting', null);
          w.writeAttribute(null, null, 'id', 'SFDC_OPPID');
          w.writeAttribute(null, null, 'value', opportunityId);
          w.writeCharacters(l);
          
          // For User Locale
          w.writeEmptyElement(null, 'setting', null);
          w.writeAttribute(null, null, 'id','SFDC_USERCURRENCY');
          w.writeAttribute(null, null, 'value', opp.CurrencyIsoCode!=null?opp.CurrencyIsoCode:'USD');
          w.writeCharacters(l);
          
                    // For User Locale
          w.writeEmptyElement(null, 'setting', null);
          w.writeAttribute(null, null, 'id','SFDC_OPPCOUNTRY');
          w.writeAttribute(null, null, 'value', opp.Main_Delivery_Country__c!=null?opp.Main_Delivery_Country__c:'USD');
          w.writeCharacters(l);
          
          
          // For User Currency 
          
          w.writeEmptyElement(null, 'setting', null);
          w.writeAttribute(null, null, 'id','SFDC_USERLOCALE');
          w.writeAttribute(null, null, 'value',usr.LocaleSidKey!=null?usr.LocaleSidKey:'en_US');
          w.writeCharacters(l);
          
            
          w.writeEmptyElement(null, 'setting', null);
          w.writeAttribute(null, null, 'id', 'SFDC_COUNTRY');
          w.writeAttribute(null, null, 'value',usr.Country!=null?usr.Country:'USA');
          w.writeCharacters(l);
          w.writeEndElement();
          w.writeCharacters(l); 



          // Cart data :header fields default values & list of values
          w.writeStartElement(null, 'cartData', null);
          w.writeCharacters(l);
          w.writeStartElement(null, 'dynamicValues', null);
          w.writeAttribute(null, null, 'overwrite', 'yes');
          w.writeCharacters(l);
          w.writeEmptyElement(null, 'defaultValue', null);
          w.writeAttribute(null, null, 'id', 'ParameterTab.QuoteDescription');
          w.writeAttribute(null, null, 'value', opp.Description!= null ? opp.Description: '-');
          w.writeCharacters(l);
          w.writeEmptyElement(null, 'defaultValue', null);
          w.writeAttribute(null, null, 'id', 'ParameterTab.CustomerId');
          w.writeAttribute(null, null, 'value', opp.AccountId != null ? opp.AccountId: '00000000');
          w.writeCharacters(l);
          w.writeEmptyElement(null, 'defaultValue', null);
          w.writeAttribute(null, null, 'id', 'ParameterTab.CustomerId');
          w.writeAttribute(null, null, 'value', opp.AccountId != null ? opp.AccountId: '00000000');
          w.writeCharacters(l);
          w.writeEmptyElement(null, 'defaultValue', null);
          w.writeAttribute(null, null, 'id', 'ParameterTab.Currency');
          w.writeAttribute(null, null, 'value', opp.CurrencyIsoCode != null ? opp.CurrencyIsoCode: '');
          w.writeCharacters(l);
          
          w.writeEmptyElement(null, 'defaultValue', null);
          w.writeAttribute(null, null, 'id', 'ChangeAndControlTab.CurrentStatus');
          w.writeAttribute(null, null, 'value', status);
          w.writeCharacters(l);

          w.writeEmptyElement(null, 'defaultValue', null);
          w.writeAttribute(null, null, 'id', 'CartInfoTab.OppType');
          w.writeAttribute(null, null, 'value', opp.Type != null ? opp.Type : '');
          w.writeCharacters(l);
          w.writeEmptyElement(null, 'defaultValue', null);
          w.writeAttribute(null, null, 'id', 'CartInfoTab.OppStatus');
          w.writeAttribute(null, null, 'value', opp.StageName != null ? opp.StageName : '');
          w.writeCharacters(l);
          w.writeEmptyElement(null, 'defaultValue', null);
          w.writeAttribute(null, null, 'id', 'CartInfoTab.ApprvStatus');
          w.writeAttribute(null, null, 'value', opp.Discount_Approval_Status__c != null ? opp.Discount_Approval_Status__c: '');
          w.writeCharacters(l);
          w.writeEmptyElement(null, 'defaultValue', null);
          w.writeAttribute(null, null, 'id', 'CartInfoTab.ApprvReq');
          w.writeAttribute(null, null, 'value', (opp.Discount_Approval_Requested__c != null ?  (opp.Discount_Approval_Requested__c==true ? '1' : '0'): '1'));
          w.writeCharacters(l);
          

          if (acc!=null) {
              w.writeEmptyElement(null, 'defaultValue', null);
              w.writeAttribute(null, null, 'id', 'AddressTab.BillTo.Address1');
              w.writeAttribute(null, null, 'value', acc.BillingStreet != null ? acc.BillingStreet : '');
              w.writeCharacters(l);
              w.writeEmptyElement(null, 'defaultValue', null);
              w.writeAttribute(null, null, 'id', 'AddressTab.BillTo.City');
              w.writeAttribute(null, null, 'value', acc.BillingCity != null ? acc.BillingCity : '');
              w.writeCharacters(l);
              w.writeEmptyElement(null, 'defaultValue', null);
              w.writeAttribute(null, null, 'id', 'AddressTab.BillTo.State');
              w.writeAttribute(null, null, 'value', acc.BillingState != null ? acc.BillingState : '');
              w.writeCharacters(l);
              w.writeEmptyElement(null, 'defaultValue', null);
              w.writeAttribute(null, null, 'id', 'AddressTab.BillTo.ZipCode');
              w.writeAttribute(null, null, 'value', acc.BillingPostalCode != null ? acc.BillingPostalCode : '');
              w.writeCharacters(l);
              w.writeEmptyElement(null, 'defaultValue', null);
              w.writeAttribute(null, null, 'id', 'AddressTab.BillTo.Country');
              w.writeAttribute(null, null, 'value', acc.BillingCountry != null ? acc.BillingCountry : '');
              w.writeCharacters(l);
              w.writeEmptyElement(null, 'defaultValue', null);
              w.writeAttribute(null, null, 'id', 'AddressTab.BillTo.CustomerName');
              w.writeAttribute(null, null, 'value', acc.Name != null ? acc.Name : '');
              w.writeCharacters(l);
              w.writeEmptyElement(null, 'defaultValue', null);
              w.writeAttribute(null, null, 'id', 'AddressTab.ShipTo.Address1');
              w.writeAttribute(null, null, 'value', acc.ShippingStreet != null ? acc.ShippingStreet : '');
              w.writeCharacters(l);
              w.writeEmptyElement(null, 'defaultValue', null);
              w.writeAttribute(null, null, 'id', 'AddressTab.ShipTo.City');
              w.writeAttribute(null, null, 'value', acc.ShippingCity != null ? acc.ShippingCity : '');
              w.writeCharacters(l);
              w.writeEmptyElement(null, 'defaultValue', null);
              w.writeAttribute(null, null, 'id', 'AddressTab.ShipTo.State');
              w.writeAttribute(null, null, 'value', acc.ShippingState != null ? acc.ShippingState : '');
              w.writeCharacters(l);
              w.writeEmptyElement(null, 'defaultValue', null);
              w.writeAttribute(null, null, 'id', 'AddressTab.ShipTo.ZipCode');
              w.writeAttribute(null, null, 'value', acc.ShippingPostalCode != null ? acc.ShippingPostalCode : '');
              w.writeCharacters(l);
              w.writeEmptyElement(null, 'defaultValue', null);
              w.writeAttribute(null, null, 'id', 'AddressTab.ShipTo.Country');
              w.writeAttribute(null, null, 'value', acc.ShippingCountry != null ? acc.ShippingCountry : '');
              w.writeCharacters(l);
              w.writeEmptyElement(null, 'defaultValue', null);
              w.writeAttribute(null, null, 'id', 'AddressTab.ShipTo.CustomerName');
              w.writeAttribute(null, null, 'value', acc.Name != null ? acc.Name : '');
              w.writeCharacters(l);
              w.writeEmptyElement(null, 'defaultValue', null);
              w.writeAttribute(null, null, 'id', 'CartInfoTab.CustSeg');
              w.writeAttribute(null, null, 'value', acc.Client_Segment__c != null ? acc.Client_Segment__c : '');
              w.writeCharacters(l);
          }

        
          w.writeEndElement();
          w.writeCharacters(l);
          w.writeEndElement();
          w.writeCharacters(l);
          w.writeEndElement();
          w.writeCharacters(l);
          w.writeEndDocument();
          w.writeCharacters(l);
          String xmlOutput = w.getXmlString();
       
          w.close();
          return xmlOutput;
        }
    // COde is commented as it is already separated out in TEST Class
    /*
private static testMethod void runPositiveTest()

    {

        // Prepare test data

        Account newAccount = new Account(AccountNumber ='TAC00001', Name='TESTING ACCOUNT', Type='Customer - Direct', Description='Account used for APEX code unitary tests', BillingStreet='1274 California St', BillingState='CA', BillingPostalCode='93415', BillingCountry='USA', BillingCity='San Francisco', ShippingStreet='1274 California St', ShippingState='CA', ShippingPostalCode='93415', ShippingCountry='USA', ShippingCity='San Francisco', AnnualRevenue=100000000);

        insert newAccount;

        // Prepare test data

         Opportunity  newOpportunity = new Opportunity(Type='Existing Customer - Upgrade', Name='TESTING OPPORTUNITY', Description='Opportunity used for APEX code unitary tests', AccountId= newAccount.id, Amount=50000.00, CloseDate=date.valueOf('2012-01-01 00:00:00'), Probability=10.00, StageName='Prospecting');

        insert newOpportunity;
        
        Set<Id> opps =new Set<Id> {newOpportunity.Id};

        CAM_Callout(opps);

    }



 private static testMethod void runPositiveTest2()

    {
    
        // Prepare test data

        Account newAccount = new Account(AccountNumber ='TAC00001', Name='TESTING ACCOUNT', Type='Customer - Direct', Description='Account used for APEX code unitary tests', BillingStreet='1274 California St', BillingState='CA', BillingPostalCode='93415', BillingCountry='USA', BillingCity='San Francisco', ShippingStreet='1274 California St', ShippingState='CA', ShippingPostalCode='93415', ShippingCountry='USA', ShippingCity='San Francisco', AnnualRevenue=100000000);

        insert newAccount;

        // Prepare test data

         Opportunity  newOpportunity = new Opportunity(Type='Existing Customer - Upgrade', Name='TESTING OPPORTUNITY', Description='Opportunity used for APEX code unitary tests', AccountId= newAccount.id, Amount=50000.00, CloseDate=date.valueOf('2012-01-01 00:00:00'), Probability=10.00, StageName='Prospecting');

        insert newOpportunity;
        
        String xml = getCartSessionXml(newOpportunity.Id, '006Q0000002oGXyIAM', '1', '', '','no');
    }    
    
   */
}