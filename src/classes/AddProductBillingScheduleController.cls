public class AddProductBillingScheduleController {
    private static final String FIFTY_FIFTY = '50/50';
    private static final String FOURTY_SIXTY = '60/40';
    private static final String SIGNATURE_100 = '100% on signature';
    private static final String DELIVERY_100 = '100% on delivery';
    private static final String MONTHLY = 'Monthly';
    private static final String QUARTERLY = 'Quarterly';
    
    private static final String NONE = '-';
    private static final String OPP_LEVEL = 'Opportunity Level';
    private static final String OLI_LEVEL = 'Component Level';
    
    Public Integer selectedOpLevel{get;set;}
    Public double zrepAmount;// {get; private set;}
    public Billing_Schedule_Item__c temp_obj{get;set;}
    Public List<String> L {get;private set;} 
    Public static String BNfId; 

    Public static String oliId;   // Ghanshyam Saini
    Public BNF2__c currentBNf ;
    public Date conStartDate;
    public Date conEndDate;
    public Date opptyContractStartDate {get; set;} 
    public Date opptyContractEndDate {get; set;}
    Public OpportunityLineItem currentOli;   // Ghanshyam Saini   
    Public List<Billing_Schedule__c> bsList;
    Public List<Billing_Schedule_Item__c> insertBSiList; 
    Public String salesOrgCode ;     
    public boolean compLevelappliedalready{get;set;}
    public decimal grandtotal;
    public Boolean PreventEdit {get; set;}
    public Date zlicLineItemStartDate{get; set;}
    public Date zlicLineItemEndDate{get; set;}
    
    private static final String ERR_BILLINGPLAN_MISSING =  'Please select billing plan pattern.';
    private static final String ERR_NEGATIVE_AMOUNT     ='Error:BIllingAmount can not be negative  ';
    private static final String ERR_ZEROAMOUNT          = 'Error:bIlling Amount can not zero  ';
    private static final String ERR_BILLINGDATE         = 'Error: Multiple billing schedules cannot have the same billing date.';                 
    private static final String ERR_COMPLEVEL_NEGATIVE_AMOUNT = 'Error: Amount can not be negative  ';
    private static final String ERR_COMPLEVEL_ZEROAMOUNT      = 'Error: Amount can not be zero';
    private static final String ERR_TOTALAMOUNT         = 'Error while saving schedules: Total amount of Billing schedule Amount  can not more than Opportunity Total amount' ; 
    private static final String ERR_SAVING              = 'error while saving schedules: ';
    private static final String ERR_DELETING            = 'error while deleting schedules: ';
    private static final String ERR_UPDATING            = 'error updating schedules: ';
    //selected billing schedule pattern   
    public String billingPattern {get;set;}
       
    //selected billing schedule level
    public String billingLevel {get; set;}  
    
    public Opportunity opp {get; private set;}
    
    public List<OpportunityLineItem> oliList = new List<OpportunityLineItem> ();    
    public List<OpportunityLineItemWrapper> oliWrapperList {get; set;}
    
    //Boolean to indicate if billing schedule is present for any of the opportunityLineItem
    public Boolean isSchedulePresent {get; private set;}
    
    //list to show opportunity Level schedules
    public List<OppLevelSchedulesWrapper> oppLvlSchWrapper {get; set;}
    
    //flag for closing the pop up on successfule saving of details
    public Boolean isSaveSuccessful {get; private set;}
    
    public Boolean showWarning {get;private set;}
    
    public Boolean isOPPBelowStage3 {get; private set;}
    
    //hide the save and Close button from mobile device.
    public Boolean hideSaveCloseButton{get; private set;}  
    
    //Issue-05144
    Set<String> bnfStatus = new Set<String>{'Submitted','LO Accepted','RA Accepted','SAP Pending','SAP Contract Pending'};
    public boolean bnfSubmitted {get; set;}
    
    public static List<SelectOption> getBillingPatterns() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption(NONE , NONE ));
        options.add(new SelectOption(FIFTY_FIFTY, FIFTY_FIFTY));
        options.add(new SelectOption(FOURTY_SIXTY,FOURTY_SIXTY));
        options.add(new SelectOption(SIGNATURE_100,SIGNATURE_100));
        options.add(new SelectOption(DELIVERY_100,DELIVERY_100));
        options.add(new SelectOption(MONTHLY ,MONTHLY ));
        options.add(new SelectOption(QUARTERLY ,QUARTERLY ));
        return options;        
    }
    
    public static List<SelectOption> getBillingLevels(){
        List<SelectOption> options = new List<SelectOption> ();
        options.add(new SelectOption(OPP_LEVEL, OPP_LEVEL));
        options.add(new SelectOption(OLI_LEVEL, OLI_LEVEL));
        return options;
    }
  
    //==========================Constructor=======================================//
    public AddProductBillingScheduleController(ApexPages.StandardController stdController) {
        //initialization
        PreventEdit = false;
        billingLevel = OLI_LEVEL;
        isSchedulePresent = false;
        billingPattern = NONE;
        isSaveSuccessful = false;
        showWarning = false;  
        isOPPBelowStage3 = false; 
        hideSaveCloseButton = true;
        temp_obj = new Billing_Schedule_Item__c();       
        // fetching id of currently BNF from URL

		//End
        currentOli = (OpportunityLineItem)stdController.getRecord();  // Ghanshyam Saini  
        
        // Ghanshyam Saini
        oliList = [select id, CurrencyIsoCode,Opportunity.StageName, Opportunity.currencyIsoCode, Opportunity.Contract_Start_Date__c, Opportunity.Contract_End_Date__c, Project_Start_Date__c,Project_End_Date__c,
        TotalPrice,PricebookEntry.Product2.Name, PricebookEntry.Product2.material_type__c,PricebookEntry.Product2.ProductCode, PricebookEntry.Product2.Item_Category_Group__c, Product_Start_Date__c, Product_End_Date__c,Revised_Price__c,Revised_Revenue_Schedule__c,Discount_Amount_Formula__c from OpportunityLineItem where id =: currentOli.id];
        oliId = currentOli.id;  
        
        // If BNF exist then use BNF start and end date instead of oppoetunity date
        BnfId = ApexPages.CurrentPage().getParameters().get('bnfid');
        if (BnfId != null && BnfId.length() > 0) {	
        	BNF2__c bnf = [select Id, Contract_Start_Date__c, Contract_End_Date__c from BNF2__c where Id =: BnfId];
        	opptyContractStartDate = bnf.Contract_Start_Date__c;
	        opptyContractEndDate = bnf.Contract_End_Date__c;
        } else {
	        opptyContractStartDate = olilist[0].Opportunity.Contract_Start_Date__c;
	        opptyContractEndDate = olilist[0].Opportunity.Contract_End_Date__c;    	        
        }
        
        if(ApexPages.CurrentPage().getParameters().get('startdate') != null && ApexPages.CurrentPage().getParameters().get('startdate').length() > 0) {
            if(ApexPages.CurrentPage().getParameters().get('isLWC') == 'true'){
                zlicLineItemStartDate = Date.ValueOf(ApexPages.CurrentPage().getParameters().get('startdate'));
            }else{
                zlicLineItemStartDate = date.parse(ApexPages.CurrentPage().getParameters().get('startdate'));
            }
        } else {
        	 if(olilist[0].PricebookEntry.Product2.material_type__c =='ZREP' && olilist[0].Project_Start_Date__c != null) {
        	 	zlicLineItemStartDate = olilist[0].Project_Start_Date__c;
        	 } else if(olilist[0].PricebookEntry.Product2.material_type__c =='ZREP' && olilist[0].Project_Start_Date__c == null) {
        	 	zlicLineItemStartDate = opptyContractStartDate;
        	 } else if(olilist[0].PricebookEntry.Product2.Item_Category_Group__c =='ZLIC' && olilist[0].Product_Start_Date__c != null) {
        	 	zlicLineItemStartDate = olilist[0].Product_Start_Date__c;
        	 } else if(olilist[0].PricebookEntry.Product2.Item_Category_Group__c =='ZLIC' && olilist[0].Product_Start_Date__c != null) {
        	 	zlicLineItemStartDate = opptyContractStartDate;
        	 }
        }
        
        if(ApexPages.CurrentPage().getParameters().get('enddate') != null && ApexPages.CurrentPage().getParameters().get('enddate').length() > 0) {
            if(ApexPages.CurrentPage().getParameters().get('isLWC') == 'true'){
                zlicLineItemEndDate = Date.ValueOf(ApexPages.CurrentPage().getParameters().get('enddate'));
            }else{
                zlicLineItemEndDate = date.parse(ApexPages.CurrentPage().getParameters().get('enddate'));
            }
        } else {
        	 if(olilist[0].PricebookEntry.Product2.material_type__c =='ZREP' && olilist[0].Project_End_Date__c != null) {
        	 	zlicLineItemEndDate = olilist[0].Project_End_Date__c;
        	 } else if(olilist[0].PricebookEntry.Product2.material_type__c =='ZREP' && olilist[0].Project_End_Date__c == null) {
        	 	zlicLineItemEndDate = opptyContractStartDate;
        	 } else if(olilist[0].PricebookEntry.Product2.Item_Category_Group__c =='ZLIC' && olilist[0].Product_End_Date__c != null) {
        	 	zlicLineItemEndDate = olilist[0].Product_Start_Date__c;
        	 } else if(olilist[0].PricebookEntry.Product2.Item_Category_Group__c =='ZLIC' && olilist[0].Product_End_Date__c != null) {
        	 	zlicLineItemEndDate = opptyContractStartDate;
        	 }
        }
        if(olilist[0].Opportunity.StageName == CON_CRM.IDENTIFYING_OPP_STAGE || olilist[0].Opportunity.StageName == CON_CRM.QUALIFYING_OPP_STAGE || olilist[0].Opportunity.StageName == CON_CRM.DEVELOPING_PROP_STAGE) {
            isOPPBelowStage3 = true;
        }
        //  This gets the latest revised price that has been entered in the OLI.Revised_revenue_Schedule__c field but
        //  OLI.Revised_Price__c has not yet been updated on the OLI
        if(olilist[0].Revised_Revenue_Schedule__c != null)
        {
            List<String> strRevSchedule = olilist[0].Revised_Revenue_Schedule__c.split('\\|');  
            //  If Revised_Revenue_Schedule__c contains 'x' it indicates that a revised price of zero has been entered
            if (strRevSchedule[0] == 'x'){
            	strRevSchedule.clear();
            }
            olilist[0].Revised_Price__c = 0;            
            for (integer i=0;i<strRevSchedule.size();i++)
            {
                //  Overwrite the Revised_Price__c to have the latest value as entered on revised revenue schedule
                olilist[0].Revised_Price__c += Decimal.valueOf(strRevSchedule[i].split(':')[1]);            
            }                   
        }

        //set default billing schedule pattern for the IMS sales org
        salesOrgCode = ApexPages.CurrentPage().getParameters().get('salesOrg');     
        
        if(salesOrgCode != null && salesOrgCode !='') {
            List<SalesOrg__c> salesOrgList = [SELECT Default_Billing_Pattern__c FROM SalesOrg__c 
                                            where CompanyCode__c =:salesOrgCode limit 1 ];
            if(salesOrgList != null && salesOrgList.size() > 0){
                billingPattern = salesOrgList[0].Default_Billing_Pattern__c;     
            }
         }
      
        zrepAmount = 0.00;
        for (OpportunityLineItem oppLineItem : oliList){
            if(oppLineItem.PricebookEntry.Product2.material_type__c =='ZREP' || oppLineItem.PricebookEntry.Product2.Item_Category_Group__c=='ZLIC')
            {
                //  Use revised price if this has been set
                if(oppLineItem.Revised_Price__c != null)
                {
                	zrepAmount += oppLineItem.Revised_Price__c;
                	//  Set sales price = revised price so that the new value gets used for billing pattern 
            		oppLineItem.TotalPrice = oppLineItem.Revised_Price__c;   
                }
                else if(oppLineItem .TotalPrice != null)
                {
                	zrepAmount += oppLineItem.TotalPrice;
                }
            }
        }	
        temp_obj.currencyIsoCode = oliList[0].Opportunity.currencyIsoCode;
        temp_obj.Billing_Amount__c =zrepAmount;
         
        //for hinding save & close button for mobile device.
        if(UserInfo.getUiThemeDisplayed() == 'Theme4t'){
            hideSaveCloseButton = false;
        }
        
        resetSchedules();
        Init();
    }
    // this Methdod to reset to unsaved data and come back to last saved state    
    public PageReference  crudeReset() {        
         salesOrgCode = ApexPages.CurrentPage().getParameters().get('salesOrg'); 
                
        PageReference page = new PageReference('/apex/AddProductBillingSchedule?id=' + currentOli.id + '&oppId=' + olilist[0].Opportunity.id) ;      
        page.setRedirect(true);   
             
        return page;       
      
    }
    /**
    Billing schedules will be reset back to previously saved database state.
    **/
     
    //========================resetSchedules method ==============================
    public void resetSchedules(){
        //reinitialize the list of marked deletions
        deletedSchedules = new Set<Billing_Schedule_Item__c> ();
        Set<Id> OLIIdSet = new  Set<Id>(); 
        for (OpportunityLineItem oppLineItem : oliList){
        if(oppLineItem .TotalPrice != null /*&& oppLineItem .TotalPrice >0*/ && 
                      (oppLineItem.PricebookEntry.Product2.material_type__c =='ZREP' || (oppLineItem.PricebookEntry.Product2.Material_Type__c=='ZPUB' && 
                                        oppLineItem.PricebookEntry.Product2.Item_Category_Group__c=='ZLIC'))){
              OLIIdSet.add(oppLineItem.Id) ;
           }
        }     
        oliWrapperList = new List<OpportunityLineItemWrapper>();
        //map of oli id and billing schedule
        Map<Id, Billing_Schedule__c> billingSchedueMap = new Map<Id, Billing_Schedule__c>();       
        
        List<Billing_Schedule__c> currentBsList = [ select id,oliid__c ,(Select id, Billing_Amount__c, Billing_Date__c,Invoice_Description__c,
                                                        Billing_Schedule__c from Billing_Schedule_Items__r order by Billing_Date__c ) 
                                                        from Billing_Schedule__c where OLIId__c in : OLIIdSet];
                
        for(Billing_Schedule__c bs : currentBsList) {
            billingSchedueMap.put(bs.oliid__c, bs);
        }
        
        //for(Billing_Schedule__c b : Billing_Schedule__c)
        for(OpportunityLineItem oli : oliList){
             If(oli.PricebookEntry.Product2.material_type__c == 'ZREP' || (oli.PricebookEntry.Product2.Material_Type__c=='ZPUB' && 
                                        oli.PricebookEntry.Product2.Item_Category_Group__c=='ZLIC')){              
                Billing_Schedule__c bsFromMap = billingSchedueMap.get(oli.id);
                if(bsFromMap != null) {                   
                    //create BillingScheduleWrapper object and add to list here
                    OpportunityLineItemWrapper oliW = new OpportunityLineItemWrapper(oli,bsFromMap, null);                       

                    Date startDate;
                    Date endDate;
                    if(oliW.oli.Project_Start_Date__c != null && oliW.oli.Project_End_Date__c != null){
							startDate = zlicLineItemStartDate;  
							endDate = zlicLineItemEndDate;                              
                    }else if(oliW.oli.PricebookEntry.Product2.material_type__c == 'ZPUB' && oliW.oli.PricebookEntry.Product2.Item_Category_Group__c == 'ZLIC' && oliW.oli.Product_Start_Date__c != null && oliW.oli.Product_End_Date__c != null){
							startDate = zlicLineItemStartDate == null ? oliW.oli.Product_Start_Date__c : zlicLineItemStartDate;  
							endDate = zlicLineItemEndDate == null ? oliW.oli.Product_End_Date__c : zlicLineItemEndDate;                             
                    }else{
                            startDate = opptyContractStartDate;
                            endDate = opptyContractEndDate;
                    }
                    oliW.setHeaderStartEndDate(startDate, endDate);
                  
                    List<Billing_Schedule_Item__c> oliScheduleList = bsFromMap.Billing_Schedule_Items__r;                   
                    if(oliScheduleList != null){                                          
                        for(Billing_Schedule_Item__c schItem : oliScheduleList  ){ 
                                        oliW.addBilingSchedule( schItem);                                       
                                        isSchedulePresent = true;
                        }
                    }
                    //add to the list of OpportunityLineItemWrapper here
                       oliWrapperList.add(oliW);  
                }
                else {                   
                    OpportunityLineItemWrapper oliW = new OpportunityLineItemWrapper(oli,null, null);                       
                    oliWrapperList.add(oliW);                   
                }
            }
        }
    }
    /**
    Add Opportunity level schedule 
    **/
    public void addOppLevelSchedule () {        
        OppLevelSchedulesWrapper oppLvlSch = new OppLevelSchedulesWrapper();
        oppLvlSch.scheduleItem = new Billing_Schedule_Item__c();         
        oppLvlSch.scheduleItem.Billing_Date__c = System.today();
        oppLvlSch.scheduleItem.Billing_Amount__c = 0.00;
        oppLvlSch.scheduleItem.Invoice_Description__c = '';
        oppLvlSch.OppLevelindex = oppLvlSchWrapper.size()+1;
        oppLvlSchWrapper.add(oppLvlSch);
    }
    
    /**Based on the selected Default Billing Schedule Pattern
    *Billing schedules will be created to show on the screen but not saved.
    **/
    
    //================================calculateSchdeule Method====================================
    public void calculateSchedules() {
        issaved  = false;
        compLevelappliedalready = true;






            
        if(billingPattern == NONE ) {
             ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.ERROR,ERR_BILLINGPLAN_MISSING);                        
             //add error on page
             ApexPages.addMessage(errMsg );
             return;
        } 
        isSchedulePresent = true;        
        markAllSchedulesForDeletion();
        


        date conStDate = opptyContractStartDate;
        //conStDate = (conStDate < system.today())? system.today():conStDate;
        date startDate;
        date endDate;
        
        if(billingPattern == FIFTY_FIFTY){            
            for(OpportunityLineItemWrapper oliWrapper : oliWrapperList ) 
            {
                if (oliWrapper.oli.TotalPrice != 0 || oliWrapper.oli.Discount_Amount_Formula__c != 0)
        		{
	                if(oliWrapper.oli.Project_Start_Date__c != null && oliWrapper.oli.Project_End_Date__c != null){
									startDate = zlicLineItemStartDate;  
									endDate = zlicLineItemEndDate;                                      
	                        }else if(oliWrapper.oli.PricebookEntry.Product2.material_type__c == 'ZPUB' && oliWrapper.oli.PricebookEntry.Product2.Item_Category_Group__c == 'ZLIC' && oliWrapper.oli.Product_Start_Date__c != null && oliWrapper.oli.Product_End_Date__c != null){
									startDate = zlicLineItemStartDate == null ? oliWrapper.oli.Product_Start_Date__c : zlicLineItemStartDate;  
									endDate = zlicLineItemEndDate == null ? oliWrapper.oli.Product_End_Date__c : zlicLineItemEndDate;    		                                
	                        }else{
	                                startDate = conStDate;
	                                endDate = opptyContractEndDate;
	                        }
	                oliWrapper.setHeaderStartEndDate(startDate, endDate);        
	                oliWrapper.addBilingSchedule( startDate , oliWrapper.oli.TotalPrice/2, '');                
	                oliWrapper.addBilingSchedule( endDate, oliWrapper.oli.TotalPrice/2, '');
        		}
                
            }
        } else if (billingPattern == FOURTY_SIXTY){            
            for(OpportunityLineItemWrapper oliWrapper : oliWrapperList ) 
            {
                if (oliWrapper.oli.TotalPrice != 0 || oliWrapper.oli.Discount_Amount_Formula__c != 0)
        		{
                    if(oliWrapper.oli.Project_Start_Date__c != null && oliWrapper.oli.Project_End_Date__c != null){
	                                startDate = zlicLineItemStartDate;  
									endDate = zlicLineItemEndDate;      
	                        }else if(oliWrapper.oli.PricebookEntry.Product2.material_type__c == 'ZPUB' && oliWrapper.oli.PricebookEntry.Product2.Item_Category_Group__c == 'ZLIC' && oliWrapper.oli.Product_Start_Date__c != null && oliWrapper.oli.Product_End_Date__c != null){
									startDate = zlicLineItemStartDate == null ? oliWrapper.oli.Product_Start_Date__c : zlicLineItemStartDate;  
									endDate = zlicLineItemEndDate == null ? oliWrapper.oli.Product_End_Date__c : zlicLineItemEndDate;                                  
	                        }else{
	                                startDate = conStDate;
	                                endDate = opptyContractEndDate;
	                        }
	                oliWrapper.setHeaderStartEndDate(startDate, endDate);        
	                oliWrapper.addBilingSchedule( startDate , oliWrapper.oli.TotalPrice* (60.00/100.00), '');                
	                oliWrapper.addBilingSchedule( endDate, oliWrapper.oli.TotalPrice* (40.00/100.00), '');
        		}
          }
        } else if (billingPattern == SIGNATURE_100) {                
            for(OpportunityLineItemWrapper oliWrapper : oliWrapperList ) 
            { 
				if (oliWrapper.oli.TotalPrice != 0 || oliWrapper.oli.Discount_Amount_Formula__c != 0)
        		{

	                startDate = conStDate;
	                endDate = opptyContractEndDate;
	                oliWrapper.setHeaderStartEndDate(startDate, endDate);
	                oliWrapper.addBilingSchedule( startDate , oliWrapper.oli.TotalPrice, '');              
        		}
            }
        } else if (billingPattern == DELIVERY_100) {
            for(OpportunityLineItemWrapper oliWrapper : oliWrapperList ) 
            {
                if (oliWrapper.oli.TotalPrice != 0 || oliWrapper.oli.Discount_Amount_Formula__c != 0)
        		{
	                if(oliWrapper.oli.Project_Start_Date__c != null && oliWrapper.oli.Project_End_Date__c != null){
									startDate = zlicLineItemStartDate;  
									endDate = zlicLineItemEndDate;                                      
	                        }else if(oliWrapper.oli.PricebookEntry.Product2.material_type__c == 'ZPUB' && oliWrapper.oli.PricebookEntry.Product2.Item_Category_Group__c == 'ZLIC' && oliWrapper.oli.Product_Start_Date__c != null && oliWrapper.oli.Product_End_Date__c != null){
									startDate = zlicLineItemStartDate == null ? oliWrapper.oli.Product_Start_Date__c : zlicLineItemStartDate;  
									endDate = zlicLineItemEndDate == null ? oliWrapper.oli.Product_End_Date__c : zlicLineItemEndDate;                                    
	                        }else{
	                                startDate = conStDate;
	                                endDate = opptyContractEndDate;
	                        }
	                oliWrapper.setHeaderStartEndDate(startDate, endDate);        
	                oliWrapper.addBilingSchedule( endDate, oliWrapper.oli.TotalPrice, '');                             
        		}
            }
        } else if (billingPattern == MONTHLY) {         
                         
            //for each month, each line item add a schedule
            for(OpportunityLineItemWrapper oliWrapper : oliWrapperList ) 
            {
                if (oliWrapper.oli.TotalPrice != 0 || oliWrapper.oli.Discount_Amount_Formula__c != 0)
        		{
	                if(oliWrapper.oli.Project_Start_Date__c != null && oliWrapper.oli.Project_End_Date__c != null){
							startDate = zlicLineItemStartDate;  
							endDate = zlicLineItemEndDate;                              
	                }else if(oliWrapper.oli.PricebookEntry.Product2.material_type__c == 'ZPUB' && oliWrapper.oli.PricebookEntry.Product2.Item_Category_Group__c == 'ZLIC' && oliWrapper.oli.Product_Start_Date__c != null && oliWrapper.oli.Product_End_Date__c != null){
	                                startDate = zlicLineItemStartDate == null ? oliWrapper.oli.Product_Start_Date__c : zlicLineItemStartDate;  
									endDate = zlicLineItemEndDate == null ? oliWrapper.oli.Product_End_Date__c : zlicLineItemEndDate;  
	                }else{
	                        startDate = conStDate;
	                        endDate = opptyContractEndDate;
	                }
	                
	                Integer monthsBetween = startDate.monthsBetween(endDate);                       
                    if(monthsBetween < 0) {
	                        monthsBetween *= (-1);
                    }
	                    // updated by Ghanshyam Saini       
	                    if(endDate.day() >= startDate.day()){
                            if(monthsBetween == 0) {
	                                monthsBetween = 1;
                            }
                            else  {  
	                                monthsBetween++;
                            }
	                    } 
	                    
	                    // updated by Ghanshyam Saini 
	                    oliWrapper.setHeaderStartEndDate(startDate, endDate);
	                    if(monthsBetween <= 1){
	                        oliWrapper.addBilingSchedule( startDate, oliWrapper.oli.TotalPrice, '');
	                    }else{
	                        for(Integer i = 0; i < monthsBetween-1; i++) {                    
	                            oliWrapper.addBilingSchedule( startDate.addMonths(i), 
	                                                          ( Integer.valueof((oliWrapper.oli.TotalPrice/monthsBetween)*100)/100.00), '');                                
	                        }
	                         oliWrapper.addBilingSchedule( startDate.addMonths(monthsBetween-1), 
	                                                          (oliWrapper.oli.TotalPrice - (Integer.valueof((oliWrapper.oli.TotalPrice/monthsBetween)*100)/100.00)*(monthsBetween-1)), ''); 
	                    }
	                                               
        		}
            }
        } else if (billingPattern == QUARTERLY ) {           
            
            //for each month, each line item add a schedule           
            for(OpportunityLineItemWrapper oliWrapper : oliWrapperList ) 
            {  
                if (oliWrapper.oli.TotalPrice != 0 || oliWrapper.oli.Discount_Amount_Formula__c != 0)
        		{
	                if(oliWrapper.oli.Project_Start_Date__c != null && oliWrapper.oli.Project_End_Date__c != null){
							startDate = zlicLineItemStartDate;  
							endDate = zlicLineItemEndDate;                              
	                }else if(oliWrapper.oli.PricebookEntry.Product2.material_type__c == 'ZPUB' && oliWrapper.oli.PricebookEntry.Product2.Item_Category_Group__c == 'ZLIC' && oliWrapper.oli.Product_Start_Date__c != null && oliWrapper.oli.Product_End_Date__c != null){
									startDate = zlicLineItemStartDate == null ? oliWrapper.oli.Product_Start_Date__c : zlicLineItemStartDate;  
									endDate = zlicLineItemEndDate == null ? oliWrapper.oli.Product_End_Date__c : zlicLineItemEndDate;                                  
	                }else{
	                        startDate = conStDate;
	                        endDate = opptyContractEndDate;
	                }  
	                
	                //find months between contract start date and end date            
	                    Integer monthsBetween = startDate.monthsBetween(endDate);
                    if(monthsBetween < 0) {
	                        monthsBetween *= (-1);
                    }
	                    
	                    Integer quartesBetween = (monthsBetween/3) +1;
                    if(quartesBetween < 0) {
	                        quartesBetween *= (-1);
                    }
	                    
                    if(quartesBetween == 0) {
	                        quartesBetween  = 1;
                    }
	                    oliWrapper.setHeaderStartEndDate(startDate, endDate);
	                    if(monthsBetween <= 1){
	                        oliWrapper.addBilingSchedule( startDate, oliWrapper.oli.TotalPrice, '');
	                    }else{              
	                        for(Integer i = 0; i < quartesBetween-1; i++) {                    
	                            oliWrapper.addBilingSchedule( startDate.addMonths(i*3), 
	                                                          ( Integer.valueof((oliWrapper.oli.TotalPrice/quartesBetween)*100)/100.00), '');                                
	                        }
	                         oliWrapper.addBilingSchedule( startDate.addMonths((quartesBetween-1)*3), 
	                                                          (oliWrapper.oli.TotalPrice - (Integer.valueof((oliWrapper.oli.TotalPrice/quartesBetween)*100)/100.00)*(quartesBetween-1)), '');                                
	                    }  
        		}                    
            }
        }
         
        oppLvlSchWrapper = new List<OppLevelSchedulesWrapper> ();
        Integer orederno = 1;  

        for(BillingScheduleWrapper bw : oliWrapperList[0].schedules)
        {          
          
          	if (oliWrapperList[0].oli.TotalPrice != 0)
        	{
	          OppLevelSchedulesWrapper oppLvlSch = new OppLevelSchedulesWrapper();
	          oppLvlSch.scheduleItem = new Billing_Schedule_Item__c();
	          
	          oppLvlSch.scheduleItem.Billing_Date__c = bw.scheduleItem.Billing_Date__c;      
	          oppLvlSch.scheduleItem.Billing_Amount__c = bw.scheduleItem.Billing_Amount__c *(ZrepAmount/oliWrapperList[0].oli.TotalPrice); 
	          oppLvlSch.scheduleItem.Invoice_Description__c = bw.scheduleItem.Invoice_Description__c;
	          oppLvlSch.isDeleted = false;
	          OppLvlSch.OppLevelindex = orederno ;  
	          oppLvlSchWrapper.add(oppLvlSch);
	          orederno ++;
        	}
        }
        
    }
    Public boolean issaved{get;set;}
    public void saveOppLevelSchedules(){
        
        //TODO: clean this up
         issaved  = true;
        SavePoint sp = Database.setSavePoint();
        try {
            //first delete all schedules and then add the modified ones 
            markAllSchedulesForDeletion();
            
            //recalculate all schedules
            for(OppLevelSchedulesWrapper oppLvlSch : oppLvlSchWrapper ) {
                if(!oppLvlSch.getDeleted()){
                    for(OpportunityLineItemWrapper oliWrapper : oliWrapperList ) {     
                                              
                        if(oppLvlSch.scheduleItem.Billing_Amount__c * (oliWrapper.oli.TotalPrice/zrepAmount)<0){
                             ApexPages.Message dupeMsg = new ApexPages.Message(ApexPages.Severity.ERROR,ERR_NEGATIVE_AMOUNT);                 
                                                ApexPages.addMessage(dupeMsg);
                                                isSaveSuccessful = false;
                                                 return;

                        }
                        if(oppLvlSch.scheduleItem.Billing_Amount__c * (oliWrapper.oli.TotalPrice/zrepAmount)==0){
                             ApexPages.Message dupeMsg = new ApexPages.Message(ApexPages.Severity.ERROR,ERR_ZEROAMOUNT);                 
                                                ApexPages.addMessage(dupeMsg);
                                                isSaveSuccessful = false;
                                                 return;

                        }
                        else{
                            oliWrapper.addBilingSchedule( oppLvlSch.scheduleItem.Billing_Date__c , 
                                                      oppLvlSch.scheduleItem.Billing_Amount__c * (oliWrapper.oli.TotalPrice/zrepAmount) , 
                                                      oppLvlSch.scheduleItem.Invoice_Description__c);
                        }
                    }
                }
            }
            saveSchedules();
        }catch(Exception ex) {
            //roll back the transcation
            database.rollback(sp);
            isSaveSuccessful = false;
        }
    }
    
    // ======================= saveSchedules method ======================= 
    public void saveSchedules(){
     //currentBnf.Is_Opp_Level_Bill_Schedule__c = (billingLevel == OPP_LEVEL)?(true):(false); 
    //==========================validations begin ===============================
        // Validation for Billing date 
        for(OpportunityLineItemWrapper oliWrapper : oliWrapperList ) {            
            for(BillingScheduleWrapper bsw : oliWrapper.schedules){
                if( !bsw.getDeleted() ) {
                    Date D1 = bsw.scheduleItem.Billing_Date__c; 
                    Integer Dateferquency = 0;
                    for(BillingScheduleWrapper bsw1 : oliWrapper.schedules) {
                        if( !bsw.getDeleted() ) {
                            if(D1 ==  bsw1.scheduleItem.Billing_date__c && Dateferquency <= 1  ){
                                Dateferquency ++;
                                  
                            }                  
                        }                    
                    }                     
                }                    
            }
        }
        grandTotal = 0.0;
        Boolean BillingScheduleError = false;
        //check that the total of line item does not exceed the schedules total     
       for(OpportunityLineItemWrapper oliWrapper : oliWrapperList )
        {
            decimal TotalAmt = 0.0;         
            for(BillingScheduleWrapper bsw : oliWrapper.schedules) 
            {
                if( !bsw.getDeleted() ) {                                          
                     if (bsw.scheduleItem.Billing_Date__c == null && bsw.scheduleItem.Billing_Amount__c != null)
                     {
                   	     bsw.scheduleItem.Billing_Date__c.addError('Please enter a valid billing date');
                   		 BillingScheduleError = true;
                     }
                     if (bsw.scheduleItem.Billing_Date__c != null && bsw.scheduleItem.Billing_Amount__c == null)
                     {
                   	     bsw.scheduleItem.Billing_Amount__c.addError('Please enter a valid billing amount');
                   		 BillingScheduleError = true;
                     }
                     //  If user has removed date and amount, consider this to be the same as a deletion
                     if (bsw.scheduleItem.Billing_Date__c == null && bsw.scheduleItem.Billing_Amount__c == null)
                     {
                     	 bsw.setDeleted();
                         if (bsw.scheduleItem.id != null){
                     	 	deletedSchedules.add(bsw.scheduleItem);   
                         }
                     }                     
                     if(bsw.scheduleItem.Billing_Amount__c<0)
                     {
                        bsw.scheduleItem.Billing_Amount__c.addError(ERR_COMPLEVEL_NEGATIVE_AMOUNT);
                        isSaveSuccessful  = false;                        
                    }
                    /*if(bsw.scheduleItem.Billing_Amount__c==0)
                    {
                        bsw.scheduleItem.Billing_Amount__c.addError(ERR_COMPLEVEL_ZEROAMOUNT);
                        isSaveSuccessful  = false;
                    }*/
                    else if (bsw.scheduleItem.Billing_Amount__c != null && !bsw.getDeleted())
                    { 
                        TotalAmt += bsw.scheduleItem.Billing_Amount__c;                        
                    }                  
                }               
            }          
            
            //system.assert(false, 'TotalAmt = ' + TotalAmt + ', oliWrapper.oli.TotalPrice = ' + oliWrapper.oli.TotalPrice.setscale(2));
            grandTotal += TotalAmt;   
            //  Check whether a revised BNF is being submitted, in which case the revised price must be equal to the billing schedule
            Decimal ValidationPrice =0;
            String RevisedBnf = '';
            if(oliWrapper.oli.Revised_Price__c == null)
            {
                ValidationPrice = oliWrapper.oli.TotalPrice;
            }
            else
            {
                ValidationPrice = oliWrapper.oli.Revised_Price__c;
                RevisedBnf = 'revised';
            }
            if(billingLevel == OLI_LEVEL){
            if( TotalAmt.setscale(2) != ValidationPrice.setscale(2)) {
                //show the message to the user
                isSaveSuccessful = false; 
                String msgStr = 'Total scheduled billing amount of ' + temp_obj.CurrencyIsoCode + ' ';                                 
                msgStr += TotalAmt+' for product' +' \"'+ oliWrapper.oli.PricebookEntry.Product2.Name+'\" '+' must equal '+ RevisedBnf +' sales price of ' + temp_obj.CurrencyIsoCode + ' ' + ValidationPrice;
                for (BillingScheduleWrapper bsw : oliWrapper.schedules)
                {
					bsw.scheduleItem.Billing_Amount__c.addError(msgStr);
                }
                return;
            }
            if (BillingScheduleError)
            {
            	isSaveSuccessful = false;  
            	ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error while saving schedules: Invalid billing date/amount');                                       
                //add error on page
                ApexPages.addMessage(errMsg );
                return;
            }
            
            }
             
        }
        
        // validation on total Amount st grand Level 
        if(billingLevel == OPP_LEVEL){
            if(grandTotal > ZrepAmount){  
                    isSaveSuccessful = false; 
                    String msgStr = 'Total scheduled amount '+grandTotal.setScale(2)+' is greater than total opportunity amount '+ZrepAmount;                                                   
                    ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error while saving schedules: ' + msgStr );                        
                    //add error on page
                    ApexPages.addMessage(errMsg );
                    return ;
            }
        }
        //==========================validations End===============================
        List<OpportunityLineItem> oliList = new List<OpportunityLineItem> ();
        bsList = new List<Billing_Schedule__c> ();      
      
        for(OpportunityLineItemWrapper oliWrapper : oliWrapperList){             
            bsList.add(oliWrapper.bilingschduel); 
        }
        try{             
            upsert bsList;
        } catch (Exception ex) {
            isSaveSuccessful = false; 
            ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.ERROR,ERR_SAVING + ex.getMessage());                        
            //add error on page
            ApexPages.addMessage(errMsg );
            return ;
        }       
          
        insertBSiList = new List<Billing_Schedule_Item__c> ();
        List<Billing_Schedule_Item__c> delBSiList = new List<Billing_Schedule_Item__c> ();        
        for(OpportunityLineItemWrapper oliWrapper : oliWrapperList ) {           
            for(BillingScheduleWrapper bsw : oliWrapper.schedules) {
                bsw.scheduleItem.CurrencyIsoCode = oliWrapper.oli.CurrencyIsoCode;
                if( bsw.getDeleted() ) {
                    if( (bsw.scheduleItem.id != null) && (bsw.scheduleItem.Billing_Schedule__c != null) ){
                         delBSiList.add(bsw.scheduleItem);
                    }
                } else {
                    if(bsw.scheduleItem.Billing_Schedule__c != null){
                            insertBSiList.add(bsw.scheduleItem);
                            
                    }
                    if(bsw.scheduleItem.Billing_Schedule__c == null) {                          
                        bsw.scheduleItem.Billing_Schedule__c = oliWrapper.bilingschduel.id;
                        insertBSiList.add(bsw.scheduleItem);
                    }                    
                }                 
            } 
        }
        
        //add all schedules marked for deletion        
        delBSiList.addAll(deletedSchedules);        
        if(delBSiList.size() > 0){
            try{
                delete delBSiList;
                //if deleted successfully, reinitialize
                deletedSchedules = new Set<Billing_Schedule_Item__c> ();
            } catch(Exception ex){
                isSaveSuccessful = false;                 
                ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.ERROR,ERR_DELETING + ex.getMessage());                        
                //add error on page
                ApexPages.addMessage(errMsg );
                return ;
            }
        }
        if(insertBSiList.size() > 0){
            try{
                upsert insertBSiList;
            } catch(Exception ex) {
                isSaveSuccessful = false;               
                ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.ERROR,ERR_UPDATING + ex.getMessage());                        
                //add error on page
                ApexPages.addMessage(errMsg );
                return ;
            }
        }
                
        //update the opportunity to indicate that the schedules have been setup at line item level
        try{             


            update oliList;// update opp                                   
        } catch(Exception ex) {
            isSaveSuccessful = false; 
            ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.ERROR,ERR_UPDATING + ex.getMessage());                        
            //add error on page
            ApexPages.addMessage(errMsg );
            return ;
        }     
                
    }

    public PageReference SaveScheduleListNClose(){
        try{ 
            isSaveSuccessful = true;
            saveSchedules();  
        }catch (Exception ex){
            isSaveSuccessful = false; 
        }
        return null;
    }
    
    //while calling from opp level
    public PageReference SaveOppLvlScheduleListNClose(){    
        try{ 
            isSaveSuccessful = true;
            saveOppLevelSchedules(); 
           
        } catch (Exception ex) {
            isSaveSuccessful = false;
        }
        return null;
    }
   // Public Id selectedOLIId1{get;set;}
    public Id selectedOLIId {get; set;}
    public Integer selectedIdx {get; set;}    
    public  set<Billing_Schedule_Item__c> deletedSchedules = new Set<Billing_Schedule_Item__c> ();
         
    public void deleteScheduleOppLevel(){
        for(OppLevelSchedulesWrapper OLW : oppLvlSchWrapper ){
            if(OLW.OppLevelindex == selectedOpLevel) {
            OLW.setdeleted();
            }
        }
        List<OppLevelSchedulesWrapper> neWoppLvlSchWrapper = new List<OppLevelSchedulesWrapper >();
        Integer newOrder = 1;
        for(OppLevelSchedulesWrapper OLW : oppLvlSchWrapper ){    
            if(  OLW.getdeleted()!= True){
               OLW.OppLevelindex = newOrder; 
               neWoppLvlSchWrapper .add(OLW);
               newOrder++;
            }
        }
        oppLvlSchWrapper = neWoppLvlSchWrapper ; 
    }
        
    public void deleteSchedule(){
        for(OpportunityLineItemWrapper oliWrapper : oliWrapperList ) {           
           if(oliWrapper.oli.id == selectedOLIId) {
               for(BillingScheduleWrapper bw : oliWrapper.schedules){
                   if(bw.idx == selectedIdx) {
                       bw.setDeleted();                       
                       if(bw.scheduleItem.id == null){
                           return;
                       }
                       else {
                           deletedSchedules.add(bw.scheduleItem);
                           bw.SetDeleted();
                        }   
                    }
                }
            }
        }
    }
    
    //mark all existing schedules to be deleted for recalculations
    private void markAllSchedulesForDeletion(){        
        for(OpportunityLineItemWrapper oliWrapper : oliWrapperList ){            
            for(BillingScheduleWrapper bw : oliWrapper.schedules){
                if (bw.scheduleItem.id != null ){
                    deletedSchedules.add(bw.scheduleItem);                    
                }
                bw.SetDeleted();
            }
        }
    }
            
    public class OpportunityLineItemWrapper {
        Public Id selectedOLIIdforgettingDate {get;set;}  
        Public Billing_schedule__c bilingschduel{get;set;}
        public List<BillingScheduleWrapper> schedules {
            get {
                if(schedules == null) {
                    return new List<BillingScheduleWrapper>();                
                } else {
                    List<BillingScheduleWrapper> sch = new List<BillingScheduleWrapper>();
                    for(BillingScheduleWrapper sw : schedules) {
                        if(!sw.getDeleted()) {
                            sch.add(sw);    
                        }
                    }
                    return sch;
                }
            } 
            set {            
                if(value != null ){
                    if(schedules == null) {
                        schedules = new List<BillingScheduleWrapper>();                
                    }
                    for(BillingScheduleWrapper sw : value) {
                        schedules.add(sw);    
                    }
                }
            }
        }
        public OpportunityLineItem oli {get; set;} 
        
        public OpportunityLineItemWrapper(OpportunityLineItem oli1, Billing_Schedule__c bs, List<BillingScheduleWrapper> schedules1 ){
            oli = oli1;      
            bilingschduel = (bs != null)? bs:new Billing_schedule__c();
            bilingschduel.CurrencyIsoCode = oli.CurrencyIsoCode;
           /* if(bilingschduel.bnfId__c == null)
                    bilingschduel.bnfId__c = bnfId ;*/
            if(bilingschduel.oliId__c == null) {
                bilingschduel.oliId__c = oli1.id;
            }
        }      
       
        //Date LastDate;
        public void addBilingSchedule(){
             addBilingSchedule(system.today(), 0.00, '');
        }
        
        public Date startDate{get;set;}
        public Date endDate{get;set;}
        public String startDateStr{get;set;}//{get{return startDate.format();}set;}
        public String endDateStr{get;set;}//{get{return endDate.format();}set;}
        public void setHeaderStartEndDate(Date sDate, Date eDate){
            startDate = sDate;
            endDate = eDate;
            if(sDate != null){
            	startDateStr = sDate.format();
            }
            if(eDate != null){
            	endDateStr = eDate.format();
            }
        }
        public void addBilingSchedule(Date dt, decimal amt, String invoiceTxt){
            Billing_Schedule_Item__c bsItem = new Billing_Schedule_Item__c();
            bsItem.Billing_Date__c = dt;
            bsItem.Billing_Amount__c = Amt;
            bsItem.Invoice_Description__c = invoiceTxt;
            bsItem.CurrencyIsoCode = oli.CurrencyIsoCode;
            Integer idx = schedules.size();
            List<BillingScheduleWrapper> sList = new List<BillingScheduleWrapper> () ;
            sList.add(new BillingScheduleWrapper (bsItem, idx));
            this.schedules = sList; 
        }
        
        public void addBilingSchedule(Billing_Schedule_Item__c bsI){            
            Integer idx = schedules.size();
            List<BillingScheduleWrapper> sList = new List<BillingScheduleWrapper> () ;
            sList.add(new BillingScheduleWrapper (bsI, idx));
            this.schedules = sList; 
        }
    }
    
    public class BillingScheduleWrapper {
        Public Billing_Schedule_Item__c scheduleItem {get;set;}
        Public Boolean isDeleted {get;set;}
        Public Integer idx{get; set;}
        
        
        Public BillingScheduleWrapper(Billing_Schedule_Item__c inscheduleItem, Integer inIdx) {
            scheduleItem = inscheduleItem;
            idx = inIdx;
            isDeleted = false;
            
        }
        
        Public void SetDeleted(){
            isDeleted = true;  
            
        }
        
        public Boolean getDeleted(){
            return isDeleted ;
        }
    } 
    
    public class OppLevelSchedulesWrapper {
        Public Billing_Schedule_Item__c scheduleItem {get;set;}
        Public Boolean isDeleted {get;set;} 
        Public Integer OppLevelindex{get; set;} 
        Public OppLevelSchedulesWrapper(){
            isDeleted = false;
        }
        Public void SetDeleted(){
            isDeleted = true;              
        }        
        public Boolean getDeleted(){
            return isDeleted ;
        }
    }
          
    public void Init() {    
        String localBNFID;
        String RevenueAnalyst_ID;
        sObject objBNF;     
        List<ProcessInstanceWorkitem> PIW_List = new List<ProcessInstanceWorkitem>();
        User CurrentUser = [select Id,Profile.Name from User where Id = :userInfo.getUserId()];
        PreventEdit = false;
        if(ApexPages.CurrentPage().getParameters().get('bnfid') != null && ApexPages.CurrentPage().getParameters().get('bnfid')!='')
            localBNFID=ApexPages.CurrentPage().getParameters().get('bnfid');
        else
            localBNFID=ApexPages.CurrentPage().getParameters().get('mibnf_comp_id');         
        
        list<BNF2__c> submittedBnfList = new list<BNF2__c>();
        list<MI_BNF_LineItem__c> submittedMIBNFList = new list<MI_BNF_LineItem__c>();       
                
        if(localBNFID == null) {
            submittedBnfList = [select Id, BNF_Status__c, Revenue_Analyst__r.user__c from BNF2__c where Opportunity__c =:ApexPages.CurrentPage().getParameters().get('oppId') limit 1];   
            if(submittedBnfList.size() == 0) {
                submittedMIBNFList = [SELECT MIBNF_Component__c,Opportunity_Line_Itemid__c FROM MI_BNF_LineItem__c where MIBNF_Component__r.Opportunity__c =:ApexPages.CurrentPage().getParameters().get('oppId') and Opportunity_Line_Itemid__c =:ApexPages.CurrentPage().getParameters().get('id') limit 1];
            }
            
            if(submittedBnfList.size() > 0) {
                PIW_List = [select Id, ProcessInstance.Id, ProcessInstance.TargetObjectId, ActorId from ProcessInstanceWorkitem  where ProcessInstance.Status
                    = 'Pending' and ProcessInstance.TargetObjectId = :submittedBnfList[0].id];
                objBNF= new BNF2__c();
                List<BNF2__c> bnfComps = new List<BNF2__c>([select id,Revenue_Analyst_del__c, BNF_Status__c from BNF2__c where id =: submittedBnfList[0].id]);
                if(bnfComps.size()>0){
                    objBNF=bnfComps[0];
                }              

            } else if(submittedMIBNFList.size() > 0) {
                PIW_List = [select Id, ProcessInstance.Id, ProcessInstance.TargetObjectId, ActorId from ProcessInstanceWorkitem  where ProcessInstance.Status
                    = 'Pending' and ProcessInstance.TargetObjectId = :submittedMIBNFList[0].id];         
                objBNF= new MIBNF_Component__c();
                List<MIBNF_Component__c> mibnfComp = new List<MIBNF_Component__c>([select id,Revenue_Analyst__c, Comp_Revenue_Analyst_user__c, BNF_Status__c from MIBNF_Component__c where id =: submittedMIBNFList[0].id]);
                if(mibnfComp.size()>0){
                    objBNF=mibnfComp[0];
                }
                            
            }
        } else {
            PIW_List = [select Id, ProcessInstance.Id, ProcessInstance.TargetObjectId, ActorId from ProcessInstanceWorkitem  where ProcessInstance.Status
            = 'Pending' and ProcessInstance.TargetObjectId = :localBNFID];
        
            if(ApexPages.CurrentPage().getParameters().get('bnfid')!=null && ApexPages.CurrentPage().getParameters().get('bnfid')!='')
            {
                objBNF= new BNF2__c();
                objBNF=[select id,Revenue_Analyst_del__c,BNF_Status__c from BNF2__c where id =: ApexPages.CurrentPage().getParameters().get('bnfid')];
            }
            else if(ApexPages.CurrentPage().getParameters().get('mibnf_comp_id') !=null && ApexPages.CurrentPage().getParameters().get('mibnf_comp_id') != '')
            {
                objBNF= new MIBNF_Component__c();
                objBNF=[select id,Revenue_Analyst__c, Comp_Revenue_Analyst_user__c, BNF_Status__c from MIBNF_Component__c where id =: ApexPages.CurrentPage().getParameters().get('mibnf_comp_id')];
            }           
        }
        //Updated By:-Ekta ,Date:-18th March,2015 , Details:- Add Null check (Issue-06553)
        if(objBNF != Null && String.valueof(objBNF.getSObjectType())=='BNF2__c')
        {
           RevenueAnalyst_ID=string.valueof(objBNF.get('Revenue_Analyst_del__c'));
        }
        //Updated By:-Ekta ,Date:-18th March,2015 , Details:- Add Null check (Issue-06553)
        else if(objBNF != Null && String.valueof(objBNF.getSObjectType())=='MIBNF_Component__c')
        {
            RevenueAnalyst_ID=String.valueof(objBNF.get('Comp_Revenue_Analyst_user__c'));
        }       
        
        //system.assert(false, 'RevenueAnalyst_ID = ' + RevenueAnalyst_ID + 'PIW_List = ' + PIW_List);
        
        if (PIW_List.size() > 0)
        {
            
            if (CurrentUser.Profile.Name.toUpperCase().contains('SYSTEM ADMINISTRATOR') || CurrentUser.Id == PIW_List[0].ActorId) {
                //  Allow sys admins or the user to whom the BNF is currently assigned to edit
            }
            //  Else if the BNF is somewhere else within the approval process
            else {
                this.PreventEdit = true;
            }             
        }  
        //return PreventEdit;           
    }    
}