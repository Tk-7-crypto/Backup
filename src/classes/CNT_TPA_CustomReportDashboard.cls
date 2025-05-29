global class CNT_TPA_CustomReportDashboard {
    public static transient map<string, string> mapCountryCodesWithAllValues { get; set; }
    
    public static string strMapCountryCodesWithAllValues {
        get {
            return JSON.serialize(mapCountryCodesWithAllValues);
        }
    }
    
    static {
        mapCountryCodesWithAllValues = UTL_TPA.mapCountryCodeWithAllPossibleValues;
        system.debug('mapCountryCodesWithAllValues' + mapCountryCodesWithAllValues);
    }
   
    public static Map<String, String> reportDashboardSettingMap{
        get{
            if(reportDashboardSettingMap == null)
            {
                List<TPA_Reports_Dashboards_Setting__c> reportDashboardSettings = [Select name, Setting_Unique_Name__c, Setting_Value__c from TPA_Reports_Dashboards_Setting__c where Setting_Type__c = 'reports'];
                reportDashboardSettingMap = new Map<string, string>();
                for(TPA_Reports_Dashboards_Setting__c repDbSettObj: reportDashboardSettings)
                    reportDashboardSettingMap.put(repDbSettObj.Setting_Unique_Name__c, repDbSettObj.Setting_Value__c);
            }
            return reportDashboardSettingMap;
        }
        set{
            reportDashboardSettingMap = value;
        }
    }

    public static List<TPA_Trending_Reports_Mapping_BU__c> reportMappings{
        get{
            if(reportMappings == null)
            {
                reportMappings = [Select Id, Name, Business_Units__c, Countries_Under_BU__c, Record_Type__c From TPA_Trending_Reports_Mapping_BU__c];
            }
            return reportMappings;
        }
        set{
            reportMappings = value;
        }
    }

    public static Map<string, set<string>> reportBUsMapping{
        get{
            if(reportBUsMapping == null)
            {
                reportBUsMapping = new Map<string, set<string>>();
                set<string> BUList;
                for(TPA_Trending_Reports_Mapping_BU__c reportBUObj: reportMappings)
                {
                    if(reportBUObj.Record_Type__c != 'BU Mapping')
                        continue;
                    BUList = reportBUsMapping.get(reportBUObj.Business_Units__c);
                    if(BUList == null)
                        BUList = new set<string>();
                    if(!BUList.contains(reportBUObj.Countries_Under_BU__c))
                        BUList.add(reportBUObj.Countries_Under_BU__c);
                    reportBUsMapping.put(reportBUObj.Business_Units__c, BUList);
                }
            }
            return reportBUsMapping;
        }
        set{
            reportBUsMapping = value;
        }
    }

    public static string reportDashboardSettingMapSerialize{
        get{
            return JSON.serialize(reportDashboardSettingMap);
        }
    }

    public static Boolean testAccountsToExclude {
        get {
            if(testAccountsToExclude == null && reportDashboardSettingMap.get('Test Accounts to Exclude') != null && reportDashboardSettingMap.get('Test Accounts to Exclude') != '')
                testAccountsToExclude = Boolean.valueOf(reportDashboardSettingMap.get('Test Accounts to Exclude'));

            return testAccountsToExclude;
        }
        set;
    }

    public static List<string> allBUs{
        get{
            if(allBUs == null)
            {
                if(reportDashboardSettingMap.get('BU1') != null && reportDashboardSettingMap.get('BU1') != '')
                    allBUs  = reportDashboardSettingMap.get('BU1').split(',');
                if(reportDashboardSettingMap.get('BU2') != null && reportDashboardSettingMap.get('BU2') != '')
                {
                    for(string strObj: reportDashboardSettingMap.get('BU2').split(','))
                        allBUs.add(strObj);
                }
                if(reportDashboardSettingMap.get('BU3') != null && reportDashboardSettingMap.get('BU3') != '')
                {
                    for(string strObj: reportDashboardSettingMap.get('BU3').split(','))
                        allBUs.add(strObj);
                }
                if(reportDashboardSettingMap.get('BU4') != null && reportDashboardSettingMap.get('BU4') != '')
                {
                    for(string strObj: reportDashboardSettingMap.get('BU4').split(','))
                        allBUs.add(strObj);
                }
            }
            return allBUs;
        }
        set;
    }

    public static List<string> tpaStatusToExclude{
        get{
            if(tpaStatusToExclude == null && reportDashboardSettingMap.get('TPA Status To Exclude') != null && reportDashboardSettingMap.get('TPA Status To Exclude') != '')
                tpaStatusToExclude = reportDashboardSettingMap.get('TPA Status To Exclude').split(',');

            return tpaStatusToExclude;
        }
        set;
    }

    public string getRequestChunkSize{
        get{
            return CNT_TPA_CustomReportDashboard.reportDashboardSettingMap.get('Requests chunk size to pull');
        }
        private set;
    }

    private static final string Category_TPA_Requests_by_Manual_Trigger = 'TPA Requests by Manual Trigger';
    private static final string Category_TPA_Requests_by_Month = 'TPA Requests by Month';
    private static final string Category_TPA_Requests_by_Month_in_Manual_Auto = 'TPA Requests by Month in Manual/Auto';
    private static final string Category_TPA_Top_Vendors = 'TPA Top ' + reportDashboardSettingMap.get('Top N Records in DB') + ' Vendors';
    private static final string Category_TPA_Top_Small_Clients = 'TPA Top ' + reportDashboardSettingMap.get('Top N Records in DB') + ' Small Clients - no parent record';
    private static final string Category_TPA_Top_Large_Clients = 'TPA Top ' + reportDashboardSettingMap.get('Top N Records in DB') + ' Large Clients - aggregated to parent level';
    private static final string Category_TPA_Top_Uses = 'TPA Top 15 Uses';
    private static final string Category_TPA_Top_Primary_Offerings = 'TPA Top ' + reportDashboardSettingMap.get('Top N Records in DB') + ' Primary Offerings';
    private static final string Category_TPA_Top_Countries = 'TPA Top ' + reportDashboardSettingMap.get('Top N Records in DB') + ' Countries';
    private static final string Category_Top_Offerings = 'Top ' + reportDashboardSettingMap.get('Top N Records in DB') + ' Offerings';
    private static final string Category_ALL = 'ALL';

    public static ReceivedValues receivedObj;
    public static ReturnValues returnObj = new ReturnValues();
    public static String query = '';
    //public static date fromDate;
    public static date fromCreatedDate;
    public static date toCreatedDate;
    public static List<String> requestStatus;
    public static Set<String> category;
    public static boolean selectAllCategory;
    
    @remoteAction
    global static ReturnValues getReportDashboardValues(string serializedValue, string lastRecordId)
    {
        receivedObj = (ReceivedValues)JSON.deserialize(serializedValue, ReceivedValues.class);
        // fromDate = date.today().addMonths(receivedObj.durationValue - (2 * receivedObj.durationValue));
        // fromDate = fromDate.toStartOfMonth().addMonths(1);
        // system.debug(' IN getReportDashboardValues() : FromDate = ' + fromDate);
        fromCreatedDate = parseDate(receivedObj.fromDateValue);
        toCreatedDate = parseDate(receivedObj.toDateValue);
        if(toCreatedDate != null){
            toCreatedDate = toCreatedDate.addDays(1);
        }
        if(receivedObj.reqStatus != null && receivedObj.reqStatus != '') {
          requestStatus = receivedObj.reqStatus.split(';');
        }
        if(receivedObj.lstCategory != null && receivedObj.lstCategory != '') {
          category = new Set<String>(receivedObj.lstCategory.split(';'));
          system.debug(category +'receivedObj.category');
          selectAllCategory = false;
        }
        else{
          selectAllCategory = true;
        }


        if((category != null && category.contains(Category_TPA_Requests_by_Month)) || selectAllCategory){
          loadRequestByMonthDbResult();
        }

        return returnObj;
    }

    @remoteAction
    global static ReturnValues getReportDashboardValuesPart2(string serializedValue, string lastRecordId)
    {
        receivedObj = (ReceivedValues)JSON.deserialize(serializedValue, ReceivedValues.class);
        // fromDate = date.today().addMonths(receivedObj.durationValue - (2 * receivedObj.durationValue));
        // fromDate = fromDate.toStartOfMonth().addMonths(1);
        // system.debug(' IN getReportDashboardValues() : FromDate = ' + fromDate);
        fromCreatedDate = parseDate(receivedObj.fromDateValue);
        toCreatedDate = parseDate(receivedObj.toDateValue);
        if(toCreatedDate != null){
            toCreatedDate = toCreatedDate.addDays(1);
        }
        if(receivedObj.reqStatus != null && receivedObj.reqStatus != '') {
          requestStatus = receivedObj.reqStatus.split(';');
        }
        if(receivedObj.lstCategory != null && receivedObj.lstCategory != '') {
          category = new Set<String>(receivedObj.lstCategory.split(';'));
          system.debug(category +'receivedObj.category');
          selectAllCategory = false;
        }
        else{
          selectAllCategory = true;
        }

        if((category != null && (category.contains(Category_TPA_Requests_by_Month_in_Manual_Auto) || category.contains(Category_TPA_Top_Countries) ) ) || selectAllCategory){
          loadRequestByManualAutoDbResult();
        }
        return returnObj;
    }

    @remoteAction
    global static ReturnValues getReportDashboardValuesPart3(string serializedValue, string lastRecordId)
    {
        receivedObj = (ReceivedValues)JSON.deserialize(serializedValue, ReceivedValues.class);
        // fromDate = date.today().addMonths(receivedObj.durationValue - (2 * receivedObj.durationValue));
        // fromDate = fromDate.toStartOfMonth().addMonths(1);
        // system.debug(' IN getReportDashboardValues() : FromDate = ' + fromDate);
        fromCreatedDate = parseDate(receivedObj.fromDateValue);
        toCreatedDate = parseDate(receivedObj.toDateValue);
        if(toCreatedDate != null){
            toCreatedDate = toCreatedDate.addDays(1);
        }
        if(receivedObj.reqStatus != null && receivedObj.reqStatus != '') {
          requestStatus = receivedObj.reqStatus.split(';');
        }
        if(receivedObj.lstCategory != null && receivedObj.lstCategory != '') {
          category = new Set<String>(receivedObj.lstCategory.split(';'));
          system.debug(category +'receivedObj.category');
          selectAllCategory = false;
        }
        else{
          selectAllCategory = true;
        }

        if((category != null && (category.contains(Category_TPA_Top_Vendors) || category.contains(Category_TPA_Top_Small_Clients) || category.contains(Category_TPA_Top_Large_Clients) ) ) || selectAllCategory){
          loadRequestTopClientsVendorsDbResult();
        }
        return returnObj;
    }

    @remoteAction
    global static ReturnValues getReportDashboardValuesPart4(string serializedValue, string lastRecordId)
    {
        receivedObj = (ReceivedValues)JSON.deserialize(serializedValue, ReceivedValues.class);
        // fromDate = date.today().addMonths(receivedObj.durationValue - (2 * receivedObj.durationValue));
        // fromDate = fromDate.toStartOfMonth().addMonths(1);
        // system.debug(' IN getReportDashboardValues() : FromDate = ' + fromDate);
        fromCreatedDate = parseDate(receivedObj.fromDateValue);
        toCreatedDate = parseDate(receivedObj.toDateValue);
        if(toCreatedDate != null){
            toCreatedDate = toCreatedDate.addDays(1);
        }
        if(receivedObj.reqStatus != null && receivedObj.reqStatus != '') {
          requestStatus = receivedObj.reqStatus.split(';');
        }
        if(receivedObj.lstCategory != null && receivedObj.lstCategory != '') {
          category = new Set<String>(receivedObj.lstCategory.split(';'));
          system.debug(category +'receivedObj.category');
          selectAllCategory = false;
        }
        else{
          selectAllCategory = true;
        }

        if((category != null && (category.contains(Category_TPA_Top_Uses) || category.contains(Category_TPA_Top_Primary_Offerings))) || selectAllCategory ){
          loadRequestTopUsesDbResult();
        }
        return returnObj;
    }

    @remoteAction
    global static ReturnValues getReportDashboardValuesPart5(string serializedValue, string lastRecordId)
    {
        receivedObj = (ReceivedValues)JSON.deserialize(serializedValue, ReceivedValues.class);
        // fromDate = date.today().addMonths(receivedObj.durationValue - (2 * receivedObj.durationValue));
        // fromDate = fromDate.toStartOfMonth().addMonths(1);
        // system.debug(' IN getReportDashboardValues() : FromDate = ' + fromDate);
        fromCreatedDate = parseDate(receivedObj.fromDateValue);
        toCreatedDate = parseDate(receivedObj.toDateValue);
        if(toCreatedDate != null){
            toCreatedDate = toCreatedDate.addDays(1);
        }
        if(receivedObj.reqStatus != null && receivedObj.reqStatus != '') {
          requestStatus = receivedObj.reqStatus.split(';');
        }
        if(receivedObj.lstCategory != null && receivedObj.lstCategory != '') {
          category = new Set<String>(receivedObj.lstCategory.split(';'));
          system.debug(category +'receivedObj.category');
          selectAllCategory = false;
        }
        else{
          selectAllCategory = true;
        }

        if((category != null && (category.contains(Category_TPA_Top_Uses) || category.contains(Category_TPA_Top_Primary_Offerings))) || selectAllCategory ){
          loadRequestTopPrimOffDbResult();
        }
        return returnObj;
    }

    @remoteAction
    global static ReturnValues getReportDashboardValuesPart6(string serializedValue, string lastRecordId)
    {
        receivedObj = (ReceivedValues)JSON.deserialize(serializedValue, ReceivedValues.class);
        // fromDate = date.today().addMonths(receivedObj.durationValue - (2 * receivedObj.durationValue));
        // fromDate = fromDate.toStartOfMonth().addMonths(1);
        // system.debug(' IN getReportDashboardValues() : FromDate = ' + fromDate);
        fromCreatedDate = parseDate(receivedObj.fromDateValue);
        toCreatedDate = parseDate(receivedObj.toDateValue);
        if(toCreatedDate != null){
            toCreatedDate = toCreatedDate.addDays(1);
        }
        if(receivedObj.reqStatus != null && receivedObj.reqStatus != '') {
          requestStatus = receivedObj.reqStatus.split(';');
        }
        if(receivedObj.lstCategory != null && receivedObj.lstCategory != '') {
          category = new Set<String>(receivedObj.lstCategory.split(';'));
          system.debug(category +'receivedObj.category');
          selectAllCategory = false;
        }
        else{
          selectAllCategory = true;
        }

        if((category != null && (category.contains(Category_TPA_Top_Uses) || category.contains(Category_TPA_Top_Primary_Offerings))) || selectAllCategory ){
          loadRequestTopSecOffDbResult();
        }
        return returnObj;
    }

    public static void loadRequestTopUsesDbResult()
    {
        Set<String> countrySet = new Set<String>();
        //system.debug(' IN loadRequestTopUsesOfferingsDbResult() : FromDate = ' + fromDate);
        query = 'Select Count(Id) Use_Count, Name from TPA_Purpose__c where Request__r.Request_Status__c != null and Request__r.Request_Status__c != \'\' and Request__c != null and Request__r.Is_Submitted__c = true and Request__r.createdDate >= ' + reportDashboardSettingMap.get('Requests After Date') + ' ';
        if(testAccountsToExclude != null && testAccountsToExclude == true)
        {
        query += ' and (NOT Request__r.Service_Provider_Address__r.Name like \'Test\\_%\') and (NOT Request__r.Client_Address__r.Name like \'Test\\_%\') ';
        }
        query = addStatusFilterInQuery(query, 'Request__r.Request_Status__c');
        if(receivedObj.countryLocation == 'All excluding US'){
            if(mapCountryCodesWithAllValues.containsKey(('United States').toLowerCase()) ){
                    countrySet.addAll(mapCountryCodesWithAllValues.get(('United States').toLowerCase()).split(';'));
                }
                system.debug('countrysetfornonus****'+countrySet);
            query += ' and BU__c Not in : countrySet ';
        }
        else if(receivedObj.countryLocation.indexOf('BU - ') != -1)
        {
            set<string> buList = reportBUsMapping.get(receivedObj.countryLocation.split('BU - ')[1]);
            set<string> buListWithCodes = new set<string>();
            for(string strBu: buList) {
                if(mapCountryCodesWithAllValues.get(strBu.toLowerCase()) != null) {
                    buListWithCodes.addAll(mapCountryCodesWithAllValues.get(strBu.toLowerCase()).split(';'));
                }
            }
            if(buListWithCodes.size() == 0) {
                buListWithCodes = buList;
            }
            query += ' and BU__c in :buListWithCodes ';
        }
        else if(receivedObj.countryLocation != 'All'){
            if(mapCountryCodesWithAllValues.containsKey(receivedObj.countryLocation.toLowerCase())) {
                                countrySet.addAll(mapCountryCodesWithAllValues.get(receivedObj.countryLocation.toLowerCase()).split(';'));
                                countrySet.add(receivedObj.countryLocation);
                            }
            system.debug('*********countrySet '+countrySet);
            query += ' and BU__c in : countrySet ';
        }

        query = addDatesinQuery(query, 'Request__r.createddate');
        query += ' group by Name order by Count(Id) desc ';
        if(reportDashboardSettingMap.get('Top N Records in DB') != null && reportDashboardSettingMap.get('Top N Records in DB') != '')
            query += ' Limit ' + reportDashboardSettingMap.get('Top N Records in DB');
        system.debug('qery:::'+query);
        returnObj.requestTopUsesDbResult = Database.query(query);system.debug('done:::');
    }

    public static void loadRequestTopPrimOffDbResult()
    {
        Set<String> countrySet = new Set<String>();
        //system.debug(' IN loadRequestTopUsesOfferingsDbResult() : FromDate = ' + fromDate);

        query = 'Select Count(Id) Offering_Count, Asset_NametText__c from TPA_Data_Asset__c where Request__r.Request_Status__c != null and Request__r.Request_Status__c != \'\' and Request__c != null and Request__r.Is_Submitted__c = true and Request__r.createdDate >= ' + reportDashboardSettingMap.get('Requests After Date') + ' ';
        if(testAccountsToExclude != null && testAccountsToExclude == true){
        query += ' and (NOT Request__r.Service_Provider_Address__r.Name like \'Test\\_%\') and (NOT Request__r.Client_Address__r.Name like \'Test\\_%\') '; // Commented by Babita Dadarwal under Issue-10866
        }

        query = addStatusFilterInQuery(query, 'Request__r.Request_Status__c');
        if(receivedObj.countryLocation == 'All excluding US'){
            if(mapCountryCodesWithAllValues.containsKey(('United States').toLowerCase()) ){
                    countrySet.addAll(mapCountryCodesWithAllValues.get(('United States').toLowerCase()).split(';'));
                }
                system.debug('countrysetfornonus****'+countrySet);
            query += ' and BU__c Not in : countrySet ';
        }
        else if(receivedObj.countryLocation.indexOf('BU - ') != -1)
        {
            set<string> buList = reportBUsMapping.get(receivedObj.countryLocation.split('BU - ')[1]);
            set<string> buListWithCodes = new set<string>();
            for(string strBu: buList) {
                if(mapCountryCodesWithAllValues.get(strBu.toLowerCase()) != null) {
                    buListWithCodes.addAll(mapCountryCodesWithAllValues.get(strBu.toLowerCase()).split(';'));
                }
            }
            if(buListWithCodes.size() == 0) {
                buListWithCodes = buList;
            }
            query += ' and BU__c in :buListWithCodes ';
        }
        else if(receivedObj.countryLocation != 'All'){
            
            if(mapCountryCodesWithAllValues.containsKey(receivedObj.countryLocation.toLowerCase())) {
                                countrySet.addAll(mapCountryCodesWithAllValues.get(receivedObj.countryLocation.toLowerCase()).split(';'));
                                countrySet.add(receivedObj.countryLocation);
                            }
            system.debug('*********countrySet '+countrySet);
            query += ' and BU__c in : countrySet ';
        }
        query = addDatesinQuery(query, 'Request__r.createddate');
        query += ' group by Asset_NametText__c order by count(Id) desc ';
        if(reportDashboardSettingMap.get('Top N Records in DB') != null && reportDashboardSettingMap.get('Top N Records in DB') != '')
            query += ' Limit ' + reportDashboardSettingMap.get('Top N Records in DB');

        system.debug('top offering query' + query);
        returnObj.requestTopOfferingsDbResult = Database.query(query);
    }

    public static void loadRequestTopSecOffDbResult()
    {
        Set<String> countrySet = new Set<String>();
        //system.debug(' IN loadRequestTopUsesOfferingsDbResult() : FromDate = ' + fromDate);

        query = 'Select Count(Id) Sec_Offering_Count, TPA_Data_Asset__r.Asset_NametText__c, Secondary_Asset_Name__c from TPA_Secondary_Data_Asset__c where TPA_Data_Asset__c != null and TPA_Data_Asset__r.Request__r.Request_Status__c != null and TPA_Data_Asset__r.Request__r.Request_Status__c != \'\' and TPA_Data_Asset__r.Request__c != null and TPA_Data_Asset__r.Request__r.Is_Submitted__c = true and TPA_Data_Asset__r.Request__r.createdDate >= ' + reportDashboardSettingMap.get('Requests After Date') + ' ';
        if(testAccountsToExclude != null && testAccountsToExclude == true)
        {
        query += ' and (NOT TPA_Data_Asset__r.Request__r.Service_Provider_Address__r.Name like \'Test\\_%\') and (NOT TPA_Data_Asset__r.Request__r.Client_Address__r.Name like \'Test\\_%\') '; // Commented by Babita Dadarwal under Issue-10866
        }
        query = addStatusFilterInQuery(query, 'TPA_Data_Asset__r.Request__r.Request_Status__c');
        if(receivedObj.countryLocation == 'All excluding US'){
            if(mapCountryCodesWithAllValues.containsKey(('United States').toLowerCase()) ){
                    countrySet.addAll(mapCountryCodesWithAllValues.get(('United States').toLowerCase()).split(';'));
                }
                system.debug('countrysetfornonus****'+countrySet);
            query += ' and BU__c Not in : countrySet ';
        }
        else if(receivedObj.countryLocation.indexOf('BU - ') != -1)
        {
            set<string> buList = reportBUsMapping.get(receivedObj.countryLocation.split('BU - ')[1]);
            set<string> buListWithCodes = new set<string>();
            for(string strBu: buList) {
                if(mapCountryCodesWithAllValues.get(strBu.toLowerCase()) != null) {
                    buListWithCodes.addAll(mapCountryCodesWithAllValues.get(strBu.toLowerCase()).split(';'));
                }
            }
            if(buListWithCodes.size() == 0) {
                buListWithCodes = buList;
            }
            query += ' and BU__c in :buListWithCodes ';
        }
        else if(receivedObj.countryLocation != 'All'){
            
            if(mapCountryCodesWithAllValues.containsKey(receivedObj.countryLocation.toLowerCase())) {
                                countrySet.addAll(mapCountryCodesWithAllValues.get(receivedObj.countryLocation.toLowerCase()).split(';'));
                                countrySet.add(receivedObj.countryLocation);
                            }
            system.debug('*********countrySet1 '+countrySet);
            query += ' and BU__c in : countrySet ';
        }
        query = addDatesinQuery(query, 'TPA_Data_Asset__r.Request__r.createddate');
        query += ' group by TPA_Data_Asset__r.Asset_NametText__c, Secondary_Asset_Name__c order by count(Id) desc ';
        returnObj.requestTopSecOfferingsDbResult = Database.query(query);
    }
    
    public static void loadRequestTopClientsVendorsDbResult()
    {
        Set<String> countrySet = new Set<String>();
        query = 'Select count(Id) TPA_Count, Service_Provider_Address__r.Name from TPA_Request__c where Request_Status__c != null and Request_Status__c != \'\' and ' + 
                'Is_Submitted__c = true and Service_Provider_Address__c != null and createdDate >= ' + 
                 reportDashboardSettingMap.get('Requests After Date') + ' ';
        if(testAccountsToExclude != null && testAccountsToExclude == true){
        query += ' and (NOT Service_Provider_Address__r.Name like \'Test\\_%\') and (NOT Client_Address__r.Name like \'Test\\_%\') ';
        }
        query = addStatusFilterInQuery(query, 'Request_Status__c');
        if(receivedObj.countryLocation == 'All excluding US'){
            if(mapCountryCodesWithAllValues.containsKey(('United States').toLowerCase()) ){
                    countrySet.addAll(mapCountryCodesWithAllValues.get(('United States').toLowerCase()).split(';'));
                }
                system.debug('countrysetfornonus****'+countrySet);
            query += ' and Service_Provider_Address__r.Region_Territory__c Not in : countrySet ';
        }
        else if(receivedObj.countryLocation.indexOf('BU - ') != -1)
        {
            set<string> buList = reportBUsMapping.get(receivedObj.countryLocation.split('BU - ')[1]);
            set<string> buListWithCodes = new set<string>();
            for(string strBu: buList) {
                if(mapCountryCodesWithAllValues.get(strBu.toLowerCase()) != null) {
                    buListWithCodes.addAll(mapCountryCodesWithAllValues.get(strBu.toLowerCase()).split(';'));
                }
            }
            if(buListWithCodes.size() == 0) {
                buListWithCodes = buList;
            }
            system.debug('buListWithCodes:::' + buListWithCodes);
            query += ' and Service_Provider_Address__r.Region_Territory__c in :buListWithCodes ';
        }
        else if(receivedObj.countryLocation != 'All'){
            
            if(mapCountryCodesWithAllValues.containsKey(receivedObj.countryLocation.toLowerCase())) {
                                countrySet.addAll(mapCountryCodesWithAllValues.get(receivedObj.countryLocation.toLowerCase()).split(';'));
                                countrySet.add(receivedObj.countryLocation);
                            }
            system.debug('*********countrySet1 '+countrySet);
            query += ' and Service_Provider_Address__r.Region_Territory__c in : countrySet ';
        }
        query = addDatesinQuery(query, 'createddate');
        query += ' group by Service_Provider_Address__r.Name order by count(Id) desc ';
        SYSTEM.debug('***********query447'+query);
        if(reportDashboardSettingMap.get('Top N Records in DB') != null && reportDashboardSettingMap.get('Top N Records in DB') != '')
            query += ' Limit ' + reportDashboardSettingMap.get('Top N Records in DB');
        returnObj.requestTopVendorsDbResult = Database.query(query);


        query = 'Select count(Id) TPA_Count, Client_Address__r.Name from TPA_Request__c where Request_Status__c != null and Request_Status__c != \'\' and ' +
                'Is_Submitted__c = true and Client_Address__c != null and Client_Address__r.Account__r.parent.name = null and createdDate >= ' + 
                reportDashboardSettingMap.get('Requests After Date') + ' ';
        if(testAccountsToExclude != null && testAccountsToExclude == true)
        {
        query += ' and (NOT Service_Provider_Address__r.Name like \'Test\\_%\') and (NOT Client_Address__r.Name like \'Test\\_%\') ';
        }

        query = addStatusFilterInQuery(query, 'Request_Status__c');
        if(receivedObj.countryLocation == 'All excluding US'){
            if(mapCountryCodesWithAllValues.containsKey(('United States').toLowerCase()) ){
                    countrySet.addAll(mapCountryCodesWithAllValues.get(('United States').toLowerCase()).split(';'));
                }
                system.debug('countrysetfornonus****'+countrySet);
            query += ' and Client_Address__r.Region_Territory__c Not in : countrySet ';
        }
        else if(receivedObj.countryLocation.indexOf('BU - ') != -1)
        {
            set<string> buList = reportBUsMapping.get(receivedObj.countryLocation.split('BU - ')[1]);
            set<string> buListWithCodes = new set<string>();
            for(string strBu: buList) {
                if(mapCountryCodesWithAllValues.get(strBu.toLowerCase()) != null) {
                    buListWithCodes.addAll(mapCountryCodesWithAllValues.get(strBu.toLowerCase()).split(';'));
                }
            }
            if(buListWithCodes.size() == 0) {
                buListWithCodes = buList;
            }
            query += 'and Client_Address__r.Region_Territory__c in :buListWithCodes ';
        }
        else if(receivedObj.countryLocation != 'All'){
            if(mapCountryCodesWithAllValues.containsKey(receivedObj.countryLocation.toLowerCase())) {
                                countrySet.addAll(mapCountryCodesWithAllValues.get(receivedObj.countryLocation.toLowerCase()).split(';'));
                                countrySet.add(receivedObj.countryLocation);
                            }
            system.debug('*********countrySet2 '+countrySet);
            query += ' and Client_Address__r.Region_Territory__c in : countrySet ';
        }
        query = addDatesinQuery(query, 'createddate');
        query += ' group by Client_Address__r.Name order by count(Id) desc ';
        if(reportDashboardSettingMap.get('Top N Records in DB') != null && reportDashboardSettingMap.get('Top N Records in DB') != '')
            query += ' Limit ' + reportDashboardSettingMap.get('Top N Records in DB');
        returnObj.requestTopSmallClientsDbResult = Database.query(query);

        query = 'Select count(Id) TPA_Count, Client_Address__r.Account__r.parent.name from TPA_Request__c where Request_Status__c != null and Request_Status__c != \'\' and ' +
                'Is_Submitted__c = true and Client_Address__c != null and Client_Address__r.Account__r.parent.name != null and createdDate >= ' + 
                reportDashboardSettingMap.get('Requests After Date') + ' ';
        if(testAccountsToExclude != null && testAccountsToExclude == true){
            query += ' and (NOT Service_Provider_Address__r.Name like \'Test\\_%\') and (NOT Client_Address__r.Name like \'Test\\_%\') ';
        }

        query = addStatusFilterInQuery(query, 'Request_Status__c');
        if(receivedObj.countryLocation == 'All excluding US'){
            if(mapCountryCodesWithAllValues.containsKey(('United States').toLowerCase()) ){
                    countrySet.addAll(mapCountryCodesWithAllValues.get(('United States').toLowerCase()).split(';'));
                }
                system.debug('countrysetfornonus****'+countrySet);
            query += ' and Client_Address__r.Region_Territory__c Not in : countrySet ';
        }
        else if(receivedObj.countryLocation.indexOf('BU - ') != -1)
        {
            set<string> buList = reportBUsMapping.get(receivedObj.countryLocation.split('BU - ')[1]);
            set<string> buListWithCodes = new set<string>();
            for(string strBu: buList) {
                if(mapCountryCodesWithAllValues.get(strBu.toLowerCase()) != null) {
                    buListWithCodes.addAll(mapCountryCodesWithAllValues.get(strBu.toLowerCase()).split(';'));
                }
            }
            if(buListWithCodes.size() == 0) {
                buListWithCodes = buList;
            }
            query += ' and Client_Address__r.Region_Territory__c in :buListWithCodes ';
        }
        else if(receivedObj.countryLocation != 'All'){
            if(mapCountryCodesWithAllValues.containsKey(receivedObj.countryLocation.toLowerCase())) {
                                countrySet.addAll(mapCountryCodesWithAllValues.get(receivedObj.countryLocation.toLowerCase()).split(';'));
                                countrySet.add(receivedObj.countryLocation);
                            }
            system.debug('*********countrySet3 '+countrySet);
            query += ' and Client_Address__r.Region_Territory__c in : countrySet ';
        }
        query = addDatesinQuery(query, 'createddate');
        query += ' group by Client_Address__r.Account__r.parent.name order by count(Id) desc ';
        if(reportDashboardSettingMap.get('Top N Records in DB') != null && reportDashboardSettingMap.get('Top N Records in DB') != '')
            query += ' Limit ' + reportDashboardSettingMap.get('Top N Records in DB');
        returnObj.requestTopLargeClientsDbResult = Database.query(query);
    }

    public static void loadRequestByMonthDbResult()
    {
        Set<String> countrySet = new Set<String>();
        query = 'Select count(Id) TPA_Count, CALENDAR_YEAR(CreatedDate) Year, calendar_month(createddate) Month from TPA_Request__c where Request_Status__c != null and ' +
                'Request_Status__c != \'\' and Is_Submitted__c = true and createdDate >= ' + reportDashboardSettingMap.get('Requests After Date') + ' ';
        if(testAccountsToExclude != null && testAccountsToExclude == true){
            query += ' and (NOT Service_Provider_Address__r.Name like \'Test\\_%\') and (NOT Client_Address__r.Name like \'Test\\_%\') ';
        }

        query = addStatusFilterInQuery(query, 'Request_Status__c');
        if(receivedObj.countryLocation == 'All excluding US'){
            if(mapCountryCodesWithAllValues.containsKey(('United States').toLowerCase()) ){
                    countrySet.addAll(mapCountryCodesWithAllValues.get(('United States').toLowerCase()).split(';'));
                }
                system.debug('countrysetfornonus****'+countrySet);
            query += ' and Client_Contact_Territory__c Not in : countrySet ';
        }
        else if(receivedObj.countryLocation.indexOf('BU - ') != -1)
        {
            set<string> buList = reportBUsMapping.get(receivedObj.countryLocation.split('BU - ')[1]);
            set<string> buListWithCodes = new set<string>();
            for(string strBu: buList) {
                if(mapCountryCodesWithAllValues.get(strBu.toLowerCase()) != null) {
                    buListWithCodes.addAll(mapCountryCodesWithAllValues.get(strBu.toLowerCase()).split(';'));
                }
            }
            if(buListWithCodes.size() == 0) {
                buListWithCodes = buList;
            }
            query += ' and Client_Contact_Territory__c in :buListWithCodes ';
        }
        else if(receivedObj.countryLocation != 'All'){
            if(mapCountryCodesWithAllValues.containsKey(receivedObj.countryLocation.toLowerCase())) {
                                countrySet.addAll(mapCountryCodesWithAllValues.get(receivedObj.countryLocation.toLowerCase()).split(';'));
                                countrySet.add(receivedObj.countryLocation);
                            }
            system.debug('*********countrySet4 '+countrySet);
            query += ' and Client_Contact_Territory__c in : countrySet  ';
        }
        query = addDatesinQuery(query, 'createddate');
        query += ' group by CALENDAR_YEAR(CreatedDate),  calendar_month(createddate) order by CALENDAR_YEAR(CreatedDate), calendar_month(createddate)';
        returnObj.requestByMonthDbResult = Database.query(query);
    }

    public static void loadRequestByManualAutoDbResult()
    {
    Set<String> countrySet = new Set<String>();
        query = 'Select count(Id) TPA_Count, CALENDAR_YEAR(CreatedDate) Year, calendar_month(createddate) Month, Requires_Manual_Review__c Manual_Auto from TPA_Request__c ' +
                'where Request_Status__c != null and Request_Status__c != \'\' and Is_Submitted__c = true and createdDate >= ' + 
                reportDashboardSettingMap.get('Requests After Date') + ' ';
        if(testAccountsToExclude != null && testAccountsToExclude == true){
            query += ' and (NOT Service_Provider_Address__r.Name like \'Test\\_%\') and (NOT Client_Address__r.Name like \'Test\\_%\') ';
        }

        query = addStatusFilterInQuery(query, 'Request_Status__c');
        if(receivedObj.countryLocation == 'All excluding US'){
            if(mapCountryCodesWithAllValues.containsKey(('United States').toLowerCase()) ){
                    countrySet.addAll(mapCountryCodesWithAllValues.get(('United States').toLowerCase()).split(';'));
                }
                system.debug('countrysetfornonus****'+countrySet);
            query += ' and Client_Contact_Territory__c Not in : countrySet ';
        }
        else if(receivedObj.countryLocation.indexOf('BU - ') != -1)
        {
            set<string> buList = reportBUsMapping.get(receivedObj.countryLocation.split('BU - ')[1]);
            set<string> buListWithCodes = new set<string>();
            for(string strBu: buList) {
                if(mapCountryCodesWithAllValues.get(strBu.toLowerCase()) != null) {
                    buListWithCodes.addAll(mapCountryCodesWithAllValues.get(strBu.toLowerCase()).split(';'));
                }
            }
            if(buListWithCodes.size() == 0) {
                buListWithCodes = buList;
            }
            query += ' and Client_Contact_Territory__c in :buListWithCodes ';
        }
        else if(receivedObj.countryLocation != 'All'){
            system.debug('*********'+receivedObj.countryLocation);
            if(mapCountryCodesWithAllValues.containsKey(receivedObj.countryLocation.toLowerCase())) {
                                countrySet.addAll(mapCountryCodesWithAllValues.get(receivedObj.countryLocation.toLowerCase()).split(';'));
                                countrySet.add(receivedObj.countryLocation);
                            }
            system.debug('*********countrySet5 '+countrySet);
            query += ' and Client_Contact_Territory__c in : countrySet  ';
        }
        query = addDatesinQuery(query, 'createddate');
        query += ' group by CALENDAR_YEAR(CreatedDate),  calendar_month(createddate), Requires_Manual_Review__c order by CALENDAR_YEAR(CreatedDate), calendar_month(createddate), Requires_Manual_Review__c';
        returnObj.requestByManualAutoDbResult = Database.query(query);

        if(receivedObj.countryLocation == 'All' || receivedObj.countryLocation == 'All excluding US')
        {
            query = 'Select count(Id) TPA_Count, Client_Contact_Territory__c from TPA_Request__c where Request_Status__c != null and Request_Status__c != \'\' and ' +
                    'Is_Submitted__c = true and createdDate >= ' + reportDashboardSettingMap.get('Requests After Date') + ' ';
            if(testAccountsToExclude != null && testAccountsToExclude == true){
                query += ' and (NOT Service_Provider_Address__r.Name like \'Test\\_%\') and (NOT Client_Address__r.Name like \'Test\\_%\') ';
            }

            query = addStatusFilterInQuery(query, 'Request_Status__c');
            if(receivedObj.countryLocation == 'All excluding US'){
                if(mapCountryCodesWithAllValues.containsKey(('United States').toLowerCase()) ){
                    countrySet.addAll(mapCountryCodesWithAllValues.get(('United States').toLowerCase()).split(';'));
                }
                system.debug('countrysetfornonus****'+countrySet);
                query += ' and Client_Contact_Territory__c Not in : countrySet ';
            }
            else if(receivedObj.countryLocation != 'All'){
                if(mapCountryCodesWithAllValues.containsKey(receivedObj.countryLocation.toLowerCase())) {
                    countrySet.addAll(mapCountryCodesWithAllValues.get(receivedObj.countryLocation.toLowerCase()).split(';'));
                    countrySet.add(receivedObj.countryLocation);
                }
                system.debug('*********countrySet6 '+countrySet);
                query += ' and Client_Contact_Territory__c in : countrySet ';
            }
            query = addDatesinQuery(query, 'createddate');
            query += ' group by Client_Contact_Territory__c order by count(Id) desc ';
            //if(reportDashboardSettingMap.get('Top N Records in DB') != null && reportDashboardSettingMap.get('Top N Records in DB') != '')
            //    query += ' Limit ' + reportDashboardSettingMap.get('Top N Records in DB');
            
            System.debug('TopCountries query --------------> ' + query);
            System.debug('TopCountries --------------> ' + Database.query(query));
            returnObj.requestByCountries = Database.query(query);
        }
    }

    @remoteAction @ReadOnly
    public static ReturnValues loadPrimSecOfferingsByCountryDbResult(string serializedValue, string lastRecordId)
    {
        Set<String> countrySet = new Set<String>();
        receivedObj = (ReceivedValues)JSON.deserialize(serializedValue, ReceivedValues.class);
        system.debug('receivedObj:::'+lastRecordId);
        
        // fromDate = date.today().addMonths(receivedObj.durationValue - (2 * receivedObj.durationValue));
        // fromDate = fromDate.toStartOfMonth().addMonths(1);
        // system.debug(' IN loadPrimSecOfferingsByCountryDbResult() : FromDate = ' + fromDate);

        datetime lastRecordCretedDateTime;
        if(lastRecordId != null)
            lastRecordCretedDateTime = [select createddate from TPA_Data_Asset__c where id =: lastRecordId limit 1][0].createddate;

        query = 'select id, Asset_Name__c, Geo_Level__c, purpose__r.name, Request__r.name, Request__r.Service_Provider_Address__r.name, Request__r.Client_Address__r.name, BU__c, createddate, (select Secondary_Asset_Name__c from TPA_Secondary_Data_Assets__r) from TPA_Data_Asset__c';
        query += ' where Request__r.Request_Status__c != null';
        query += ' and Request__r.Request_Status__c != \'\'';
        query += ' and Request__c != null';
        query += ' and Request__r.Is_Submitted__c = true';
        query += ' and Request__r.createdDate >= ' + reportDashboardSettingMap.get('Requests After Date') + ' ';
        if(testAccountsToExclude != null && testAccountsToExclude == true){
        query += ' and (NOT Request__r.Service_Provider_Address__r.Name like \'Test\\_%\') and (NOT Request__r.Client_Address__r.Name like \'Test\\_%\')'; 
        }
        if(receivedObj.reqStatus != null && receivedObj.reqStatus != '') {
          requestStatus = receivedObj.reqStatus.split(';');
        }
        if(requestStatus != null && requestStatus.size() > 0 ){
           query += ' and Request__r.Request_Status__c In :requestStatus ';
        }
        else if(tpaStatusToExclude != null)
            query += ' and  Request__r.Request_Status__c Not In :tpaStatusToExclude ';

        fromCreatedDate = parseDate(receivedObj.fromDateValue);
        toCreatedDate = parseDate(receivedObj.toDateValue);
        if(fromCreatedDate != null){
            query += 'and createddate >= :fromCreatedDate ';
        }
        if(toCreatedDate != null){
            toCreatedDate = toCreatedDate.addDays(1);
            query += 'and createddate < :toCreatedDate ';
        }
        if(receivedObj.countryLocation == 'All excluding US'){
            if(mapCountryCodesWithAllValues.containsKey(('United States').toLowerCase()) ){
                    countrySet.addAll(mapCountryCodesWithAllValues.get(('United States').toLowerCase()).split(';'));
                }
                system.debug('countrysetfornonus****'+countrySet);
            query += ' and BU__c Not in : countrySet ';
        }
        else if(receivedObj.countryLocation.indexOf('BU - ') != -1)
        {
            set<string> buList = reportBUsMapping.get(receivedObj.countryLocation.split('BU - ')[1]);
            set<string> buListWithCodes = new set<string>();
            for(string strBu: buList) {
                if(mapCountryCodesWithAllValues.get(strBu.toLowerCase()) != null) {
                    buListWithCodes.addAll(mapCountryCodesWithAllValues.get(strBu.toLowerCase()).split(';'));
                }
            }
            if(buListWithCodes.size() == 0) {
                buListWithCodes = buList;
            }
            query += ' and BU__c in :buListWithCodes ';
        }
        else if(receivedObj.countryLocation != 'All'){
                if(mapCountryCodesWithAllValues.containsKey(receivedObj.countryLocation.toLowerCase())) {
                                countrySet.addAll(mapCountryCodesWithAllValues.get(receivedObj.countryLocation.toLowerCase()).split(';'));
                                countrySet.add(receivedObj.countryLocation);
                            }
            system.debug('*********countrySet* '+countrySet);
            query += ' and BU__c in : countrySet ';
        }
        else if(receivedObj.countryLocation == 'All')
        {
            query += ' and BU__c in :allBUs ';
        }
        if(lastRecordCretedDateTime != null)
            query += ' and createddate >=: lastRecordCretedDateTime ';
        query += ' order by createddate asc Limit ' + receivedObj.pageSize;
        system.debug(' IN loadPrimSecOfferingsByCountryDbResult() :  query::::'+query);
        returnObj.primSecOfferingByCountries = Database.query(query);
        system.debug('query1::::'+lastRecordCretedDateTime);
        return returnObj;
    }

    @remoteAction
    global static ReturnValues getReportDashboardValuesManualReview(string serializedValue, string lastRecordId)
    {
        Set<String> countrySet = new Set<String>();
        receivedObj = (ReceivedValues)JSON.deserialize(serializedValue, ReceivedValues.class);
        datetime lastRecordCretedDateTime;
        // fromDate = date.today().addMonths(receivedObj.durationValue - (2 * receivedObj.durationValue));
        // fromDate = fromDate.toStartOfMonth().addMonths(1);
        fromCreatedDate = parseDate(receivedObj.fromDateValue);
        toCreatedDate = parseDate(receivedObj.toDateValue);
        if(receivedObj.reqStatus != null && receivedObj.reqStatus != '') {
          requestStatus = receivedObj.reqStatus.split(';');
        }
        if(lastRecordId != null)
            lastRecordCretedDateTime = [select createddate from TPA_Request__c where id =: lastRecordId limit 1][0].createddate;

        query = 'Select Id, Manual_Trigger_Reasons__c, Requires_Manual_Review__c from TPA_Request__c where Request_Status__c != null and Request_Status__c != \'\' and ' + 
                'Is_Submitted__c = true and createdDate >= ' + reportDashboardSettingMap.get('Requests After Date') + ' ';
        if(testAccountsToExclude != null && testAccountsToExclude == true){
            query += ' and (NOT Service_Provider_Address__r.Name like \'Test\\_%\') and (NOT Client_Address__r.Name like \'Test\\_%\') ';
        }

        if(requestStatus != null && requestStatus.size() > 0 ){
            query += ' and Request_Status__c In :requestStatus ';
        }
        else if(tpaStatusToExclude != null)
            query += ' and Request_Status__c Not In :tpaStatusToExclude ';
        if(receivedObj.countryLocation == 'All excluding US'){
            if(mapCountryCodesWithAllValues.containsKey(('United States').toLowerCase()) ){
                    countrySet.addAll(mapCountryCodesWithAllValues.get(('United States').toLowerCase()).split(';'));
                }
                system.debug('countrysetfornonus****'+countrySet);
            query += 'and Client_Contact_Territory__c Not in : countrySet ';
        }
        else if(receivedObj.countryLocation.indexOf('BU - ') != -1)
        {
            set<string> buList = reportBUsMapping.get(receivedObj.countryLocation.split('BU - ')[1]);
            set<string> buListWithCodes = new set<string>();
            for(string strBu: buList) {
                if(mapCountryCodesWithAllValues.get(strBu.toLowerCase()) != null) {
                    buListWithCodes.addAll(mapCountryCodesWithAllValues.get(strBu.toLowerCase()).split(';'));
                }
            }
            if(buListWithCodes.size() == 0) {
                buListWithCodes = buList;
            }
            query += ' and Client_Contact_Territory__c in :buListWithCodes ';
        }
        else if(receivedObj.countryLocation != 'All'){
            if(mapCountryCodesWithAllValues.containsKey(receivedObj.countryLocation.toLowerCase())) {
                                countrySet.addAll(mapCountryCodesWithAllValues.get(receivedObj.countryLocation.toLowerCase()).split(';'));
                                countrySet.add(receivedObj.countryLocation);
                            }
            system.debug('*********countrySet7 '+countrySet);
            query += 'and Client_Contact_Territory__c in : countrySet ';
        }
        if(fromCreatedDate != null){
            query += 'and createddate >= :fromCreatedDate ';
        }
        if(toCreatedDate != null){
            toCreatedDate = toCreatedDate.addDays(1);
            query += 'and createddate < :toCreatedDate ';
        }
        if(lastRecordCretedDateTime != null)
            query += ' and createddate >: lastRecordCretedDateTime order by createddate asc Limit ' + reportDashboardSettingMap.get('Requests chunk size to pull');
        else
            query += ' order by createddate asc Limit ' + reportDashboardSettingMap.get('Requests chunk size to pull');
        returnObj.manualReviewDbResult = Database.query(query);
        return returnObj;
    }

    public static String addDatesinQuery(string query, String createdDate)
    {
      if(fromCreatedDate != null){
           query += 'and ' + createdDate +' >= :fromCreatedDate ';
        }
        if(toCreatedDate != null){
           query += 'and ' + createdDate +' < :toCreatedDate ';
        }
      return query;
    }

    public static String addStatusFilterInQuery(string query, String status)
    {
      if(requestStatus != null && requestStatus.size() > 0 ){
          query += ' and  ' + status + ' In :requestStatus ';
      }
      else if(tpaStatusToExclude != null)
          query += ' and ' + status + ' Not In :tpaStatusToExclude ';
      return query;
    }
    
    public string getRequestLocations()
    {
        List<string> requestedData = new List<string>();
        for(string buObj: reportBUsMapping.keySet())
        {
            requestedData.add('BU - ' + buObj);
        }
        requestedData.add('-- Business Units --');

        Schema.DescribeFieldResult fieldResult = TPA_Request__c.Client_Contact_Territory__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry f : ple)
        {
            requestedData.add(f.getLabel());
        }
        requestedData.add('-- Countries --');
        return JSON.serialize(requestedData);
    }

    public string getCategory()
    {
        List<string> dashboardCategory = new List<string>{'TPA Requests by Manual Trigger ',
        'TPA Requests by Month','TPA Requests by Month in Manual/Auto',
         'TPA Top ' + reportDashboardSettingMap.get('Top N Records in DB') + ' Vendors',
          'TPA Top ' + reportDashboardSettingMap.get('Top N Records in DB') + ' Small Clients - no parent record',
          'TPA Top ' + reportDashboardSettingMap.get('Top N Records in DB') + ' Large Clients - aggregated to parent level',
          'TPA Top ' + reportDashboardSettingMap.get('Top N Records in DB') + ' Uses' ,
          'TPA Top ' + reportDashboardSettingMap.get('Top N Records in DB') + ' Primary Offerings',
          'TPA Top ' + reportDashboardSettingMap.get('Top N Records in DB') + ' Countries' ,
          'Top ' + reportDashboardSettingMap.get('Top N Records in DB') + ' Offerings' };

        return JSON.serialize(dashboardCategory);
    }

    public string getRequestStatuses()
    {
        List<string> requestedData = new List<string>();
        Schema.DescribeFieldResult fieldResult = TPA_Request__c.Request_Status__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry f : ple){
            requestedData.add(f.getLabel());
        }
        Set<String> setStatuses = new Set<String>(requestedData);
        setStatuses.removeAll(tpaStatusToExclude);
        return JSON.serialize(setStatuses);
    }
    
    public static Date parseDate(String inDate) {
        Date dateRes = null;
        //1 - Try locale specific mm/dd/yyyy or dd/mm/yyyy    
        try {
            String candDate = inDate.substring(0,Math.min(10,inDate.length())); // grab date portion only m[m]/d[d]/yyyy, ignore time
            //dateRes = Date.parse(candDate);
            dateRes = Date.newInstance(Integer.valueOf(candDate.split('/')[2]),Integer.valueOf(candDate.split('/')[0]),Integer.valueOf(candDate.split('/')[1]));
        }
        catch (Exception e) {
            UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, UTL_LogFactory.GUID, e.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + e.getLineNumber() + ':::CNT_TPA_CustomReportDashboard.parseDate:::in update records', ''));
            UTL_LogFactory.saveLogs(UTL_LogFactory.getLogLst(), TRUE);
        }
    
        if (dateRes == null) {
        //2 - Try yyyy-mm-dd          
            try {
                String candDate = inDate.substring(0,10); // grab date portion only, ignore time, if any
                //dateRes = Date.valueOf(candDate);
                dateRes = Date.newInstance(Integer.valueOf(candDate.split('/')[2]),Integer.valueOf(candDate.split('/')[0]),Integer.valueOf(candDate.split('/')[1]));
            }
            catch (Exception ex) {
                UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, UTL_LogFactory.GUID, ex.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + ex.getLineNumber() + ':::CNT_TPA_CustomReportDashboard.parseDate:::in update records', ''));
                UTL_LogFactory.saveLogs(UTL_LogFactory.getLogLst(), TRUE);
            } 
        }        
        return dateRes;
    }

    public class ReceivedValues
    {
        public string callType {get; set;}
        public string countryLocation {get; set;}
        public string countryLocationAccountMap {get; set;}
        public integer durationValue {get; set;}
        public String lstCategory {get; set;}
        public String reqStatus {get; set;}
        public String fromDateValue {get; set;}
        public String toDateValue {get; set;}
        public integer pageSize {get; set;}
    }

    global class ReturnValues
    {
        public List<sObject> manualReviewDbResult {get; set;}
        public List<sObject> requestByMonthDbResult {get; set;}
        public List<sObject> requestByManualAutoDbResult {get; set;}
        public List<sObject> requestTopVendorsDbResult {get; set;}
        public List<sObject> requestTopLargeClientsDbResult {get; set;}
        public List<sObject> requestTopSmallClientsDbResult {get; set;}
        public List<sObject> requestTopUsesDbResult {get; set;}
        public List<sObject> requestTopOfferingsDbResult {get; set;}
        public List<sObject> requestTopSecOfferingsDbResult {get; set;}
        public List<sObject> requestByCountries {get; set;}
        public List<sObject> primSecOfferingByCountries {get; set;}
    }
}