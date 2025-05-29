/*
 * This Class is Used to Render MIBNF Component as PDF
 * Create By: Himanshu Parashar
 * Date: 11 Nov 2011
 * Page: MI_BNF_Comp_PDF 
 */
public with sharing class MI_BNF_Comp_PDF {
    MIBNF_Component__c MIBNF_Comp;
    MIBNF2__c MIBNF;
    String OpportunityId;
    String MIBNFID;
    List<OpportunityLineItem> opptyLineItem;
    public Map<String, List<Billing_Schedule_Item__c>> Billing_Schedule_Items;
    public String Revenue_Schedule_Items_String;
   	public String Billing_Schedule_Items_String;
    public Boolean isNewBnf {get; private set;}
    private set<Id> JoOppLineItemidSet;
    private static Set<String> excludedProducts;
    static {
        BNF_Settings__c bnfSetting = BNF_Settings__c.getInstance();
        excludedProducts = new Set<String>();
        if(bnfSetting.Excluded_Products__c != null) {
            excludedProducts = new Set<String>(bnfSetting.Excluded_Products__c.split('\\|'));
        }
    }
    
    // updated by dheeraj kumar 04 Nov 2016 ER 3208 Start
    public List<String> updatedFieldSet {get; private set;}
    private Set<String> OLISchedulesFields = new Set<String>{'Description', 'Revenue', 'ScheduleDate'};
    // private Set<String> billingSchFields = new Set<String>{'Name', 'OLIId__c', 'Total_Billing_Amount__c'};
    private Set<String> billingSchItemFields = new Set<String>{'Billing_Amount__c', 'Billing_Date__c', 'Invoice_Description__c'};
    public Set<Id> addedFieldSet {get; private set;}
    
    // updated by dheeraj kumar 04 Nov 2016 ER 3208 End
	public MI_BNF_Comp_PDF() {
		// updated by dheeraj kumar 04 Nov 2016 ER 3208 Start
        updatedFieldSet = new List<String>();
        addedFieldSet = new Set<Id>();
        updatedFieldSet.add('MIBNF2__c');
        getMIBNF_Comp();
        getMIBNF();
        String query = 'Select  ';
		// String childQuery = '( Select ';
        for(Schema.FieldSetMember f : SObjectType.MIBNF2__c.FieldSets.FieldsToTraceMIBNF.getFields()) {
            query += 'MIBNF__r.' + f.getFieldPath() + ', ';  
        }
        for(Schema.FieldSetMember f : SObjectType.MIBNF_Component__c.FieldSets.FieldsToTraceMIBNFComp.getFields()) {
            query += f.getFieldPath() + ', ';  
        }
        query += ' OLI_Json_Data_1__c, OLI_Json_Data_2__c, OLI_Json_Data_3__c  FROM MIBNF_Component__c where opportunity__c = \'' + MIBNF_Comp.Opportunity__c + '\' and Name like  \'%'+ MIBNF_Comp.Orignal_BNF__r.Name + '%\'  and BNF_Status__c = \'SAP Contract Confirmed\' and RA_End_Date__c != null order by RA_End_Date__c desc limit 1';
        List<MIBNF_Component__c> lastApprovedMIBNFCompList = (List<MIBNF_Component__c>) Database.query(query);
        if(lastApprovedMIBNFCompList.size() > 0) {
            MIBNF_Component__c lastApprovedMIBNFComp = lastApprovedMIBNFCompList[0];
            if(lastApprovedMIBNFComp.OLI_Json_Data_1__c != null){
                for(Schema.FieldSetMember f : SObjectType.MIBNF2__c.FieldSets.FieldsToTraceMIBNF.getFields()) {
                    if(lastApprovedMIBNFComp.getSobject('MIBNF__r').get(f.getFieldPath()) != MIBNF.get(f.getFieldPath())){
                        updatedFieldSet.add(MIBNF.id +'.'+f.getFieldPath());
                    }
                }
                for(Schema.FieldSetMember f : SObjectType.MIBNF_Component__c.FieldSets.FieldsToTraceMIBNFComp.getFields()) {
                    if(lastApprovedMIBNFComp.get(f.getFieldPath()) != MIBNF_Comp.get(f.getFieldPath())){
                        updatedFieldSet.add(MIBNF_Comp.id +'.'+ f.getFieldPath());
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
                query += ' , BSI_Json_Data_LAB__c, OLIS_Json_Data_LAB__c, Other_Ship_To_Address__r.Name, Other_Ship_To_Address__r.SAP_Reference__c, Other_Ship_To_SAP_Contact__r.Name, PricebookEntry.Name,  '+ childQuery +' FROM OpportunityLineItem where OpportunityId = \'' + MIBNF.opportunity__c + '\'';
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
                List<Billing_Schedule_Item__c> currentbillingScheduleItems = Database.query(query);
                List<OpportunityLineItemSchedule> currentOliSchList;
                Map<Id, Billing_Schedule_Item__c> priorBilSchItemsMap;
                List<OpportunityLineItem> priorOliWholeList = new  List<OpportunityLineItem>(); 
                
                if(lastApprovedMIBNFComp.OLI_Json_Data_1__c != null){
                    priorOliWholeList.addAll((List<OpportunityLineItem>) json.deserialize(lastApprovedMIBNFComp.OLI_Json_Data_1__c, List<OpportunityLineItem>.class));
                }
                if(lastApprovedMIBNFComp.OLI_Json_Data_2__c != null){
                    priorOliWholeList.addAll((List<OpportunityLineItem>) json.deserialize(lastApprovedMIBNFComp.OLI_Json_Data_2__c, List<OpportunityLineItem>.class));
                }
                if(lastApprovedMIBNFComp.OLI_Json_Data_3__c != null){
                    priorOliWholeList.addAll( (List<OpportunityLineItem>) json.deserialize(lastApprovedMIBNFComp.OLI_Json_Data_3__c, List<OpportunityLineItem>.class));
                }
                
                Map<Id, OpportunityLineItem> priorOliWholeMap = new Map<Id, OpportunityLineItem>(priorOliWholeList);
                Map<Id, OpportunityLineItemSchedule> priorOliSchMap;
                for(OpportunityLineItem oli : currentOliMap.values()) {
                    if(priorOliWholeMap.containsKey(oli.id)) {
                        for(Schema.FieldSetMember f : SObjectType.OpportunityLineItem.FieldSets.FieldsToTraceForBNF.getFields()) {
                            system.debug('&&&&& oli.get(f.getFieldPath()) = ' + oli.get(f.getFieldPath()));
							system.debug('&&&&& priorOliWholeMap.get(oli.id).get(f.getFieldPath()) = ' + priorOliWholeMap.get(oli.id).get(f.getFieldPath()));
                            
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
                            priorOliSchMap  =  new Map<Id,OpportunityLineItemSchedule>((List<OpportunityLineItemSchedule>)json.deserialize(oli.OLIS_Json_Data_LAB__c, List<OpportunityLineItemSchedule>.class)) ;
                            for(OpportunityLineItemSchedule olisch : currentOliMap.get(oli.id).OpportunityLineItemSchedules) {
                                if(priorOliSchMap.containsKey(olisch.id)) {
                                    for(String str : OLISchedulesFields) {
                                        if(olisch.get(str) != priorOliSchMap.get(olisch.id).get(str)){
                                            updatedFieldSet.add(olisch.id + '.' + str);
                                        }   
                                    }         
                                 }
                                 else if(olisch.OpportunityLineItemId == oli.id){
                                    addedFieldSet.add(olisch.id);
                                 }
                            }
                        }
                        if(oli.BSI_Json_Data_LAB__c != null) {   
                            System.debug('oli.BSI_Json_Data_LAB__c ' + oli.BSI_Json_Data_LAB__c );
                            priorBilSchItemsMap = new Map<Id,Billing_Schedule_Item__c >((List<Billing_Schedule_Item__c>)json.deserialize(oli.BSI_Json_Data_LAB__c, List<Billing_Schedule_Item__c>.class)) ;
                            for(Billing_Schedule_Item__c billingLineItem : currentbillingScheduleItems) {
                                if(priorBilSchItemsMap.containsKey(billingLineItem.id)) {
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
                    } else {
                        addedFieldSet.add(oli.id);
                    }
                }
            }
        }
        
        // updated by dheeraj kumar 04 Nov 2016 ER 3208 End
        // Get LineItem from MIBNF LineItem    
		JoOppLineItemidSet = new set<Id>();
		for(MI_BNF_LineItem__c MIBNF_LineItem : [Select Opportunity_Line_Itemid__c from MI_BNF_LineItem__c where MIBNF_Component__c=:System.currentPageReference().getParameters().get('id')]) {
			JoOppLineItemidSet.add(MIBNF_LineItem.Opportunity_Line_Itemid__c);
		} 
	}
    
    public MIBNF_Component__c  getMIBNF_Comp() 
    {
		if(MIBNF_Comp == null) { 
	        // updated by dheeraj kumar 04 Nov 2016 ER 3208 Start
	        String query = 'SELECT ';
	        for(Schema.FieldSetMember f : SObjectType.MIBNF_Component__c.FieldSets.FieldsToTraceMIBNFComp.getFields()) {
	            query += f.getFieldPath() + ', ';  
	        }
	        query += ' MIBNF__r.Opportunity__c,MIBNF__r.Opportunity__r.Opportunity_Number__c, MIBNF__r.Client__c, Orignal_BNF__r.Name, MIBNF__r.Name, LastModifiedBy.Name, CreatedBy.Name, Bill_To__r.Name, Ship_To__r.Name, Bill_To_SAP_Contact__r.Name, Ship_To_SAP_Contact__r.Name, Sold_To__r.Name, X2nd_Copy__r.Name, Cover_Sheet__r.Name, X2nd_Copy_SAP_Contact__r.Name, Cover_Sheet_SAP_Contact__r.Name, Carbon_Copy__r.Name, Carbon_Copy_SAP_Contact__r.Name from MIBNF_Component__c where id = \'' + System.currentPageReference().getParameters().get('id') + '\'';
	        // updated by dheeraj kumar 04 Nov 2016 ER 3208 End
	        MIBNF_Comp = (MIBNF_Component__c) Database.query(query)[0];
	        
	        isNewBnf = false;
	        try {
                    if(BNF_Settings__c.getInstance().BNF_Opportunity_Threshold__c != null) {
                        if(Integer.valueOf(MIBNF_Comp.MIBNF__r.Opportunity__r.Opportunity_Number__c) > BNF_Settings__c.getInstance().BNF_Opportunity_Threshold__c) {
	                    isNewBnf = true;                
	                } 
	            } 
			} catch(Exception exp) {
	            isNewBnf = false;
	        }
		}
		OpportunityId =  MIBNF_Comp.MIBNF__r.Opportunity__c;
		return MIBNF_Comp;
    }
    
    public MIBNF2__c getMIBNF() {
		if(MIBNF == null) {       
            // updated by dheeraj kumar 04 Nov 2016 ER 3208 Start
            String query = 'SELECT ';
            for(Schema.FieldSetMember f : SObjectType.MIBNF2__c.FieldSets.FieldsToTraceMIBNF.getFields()) {
                query += f.getFieldPath() + ', ';  
            }
            query += ' Opportunity__r.Opportunity_Number__c,Revenue_Analyst__r.Name,Client__r.Name,Original_Prior_Opportunity__r.Name,Opportunity__r.Name  from MIBNF2__c where id= \'' + System.currentPageReference().getParameters().get('mibnfid') + '\'';        
            // updated by dheeraj kumar 04 Nov 2016 ER 3208 End
            MIBNF = (MIBNF2__c) Database.query(query)[0];  
		}
		return MIBNF;
    }


   /* Getter For OpportunityLineItem */ 
   public List<OpportunityLineItem> getOpportunityLineItem() 
   {        
       //Update by: Ritesh Gupta : Issue-07072 - Audit_Subscription_Status__c added     
	   // Updated by Dheeraj -- Issue-10593 -- 30  march 2017
       opptyLineItem = [Select ProfitCenter__c, ProfitCenter__r.Name, PricebookEntry.Name,Book_No__c,CurrencyISOCode,TotalPrice,Surcharge_text__c,
       Delivery_Media__c,PricebookEntry.ProductCode,Billing_Frequency__c,Proj_Rpt_Frequency__c, Discount_Percentage_Formula__c,
       Product_Start_Date__c,Product_End_Date__c, WBS__c,WBSRElement__c,WBS_R_Element__c,Nbr_of_Users__c,Business_Type__c,Product2.Name,PricebookEntry.Product2.Material_Type__c,Practice_Area__c,SubPractice_Area__c,Delivery_Country__c, List_Price__c, Discount_Reason__c,PO_line_item_number__c, Invoice_Date__c, Product_Invoice_Text__c, Discount_Amount_Formula__c, Other_Ship_To__c, Revised_Price__c,MIBNF_Cancel__c,
       Sale_Type__c,Revenue_Type__c,WinBack__c, Invoice_Lag_to_Data_Period__c,Billing_Date__c, Delivery_Date__c, PO_Number__c, Sales_Text__c, Audit_Subscription_Status__c, therapy_area__c,Other_Ship_To_Address__r.Name,Other_Ship_To_Address__r.SAP_Reference__c,Other_Ship_To_SAP_Contact__r.SAP_Contact_Number__c,Other_Ship_To_SAP_Contact__r.Name,Revised_Revenue_Schedule__c,
       PricebookEntry.Product2.Item_Category_Group__c,Budget_Billing_Model__c, Prebilling__c
       from OpportunityLineItem 
       where id in:JoOppLineItemidSet and OpportunityId = :OpportunityId AND Product_Material_Type__c NOT IN :excludedProducts order by PricebookEntry.ProductCode asc, Product_Start_Date__c asc];    
       for(OpportunityLineItem oli : opptyLineItem){
           if(oli.Product2.Name.length() > 30 ){
               oli.Product2.Name = oli.Product2.Name.substring(0,29)+'\n'+oli.Product2.Name.substring(29,oli.Product2.Name.length());
           }
       }
       return opptyLineItem;
    }
    
    public Map<String,List<Billing_Schedule_Item__c>> getBilling_Schedule_Items()
    {
        Map<String, List<Billing_Schedule_Item__c>> bsMap = new Map<String, List<Billing_Schedule_Item__c>>();
        //bsMap.put(null, null);
        if(System.currentPageReference().getParameters().get('id') != null && System.currentPageReference().getParameters().get('id') != '') {            
            for(Billing_Schedule__c bs : [Select Total_Billing_Amount__c, OLIId__c,
                Name, Id, CurrencyIsoCode,
                (Select Name, Billing_Amount__c, Billing_Date__c, Invoice_Description__c, Billing_Schedule__c 
                	From Billing_Schedule_Items__r order by Billing_Date__c asc)
                From Billing_Schedule__c where OLIId__c in :JoOppLineItemidSet]) {
                List<Billing_Schedule_Item__c> lstt = new List<Billing_Schedule_Item__c>();
                lstt = bs.Billing_Schedule_Items__r;
                bsMap.put(bs.OLIId__c, lstt);
            }
            opptyLineItem = getOpportunityLineItem();
            for(Opportunitylineitem oli: opptyLineItem)
            {
                if(!bsMap.containskey(oli.id))
                {
                    // This Blank record is required to format billing schedule in PDF
                    Billing_Schedule_Item__c tempobj = new Billing_Schedule_Item__c(Invoice_Description__c = '                            ');
                    List<Billing_Schedule_Item__c> lstt = new List<Billing_Schedule_Item__c>(); 
                    lstt.add(tempobj); 
                    bsMap.put(oli.id, lstt);
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
    

    public Map<String,List<OpportunityLineItemSchedule>> getRevenue_Schedule_Items()
    {
		Map<String, List<OpportunityLineItemSchedule>> bsMap = new Map<String, List<OpportunityLineItemSchedule>>();
        //bsMap.put(null, null);
        Set<ID> oppIds = new Set<ID>();

        if(System.currentPageReference().getParameters().get('id')!= null && System.currentPageReference().getParameters().get('id') != '') 
        {
            for(Opportunitylineitem oli: opptyLineItem) {
                oppIds.add(oli.id);
            }            
            
			//  Get all revenue schedules
            for(OpportunityLineItemSchedule bs : [select Description,Quantity, Revenue, ScheduleDate, opportunityLineItemID  from OpportunityLineItemSchedule where opportunityLineItemID IN: JoOppLineItemidSet order by ScheduleDate asc]) {
                if(bsMap.containskey(bs.opportunityLineItemID)) {
                    bsMap.get(bs.opportunityLineItemID).add(bs);
                } else {
                    List<OpportunityLineItemSchedule> lstt = new List<OpportunityLineItemSchedule>();
                    lstt.add(bs);
                    bsMap.put(bs.opportunityLineItemID, lstt);
                }
            }
            
            for(Opportunitylineitem oli: opptyLineItem) {
                if(!bsMap.containskey(oli.id)) {
                    // This Blank record is required to format billing schedule in PDF
                    OpportunityLineItemSchedule tempobj = new OpportunityLineItemSchedule ();
                    List<OpportunityLineItemSchedule> lstt = new List<OpportunityLineItemSchedule>(); 
                    lstt.add(tempobj); 
                    bsMap.put(oli.id, lstt);
                }
			}
           
			// If any line items have revised revenue schedules, overwrite the map with the revised schedules               
            for(Opportunitylineitem oli: opptyLineItem)
            {
                List<String> strRevSchedule = new List<String>();
                List<OpportunityLineItemSchedule> OLIS_wrapper = new List<OpportunityLineItemSchedule>();
                if (oli.Revised_Revenue_Schedule__c != null && oli.Revised_Revenue_Schedule__c != '')
                {
                    strRevSchedule = oli.Revised_Revenue_Schedule__c.split('\\|');
                    // If Revised_Revenue_Schedule__c contains 'x' it indicates that a revised price of zero has been entered
                    if (strRevSchedule[0] == 'x')
                    {
                        strRevSchedule.clear();
                        // Put an empty OpportunityLineItemSchedule list in the map for this line item                     
                        bsMap.put(oli.id, OLIS_wrapper);
                    }
                } 
                for(integer i = 0; i < strRevSchedule.size(); i++)
                {
                    String tempDate = strRevSchedule[i].split(':')[0];
                    Integer RevenueYear = Integer.valueOf(tempDate.left(4));
                    Integer RevenueMonth = Integer.valueOf(tempDate.mid(4,2));
                    Integer RevenueDay = Integer.valueOf(tempDate.right(2));
                    system.debug('year: ' + tempDate.left(4));
                    system.debug('month: ' + tempDate.mid(5,2));
                    system.debug('day: ' + tempDate.right(2));                    
                    Date RevenueDate = Date.newInstance(RevenueYear, RevenueMonth, RevenueDay);
                    Decimal RevenueAmount = Decimal.valueOf(strRevSchedule[i].split(':')[1]);
                    Map<Date, String> schDatetoDescMap = new Map<Date, String>();
                    if(bsMap.get(oli.id) != null) {
                        for(OpportunityLineItemSchedule schedule : bsMap.get(oli.id)) {
                            schDatetoDescMap.put(schedule.ScheduleDate, schedule.Description);
                        }
                    }
                    // Added on 10, April 2017 , Issue-10676- Start
                    // clone the revenue schedule and replace with revised revenue schedule
                    if(bsMap.get(oli.id) != null){
                        OpportunityLineItemSchedule cloneOLIS = bsMap.get(oli.id)[0].clone();
                        cloneOLIS.Revenue = RevenueAmount;
                        cloneOLIS.ScheduleDate = RevenueDate;
                        cloneOLIS.Description = schDatetoDescMap.get(RevenueDate);
                        OLIS_wrapper.add(cloneOLIS);
                    }
                    // Added on 10, April 2017- Issue-10676- End
                    
	                // Commented on 10, April 2017- Issue-10676
	                // OLIS_wrapper.add(new OpportunityLineItemSchedule(OpportunityLineItemId=oli.Id,Revenue=RevenueAmount,ScheduleDate=RevenueDate));                                                  
                }
                if (strRevSchedule.size() > 0){
                    bsMap.put(oli.id, OLIS_wrapper);
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