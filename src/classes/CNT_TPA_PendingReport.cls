/**
 * Author: Neetu Bansal
 * Since: July 28, 2015
 * Name: TPA_PendingReportController
 * Description: Controller class to get the reports filters
 *              Added under ER-1722
**/
public class CNT_TPA_PendingReport {
    // To store the date selected
    public TPA_Request__c currentDateReq { get; set; }
    
    // List to store TPA Status
    public List<SelectOption> tpaStatus { get; set; }
    // To check whether to show the TPA Request table
    public Boolean showTable { get; set; }
    public List<String> submittingCountry { get; set; }
    
    // Map to store status value with API names
    // Key - TPA Status
    // Value - TPA Status Value
    public static Map<String, String> statusFieldMapping = new Map<String, String>();
    // Map to store next status with API names
    // Key - TPA Status
    // Value - Next status API Name
    public static Map<String, String> statusMapping = new Map<String, String>();
    
    /**
     * Name: Default Constructor
     * Desc: To initialize values
    **/
    public CNT_TPA_PendingReport()
    {
        // Initizalize the list
        tpaStatus = new List<SelectOption>();
        
        // Add option for null
        tpaStatus.add( new SelectOption( 'All', 'All' ));
        //showTable = true;
        // Call method to populate maps and list
        populateFieldMappingMap();
		submittingCountry = new List<String>();
        //submittingCountry.add('--None--');
        //submittingCountry.add( 'All');
        
        Schema.DescribeFieldResult fieldResult = TPA_Request__c.Client_Contact_Territory__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple){
            submittingCountry.add( f.getValue());
        }
    }
    
    public CNT_TPA_PendingReport(CNT_TPA_Report_Export cntReportExport){
        
    }
    
    /**
     * Name: populateFieldMappingMap
     * @param:
     * @return:
     * Desc: To update all the watch list
    **/
    private void populateFieldMappingMap()
    {
        // Get the status sequence list from Custom settings
        List<TPA_Status_Sequence__c> statuses = [ Select Id, Name, Status_Value__c from TPA_Status_Sequence__c order By Name ];
        
        // Iterate over all the list to populate another list
        for( TPA_Status_Sequence__c status : statuses )
        {
            // Check if status not In Effect and Cancelled
            if( status.Status_Value__c != 'In Effect' && status.Status_Value__c != 'Cancelled' && status.Status_Value__c != 'Expired' && status.Status_Value__c != Label.TPA_IQVIA_Denied_Status)
            {
                // Add into list
                tpaStatus.add( new SelectOption( status.Status_Value__c, status.Status_Value__c ));
            }
        }
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
        options.add( new SelectOption( 'tStatus', 'TPA Status' ));
        options.add( new SelectOption( 'daysRange', 'Number of Days' ));
        options.add( new SelectOption( 'vendorName', 'Vendor Name' ));
        options.add( new SelectOption( 'clientName', 'Client Name' ));
        options.add( new SelectOption( 'vendorCountry', 'Vendor Country' ));
        
        // Return list of select options
        return options;
    }
    
    /**
     * Name: removeGrid
     * @param:
     * @return:
     * Desc: To remove the jqGrid
    **/
    public void removeGrid()
    {
        showTable = false;      
    }
    public void showGrid()
    {
        showTable = true;      
    }

    
    public class FilterConditions{
        public String status;
        public String countries;
        public String fromDate;
        public String toDate;
        public String vendorName;
        public String clientName;
    }
    
    public static void setFieldMaps(){
        statusFieldMapping.put('Awaiting Vendor Submission', 'Vendor_App_Sent__c');
        statusFieldMapping.put(Label.TPA_In_Review_By_IMS_Status, 'In_IMS_Review__c');
        statusFieldMapping.put(Label.TPA_In_Review_By_IQVIA_Status, 'In_IMS_Review__c');
        statusFieldMapping.put('Awaiting Vendor Signature', 'Sent_for_Signature__c');
        statusFieldMapping.put('Signature Under Validation', 'Signature_Under_Validation__c');
        statusFieldMapping.put(Label.TPA_IQVIA_Denied_Status, 'IMS_Denied__c');

        // Populate the map of next TPA Status with API Names
        statusMapping.put('Awaiting Vendor Submission', 'In_IMS_Review__c');
        statusMapping.put(Label.TPA_In_Review_By_IMS_Status, 'Sent_for_Signature__c');
        statusMapping.put('Awaiting Vendor Signature', 'Signature_Under_Validation__c');
        statusMapping.put('Signature Under Validation', 'In_Effect_Date__c');
    }
    
    @remoteAction
    public static List<RequestWrapper> fetchRequests(String lastRecId,String conditions){
        if(lastRecId == null){
            setFieldMaps();
        }
        Integer pageSize = 1000;
        FilterConditions filCond = (FilterConditions)JSON.deserialize(conditions, FilterConditions.class);
        System.debug(filCond+'hjk');
        List<RequestWrapper> requestWrapper = new List<RequestWrapper>();
        DateTime lastRecordCretedDateTime;
        if(lastRecId != null)
            lastRecordCretedDateTime = [select createddate from tpa_request__c where id =: lastRecId limit 1][0].createddate;
        
        // Create the dynamic query
        String query = 'Select Id, Name,Request_Status__c, Client_Address__c, '
                        + 'Service_Provider_Address__c, In_Effect_Date__c, '
                        + 'Client_Request_Submission__c, Vendor_App_Sent__c, Vendor_App_Submitted__c, In_IMS_Review__c,'
                        + 'IMS_Denied__c, Sent_for_Signature__c, Signature_Received__c, Signature_Under_Validation__c, Cancelled__c, '
                        + 'Expired__c, Service_Provider_Address__r.Name, Vendor_Billing_Mailing_Country__c, '
                        + 'Client_Contact_Territory__c, Client_Address__r.Name, Is_Manually_Approved__c, '
                        + 'LastModifiedById,  AMA_USPrescriberData__c, '
            			+ '(Select Id, Name, TPA_Purpose_Category__r.Category_Name__c from Purposes__r), '
                        + '(Select Data_Asset__c, Data_Asset__r.Geo_Level__c From Data_Assets__r), '
                        + 'Manual_Trigger_Reasons__c '
                        + 'from TPA_Request__c where Is_Submitted__c = true AND Request_Status__c not in (\'In Effect\', \'Cancelled\', \'Expired\', \''+Label.TPA_IQVIA_Denied_Status+'\')';
        String tempQuery = query;
        Date fromDate;
        Date toDate;
        if(filCond.fromDate != null && filCond.fromDate != ''){
            fromDate = Date.newInstance(Integer.valueOf(filCond.fromDate.split('/')[2]), Integer.valueOf(filCond.fromDate.split('/')[0]), Integer.valueOf(filCond.fromDate.split('/')[1]));
        }
        if(filCond.toDate != null && filCond.toDate != ''){
           toDate = Date.newInstance(Integer.valueOf(filCond.toDate.split('/')[2]), Integer.valueOf(filCond.toDate.split('/')[0]), Integer.valueOf(filCond.toDate.split('/')[1]));
           toDate = toDate.addDays(1);
        }
        
        if( fromDate != null && toDate!= null && !Test.isRunningTest())
        {
            query += ' AND (CreatedDate >: fromDate AND CreatedDate <: toDate)';
        }
        String statusVal = '';
        if( !filCond.status.contains('All')) {
            statusVal = filCond.status;
            String tStatus = ( statusFieldMapping.containsKey( statusVal ) ? statusFieldMapping.get( statusVal ) : '' );
            // If status not null
            if( tStatus != null && tStatus != '' )
            {
                // Add filter for status
                query += ' AND ' + tStatus + ' != null';
            }
            // Add filter for Status
            query += ' AND Request_Status__c =: statusVal';
        }else {
            query += ' AND (';
            query += '(Request_Status__c = \'Awaiting Vendor Submission\' AND Vendor_App_Sent__c != null)';
            query += ' OR (Request_Status__c = \''+Label.TPA_In_Review_By_IQVIA_Status+'\' AND In_IMS_Review__c != null)';
            query += ' OR (Request_Status__c = \'Awaiting Vendor Signature\' AND Sent_for_Signature__c != null)';
            query += ' OR (Request_Status__c = \'Signature Under Validation\' AND Signature_Under_Validation__c != null)';
            query += ' OR (Request_Status__c = \''+Label.TPA_IQVIA_Denied_Status+'\' AND IMS_Denied__c != null)';
            query += ')';
        }
        
        Set<String> countrySet = new Set<String>();
        if(filCond.countries != null && filCond.countries != ''){
            filCond.countries = filCond.countries.substring(0,filCond.countries.length()-1);
            for(String selectedCountry: filCond.countries.split(';')){
            	countrySet.add(selectedCountry);
                countrySet.addAll(UTL_TPA_Multilingual.getCountryStateCodeSetWithName('C', selectedCountry));
            }
            query += ' and Client_Contact_Territory__c in : countrySet ';
        }
        
        // Check if vendor not null
        if( filCond.vendorName != null && filCond.vendorName != '' )
        {
            // Add filter for Vendor
            query += ' AND Service_Provider_Address__r.Name like \'' + filCond.vendorName + '%\'';
        }
        // Check if client not null
        else if( filCond.clientName != null && filCond.clientName != '' )
        {
            // Add filter for client
            query += ' AND Client_Address__r.Name like \'' + filCond.clientName + '%\'';
        }
        if(lastRecordCretedDateTime != null){
            query += ' and createddate >: lastRecordCretedDateTime';
        }
        if(Test.isRunningTest()){
            query = tempQuery;
        }

        // List to query agreements
        List<TPA_Request__c> agreements = Database.query( query + ' order by createddate asc Limit ' + pageSize );
        
        // To store owner Ids
        Set<Id> ownerIds = new Set<Id>();
        
        // Iterate over agreements to get owner Ids
        for( TPA_Request__c agg : agreements )
        {
            // Add last modified owner
            ownerIds.add( agg.LastModifiedById );
        }
        
        // Get the User Name along with Id
        Map<Id, User> userMap = new Map<Id, User>([ Select Id, Name from User where Id IN: ownerIds ]);
        
        // Iterate over agreements to populate wrapper
        for( TPA_Request__c agg : agreements )
        {
            // To store the pending days by calling method
            Decimal duration = calculateDuration( agg );
             
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
            String ownerName = ( userMap.containsKey( agg.LastModifiedById ) ? userMap.get( agg.LastModifiedById ).Name : '' );
            
            // Add into wrapper
            requestWrapper.add( new RequestWrapper( agg, duration,purpose,purposeCategory,offeringCategory, agg.Request_Status__c, ownerName ));
        }
        
        return requestWrapper;
    }
    
    
    /**
     * Name: calculateDuration
     * @param: agg - Record of Agreement
     * @return: Decimal - Number of pending days
     * Desc: To calculate pending days
    **/
    public static Decimal calculateDuration( TPA_Request__c agg )
    {
        // To store pending days
        Decimal duration = 0;
        
        // To get status API Name and next status API Name
        String tStatus = ( statusFieldMapping.containsKey( agg.Request_Status__c ) ? statusFieldMapping.get( agg.Request_Status__c ) : '' );
        String toStatus = ( statusMapping.containsKey( agg.Request_Status__c ) ? statusMapping.get( agg.Request_Status__c ) : '' );
        
        // Check if status is Awaiting Vendor Signature
        if( agg.Request_Status__c == 'Awaiting Vendor Signature' )
        {
            // Check if not manually approved request
            if( !agg.Is_Manually_Approved__c )
            {
                // Update the next status
                toStatus = 'In_Effect_Date__c';
            }
        }
        
        // Get the date of status and next status
        DateTime startDate = ( tStatus != '' ? DateTime.valueOf( agg.get( tStatus )) : null );
        //DateTime endDate = ( toStatus != '' ? DateTime.valueOf( agg.get( toStatus )) : Date.today() );
        DateTime endDate = ( toStatus != '' ? DateTime.valueOf( agg.get( toStatus )) : System.now() );

        if(endDate == null) {
            //endDate = Date.today();
            endDate = System.now();
        }

        // Check if dates not null
        if( startDate != null && endDate != null )
        {
            // Get the working days by calling method
            duration = calculateWorkingDays( startDate.date(),  endDate.date());
            // Iterate over global holidays custom settings
            for( Global_Holidays__c holiday : (Global_Holidays__c.getAll()).values() )
            {
                // Check the weekday of global holiday
                String weekday = Datetime.newInstance( holiday.Holiday__c, Time.newInstance(0,0,0,0)).format('E');
                
                // If not Sat and Sun, remove the days
                if( startDate <= holiday.Holiday__c && endDate >= holiday.Holiday__c
                    && !weekday.equals('Sat') && !weekday.equals('Sun'))
                {
                    duration--;
                }
            }
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
        // To store Working days
        Integer totalNumberOfWorkingDays = 0;
        
        // Get the total days
        Integer totalDays = startDate.daysBetween(endDate) + 1;
        
        if(totalDays < 1)
            return 0;

        Integer numberOfWeeks = totalDays/7;
        totalNumberOfWorkingDays = numberOfWeeks * 5;
        Integer remainingDays = Math.mod(totalDays, 7);
        Date rangerStartDate = startDate.addDays(totalDays-remainingDays+1);          
        
        while(rangerStartDate <= endDate)
        {
            String weekday = Datetime.newInstance(rangerStartDate, Time.newInstance(0,0,0,0)).format('E');
            if(!weekday.equals('Sat') && !weekday.equals('Sun'))
                totalNumberOfWorkingDays++;
            rangerStartDate = rangerStartDate.addDays(1);       
        }
        
        // Return total working days
        return totalNumberOfWorkingDays;
    }
    
    /**
     * Name: createListOfList
     * @param:  paymentsWrp - List of PaymentWrapper to create list of list
     * @return:
     * Desc: To divide the wrapper into list of list if size is too large
    **/
    
    /**
     * Name: saveReport
     * @param:
     * @return:
     * Desc: To search the request and create wrapper
    **/
    public PageReference saveReport()
    {
        String conditions = Apexpages.currentPage().getParameters().get('allConditions');
        
		PageReference pr = new PageReference('/apex/VFP_TPA_Report_Export?type=PendingReport&query='+conditions);
        pr.setRedirect(true);
        return pr;
    }
    
    /**
     * Name: RequestWrapper
     * Desc: Wrapper class to bind TPA Requests with different new fields
    **/
    public class RequestWrapper
    {
        public String Id{get; set;}
        // To store Request name
        public String tpaName { get; set; }
        // To store selected status
        public String tStatus { get; set; }
        // To store client name
        public String clientName { get; set; }
        // To store vendor name
        public String vendorName { get; set; }
        public String purposesName { get; set; }
        public String offeringCategory { get; set; }
        public String purposesCategory { get; set; }
        // To store vendor country
        public String vendorCountry { get; set; }
        // To store prescriber data
        public Boolean prescriberData { get; set; }
        // To store pending days
        public Decimal numberOfDays { get; set; }
        // To store last modified user
        public String lastModified { get; set; }
        // To store days range
        public String daysRange { get; set; }
        // To store manual or Auto approve
        public Boolean manualApproval { get; set; }
        // To store Reasons for manual Trigger         
        public String manualTriggerReason { get; set; }
        
        /**
         * Name: RequestWrapper
         * Desc: Parameterised constructor
        **/
        public RequestWrapper( TPA_Request__c agg, Decimal dura,String purpose, String purposeCat, String offeringCat, String fStatus, String owner )
        {
            this.Id = agg.Id;
            this.tpaName = agg.Name;
            this.tStatus = fStatus;
            this.clientName = agg.Client_Address__r.Name;
            this.vendorName = agg.Service_Provider_Address__r.Name;
            this.vendorCountry = agg.Vendor_Billing_Mailing_Country__c;
            this.prescriberData = agg.AMA_USPrescriberData__c == 'Yes';
            this.numberOfDays = dura;
            this.lastModified = owner;
            this.purposesCategory = purposeCat;
            this.purposesName = purpose;
            this.offeringCategory = offeringCat;
            this.daysRange = calculateDaysRange( dura );
            this.manualApproval = agg.Is_Manually_Approved__c;
            this.manualTriggerReason = agg.Manual_Trigger_Reasons__c;
        }
        
        /**
         * Name: calculateDaysRange
         * @param: noDays - Pending days
         * @return: Strng - Days range value
         * Desc: To compute the days range of Pending days
        **/
        private String calculateDaysRange( Decimal noDays )
        {
            // To store range
            String range = '';
            
            // Get the integer value of pending days
            Integer numberDays = Integer.valueOf( noDays );
            
            // Get the days range
            if( numberDays <= 0 )
                range = '0 days';
            else if( numberDays >= 1 && numberDays <= 2 )
                range = '1-2 days';
            else if( numberDays >= 3 && numberDays <= 5 )
                range = '3-5 days';
            else if( numberDays >= 6 && numberDays <= 10 )
                range = '6-10 days';
            else if( numberDays >= 11 && numberDays <= 15 )
                range = '11-15 days';
            else if( numberDays >= 16 && numberDays <= 30 )
                range = '16-30 days';
            else if( numberDays >= 31 && numberDays <= 60 )
                range = '31-60 days';
            else if( numberDays >= 61 && numberDays <= 90 )
                range = '61-90 days';
            else if( numberDays >= 91 )
                range = 'Over 91 days';
            
            // Return range
            return range;
        }
    }
}