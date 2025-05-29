/**
 * Author: Neetu Bansal
 * Since: July 21, 2015
 * Name: TPA_TATReportController
 * Description: Controller class to get the reports filters
 *              Added under ER-1722
**/
public class CNT_TPA_TATReport {
    // To store from date selected
    public static TPA_Request__c fromDateReq { get; set; }
    // To store to date selected
    public static TPA_Request__c toDateReq { get; set; }
    // List to store from TPA Status
    public List<SelectOption> fromStatus { get; set; }
    // List to store to TPA Status
    public List<SelectOption> toStatus { get; set; }
    // To store selected from status
    public static String fromStatusValue { get; set; }
    // To store selected to status
    public static String toStatusValue { get; set; }
    // To store vendor name
    public static String vendorName { get; set; }
    // To store client name
    public static String clientName { get; set; }
    // List to store selected countries
    public static List<String> submittingCountries { get; set; }
    // To check whether to show the TPA Request table
    public static Boolean showTable { get; set; }
    public date fromDateTest { get; set; }
    // To store the json value of request
    transient public static String jsonData { get; set; }
    
    // Map to from status and list of to status
    // Key - From TPA Status
    // Value - List of to TPA Status
    private Map<String, List<String>> sequenceNumberWithStatusMap = new Map<String, List<String>>();
    // Map to store status value with API names
    // Key - TPA Status
    // Value - TPA Status API Name
    private static Map<String, String> toStatusFieldMapping = new Map<String, String>();

    // List of TPA Request selected wrapper
    transient private static List<RequestWrapper> requestWrapper;
    
    /**
     * Name: Default Constructor
     * Desc: To initialize values
    **/
    public CNT_TPA_TATReport()
    {
        fromDateReq = new TPA_Request__c();
        toDateReq = new TPA_Request__c();
        fromStatus = new List<SelectOption>();
        
        // Add option for null
        fromStatus.add( new SelectOption( '', '--None--' ));
        
        submittingCountries = new List<String>();
        
        Schema.DescribeFieldResult fieldResult = TPA_Request__c.Client_Contact_Territory__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple){
            submittingCountries.add( f.getValue());
        }
        // Call methods to populate maps
        populateSequenceMap();
        populateFieldMappingMap();
        
    }
    
    public CNT_TPA_TATReport(CNT_TPA_Report_Export cntReportExport){}
    
    /**
     * Name: populateSequenceMap
     * @param:
     * @return:
     * Desc: To populate from status list and create map for to status
    **/
    private void populateSequenceMap()
    {
        // Get the status sequence list from Custom settings
        List<TPA_Status_Sequence__c> tpaStatus = TPA_Status_Sequence__c.getAll().values();
        // To store to status list
        List<String> statusList = new List<String>();
        
        // Iterate over all the list to populate another list
        for( TPA_Status_Sequence__c status : tpaStatus )
        {
            // Add into list and from status list
            statusList.add( status.Status_Value__c );
            fromStatus.add( new SelectOption( status.Status_Value__c, status.Status_Value__c ));
        }
        
        // Iterate over all the status
        for( TPA_Status_Sequence__c status : tpaStatus )
        {
            // Remove the first element
            statusList.remove(0);
            
            // Create copy of list and add all the status
            List<String> statusCopy = new List<String>();
            statusCopy.addAll( statusList );
            
            // Check if status not equal expired, cancelled and IMS denied
            if( status.Status_Value__c == 'Expired' || status.Status_Value__c == 'Cancelled' || status.Status_Value__c == Label.TPA_IQVIA_Denied_Status )
            {
                // Add the same value
                sequenceNumberWithStatusMap.put( status.Status_Value__c, new List<String>{status.Status_Value__c} );
            }
            else
            {
                // Put the list for status in map
                sequenceNumberWithStatusMap.put( status.Status_Value__c, statusCopy );
            }
        }
    }

    /**
     * Name: populateFieldMappingMap
     * @param:
     * @return:
     * Desc: To populate map of status with API Name
    **/
    private static void populateFieldMappingMap()
    {
        // Add values
        toStatusFieldMapping.put('Awaiting Vendor Submission', 'Client_Request_Submission__c');
        toStatusFieldMapping.put(Label.TPA_In_Review_By_IQVIA_Status, 'In_IMS_Review__c');
        toStatusFieldMapping.put('Awaiting Vendor Signature', 'Sent_for_Signature__c');
        toStatusFieldMapping.put('Signature Under Validation', 'Signature_Under_Validation__c');
        toStatusFieldMapping.put('In Effect', 'In_Effect_Date__c');
        toStatusFieldMapping.put('Expired', 'Expired_Date__c');
        toStatusFieldMapping.put('Cancelled', 'Cancelled__c');
        toStatusFieldMapping.put(Label.TPA_IQVIA_Denied_Status, 'IMS_Denied__c');
    }

    /**
     * Name: getGroupingOptions
     * @param:
     * @return: List<SelectOption> - return the list of grouping parameters
     * Desc: To get the grouping parameters
    **/
    public List<SelectOption> getGroupingOptions()
    {
        // List of select options to store grouping options
        List<SelectOption> options = new List<SelectOption>();

        // Add default option in the select option list
        options.add( new SelectOption( 'submittimgCountry', 'Client Country' ));
        options.add( new SelectOption( 'toStatus', 'Status' ));
        options.add( new SelectOption( 'vendorName', 'Vendor Name' ));
        options.add( new SelectOption( 'clientName', 'Client Name' ));

        // Return list of select options
        return options;
    }

    /**
     * Name: populateToStatus
     * @param:
     * @return:
     * Desc: To populate To status list
    **/
    public void populateToStatus()
    {
        // Initialize the list and add default value
        toStatus = new List<SelectOption>();
        toStatus.add( new SelectOption( '', '--None--' ));

        // Check if selected value not null and map contains the value
        if( fromStatusValue != null && fromStatusValue != ''
            && sequenceNumberWithStatusMap.containsKey( fromStatusValue ))
        {
            // Iterate over list
            for( String str : sequenceNumberWithStatusMap.get( fromStatusValue ))
            {
                // Add into list
                toStatus.add( new SelectOption( str, str ));
            }
        }
    }

    /**
    /**
     * Name: searchRequest
     * @param:
     * @return:
     * Desc: To search the request and create wrapper
    **/
    @remoteAction
    public static ReturnDataWaraper searchRequest(String lastRecId,String searchData){
        ReturnDataWaraper retDataWrapObj = new ReturnDataWaraper();
        String lastRecordId;
        SearchData receivedValues = (SearchData)JSON.deserialize(searchData, SearchData.class);
        datetime lastRecordCretedDateTime;
        if(lastRecId != null){
            lastRecordCretedDateTime = [Select CreatedDate from TPA_Request__c where Id = :lastRecId][0].CreatedDate;
        }
        // Intitlize the list
        requestWrapper = new List<RequestWrapper>();
        populateFieldMappingMap();
        // Create the dynamic query
        String query = 'Select Id, Name, Client_Address__c, '
                        + 'Service_Provider_Address__c, Request_Status__c, '
                        + 'Client_Request_Submission__c, Vendor_App_Sent__c, Vendor_App_Submitted__c, In_IMS_Review__c, In_Effect_Date__c, '
                        + 'IMS_Denied__c, Sent_for_Signature__c, Signature_Received__c, Signature_Under_Validation__c, Cancelled__c, '
                        + 'Expired_Date__c, Service_Provider_Address__r.Name, Is_Manually_Approved__c, '
                        + 'Client_Contact_Territory__c, Client_Address__r.Name, '
                        + 'LastModifiedById, AMA_USPrescriberData__c, LastModifiedBy.Name,'
                        + 'Manual_Trigger_Reasons__c, '
                        + '(Select Id, Name, TPA_Purpose_Category__r.Category_Name__c from Purposes__r), '
                        + '(Select Data_Asset__c, Data_Asset__r.Geo_Level__c From Data_Assets__r) '
                        + 'from TPA_Request__c where Is_Submitted__c = true';

        // Get the from and to date
        List<String> dateVals = new List<String>();
        if(receivedValues.fromDate != null){
            dateVals = receivedValues.fromDate.split('/');
        }
        Date fromDate = Test.isRunningTest()? Date.valueOf(receivedValues.fromDate): Date.newInstance(Integer.valueOf(dateVals[2]),Integer.valueOf(dateVals[0]),Integer.valueOf(dateVals[1]));
        if(receivedValues.toDate != null){
            dateVals = receivedValues.toDate.split('/');
        }
        Date toDate = Test.isRunningTest()? Date.valueOf(receivedValues.toDate).addDays(1): Date.newInstance(Integer.valueOf(dateVals[2]),Integer.valueOf(dateVals[0]),Integer.valueOf(dateVals[1])).addDays(1);
        
        System.debug('fromDate ----------> ' + fromDate + ' toDate ----------------> ' + toDate);
        
        if(TPA_Settings__c.getOrgDefaults().Exclude_Test_Data__c){
            query += ' and (NOT Service_Provider_Address__r.Name like \'Test\\_%\') and (NOT Client_Address__r.Name like \'Test\\_%\') ';
        }
        // Add filter for date
        query += ' AND ( CreatedDate >= :fromDate AND CreatedDate < :toDate )';
        // Get the selected to status API Name from map
        System.debug('receivedValues.toStatus ---------> ' + receivedValues);
        String toStatus = ( toStatusFieldMapping.containsKey( receivedValues.toStatus ) ? toStatusFieldMapping.get( receivedValues.toStatus ) : '' );
        
        // If status not null
        if( toStatus != null && toStatus != '' )
        {
            // Add filter for status
            query += ' AND ' + toStatus + ' != null';
        }

        // Set to store the countires
        Set<String> countrySet = new Set<String>();
        if(receivedValues.submittingCountry != null && receivedValues.submittingCountry != ''){
            receivedValues.submittingCountry = receivedValues.submittingCountry.substring(0,receivedValues.submittingCountry.length()-1);
            for(String selectedCountry: receivedValues.submittingCountry.split(';')){
                countrySet.add(selectedCountry);
                countrySet.addAll(UTL_TPA_Multilingual.getCountryStateCodeSetWithName('C', selectedCountry));
            }
            query += ' and Client_Contact_Territory__c in : countrySet ';
        }

        // Check if vendor not null
        if( receivedValues.vendorName != null && receivedValues.vendorName != '' )
        {
            // Add filter for Vendor
            query += ' AND Service_Provider_Address__r.Name like \'' + receivedValues.vendorName + '%\'';
        }
        // Check if client not null
        else if( receivedValues.clientName != null && receivedValues.clientName != '' )
        {
            // Add filter for client
            query += ' AND Client_Address__r.Name like \'' + receivedValues.clientName + '%\'';
        }
        
        if(lastRecordCretedDateTime != null){
            query += ' AND CreatedDate > :lastRecordCretedDateTime';
        }
        System.debug('query ----------------------> ' + query);
        // List to query agreements
       
        List<TPA_Request__c> agreements = Database.query( query + ' Order By CreatedDate Limit 1000');
        System.debug('agreements ----------------------> ' + agreements);
        if(agreements == null || agreements.size() == 0){
            System.debug('agreements in If ----------------------> ' + agreements);
            retDataWrapObj.resultData = new List<RequestWrapper>();
            retDataWrapObj.noOfTPAReqProcessed = 0;
            retDataWrapObj.lastReqId = '';
            return retDataWrapObj;
        }
        lastRecordId = agreements[agreements.size() -1].Id;
        // To store owner Ids
        Set<Id> ownerIds = new Set<Id>();
        
        // Iterate over agreements to get owner Ids
        for( TPA_Request__c agg : agreements )
        {
            // Add last modified owner
            ownerIds.add( agg.LastModifiedById );
        }
        
        fromStatusValue = receivedValues.fromStatus;
        toStatusValue = receivedValues.toStatus;
        // Iterate over agreements to populate wrapper
        if(agreements != null && agreements.size() > 0){
            
            
            for( TPA_Request__c agg : agreements )
            {
                // To store the pending days by calling method
                Decimal duration = calculateDuration( agg );
                 // To store the uses, uses category and offering categories with comma separated values
                String purpose = '';
                String purposeCategory = '';
                String offeringCategory = '';
                
                // Iterate over purposes to get use and use category
                for( TPA_Purpose__c purp : agg.Purposes__r )
                {
                    // Add use name
                    purpose += purp.Name + ',';
                    
                    // Add the use category
                    if( purp.TPA_Purpose_Category__r.Category_Name__c != null && purp.TPA_Purpose_Category__r.Category_Name__c != ''
                       && purposeCategory.indexOf( purp.TPA_Purpose_Category__r.Category_Name__c ) == -1 )
                        purposeCategory += purp.TPA_Purpose_Category__r.Category_Name__c + ',';
                }
                
                // Iterate over offerings to get offering category
                for( TPA_Data_Asset__c asset : agg.Data_Assets__r )
                {
                    // Add offering category
                    if( asset.Data_Asset__c != null && asset.Data_Asset__r.Geo_Level__c != null && asset.Data_Asset__r.Geo_Level__c != ''
                       && offeringCategory.indexOf( asset.Data_Asset__r.Geo_Level__c ) == -1 )
                        offeringCategory += asset.Data_Asset__r.Geo_Level__c + ',';
                }
                
                // Remove the last comma from use, use category and offering category
                purpose = ( purpose.length() != 0 ? purpose.subString( 0, purpose.length() - 1 ) : purpose );
                purposeCategory = ( purposeCategory.length() != 0 ? purposeCategory.subString( 0, purposeCategory.length() - 1 ) : purposeCategory );
                offeringCategory = ( offeringCategory.length() != 0 ? offeringCategory.subString( 0, offeringCategory.length() - 1 ) : offeringCategory );
                
                // Get the last modified user names from map
                String ownerName = ( agg.LastModifiedBy.Name != null ? agg.LastModifiedBy.Name : '' );
                
                // Add into wrapper
                requestWrapper.add( new RequestWrapper( agg, duration, purpose, purposeCategory, offeringCategory, fromStatusValue, toStatusValue, ownerName ));
            }
        }
        retDataWrapObj.resultData = requestWrapper;
        System.debug('retDataWrapObj.resultData ------> ' + retDataWrapObj.resultData);
        retDataWrapObj.noOfTPAReqProcessed = agreements.size();
        retDataWrapObj.lastReqId = agreements[agreements.size()-1].Id;
        
        // Check if records > 0, set the property to show table on page
        if( requestWrapper.size() > 0 )
            showTable = true;
        
        return retDataWrapObj;
    }
    
    /**
     * Name: calculateDuration
     * @param: agg - Record of Agreement
     * @return: Decimal - Number of pending days
     * Desc: To calculate pending days
    **/
    private static Decimal calculateDuration( TPA_Request__c agg )
    {
        // To store pending days
        Decimal duration = 0;
        
        // To get from status API Name and to status API Name
        String fromStatus = ( toStatusFieldMapping.containsKey( fromStatusValue ) ? toStatusFieldMapping.get( fromStatusValue ) : '' );
        String toStatus = ( toStatusFieldMapping.containsKey( toStatusValue ) ? toStatusFieldMapping.get( toStatusValue ) : '' );
        
        // Get the date of from status and to status
        DateTime startDate = ( fromStatus != '' ? DateTime.valueOf( agg.get( fromStatus )) : null );
        DateTime endDate = ( toStatus != '' ? DateTime.valueOf( agg.get( toStatus )) : null );
        
        // Check if dates not null
        if( startDate != null && endDate != null )
        {
            // Get the working days by calling method
            Integer workingDays = calculateWorkingDays( startDate.date(),  endDate.date() );
            
            // Iterate over global holidays custom settings
            for( Global_Holidays__c holiday : (Global_Holidays__c.getAll()).values() )
            {
                // Check the weekday of global holiday
                String weekday = Datetime.newInstance( holiday.Holiday__c, Time.newInstance(0,0,0,0)).format('E');
                
                // If not Sat and Sun, remove the days
                if( startDate <= holiday.Holiday__c && endDate >= holiday.Holiday__c
                    && !weekday.equals('Sat') && !weekday.equals('Sun') )
                {
                    workingDays--;
                }
            }
            
            // Add into duration
            duration = workingDays;
        }
        
        // Return the pending days
        return duration;
    }
    
    /**
     * Name: calculateWorkingDays
     * @param: startDate - Start date
     *          endDate - End Date
     * @return:
     * Desc: To calculate working days between two dates
    **/
    public static Integer calculateWorkingDays(Date startDate, Date endDate)
    {
        Integer totalNumberOfWorkingDays = 0;
        Integer totalDays = startDate.daysBetween(endDate) + 1;
        
        if(totalDays <= 1)
            return 0;

        Integer numberOfWeeks = totalDays/7;
        totalNumberOfWorkingDays = numberOfWeeks * 5;
        Date rangerStartDate = startDate.addDays(numberOfWeeks * 7);          
        
        while(rangerStartDate <= endDate)
        {
            String weekday = Datetime.newInstance(rangerStartDate, Time.newInstance(0,0,0,0)).format('E');
            if(!weekday.equals('Sat') && !weekday.equals('Sun'))
                totalNumberOfWorkingDays++;
            rangerStartDate = rangerStartDate.addDays(1);       
        }
        
        return totalNumberOfWorkingDays - 1;
    }
    
        
    /**
* Name: RequestWrapper
* Desc: Wrapper class to bind TPA Requests with different new fields
**/
    public class RequestWrapper
    {
        // To store suration between two status
        public Decimal duration { get; set; }
         // To store uses name
        public String purposesName { get; set; }
        // To store uses category
        public String purposesCategory { get; set; }
        // To store offering category
        public String offeringCategory { get; set; }
        // To store Request name
        public String tpaName { get; set; }
        // To store tpa request country
        public String submittimgCountry { get; set; }
        // To store client name
        public String clientName { get; set; }
        // To store vendor name
        public String vendorName { get; set; }
        // To store prescriber data
        public Boolean prescriberData { get; set; }
        // To store last modified user
        public String lastModified { get; set; }
        // To store selected from status
        public String fromStatus { get; set; }
        // To store selected to status
        public String toStatus { get; set; }
        // To store manual or Auto approve
        public Boolean manualApproval { get; set; }
        // To store Reasons for manual Trigger
        public String manualTriggerReason { get; set; }
        /**
         * Name: RequestWrapper
         * Desc: Parameterised constructor
        **/
        public RequestWrapper( TPA_Request__c agg, Decimal dura, String purpose, String purposeCat, String offeringCat,
                              String fStatus, String tStatus, String owner )
        {
            this.duration = dura;
            this.purposesName = purpose;
            this.purposesCategory = purposeCat;
            this.offeringCategory = offeringCat;
            this.tpaName = agg.Name;
            this.clientName = agg.Client_Address__r.Name;
            this.submittimgCountry = agg.Client_Contact_Territory__c;
            this.vendorName = agg.Service_Provider_Address__r.Name;
            this.prescriberData = agg.AMA_USPrescriberData__c == 'Yes';
            this.lastModified = owner;
            this.fromStatus = fStatus;
            this.toStatus = tStatus;
            this.manualApproval = agg.Is_Manually_Approved__c;
            this.manualTriggerReason = agg.Manual_Trigger_Reasons__c!= null? agg.Manual_Trigger_Reasons__c: '';
        }
    }
    
    public Class SearchData{
        String fromDate;
        String toDate;
        String fromStatus;
        String toStatus;
        String submittingCountry;
        String vendorName;
        String clientName;
    }
    
    public Class ReturnDataWaraper{
        List<RequestWrapper> resultData;
        Integer noOfTPAReqProcessed;
        String lastReqId;
    }

    /*
        Call Export From here 
    */

    public PageReference saveReport()
    {       
        String conditions = Apexpages.currentPage().getParameters().get('allConditions');
		PageReference pr = new PageReference('/apex/VFP_TPA_Report_Export?type=TATReport&query='+conditions);
        pr.setRedirect(true);
        return pr;
    }
}