public class RevisedRevenueScheduleController {

    private ApexPages.StandardController StandardController;
    public OpportunityLineItem OLI{get; private set;}
    public List<OpportunityLineItemSchedule> OLIS_wrapper {get ; set;}
    public List<String> strRevSchedule;
    public OpportunityLineItemSchedule RevisedPrice {get ; private set;}
    public Boolean errorOccured {get ; set;}
    public String RevisedPriceId {get; private set; }
    public String ListPriceId {get; private set; }
    private Integer NumRevSchedules;
    public Boolean OriginalRevSchedules {get ;private set;}
    private List<OpportunityLineItemSchedule> OLIS_List;
    //Update by Suman : 8-march-2017 : ER - 0688
    public List<OpportunityLineItemSchedule> OLIS_wrapper_Copy = new List<OpportunityLineItemSchedule>();
    public Boolean ascending {get;set;}
    public Boolean descending {get;set;}
    public List<OpportunityLineItemSchedule> OLIS_wrapper_clone;
    public String fieldName {get;set;}
    
    //  If an invalid (i.e. incorrectly formatted) date is entered on the VF page, the native validation will show an error 
    //  and the code doesn't enter the Save() function in the controller.  We need to use a Javacript function
    //  to set the SaveCompleted hidden input to false as soon as the user clicks the "Save" button
    //  After a successful Save the ErrorPanel is re-rendered and the hidden input value updated to reflect that a save has occurred.
    //  The "SaveAndClose()" javascript function then evaluates the hidden field to determine whether a native UI validation error has occurred or not   
    public Boolean SaveCompleted {get; set;}
    public String materialType {get; set;}
    public Date UpdatedLineItemStartDate{get; set;}
    public Date UpdatedLineItemEndDate{get; set;}
    //hide the save and Close button from mobile device.
    public Boolean hideSaveCloseButton{get; private set;}  
    
    public RevisedRevenueScheduleController(ApexPages.StandardController controller) 
    {
        errorOccured = false;
        NumRevSchedules = 20;
        StandardController = controller;
        hideSaveCloseButton = true;
        //Commented by Ghanshyam Saini - Issue-07797 - Start
        //RevisedPrice = new OpportunityLineItemSchedule();
        OLI = (OpportunityLineItem)controller.getRecord();
        //Added by Ghanshyam Saini - Issue-07797 - Start
        List<OpportunityLineItemSchedule> tempOLIS_List = [select Id,Description,Quantity, Revenue, ScheduleDate, opportunityLineItemID from OpportunityLineItemSchedule where OpportunityLineItemId = :OLI.Id];
        if(tempOLIS_List != null && tempOLIS_List.size() > 0){
        	RevisedPrice = tempOLIS_List[0].clone(false,true,false,false);
             //Start Updated by Suman : 8-march-2017 : ER - 0688
            OLIS_wrapper_Copy = tempOLIS_List.clone(); //.addAll(OLIS_wrapper);   
            //End
        }else{
        	RevisedPrice = new OpportunityLineItemSchedule();
        }
        //Added by Ghanshyam Saini - Issue-07797 - End
        OLIS_wrapper = new List<OpportunityLineItemSchedule>();
        strRevSchedule = new List<String>();
        RevisedPriceId = System.currentPageReference().getParameters().get('RevisedPriceId');
        ListPriceId = System.currentPageReference().getParameters().get('ListPriceId');
        SaveCompleted = false;
        if(System.currentPageReference().getParameters().get('OriginalRevSchedules') != null && System.currentPageReference().getParameters().get('OriginalRevSchedules') == 'true'){
        	OriginalRevSchedules = true;
        }
        else{
        	OriginalRevSchedules = false;
        }
		OLIS_List = new List<OpportunityLineItemSchedule>();
		
		// For ZLIC materials the start/end date can be set on the "BNF Product Page"
	       
	   if(OLI.PricebookEntry.Product2.Item_Category_Group__c == 'ZLIC') 
	    {
	        if(ApexPages.CurrentPage().getParameters().get('startdate') != null && ApexPages.CurrentPage().getParameters().get('startdate').length() > 0) 
	        {
                if(ApexPages.CurrentPage().getParameters().get('isLWC') == 'true'){
                    UpdatedLineItemEndDate = Date.ValueOf(ApexPages.CurrentPage().getParameters().get('startdate'));
                }else{
                    UpdatedLineItemStartDate = date.parse(ApexPages.CurrentPage().getParameters().get('startdate'));
                }
	        } 
	        else if(OLI.Product_Start_Date__c != null) 
	        {
	        	UpdatedLineItemStartDate = OLI.Product_Start_Date__c;
	        }
	        
	        if(ApexPages.CurrentPage().getParameters().get('enddate') != null && ApexPages.CurrentPage().getParameters().get('enddate').length() > 0) 
	        {
                if(ApexPages.CurrentPage().getParameters().get('isLWC') == 'true'){
                    UpdatedLineItemEndDate = Date.ValueOf(ApexPages.CurrentPage().getParameters().get('enddate'));
                }else{
                    UpdatedLineItemEndDate = date.parse(ApexPages.CurrentPage().getParameters().get('enddate'));
                }
	        } 
	        else if(OLI.Product_End_Date__c != null) 
			{
	    		UpdatedLineItemEndDate = OLI.Product_Start_Date__c;
	    	}
	    }   
	    else if(OLI.PricebookEntry.Product2.material_type__c == 'ZREP') 
	    {	    	
	        // If it's a revised BNF, the start date for ZREP products can be set 
	        if(ApexPages.CurrentPage().getParameters().get('startdate') != null && ApexPages.CurrentPage().getParameters().get('startdate').length() > 0 && OriginalRevSchedules == false) 
	        {
	        	UpdatedLineItemStartDate = date.parse(ApexPages.CurrentPage().getParameters().get('startdate'));
	        } 
	        else if(OLI.Project_Start_Date__c != null)
	        {
	        	UpdatedLineItemStartDate = OLI.Project_Start_Date__c;
	        }
	        
	        if(OLI.Project_End_Date__c != null) 
	        {
				UpdatedLineItemEndDate = OLI.Project_End_Date__c;
	        }  	
	    }   
		//End
		

        if (OLI.Revised_Revenue_Schedule__c != null && OLI.Revised_Revenue_Schedule__c != '' && OriginalRevSchedules == false)
        {         	
        	
            strRevSchedule = OLI.Revised_Revenue_Schedule__c.split('\\|'); 
		 	//  If Revised_Revenue_Schedule__c contains 'x' it indicates that a revised price of zero has been entered
            if (strRevSchedule[0] == 'x'){
		   		strRevSchedule.clear(); 
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
                OLIS_wrapper.add(new OpportunityLineItemSchedule(Revenue=RevenueAmount,ScheduleDate=RevenueDate));             
            }
            OLIS_wrapper.sort();
        }
        else
        {
            OLIS_List = [select Id,Revenue,ScheduleDate from OpportunityLineItemSchedule where OpportunityLineItemId = :OLI.Id order by ScheduleDate asc];
            for (OpportunityLineItemSchedule OLIS:OLIS_List)
            {
                OLIS_wrapper.add(OLIS);
            }            
        }
        if (OriginalRevSchedules == false)
        {
	        for (integer j=0;j<NumRevSchedules-OLIS_wrapper.size();j++)
	        {
	             OLIS_wrapper.add(new OpportunityLineItemSchedule());             
	        }
        }
        
         //for hinding save & close button for mobile device.
        if(UserInfo.getUiThemeDisplayed() == 'Theme4t'){
            hideSaveCloseButton = false;
        }
        
        Recalc();
        OLIS_wrapper_clone = OLIS_wrapper.clone();
        ascending = false;
        descending = true;
    }
    
    public void Save()
    {
        system.debug('Entering save');
        String RevenueSchedule = '';
        errorOccured = false;
        
		//Update by Suman Sharma : 8-march-2017 : ER - 0688 -- start--
		Boolean isValidate = false;
        Map<date,decimal> ScheduleDateOldMap = new  Map<date,decimal>();
        List<OpportunityLineItemSchedule> lineSchedulesnew = new List<OpportunityLineItemSchedule>();
        
        for (OpportunityLineItemSchedule OLIS:OLIS_wrapper_Copy)
        {
            if(OLIS.ScheduleDate < system.today()){
                ScheduleDateOldMap.put(OLIS.ScheduleDate , OLIS.Revenue);
            }
        }
       	
        Profile profile = [select Name from profile where id=:UserInfo.getProfileId()][0]; 
        //System.debug('### OLI : '+OLI); 
        OpportunityLineItem oppOli = [select Id, name, OpportunityId from OpportunityLineItem where id = : OLI.id Limit 1];
        Opportunity opp = [select Id, name, StageName from Opportunity where id = : oppOli.OpportunityId Limit 1];
        if(!profile.Name.tolowercase().contains('system administrator'))  {              
            if(opp.StageName != 'In-Hand' && opp.StageName != '7a. Closed Won' && opp.StageName != '7b. Closed Lost' ){
                isValidate = true;
            } 
        }   
        
       	OpportunityTriggerHaultSetting__c oppTriggHauSett = OpportunityTriggerHaultSetting__c.getOrgDefaults();
        
        for (OpportunityLineItemSchedule OLIS:OLIS_wrapper)
        {
            if(Global_Variables.isclonningOpportunity == false && isValidate == true && Global_Variables.EXCLUDE_SCHEDULE_DATE_VALIDATION_FOR_PA == false && oppTriggHauSett.StopRevenueSchedulePastValidation__c == false){
                if(OLIS.ScheduleDate < system.today()){
                    if(!ScheduleDateOldMap.containsKey(OLIS.ScheduleDate)){
                        OLIS.ScheduleDate.addError('Revenue schedule date "'+(OLIS.ScheduleDate).format()+'" for open opportunities cannot be in the past.');
                        errorOccured = true;
                    }else if(ScheduleDateOldMap.containsKey(OLIS.ScheduleDate) && !(ScheduleDateOldMap.get(OLIS.ScheduleDate) == OLIS.Revenue)) {
                        OLIS.ScheduleDate.addError('Revenue schedule date "'+(OLIS.ScheduleDate).format()+'" for open opportunities cannot be in the past.'); 
                        errorOccured = true;                    
                    } 
                } 
            }            
            //Update by Suman Sharma : 8-march-2017 : ER - 0688 -- End--
            
            if(OLIS.ScheduleDate == null && OLIS.Revenue != null) 
            {           
                OLIS.ScheduleDate.addError('Please enter schedule date');
                errorOccured = true;
            }
            if (OLIS.ScheduleDate != null && OLIS.Revenue == null)
            {
                OLIS.Revenue.addError('Please enter revenue amount');
                errorOccured = true;
            }        
            //  Revenue vs project date validations only apply to ZREP materials    
            if (OLIS.ScheduleDate > UpdatedLineItemEndDate && OLI.PricebookEntry.Product2.Material_Type__c == 'ZREP')
            {
                OLIS.ScheduleDate.addError('Revenue date falls after project end date (' +UpdatedLineItemEndDate.format() + ')');
                errorOccured = true;
            }
            if (OLIS.ScheduleDate < UpdatedLineItemStartDate && OLI.PricebookEntry.Product2.Material_Type__c == 'ZREP')
            {
                OLIS.ScheduleDate.addError('Revenue date falls before project start date (' +UpdatedLineItemStartDate.format() + ')');
                errorOccured = true;
            }
            if (OLIS.ScheduleDate != null && OLIS.Revenue != null)
            {
                RevenueSchedule += String.valueOf(OLIS.ScheduleDate.Year()) + ('0'+String.valueOf(OLIS.ScheduleDate.Month())).right(2) + ('0'+String.valueOf(OLIS.ScheduleDate.Day())).right(2) + ':' + String.valueOf(OLIS.Revenue)+ '|';
            }
        }
        if (!errorOccured)
        {
            if (RevenueSchedule.length() == 0)
            {
            	RevenueSchedule = 'x';
            }
            Recalc();
            //  If the page is being used to edit the actual OpportunityLineItemRevenueSchedules, do an update directly
            if (OriginalRevSchedules == true)
            {
            	update OLIS_List;
                //Update by Suman Sharma : 27-April-2017 : ER - 0688 -- Here when update date schedule then OLI not update and it makes Conflict in Oli Shedule (OLISchedule Jason Data) Update  So we are updating blank OLI
                Update OLI;
            }
            else
            {
	        	OLI.Revised_Revenue_Schedule__c = RevenueSchedule; 
	        	//Added and commented by Ghanshyam : Issue-08341 - Start
	        	//StandardController.save();       	    
        	    try{
        	    	upsert OLI;
        	    }catch(Exception e){
        	    	ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        	    }
        	    //Added by Ghanshyam : Issue-08341 - End
            }   
        }
        SaveCompleted = true;
    }
    
    public pageReference Recalc()
    {
        RevisedPrice.Revenue = 0;
        for (OpportunityLineItemSchedule OLIS:OLIS_wrapper)
        {
            if(OLIS.ScheduleDate == null && OLIS.Revenue != null) 
            {           
                OLIS.ScheduleDate.addError('Please enter schedule date');
            }
            if (OLIS.ScheduleDate != null && OLIS.Revenue == null)
            {
                OLIS.Revenue.addError('Please enter revenue amount');
            }
            if (OLIS.ScheduleDate != null && OLIS.Revenue != null)
            {
                RevisedPrice.Revenue += OLIS.Revenue;
            } 
        }        
        return null;
    }
    
    public pageReference SaveMore()
    {        
     	Save();
        if (!errorOccured)
        {
            for (integer j=0;j<10;j++)
            {
                 OLIS_wrapper.add(new OpportunityLineItemSchedule());             
            }
        }
        return null;
    }
    
    public List<OLISWrapper> olisWrapperLst;
    public void sorting() {
        olisWrapperLst = new List<OLISWrapper>();
        if(fieldName == 'Revenue') {
			for(OpportunityLineItemSchedule olis : OLIS_wrapper_clone){
				olisWrapperLst.add(new OLISWrapper(olis, 'Revenue', descending));
			}
			if(descending) {
				descending = false;
			} else {
				descending = true;
			}
        }
        
        if(fieldName == 'ScheduleDate') {
			for(OpportunityLineItemSchedule olis : OLIS_wrapper_clone){
				olisWrapperLst.add(new OLISWrapper(olis, 'ScheduleDate', ascending));
			}
			if(ascending) {
				ascending = false;
			} else {
				ascending = true;
			}
        }
        
        olisWrapperLst.sort();
        OLIS_wrapper.clear();
        for(OLISWrapper objWrapper : olisWrapperLst){
            OLIS_wrapper.add(objWrapper.olis);
        }
    }
    
    public Class OLISWrapper implements Comparable{
        
        public OpportunityLineItemSchedule olis{get;set;}
        public String fieldName {get;set;}
        public Boolean sortOrder {get;set;}
        public OLISWrapper(OpportunityLineItemSchedule olis, String fieldname, Boolean sortOrder){
            this.olis = olis;
            this.fieldName = fieldName;
            this.sortOrder = sortOrder;
        }
        
        public Integer compareTo(Object objToCompare) {
            OLISWrapper compareToObj = (OLISWrapper)objToCompare;
            Integer returnValue = 0;
            if(fieldName == 'Revenue') {
                if(sortOrder) {
                    if(olis.Revenue == compareToObj.olis.Revenue) {
                        returnValue =  0;
                    } else if(olis.Revenue > compareToObj.olis.Revenue) {
                        returnValue = -1;
                    }
                    else if(olis.Revenue < compareToObj.olis.Revenue) {
                        returnValue = 1;
                    }
                } else {
                    if(olis.Revenue == compareToObj.olis.Revenue) {
                        returnValue = 0;
                    } else if(olis.Revenue > compareToObj.olis.Revenue) {
                        returnValue = 1;
                    }
                    else if(olis.Revenue < compareToObj.olis.Revenue) {
                        returnValue = -1;
                    }
                }
                
            }
            
            if(fieldName == 'ScheduleDate') {
                if(sortOrder) {
                    if(olis.ScheduleDate == compareToObj.olis.ScheduleDate) {
                        returnValue = 0;
                    } else if(olis.ScheduleDate > compareToObj.olis.ScheduleDate) {
                        returnValue = 1;
                    }
                    else if(olis.ScheduleDate < compareToObj.olis.ScheduleDate) {
                        returnValue = -1;
                    }
                } else {
                    if(olis.ScheduleDate == compareToObj.olis.ScheduleDate) {
                        returnValue = 0;
                    } else if(olis.ScheduleDate > compareToObj.olis.ScheduleDate) {
                        returnValue = -1;
                    }
                    else if(olis.ScheduleDate < compareToObj.olis.ScheduleDate) {
                        returnValue = 1;
                    }
                }
                
            }
            return returnValue;
        } 
	}		

}