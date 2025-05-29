public class BNF_BillingScheduleController {
    

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

    Public BNF2__c currentBNf ;    

	public Date conStartDate;
	public Date conEndDate;

    Public List<Billing_Schedule__c> bsList;
    Public List<Billing_Schedule_Item__c> insertBSiList; 
    Public String salesOrgCode ;     
    public boolean compLevelappliedalready{get;set;}
    public decimal grandtotal;
    public Boolean PreventEdit {get; set;}
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
    
    private List<OpportunityLineItem> oliList = new List<OpportunityLineItem> ();    
    public List<OpportunityLineItemWrapper> oliWrapperList {get; set;}
    
    //Boolean to indicate if billing schedule is present for any of the opportunityLineItem
    public Boolean isSchedulePresent {get; private set;}
    
    //list to show opportunity Level schedules
    public List<OppLevelSchedulesWrapper> oppLvlSchWrapper {get; set;}
    
    //flag for closing the pop up on successfule saving of details
    public Boolean isSaveSuccessful {get; private set;}
    
    public Boolean showWarning {get;private set;}
    
 	public Boolean isOPPBelowStage3 {get; private set;}    
    
	// ESPSFDCQI-15577
    public String oLIID1{get; set;}
    public Set<String>  OLIId_Set = new Set<String> ();
    public String oppCurrencyIsocode;
    public String[] billingScheduleItemList;
    public String excelJsonData {get; set;} 
    public Attachment newErrorFile;
    public ID attachmentId {get;set;}
    public boolean hasError {get;set;}
    public Boolean uploadButtonClicked {set;get;}
    
    //Issue-05144
    Set<String> bnfStatus = new Set<String>{'Submitted','LO Accepted','RA Accepted','SAP Pending','SAP Contract Pending'};
    public boolean bnfSubmitted {get; set;}
    //  Flag to allow billing schedule validations to be ignored on 1st time that user views the BNF product page
    //  after creating a new BNF
    public boolean ShowBillingScheduleScreen {get; private set;}
    private Boolean hasAccessBNFAll;
    
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
    public BNF_BillingScheduleController (ApexPages.StandardController stdController) {
        //initialization
        PreventEdit = false;
        hasAccessBNFAll = false;
        billingLevel = OLI_LEVEL;
        isSchedulePresent = false;
        billingPattern = NONE;
        isSaveSuccessful = false;
        showWarning = false;       
        isOPPBelowStage3 = false; 
        uploadButtonClicked = false; 
        temp_obj = new Billing_Schedule_Item__c();
        // fetching id of currently BNF from URL
        //  setupbillsched parameter indicates that this a new BNF
        if (ApexPages.CurrentPage().getParameters().get('setupbillsched') != null)
        	ShowBillingScheduleScreen = true;
        else
        	ShowBillingScheduleScreen = false;


        currentBNf = (BNF2__c)stdController.getRecord();        
        currentBnf = [select id,bnf_status__c, Opportunity__c, Contract_Start_Date__c, Contract_End_Date__c,
                      Is_Opp_Level_Bill_Schedule__c, Revenue_Analyst__r.user__c, Addendum__c from BNF2__c where id =: currentBnf.id limit 1];
        //  Opp level bill schedules are not used
        currentBnf.Is_Opp_Level_Bill_Schedule__c = false;                    
        Bnfid  = currentBNf.id;
        opp = [select id, StageName, name, Amount, currencyIsoCode, Contract_Start_Date__c, Contract_End_Date__c,(select id,CurrencyIsoCode,Project_Start_Date__c,Project_End_Date__c,
        TotalPrice, Delivery_Country__c, PricebookEntry.Product2.Name, PricebookEntry.Product2.material_type__c,PricebookEntry.Product2.ProductCode, PricebookEntry.Product2.Item_Category_Group__c, Product_Start_Date__c, Product_End_Date__c,Revised_Price__c, Discount_Amount_Formula__c from OpportunityLineItems )
        from Opportunity where id =: currentBNf.Opportunity__c limit 1];
               
		conStartDate = currentBnf.Contract_Start_Date__c;
		conEndDate = currentBnf.Contract_End_Date__c;
		
        if(opp.StageName == CON_CRM.IDENTIFYING_OPP_STAGE || opp.StageName == CON_CRM.QUALIFYING_OPP_STAGE || opp.StageName == CON_CRM.DEVELOPING_PROP_STAGE) {
        	isOPPBelowStage3 = true;
        }		

        //set default billing schedule pattern for the IMS sales org
        salesOrgCode = ApexPages.CurrentPage().getParameters().get('salesOrg');     
        
        if(salesOrgCode != null && salesOrgCode !='') {
            List<SalesOrg__c> salesOrgList = [SELECT Default_Billing_Pattern__c FROM SalesOrg__c 
                                            where CompanyCode__c =:salesOrgCode limit 1 ];
            if(salesOrgList != null && salesOrgList.size() > 0)
                billingPattern = salesOrgList[0].Default_Billing_Pattern__c;      
         }
      	olilist = opp.OpportunityLineItems;
        zrepAmount = 0.00;
        Set<String> oppLineItemId = new Set<String>();  
        for (OpportunityLineItem oppLineItem : oliList)
        {
            if(oppLineItem.PricebookEntry.Product2.material_type__c =='ZREP' || oppLineItem.PricebookEntry.Product2.Item_Category_Group__c=='ZLIC')
            {
                //  Use revised price if this has been set
                if(oppLineItem.Revised_Price__c != null)
                {
                	zrepAmount += oppLineItem.Revised_Price__c;
                	//  Set sales price = revised price so that the new value gets used for billing pattern 
            		oppLineItem.TotalPrice = oppLineItem.Revised_Price__c;   
            		
                }
                else if(oppLineItem.TotalPrice != null)
                {
                	zrepAmount += oppLineItem.TotalPrice;
                    oppLineItemId.add(oppLineItem.Id);
                }               
            }
        }
        //15577
        OLIId_Set = (Set<String>)JSON.deserialize(JSON.serialize(oppLineItemId), Set<String>.class);
        oLIID1 = String.join(new List<String>(oppLineItemId), ',');
        
        temp_obj.currencyIsoCode = opp.currencyIsoCode;
        temp_obj.Billing_Amount__c = zrepAmount;
        oppCurrencyIsocode = opp.currencyIsoCode;               
        resetSchedules();
       
        if( isSchedulePresent && ( (currentBnf.Is_Opp_Level_Bill_Schedule__c != null) && !(currentBnf.Is_Opp_Level_Bill_Schedule__c))){           
           billingLevel = OLI_LEVEL;
           currentBnf.Is_Opp_Level_Bill_Schedule__c = false;
        } 
       
        L = new List<String>();
        L.add('--');  
        Init();  
        
        //Issue-05144
        if(bnfStatus.contains(currentBnf.BNF_Status__c)) {
                        bnfSubmitted = true;
        }
        this.hasAccessBNFAll = false;
        List<PermissionSetAssignment> permSetAssList = [SELECT Id, PermissionSet.Name, AssigneeId FROM PermissionSetAssignment WHERE AssigneeId = :Userinfo.getUserId() and  PermissionSet.Name = 'Modify_all_privileges_on_BNF'];
        if(permSetAssList.size() > 0) {
            hasAccessBNFAll = true; 
        }
  

    }
    // this Methdod to reset to unsaved data and come back to last saved state    
    public PageReference  crudeReset() {        
        salesOrgCode = ApexPages.CurrentPage().getParameters().get('salesOrg');
        String setupbillingScreen = ApexPages.CurrentPage().getParameters().get('setupbillsched');
        PageReference page = new PageReference('/apex/BNF_AddBillingSchedule?id=' + currentBnf.id + '&salesOrg=' + salesOrgCode +'&setupbillsched='+setupbillingScreen);      
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
        for (OpportunityLineItem oppLineItem : opp.OpportunityLineItems  ){
        if(oppLineItem .TotalPrice != null /*&& oppLineItem .TotalPrice >0*/ && 
                      (oppLineItem.PricebookEntry.Product2.material_type__c =='ZREP' || (oppLineItem.PricebookEntry.Product2.Material_Type__c=='ZPUB' && 
                                        oppLineItem.PricebookEntry.Product2.Item_Category_Group__c=='ZLIC'))){
              OLIIdSet.add(oppLineItem.Id) ;
           }
        }     
        oliWrapperList = new List<OpportunityLineItemWrapper>();
        //map of oli id and billing schedule
        Map<Id, Billing_Schedule__c> billingSchedueMap = new Map<Id, Billing_Schedule__c>();       
        
        List<Billing_Schedule__c> currentBsList = [ select id,oliid__c,CurrencyIsoCode, (Select id, Billing_Amount__c, Billing_Date__c,Invoice_Description__c,
                                                        Billing_Schedule__c from Billing_Schedule_Items__r order by Billing_Date__c ) 
                                                        from Billing_Schedule__c where OLIId__c in : OLIIdSet];
                
        for(Billing_Schedule__c bs : currentBsList) {
            billingSchedueMap.put(bs.oliid__c, bs);
        }
        
        //for(Billing_Schedule__c b : Billing_Schedule__c)
        for(OpportunityLineItem oli : opp.OpportunityLineItems ){
            If(oli.PricebookEntry.Product2.material_type__c == 'ZREP' || (oli.PricebookEntry.Product2.Material_Type__c=='ZPUB' && 
                                        oli.PricebookEntry.Product2.Item_Category_Group__c=='ZLIC')){              
                Billing_Schedule__c bsFromMap = billingSchedueMap.get(oli.id);
                if(bsFromMap != null) {                   
                    //create BillingScheduleWrapper object and add to list here
                    OpportunityLineItemWrapper oliW = new OpportunityLineItemWrapper(oli,bsFromMap, null,currentBnf.Addendum__c); 
                    
                	//  The OpportunityLineItemWrapper constructor will set start & end date according to the line item dates.  If no line item 
                	//  dates are available then we need to use the contract dates.
                	if (oliW.startDate == null || oliW.endDate == null)
                	{
                		oliW.setHeaderStartEndDate(conStartDate, conEndDate); 
                	}              
                  
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
                    OpportunityLineItemWrapper oliW = new OpportunityLineItemWrapper(oli,null, null,currentBnf.Addendum__c);   
                    //  The OpportunityLineItemWrapper constructor will set start & end date according to the line item dates.  If no line item 
                	//  dates are available then we need to use the contract dates.
                	if (oliW.startDate == null || oliW.endDate == null)
                	{
                		oliW.setHeaderStartEndDate(conStartDate, conEndDate); 
                	}                      
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
        compLevelappliedalready = false;
        decimal firstInstallment;
        decimal secondInstallment;
        if(currentBnf.Is_Opp_Level_Bill_Schedule__c == false){
            boolean   temp = (billingLevel == OPP_LEVEL)?(true):(false); 
            if(temp == true)
                compLevelappliedalready = true;           
        }
            
        if(billingPattern == NONE ) {
             ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.ERROR,ERR_BILLINGPLAN_MISSING);                        
             //add error on page
             ApexPages.addMessage(errMsg );
             return;
        } 
        isSchedulePresent = true;        
        markAllSchedulesForDeletion();
        
        date conStartDate = opp.Contract_Start_Date__c;

        //conStartDate = (conStartDate < system.today())? system.today():conStartDate;

        date startDate;
        date endDate;
        
        if(billingPattern == FIFTY_FIFTY){            

            for(OpportunityLineItemWrapper oliWrapper : oliWrapperList ) 
            {
                if (oliWrapper.oli.TotalPrice != 0 || oliWrapper.oli.Discount_Amount_Formula__c != 0)
        		{
	                if(oliWrapper.oli.Project_Start_Date__c != null && oliWrapper.oli.Project_End_Date__c != null){
	                                startDate = oliWrapper.oli.Project_Start_Date__c;
	                                endDate = oliWrapper.oli.Project_End_Date__c;
	                        }else if(oliWrapper.oli.PricebookEntry.Product2.material_type__c == 'ZPUB' && oliWrapper.oli.PricebookEntry.Product2.Item_Category_Group__c == 'ZLIC' && oliWrapper.oli.Product_Start_Date__c != null && oliWrapper.oli.Product_End_Date__c != null){
	                                startDate = oliWrapper.oli.Product_Start_Date__c;
	                                endDate = oliWrapper.oli.Product_End_Date__c;
	                        }else{
	                                startDate = conStartDate;
	                            	endDate = conEndDate;
	
	                        }
	                oliWrapper.setHeaderStartEndDate(startDate, endDate); 
	                firstInstallment = (oliWrapper.oli.TotalPrice/2).divide(1, 2,System.RoundingMode.HALF_UP);    
	                secondInstallment = oliWrapper.oli.TotalPrice - firstInstallment;  	                       
	                oliWrapper.addBilingSchedule( startDate , firstInstallment, '');                
	                oliWrapper.addBilingSchedule( endDate, secondInstallment, '');
        		}
            }
        } else if (billingPattern == FOURTY_SIXTY){            

            for(OpportunityLineItemWrapper oliWrapper : oliWrapperList ) 
            {
                if (oliWrapper.oli.TotalPrice != 0 || oliWrapper.oli.Discount_Amount_Formula__c != 0)
        		{
	                if(oliWrapper.oli.Project_Start_Date__c != null && oliWrapper.oli.Project_End_Date__c != null){
	                                startDate = oliWrapper.oli.Project_Start_Date__c;
	                                endDate = oliWrapper.oli.Project_End_Date__c;
	
	
	
	
	                        }else if(oliWrapper.oli.PricebookEntry.Product2.material_type__c == 'ZPUB' && oliWrapper.oli.PricebookEntry.Product2.Item_Category_Group__c == 'ZLIC' && oliWrapper.oli.Product_Start_Date__c != null && oliWrapper.oli.Product_End_Date__c != null){
	                                startDate = oliWrapper.oli.Product_Start_Date__c;
	                                endDate = oliWrapper.oli.Product_End_Date__c;     
	                        }else{
	                                startDate = conStartDate;
	                            	endDate = conEndDate;
	
	                        }
	                         
	                oliWrapper.setHeaderStartEndDate(startDate, endDate);  
	                firstInstallment = (oliWrapper.oli.TotalPrice* (60.00/100.00)).divide(1, 2,System.RoundingMode.HALF_UP);    
	                secondInstallment = oliWrapper.oli.TotalPrice - firstInstallment;  
	                oliWrapper.addBilingSchedule( startDate , firstInstallment, '');                
	                oliWrapper.addBilingSchedule( endDate, secondInstallment, '');
        		}
          }
        } else if (billingPattern == SIGNATURE_100) 
        {                			
            for(OpportunityLineItemWrapper oliWrapper : oliWrapperList ) 
            { 
                if (oliWrapper.oli.TotalPrice != 0 || oliWrapper.oli.Discount_Amount_Formula__c != 0)
        		{
	                startDate = conStartDate;
	                endDate = conEndDate;
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
	                                startDate = oliWrapper.oli.Project_Start_Date__c;
	                                endDate = oliWrapper.oli.Project_End_Date__c;



	
	                        }else if(oliWrapper.oli.PricebookEntry.Product2.material_type__c == 'ZPUB' && oliWrapper.oli.PricebookEntry.Product2.Item_Category_Group__c == 'ZLIC' && oliWrapper.oli.Product_Start_Date__c != null && oliWrapper.oli.Product_End_Date__c != null){
	                                startDate = oliWrapper.oli.Product_Start_Date__c;
	                                endDate = oliWrapper.oli.Product_End_Date__c;     
	                        }else{
	                                startDate = conStartDate;
	                            	endDate = conEndDate;
	
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
	                        startDate = oliWrapper.oli.Project_Start_Date__c;
	                        endDate = oliWrapper.oli.Project_End_Date__c;
	
	                }else if(oliWrapper.oli.PricebookEntry.Product2.material_type__c == 'ZPUB' && oliWrapper.oli.PricebookEntry.Product2.Item_Category_Group__c == 'ZLIC' && oliWrapper.oli.Product_Start_Date__c != null && oliWrapper.oli.Product_End_Date__c != null){
	                                startDate = oliWrapper.oli.Product_Start_Date__c;
	                                endDate = oliWrapper.oli.Product_End_Date__c;     
	                }else{
	                        startDate = conStartDate;
	                        endDate = conEndDate;
	
	                }
	                Integer monthsBetween = startDate.monthsBetween(endDate);                       
	                    if(monthsBetween < 0) 
	                        monthsBetween *= (-1); 
	                    // updated by Ghanshyam Saini       
	                    if(endDate.day() >= startDate.day()){
	                        if(monthsBetween == 0) 
	                                monthsBetween = 1; 
	                        else    
	                                monthsBetween++;
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
	                        startDate = oliWrapper.oli.Project_Start_Date__c;
	                        endDate = oliWrapper.oli.Project_End_Date__c;
	
	                }else if(oliWrapper.oli.PricebookEntry.Product2.material_type__c == 'ZPUB' && oliWrapper.oli.PricebookEntry.Product2.Item_Category_Group__c == 'ZLIC' && oliWrapper.oli.Product_Start_Date__c != null && oliWrapper.oli.Product_End_Date__c != null){
	                                startDate = oliWrapper.oli.Product_Start_Date__c;
	                                endDate = oliWrapper.oli.Product_End_Date__c;     
	                }else{
	                        startDate = conStartDate;
	                        endDate = conEndDate;
	
	                }  
	                
	                //find months between contract start date and end date            
	                    Integer monthsBetween = startDate.monthsBetween(endDate);
	                    if(monthsBetween < 0) 
	                        monthsBetween *= (-1);
	
	                    
	                    Integer quartesBetween = (monthsBetween/3) +1;
	                    if(quartesBetween < 0) 
	                        quartesBetween *= (-1);
	
	                    
	                    if(quartesBetween == 0) 
	                        quartesBetween  = 1;  
	
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
    public pageReference saveSchedules()
    {     
     currentBnf.Is_Opp_Level_Bill_Schedule__c = (billingLevel == OPP_LEVEL)?(true):(false); 
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
            double TotalAmt = 0.0;         
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
                     	 if (bsw.scheduleItem.id != null)
                     	 	deletedSchedules.add(bsw.scheduleItem);                     	 
                     }                     
                     if(bsw.scheduleItem.Billing_Amount__c<0)
                     {
                        bsw.scheduleItem.Billing_Amount__c.addError(ERR_COMPLEVEL_NEGATIVE_AMOUNT);
                        isSaveSuccessful  = false;
                        return null;
                    }
                    /*if(bsw.scheduleItem.Billing_Amount__c==0)
                    {
                        bsw.scheduleItem.Billing_Amount__c.addError(ERR_COMPLEVEL_ZEROAMOUNT);
                        isSaveSuccessful  = false;
                        return null;
                    }*/
                    else if (bsw.scheduleItem.Billing_Amount__c != null && !bsw.getDeleted())
                    { 
                        TotalAmt += bsw.scheduleItem.Billing_Amount__c;                        
                    }                  
                }               
            }  
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
            grandTotal += TotalAmt;                              
            if(billingLevel == OLI_LEVEL){
            if( TotalAmt != ValidationPrice.setscale(2)) {
                //show the message to the user
                isSaveSuccessful = false;           
                String msgStr = 'Total scheduled billing amount of ' + temp_obj.CurrencyIsoCode + ' ';                                 
                msgStr += TotalAmt+' for product' +' \"'+ oliWrapper.oli.PricebookEntry.Product2.Name+'\" '+' must equal '+ RevisedBnf +' sales price of ' + temp_obj.CurrencyIsoCode + ' ' + ValidationPrice;                        
                for (BillingScheduleWrapper bsw : oliWrapper.schedules)
                {
					bsw.scheduleItem.Billing_Amount__c.addError(msgStr);
                }
                return null;
            }
            if (BillingScheduleError)
            {
            	isSaveSuccessful = false;  
            	ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error while saving schedules: Invalid billing date/amount');                                       
                //add error on page
                ApexPages.addMessage(errMsg );
                return null;
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
                    return  null;
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
            return  null;
        }       
          
        insertBSiList = new List<Billing_Schedule_Item__c> ();
        List<Billing_Schedule_Item__c> delBSiList = new List<Billing_Schedule_Item__c> ();        
        for(OpportunityLineItemWrapper oliWrapper : oliWrapperList ) {           
            for(BillingScheduleWrapper bsw : oliWrapper.schedules) {            	
                bsw.scheduleItem.CurrencyIsoCode = oliWrapper.oli.CurrencyIsoCode;
                if( bsw.getDeleted() ) 
                {
                    if( (bsw.scheduleItem.id != null) && (bsw.scheduleItem.Billing_Schedule__c != null) )
                    {
                    	delBSiList.add(bsw.scheduleItem);
                    }
                } 
                else 
                {
                    if(bsw.scheduleItem.Billing_Schedule__c != null)
                    {
                    	insertBSiList.add(bsw.scheduleItem);                            
                    }
                    if(bsw.scheduleItem.Billing_Schedule__c == null) 
                    {                          
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
                return  null;
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
                return  null;
            }
        }
        if (ShowBillingScheduleScreen)
        {
        	pageReference NextPage = new pageReference('/'+currentBnf.Id);
        	NextPage.setRedirect(true);
        	return NextPage;
        }
        else
        {
        	return null;
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
            if(OLW.OppLevelindex == selectedOpLevel) 
            OLW.setdeleted();
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
                       if(bw.scheduleItem.id == null)
                           return;
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
        
        public OpportunityLineItemWrapper(OpportunityLineItem oli1, Billing_Schedule__c bs, List<BillingScheduleWrapper> schedules1, Boolean RevisedBnf ){
            oli = oli1;      
            bilingschduel = (bs != null)? bs:new Billing_schedule__c();
            bilingschduel.CurrencyIsoCode = oli.CurrencyIsoCode;
            /*if(bilingschduel.bnfId__c == null)
                    bilingschduel.bnfId__c = bnfId ;*/
            if(bilingschduel.oliId__c == null) 
                bilingschduel.oliId__c = oli1.id;              
            //if(oli.budget__c != null)
            //{
	            if(oli.Project_Start_Date__c != null && oli.Project_End_Date__c != null)
	            {
	                startDate = oli.Project_Start_Date__c;
	                endDate = oli.Project_End_Date__c;
	            }
            //}
            else if(oli.PricebookEntry.Product2.material_type__c == 'ZPUB' && oli.PricebookEntry.Product2.Item_Category_Group__c == 'ZLIC' && oli.Product_Start_Date__c != null && oli.Product_End_Date__c != null)
            {
                    startDate = oli.Product_Start_Date__c;
                    endDate = oli.Product_End_Date__c;
            }
            //  If it's a revised BNF we need to use the data period start from the line item as these may have been adjusted for ZREP materials
        	if (RevisedBnf == true)
        	{
        		startDate = oli.Product_Start_Date__c;
        	}
            if (startDate != null && endDate != null)
        		setHeaderStartEndDate(startDate, endDate);
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
            if(sDate != null)
            	startDateStr = sDate.format();
            if(eDate != null)
            	endDateStr = eDate.format();
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
        Public Boolean isError{get;set;}
        Public String errorMsg{get;set;}
        Public Id oliIDForBsli{get;set;} 
        Public String deliveryCountry {get;set;}
        Public Decimal totalPrice {get;set;}
        Public String serialNumber{get;set;}
        Public BillingScheduleWrapper(){
            errorMsg = '';
        }
        
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
        User CurrentUser = [select Id,Profile.Name from User where Id = :userInfo.getUserId()];
                List<ProcessInstanceWorkitem> PIW_List = new List<ProcessInstanceWorkitem>([select Id, ProcessInstance.Id, ProcessInstance.TargetObjectId, ActorId from ProcessInstanceWorkitem  where ProcessInstance.Status = 'Pending' and ProcessInstance.TargetObjectId = :currentBNf.Id]);
        if (PIW_List.size() > 0) {          
            //  If BNF has been submitted, only sys admins or the user to which it has been assigned are able to edit
                        if (CurrentUser.Profile.Name.toUpperCase().contains('SYSTEM ADMINISTRATOR') || CurrentUser.Id == PIW_List[0].ActorId || hasAccessBNFAll) {
                                //  Allow sys admins or the user to whom the BNF is currently assigned to edit
                        }
            //  Else if the BNF is somewhere else within the approval process
            else {
                this.PreventEdit = true;
            }    
        }
        else if (currentBNf.BNF_Status__c == MDM_Defines.BnfStatus_Map.get('SAP_CONTRACT_CONFIRMED') || currentBNf.BNF_Status__c == MDM_Defines.BnfStatus_Map.get('ACCEPTED')) {
            this.PreventEdit = true;
        }  
    }    
    
    public pageReference Cancel()
    {
    	pageReference retUrl = new pageReference('/'+currentBnf.Id);
    	retUrl.setRedirect(true);
    	return returl;
    }
   
   /**
    * Under ESPSFDCQI-16384
	* This method is used download the sample template to upload the billing schedules using CSV file
	* @return PageReference
	*/
   public PageReference getExport() {
        PageReference pr = Page.VFP_CRM_ExportBillingScheduleItems;
        pr.getParameters().put('dataParam', oLIID1);
        pr.setRedirect(False);
        return pr; 
    }
   
    /**
    * Under ESPSFDCQI-16384
	* This method is used to upload the billing schedules using CSV file
	* @return PageReference
	*/
   public PageReference uploadFile(){
        isSchedulePresent = true;
        ApexPages.Message errorMessage;  
        try{
        String[] header = (excelJsonData.substringBefore('\r\n')).split(',');
        String[] rows = (excelJsonData.substringAfter('\r\n')).split('\n');
        // check if there is no data in the uploaded file 
        if(rows.size() == 0 || String.isBlank(rows[0])){
            if(header.size() > 10){
                errorMessage = new ApexPages.Message(ApexPages.severity.ERROR,'Please open and make changes in file once.');
                
            }else if(header.size() == 9 || header.size() == 10){
                errorMessage = new ApexPages.Message(ApexPages.severity.ERROR,'No record found for billing schedule item');
            }
            ApexPages.addMessage(errorMessage);
            return null;
        }
            
        // check if header is incomplete or not in proper format
        String bscurrencyISOCode = 'Billing Amount ('+oppCurrencyIsocode+')'; 
        
        if(header[0] != 'Serial Number'){
            errorMessage = new ApexPages.Message(ApexPages.severity.ERROR,'Header is not in proper format.' + ' 1st column header value should be "Serial Number" but it is ' + header[0]);
            ApexPages.addMessage(errorMessage);
            return null;
        }else if(header[1] != 'OLI Id(Required)'){
            errorMessage = new ApexPages.Message(ApexPages.severity.ERROR,'Header is not in proper format.' + ' 2nd column header value should be "OLI Id(Required)" but it is ' + header[1]);
            ApexPages.addMessage(errorMessage);
            return null;
        }else if(header[2] != 'Product Name (Optional)'){
            errorMessage = new ApexPages.Message(ApexPages.severity.ERROR,'Header is not in proper format.' + ' 3rd column header value should be "Product Name (Optional)" but it is ' + header[2]);
            ApexPages.addMessage(errorMessage);
            return null;
        }else if(header[3] != 'Product Code (Optional)'){
            errorMessage = new ApexPages.Message(ApexPages.severity.ERROR,'Header is not in proper format.' + ' 4th column header value should be "Product Code (Optional)" but it is ' + header[3]);
            ApexPages.addMessage(errorMessage);
            return null;
        }else if(header[4] != 'Delivery Country'){
            errorMessage = new ApexPages.Message(ApexPages.severity.ERROR,'Header is not in proper format.' + ' 5th column header value should be "Delivery Country" but it is ' + header[4]);
            ApexPages.addMessage(errorMessage);
            return null;
        }else if(header[5] != 'Total Price'){
            errorMessage = new ApexPages.Message(ApexPages.severity.ERROR,'Header is not in proper format.' + ' 6th column header value should be "Total Price" but it is ' + header[5]);
            ApexPages.addMessage(errorMessage);
            return null;
        }else if(header[6] != 'Billing Date (mm-dd-yyyy)'){
            errorMessage = new ApexPages.Message(ApexPages.severity.ERROR,'Header is not in proper format.' + ' 7th column header value should be "Billing Date (mm-dd-yyyy)" but it is ' + header[6]);
            ApexPages.addMessage(errorMessage);
            return null;
        }else if(header[7] != bscurrencyISOCode){
            errorMessage = new ApexPages.Message(ApexPages.severity.ERROR,'Header is not in proper format.' + ' 8th column header value should be "' + bscurrencyISOCode + '" but it is ' + header[7]);
            ApexPages.addMessage(errorMessage);
            return null;
        }else if(header[8] != 'Invoice Description'){
            errorMessage = new ApexPages.Message(ApexPages.severity.ERROR,'Header is not in proper format.' + ' 9th column header value should be "Invoice Description" but it is ' + header[8]);
            ApexPages.addMessage(errorMessage);
            return null;
        }  
       
        List<Map<String, String>> jsonData = new List<Map<String, String>>();
        if(rows.size()>0){
            for (String row : rows) {
                List<String> values = new List<String>();
                //values = row.split(',');
                row = row.replaceAll(',,',',null,');
                Pattern pattern = Pattern.compile('(?<=^|,)(\"(?:[^\"]|\"\")*\"|[^,]*)');
				Matcher matcher = pattern.matcher(row);
                while (matcher.find()) {
                    values.add(matcher.group().replaceAll('"', ''));
                } 
                
               Map<String, String> rowMap = new Map<String, String>();
               for (Integer i = 0; i < header.size(); i++) {
                    if(values[i] == null || values[i] == 'null'){
                    rowMap.put(header[i], '');
                    }
                    else{
                        rowMap.put(header[i], values[i]);
                    }
                }
                jsonData.add(rowMap);
            }
        }
    
        String serializeJsonData = JSON.serialize(jsonData);
        List<Object> billingScheduleItemList = (List<Object>)JSON.deserializeUntyped(serializeJsonData);
        List<BillingScheduleWrapper> bsliWrapperList = new List<BillingScheduleWrapper>();
        
        // check for billing schedule item records if it is correct or not and if any field data is missing or blank in the uploaded sheet  
        for(Object obj : billingScheduleItemList){
            Map<String, Object> item = (Map<String, Object>)obj; 
            BillingScheduleWrapper bsli = new BillingScheduleWrapper();
            bsli.scheduleItem = new Billing_Schedule_Item__c();
            if(String.isNotBlank((String)item.get('Serial Number'))){
               bsli.serialNumber = (String)item.get('Serial Number');
            }
            if(String.isNotBlank((String)item.get('OLI Id(Required)'))){
               bsli.oliIDForBsli = (ID)item.get('OLI Id(Required)');
            }else{
                bsli.isError = true;
                bsli.errorMsg += ' OLI ID(Required) is missing. Please make sure to fill OLI ID relevant to product name';
            }
            
            if(String.isNotBlank((String)item.get('Billing Date (mm-dd-yyyy)'))){
                String strDate = (String)item.get('Billing Date (mm-dd-yyyy)'); 
                String convertedDate = strDate.replace('-','/');
               
                List<String> dateVals = new List<String>();
                if(convertedDate.length() > 0){
                    dateVals = convertedDate.split('/');
                }
                Date fromDate = Date.newInstance(Integer.valueOf(dateVals[2]),Integer.valueOf(dateVals[0]),Integer.valueOf(dateVals[1])); 
                bsli.scheduleItem.Billing_Date__c = fromDate;
            }else{
                bsli.isError = true;
                bsli.errorMsg += ' Value of Billing Date is missing.';                
            }
            
            if(String.isNotBlank((String)item.get(bscurrencyISOCode))){
                String amount = ((String)item.get(bscurrencyISOCode)).replaceAll(',','');
                bsli.scheduleItem.Billing_Amount__c =  decimal.valueOf(amount).setScale(2);
            }else{
                bsli.isError = true;
                bsli.errorMsg += ' Value of Billing Amount is missing.';
            }
            
            if(String.isNotBlank((String)item.get('Delivery Country'))){
                bsli.deliveryCountry = (String)item.get('Delivery Country');
            }
            
            if(String.isNotBlank((String)item.get('Total Price'))){
                String totalPrice = ((String)item.get('Total Price')).replaceAll(',','');
                bsli.totalPrice = Decimal.valueOf(totalPrice).setScale(2);
            }
            
            if(String.isNotBlank((String)item.get('Invoice Description'))){
                bsli.scheduleItem.Invoice_Description__c = (String)item.get('Invoice Description');
            }
            
            bsliWrapperList.add(bsli);
        }
        
        List<BillingScheduleWrapper> bsliWrapperListWithError = new List<BillingScheduleWrapper>();
        Map<Id,List<BillingScheduleWrapper>> bsliMapWithOliID = new Map<Id,List<BillingScheduleWrapper>>();
        Map<ID,double> oliIdWithTotalBillingAmount = new Map<Id,double>();
		
        markAllSchedulesForDeletion();
        
        
            //add biling schedules to oli wrapper 
        for(OpportunityLineItemWrapper oliWrapper : oliWrapperList ){
                for(Object obj : billingScheduleItemList){
                    Map<String, Object> item = (Map<String, Object>)obj; 
                    decimal billingAmount;
                    String strDate;   
                    Date billingDate;
                    String invoiceDescription = '';
                    if(String.isNotBlank((String)item.get('Billing Date (mm-dd-yyyy)')) ){
                        strDate = (String)item.get('Billing Date (mm-dd-yyyy)'); 
                        String convertedDate = strDate.replace('-','/');
                        List<String> dateVals = new List<String>();
                        if(convertedDate.length() > 0){
                            dateVals = convertedDate.split('/');
                        }
                        Date fromDate = Date.newInstance(Integer.valueOf(dateVals[2]),Integer.valueOf(dateVals[0]),Integer.valueOf(dateVals[1])); 
                        billingDate = fromDate;
                    }                
                    if(String.isNotBlank((String)item.get(bscurrencyISOCode))){
                        String amount = ((String)item.get(bscurrencyISOCode)).replaceAll(',','');
                        billingAmount =  decimal.valueOf(amount).setScale(2);
                    }
                    
                    if(String.isNotBlank((String)item.get('Invoice Description'))){
                         invoiceDescription = (String)item.get('Invoice Description');}
                    
                    if(String.isNotBlank((String)item.get('OLI Id(Required)')) && String.isNotBlank((String)item.get(bscurrencyISOCode))){
                        if(oliWrapper.oli.Id == (Id)item.get('OLI Id(Required)')){
                            oliWrapper.addBilingSchedule(billingDate, billingAmount, invoiceDescription);
                            ID oliID1 = (Id)item.get('OLI Id(Required)');
                            if(oliIdWithTotalBillingAmount.containsKey(oliID1)){
                                oliIdWithTotalBillingAmount.put(oliID1,oliIdWithTotalBillingAmount.get(oliID1) + billingAmount);
                            } else{
                                oliIdWithTotalBillingAmount.put(oliID1, billingAmount);
                            }
                        }
                        
                    } else if(String.isBlank((String)item.get('OLI Id(Required)'))){
                        errorMessage = new ApexPages.Message(ApexPages.severity.ERROR,'One or more OLI ID is missing in the uploaded file');
                        ApexPages.addMessage(errorMessage); 
                        return null;
                    }
                } 
            }
        
		
            // check for billing amount mismatch 
            for(OpportunityLineItemWrapper oliWrapper : oliWrapperList ){
                Decimal ValidationPrice =0;
                String RevisedBnf = '';
                Double totalBillingAmount = oliIdWithTotalBillingAmount.get(oliWrapper.oli.Id);
                String oliName = oliWrapper.oli.PricebookEntry.Product2.Name;
                if(oliWrapper.oli.Revised_Price__c == null)
                {
                    ValidationPrice = oliWrapper.oli.TotalPrice.setScale(2);
                }
                else
                {
                    ValidationPrice = oliWrapper.oli.Revised_Price__c.setScale(2);
                    RevisedBnf = 'revised';
                }
                
                for(BillingScheduleWrapper bsWrap : bsliWrapperList){
                    if(oliWrapper.oli.ID == bsWrap.oliIDForBsli && oliIdWithTotalBillingAmount.containsKey(oliWrapper.oli.ID)){
                        if(ValidationPrice != totalBillingAmount){
                            bsWrap.isError = true;
                            bsWrap.errorMsg += ' Total scheduled billing amount of '+oppCurrencyIsocode+' '+ totalBillingAmount+' for product "'+oliName+'" must equal sales price of '+oppCurrencyIsocode+' '+ValidationPrice+'.';
                        }
                    }
                }  
            }
			
            for(BillingScheduleWrapper bsWrap : bsliWrapperList){
                if(bsWrap.isError == true){
                    bsliWrapperListWithError.add(bsWrap);
                }
            }
			
            // to generate error file 
        	String headerWithError = '' 
                + '"Serial Number","OLI Id(Required)","Product Name (Optional)","Product Code (Optional)","Delivery Country","Total Price","Billing Date (mm-dd-yyyy)","Billing Amount ('+oppCurrencyIsocode+')'+'","Invoice Description","Error Message"\n';
       		for(OpportunityLineItemWrapper oliWrapper : oliWrapperList){
                for(BillingScheduleWrapper bsWrap : bsliWrapperList){
                    if(bsWrap.oliIDForBsli == oliWrapper.oli.ID ){
                        headerWithError += line(new String[] {
                            format(bsWrap.serialNumber),
                            format(bsWrap.oliIDForBsli),
                                format(oliWrapper.oli.PricebookEntry.Product2.Name),
                                format(oliWrapper.oli.PricebookEntry.Product2.ProductCode),
                                format(oliWrapper.oli.Delivery_Country__c),
                                format(String.valueOf(oliWrapper.oli.TotalPrice.setScale(2))),
                                (bsWrap.scheduleItem.Billing_Date__c != null ? String.valueOf('"'+(bsWrap.scheduleItem.Billing_Date__c).format()+'"') : '""'),
                                (bsWrap.scheduleItem.Billing_Amount__c != null ? String.valueOf('"'+(bsWrap.scheduleItem.Billing_Amount__c.setScale(2)).format()+'"') : '""'),
                                format(bsWrap.scheduleItem.Invoice_Description__c),
                                format(bsWrap.errorMsg)
                                }) + '\n' ; 
                    }
                }
            }
            
       		//create attachment
            Blob CSVBlob;
            if(headerWithError.length() > 160 && bsliWrapperListWithError.size() > 0){
                CSVBlob = Blob.valueOf(headerWithError);
                newErrorFile = new Attachment(Body = CSVBlob,Name = 'BillingScheduleTemplate_Error.csv',parentId = currentBNf.Id);
                insert newErrorFile;
                attachmentId = newErrorFile.Id; 
                hasError = true;
                errorMessage = new ApexPages.Message(ApexPages.severity.ERROR,'Error while uploading file. Please download the error file from given link and refresh the page then upload the file after resolving errors.');
                ApexPages.addMessage(errorMessage);
            }else{
                hasError = false;
            }
        } catch(Exception e){
            errorMessage = new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage());
            ApexPages.addMessage(errorMessage);
        }
        return null;
    }
    
    private String line(String[] cells) {
        return String.join(cells, ',');
    }
    
    //Format the string compatible with CSV
    private String format(String s) {
        return s != null ? '"' + s.trim() + '"' : '""';
    } 
    
}