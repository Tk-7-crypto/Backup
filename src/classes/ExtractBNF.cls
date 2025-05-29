public class ExtractBNF { 

   //public BNF2__c BNF {public get; private set;}
   BNF2__c BNF;
   String OpportunityId;
   public List<OpportunityLineItem> opptyLineItem;
   public map<String,List<Billing_Schedule_Item__c>> Billing_Schedule_Items;
   public String Revenue_Schedule_Items_String;
   public String Billing_Schedule_Items_String;
   public Boolean isNewBnf {get ; private set;}
   public BNF_Settings__c bnfSetting;
   public List<String> updatedFieldSet {get; private set;}
   private static Set<String> excludedProducts;
   static {
       BNF_Settings__c bnfSetting = BNF_Settings__c.getInstance();
       excludedProducts = new Set<String>();
       if(bnfSetting.Excluded_Products__c != null) {
           excludedProducts = new Set<String>(bnfSetting.Excluded_Products__c.split('\\|'));
       }
   }

   Date DataFormat;
   //updated by dheeraj kumar 8 Nov 2016  ER 3208 Start
   private Set<String> OLISchedulesFields = new Set<String>{'Description', 'Revenue', 'ScheduleDate'};
   private Set<String> billingSchItemFields = new Set<String>{'Billing_Amount__c', 'Billing_Date__c', 'Invoice_Description__c'};
   // private Set<String> newOLIFields = new Set<String> {'PricebookEntry.Name', 'Other_Ship_To_SAP_Contact__r.Name'};
   public Set<Id> addedFieldSet {get;private set;}
   private Set<String> BNFFieldsAdded;
  //updated by dheeraj kumar 8 Nov 2016  ER 3208 End   
   public BNF2__c  getBNF() 
   {
	   //updated by dheeraj kumar 8 Nov 2016  ER 3208 Start
       if(BNF == null) {
      	BNFFieldsAdded = new Set<String>();
      	// updated by Ritesh Gupta - ER-3208
      	//BNF = [select opportunity__c, name, Client__c, CurrencyIsoCode,Addendum__c,Opportunity__r.Opportunity_Number__c from BNF2__c where id = :System.currentPageReference().getParameters().get('id')];
        String query = 'SELECT  Opportunity__r.Name, Revenue_Analyst__r.Name, Client__r.Name, Original_Prior_Opportunity__r.Name, Bill_To_Company__r.Name, Ship_To_Company__r.Name, Contact__r.Name, Delivery_Contact__r.Name,LastModifiedBy.Name,CreatedBy.Name,Carbon_Copy_Contact__r.Name,Carbon_Copy_Company__r.Name,X2nd_Copy_Contact__r.Name,Cover_Sheet_Contact__r.Name,Cover_Sheet_Company__r.Name,X2nd_Copy_Company__r.Name,Bill_To_SAP_Contact__r.Name,Ship_To_SAP_Contact__r.Name,Sold_To__r.Name,Cover_Sheet__r.Name,X2nd_Copy__r.Name,Cover_Sheet_SAP_Contact__r.Name,X2nd_Copy_SAP_Contact__r.Name,Carbon_Copy__r.Name,Bill_To__r.Name,Ship_To__r.Name,';
        for(Schema.FieldSetMember f : SObjectType.BNF2__c.FieldSets.FieldsToTraceBNF.getFields()) {
        	BNFFieldsAdded.add(f.getFieldPath());
            query += f.getFieldPath() + ', ';
        }
          
        for(Schema.FieldSetMember fm : SObjectType.BNF2__c.FieldSets.FieldsToTraceBNF_MDM.getFields()) {
            //String str = fm.getFieldPath();
            if(!BNFFieldsAdded.contains(fm.getFieldPath())){
           	 	query += fm.getFieldPath() + ', ';
            }
        } 
        query += ' CurrencyIsoCode,Opportunity__r.Opportunity_Number__c  FROM BNF2__c where id = \'' + System.currentPageReference().getParameters().get('id') + '\'';
        //updated by dheeraj kumar 8 Nov 2016  ER 3208 End
      	BNF = (BNF2__c) Database.query(query)[0];
      }		
      
      OpportunityId =  BNF.opportunity__c;
      bnfSetting =BNF_Settings__c.getInstance();
      if(bnfSetting.BNF_Opportunity_Threshold__c != null) 
      {
        String opportunityNumber = bnf.Opportunity__r.Opportunity_Number__c;
        try {
	        if(opportunityNumber !=null && opportunityNumber != '' && bnfSetting.BNF_Opportunity_Threshold__c < Integer.valueOf(opportunityNumber)) 
	        {
	            isNewBnf = true;
	        } 
	        else 
	        {
	            isNewBnf = false;
	        }
        } catch (Exception exp) {
        	isNewBnf = false;
        }
      } 
      else 
      {
        isNewBnf = true;
      }
      return BNF;
    }
    
	 public ExtractBNF(){

    	updatedFieldSet = new List<String>();
    	//updated by dheeraj kumar 8 Nov 2016  ER 3208 Start
    	addedFieldSet = new Set<Id>();
    	BNFFieldsAdded = new Set<String>();
    	BNF = getBNF();
    	String query = 'SELECT ';
        for(Schema.FieldSetMember f : SObjectType.BNF2__c.FieldSets.FieldsToTraceBNF.getFields()) {
        	BNFFieldsAdded.add(f.getFieldPath());
            query += f.getFieldPath() + ', ';
        }
        for(Schema.FieldSetMember fm : SObjectType.BNF2__c.FieldSets.FieldsToTraceBNF_MDM.getFields()) {
            //String str = fm.getFieldPath();
            if(!BNFFieldsAdded.contains(fm.getFieldPath())){
           	 	query += fm.getFieldPath() + ', ';
            }
        } 
        query += ' CurrencyIsoCode, oli_json_data_1__c,oli_json_data_2__c,oli_json_data_3__c FROM BNF2__c where opportunity__c = \'' + BNF.opportunity__c + '\' and BNF_Status__c = \'SAP Contract Confirmed\' and RA_End_Date__c != null order by RA_End_Date__c desc limit 1';
        System.debug('BNF Query '+query);
      	List<BNF2__c> lastApprovedBNFList = (List<BNF2__c>) Database.query(query);
      	if(lastApprovedBNFList.size() > 0) {
      		BNF2__c lastApprovedBNF = lastApprovedBNFList[0];
      		if(lastApprovedBNF.oli_json_data_1__c != null){
	      		for(Schema.FieldSetMember f : SObjectType.BNF2__c.FieldSets.FieldsToTraceBNF.getFields()) {
		            if(lastApprovedBNF.get(f.getFieldPath()) != BNF.get(f.getFieldPath())){
		            	updatedFieldSet.add(BNF.id +'.'+ f.getFieldPath());
		            }
		        }
		        for(Schema.FieldSetMember f : SObjectType.BNF2__c.FieldSets.FieldsToTraceBNF_MDM.getFields()) {
		        	if(!BNFFieldsAdded.contains(f.getFieldPath())) {
		        		if(lastApprovedBNF.get(f.getFieldPath()) != BNF.get(f.getFieldPath())){
		            		updatedFieldSet.add(BNF.id +'.'+ f.getFieldPath());
		            	}
		        	}
		        }
		        query = 'select Id ';
		        String childQuery = '( Select Id , OpportunityLineItemId ';
			    for(Schema.FieldSetMember f : SObjectType.OpportunityLineItem.FieldSets.FieldsToTraceForBNF.getFields()) {
			        query += ', ' + f.getFieldPath();
			    }
			    for(String flds : OLISchedulesFields) {
	                childQuery += ', ' + flds;
	            }
	            childQuery += ' from OpportunityLineItemSchedules )';
	           	query += ' , BSI_Json_Data_LAB__c, OLIS_Json_Data_LAB__c, Other_Ship_To_SAP_Contact__r.Name, PricebookEntry.Name,  Other_Ship_To_Address__r.Name, Other_Ship_To_Address__r.SAP_Reference__c, '+childQuery +' FROM OpportunityLineItem where OpportunityId = \'' + BNF.opportunity__c + '\'';
	  			System.debug('OLI Query '+query);
	 			Map<Id, OpportunityLineItem> currentOliMap = new Map<Id, OpportunityLineItem>((List<OpportunityLineItem>) Database.query(query));
	 			
	            
	            query = 'Select Id , Billing_Schedule__r.OLIId__c ';
	            for(String flds : billingSchItemFields) {
	                query +=  ', ' + flds;
	            }   
	            query += ' From Billing_Schedule_Item__c  where Billing_Schedule__r.OLIId__c IN (';
		        for(Id oppId : currentOliMap.keySet()){
		 			query += '\'' + oppId + '\',';
		 		}
		 		query = query.removeEnd(',');
		 		query += ')';
	            System.debug('BSI Query '+query);
	            List<Billing_Schedule_Item__c> currentbillingScheduleItemsList = Database.query(query);
	            List<OpportunityLineItemSchedule> currentOliSchList;
	            Map<Id, Billing_Schedule_Item__c> priorBilSchItemsMap; 
	        	List<OpportunityLineItem> priorOliWholeList = new  List<OpportunityLineItem>(); 
                if(lastApprovedBNF.OLI_Json_Data_1__c != null){
	                priorOliWholeList.addAll((List<OpportunityLineItem>) json.deserialize(lastApprovedBNF.OLI_Json_Data_1__c, List<OpportunityLineItem>.class));
                }
                if(lastApprovedBNF.OLI_Json_Data_2__c != null){
	                priorOliWholeList.addAll((List<OpportunityLineItem>) json.deserialize(lastApprovedBNF.OLI_Json_Data_2__c, List<OpportunityLineItem>.class));
                }
                if(lastApprovedBNF.OLI_Json_Data_3__c != null){
	                priorOliWholeList.addAll( (List<OpportunityLineItem>) json.deserialize(lastApprovedBNF.OLI_Json_Data_3__c, List<OpportunityLineItem>.class));
                }
	            Map<Id, OpportunityLineItem> priorOliWholeMap = new Map<Id, OpportunityLineItem>(priorOliWholeList);
	            Map<Id, OpportunityLineItemSchedule> priorOliSchMap;
	            for(OpportunityLineItem oli : currentOliMap.values()) {
	            	if(priorOliWholeMap.containsKey(oli.id)) {
	                	for(Schema.FieldSetMember f : SObjectType.OpportunityLineItem.FieldSets.FieldsToTraceForBNF.getFields()) {
	                        if(f.getFieldPath() == 'TotalPrice' ) {
	                        	Decimal totalPrice = Decimal.valueOf(String.valueof(oli.get(f.getFieldPath())));
	                        	totalPrice = totalPrice.setScale(2); 
	                        	Decimal priorTotalPrice = Decimal.valueOf(String.valueof(priorOliWholeMap.get(oli.id).get(f.getFieldPath())));
	                        	priorTotalPrice = priorTotalPrice.setScale(2); 	
                                if(totalPrice !=  priorTotalPrice){
	                        		updatedFieldSet.add(oli.id + '.' + f.getFieldPath());
                                }
	                        }
	                        else if(oli.get(f.getFieldPath()) != priorOliWholeMap.get(oli.id).get(f.getFieldPath())){
	                            updatedFieldSet.add(oli.id + '.' + f.getFieldPath());
	                        }
	                    } 
	                   	if(oli.Other_Ship_To_Address__c != null && priorOliWholeMap.get(oli.id).getSobject('Other_Ship_To_Address__r') != null &&  oli.Other_Ship_To_Address__r.Name != priorOliWholeMap.get(oli.id).getSobject('Other_Ship_To_Address__r').get('Name')) {
	                    	 updatedFieldSet.add(oli.id + '.' + 'Other_Ship_To_Address__r.Name');
	                    }
	                    if(oli.Other_Ship_To_Address__c != null &&  priorOliWholeMap.get(oli.id).getSobject('Other_Ship_To_Address__r') != null && oli.Other_Ship_To_Address__r.SAP_Reference__c != priorOliWholeMap.get(oli.id).getSobject('Other_Ship_To_Address__r').get('SAP_Reference__c')) {
	                    	updatedFieldSet.add(oli.id + '.' + 'Other_Ship_To_Address__r.SAP_Reference__c');
	                    }
	                    if(oli.Other_Ship_To_SAP_Contact__c != null && priorOliWholeMap.get(oli.id).getSobject('Other_Ship_To_SAP_Contact__r') != null && oli.Other_Ship_To_SAP_Contact__r.Name != priorOliWholeMap.get(oli.id).getSobject('Other_Ship_To_SAP_Contact__r').get('Name')) {
	                    	updatedFieldSet.add(oli.id + '.' + 'Other_Ship_To_SAP_Contact__r.Name');
	                    } 
	                    if(oli.PricebookEntry != null &&  priorOliWholeMap.get(oli.id).getSobject('PricebookEntry') != null && oli.PricebookEntry.Name != priorOliWholeMap.get(oli.id).getSobject('PricebookEntry').get('Name')) {
	                    	updatedFieldSet.add(oli.id + '.' + 'PricebookEntry.Name');
	                    }
	                    if(oli.OLIS_Json_Data_LAB__c != null) {
			                priorOliSchMap  = new Map<Id,OpportunityLineItemSchedule > ((List<OpportunityLineItemSchedule>)json.deserialize(oli.OLIS_Json_Data_LAB__c, List<OpportunityLineItemSchedule>.class)) ;
			                for(OpportunityLineItemSchedule olisch : currentOliMap.get(oli.id).OpportunityLineItemSchedules) {
			                	if(priorOliSchMap.containskey(olisch.id)) {
				                    for(String str : OLISchedulesFields) {
				                       if(olisch.get(str) != priorOliSchMap.get(olisch.id).get(str)){
				                            updatedFieldSet.add(olisch.id + '.' + str);
				                        }
				                    }          
			                	} else if(olisch.OpportunityLineItemId == oli.id){
			                		addedFieldSet.add(olisch.id);
			                	}
			                }
	                    }
		                if(oli.BSI_Json_Data_LAB__c != null) {   
		                   	priorBilSchItemsMap = new Map<Id,Billing_Schedule_Item__c >((List<Billing_Schedule_Item__c>)json.deserialize(oli.BSI_Json_Data_LAB__c, List<Billing_Schedule_Item__c>.class)) ;
		                    for(Billing_Schedule_Item__c billingLineItem : currentbillingScheduleItemsList) {
		                    	if(priorBilSchItemsMap.containskey(billingLineItem.id)) {
			                        for(String str : billingSchItemFields) {
			                            if(billingLineItem.get(str) != priorBilSchItemsMap.get(billingLineItem.id).get(str)){
			                                updatedFieldSet.add(billingLineItem.id + '.' + str);
			                            }
			                        }
		                    	} else if(billingLineItem.Billing_Schedule__r.OLIId__c == oli.id) {
		                    		addedFieldSet.add(billingLineItem.id);
		                    	}
		                    }
		                }
		                //addedFieldSet.add(oli.id);
	                } else {
	                	addedFieldSet.add(oli.id);
	                	}
	                
	            }
      		}
        }
    	//updated by dheeraj kumar 8 Nov 2016  ER 3208 End
	}
	

    
	/*public ExtractBNF(ApexPages.StandardController controller){ 
     
     
    }*/
      
   public List<OpportunityLineItem> getOpportunityLineItem() 
   {
       //Update by: Himanshu Parashar : ER-0303 - Therapy_area__c added
       //Update by: Ritesh Gupta : Issue-07072 - Audit_Subscription_Status__c added
       //Updated by Dheeraj -- Issue-10593 -- 30  march 2017 -- ProfitCenter__c 
       opptyLineItem = [Select ProfitCenter__c, ProfitCenter__r.Name, PricebookEntry.Name,Book_No__c,CurrencyISOCode,TotalPrice,Therapy_area__c,Audit_Subscription_Status__c,surcharge_text__c,
       Delivery_Media__c,PricebookEntry.ProductCode,Billing_Frequency__c,Proj_Rpt_Frequency__c, Discount_Percentage_Formula__c,
       Product_Start_Date__c,Product_End_Date__c, WBS__c,WBSRElement__c,WBS_R_Element__c,Nbr_of_Users__c,Business_Type__c,Product2.Name,PricebookEntry.Product2.Material_Type__c, PricebookEntry.Product2.Item_Category_Group__c, Practice_Area__c,SubPractice_Area__c,Delivery_Country__c, List_Price__c, Discount_Reason__c,PO_line_item_number__c, Invoice_Date__c, Product_Invoice_Text__c, Discount_Amount_Formula__c, Other_Ship_To__c, Revised_Price__c, Cancel_Text__c,
       Sale_Type__c,Revenue_Type__c,WinBack__c, Invoice_Lag_to_Data_Period__c,Billing_Date__c, Delivery_Date__c, PO_Number__c, Sales_Text__c,Other_Ship_To_Address__r.Name,Other_Ship_To_Address__r.SAP_Reference__c,Other_Ship_To_SAP_Contact__r.SAP_Contact_Number__c,Other_Ship_To_SAP_Contact__r.Name, Budget_Billing_Model__c, Revised_Revenue_Schedule__c, Prebilling__c
       from OpportunityLineItem 
       where OpportunityId = :OpportunityId AND Product_Material_Type__c Not IN :excludedProducts order by PricebookEntry.ProductCode asc, Product_Start_Date__c asc];
       
       for(OpportunityLineItem oli : opptyLineItem){
           if(oli.Product2.Name.length() > 30 ){
               oli.Product2.Name = oli.Product2.Name.substring(0,29)+'\n'+oli.Product2.Name.substring(29,oli.Product2.Name.length());
           }
       }
       
       return opptyLineItem;
    }
    
    public map<String,List<Billing_Schedule_Item__c>> getBilling_Schedule_Items()
    {
        // New Code
        Set<Id> OLIIdSet = new  Set<Id>();
        Opportunity opp = [select id, name, Amount, Contract_Start_Date__c, Contract_End_Date__c,(select id,Project_Start_Date__c,Project_End_Date__c,
                TotalPrice,PricebookEntry.Product2.Name, PricebookEntry.Product2.material_type__c,PricebookEntry.Product2.ProductCode, PricebookEntry.Product2.Item_Category_Group__c, Product_Start_Date__c, Product_End_Date__c from OpportunityLineItems )
                from Opportunity where id =: BNF.Opportunity__c limit 1];
                
        for (OpportunityLineItem oppLineItem : opp.OpportunityLineItems  ) {
            if(oppLineItem .TotalPrice != null && oppLineItem .TotalPrice > 0 && 
                (oppLineItem.PricebookEntry.Product2.material_type__c =='ZREP' || (oppLineItem.PricebookEntry.Product2.Material_Type__c=='ZPUB' && 
                oppLineItem.PricebookEntry.Product2.Item_Category_Group__c=='ZLIC'))) {
                    
              OLIIdSet.add(oppLineItem.Id) ;
            }
        }           
        
        // End
        Map<String,List<Billing_Schedule_Item__c>> bsMap = new Map<String,List<Billing_Schedule_Item__c>>();
        //bsMap.put(null,null);
        if(System.currentPageReference().getParameters().get('id')!=null && System.currentPageReference().getParameters().get('id')!='') 
        {
            
            
            for(Billing_Schedule__c bs : [Select Total_Billing_Amount__c, OLIId__c,
                Name, Id, CurrencyIsoCode,
                (Select Name, Billing_Amount__c, Billing_Date__c, Invoice_Description__c, Billing_Schedule__c From Billing_Schedule_Items__r order by Billing_Date__c asc)
                From Billing_Schedule__c where OLIId__c in : OLIIdSet])
            {
                List<Billing_Schedule_Item__c> lstt=new List<Billing_Schedule_Item__c>();
                lstt=bs.Billing_Schedule_Items__r;
                bsMap.put(bs.OLIId__c,lstt);


            }
            opptyLineItem = getOpportunityLineItem();
            for(Opportunitylineitem oli: opptyLineItem)
            {
                if(!bsMap.containskey(oli.id))
                {
                    //This Blank record is required to format billing schedule in PDF
                    Billing_Schedule_Item__c tempobj=new Billing_Schedule_Item__c(Invoice_Description__c='                            ');                    
                    List<Billing_Schedule_Item__c> lstt=new List<Billing_Schedule_Item__c>(); 
                    lstt.add(tempobj); 
                    bsMap.put(oli.id,lstt);
                }
            
            }
            
         
        }
        return bsMap;
        
    }
    
    /**
     * Getter method for Billing_Schedule_Items_String
     */
    public String getBilling_Schedule_Items_String() {
        
        Map<String,List<Billing_Schedule_Item__c>> bsMap = getBilling_Schedule_Items();
        Billing_Schedule_Items_String = JSON.serialize(bsMap);
        return Billing_Schedule_Items_String;
    }
    
    /**
     * Setter method for Billing_Schedule_Items_String
     */
    public void setBilling_Schedule_Items_String(String Billing_Schedule_Items_String) {
        this.Billing_Schedule_Items_String = Billing_Schedule_Items_String;
    }
    

    // Added New
    public Map<String,List<OpportunityLineItemSchedule>> getRevenue_Schedule_Items()
    {

        Map<String,List<OpportunityLineItemSchedule>> bsMap = new Map<String,List<OpportunityLineItemSchedule>>();
        //bsMap.put(null,null);
        Set<ID> oppIds = new Set<ID>();

        if(System.currentPageReference().getParameters().get('id')!=null && System.currentPageReference().getParameters().get('id')!='') 
        {

            for(Opportunitylineitem oli: opptyLineItem) {
                oppIds.add(oli.id);
            }            
            
           //  Get all revenue schedules
            {           
                for(OpportunityLineItemSchedule bs : [select id,Description,Quantity, Revenue, ScheduleDate, opportunityLineItemID  from OpportunityLineItemSchedule where opportunityLineItemID IN: oppIds order by ScheduleDate asc])
                {
                    if(bsMap.containskey(bs.opportunityLineItemID)) {
                        bsMap.get(bs.opportunityLineItemID).add(bs);
                    } else {
                        List<OpportunityLineItemSchedule> lstt = new List<OpportunityLineItemSchedule>();
                        lstt.add(bs);
                        bsMap.put(bs.opportunityLineItemID,lstt);
                    }
                }
                
                for(Opportunitylineitem oli: opptyLineItem)
                {
                    if(!bsMap.containskey(oli.id))
                    {
                        //This Blank record is required to format billing schedule in PDF
                        OpportunityLineItemSchedule tempobj = new OpportunityLineItemSchedule ();
                        List<OpportunityLineItemSchedule> lstt=new List<OpportunityLineItemSchedule>(); 
                        lstt.add(tempobj); 
                        bsMap.put(oli.id,lstt);
                    }
                
                }
            }
           
           //  If any line items have revised revenue schedules, overwrite the map with the revised schedules
           {                
                for(Opportunitylineitem oli: opptyLineItem)
                {
                    List<String> strRevSchedule = new List<String>();
                    List<OpportunityLineItemSchedule> OLIS_wrapper = new List<OpportunityLineItemSchedule>();
                    if (oli.Revised_Revenue_Schedule__c != null && oli.Revised_Revenue_Schedule__c != '')
                    {
                        strRevSchedule = oli.Revised_Revenue_Schedule__c.split('\\|');
                    	//  If Revised_Revenue_Schedule__c contains 'x' it indicates that a revised price of zero has been entered
				   		if (strRevSchedule[0] == 'x')
				   		{
				   			strRevSchedule.clear();
				   			//  Put an empty OpportunityLineItemSchedule list in the map for this line item				   		
				   			bsMap.put(oli.id,OLIS_wrapper);
				   		}
                    } 
                    for (integer i=0;i<strRevSchedule.size();i++)
                    {
                        String tempDate = strRevSchedule[i].split(':')[0];
                        Integer RevenueYear = Integer.valueOf(tempDate.left(4));
                        Integer RevenueMonth = Integer.valueOf(tempDate.mid(4,2));
                        Integer RevenueDay = Integer.valueOf(tempDate.right(2));
                        system.debug('year: ' + tempDate.left(4));
                        system.debug('month: ' + tempDate.mid(5,2));
                        system.debug('day: ' + tempDate.right(2));
                        Date RevenueDate = Date.newInstance(RevenueYear,RevenueMonth,RevenueDay);
                        Decimal RevenueAmount = Decimal.valueOf(strRevSchedule[i].split(':')[1]);
                        
                        //Added by Ghanshyam Saini - Issue-07797 - Start
                        //clone the revenue schedule and replace with revised revenue schedule
                        Map<Date, String> schDatetoDescMap = new Map<Date, String>();
                        if(bsMap.get(oli.id) != null) {
                            for(OpportunityLineItemSchedule schedule : bsMap.get(oli.id)) {
                                schDatetoDescMap.put(schedule.ScheduleDate, schedule.Description);
                            }
                        }
                        if(bsMap.get(oli.id) != null) {
                        	OpportunityLineItemSchedule cloneOLIS = bsMap.get(oli.id)[0].clone();
	                        cloneOLIS.Revenue = RevenueAmount;
	                        cloneOLIS.ScheduleDate = RevenueDate;
                                cloneOLIS.Description = schDatetoDescMap.get(RevenueDate);
	                        OLIS_wrapper.add(cloneOLIS);
                        }
                        //Added by Ghanshyam Saini - Issue-07797 - End
                        //OLIS_wrapper.add(new OpportunityLineItemSchedule(OpportunityLineItemId=oli.Id,Revenue=RevenueAmount,ScheduleDate=RevenueDate));                                                  
                    }
                    if (strRevSchedule.size() > 0){
                    	bsMap.put(oli.id,OLIS_wrapper);
                    }
                 }                                            
           }
        }
        return bsMap;
        
    }
    /**
     * Getter method for Revenue_Schedule_Items_String
     */
    public String getRevenue_Schedule_Items_String() {
        
        Map<String,List<OpportunityLineItemSchedule>> bsMap = getRevenue_Schedule_Items();
        Revenue_Schedule_Items_String = JSON.serialize(bsMap);
        return Revenue_Schedule_Items_String;
    }


    // Add current time for Document Versioning
    public DateTime getCurrentTime()
    {
        return System.now();
    }
      
}