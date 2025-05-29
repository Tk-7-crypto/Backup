global without sharing class EXT_TPA_CustomLandingPage {
    public string timePeriod{get;set;}

    
    public List<SelectOption> getDuration() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('--Select--','--Select--'));
        options.add(new SelectOption('30-Days','30-Days'));
        options.add(new SelectOption('60-Days','60-Days'));
        return options;
    }
    
    public class DateRequestsWrapper {
        public List<TPA_Request__c> lstRequest;
        public Map<Id,String> createdDateMap;
    }
    public Transient List<TPA_Request__c> lstPortalRequests = new List<TPA_Request__c>();
    public static Id userId;
    //public static Id accId;
    public static List<String> addressIds = new List<String>();
    public static List<String> idsOfQueues = new List<String>();
    public static List<String> pendingReqStatuses = new List<String> {
        'Awaiting Vendor Submission',
        'Awaiting Vendor Signature',
        'Awaiting Client Modification',
        UTL_TPA.AWAITING_CLIENT_CONFIRMATION,
        'Awaiting Account Mgmt Communication',
        'Client Draft',
        'Hold for TPA non-compliance',
        'In Auto Approval Process',
        'Initializing Vendor',
        'In Review By IQVIA',
        'Pending Cancellation',
        'Pending IQVIA Review of Voided Envelope',
        'Pending Vendor AMA Fee Acknowledgement',
        'Pending - Vendor Declined AMA Fees',
        'Pending Vendor Response on Data Destruction from Prior TPAs',
        'Awaiting Final Review',
        'TPA Approved Awaiting AMA Approval'
    };
    public Transient String strPortalRequests{get;set;}
    public Transient Map<Id,String> createDateMap = new Map<Id,String>();
    public Transient String strDateMap{get;set;}
    public boolean isMessageShow { get; set; }
    public boolean isTPAPermanentDown { get; set; }
    public String title { get; set; }
    public String Message { 
        get{
            String content = [Select Content__c from TPA_Text_Editor__c where Page_Title__c = 'Shutdown Message' AND Is_Active__c = true][0].Content__c;
            if(Message == null && content != null){
                Message = content;
            }else if(content == null){
                Message = Label.TPA_Downtime_Message;
            }
            return Message;
        }
        set; 
    }
    public boolean isRestrictedUser { get; set; }
    public boolean TPA_Is_Show_TPA_Down_Message {get;set;}
    public static string isQaTesting {get; set;}
    public boolean isClientFromUS {get; set;}
    public String lastSelectedLanguage {get; set;}

    //Added for site to community logic submission start
    public static Boolean isVendorUser {
        get {
            if(UTL_TPA.getVendorProfileMap().get(userinfo.getProfileid()) != null 
               && UTL_TPA.getVendorProfileMap().get(userinfo.getProfileid()).Name == 'TPA Vendor Community User') {
                return true;
            }
            return false;
        }
        set;
    }

    @remoteAction
    public static Boolean isVendorUserProp() {
        return isVendorUser;
    }
    //Added for site to community logic submission end
    
    private string msgBoardContentPrivate;
    public String msgBoardContent {
        get{
            msgBoardContentPrivate = '';
            List<TPA_Text_Editor__c> editorDataList = SLT_TPATextEditor.instance.getTPATextEditorDataById(TPA_Settings__c.getOrgDefaults().ClientMessageBoardId__c);
            if(editorDataList != null && editorDataList.size() ==1)
                msgBoardContentPrivate = editorDataList[0].get(supportedLanguageMap.get(language).split('~')[1]) != null ? String.valueOf(editorDataList[0].get(supportedLanguageMap.get(language).split('~')[1])) : String.valueOf(editorDataList[0].Content__c);
            return msgBoardContentPrivate;
        }
        public set;
    }
    private static User CurrentUser = UTL_TPA_Multilingual.CurrentUser;
    private String communityUrl = UTL_TPA.TPA_COMMUNIYTURL;
    
    public String listName {
        get;
        set {
            listName = value;
            Database.QueryLocator queryLocator = SLT_TPARequest.instance.queryLocatorTPARequest(1);
            ApexPages.StandardSetController ssc = new ApexPages.StandardSetController(queryLocator);
            List<SelectOption> allViews = ssc.getListViewOptions();
            for (SelectOption so : allViews) {
                if (so.getLabel() == listName) {
                    listId = so.getValue().substring(0,15);
                    break;
                } else {
                    listId = null;
                }
            }             
        }      
    }
    
    public TPA_Request__c tpaRequest {get; set;}
    
    //Multilanguage starts
    public static String language {get; set;}
    //public String languageForComponent {get; set;}
    public static Map<String, String> supportedLanguageMap {
        get{
            if(supportedLanguageMap == null){
                supportedLanguageMap = new Map<String, String>();
                for(TPA_Multilingual_Template_Setting__c langFC :UTL_TPA_Multilingual.multiLingualTemplateSettings){
                    if(langFC.Label__c == 'SupportedLanguageCodeFieldMap' && langFC.Translated_Template_Name__c != null)
                        supportedLanguageMap.put(langFC.Translated_Template_Name__c.split('=')[0], langFC.Translated_Template_Name__c.split('=')[1]);
                }
            }
            return supportedLanguageMap;
        }
        set;
    }
    public string getLanguageMap()
    {
        return JSON.serialize(supportedLanguageMap);
    }
    public Map<String, List<TPA_Language_Cross_Walk__c>> multilanguageUtilityMap {get; set;}
    public string getTranslatedMap()
    {
        string selectedLangFieldApi = supportedLanguageMap.get(language).split('~')[1];
        return JSON.serialize(UTL_TPA_Multilingual.getTranslatedValueMap(new set<string>{selectedLangFieldApi}));
    }
    //Multilanguage ends
  
    public String listId {get;set;}
    
    public string viewName
    {
       get {
          if(viewName == null)
              viewName = Label.TPA_Third_Party_Access_Portal;
          return viewName;
       }
       set {
          viewName = value;
       }
    }    
    
    public EXT_TPA_CustomLandingPage(ApexPages.StandardController stdController) {
        this();

        try {
        
        } catch (Exception ex) {
            system.debug(LoggingLevel.INFO, 'ERROR: ' + ex.getMessage());
        }
    }
    
    public EXT_TPA_CustomLandingPage()
    {
        if(isVendorUser) {
            return;
        }
        tpaRequest = new TPA_Request__c();
        
        language = UTL_TPA_Multilingual.getLanguage();
        //languageForComponent = language;
        system.debug('####language: '+language);
        
        if( Date.today() >= UTL_TPA.restrictionDaterForMaintenance )
        {
            isRestrictedUser = true;
        }
        
        isMessageShow = UTL_TPA.isMessageShow;
        isTPAPermanentDown =  UTL_TPA.isTPAPermanentDown;
        
        title = Label.TPA_Custom_Landing_Page_Title;
        //Message = Label.TPA_Downtime_Message;
        
        if(CurrentUser != null)
        {
            TPA_Is_Show_TPA_Down_Message = CurrentUser.TPA_Is_Show_TPA_Down_Message__c;
            
            String restrictedUserIds = Label.TPA_Non_Restricted_Users;
            String currentUserId = String.valueOf(CurrentUser.Id).subString( 0, 15 );
            system.debug('restrictedUserIds:::'+restrictedUserIds.contains( currentUserId ));
            if(currentUserId != null && currentUserId.length() > 14){
            if( restrictedUserIds.contains( currentUserId )){
                isRestrictedUser = false; 
            }
            else if(isTPAPermanentDown){
                isRestrictedUser = true;
            }
            }
            isQaTesting = ApexPages.currentPage().getParameters().get('isQaTesting');
            if(isTPAPermanentDown == true && isQaTesting == 'true'){
                isTPAPermanentDown=false;
                isRestrictedUser = false;
                
            }
            else if (isTPAPermanentDown == true){
                isMessageShow = UTL_TPA.isMessageShow;
                isTPAPermanentDown =  UTL_TPA.isTPAPermanentDown;
                isRestrictedUser = true;
                
                title = Label.TPA_Custom_Landing_Page_Title;
                //Message = Label.TPA_Downtime_Message;
                TPA_Is_Show_TPA_Down_Message = CurrentUser.TPA_Is_Show_TPA_Down_Message__c;
            }
               
            String accTerritory = null;
            if(CurrentUser.Contact != null && CurrentUser.Contact.Account != null){
                accTerritory = CurrentUser.Contact.Account.Region_Territory__c != null ? CurrentUser.Contact.Account.Region_Territory__c : CurrentUser.Contact.Account.AccountCountry__c;
            }

            if(accTerritory != null && accTerritory != ''){
                Set<String> USACountryCode =  UTL_TPA_Multilingual.getCountryStateCodeSet('C', 'USA');
                system.debug('####TPA_Custom_Landing_Page_controller_Multi USACountryCode: '+USACountryCode);
                if(USACountryCode != null && USACountryCode.size() > 0){
                    isClientFromUS = USACountryCode.contains(accTerritory.toLowerCase()) ? true : false;
                    
                    /*Cookie ckExtUsrAction = ApexPages.currentPage().getCookies().get('extUserActionVal');
                    system.debug('ckExtUsrAction0:::'+ckExtUsrAction);
                    if(ckExtUsrAction != null && !String.isEmpty(ckExtUsrAction.getValue()))
                    {
                        Map<string, string> usrActionParamMap = new Map<string, string>();
                        for(string parObj: ckExtUsrAction.getValue().split('&'))
                        {
                            if((parObj.split('=')).size() == 2)
                                usrActionParamMap.put(parObj.split('=')[0], parObj.split('=')[1]);
                        }
                        if(usrActionParamMap.get('extAction') == 'ExtNewReq' || usrActionParamMap.get('extAction') == 'ExtLogin')
                            isClientFromUS = true;
                    }
                    ApexPages.currentPage().setCookies(new System.Cookie[] { new System.Cookie('extUserActionVal', null, null, 0, false) });
                    ApexPages.currentPage().getCookies().put('extUserActionVal', null);
                    ckExtUsrAction = null;*/	
                    String actionType = ApexPages.currentPage().getParameters().get('extAction');	
                    if(!String.isEmpty(actionType) && actionType == 'ExtLogin') {	
                        isClientFromUS = true;	
                    }
                    
                    system.debug('####TPA_Custom_Landing_Page_controller_Multi isClientFromUS: '+isClientFromUS);
                    if(isClientFromUS){
                        language = 'en_US';
                        //languageForComponent = language;
                    }else{
                        lastSelectedLanguage = ApexPages.currentPage().getParameters().get('lastSelectedLanguage');
                        system.debug('####TPA_Custom_Landing_Page_controller_Multi lastSelectedLanguage before: '+lastSelectedLanguage);
                        if(CurrentUser.Contact != null && CurrentUser.Contact.TPA_Last_Selected_Language__c != null && lastSelectedLanguage != 'changeme'){
                            lastSelectedLanguage = CurrentUser.Contact.TPA_Last_Selected_Language__c;
                            String languageCode =  UTL_TPA_Multilingual.supportedLanguageCodeMap.get(CurrentUser.Contact.TPA_Last_Selected_Language__c);
                            system.debug('####TPA_Custom_Landing_Page_controller_Multi languageCode: '+languageCode);
                            language = languageCode;
                            //languageForComponent = language;
                        }
                        system.debug('####TPA_Custom_Landing_Page_controller_Multi lastSelectedLanguage after: '+lastSelectedLanguage);
                    }
                }
            }
        }
    }
    
    public PageReference setView()
    {
        if(tpaRequest.Status_View_of_Requests__c != 'All' && timePeriod == '--Select--') {
            viewName = tpaRequest.Status_View_of_Requests__c;
        }
        else {
            viewName = Label.TPA_Third_Party_Access_Portal;
        }
            
        String query = getTPAQuery()+  ' Limit 10000';
        setTPARequest = new ApexPages.StandardSetController(SLT_TPARequest.instance.queryLocatorTPARequest(query));
        setTPARequest.setPageSize(pageSize);
        return null;
    }
    
    public PageReference refreshPage()
    {
        CurrentUser.TPA_Is_Show_TPA_Down_Message__c = true; 
        update CurrentUser; 
        system.debug('####refreshPage language: '+language);
        PageReference pageRef = new PageReference(communityUrl+'/VFP_TPA_CustomLandingPage'+(ApexPages.currentPage().getParameters().get('isLangOverride') != null ? ('?isLangOverride='+ApexPages.currentPage().getParameters().get('isLangOverride')):''));
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    public PageReference goBackToChangeLanguagePage()
    {
        PageReference pageRef = new PageReference(communityUrl+'/VFP_TPA_CustomLandingPage?lastSelectedLanguage=changeme');
        pageRef.setRedirect(true);
        return pageRef;
    }

    public static User currentLoggedInUser {
        get {
            if(currentLoggedInUser == null) {
                return UTL_TPA.getCurrentUserDetails();
            }
            else {
                return currentLoggedInUser;
            }
        }
        set;
    }
    
    public static string loggedUserProfileName {
        get {
            if(loggedUserProfileName == null) {
                loggedUserProfileName = currentLoggedInUser.Profile.Name;
            }
            return loggedUserProfileName;
        }
        set;
    }
    
    @remoteAction
    public static void updateLastSelectedLanguage(String selectedLang)
    {
        System.debug('isVendorUser:::'+isVendorUser);
        if(!isVendorUser) {
            system.debug('####updateLastSelectedLanguage: '+selectedLang);
            Contact c = CurrentUser.Contact;
            System.debug('###map is:::'+UTL_TPA_Multilingual.supportedLanguageCodeAndNameMap);
            System.debug('###map is:::'+UTL_TPA_Multilingual.supportedLanguageCodeAndNameMap.get(selectedLang));
            System.debug('c is:::'+c);
            if(c != null ) {
                c.TPA_Last_Selected_Language__c = UTL_TPA_Multilingual.supportedLanguageCodeAndNameMap.get(selectedLang);
                System.debug('contact is updatable-----------> ' + Schema.SObjectType.Contact.isupdateable());
                upsert c;
            }
        }        
    }

    public static Map<ID,String> getCreatedDateByZone(List<TPA_Request__c> lstRequest) {
        String userTimeZone = null;
        List<User> lstUser = [select id,TimeZoneSidKey from User where id =: userInfo.getUserId()];
        if(lstUser != null && lstUser.size() != 0)
            userTimeZone = lstUser[0].TimeZoneSidKey;
        Map<Id,String> mpTPAIdWithDate = new Map<Id,String>();
        for(Integer counter = 0;counter < lstRequest.size() ; counter++) {  
            String strConvertedDate = lstRequest[counter].CreatedDate.format('MM/dd/yyyy hh:mm a',userTimeZone);
            mpTPAIdWithDate.put(lstRequest[counter].id,strConvertedDate);
        }
        return mpTPAIdWithDate;
        
    }
    
    @remoteAction
    public static DateRequestsWrapper getTPARequestsByDate(String cDate)
    {
        DateRequestsWrapper objWrapper = new DateRequestsWrapper();
        List<TPA_Request__c> lstRequest = new List<TPA_Request__c>();
        String query = getQuery();
        cDate = (String)JSON.deserialize(cDate,String.class);
        if(cDate == '0')
            query += ' order by Id limit 2000';
        else
            query += ' and id > \'' + cDate + '\' order by Id limit 2000';
        System.debug('Query------------------> ' + query);
        lstRequest = Database.Query(query);
        //lstRequest = SLT_TPARequest.instance.getTPARequests(query);
        
        objWrapper.lstRequest = lstRequest;
        objWrapper.createdDateMap = getCreatedDateByZone(lstRequest);
        return objWrapper;
    }
    
    public static String getQuery(){
        String permissionSetName = '';
        Boolean isGlobalUser = false;              //ESPSFDCTPA-2402
        List<PermissionSetAssignment> lstcurrentUserPerSet = [SELECT Id, PermissionSet.Name,AssigneeId FROM PermissionSetAssignment WHERE AssigneeId = :Userinfo.getUserId() ];
        if(lstcurrentUserPerSet != null && lstcurrentUserPerSet.size() != 0)
            permissionSetName = lstcurrentUserPerSet[0].PermissionSet.Name;
        System.debug('Permission Set Name is :::'+permissionSetName);
        String query = 'select id,TPA_Name_New__c,name,Action__c,Client_Project_Name__c,request_status__c, Client_Address__c, Client_Address__r.Name,Agreement_Effective_Date_f__c,CreatedBy.Name,CreatedDate,Service_Provider_Address__r.name,Service_Provider_Contact_f__c,Service_Provider_f__c,Data_Access_End_Date__c from TPA_request__c';
        String profileName = UTL_TPA.getCurrentUserProfileInfo().Name;
        
        userId = UserInfo.getUserId();
        //accId = null;
        String contactId = null;
        List<User> lstUser = [select id,contact.id, Contact.AccountId from User where id =: UserInfo.getUserId()];
        if(lstUser != null && lstUser.size() != 0)
            contactId = lstUser[0].contact.id;
        
        List<String> addIds = UTL_TPA.getAddressIds(contactId);
        if(addIds != null){
            addressIds.addAll(addIds);
        }
        
        List<String> queueIds = UTL_TPA.getIdsOfQueue();
        if(queueIds != null){
            idsOfQueues.addAll(queueIds);
        }
        List<Id> groupMemberId = UTL_TPA.getIdOfMembersOfGroup();       //ESPSFDCTPA-2402
        if(groupMemberId.contains(UserInfo.getUserId())){
            system.debug('user part of global group');
            isGlobalUser = true;
            query += ' where Request_Status__c in : pendingReqStatuses and Is_Submitted__c = true';
        }
        else if(permissionSetName == 'TPA_Admin' && !isGlobalUser)
        {
            query += ' where  Is_Submitted__c = true';
        }
        else if(profileName.indexof('Super User Profile') != -1) {
            query += ' where (Client_Company_Name_Address__c in : AddressIds  or ownerId = \'' + userId + '\')';
        }
        else if(profileName.indexOf('TPA Processor Profile') != -1) {
            query += ' where (TPA_Processor_Account_Address__c in : AddressIds or ownerId = \'' + userId + '\')';//Modified by Shaik under ESPSFDCTPA-229
        }
        else if(profileName.indexOf('US TP Processor Profile') != -1) {
            query += ' where (TPA_Processor_Account_Address__c in : AddressIds or ownerId = \'' + userId + '\')';//Modified by Shaik under ESPSFDCTPA-229  
        }
        else {
            query += ' where (Owner.Id in: idsOfQueues or ownerId = \'' + userId + '\')';
        }
        if(permissionSetName != 'TPA_Admin' && !isGlobalUser){
            query += ' and  Is_Submitted__c = true';
        }
        system.debug('query in search: ' + query);
        return query;
    }
    
    public List<TPA_Request__c> gettpaRequests(){
        return setTPARequest.getRecords();
    }
    
    public Integer pageSize {
        get {
            if(pageSize == null){
                pageSize = 15;
            }
            return pageSize;
        }
        set;
    }
    
    public Integer currentPageNo{
        get{
            currentPageNo = setTPARequest.getPageNumber();
            return currentPageNo;
        }
        set;
    }
    public Integer orderByField;
    public Integer noOfRecords;
    public PageReference settableSize(){
        System.debug('pageSize------->>' +pageSize);
        setTPARequest.setPageSize(pageSize);
        return null;
    }
    
    public Integer totalNoOfRec{
        get{
            totalNoOfRec = setTPARequest.getResultSize();
            return totalNoOfRec;
        }
        set;
    }
    
    public ApexPages.StandardSetController setTPARequest {
        get {
        	String query = getTPAQuery() + 'ORDER BY TPA_Name_New__c Desc Limit 10000';
            if(setTPARequest == null) {                
                setTPARequest = new ApexPages.StandardSetController(SLT_TPARequest.instance.queryLocatorTPARequest(query));
                setTPARequest.setPageSize(pageSize);  
                noOfRecords = setTPARequest.getResultSize();
            }            
            return setTPARequest;
        }
        set;
    }
    
    public String previousSortBy;
    public String sortBy{get;set;}
    public String query;
    public String sortOrder{get{
        if(sortOrder == null){
            sortOrder = 'ASC';
        }
        return sortOrder;
    } set;}
    
    public PageReference sortData(){
        
        query = getTPAQuery()+  ' Limit 10000';
        setTPARequest = new ApexPages.StandardSetController(SLT_TPARequest.instance.queryLocatorTPARequest(query));
        setTPARequest.setPageSize(pageSize);
        return null;
    }
    
    private String getTPAQuery(){
        language = UTL_TPA_Multilingual.getLanguage();
        String query = 'Select Id, Action__c, Name, Client_Project_Name__c, Request_Status__c, Client_Address__r.Name, Service_Provider_f__c, Service_Provider_Contact_f__c, Agreement_Effective_Date_f__c, Expiration_Date__c, CreatedBy.Name from TPA_Request__c ';
        if(timePeriod != null && timePeriod != '--Select--') {
            if(timePeriod == '30-Days'){
                query += 'where Request_Status__c = \'In Effect\' and Data_Access_End_Date__c = NEXT_N_DAYS:30';
            }
            else if(timePeriod == '60-Days'){
                query += 'where Request_Status__c = \'In Effect\' and Data_Access_End_Date__c = NEXT_N_DAYS:60';
            }
        }
        else if(viewName != null && viewName != Label.TPA_Third_Party_Access_Portal && (timePeriod == null || timePeriod == '--Select--')){
            query += 'where Request_Status__c = \'' + viewName + '\'';
        }
        if(sortBy != null && sortOrder != null){
            query += 'ORDER BY ' + sortBy + ' ' + sortOrder;
        }
        System.debug('query------------> ' + query);
        return query;
    }
    
    public PageReference refreshTPAPage(){
        PageReference pageRef = new PageReference(communityUrl+'/VFP_TPA_CustomLandingPage'+(ApexPages.currentPage().getParameters().get('isLangOverride') != null ? ('?isLangOverride='+ApexPages.currentPage().getParameters().get('isLangOverride')):''));//Modified by C.P.Pandey under ER-1940
        pageRef.setRedirect(true);
        return pageRef;
    }
}
