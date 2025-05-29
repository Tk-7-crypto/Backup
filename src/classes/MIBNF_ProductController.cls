public with sharing class MIBNF_ProductController {

    public List <OpportunityLineItem> opptyLineItem2{get;set;}
    Static boolean validationError = false;
    MIBNF_Component__c MIBNF_Comp;
    MIBNF2__c MIBNF{get;private set;}
    boolean bDeliveryMedia;
    private ID Opportunityid;
    public ID MIBNFID{get;private set;}
    public boolean US_SalesOrg {get;private set;}
    public Boolean ErrorFlag{get;private set;}
    private Boolean UserIsSysAdmin;
    public  Boolean AllowedToApprove {public get;private set;}
    private Set<String> excludedProducts;
    public Map<id,List<SelectOption>> DeliveryMedia_Map{get;private set;} // Added by Himanshu Parashar : 22 nov 2012 : Show only selected Delivery media for user
    public Map<id,List<SelectOption>> DeliveryFrequency_Map{get;private set;} // Added by Sam Duncan : 29 nov 2012 : Show only selected Delivery frequency for user
    public Map<id,List<SelectOption>> oliIdToTherapyAreaOptionsMap{get;private set;} // Added by Dheeraj -- Issue-11063 -- 10 July 2017

    // Added by Dheeraj -- Issue-10593 -- 23 march 2017 -- Start
    public String isProfitCenterReadOnlyListJSON {get; private set;}
    private List<Boolean> isProfitCenterReadOnlyList;
    public String revenueCountryMapJSON{get;set;}
    public List<SelectOption> profitCenterOptions {get;set;}
    private Boolean hasAccessBNFAll; 
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
    
    
    
    // Constructor
    public MIBNF_ProductController(ApexPages.StandardController controller) {
        
        BNF_Settings__c bnfSetting = BNF_Settings__c.getInstance();
        excludedProducts = new Set<String>();
        if(bnfSetting.Excluded_Products__c != null) {
            excludedProducts = new Set<String>(bnfSetting.Excluded_Products__c.split('\\|'));
        }
    	
    	// Added by Dheeraj -- Issue-10593 -- 23 march 2017 -- Start  
    	setRevenueCountryList();
    	isProfitCenterReadOnlyList = new List<boolean>();
    	// Added by Dheeraj -- Issue-10593 -- 23 march 2017 -- End 
     
       // Load Lineitem for single invoice
       this.AllowedToApprove = false;
       this.hasAccessBNFAll = false;
       List<PermissionSetAssignment> permSetAssList = [SELECT Id, PermissionSet.Name, AssigneeId FROM PermissionSetAssignment WHERE AssigneeId = :Userinfo.getUserId() and  PermissionSet.Name = 'Modify_all_privileges_on_BNF'];
       if(permSetAssList.size() > 0) {
          hasAccessBNFAll = true; 
       }
       if(System.currentPageReference().getParameters().get('compid') != null){
       
           MIBNF_Comp = [Select Name,BNF_Status__c,Comments__c,MIBNF__c,MIBNF__r.Opportunity__c,MIBNF__r.Sales_Org_Code__c from MIBNF_Component__c where id = :System.currentPageReference().getParameters().get('compid')]; //--- add Comments by ej. temporary solution --->
           
           //Check for Sysadmin and allow user to Edit Products if user has rights
            User U = [select Id, Sales_Org__c,Profile.Name from User where Id = :UserInfo.getUserId()];
            if(U.Profile.Name.contains('Administrator'))
                UserIsSysAdmin=true;
            else
                UserIsSysAdmin=false;
           
           //Check for Approval User
           ProcessInstanceWorkitem[] P_array = [select Id, ProcessInstance.TargetObjectId,ActorId from ProcessInstanceWorkitem where ProcessInstance.Status = 'Pending' and ProcessInstance.TargetObjectId = :MIBNF_Comp.Id];        
           if (P_array.size()!= 0)
           {
                for (ProcessInstanceWorkitem P2:P_array)
                 {
                    if (P2.ActorId == U.Id || Pattern.matches('system administrator[\\s|[A-z]|[0-9]]*',U.Profile.Name.toLowerCase()) || hasAccessBNFAll)
                    {
                        AllowedToApprove = true;
                    }
                 }
           }
          
           if(!UserIsSysAdmin && !AllowedToApprove && MIBNF_Comp.BNF_Status__c!='New' && MIBNF_Comp.BNF_Status__c!='Rejected')
           {
              ErrorFlag=true;
              ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Products from Submitted BNF cannot be edited.');
              ApexPages.addMessage(errMsg); 
              ErrorFlag=true; 
           }
           
           
           
           Opportunityid=MIBNF_Comp.MIBNF__r.Opportunity__c;
           //this.US_SalesOrg=(Pattern.matches('US[\\s|[A-z]|[0-9]]*',MIBNF_Comp.MIBNF__r.Sales_Org_Code__c.toUpperCase())) ? true : false;   
           MIBNFID=MIBNF_Comp.MIBNF__c;
           
           set<id> oppLineItemset= new set<id>();
           //adding MIBNF line item in to set
           for(MI_BNF_LineItem__c MI_BNF_oppLineItem : [select Opportunity_Line_Itemid__c from MI_BNF_LineItem__c where MIBNF_Component__c=:System.currentPageReference().getParameters().get('compid')])
           {
             oppLineItemset.add(MI_BNF_oppLineItem.Opportunity_Line_Itemid__c);
            
           }
           // Getting LineItem details
            //Added By Sneha Rathi : 21 dec 2012 : querying Therapy_Area field - ER-0303
            // Added by Himanshu Parashar : 13 march 2013 : querying Therapy_Area field
           // Added by Ritesh Gupta : Issue-07072
           // Added by Dheeraj -- Issue-10593 -- 29 march 2017 -- ProfitCenter__c, PricebookEntry.Product2.Material_Group_1__c
           // Added by Dheeraj -- Issue-11063 -- 10 July 2017  -- PricebookEntry.Product2.Therapy_Class__c
           opptyLineItem2=[Select ProfitCenter__c, PricebookEntry.Product2.Material_Group_1__c, Audit_Subscription_Status__c, Opportunity.CEQActiveRelease__c,Discount_Percentage_Formula__c, PricebookEntry.Name, PricebookEntry.Product2.Material_Type__c,
                     PricebookEntry.Product2.Offering_Group__c , PricebookEntry.Product2.Offering_Type__c , List_Price__c,PricebookEntry.Product2.Delivery_Media__c,
                     Nbr_of_Users__c,Book_No__c,CurrencyISOCode,TotalPrice,Delivery_Media__c, Product_Invoice_Text__c,PricebookEntry.Product2.Delivery_Frequency__c, 
                     PricebookEntry.ProductCode,Billing_Frequency__c,Product_Start_Date__c,Product_End_Date__c, Therapy_Area__c,Opportunity.Therapy_Area__c,
                     Proj_Rpt_Frequency__c,Discount_Reason__c,PO_line_item_number__c, Discount_Amount_Formula__c, Other_Ship_To__c, Billing_Date__c,
                     Sale_Type__c, Revenue_Type__c, Invoice_Lag_to_Data_Period__c, Revised_Price__c, MIBNF_Cancel__c,Business_Type__c,
                     Delivery_Date__c,PO_Number__c,Sales_Text__c, PricebookEntry.Product2.Therapy_Class__c from OpportunityLineItem where id in :oppLineItemset  and Product_Material_Type__c NOT IN :excludedProducts order by
                     PricebookEntry.ProductCode asc, Product_Start_Date__c asc];
          

         // Added by Himanshu Parashar : 22 nov 2012 : Show only selected Delivery media for user
         DeliveryMedia_Map = new Map<id,List<SelectOption>>();
        DeliveryFrequency_Map = new Map<id,List<SelectOption>>();
        
        // Delivery media default values from the OLI
        Schema.DescribeFieldResult fieldResultDeliveryMedia = OpportunityLineItem.Delivery_Media__c.getDescribe();
        List<Schema.PicklistEntry> pleDeliveryMedia = fieldResultDeliveryMedia.getPicklistValues();
        
        Schema.DescribeFieldResult fieldResultProj_Rpt_Frequency = OpportunityLineItem.Proj_Rpt_Frequency__c.getDescribe();
        List<Schema.PicklistEntry> pleProj_Rpt_Frequency = fieldResultProj_Rpt_Frequency.getPicklistValues();
        
        // Added by Dheeraj -- Issue-11063 -- 10 July 2017
        Schema.DescribeFieldResult fieldResultTherapyArea = OpportunityLineItem.Therapy_Area__c.getDescribe();
        List<Schema.PicklistEntry> therapyAreaPickEntryList = fieldResultTherapyArea.getPicklistValues();
           
        // Added by Dheeraj -- Issue-11063 -- 10 July 2017 
        oliIdToTherapyAreaOptionsMap = new Map<Id, List<SelectOption>>();        
                       
            
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
	                    therapyAreaoptionList.add(new SelectOption(therapyAreaKeyToValueMap.get(therapyAreaOption),therapyAreaKeyToValueMap.get(therapyAreaOption)));
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
            DeliveryFrequencyOptions.add(new SelectOption('','--None--'));
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
       }
       // Added by Dheeraj Kumar Issue-10593 -- 25 April 2017
	   isProfitCenterReadOnlyListJSON = json.serialize(isProfitCenterReadOnlyList);
        
    }

     //cancel method
      public PageReference cancel() {
       
        PageReference cancel;
        if(ApexPages.currentPage().getParameters().get('retURL')!=null)
        {
            cancel = new PageReference('/' + ApexPages.currentPage().getParameters().get('retURL'));
        }
        else
        {
            cancel = new PageReference('/apex/MI_BNF_View?id=' + MIBNF_Comp.MIBNF__c);
        }
        cancel.setRedirect(true); 
        
        return cancel;
    }
    
    public PageReference ProductCheck()
    {
         if(opptyLineItem2.size()==0 && ApexPages.currentPage().getParameters().get('wz')==null)
         {
               ErrorFlag=true;
               ApexPages.Message myMsg2 = new ApexPages.Message(ApexPages.Severity.info,'This BNF has no products. Please go back and add products before clicking on the "Edit Products" button.');
               ApexPages.addMessage(myMsg2);                       
           
         }
         else if(opptyLineItem2.size()==0 && ApexPages.currentPage().getParameters().get('wz')=='1')
         {
             PageReference pagref = new PageReference('/apex/MI_BNF_View?id=' + MIBNF_Comp.MIBNF__c);
             pagref.setRedirect(true); 
             return pagref;
         }
         return null;
    }
    
    //save method
     public PageReference save() {
          //update Opportunity Line Item
        
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
          if(opptyLineItem2[i].Billing_Frequency__c=='Once' && opptyLineItem2[i].Billing_Date__c==null )
          {
              BillingDateError = true;                  
          }      
          if(opptyLineItem2[i].Proj_Rpt_Frequency__c=='Once [O]' && opptyLineItem2[i].Delivery_Date__c==null)
          {
              DeliveryDateError = true;                  
          }   
         // List Price Validation
          // Date : 18 Jan 2012
          // Update By: Himanshu Parashar
          if(opptyLineItem2[i].List_Price__c!=null && (opptyLineItem2[i].Opportunity.CEQActiveRelease__c == null || opptyLineItem2[i].Opportunity.CEQActiveRelease__c == 0) && (opptyLineItem2[i].List_Price__c.setScale(2, system.roundingMode.HALF_UP)<opptyLineItem2[i].TotalPrice.setScale(2, system.roundingMode.HALF_UP)))
          {
              ListPriceError = true;                  
          }
         // Dheeraj Kumar Issue-10593 -- 25 April 2017
      	 if(!Trigger.isExecuting && opptyLineItem2[i].PricebookEntry.Product2.Material_Group_1__c =='MAN' && opptyLineItem2[i].ProfitCenter__c == null)
         {
              profitCenterError = true;
              opptyLineItem2[i].ProfitCenter__c.addError('Please Enter Profit Center');

         }  
                         
        }
        
        
        if (BillingDateError)
        {
          ApexPages.Message myMsg2 = new ApexPages.Message(ApexPages.Severity.ERROR,'Billing date is mandatory when billing frequency "Once" is selected.');
          ApexPages.addMessage(myMsg2);                       
          PageReference pageRef = ApexPages.currentPage();
        }      
        if (DeliveryDateError)
        {
          ApexPages.Message myMsg2 = new ApexPages.Message(ApexPages.Severity.ERROR,'Delivery date is mandatory when delivery frequency "Once" is selected.');
          ApexPages.addMessage(myMsg2);                       
          PageReference pageRef = ApexPages.currentPage();
        }                    
        if(Val==false)
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
        if (ListPriceError)
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


        try{
            update opptyLineItem2;
            validationError = false;
        }
        catch(DmlException ex){
            ApexPages.addMessages(ex);
            validationError = true;
            return null;
            
       }
       
       PageReference MIBNFviewPage;
       if(ApexPages.currentPage().getParameters().get('retURL')!=null)
       {
            MIBNFviewPage = new PageReference('/' + ApexPages.currentPage().getParameters().get('retURL'));
       }
       else
       {
            MIBNFviewPage = new PageReference('/apex/MI_BNF_View?id=' + MIBNF_Comp.MIBNF__c);
       } 
      
      MIBNFviewPage.setRedirect(true); 
      return MIBNFviewPage;
     }
     
      
      //setter method for DeliveryMediaOpt
      public void setDeliveryMediaOpt(boolean bArg){
          bDeliveryMedia = bArg;               
      }
      //getter method for DeliveryMediaOpt
      public boolean getDeliveryMediaOpt(){

              return bDeliveryMedia;
          
      }
       public MIBNF_Component__c getMIBNF_Comp(){
            return MIBNF_Comp;
        }   
        
       public void setOpportunityLineItem(List<OpportunityLineItem> lineItems){
          opptyLineItem2 = lineItems;
       }
       
       public List<OpportunityLineItem> getOpportunityLineItem2() {
        return opptyLineItem2;
    }
    boolean testCheckbox;
    String Temp;
    public PageReference testCheck()
    {
        testCheckbox =true;
        return null;
    }
    
    public String getTemp()
    {
        return Temp;
    }
     
     public void setTemp(String Temp)
     {
        this.Temp=Temp;
     }
  
 
}