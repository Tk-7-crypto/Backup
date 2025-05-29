global class CNT_TPA_ReportingServices {
    public boolean isUserHasReportAccess{get; set;}
    public string reportRequested{get; set;}
    public String searchDet {get;set;}
    public String completedKeyword {
        get{
            return UTL_TPA.TPA_COMPLETED_KEYWORD;
        } 
        set; 
    } 
    public Boolean showTestReqs{get;set;}

    public CNT_TPA_ReportingServices() {
        showTestReqs = ApexPages.currentPage().getParameters().get('showTestRequests') == null ? false : ApexPages.currentPage().getParameters().get('showTestRequests').equalsIgnoreCase('true');
        reportRequested = ApexPages.currentPage().getParameters().get('c__report');
        String currentPageName = ApexPages.currentPage().getUrl().split('/apex/')[1];
        system.debug(currentPageName + ':::' + currentPageName.indexOf('VFP_TPA_VendorOfferingLicenses'));
        if(reportRequested != null && reportRequested.length() > 0 && currentPageName.indexOf('VFP_TPA_VendorOfferingLicenses') == -1 && currentPageName.indexOf('VFP_TPA_Generate_TPSA_Report') == -1) {
            initializeValues();
        }
    }
    
    public PageReference redirectVolToExport(){
        String dates = Apexpages.currentPage().getParameters().get('volDates');
        String fromDate = (DateTime.valueOf(dates.split(';')[0])).formatGMT('yyyy-MM-dd\'T\'hh:mm:ss.SSSZ');
        String toDate = (DateTime.ValueOf(dates.split(';')[1])).formatGMT('yyyy-MM-dd\'T\'hh:mm:ss.SSSZ');
        String query;
        if(!showTestReqs){
        	query = 'SELECT id, Name, Client_Full_Name__c, Client_Address__c, Service_Provider_Address__c, Service_Provider_Address__r.Name, In_Effect_Date__c, (SELECT Id,Secondary_Asset_Name__c, BU__c, TPA_Data_Asset__c FROM TPA_Tertiary_Data_Assets__r), (SELECT Id,Asset_Name__c, BU__c FROM Data_Assets__r) FROM TPA_Request__c WHERE Is_Submitted__c = true and In_Effect_Date__c >= ' + fromDate + ' and In_Effect_Date__c <= ' + toDate + ' and Request_Status__c = \'In Effect\' and (not Client_Full_Name__c like \'TEST_%\') and (not Service_Provider_Address__r.Name like \'TEST_%\') ';
        }
        else{ 
            query = 'SELECT id, Name, Client_Full_Name__c, Client_Address__c, Service_Provider_Address__c, Service_Provider_Address__r.Name, In_Effect_Date__c, (SELECT Id,Secondary_Asset_Name__c, BU__c, TPA_Data_Asset__c FROM TPA_Tertiary_Data_Assets__r), (SELECT Id,Asset_Name__c, BU__c FROM Data_Assets__r) FROM TPA_Request__c WHERE Is_Submitted__c = true and In_Effect_Date__c >= ' + fromDate + ' and In_Effect_Date__c <= ' + toDate + ' and Request_Status__c = \'In Effect\' and ( (Client_Full_Name__c like \'TEST_%\') or (Service_Provider_Address__r.Name like \'TEST_%\')) ';
        }
        PageReference pr = new PageReference('/apex/VFP_TPA_Report_Export');
        pr.getParameters().put('type','VOL');
        pr.getParameters().put('query',query);
        pr.setRedirect(true);
        return pr;
    }
    
    public PageReference redirectToExport(){
        searchDet = Apexpages.currentPage().getParameters().get('searchFil');
        PageReference pr = new PageReference('/apex/VFP_TPA_Report_Export?type='+reportRequested+'&query='+getFullQuery());
        pr.setRedirect(true);
        return pr;
    }
    
    public String getFullQuery(){
        if(searchDet == null){
            System.debug('invalid');
            return '';
        }
        String query = '';
        if(reportRequested == 'ITPR'){
        	query = 'SELECT id, Name,ClientContact__r.Name,  Client_Address__r.Name,Client_Billing_Address__c, TPA_Assigned_TP_Processor__c,TPA_Assigned_TP_Processor__r.Name, Internal_Pending_Status__c,Secondary_Client_Contact_Territory__c, createddate, Service_Provider_Address__c, Service_Provider_Address__r.Name, Vendor_Company_Name__c,Service_Provider_Billing_Address__c, Service_Provider_Contact_f__c, Vendor_Contact_Email_Client__c, Authorized_Signer_Full_Name__c, Authorized_Signer_Email__c, Request_Status__c, Client_Request_Submission__c, Vendor_App_Submitted__c, In_IMS_Review__c, Sent_for_Signature__c, Signature_Received__c, Cancelled__c, Expired_Date__c, IMS_Denied__c, Signature_Under_Validation__c, TPA_Approved_Awaiting_AMA_Approval__c, In_Effect_Date__c, Data_Access_End_Date__c, Manual_Trigger_Reasons__c, TP_Processor_Name__c, TPA_Doc_Link__c, Client_Contact_Territory__c, Agreement_Effective_Date__c,Vendor_e_mail__c FROM TPA_Request__c WHERE Is_Submitted__c = true';
        }
        else{
            query = 'SELECT id, Name, Request_Status__c, Service_Provider_Billing_Address__c,Secondary_Client_Contact_Territory__c,createddate, Client_Contact_Territory__c, Data_Access_End_Date__c, Data_Access_Start_Date__c,Service_Provider_Address__c, Service_Provider_Address__r.Name, Vendor_Company_Name__c, Service_Provider_Contact_f__c, Vendor_e_mail__c, Vendor_Contact_Email_Client__c, ClientContact__r.Name,  Client_Address__r.Name FROM TPA_Request__c WHERE Is_Submitted__c = true ' ;
        }
        
        FilterWrapper searchFil = (FilterWrapper)JSON.deserialize(searchDet, FilterWrapper.class);
        if(searchFil.status != null && searchFil.status != ''){
            query += ' and Request_Status__c = \'' + searchFil.status + '\'';
        }
        if(searchFil.startDate != '' && searchFil.startDate != null){
        	query += ' and createddate >= ' + getDateTimeValForQuery(searchFil.startDate) ;
        }
        if(searchFil.endDate != '' && searchFil.endDate != null){
        	query += ' and createddate < ' + getDateTimeValForQuery(searchFil.endDate) ;
        }
        if(searchFil.reqType == 'Bulk'){
        	query += ' and is_Bulk_TPA_Request__c = true '; 
        }
        if(searchFil.reqType == 'Normal'){
        	query += ' and is_Bulk_TPA_Request__c = false '; 
        }

        if(searchFil.requestingCountry != null ){
        	Set<String> countries = new Set<String>( searchFil.requestingCountry.split(';') );
        	Set<String> countrySet = new Set<String>();
            String countryCode;
            map<string,string> mapCountryCodeWithName = new map<string,string>();
            for(TPA_Country_Codes__c tpaCountryCode: [Select id,Name,Country_Possible_Codes__c from TPA_Country_Codes__c where Code_Type__c ='C']) {
            	mapCountryCodeWithName.put(tpaCountryCode.Name.toLowerCase(), tpaCountryCode.Country_Possible_Codes__c.toLowerCase());
           	}
            String countryyy = '(';
            for(String countryName: countries){
            	if(SRV_TPA_AMAAgreementDetail.mapCountryCodeName.containsKey(countryName.toLowerCase())){
                	countryCode = SRV_TPA_AMAAgreementDetail.mapCountryCodeName.get(countryName.toLowerCase());
                    system.debug('countryCode' + countryCode);
                    system.debug('countrySet' + mapCountryCodeWithName.get(countryCode.toLowerCase()));
                    countrySet.addAll(mapCountryCodeWithName.get(countryCode.toLowerCase()).split(';'));
                    countrySet.add(countryCode);
                }
            }
            for(String txt: countrySet){
            	countryyy += '\''+txt+'\''+',';   
            }
            countryyy = countryyy.substring(0,countryyy.length()-1);
            countryyy += ')';
            system.debug('countrySet' + countryyy);
            query += ' and Client_Contact_Territory__c in ' + countryyy ;
       	}
        if( searchFil.vendorName != null && searchFil.vendorName != '' )
        {
        	query += ' and Service_Provider_Address__r.Name like \'' + searchFil.vendorName + '%25\'';
       	}
        if( searchFil.clientName != null && searchFil.clientName != '' )
        {
        	query += ' and Client_Address__r.Name like \'' + searchFil.clientName + '%25\'';
       	}
        return query;
    }

    public List<SelectOption> getStatusList(){
        List<TPA_Status_Sequence__c> tpaStatus = TPA_Status_Sequence__c.getAll().values();
        List<SelectOption> statusList = new List<SelectOption>();
        
        statusList.add( new SelectOption( '', '--None--' ));
        for( TPA_Status_Sequence__c status : tpaStatus )
        {
            statusList.add( new SelectOption( status.Status_Value__c, status.Status_Value__c ));
        }
        statusList.add(new SelectOption('Pending Vendor Response on Data Destruction from Prior TPAs','Pending Vendor Response on Data Destruction from Prior TPAs'));
        return statusList;
    }

    public List<SelectOption> getRequestTypeList(){
        List<String> types = 'Normal;Bulk'.split(';');
        List<SelectOption> reqTypeList = new List<SelectOption>();
        
        reqTypeList.add( new SelectOption( '', '--None--' ));
        for( String type : types )
        {
            reqTypeList.add( new SelectOption( type, type ));
        }
        return reqTypeList;
    }

    public List<String> getCountryList()
    {
        List<String> options = new List<String>();

        //options.add('--None--');
        //options.add( new SelectOption( 'All', 'All' ));

        Schema.DescribeFieldResult fieldResult = TPA_Request__c.Client_Contact_Territory__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();

        for( Schema.PicklistEntry f : ple)
        {
            options.add(f.getValue());
        }

        return options;
    }

    public void initializeValues()
    {
        List<PermissionSetAssignment> currUserPermSets = [select PermissionSet.Name from PermissionSetAssignment where Assignee.Id =: userinfo.getuserId() order by PermissionSet.Name];
        isUserHasReportAccess = false;
        for(PermissionSetAssignment permAssObj: currUserPermSets)
        {
            if(reportRequested == 'CDL' && permAssObj.PermissionSet.Name == 'TPA_Reports_and_Services_CDL')
                isUserHasReportAccess = true;
            else if(reportRequested == 'ITPR' && permAssObj.PermissionSet.Name == 'TPA_Reports_and_Services')
                isUserHasReportAccess = true;
        }
        
        if(!isUserHasReportAccess)
        {
            String profileName = [Select Id,Name from Profile where Id=:userinfo.getProfileId()].Name;
            if(profileName == 'System Administrator')
                isUserHasReportAccess = true;
        }
    }    
    @remoteAction
    public static List<TPA_Request__c> loadReport(string repType, integer pageSize,string searchFilter,string lastRecordId)
    {
        List<TPA_Request__c> reqList;
        datetime lastRecordCretedDateTime;

        if(lastRecordId == null && repType == 'CDL')
        {
            User userObj = new User(Id = userinfo.getuserId(), TPA_Client_Report_Acknowledge_Time__c = DateTime.now());
            update userObj;
        }
        
        if(lastRecordId != null)
            lastRecordCretedDateTime = [select createddate from tpa_request__c where id =: lastRecordId limit 1][0].createddate;
        system.debug('lastCreatedDate:::'+lastRecordCretedDateTime);
        String query = '';
        FilterWrapper searchFil = (FilterWrapper)JSON.deserialize(searchFilter, FilterWrapper.class);
        System.debug(searchFil+'--->');
            
        if(repType == 'ITPR')
        {
            if(searchFil.reqType == 'Bulk'){
                query = 'SELECT id, Name,ClientContact__r.Name,  Client_Address__r.Name,Client_Billing_Address__c, TPA_Assigned_TP_Processor__c,TPA_Assigned_TP_Processor__r.Name, Internal_Pending_Status__c,Secondary_Client_Contact_Territory__c, createddate, Service_Provider_Address__c, Service_Provider_Address__r.Name, Vendor_Company_Name__c,Service_Provider_Billing_Address__c, Service_Provider_Contact_f__c, Vendor_Contact_Email_Client__c, Authorized_Signer_Full_Name__c, Authorized_Signer_Email__c, Request_Status__c, Client_Request_Submission__c, Vendor_App_Submitted__c, In_IMS_Review__c, Sent_for_Signature__c, Signature_Received__c, Cancelled__c, Expired_Date__c, IMS_Denied__c, Signature_Under_Validation__c, TPA_Approved_Awaiting_AMA_Approval__c, In_Effect_Date__c, Data_Access_End_Date__c, Manual_Trigger_Reasons__c, TP_Processor_Name__c, TPA_Doc_Link__c, Client_Contact_Territory__c, Agreement_Effective_Date__c,Vendor_e_mail__c FROM TPA_Request__c where Is_Submitted__c = true ';
            }else{
            	query = 'SELECT id, Name,ClientContact__r.Name,  Client_Address__r.Name,Client_Billing_Address__c, TPA_Assigned_TP_Processor__c,TPA_Assigned_TP_Processor__r.Name, Internal_Pending_Status__c,Secondary_Client_Contact_Territory__c, createddate, Service_Provider_Address__c, Service_Provider_Address__r.Name, Vendor_Company_Name__c,Service_Provider_Billing_Address__c, Service_Provider_Contact_f__c, Vendor_Contact_Email_Client__c, Authorized_Signer_Full_Name__c, Authorized_Signer_Email__c, Request_Status__c, Client_Request_Submission__c, Vendor_App_Submitted__c, In_IMS_Review__c, Sent_for_Signature__c, Signature_Received__c, Cancelled__c, Expired_Date__c, IMS_Denied__c, Signature_Under_Validation__c, TPA_Approved_Awaiting_AMA_Approval__c, In_Effect_Date__c, Data_Access_End_Date__c, Manual_Trigger_Reasons__c, TP_Processor_Name__c, TPA_Doc_Link__c, Client_Contact_Territory__c, Agreement_Effective_Date__c,Vendor_e_mail__c, (SELECT Id,Secondary_Asset_Name__c,TPA_Data_Asset__c FROM TPA_Tertiary_Data_Assets__r), (SELECT Id,Asset_Name__c,purpose__c FROM Data_Assets__r), (select id, name, BU__c from Purposes__r) FROM TPA_Request__c where Is_Submitted__c = true ';
            }    
        }
        else if(repType == 'CDL')
        {
            query = 'SELECT id, Name, Request_Status__c, Service_Provider_Billing_Address__c,Secondary_Client_Contact_Territory__c,createddate, Client_Contact_Territory__c, Data_Access_End_Date__c, Data_Access_Start_Date__c,Service_Provider_Address__c, Service_Provider_Address__r.Name, Vendor_Company_Name__c, Service_Provider_Contact_f__c, Vendor_e_mail__c, Vendor_Contact_Email_Client__c, ClientContact__r.Name,  Client_Address__r.Name  FROM TPA_Request__c WHERE Is_Submitted__c = true '   ;
        }    
        
        if(searchFil.status != null && searchFil.status != ''){
        	query += ' and Request_Status__c = \'' + searchFil.status + '\'';
        }
        if(searchFil.startDate != '' && searchFil.startDate != null){
            query += ' and createddate >= ' + getDateTimeVal(searchFil.startDate);
        }
        if(searchFil.endDate != '' && searchFil.endDate != null){
            query += ' and createddate < ' + getDateTimeVal(searchFil.endDate);
        }
        if(searchFil.reqType == 'Bulk'){
            query += ' and is_Bulk_TPA_Request__c = true '; 
        }
        if(searchFil.reqType == 'Normal'){
            query += ' and is_Bulk_TPA_Request__c = false '; 
        }

        if(searchFil.requestingCountry != null ){
        	Set<String> countries = new Set<String>( searchFil.requestingCountry.split(';') );
        	Set<String> countrySet = new Set<String>();
        	String countryCode;
        	map<string,string> mapCountryCodeWithName = new map<string,string>();
            for(TPA_Country_Codes__c tpaCountryCode: [Select id,Name,Country_Possible_Codes__c from TPA_Country_Codes__c where Code_Type__c ='C']) {
            	mapCountryCodeWithName.put(tpaCountryCode.Name.toLowerCase(), tpaCountryCode.Country_Possible_Codes__c.toLowerCase());
            }
            String countryyy = '(';
        	for(String countryName: countries){
                if(Test.isRunningTest()){
                    countryyy += '\''+countryName+'\''+',';
                }
                if(SRV_TPA_AMAAgreementDetail.mapCountryCodeName.containsKey(countryName.toLowerCase())){
                	countryCode = SRV_TPA_AMAAgreementDetail.mapCountryCodeName.get(countryName.toLowerCase());
                	system.debug('countryCode' + countryCode);
                	system.debug('countrySet' + mapCountryCodeWithName.get(countryCode.toLowerCase()));
                	countrySet.addAll(mapCountryCodeWithName.get(countryCode.toLowerCase()).split(';'));
                	countrySet.add(countryCode);
                        
            	}
        	}
			for(String txt: countrySet){
            	countryyy += '\''+txt+'\''+',';   
            }
            countryyy = countryyy.substring(0,countryyy.length()-1);
            countryyy += ')';
        	system.debug('countrySet' + countryyy);
        	query += ' and Client_Contact_Territory__c in ' + countryyy ;
        }
        if( searchFil.vendorName != null && searchFil.vendorName != '' )
    	{
        	query += ' and Service_Provider_Address__r.Name like \'' + searchFil.vendorName + '%\'';
    	}
        if( searchFil.clientName != null && searchFil.clientName != '' )
    	{
        	query += ' and Client_Address__r.Name like \'' + searchFil.clientName + '%\'';
    	}
            
        if(lastRecordCretedDateTime != null){
            query += ' and createddate >: lastRecordCretedDateTime';
        }
            
        reqList = Database.query(query + ' order by createddate asc Limit ' + pageSize);
        
        return reqList;
    }
    
    public String getDateTimeValForQuery(String dt){
        List<String> vals = dt.split('/');
        return ''+vals[2]+'-'+vals[0]+'-'+vals[1]+'T00:00:00.000%2B0000';
    }
    public static String getDateTimeVal(String dt){
        List<String> vals = dt.split('/');
        return ''+vals[2]+'-'+vals[0]+'-'+vals[1]+'T00:00:00.000+0000';
    }
    
    @remoteAction
    public static List<TPA_Request__c> loadVendorLicenseReport(integer pageSize, string lastRecordId, String fromDateString, String toDateString, boolean isShowTestRequests) {
        List<TPA_Request__c> reqList;
        //Integer offset = pageSize * pageNumber;
        datetime lastRecordCretedDateTime;
        DateTime fromDate = DateTime.valueOf(fromDateString);
        DateTime toDate = DateTime.valueOf(toDateString).addDays(1);
        
        if(lastRecordId != null) {
            lastRecordCretedDateTime = [select createddate from tpa_request__c where id =: lastRecordId limit 1][0].createddate;
        }
        system.debug('lastCreatedDate:::'+lastRecordCretedDateTime);
        if(lastRecordCretedDateTime == null) {
            if(isShowTestRequests) {
                reqList = [SELECT id, Name, Client_Full_Name__c, Client_Address__c, Service_Provider_Address__c, Service_Provider_Address__r.Name, In_Effect_Date__c, (SELECT Id,Secondary_Asset_Name__c, BU__c, TPA_Data_Asset__c FROM TPA_Tertiary_Data_Assets__r), (SELECT Id,Asset_Name__c, BU__c FROM Data_Assets__r) FROM TPA_Request__c WHERE Is_Submitted__c = true and In_Effect_Date__c >=: fromDate and In_Effect_Date__c <=: toDate and Request_Status__c = 'In Effect' and ((Client_Full_Name__c like 'TEST_%') or (Service_Provider_Address__r.Name like 'TEST_%')) order by createddate asc Limit :pageSize];
            }
            else {
                reqList = [SELECT id, Name, Client_Full_Name__c, Client_Address__c, Service_Provider_Address__c, Service_Provider_Address__r.Name, In_Effect_Date__c, (SELECT Id,Secondary_Asset_Name__c, BU__c, TPA_Data_Asset__c FROM TPA_Tertiary_Data_Assets__r), (SELECT Id,Asset_Name__c, BU__c FROM Data_Assets__r) FROM TPA_Request__c WHERE Is_Submitted__c = true and In_Effect_Date__c >=: fromDate and In_Effect_Date__c <=: toDate and Request_Status__c = 'In Effect' and (not Client_Full_Name__c like 'TEST_%') and (not Service_Provider_Address__r.Name like 'TEST_%') order by createddate asc Limit :pageSize];
            }
        }
        else {
            if(isShowTestRequests) {
                reqList = [SELECT id, Name, Client_Full_Name__c, Client_Address__c, Service_Provider_Address__c, Service_Provider_Address__r.Name, In_Effect_Date__c, (SELECT Id,Secondary_Asset_Name__c, BU__c, TPA_Data_Asset__c FROM TPA_Tertiary_Data_Assets__r), (SELECT Id,Asset_Name__c, BU__c FROM Data_Assets__r) FROM TPA_Request__c WHERE Is_Submitted__c = true and In_Effect_Date__c >=: fromDate and In_Effect_Date__c <=: toDate and Request_Status__c = 'In Effect' and createddate >: lastRecordCretedDateTime and ((Client_Full_Name__c like 'TEST_%') or (Service_Provider_Address__r.Name like 'TEST_%')) order by createddate asc Limit :pageSize];
            }
            else {
                reqList = [SELECT id, Name, Client_Full_Name__c, Client_Address__c, Service_Provider_Address__c, Service_Provider_Address__r.Name, In_Effect_Date__c, (SELECT Id,Secondary_Asset_Name__c, BU__c, TPA_Data_Asset__c FROM TPA_Tertiary_Data_Assets__r), (SELECT Id,Asset_Name__c, BU__c FROM Data_Assets__r) FROM TPA_Request__c WHERE Is_Submitted__c = true and In_Effect_Date__c >=: fromDate and In_Effect_Date__c <=: toDate and Request_Status__c = 'In Effect' and createddate >: lastRecordCretedDateTime and (not Client_Full_Name__c like 'TEST_%') and (not Service_Provider_Address__r.Name like 'TEST_%') order by createddate asc Limit :pageSize];
            }
        }
        
        return reqList;
    }
    
    @remoteAction
    public static List<TPA_Request__c> loadGenerateTPSAReport(string lastRecordId, string recievedConditions) {
        List<TPA_Request__c> agreementList;
        //Integer offset = pageSize * pageNumber;
        TPSAReportConditions allConditions = (TPSAReportConditions)JSON.deserializeStrict(recievedConditions, TPSAReportConditions.class);

        datetime lastRecordCretedDateTime;
        date fromDate = parseDate(allConditions.fromDate,'/');
        date toDate = parseDate(allConditions.toDate,'/').addDays(1);
        
        system.debug(TPA_Settings__c.getInstance().Show_Test_Request__c);
        Boolean isShowTestRequests = TPA_Settings__c.getInstance().Show_Test_Request__c;
        Integer pageSize = Integer.valueOf(allConditions.pageSize);
        if(lastRecordId != null) {
            lastRecordCretedDateTime = [SELECT createddate FROM TPA_Request__c WHERE id =: lastRecordId limit 1][0].createddate;
        }
        system.debug('####lastCreatedDate: '+lastRecordCretedDateTime);
        system.debug('####isShowTestRequests: '+isShowTestRequests);        
        if(lastRecordCretedDateTime == null) {
            if(isShowTestRequests) {
                agreementList = [SELECT id, Name, Client_Full_Name__c, Client_Address__c, Service_Provider_Address__c, Service_Provider_Address__r.Name, In_Effect_Date__c, Data_Access_Start_Date__c, Data_Access_End_Date__c, IsDeleted, CreatedDate, Signature_Under_Validation__c, (Select Name FROM Attachments WHERE (Name LIKE '%IQVIA Third Party Tech Amendment%' OR Name LIKE '%IQVIA Third Party Tech License Agreement%') AND IsDeleted = false ORDER BY createddate desc) FROM TPA_Request__c WHERE Is_Submitted__c = true AND In_Effect_Date__c >=: fromDate AND In_Effect_Date__c <=: toDate AND Request_Status__c = 'In Effect' AND ((Client_Full_Name__c LIKE 'TEST_%') OR (Service_Provider_Address__r.Name LIKE 'TEST_%')) ORDER BY createddate desc Limit :pageSize];
            }
            else {
                agreementList = [SELECT id, Name, Client_Full_Name__c, Client_Address__c, Service_Provider_Address__c, Service_Provider_Address__r.Name, In_Effect_Date__c, Data_Access_Start_Date__c, Data_Access_End_Date__c, IsDeleted, CreatedDate, Signature_Under_Validation__c, (Select Name FROM Attachments WHERE (Name LIKE '%IQVIA Third Party Tech Amendment%' OR Name LIKE '%IQVIA Third Party Tech License Agreement%') AND IsDeleted = false ORDER BY createddate desc) FROM TPA_Request__c WHERE Is_Submitted__c = true AND In_Effect_Date__c >=: fromDate AND In_Effect_Date__c <=: toDate AND Request_Status__c = 'In Effect' AND (NOT Client_Full_Name__c LIKE 'TEST_%') AND (NOT Service_Provider_Address__r.Name LIKE 'TEST_%') ORDER BY createddate desc Limit :pageSize];
            }
        }
        else {
            system.debug('####inside lastRecordCretedDateTime section');
            if(isShowTestRequests) {
                agreementList = [SELECT id, Name, Client_Full_Name__c, Client_Address__c, Service_Provider_Address__c, Service_Provider_Address__r.Name, In_Effect_Date__c, Data_Access_Start_Date__c, Data_Access_End_Date__c, IsDeleted, CreatedDate, Signature_Under_Validation__c, (Select Name FROM Attachments WHERE (Name LIKE '%IQVIA Third Party Tech Amendment%' OR Name LIKE '%IQVIA Third Party Tech License Agreement%') AND IsDeleted = false ORDER BY createddate desc) FROM TPA_Request__c WHERE Is_Submitted__c = true AND In_Effect_Date__c >=: fromDate AND In_Effect_Date__c <=: toDate AND Request_Status__c = 'In Effect' AND createddate <: lastRecordCretedDateTime AND ((Client_Full_Name__c LIKE 'TEST_%') OR (Service_Provider_Address__r.Name LIKE 'TEST_%')) ORDER BY createddate desc Limit :pageSize];
            }
            else {
                agreementList = [SELECT id, Name, Client_Full_Name__c, Client_Address__c, Service_Provider_Address__c, Service_Provider_Address__r.Name, In_Effect_Date__c, Data_Access_Start_Date__c, Data_Access_End_Date__c, IsDeleted, CreatedDate, Signature_Under_Validation__c, (Select Name FROM Attachments WHERE (Name LIKE '%IQVIA Third Party Tech Amendment%' OR Name LIKE '%IQVIA Third Party Tech License Agreement%') AND IsDeleted = false ORDER BY createddate desc) FROM TPA_Request__c WHERE Is_Submitted__c = true AND In_Effect_Date__c >=: fromDate AND In_Effect_Date__c <=: toDate AND Request_Status__c = 'In Effect' AND createddate <: lastRecordCretedDateTime AND (NOT Client_Full_Name__c LIKE 'TEST_%') AND (NOT Service_Provider_Address__r.Name LIKE 'TEST_%') ORDER BY createddate desc Limit :pageSize];
            }
        }
        system.debug('####agreementList: '+agreementList);
        return agreementList;
    }

    public static Date parseDate(String dateString,String sep){
        dateString = dateString.substring(0, Math.min(10, dateString.length()));
        date parsedDate = Date.newInstance(Integer.valueOf(dateString.split(sep)[2]),Integer.valueOf(dateString.split(sep)[0]),Integer.valueOf(dateString.split(sep)[1]));
        return parsedDate;
    }
    
     public PageReference redirectToExportTPSA(){
        String conditions = Apexpages.currentPage().getParameters().get('filterParams');
        PageReference pr = new PageReference('/apex/VFP_TPA_Report_Export?type=TPSAReport&query='+conditions);
        pr.setRedirect(true);
        return pr;
    }

    global class TPSAReportConditions{
        public String pageSize;
        public String fromDate;
        public String toDate;
    }
    
    public class FilterWrapper{
        String startDate;
        String endDate;
        String status;
        String reqType;
        String requestingCountry;
        String clientName;
        String vendorName;
    }
}