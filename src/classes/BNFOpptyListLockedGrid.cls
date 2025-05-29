public class BNFOpptyListLockedGrid{    

    public List <OpportunityLineItem> opptyLineItem2{get;set;}
    public Boolean PreventEdit {get; set;}
    public User CurrentUser {get; private set;}
    public BNF_Settings__c bnfSetting;
    public String LocalekeyFormat{get; private set;}
    private Set<String> excludedProducts;
    public Map<id,List<SelectOption>> DeliveryMedia_Map{get;private set;} // Added by Himanshu Parashar : 22 nov 2012 : Show only selected Delivery media for user
    public Map<id,List<SelectOption>> oliIdToTherapyAreaOptionsMap{get;private set;} // Added by Dheeraj -- Issue-11063 -- 10 July 2017
    public Map<id,List<SelectOption>> DeliveryFrequency_Map{get;private set;} // Added by Sam Duncan : 29 nov 2012 : Show only selected Delivery frequency for user
    public List<SelectOption> SaleTypePickListOptions {get;private set;}
    public List<SelectOption> RevenueTypePickListOption {get;private set;}
    public static Boolean CheckValidation = true; // Added by Himanshu Parashar : 21 May 2013 : Issue-02120
    
    public Map<id,String> Surchargetext{get;private set;}
    public String addressPrefix {get; private set;}
    public Boolean isPrebillingSalesCode {get; set;}
    Integer POValueCount=0;
    Integer PONullCount=0;

    //Issue-407
    public Boolean poRequired = false; 
    
    //  Pramod : Issue-06334
    public String oliTherapyError; 
    
    public Boolean poErrorOccured = false;   
    //BEGIN - Locking grid VARS
    public List<LockedGridColDetail> lokcedColList {get; set;}
    public Id glossaryDocumentId{get; set;}
    // Is New BNF
    public Boolean isNewBnf {get; set;}
    public String opportunityNumber {get; set;}
    
    private Boolean IgnoreBillingScheduleValidations;
    private Boolean HasZrepZlicProduct;
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
     
    public List<LockedGridColDetail> unLockedColList {get; set;}
    {
        lokcedColList = new List<LockedGridColDetail>();
        //Product Code
        lokcedColList.add(new LockedGridColDetail('PricebookEntry.ProductCode','Product Code', 100, 'col0', false, 'hdrcol0'));
        //Sales Price
        lokcedColList.add(new LockedGridColDetail('TotalPrice','Sales Price', 115, 'col1', false, 'hdrcol1'));
        //Name
        lokcedColList.add(new LockedGridColDetail('PricebookEntry.Name','Name', 135, 'col2' , false, 'hdrcol2'  ));        
        //delivery country
        lokcedColList.add(new LockedGridColDetail('Delivery_Country__c','Delivery Country', 105, 'col3' , false, 'hdrcol3'));
        //WBS codes
        lokcedColList.add(new LockedGridColDetail('WBS_R_Element__c','WBS codes', 120, 'col4' , false, 'hdrcol4'));
        
        Boolean isMDMPage = false;
        if(!Trigger.isExecuting && ApexPages.CurrentPage()!=null && ApexPages.CurrentPage().getURL()!=null && ApexPages.CurrentPage().getURL().toUpperCase().contains('MDM')) {
            isMDMPage = true;
        }
        
        unLockedColList = new List<LockedGridColDetail>();
        Integer i = 0;
        //unLockedColList.add(new LockedGridColDetail('PricebookEntry.Name','Name', 130, 'hdr' + i, false, 'col' + i++ ));
        unLockedColList.add(new LockedGridColDetail('Product_Start_Date__c','Data Period Start', 168, 'hdr' + i, true, 'col' + i++));
        unLockedColList.add(new LockedGridColDetail('Product_End_Date__c','Data Period End', 168, 'hdr' + i, true, 'col' + i++));
        unLockedColList.add(new LockedGridColDetail('Delivery_Media__c','Delivery Media', 162, 'hdr' + i, true, 'col' + i++));
        unLockedColList.add(new LockedGridColDetail('Proj_Rpt_Frequency__c','Delivery/Rpt Frequency', 160, 'hdr' + i, true, 'col' + i++ ));
        unLockedColList.add(new LockedGridColDetail('Billing_Frequency__c','Billing Frequency', 170, 'hdr' + i, true, 'col' + i++));
        
        
        if(isMDMPage) unLockedColList.add(new LockedGridColDetail('Sales_Text__c','Sales Text', 150, 'hdr' + i, false, 'col' + i++ )); 
        else unLockedColList.add(new LockedGridColDetail('Product_Invoice_Text__c','Product Invoice Text', 150, 'hdr' + i, false, 'col' + i++ )); 
        
        if(isMDMPage) unLockedColList.add(new LockedGridColDetail('PO_Number__c','PO Number', 155, 'hdr' + i , false, 'col' + i++ ));
        //unLockedColList.add(new LockedGridColDetail('PO Number', 120)); 
        unLockedColList.add(new LockedGridColDetail('List_Price__c','List Price', 150, 'hdr' + i, false, 'col' + i++)); 
        unLockedColList.add(new LockedGridColDetail('Discount_Percentage_Formula__c','Discount %', 90, 'hdr' + i, false, 'col' + i++)); 
        unLockedColList.add(new LockedGridColDetail('Discount_Amount_Formula__c','Discount / Surcharge Amt', 160, 'hdr' + i, false, 'col' + i++)); 
        unLockedColList.add(new LockedGridColDetail('Discount_Reason__c','Discount Reason / Surcharge Text', 220, 'hdr' + i, true, 'col' + i++));
        unLockedColList.add(new LockedGridColDetail('PO_line_item_number__c','PO line item number', 220, 'hdr' + i, false, 'col' + i++));
        unLockedColList.add(new LockedGridColDetail('Nbr_of_Users__c','Number of Users', 180, 'hdr' + i, true, 'col' + i++));
        unLockedColList.add(new LockedGridColDetail('Other_Ship_To__c','Other Ship To', 200, 'hdr' + i, false, 'col' + i++));
        unLockedColList.add(new LockedGridColDetail('Billing_Date__c','Billing Date', 170,'hdr' + i, false, 'col' + i++)); 
        if(isMDMPage) unLockedColList.add(new LockedGridColDetail('Delivery_Date__c','Delivery Date', 170, 'hdr' + i, false, 'col' + i++ )); 
        //unLockedColList.add(new LockedGridColDetail('Delivery Date', 190)); 
        unLockedColList.add(new LockedGridColDetail('Sale_Type__c','Sales Type', 150, 'hdr' + i, false, 'col' + i++)); 
        unLockedColList.add(new LockedGridColDetail('Revenue_Type__c','Revenue Type', 150, 'hdr' + i, false, 'col' + i++)); 
        unLockedColList.add(new LockedGridColDetail('Invoice_Lag_to_Data_Period__c','Invoice Lag to Data Period', 190, 'hdr' + i, false, 'col' + i++));
        //Update by: Sneha Rathi Date: 21 Dec, 2012 -- Added Theraphy Area field - Er-0303
        unLockedColList.add(new LockedGridColDetail('Therapy_Area__c','Therapy Area', 190, 'hdr' + i, false, 'col' + i++)); 
		// Added by Ritesh Gupta : Issue :07072 : add field Audit_Subscription_Status__c
		// updated by dheeraj kumar 16 Nov 2016   Issue-09948
        unLockedColList.add(new LockedGridColDetail('Audit_Subscription_Status__c','Audit Subscription Status', 160, 'hdr' + i, false, 'col' + i++, true)); 
        
        // Added by Dheeraj -- Issue-10593 -- 23 march 2017 -- Start
        // Added by Dheeraj Kumar Issue-10686 - Add help text for profit centre 06 April 2017 
        unLockedColList.add(new LockedGridColDetail('ProfitCenter__c','Profit Center', 230, 'hdr' + i, false, 'col' + i++, true));
        unLockedColList.add(new LockedGridColDetail('Prebilling__c','Prebilling?', 150, 'hdr' + i, false, 'col' + i++ ));
        // Added by Dheeraj -- Issue-10593 -- 23 march 2017 -- End       
        unLockedColList.add(new LockedGridColDetail('Revised_Price__c','Revised Sales Price', 200, 'hdr' + i, false, 'col' + i++)); 
        unLockedColList.add(new LockedGridColDetail('Cancel__c','Cancel', 52, 'hdr' + i, false, 'col' + i++));
                
    }
    //END - Locking grid VARS
    
    //inner class introduced for list price validation
    //If data period is changing and bnf is revised then list
    //price should also be modified.
    //----- START -----------------
    
    //setIsNewBnfFlag
    public void setIsNewBnfFlag(){
        try {
            if(bnfSetting.BNF_Opportunity_Threshold__c != null) {
                opportunityNumber = bnf.Opportunity_Number__c;
                if(opportunityNumber !=null && opportunityNumber != '' && bnfSetting.BNF_Opportunity_Threshold__c < Integer.valueOf(opportunityNumber)) {
                    isNewBnf = true;
                } else {
                    isNewBnf = false;
                }
            } else {
                isNewBnf = true;
            } 
        } catch(Exception exp) {
            isNewBnf = false;
        }
    }
    
    // Added by Himanshu Parashar : 21 May 2013 : Issue-02120
    public BNFOpptyListLockedGrid() {
        setLocaleFormat();
        isPrebillingSalesCode = false;
        bnfSetting = BNF_Settings__c.getInstance();
        addressPrefix = Address__c.SobjectType.getDescribe().getKeyPrefix();
        excludedProducts = new Set<String>();
        if(bnfSetting.Excluded_Products__c != null) {
            excludedProducts = new Set<String>(bnfSetting.Excluded_Products__c.split('\\|'));
        }
        isNewBnf = false;
        IgnoreBillingScheduleValidations = false;
        this.hasAccessBNFAll = false;
        List<PermissionSetAssignment> permSetAssList = [SELECT Id, PermissionSet.Name, AssigneeId FROM PermissionSetAssignment WHERE AssigneeId = :Userinfo.getUserId() and  PermissionSet.Name = 'Modify_all_privileges_on_BNF'];
        if(permSetAssList.size() > 0) {
            hasAccessBNFAll = true; 
        }
    }

    public BNFOpptyListLockedGrid(ApexPages.StandardController controller) 
    {
        bnfSetting = BNF_Settings__c.getInstance();
        isPrebillingSalesCode = false;
        addressPrefix = Address__c.SobjectType.getDescribe().getKeyPrefix();
        excludedProducts = new Set<String>();
        if(bnfSetting.Excluded_Products__c != null) {
            excludedProducts = new Set<String>(bnfSetting.Excluded_Products__c.split('\\|'));
        }
        // Added by Dheeraj -- Issue-10593 -- 23 march 2017 -- Start  
        setRevenueCountryList();
        isProfitCenterReadOnlyList = new List<boolean>();
        // Added by Dheeraj -- Issue-10593 -- 23 march 2017 -- End
        this.hasAccessBNFAll = false;
        List<PermissionSetAssignment> permSetAssList = [SELECT Id, PermissionSet.Name, AssigneeId FROM PermissionSetAssignment WHERE AssigneeId = :Userinfo.getUserId() and  PermissionSet.Name = 'Modify_all_privileges_on_BNF'];
        if(permSetAssList.size() > 0) {
            hasAccessBNFAll = true; 
        }
        
    //public BNFOpptyListLockedGrid1() {
       setLocaleFormat();
       oliTherapyError = '';
       bnfSetting =BNF_Settings__c.getInstance();
       String newid= System.currentPageReference().getParameters().get('newid');
       //  If user has entered this screen after saving a new BNF (indicated by newid param in URL) then we can ignore the billing
       //  schedule validations
       if (newid != null)
           IgnoreBillingScheduleValidations = true;
       else
           IgnoreBillingScheduleValidations = false;
       HasZrepZlicProduct = false;
       isNewBnf = false;
       opportunityNumber = null;
       if( newid != null){
       
           bnf = [Select Opportunity__r.opportunity_number__c, Opportunity_Number__c, Name, Addendum__c, Contract_Start_Date__c, Contract_End_Date__c, X2nd_Address__c, Comments__c,Sales_Org_Code__c,
                   RecordTypeId,BNF_Status__c,Revenue_Analyst__r.User__c, Bill_To__r.PO_Required__c, Client_PO_Number__c from BNF2__c where id = :newid]; //--- add Comments by ej. temporary solution --->
           
        }else{
            bnf = [Select Opportunity__r.opportunity_number__c, Opportunity_Number__c, Name, Addendum__c, Contract_Start_Date__c, Contract_End_Date__c, X2nd_Address__c, Comments__c,Sales_Org_Code__c,
                   RecordTypeId,BNF_Status__c,Revenue_Analyst__r.User__c, Bill_To__r.PO_Required__c, Client_PO_Number__c from BNF2__c where id = :System.currentPageReference().getParameters().get('bnfid')];
        }   
        
        Set<String> prebillingSalesOrgSet = new Set<String>{'MX02', 'GT01', 'CO01', 'CO71'};
        if(prebillingSalesOrgSet.Contains(bnf.Sales_Org_Code__c)) {
            isPrebillingSalesCode = true;
        }
        // IsNewBnf
        setIsNewBnfFlag();

        //remove the colum for revised price if not a revised bnf
        if(!bnf.Addendum__c){
            unLockedColList.remove(unLockedColList.size() - 2);
            //14th May, 2012 - Anjali Salecha - MIS-Issue-0339
            unLockedColList.remove(unLockedColList.size() - 1);            
        }
        
        if(!isPrebillingSalesCode) {
            Integer colIndex; 
            for(LockedGridColDetail col : unLockedColList) {
                if(col.colApiName == 'Prebilling__c') {
                    colIndex = unLockedColList.indexOf(col);
                }
            }
            if(colIndex != null) {
                unLockedColList.remove(colIndex);
            }
        }
        
        Id id = System.currentPageReference().getParameters().get('id');
        
        //null pointer exception fix - in case sales org code is not present
        this.US_SalesOrg = false;
        if (bnf.Sales_Org_Code__c != null){
            this.US_SalesOrg = (bnf.RecordTypeId !=  MDM_Defines.SAP_SD_Integrated_Record_Type_Id) ? true : false;        
        }
        //Added By Sneha Rathi : 21 dec 2012 adding Therapy_Area field in query - Er-0303
        // Added by Himanshu Parashar : 13 march 2013 : querying Therapy_Area field
        // Added by Ritesh Gupta : Issue :07072 : add field Audit_Subscription_Status__c
        // Added by Dheeraj -- Issue-10593 -- 23 march 2017 -- ProfitCenter__c, PricebookEntry.Product2.Material_Group_1__c
        // Added by Dheeraj -- Issue-11063 -- 10 July 2017  -- PricebookEntry.Product2.Therapy_Class__c
        opptyLineItem2 = [Select ProfitCenter__c, PricebookEntry.Product2.Material_Group_1__c,  Audit_Subscription_Status__c, Opportunity.CEQActiveRelease__c,Discount_Percentage_Formula__c, PricebookEntry.Name, 
                           PricebookEntry.Product2.Material_Type__c,PricebookEntry.Product2.Offering_Group__c ,Opportunity.Therapy_Area__c,  
                           PricebookEntry.Product2.Offering_Type__c , List_Price__c, Nbr_of_Users__c, Book_No__c,Other_Ship_To_SAP_Contact__c,
                           CurrencyISOCode,TotalPrice,Delivery_Media__c, Product_Invoice_Text__c, PricebookEntry.ProductCode,PricebookEntry.Product2.Delivery_Media__c,
                           PricebookEntry.Product2.Delivery_Frequency__c,Other_Ship_To_Address__c,Surcharge_Text__c,
                           Billing_Frequency__c,Product_Start_Date__c,Product_End_Date__c, Proj_Rpt_Frequency__c,Discount_Reason__c, 
                           Discount_Amount_Formula__c, Other_Ship_To__c, Billing_Date__c, Sale_Type__c, Revenue_Type__c,PricebookEntry.Product2.Item_Category_Group__c,  
                           Invoice_Lag_to_Data_Period__c,PO_line_item_number__c, Revised_Price__c,Therapy_Area__c, Cancel__c,Business_Type__c, Delivery_Date__c,PO_Number__c,
                           Sales_Text__c,Budget_Therapy_Area__c,Project_Start_Date__c,Project_End_Date__c, 
                           OpportunityId,Billing_Schedule_Error_Msg__c,Revised_Revenue_Schedule__c,Revenue_Schedule_Error_Msg__c, PricebookEntry.Product2.Therapy_Class__c, Delivery_Country__c, WBS_R_Element__c, Prebilling__c 
                           from OpportunityLineItem where OpportunityId = :id and Product_Material_Type__c NOT IN :excludedProducts order by PricebookEntry.ProductCode asc, 
                           Product_Start_Date__c asc];
         
        this.PreventEdit = false;
        this.CurrentUser = [select Id,Profile.Name from User where Id = :userInfo.getUserId()];
        
        /*****************************************************************************************/
        // Added by Himanshu Parashar : 22 nov 2012 : Show only selected Delivery media for user
        DeliveryMedia_Map = new Map<id,List<SelectOption>>();
        // Added by Dheeraj -- Issue-11063 -- 10 July 2017 
        oliIdToTherapyAreaOptionsMap = new Map<Id, List<SelectOption>>();
        DeliveryFrequency_Map = new Map<id,List<SelectOption>>();
        Surchargetext=new Map<id,String>();
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
              //  Sam Duncan 2015-02-12 - start
              if(isNewBnf) {
                if(oli.List_Price__c == null){
                  	oli.List_Price__c = oli.TotalPrice;
                }
                  if(oli.PricebookEntry.Product2.Material_Type__c=='ZREP' || oli.PricebookEntry.Product2.Material_Type__c=='ZPUB' && oli.PricebookEntry.Product2.Item_Category_Group__c=='ZLIC')
                  {
                      oli.Billing_Frequency__c = null;
                      oli.Billing_Date__c = null;               
                      oli.Proj_Rpt_Frequency__c = null;
                      oli.Delivery_Date__c = null;
                      oli.Invoice_Lag_to_Data_Period__c = null;
                  }
              }
              //  Sam Duncan 2015-02-12 - end
              if(oli.surcharge_text__c!=null && oli.surcharge_text__c!='')
              {
                 Surchargetext.put(oli.id,oli.surcharge_text__c);
              
              }
                else
                    Surchargetext.put(oli.id,'');
             
              
            
            // Added by Himanshu Parashar : 13 march 2013 : Issue-01645 :: setting up default value to Opportunity therapy area. Uncommenting this as this validation will run only for old BNFs  
            // comminted out for new BNFs to fix Issue-06334 - Therapy area on Opportunity Line Item should be set to same as budget
            if(!IsNewBNF) {
                if(oli.Therapy_Area__c==null && oli.Opportunity.Therapy_Area__c!=null)
                            oli.Therapy_Area__c=oli.Opportunity.Therapy_Area__c; 
            }            
            
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
                    if(f.getValue().indexOf('[') > 0){
                        FieldsvaluesMap.put(f.getValue().substringBetween('[',']'), f.getValue()); 
                    }
                    else{
                        FieldsvaluesMap.put(f.getValue(), f.getValue()); 
                    } 
                }
                
                List<String> SupportedDeliveryMedia = oli.PricebookEntry.Product2.Delivery_Media__c.split(':');
                for (String DeliveryMediaOption : SupportedDeliveryMedia)
                {
                    if(FieldsvaluesMap.containsKey(DeliveryMediaOption))
                        options.add(new SelectOption(FieldsvaluesMap.get(DeliveryMediaOption),FieldsvaluesMap.get(DeliveryMediaOption)));
                }
            }
            DeliveryMedia_Map.put(oli.id,options);

            if(IsNewBnf) {
                if(oli.PricebookEntry.Product2.Material_Type__c=='ZREP')
                    oli.delivery_media__c='Not Applicable [NA]';  
            }                       
            
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
            
            if(IsNewBnf) {
                //Added By Himanshu : MIS Issue-05083: 12-Aug-2014
                if(oli.PricebookEntry.Product2.Material_Type__c=='ZREP')
                {
                    //  Don't overwrite the data start date for revised BNF's as users need to be able to change this
                    if(!bnf.Addendum__c)
                        oli.Product_Start_Date__c=oli.Project_Start_Date__c;
                    oli.Product_End_Date__c=oli.Project_End_Date__c;
                
                }
                
                //Added By Pramod : 06334 - Therapy area on Opportunity Line Item should be set to same as budget
                if(oli.PricebookEntry.Product2.Material_Type__c =='ZREP' && oli.Budget_Therapy_Area__c != null) {
                    oli.Therapy_Area__c = oli.Budget_Therapy_Area__c;            
                }             
            }   
            
            if (IsNewBnf)
            {
                //  This gets the latest revised price that has been entered in the OLI.Revised_revenue_Schedule__c field but
                //  OLI.Revised_Price__c has not yet been updated on the OLI
                if(oli.Revised_Revenue_Schedule__c != null)
                {
                    List<String> strRevSchedule = oli.Revised_Revenue_Schedule__c.split('\\|');  
                    //  If Revised_Revenue_Schedule__c contains 'x' it indicates that a revised price of zero has been entered
                    if (strRevSchedule[0] == 'x')
                        strRevSchedule.clear();      
                    oli.Revised_Price__c = 0;            
                    for (integer i=0;i<strRevSchedule.size();i++)
                    {
                        //  Overwrite the Revised_Price__c to have the latest value as entered on revised revenue schedule
                        oli.Revised_Price__c += Decimal.valueOf(strRevSchedule[i].split(':')[1]);            
                    }                   
                }
            }
            //  Check on load if any issues exist and put INFO message on screen  
                         
                if(IsNewBnf) 
                {
                    ////Billing Schedule Validation for ZREP and ZLIC proeducts 
                    if (oli.PricebookEntry.Product2.Material_Type__c == 'ZREP'|| oli.PricebookEntry.Product2.Item_Category_Group__c=='ZLIC') 
                    {
                         //  Set to true to indicate at least one ZREP/ZLIC product
                         HasZrepZlicProduct = true;                       
                    }
                 }  
                 
                   
        }
        /*************************************************************************************/

        // Added by Dheeraj Kumar Issue-10593 -- 25 April 2017
		isProfitCenterReadOnlyListJSON = json.serialize(isProfitCenterReadOnlyList);

    }
 
    //Init function to prevent editing of products if user manages to get to this page when the BNF is approved or still submitted
    public pageReference Init() {
        List<Document> glossaryDocumentList = [SELECT Id FROM Document where DeveloperName = : MDM_Defines.Document_Dev_Name_IMSSFDCGlossary];
        if(glossaryDocumentList.size() > 0){
            glossaryDocumentId = glossaryDocumentList[0].Id;
        }
        if(IsNewBnf) {
            //List<ProcessInstance> PI_List = [Select p.TargetObjectId, p.Status From ProcessInstance p where p.Status = 'Pending' AND p.TargetObjectId = :bnf.Id];
            List<ProcessInstanceWorkitem> PIW_List = new List<ProcessInstanceWorkitem>([select Id, ProcessInstance.Id, ProcessInstance.TargetObjectId, ActorId from ProcessInstanceWorkitem  where ProcessInstance.Status = 'Pending' and ProcessInstance.TargetObjectId = :bnf.Id]);
            // Added  -- Issue-11129 -- 1 August 2017 -- Start
	        Set<Id> actorIdsSet = new Set<Id>();
	        for(ProcessInstanceWorkitem workItem : PIW_List){
	       		actorIdsSet.add(workItem.ActorId);
	        }
           	// Added  -- Issue-11129 -- 1 August 2017 -- End
            if (PIW_List.size() > 0) {
                
                //  If BNF has been submitted, only sys admins or the user to which it has been assigned are able to edit
                // Updated  -- Issue-11129 -- 1 August 2017 
                if (this.CurrentUser.Profile.Name.toUpperCase().contains('SYSTEM ADMINISTRATOR') || actorIdsSet.contains(this.CurrentUser.Id) || hasAccessBNFAll /*this.CurrentUser.Id == PIW_List[0].ActorId*/) {
                     //  Allow sys admins or the user to whom the BNF is currently assigned to edit
                     this.PreventEdit = false;
                } else if (bnf.BNF_Status__c == MDM_Defines.BnfStatus_Map.get('RA_ACCEPTED') ||
                        bnf.BNF_Status__c == MDM_Defines.BnfStatus_Map.get('SAP_CONTRACT_PENDING') || bnf.BNF_Status__c == MDM_Defines.BnfStatus_Map.get('SAP_PENDING')) {
                    ApexPages.Message myMsg22 = new ApexPages.Message(ApexPages.Severity.INFO,'BNF has been accepted for SAP load and cannot be edited');
                    ApexPages.addMessage(myMsg22);
                    this.PreventEdit = true;                 
                }    
                //  Else if the BNF is somewhere else within the approval process
                else {
                    ApexPages.Message myMsg2 = new ApexPages.Message(ApexPages.Severity.INFO,'BNF is submitted for approval and cannot be edited');
                    ApexPages.addMessage(myMsg2);
                    this.PreventEdit = true;
                }
        
            } else if (bnf.BNF_Status__c == MDM_Defines.BnfStatus_Map.get('SAP_CONTRACT_CONFIRMED') || bnf.BNF_Status__c == MDM_Defines.BnfStatus_Map.get('ACCEPTED')) {
                ApexPages.Message myMsg3 = new ApexPages.Message(ApexPages.Severity.INFO,'BNF has been approved and cannot be edited');
                ApexPages.addMessage(myMsg3);
                this.PreventEdit = true;
            }                      
        } else {
            
            List<ProcessInstanceWorkitem> PIW_List = new List<ProcessInstanceWorkitem>([select Id, ProcessInstance.Id, ProcessInstance.TargetObjectId, ActorId from ProcessInstanceWorkitem  where ProcessInstance.Status = 'Pending' and ProcessInstance.TargetObjectId = :bnf.Id]);
            // Added by Dheeraj -- Issue-11129 -- 1 August 2017 -- Start
	        Set<Id> actorIdsSet = new Set<Id>();
	        for(ProcessInstanceWorkitem workItem : PIW_List){
	       		actorIdsSet.add(workItem.ActorId);
	        }
           	// Added -- Issue-11129 -- 1 August 2017 -- End
            if (PIW_List.size() > 0)
            {
                //  If BNF has been submitted, only sys admins or the user to which it has been assigned are able to edit
                // Updated  -- Issue-11129 -- 1 August 2017
                if (bnf.BNF_Status__c == MDM_Defines.BnfStatus_Map.get('SUBMITTED') && 
                    (this.CurrentUser.Profile.Name.toUpperCase().contains('SYSTEM ADMINISTRATOR') || actorIdsSet.contains(this.CurrentUser.Id) || hasAccessBNFAll /*this.CurrentUser.Id == PIW_List[0].ActorId*/ ))
                {
                	this.PreventEdit = false;
                }
                //  Else if the BNF is submitted and user is not allowed to edit products, show message as appropriate
                else if (bnf.BNF_Status__c == MDM_Defines.BnfStatus_Map.get('SUBMITTED'))
                {
                    ApexPages.Message myMsg2 = new ApexPages.Message(ApexPages.Severity.INFO,'BNF is submitted for approval and cannot be edited');
                    ApexPages.addMessage(myMsg2);
                    this.PreventEdit = true; 
                }
                else if (bnf.BNF_Status__c == MDM_Defines.BnfStatus_Map.get('ACCEPTED') ||
                        bnf.BNF_Status__c == MDM_Defines.BnfStatus_Map.get('SAP_CONTRACT_PENDING') || bnf.BNF_Status__c == MDM_Defines.BnfStatus_Map.get('SAP_PENDING')) 
                {
                    ApexPages.Message myMsg22 = new ApexPages.Message(ApexPages.Severity.INFO,'BNF has been accepted for SAP load and cannot be edited');
                    ApexPages.addMessage(myMsg22);
                    this.PreventEdit = true;                 
                }          
            }
            else if (bnf.BNF_Status__c == MDM_Defines.BnfStatus_Map.get('SAP_CONTRACT_CONFIRMED') || bnf.BNF_Status__c == MDM_Defines.BnfStatus_Map.get('ACCEPTED'))
            {
                ApexPages.Message myMsg3 = new ApexPages.Message(ApexPages.Severity.INFO,'BNF has been approved and cannot be edited');
                ApexPages.addMessage(myMsg3);
                this.PreventEdit = true; 
            }                   
        } 
        return null; 
    }        
 
     Static boolean validationError = false;
     public BNF2__c bnf {get; set;}
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
    
    public PageReference testCheck() {
        testCheckbox =true;
        return null;
    }

    public PageReference cancel() {
       String newid = System.currentPageReference().getParameters().get('newid');

       if(newid == null){
           newid= System.currentPageReference().getParameters().get('bnfid');

       }
       
        PageReference cancel = new PageReference('/' + newid);
        validationError = false;
        return cancel;
    }

    public PageReference savePartial(){ 
        if(uiRequiredFieldChckListPrice()){
            return null;
        } 
        try{
            CheckValidation = false;
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
       
       pageReference NextPage;
       if(newid != null)
       {            
            url = '/' + newid;
            if (isNewBnf && HasZrepZlicProduct)
            {
                NextPage = Page.BNF_AddBillingSchedule;
                NextPage.getParameters().put('setupbillsched','true');
                NextPage.getParameters().put('id',newid);
                NextPage.setRedirect(true);
                return NextPage;
            }              
        }
        else
        {
            String bnfid= System.currentPageReference().getParameters().get('bnfid');            
            url = '/' + bnfid;       
        }         
       PageReference submitForApproval = new PageReference(url);                     
       submitForApproval.setRedirect(true); 
       return submitForApproval;
       
    }   
                 
      public PageReference save() {
          if(uiRequiredFieldChck()){
              return null;
          }
        try{
            if(ValidateOLI())
            {
                CheckValidation=false;
                update opptyLineItem2;
                validationError = false;
            } 
            else
                return null;
        }
        catch(DmlException ex){
            ApexPages.addMessages(ex);
            validationError = true;
            return null;
            
       }
          
          
         
        //get Newid
       String newid= System.currentPageReference().getParameters().get('newid');
       String url;
       
       pageReference NextPage;
       //  If user has entered this page as part of the 1st steps when creating a new BNF, then the 'newid' param will be in the URL
       //  If this is set, the next step should be the screen where users can setup billing schedules on all line items
       if(newid != null)
       {            
            url = '/' + newid;
            if (isNewBnf && HasZrepZlicProduct)
            {
                NextPage = Page.BNF_AddBillingSchedule;
                NextPage.getParameters().put('setupbillsched','true');
                NextPage.getParameters().put('id',newid);
                NextPage.setRedirect(true);
                return NextPage;
            }              
        }
        else
        {
            String bnfid= System.currentPageReference().getParameters().get('bnfid');            
            url = '/' + bnfid;       
        }         
       PageReference submitForApproval = new PageReference(url);                     
       submitForApproval.setRedirect(true); 
       return submitForApproval;
       
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
       
       // Added by Himanshu Parashar : 21 May 2013 : Issue-02120 
       public void setBNF(BNF2__c tempbnf){
           bnf = tempbnf;
       }    
       
       // Added by Pramod : 10 Feb 2014 : Issue-407 
       
       public boolean getPORequiredOnBNF(){
            return this.poRequired;
        } 
       
       public void setPORequiredOnBNF(Boolean poRequired){
           this.poRequired = poRequired;
       }          
       
       
       //  Pramod : Issue-06334
       public string getOLITherapyErrorMsg(){
            return this.oliTherapyError;
        } 
       
       public void setOLITherapyErrorMsg(String oliTherapyError){
           this.oliTherapyError = oliTherapyError;
       }           
       // End  Pramod : Issue-06334
       
       public void setOpportunityLineItem(List<OpportunityLineItem> lineItems){
     
           opptyLineItem2 = lineItems;
       
       }
       
       public List<OpportunityLineItem> getOpportunityLineItem2() {
        return opptyLineItem2;
    }
    
     // Added by Himanshu Parashar : 21 May 2013 : Issue-02120
    public Boolean ValidateOLI()
    {
          
          boolean Val = true;
          boolean BillingDateError = false;
          boolean DeliveryDateError = false;
          boolean ListPriceError=false; // List Price Validation :: Date : 29 Dec 2011 :: Update By: Himanshu Parashar
          boolean dataMonthChgListPriceError = false;
          boolean ValError = false;
          boolean TriggerError=false;       
          poErrorOccured = false;   
          Map<Id,OpportunityLineItem> OLI_Map;
          //  The Revised_Revenue_Schedule__c and Billing_Schedule__r.Total_Billing_Amount__c can be changed in a popup window, hence we need to retrieve the latest value
          OLI_Map = new Map<Id,OpportunityLineItem>([select Id, Nbr_of_Users__c, Revised_Revenue_Schedule__c,Billing_Schedule__r.Total_Billing_Amount__c,TotalPrice,Discount_Amount_Formula__c from OpportunityLineItem where OpportunityId = :bnf.Opportunity__c]);
          
          
            //==== START code to check project start/end dates vs revenue schedule dates (ER003)
            Map<String,Boolean> OLIScheduleMapStartDate = new Map<String,Boolean>();
            Map<String,Boolean> OLIScheduleMapEndDate = new Map<String,Boolean>(); 
            Map<Id,OpportunityLineItem> opptyLineItem2_Map = new Map<Id,OpportunityLineItem>();
            for (OpportunityLineItem OLI:opptyLineItem2)
            {
                opptyLineItem2_Map.put(OLI.Id,OLI);
            }
            //  Retrieve all OpportunityLineItemSchedules to validate against project start/end dates
            LIST<AggregateResult> OLSSchedule_Array = [Select MIN(ScheduleDate) StartDate,Max(ScheduleDate) EndDate,
            OpportunityLineItemId,OpportunityLineItem.Project_Start_Date__c,OpportunityLineItem.Project_End_Date__c from OpportunityLineItemSchedule where OpportunitylineitemId in : OLI_Map.keySet() and OpportunityLineItem.PricebookEntry.Product2.Material_Type__c = 'ZREP'
            group by OpportunityLineItem.Project_Start_Date__c,OpportunityLineItem.Project_End_Date__c,OpportunityLineItemId];
            
            for(AggregateResult agg : OLSSchedule_Array)
            {
                //  If a revised BNF is being validated but no revised schedule has been specified, then the validation must be done against the original
                //  Opportunitylineitemschedules using the updated data period start
                Date StartDate = (bnf.Addendum__c ? opptyLineItem2_Map.get(String.valueof(agg.get('OpportunityLineItemId'))).Product_Start_Date__c : Date.valueof(agg.get('Project_Start_Date__c')));
                if(StartDate!=null && (Date.valueof(agg.get('StartDate')) < StartDate))
                {          
                    OLIScheduleMapStartDate.put(String.valueof(agg.get('OpportunityLineItemId')),True);
                }
                if(agg.get('Project_End_Date__c')!=null && (Date.valueof(agg.get('EndDate')) > Date.valueof(agg.get('Project_End_Date__c'))))
                {           
                    OLIScheduleMapEndDate.put(String.valueof(agg.get('OpportunityLineItemId')),True);
                }           
            }
            
            for (OpportunityLineItem OLI:opptyLineItem2)
            {
                //  Get the latest value for OLI.Revised_Revenue_Schedule__c
                if (OLI_Map.get(OLI.Id).Revised_Revenue_Schedule__c != null)
                    OLI.Revised_Revenue_Schedule__c = OLI_Map.get(OLI.Id).Revised_Revenue_Schedule__c;
                //  Check revised revenue schedule against project start/end dates (only for ZREP products)
                if (OLI.Revised_Revenue_Schedule__c != null && OLI.PricebookEntry.Product2.Material_Type__c == 'ZREP')
                {
                    List<String> strRevSchedule = OLI_Map.get(OLI.Id).Revised_Revenue_Schedule__c.split('\\|');  
                    //  If Revised_Revenue_Schedule__c contains 'x' it indicates that a revised price of zero has been entered
                    if (strRevSchedule[0] == 'x')
                        strRevSchedule.clear();       
                    String tempDate;
                    Integer RevenueYear;
                    Integer RevenueMonth;
                    Integer RevenueDay;
                    Date RevenueDate;   
                    //  If any OLI id's were put into the error map because of the original (not revised) revenue schedules, remove them from the map                   
                    OLIScheduleMapEndDate.remove(OLI.Id);
                    OLIScheduleMapStartDate.remove(OLI.Id);
                    for (integer i=0;i<strRevSchedule.size();i++)
                    {
                        tempDate = strRevSchedule[i].split(':')[0];
                        RevenueYear = Integer.valueOf(tempDate.left(4));
                        RevenueMonth = Integer.valueOf(tempDate.mid(4,2));
                        RevenueDay = Integer.valueOf(tempDate.right(2));
                        RevenueDate = Date.newInstance(RevenueYear,RevenueMonth,RevenueDay);
                        if (RevenueDate < OLI.Product_Start_Date__c)
                        {
                            OLIScheduleMapStartDate.put(OLI.Id,True);
                        }
                        if (RevenueDate > OLI.Project_End_Date__c)
                        {
                            OLIScheduleMapEndDate.put(OLI.Id,True);
                        }
                    }       
                }
            }
             if(IsNewBnf && !Trigger.isExecuting)
             {
                 for (OpportunityLineItem OLI:opptyLineItem2)
                 {
                     if (OLIScheduleMapStartDate.containskey(oli.id) && OLIScheduleMapStartDate.get(oli.id)==true || OLIScheduleMapEndDate.containskey(oli.id) && OLIScheduleMapEndDate.get(oli.id)==true)
                     {
                        //  If there is a revised price, put the error on the revised price field and the other field that can also be used to edit the revised revenue schedules.
                        if (OLI.Revised_Price__c != null)
                        {
                            OLI.Revenue_Schedule_Error_Msg__c.addError('Revised revenue schedules must be within project start/end dates');
                            OLI.Revised_Price__c.addError('Revised revenue schedules must be within project start/end dates');                          
                        }
                        //  Else put the error on the field with the link to edit the OpportunityLineItemSchedules
                        else
                            OLI.Revenue_Schedule_Error_Msg__c.addError('Revenue schedules must be within project start/end dates');
                        ValError = true;                                         
                     }
                 } 
             }
           //==== END code to check project start/end dates vs revenue schedule dates (ER003)

        
          
          for(Integer i=0;i<opptyLineItem2.size();i++)
          {
               if(IsNewBnf) {
                   //  Issue-05381
                  if ((opptyLineItem2[i].Billing_Frequency__c == '50% upon signature, 50% upon completion' || opptyLineItem2[i].Billing_Frequency__c == 'Other') && 
                        opptyLineItem2[i].Pricebookentry.product2.Material_Type__c=='ZPUB' && opptyLineItem2[i].PricebookEntry.Product2.Item_Category_Group__c != 'ZLIC') {
                        if(Trigger.isExecuting)
                            TriggerError=true;
                        else
                          opptyLineItem2[i].Billing_Frequency__c.addError('\'50% upon signature, 50% upon completion\' and \'Other\'  Billing Frequency is not applicable for ZPUB products. Please select some other Billing Frequency.');
                          ValError = true; 
                  } 
               }            
            
          
              //  Delivery date must be after data period end, except for materials with "PERF" in the material code
              if (opptyLineItem2[i].PricebookEntry.Product2.Offering_Type__c !='Management Consulting' &&
                  opptyLineItem2[i].List_Price__c==null && 
                  opptyLineItem2[i].PricebookEntry.Product2.Offering_Type__c !=Label.CES_TOT_Offering_Type && US_SalesOrg == false)
              {	
                if(Trigger.isExecuting)
                    TriggerError=true;
                else
                  opptyLineItem2[i].List_Price__c.addError('Please Enter List price');
                  ValError = true; 
              } 

              //  Delivery date must be after data period end, except for materials with "PERF" in the material code
              if (!opptyLineItem2[i].PricebookEntry.ProductCode.toUpperCase().contains('PERF') &&
                  opptyLineItem2[i].Delivery_Date__c < opptyLineItem2[i].Product_End_Date__c)
              {
                  if(Trigger.isExecuting)
                    TriggerError=true;
                  else
                    opptyLineItem2[i].Delivery_Date__c.addError('Delivery date cannot be earlier than data period end');
                  ValError = true; 
              }
              // ------- BEGIN CONTRACT VS DATA PERIOD DATES VALIDATION              
              //  Data month start must be before contract end date
              //  For new C&S iBNF (ER003), the data period vs contract date validation is ignored as the data periods come from project start/end and project start/end
              //  must be within engagement start/end and engagement start/end must be within contract start/end
              if (opptyLineItem2[i].Product_Start_Date__c > bnf.Contract_End_Date__c && opptyLineItem2[i].Revenue_Type__c != 'Ad Hoc' && (IsNewBnf ? opptyLineItem2[i].PricebookEntry.Product2.Material_Type__c!='ZREP' : true))
              {
                  ValError = true;
                  if(Trigger.isExecuting)
                    TriggerError=true;
                  else
                    opptyLineItem2[i].Product_Start_Date__c.addError('Data period must start before contract end date');
              }     
              //  Data month end must be before contract end date
              if (opptyLineItem2[i].Product_End_Date__c > bnf.Contract_End_Date__c && opptyLineItem2[i].Revenue_Type__c != 'Ad Hoc' && (IsNewBnf ? opptyLineItem2[i].PricebookEntry.Product2.Material_Type__c!='ZREP' : true))
              {
                  ValError = true;
                  if(Trigger.isExecuting)
                    TriggerError=true;
                  else
                    opptyLineItem2[i].Product_End_Date__c.addError('Data period must end before contract end date');
              }     
              // For subscription products (i.e. not back data and not ad hoc)      
              if (opptyLineItem2[i].Revenue_Type__c != 'Back Data' && opptyLineItem2[i].Revenue_Type__c != 'Ad Hoc' && (IsNewBnf ? opptyLineItem2[i].PricebookEntry.Product2.Material_Type__c!='ZREP' : true)) 
              {
                  //  Data period end must be after contract start date
                  if (opptyLineItem2[i].Product_End_Date__c < bnf.Contract_Start_Date__c)
                  {    
                      ValError = true;
                      if(Trigger.isExecuting)
                        TriggerError=true;
                      else
                        opptyLineItem2[i].Product_End_Date__c.addError('Data period must end after contract start date.');
                  }
                  //  Data period start must be after contract start date
                  if (opptyLineItem2[i].Product_Start_Date__c < bnf.Contract_Start_Date__c)
                  {
                      ValError = true;
                      if(Trigger.isExecuting)
                        TriggerError=true;
                      else
                        opptyLineItem2[i].Product_Start_Date__c.addError('Data period must start after contract start date.');
                  }
              }
              // ------- END CONTRACT VS DATA PERIOD DATES VALIDATION              
            
              if(IsNewBnf) {
                  if((opptyLineItem2[i].Billing_Frequency__c=='Once')&&(opptyLineItem2[i].Billing_Date__c==null) && 
                  opptyLineItem2[i].PricebookEntry.Product2.Material_Type__c!='ZREP') {
                      BillingDateError = true;                  
                      if(Trigger.isExecuting)
                        TriggerError=true;
                      else
                        opptyLineItem2[i].Billing_Date__c.addError('Billing date is mandatory when billing frequency "Once" is selected.');
                  }
              } else {
                  if((opptyLineItem2[i].Billing_Frequency__c=='Once')&&(opptyLineItem2[i].Billing_Date__c==null)) {
                      BillingDateError = true;                  
                      if(Trigger.isExecuting)
                        TriggerError=true;
                      else
                        opptyLineItem2[i].Billing_Date__c.addError('Billing date is mandatory when billing frequency "Once" is selected.');
                  }                 
              }                               
              
              if((opptyLineItem2[i].Proj_Rpt_Frequency__c=='Once [O]')&&(opptyLineItem2[i].Delivery_Date__c==null) && bnf.RecordTypeId==MDM_Defines.SAP_SD_Integrated_Record_Type_Id)
              {
                  DeliveryDateError = true;                  
                  if(Trigger.isExecuting)
                    TriggerError=true;
                  else
                    opptyLineItem2[i].Delivery_Date__c.addError('Delivery date is mandatory when Delivery frequency "Once" is selected.');
              }
              
              Decimal SalesPrice = bnf.Addendum__c ? (opptyLineItem2[i].Revised_Price__c != null ? opptyLineItem2[i].Revised_Price__c : opptyLineItem2[i].TotalPrice)  : opptyLineItem2[i].TotalPrice;
              
              
	    
              if(bnfSetting.Enable_BNF_Surcharge__c==true && (bnf.RecordTypeId == MDM_Defines.SAP_SD_Integrated_Record_Type_Id) && (opptyLineItem2[i].Surcharge_Text__c==null || opptyLineItem2[i].Surcharge_Text__c=='') &&
               (opptyLineItem2[i].Opportunity.CEQActiveRelease__c == null || opptyLineItem2[i].Opportunity.CEQActiveRelease__c == 0) && 
               (opptyLineItem2[i].List_Price__c!=null && (opptyLineItem2[i].List_Price__c.setScale(2,system.roundingMode.HALF_UP) < SalesPrice.setScale(2,system.roundingMode.HALF_UP)) )
               )
              {
                  if(Trigger.isExecuting)
                        TriggerError=true;
                  else
                      opptyLineItem2[i].Surcharge_Text__c.addError('Please input Surcharge Text');
               
                 ListPriceError = true;    
              }
              
            
             if(bnfSetting.Enable_BNF_Surcharge__c==true && (bnf.RecordTypeId == MDM_Defines.SAP_SD_Integrated_Record_Type_Id) && (opptyLineItem2[i].Discount_Reason__c==null || opptyLineItem2[i].Discount_Reason__c=='') &&
               (opptyLineItem2[i].Opportunity.CEQActiveRelease__c == null || opptyLineItem2[i].Opportunity.CEQActiveRelease__c == 0) && 
               (opptyLineItem2[i].List_Price__c!=null && (opptyLineItem2[i].List_Price__c.setScale(2,system.roundingMode.HALF_UP) > SalesPrice.setScale(2,system.roundingMode.HALF_UP) ))
               )
              {
                  if(Trigger.isExecuting)
                        TriggerError=true;
                  else
                      opptyLineItem2[i].Discount_Reason__c.addError('Please input Discount reason');
               
                 ListPriceError = true;    
              }
              
              
              if(bnfSetting.Enable_BNF_Surcharge__c==true && bnf.RecordTypeId == MDM_Defines.SAP_SD_Integrated_Record_Type_Id && opptyLineItem2[i].List_Price__c!=null && (opptyLineItem2[i].List_Price__c.setScale(2,system.roundingMode.HALF_UP) > SalesPrice.setScale(2,system.roundingMode.HALF_UP) ))
              {
              
                opptyLineItem2[i].Surcharge_Text__c='';

              }
              else if(bnfSetting.Enable_BNF_Surcharge__c==true && bnf.RecordTypeId == MDM_Defines.SAP_SD_Integrated_Record_Type_Id && opptyLineItem2[i].List_Price__c!=null && (opptyLineItem2[i].List_Price__c.setScale(2,system.roundingMode.HALF_UP) < SalesPrice.setScale(2,system.roundingMode.HALF_UP)))
              {
                opptyLineItem2[i].Discount_Reason__c='';
              }
              else if(bnfSetting.Enable_BNF_Surcharge__c==true && bnf.RecordTypeId == MDM_Defines.SAP_SD_Integrated_Record_Type_Id && opptyLineItem2[i].List_Price__c!=null && (opptyLineItem2[i].List_Price__c.setScale(2,system.roundingMode.HALF_UP) == SalesPrice.setScale(2,system.roundingMode.HALF_UP)))
              {
                opptyLineItem2[i].Discount_Reason__c='';
                opptyLineItem2[i].Surcharge_Text__c='';
              }

             // ER-407  - Pramod 
                          
             if(bnfSetting.Enable_PO_Validation__c && Trigger.isExecuting && getPORequiredOnBNF() && bnf.Client_PO_Number__c == null) {
                if(opptyLineItem2[i].PO_Number__c == null) {
                  if(Trigger.isExecuting) {
                    TriggerError = true;
                    poErrorOccured = true;
                  }
                }
             }
             
             
              //  Issue-05969 - Pramod : For ZPUB products, if delivery frequency "once" is selected, then users must select billing frequency of "once".             
              if (opptyLineItem2[i].PricebookEntry.Product2.Material_Type__c =='ZPUB' && opptyLineItem2[i].Proj_Rpt_Frequency__c == 'Once [O]' && opptyLineItem2[i].Billing_Frequency__c != 'Once')
              {
                if(Trigger.isExecuting)
                    TriggerError=true;
                else
                  opptyLineItem2[i].Billing_Frequency__c.addError('If Delivery/Rpt Frequency is set to \'Once [O]\' then Billing Frequency must be set to \'Once\'.');
                  ValError = true; 
              }   
              
              //  Issue-08105 - Sam Duncan : Ensure that Sale type and revenue type are not null
              if (opptyLineItem2[i].Sale_Type__c == null || opptyLineItem2[i].Revenue_Type__c == null)
              {
                if(Trigger.isExecuting)
                    TriggerError=true;
                  ValError = true; 
              } 
              //  End Issue-08105
              
              //  Check that billing schedule adds up to total of sales price/revised sales price
              //  If user has entered this screen as part of creating a new BNF we can ignore the billing schedule validations
                if(IsNewBnf && !IgnoreBillingScheduleValidations) 
                {
                    ////Billing Schedule Validation for ZREP and ZLIC proeducts 
                    if (opptyLineItem2[i].PricebookEntry.Product2.Material_Type__c == 'ZREP'|| opptyLineItem2[i].PricebookEntry.Product2.Item_Category_Group__c=='ZLIC') 
                    {
                                                
                         //Billing Schedule Validation    
                         //  Set revised price as the comparison to be used for revised bnf                        
                        Decimal ValidationPrice;
                        if (bnf.Addendum__c && opptyLineItem2[i].Revised_Price__c != null)
                            ValidationPrice = opptyLineItem2[i].Revised_Price__c.setScale(2);
                        else
                            ValidationPrice = opptyLineItem2[i].TotalPrice.setscale(2);    
                                         
                        if(OLI_Map.get(opptyLineItem2[i].id).Billing_Schedule__c==NULL && (opptyLineItem2[i].TotalPrice != 0 || opptyLineItem2[i].List_Price__c!= null && (opptyLineItem2[i].TotalPrice - opptyLineItem2[i].List_Price__c) != 0))
                        {                       
                            ValError = true; 
                            if(Trigger.isExecuting)
                              TriggerError=true;
                            else
                            {
                                //  Use the "dummy" Billing_Schedule_Error_Msg__c field to display an error next to the billing schedule link      
                                opptyLineItem2[i].Billing_Schedule_Error_Msg__c.addError('No billing schedule has been created.  Billing schedule total must be equal to sales price/revised sales price (' +ValidationPrice+').');
                            }
                        }   
                        if( OLI_Map.get(opptyLineItem2[i].id).Billing_Schedule__c!=NULL && OLI_Map.get(opptyLineItem2[i].id).Billing_Schedule__r.Total_Billing_Amount__c.setscale(2) != ValidationPrice  && 
                            (opptyLineItem2[i].TotalPrice != 0 || opptyLineItem2[i].List_Price__c!= null && (opptyLineItem2[i].TotalPrice - opptyLineItem2[i].List_Price__c) != 0))
                        {
                            ValError = true; 
                            if(Trigger.isExecuting)
                              TriggerError=true;
                            else
                            {
                                //  Use the "dummy" Billing_Schedule_Error_Msg__c field to display an error next to the billing schedule link                                
                                opptyLineItem2[i].Billing_Schedule_Error_Msg__c.addError('Billing schedule total (' + OLI_Map.get(opptyLineItem2[i].id).Billing_Schedule__r.Total_Billing_Amount__c.setscale(2) + ') must be equal to sales price/revised sales price (' +ValidationPrice+').');
                            }
                        }
                    }
                 }
                 
                  if(IsNewBnf) 
                  {
                      if(opptyLineItem2[i].List_Price__c!=null && opptyLineItem2[i].TotalPrice==0 && opptyLineItem2[i].List_Price__c!=0 && 
                        (opptyLineItem2[i].PricebookEntry.Product2.Material_Type__c=='ZREP' || opptyLineItem2[i].PricebookEntry.Product2.Item_Category_Group__c=='ZLIC')) 
                      {
                          ListPriceError = true;                  
                          if(Trigger.isExecuting)
                            TriggerError=true;
                          else
                            opptyLineItem2[i].List_Price__c.addError('ZREP/ZLIC materials with zero value sales price must also have zero value list price.');
                      }
                  }                   
                  if((opptyLineItem2[i].PricebookEntry.Product2.Item_Category_Group__c=='ZPLI' || opptyLineItem2[i].PricebookEntry.Product2.Item_Category_Group__c=='ZPLU') && opptyLineItem2[i].Nbr_of_Users__c <= 0)    
                  {
                      ValError = true; 
                      if(Trigger.isExecuting)
                          TriggerError=true;
                      else
                      {
                          opptyLineItem2[i].Nbr_of_Users__c.addError('Please enter a non-zero amount for number of users');
                      }

                  }
              	// Dheeraj Kumar Issue-10593 -- 25 April 2017
              	if(!Trigger.isExecuting && opptyLineItem2[i].PricebookEntry.Product2.Material_Group_1__c =='MAN' && opptyLineItem2[i].ProfitCenter__c == null)
                 {
                      ValError = true;
                      opptyLineItem2[i].ProfitCenter__c.addError('Please Enter Profit Center');
        
                  }
              		

          }

          if (Val==false || BillingDateError || DeliveryDateError || dataMonthChgListPriceError || ListPriceError || ValError || TriggerError)
          {             
              return false;
          }
          else
              return true;
    }
 
   
     public pageReference CalculateSurcharge()
     {

       if(System.currentPageReference().getParameters().get('itemindex')!=null && System.currentPageReference().getParameters().get('itemindex')!='' &&
       System.currentPageReference().getParameters().get('pricevalue')!=null
       )
       {
       
       
         integer currindex=integer.valueof(System.currentPageReference().getParameters().get('itemindex'));
         String PriceValue=System.currentPageReference().getParameters().get('pricevalue');   
         
         try
         {
            if(LocalekeyFormat=='Locale_Format1')
            {
                
                PriceValue=PriceValue.replace(',','');
            }
            else if(LocalekeyFormat=='Locale_Format2')
            {
                PriceValue=PriceValue.replace('.','').replace(',','.');
            }
            else if(LocalekeyFormat=='Locale_Format3')
            {
                PriceValue=PriceValue.replace('\'','');
            }
            else if(LocalekeyFormat=='Locale_Format4')
            {
                PriceValue=PriceValue.replaceAll('(\\s+)','').replace(',','.');
            }
            else if(LocalekeyFormat=='Locale_Format5')
            {
                PriceValue=PriceValue.replace(',','').replace('\\/','.');
            }
            else if(LocalekeyFormat=='Locale_Format6')
            {
                PriceValue=PriceValue.replaceAll('(\\s+)','').replace('-','.');
            }
            else if(LocalekeyFormat=='Locale_Format7')
            {
                PriceValue=PriceValue.replace(' ','');
            }
             

             if(System.currentPageReference().getParameters().get('isRevised')=='0')
             {
                if(PriceValue!='')
                    opptyLineItem2[currindex].List_Price__c=Decimal.valueof(PriceValue);
                else
                    opptyLineItem2[currindex].List_Price__c=null;
             }
             else
             {
                 if(PriceValue!='')
                    opptyLineItem2[currindex].Revised_Price__c=Decimal.valueof(PriceValue);
                else
                    opptyLineItem2[currindex].Revised_Price__c=null;
             }
         }
         catch(Exception e)
         {
             if(System.currentPageReference().getParameters().get('isRevised')=='0')
                 opptyLineItem2[currindex].List_Price__c.addError('Invalid Number');
             else
                 opptyLineItem2[currindex].Revised_Price__c.addError('Invalid Number');
         }
 
       }
       return null;
    }
    
    //This function set user locale which is used on page
    public void setLocaleFormat()
    {
         if((User_Locale__c.getinstance('Format1').LocaleSidKey__c!=null && User_Locale__c.getinstance('Format1').LocaleSidKey__c.contains(';' + Userinfo.getLocale()+ ';')) || 
            (User_Locale__c.getinstance('Format1').LocaleSidKey1__c!=null && 
            User_Locale__c.getinstance('Format1').LocaleSidKey1__c.contains(';' + Userinfo.getLocale()+ ';')))
            {
                
                LocalekeyFormat='Locale_Format1';
            }
            else if((User_Locale__c.getinstance('Format2').LocaleSidKey__c!=null && User_Locale__c.getinstance('Format2').LocaleSidKey__c.contains(';' + Userinfo.getLocale()+ ';')) || 
            (User_Locale__c.getinstance('Format2').LocaleSidKey1__c!=null && 
            User_Locale__c.getinstance('Format2').LocaleSidKey1__c.contains(';' + Userinfo.getLocale()+ ';')))
            {
                 LocalekeyFormat='Locale_Format2';
            }
            else if((User_Locale__c.getinstance('Format3').LocaleSidKey__c!=null && User_Locale__c.getinstance('Format3').LocaleSidKey__c.contains(';' + Userinfo.getLocale()+ ';')) || 
            (User_Locale__c.getinstance('Format3').LocaleSidKey1__c!=null && 
            User_Locale__c.getinstance('Format3').LocaleSidKey1__c.contains(';' + Userinfo.getLocale()+ ';')))
            {
               LocalekeyFormat='Locale_Format3';
            }
            else if((User_Locale__c.getinstance('Format4').LocaleSidKey__c!=null && User_Locale__c.getinstance('Format4').LocaleSidKey__c.contains(';' + Userinfo.getLocale()+ ';')) || 
            (User_Locale__c.getinstance('Format4').LocaleSidKey1__c!=null && 
            User_Locale__c.getinstance('Format4').LocaleSidKey1__c.contains(';' + Userinfo.getLocale()+ ';')))
            {
                 LocalekeyFormat='Locale_Format4';
            }
            else if(User_Locale__c.getinstance('Format5').LocaleSidKey__c.contains(';' + Userinfo.getLocale()+ ';'))
            {
                LocalekeyFormat='Locale_Format5';
            }
            else if(User_Locale__c.getinstance('Format6').LocaleSidKey__c.contains(';' + Userinfo.getLocale()+ ';'))
            {
                 LocalekeyFormat='Locale_Format6';
            }
            else if(User_Locale__c.getinstance('Format7').LocaleSidKey__c.contains(';' + Userinfo.getLocale()+ ';'))
            {
                LocalekeyFormat='Locale_Format7';
            }
            else
                LocalekeyFormat='Locale_Format1';      
    }


    public String oppLiId{get;set;}
    public OpportunityLineItem oppLI{get;set;}
    public List<Billing_Schedule_Item__c> billingSchList{get;set;} 
    Public Double billScheduleAmt {
        get{if(billingSchList != null && billingSchList.size() > 0){
                    Double amt = 0.0;
                    for(Billing_Schedule_Item__c bs : billingSchList ){
                        amt += bs.Billing_Amount__c;
                    }
                    return amt ;
             } else {
                 return 0;
             }
        
        }
    }
    
    Public Integer billScheduleNum {
        get{if(billingSchList != null){
                return billingSchList.size();
            } else {
                return 0;
            }
        }
    }

    public PageReference showBNFInfo(){
        oppLI = [select o.id, o.PriceBookEntry.Product2.ProductCode,
                                     o.PriceBookEntry.Product2.Name,
                                     o.Billing_Schedule__c,
                                     o.TotalPrice,
                                     o.Billing_Schedule__r.id,
                                     o.CurrencyISOCode
                                     from OpportunityLineItem o
                                     where id = :oppLiId limit 1];
        
        billingSchList = [ 
                               Select id, 
                               Billing_Amount__c, 
                               Billing_Date__c,
                               Billing_Schedule__c from Billing_Schedule_Item__c 
                               where Billing_Schedule__r.OLIId__c =:oppLiId order by Billing_Date__c ASC ];
        
               
        //system.assert(false, 'Opp = ' + oppLI + ', billingSchList = ' + billingSchList + ', oppLi.Billing_Schedule__c = ' + oppLi.Billing_Schedule__c);        
        return null;
    }
    
        
    public pageReference CalculateRevisedPrice()
    {
        if(System.currentPageReference().getParameters().get('itemindex2')!=null && System.currentPageReference().getParameters().get('itemindex2')!='')
        {           
            integer currindex=integer.valueof(System.currentPageReference().getParameters().get('itemindex2'));
            OpportunityLineItem OLI = [select Id,Revised_Revenue_Schedule__c from OpportunityLineItem where Id = :opptyLineItem2[currindex].Id];
            
            List<String> strRevSchedule = new List<String>();
            if (OLI.Revised_Revenue_Schedule__c != null && OLI.Revised_Revenue_Schedule__c != '')
            {
               strRevSchedule = OLI.Revised_Revenue_Schedule__c.split('\\|');
               //  If Revised_Revenue_Schedule__c contains 'x' it indicates that a revised price of zero has been entered
               if (strRevSchedule[0] == 'x')
                    strRevSchedule.clear();
            }    
            Decimal RevisedPriceAmount = 0;
            for (integer i=0;i<strRevSchedule.size();i++)
            {
               RevisedPriceAmount += Decimal.valueOf(strRevSchedule[i].split(':')[1]);
            }
            
            try
            {           
               opptyLineItem2[currindex].Revised_Price__c=RevisedPriceAmount;            
            }
            catch(Exception e)
            {
                if(System.currentPageReference().getParameters().get('isRevised')=='0')
                    opptyLineItem2[currindex].List_Price__c.addError('Invalid Number');
                else
                    opptyLineItem2[currindex].Revised_Price__c.addError('Invalid Number');
            }            
        }
    return null;
    }
    
    public Boolean uiRequiredFieldChck(){
        Boolean isError = false;
        Boolean isTriggerExecuted = false;
        if(Trigger.isExecuting){
            isTriggerExecuted = true;
        }
        for(OpportunityLineItem oli : opptyLineItem2){
            if(isNewBnf){
                if(oli.Product_Start_Date__c == Null && (oli.PricebookEntry.Product2.Material_Type__c == 'ZPUB' || bnf.Addendum__c == true)){
                    isError = true;
                    if(!isTriggerExecuted)
                        oli.Product_Start_Date__c.addError('You must enter a value');
                }
               if(oli.Delivery_Media__c == Null && oli.PricebookEntry.Product2.Material_Type__c != 'ZREP'){
                   isError = true;
                   if(!isTriggerExecuted)
                       oli.Delivery_Media__c.addError('Value is required.');
                }
                if(oli.Proj_Rpt_Frequency__c == Null && oli.PricebookEntry.Product2.Material_Type__c == 'ZPUB' && 
                   oli.PricebookEntry.Product2.Item_Category_Group__c !='ZLIC') {
                       isError = true;
                       if(!isTriggerExecuted)
                           oli.Proj_Rpt_Frequency__c.addError('Value is required.');
                   }
                
                if(oli.Billing_Frequency__c == Null && oli.Pricebookentry.product2.Material_Type__c=='ZPUB' &&
                   oli.PricebookEntry.Product2.Item_Category_Group__c != 'ZLIC'){
                       isError = true;
                       if(!isTriggerExecuted)
                           oli.Billing_Frequency__c.addError('You must enter a value');
                   }
                if(oli.Nbr_of_Users__c == Null && (oli.PricebookEntry.Product2.Item_Category_Group__c =='ZPLI' ||
                       oli.PricebookEntry.Product2.Item_Category_Group__c == 'ZPLU')) {
                       isError = true;  
                       if(!isTriggerExecuted)
                           oli.Nbr_of_Users__c.addError('You must enter a value');                              
                   }
                if(oli.Therapy_Area__c == Null && oli.Pricebookentry.product2.Material_Type__c != 'ZREP'){
                    isError = true;
                    if(!isTriggerExecuted)
                        oli.Therapy_Area__c.addError('Value is required.');
                }
            }
            else{
                if(oli.Product_Start_Date__c == Null && oli.PricebookEntry.Product2.Material_Type__c == 'ZPUB'){
                    isError = true;
                    if(!isTriggerExecuted)
                        oli.Product_Start_Date__c.addError('You must enter a value');
                }
               if(oli.Delivery_Media__c == Null){
                   isError = true;
                   if(!isTriggerExecuted)
                       oli.Delivery_Media__c.addError('Value is required.');
                }
                if(oli.Proj_Rpt_Frequency__c == Null) {
                    isError = true;
                    if(!isTriggerExecuted)
                        oli.Proj_Rpt_Frequency__c.addError('Value is required.');
                   }
                
                if(oli.Billing_Frequency__c == Null){
                    isError = true;
                    if(!isTriggerExecuted)
                        oli.Billing_Frequency__c.addError('You must enter a value');
                   }
                if(oli.Therapy_Area__c == Null ){
                    isError = true;
                    if(!isTriggerExecuted)
                        oli.Therapy_Area__c.addError('Value is required.');
                }
            }
                
                if(oli.Product_End_Date__c == Null && oli.PricebookEntry.Product2.Material_Type__c == 'ZPUB'){
                    isError = true;
                    if(!isTriggerExecuted)
                        oli.Product_End_Date__c.addError('You must enter a value');
                }
               
                if(oli.Sale_Type__c == Null) {
                    isError = true;
                    if(!isTriggerExecuted)
                        oli.Sale_Type__c.addError('You must enter a value');
                }
                if(oli.Revenue_Type__c == Null){
                    isError = true;
                    if(!isTriggerExecuted)
                        oli.Revenue_Type__c.addError('You must enter a value');
                }
                if(oli.Audit_Subscription_Status__c == Null && oli.PricebookEntry.Product2.Offering_Type__c == 'National Tracking'){
                    isError = true; 
                    if(!isTriggerExecuted)
                        oli.Audit_Subscription_Status__c.addError('Value is required.');
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
    
    public Boolean uiRequiredFieldChckListPrice(){
        Boolean isError = false;
        Boolean isTriggerExecuted = false;
        if(Trigger.isExecuting){
            isTriggerExecuted = true;
        }
        for(OpportunityLineItem oli : opptyLineItem2){
            if(bnfSetting.Enable_BNF_Surcharge__c==true && (oli.Discount_Reason__c==null || oli.Discount_Reason__c=='') &&
               (oli.Opportunity.CEQActiveRelease__c == null || oli.Opportunity.CEQActiveRelease__c == 0)){
                   if(oli.List_Price__c!=null && oli.Revised_Price__c!=null && (oli.List_Price__c.setScale(2,system.roundingMode.HALF_UP) > oli.Revised_Price__c.setScale(2,system.roundingMode.HALF_UP))){
                       isError = true;
                       if(!isTriggerExecuted){
                           oli.Discount_Reason__c.addError('Please input Discount reason');
                       }
                   } else if(oli.List_Price__c!=null && oli.Revised_Price__c==null && (oli.List_Price__c.setScale(2,system.roundingMode.HALF_UP) > oli.TotalPrice.setScale(2,system.roundingMode.HALF_UP))){
                       isError = true; 
                       if(!isTriggerExecuted){
                           oli.Discount_Reason__c.addError('Please input Discount reason');
                       }
                   }
               }
            if(bnfSetting.Enable_BNF_Surcharge__c==true && (oli.Surcharge_Text__c==null || oli.Surcharge_Text__c=='') &&
               (oli.Opportunity.CEQActiveRelease__c == null || oli.Opportunity.CEQActiveRelease__c == 0)){
                   if(oli.List_Price__c!=null && oli.Revised_Price__c!=null && (oli.List_Price__c.setScale(2,system.roundingMode.HALF_UP) < oli.Revised_Price__c.setScale(2,system.roundingMode.HALF_UP))){
                       isError = true; 
                       if(!isTriggerExecuted){   
                           oli.Surcharge_Text__c.addError('Please input Surcharge Text');
                       } 
                   } else if(oli.List_Price__c!=null && oli.Revised_Price__c==null && (oli.List_Price__c.setScale(2,system.roundingMode.HALF_UP) < oli.TotalPrice.setScale(2,system.roundingMode.HALF_UP))){
                       isError = true;  
                       if(!isTriggerExecuted){ 
                           oli.Surcharge_Text__c.addError('Please input Surcharge Text');
                       }
                   }
               }
        } 
        return isError;
    }
}