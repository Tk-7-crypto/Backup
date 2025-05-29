/*
 * Version       : 1.0
 * Description   : Apex Controller for LXC_CSM_PortalCreateCase Lightning component
 */
public without sharing class CNT_CSM_PortalCreateCase {
    /**
     * This method used to return List<AggregateResult> of  Product__r.Name Categorization fro a current user
     * @return  List<AggregateResult>
     */
    @AuraEnabled
    public static List<EXT_CSM_CheckboxDetails> getProductCategorizationForNewCase(String accountId,String recordType){
        List<Asset> assets =  new List<Asset>();
        List<Asset> assetsWithLimitedAccess =  new List<Asset>();
        List<AggregateResult> productList = new  List<AggregateResult>();
        List<EXT_CSM_CheckboxDetails> keyValues = new  List<EXT_CSM_CheckboxDetails>();
        EXT_CSM_CheckboxDetails obj=null;
        Map<String,String> c = new Map<String,String>();
        Map<String, Boolean> enableAllSubtypeMap = new Map<String,Boolean>();
        Map<String, Boolean> subtypeMandatoryMap = new Map<String,Boolean>();
        Map<String, Boolean> disableCSHP1CaseCreationMap = new Map<String,Boolean>();
        Map<String, Boolean> enableEscalationFormFieldsMap = new Map<String,Boolean>();
        Map<String, Boolean> attachmentMandatoryMap = new Map<String,Boolean>();
        String technoRecordTypeId = Case.sObjectType.getDescribe().getRecordTypeInfosByName().get(CON_CSM.S_TECHNOLOGY_R_T).getRecordTypeId();
        String dataRecordTypeId = Case.sObjectType.getDescribe().getRecordTypeInfosByName().get(CON_CSM.S_DATA_CASE_R_T).getRecordTypeId();
        try {
            List<User> users = new SLT_User().selectContactDetailByUser(new Set<Id> {userInfo.getUserId()}, new Set<String> {'Contact.Portal_Case_Type__c','Contact.Account.AccountCountry__c'});
            String contactId = users[0].ContactId;
           //Set<String> fieldSet = new Set<String> {'Id','Product2.Name', 'Product2.CSH_Enable_SubType123__c', 'CSH_EnableEscalationFormFields__c','CSH_Enable_SubType123__c', 'CSH_Sub_Type_mandatory__c', 'Disable_CSH_P1_Case_Creation__c'};
            String filterCondition ='';
            filterCondition = ' AccountId=\''+ accountId +'\' AND Status !=\'Obsolete\' AND Visible_in_CSH__c = true';
            String prodIds = '';
            List<Id> removeProd = new List<Id>();
            if(technoRecordTypeId == recordType || dataRecordTypeId == recordType) {
                List<CSM_QI_Data_Portal_Queue_User_details__c> dataList = new SLT_CSMDataPortalQueueUserdetails().getDataWithFilter(new Set<String> {'ProductId__c'},'ProductId__c != null AND Account__c=\''+ users[0].AccountId +'\' AND Type__c =\'Product Level Restriction\' AND ClientContact__c=\''+ users[0].ContactId +'\'');
                if(dataList != null && !dataList.isEmpty()) {
                    for (Integer i=0; i<dataList.size(); i++) {
                        if(dataList[i].ProductId__c != null ) {
                            prodIds += '\''+ dataList[i].ProductId__c+'\',';
                        }
                    }
                    prodIds = prodIds.removeEnd(',');
                    filterCondition += ' AND Product2Id in ('+ prodIds +')';
                }else{
                    List<CSM_QI_Case_Categorization__c> prodDataList = new SLT_CaseCategorization().getProductLevelRestrict();
                    for(CSM_QI_Case_Categorization__c p : prodDataList) {
                        removeProd.add(p.Product__c);
                    }
                }
            }

            //products = new SLT_Asset().getAssetsWithFilter(fieldSet,filterCondition);
            assets = Database.query('select Id, Product2.Name, Product2.CSH_Enable_SubType123__c, CSH_EnableEscalationFormFields__c, CSH_Enable_SubType123__c, CSH_Sub_Type_mandatory__c, Disable_CSH_P1_Case_Creation__c, CSH_Attachment_mandatory__c from Asset where Id not in (select Asset__c from CSM_QI_Asset_Contact_Relationship__c where Asset__r.AccountId =:accountId and CSH_Limited_Access__c = true) and' + filterCondition);
            assetsWithLimitedAccess = Database.query('select Id, Product2.Name, Product2.CSH_Enable_SubType123__c, CSH_EnableEscalationFormFields__c, CSH_Enable_SubType123__c, CSH_Sub_Type_mandatory__c, Disable_CSH_P1_Case_Creation__c, CSH_Attachment_mandatory__c from Asset where Id in (select Asset__c from CSM_QI_Asset_Contact_Relationship__c where Asset__r.AccountId =:accountId and Contact__c = :contactId and CSH_Limited_Access__c = true ) and' + filterCondition);
            assets.addAll(assetsWithLimitedAccess);
            //users = new SLT_User().selectById(new Set<Id> {userInfo.getUserId()});
            //products = new SLT_Asset().selectByAccountId(new Set<Id> {accountId});
            for (Asset ast : assets) {
                Boolean enableAllSubtype = ast.Product2.CSH_Enable_SubType123__c ? ast.Product2.CSH_Enable_SubType123__c : ast.CSH_Enable_SubType123__c;
                if(removeProd.isEmpty()) {
                    c.put(ast.Product2.Name,ast.Id);
                    enableAllSubtypeMap.put(ast.Product2.Name, enableAllSubtype);
                    subtypeMandatoryMap.put(ast.Product2.Name, ast.CSH_Sub_Type_mandatory__c);
                    disableCSHP1CaseCreationMap.put(ast.Product2.Name, ast.Disable_CSH_P1_Case_Creation__c);
                    enableEscalationFormFieldsMap.put(ast.Product2.Name, ast.CSH_EnableEscalationFormFields__c);
                    attachmentMandatoryMap.put(ast.Product2.Name, ast.CSH_Attachment_mandatory__c);
                }else if(!removeProd.isEmpty() && !removeProd.contains(ast.Product2Id)) {
                    c.put(ast.Product2.Name,ast.Id);
                    enableAllSubtypeMap.put(ast.Product2.Name, enableAllSubtype);
                    subtypeMandatoryMap.put(ast.Product2.Name, ast.CSH_Sub_Type_mandatory__c);
                    disableCSHP1CaseCreationMap.put(ast.Product2.Name, ast.Disable_CSH_P1_Case_Creation__c);
                    enableEscalationFormFieldsMap.put(ast.Product2.Name, ast.CSH_EnableEscalationFormFields__c);
                    attachmentMandatoryMap.put(ast.Product2.Name, ast.CSH_Attachment_mandatory__c);
                }
            }
            productList = new SLT_CaseCategorization().getProducts(c.keySet(),recordType);
            for(AggregateResult result : productList) {
                if(c.containsKey(String.valueOf(result.get('Name')))) {
                    obj = new EXT_CSM_CheckboxDetails(c.get(String.valueOf(result.get('Name'))),String.valueOf(result.get('Name')),false);
                    obj.enableSubtype_1_2_3 = (technoRecordTypeId == recordType && enableAllSubtypeMap.containsKey(String.valueOf(result.get('Name')))) ? enableAllSubtypeMap.get(String.valueOf(result.get('Name'))) : false;
                    obj.subtypeMandatory = (technoRecordTypeId == recordType && subtypeMandatoryMap.containsKey(String.valueOf(result.get('Name')))) ? subtypeMandatoryMap.get(String.valueOf(result.get('Name'))) : false;
                    obj.disableCSHP1CaseCreation = (technoRecordTypeId == recordType && disableCSHP1CaseCreationMap.containsKey(String.valueOf(result.get('Name')))) ? disableCSHP1CaseCreationMap.get(String.valueOf(result.get('Name'))) : false;
                    obj.enableEscalationForm = (technoRecordTypeId == recordType && enableEscalationFormFieldsMap.containsKey(String.valueOf(result.get('Name')))) ? enableEscalationFormFieldsMap.get(String.valueOf(result.get('Name'))) : false;
                    obj.attachmentMandatory = (attachmentMandatoryMap.containsKey(String.valueOf(result.get('Name')))) ? attachmentMandatoryMap.get(String.valueOf(result.get('Name'))) : false;
                    keyValues.add(obj);
                }
            }
            return keyValues;
        } catch(Exception ex) {
            ApexPages.addMessages(ex);
            throw new AuraHandledException(JSON.serialize(ex));
        }
    }

    /**
     * This method used to return List<AggregateResult> of  SubType1__c Categorization by given productName
     * @params  String productName
     * @return  List<AggregateResult>
     */
    @AuraEnabled
    public static List<AggregateResult> getSubtypeCategorization(String productName, String origin){
        List<AggregateResult> subtypeList = new  List<AggregateResult>();
        try {
            // PEP-ACN added new param to distinguish PEP subtypes from CSH
            if(origin == CON_PEP.S_PARTNER_PORTAL) {
                subtypeList = new SLT_CaseCategorization().getPEPSubTypeByProductName(productName);
            }else{
                subtypeList = new SLT_CaseCategorization().getCSHSubTypeByProductName(productName);
            }
            return subtypeList;
        } catch(Exception ex) {
            ApexPages.addMessages(ex);
            throw new AuraHandledException(JSON.serialize(ex));
        }
    }

    @AuraEnabled
    public static List<CSM_QI_Case_Categorization__c> getCategorization(String productName,String cshSubtype){
        List<CSM_QI_Case_Categorization__c> categorizations= new List<CSM_QI_Case_Categorization__c>();
        if(cshSubtype != null && !'Please Specify'.equalsIgnoreCase(cshSubtype)) {
            categorizations = new SLT_CaseCategorization().getCaseCategorizationByFilter('Product__r.Name=\''+productName+'\' and CSHSubType__c=\''+cshSubtype+'\'');
        }else{
            categorizations = new SLT_CaseCategorization().getCaseCategorizationByFilter('Product__r.Name=\''+productName+'\' and SubType1__c=\'Please Specify\'');
        }

        return categorizations;
    }

    @AuraEnabled
    public static List<CSM_QI_Case_Categorization__c> getCategorizationForDataGlobalSupport(String productName, String recordTypeId){
        List<CSM_QI_Case_Categorization__c> categorizations= new List<CSM_QI_Case_Categorization__c>();
        categorizations = new SLT_CaseCategorization().getCaseCategorizationByFilter('Product__r.Name=\''+productName+'\' and SubType1__c!=\'Please Specify\' and Pillar__c=\'Information Offering\' and RecordTypeId__c=\''+ recordTypeId + '\' and Type__c =\'Categorization\' and Active__c = true');
        return categorizations;
    }

    @AuraEnabled
    public static List<Asset> getAssetByProductId(String productId,String accountId){
        List<Asset> assets=new List<Asset>();
        assets = new SLT_Asset().selectByAccountIdAndProductId(new Set<Id> {accountId},new Set<Id> {productId});
        return assets;
    }

    @AuraEnabled
    public static List<Account> getUserAccount(){
        List<User> users = new List<User>();
        users = new SLT_User().selectById(new Set<Id> {userInfo.getUserId()});
        List<Account> accounts=new List<Account>();
        accounts = new SLT_Account().selectById(new Set<Id> {users[0].AccountId});
        return accounts;
    }

    @AuraEnabled(cacheable=true)
    public static List<Contact> getUserContact(){
        List<User> users = new List<User>();
        users = new SLT_User().selectById(new Set<Id> {userInfo.getUserId()});
        List<Contact> contacts=new List<Contact>();
        Set<string> contactDetailsSet= new Set<string>();
        contactDetailsSet.Add('AccountId');
        contactDetailsSet.Add('Country__c');
        contactDetailsSet.Add('Portal_Case_Type__c');
        contactDetailsSet.Add('Contact_User_Type__c');
        if(users[0].ContactId!=null)
        {
            contacts = new SLT_Contact().selectByContactIdList(new Set<Id> {users[0].ContactId}, contactDetailsSet);
        }
        return contacts;
    }

    @AuraEnabled
    public static List<String> getPickListOptions(String fld){
        List<String> options =  new List<String>();
        Schema.DescribeFieldResult fieldResult = Schema.getGlobalDescribe().get('Case').getDescribe().fields.getMap().get(fld).getDescribe();
        List<Schema.picklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.picklistEntry f:ple)
        {
            options.add(f.getValue());
        }
        return options;
    }

    @AuraEnabled
    public static List<EXT_CSM_CheckboxDetails> getPickListOptionValues(String fld){
        List<EXT_CSM_CheckboxDetails> options = new List<EXT_CSM_CheckboxDetails>();
        Schema.DescribeFieldResult fieldResult = Schema.getGlobalDescribe().get('Case').getDescribe().fields.getMap().get(fld).getDescribe();
        List<Schema.picklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.picklistEntry f:ple)
        {
            options.add(new EXT_CSM_CheckboxDetails(f.getValue(), f.getLabel(),f.isActive()));
        }
        return options;
    }
    
    @AuraEnabled
    public static List<Asset> getUserAssetsForDATA2(List<String> names){
        List<User> users = new List<User>();
        users = new SLT_User().selectById(new Set<Id> {userInfo.getUserId()});
        List<Asset> assets=new List<Asset>();
        String filter='Name in(';
        for( Integer i=0; i<names.size(); i++) {
            filter+='\''+names[i]+ '\'';
            if (i != names.size()-1) {
                filter+=',';
            }
        }
        filter+=')';
        filter+=' AND AccountId = \''+users[0].AccountId + '\'';
        assets = new SLT_Asset().getAssetsWithFilter(new Set<String> {'Id','Name'}, filter);
        return assets;
    }

    @AuraEnabled
    public static List<string> getpriorityvalue(){
        List<string> picList= getPickListOptions('Priority');
        return picList;
    }

    @AuraEnabled
    public static List<string> getUrgencyList(){
        List<string> picList= getPickListOptions('Urgency__c');
        return picList;
    }

    @AuraEnabled
    public static List<string> getImpactList(){
        List<string> picList= getPickListOptions('Techno_Impact__c');
        return picList;
    }

    @AuraEnabled
    public static List<string> getEnvironmentList(){
        List<string> picList= getPickListOptions('EnvironmentType__c');
        return picList;
    }

    @AuraEnabled
    public static List<EXT_CSM_CheckboxDetails> getCountryRequesterList(){
        return getPickListOptionValues('Country_of_the_requester2__c');
    }

    @AuraEnabled
    public static List<AggregateResult> getCategorizationWithAggregate(String q){
        try {
            return new SLT_CaseCategorization().selectWithAggregate(q);
        } catch(Exception ex) {
            ApexPages.addMessages(ex);
            throw new AuraHandledException(JSON.serialize(ex));
        }
    }

    public class WRP_CSM_SearchResult {
        @AuraEnabled
        public String id {get; set;}
        @AuraEnabled
        public SObject sobj {get; set;}
    }
    @AuraEnabled
    public static List<WRP_CSM_SearchResult> searchForIds(String searchText, String productName) {
        List<User> users = new List<User>();
        List<WRP_CSM_SearchResult> srList = new List<WRP_CSM_SearchResult>();
        if(UserInfo.getUserType().contains(CON_CSM.S_CUSTOMER_SUCCCESS)) {
            users = new SLT_User().selectContactDetailByUser(new Set<Id> {userInfo.getUserId()}, new Set<String>  {'Contact.Portal_Case_Type__c','Contact.Contact_User_Type__c','AccountId','Contact.KB_Location__c'});
            if (users.size() > 0 && users[0].Contact != null && users[0].AccountId != null) {
                String pillar = users[0].Contact.Portal_Case_Type__c;
                pillar = '\'' + pillar.replace(';','\',\'') +'\'';
                String userType = users[0].Contact.Contact_User_Type__c;
                Set<String> ids = new Set<String>();
                List<asset> assets = new SLT_Asset().getAssetsWithFilter(new Set<String> {'Product2Id'}, 'AccountId=\''+ users[0].AccountId +'\' AND Status !=\'Obsolete\' AND Product2Id !=\'\'');
                for (Integer i=0; i<assets.size(); i++) {
                    ids.add(assets[i].Product2Id);
                }
                String contact_role_conditions = '';
                if (userType == 'Rep User') {
                    contact_role_conditions ='(Contact_Role__c = \'\' or Contact_Role__c = \'Rep User\') AND ';
                }
                String KB_Location = users[0].Contact.KB_Location__c;
                String location_condition = '';
                if (KB_Location != null) {
                    KB_Location = '\'' + KB_Location.replace(';','\',\'') +'\'';
                    location_condition = ' OR Location__r.Location__c  in ('+ KB_Location +')';
                }
                String q1 = 'FIND :searchText IN ALL FIELDS RETURNING Knowledge__kav(Id, ArticleNumber, Title, LastPublishedDate, ProductName__c, SubType1__c, SubType2__c, SubType3__c, UrlName, Contact_Role__c WHERE ProductName__c = :productName AND Product__c in :ids AND Pillar__c in (' + pillar + ') AND PublishStatus =\'Online\' AND Language = \'en_US\' AND IsVisibleInCsp = true AND ' + contact_role_conditions + 'Id in (select Knowledge__c from Knowledge_Account_RelationShip__c where Account__c =\''+ users[0].AccountId +'\' AND (Location__c = \'\' ' + location_condition + ' )) LIMIT 10)';
                List<List<SObject> > results1 =  search.query(q1);
                String q2 = 'FIND :searchText IN ALL FIELDS RETURNING Knowledge__kav(Id, ArticleNumber, Title, LastPublishedDate, ProductName__c, SubType1__c, SubType2__c, SubType3__c, UrlName, Contact_Role__c WHERE ProductName__c = :productName AND Product__c in :ids AND Pillar__c in (' + pillar + ') AND PublishStatus =\'Online\' AND Language = \'en_US\' AND IsVisibleInCsp = true AND '+ contact_role_conditions + 'Id NOT in (select Knowledge__c from Knowledge_Account_RelationShip__c) LIMIT 10 )';
                List<List<SObject> > results2 =  search.query(q2);
                List<List<SObject> > results = new List<List<SObject> >();
                results.addAll(results1);
                results.addAll(results2);

                for (List<SObject> sobjs : results) {
                    for (SObject sobj : sobjs) {
                        WRP_CSM_SearchResult sr = new WRP_CSM_SearchResult();
                        sr.id = sobj.Id;
                        sr.sobj = sobj;
                        srList.add(sr);
                    }
                }
            }
        }
        return srList;
    }
    public static List<Messaging.SingleEmailMessage> dataSendEmailList;
    @AuraEnabled
    @SuppressWarnings('PMD.AvoidDebugStatements')
    public static void sendAttachmentEmailToCaseOriginator(String caseId) {
        //Map<ID,Schema.RecordTypeInfo> rt_Map = Case.sObjectType.getDescribe().getRecordTypeInfosById();
        List<Case> caseList = new SLT_Case().selectByCaseIdList(new Set<Id> {caseId}, new Set<String> {'CSM_QI_Data_Originator__c', 'recordTypeID', 'Id', 'Origin', 'ContactId'});
        Case caseRecord = (caseList != null && caseList.size() > 0) ? caseList[0] : null;
        //Map<Id,Id> userList = new Map<Id,Id>();
        Map<Id,Id> queueList = new Map<Id,Id>();
        List<String> toAddresses = new List<String>();
        if (caseRecord != null) {
            if(caseRecord.CSM_QI_Data_Originator__c != null && (caseRecord.CSM_QI_Data_Originator__c.startsWith(CON_CSM.S_QUEUE_ID) || caseRecord.CSM_QI_Data_Originator__c.startsWith('005'))
               && caseRecord.RecordTypeName__c == CON_CSM.S_DATACASE &&
               UserInfo.getUserType().contains('CustomerSuccess')) {
                queueList.put(caseRecord.CSM_QI_Data_Originator__c, caseRecord.Id);
            }
            List<Queue_User_Relationship__c> queueUser = null;
            if(!queueList.isEmpty()) {
                queueUser = new SLT_QueueUserRelationshipC().selectByCSHUserorGroupSet(queueList.keySet());
            }

            if(queueUser != null && !queueUser.isEmpty()) {
                Pattern patt = Pattern.compile(CON_CSM.S_EMAIL_REGEXP);
                Matcher match = null;
                String emailId,queueemailId;
                for (Queue_User_Relationship__c c : queueUser) {
                    if(CON_CSM.S_QUEUE == c.Type__c && c.Queue_Email__c != null) {
                        emailId = c.Queue_Email__c;
                        queueemailId = c.Queue_Email__c;
                        break;
                    }else{
                        emailId = c.User_Email__c;
                    }
                    if(emailId != null) {
                        match = patt.matcher(emailId.trim());
                    }
                    if(match != null && match.matches()) {
                        toAddresses.add(emailId);
                    }
                }
                if(queueemailId != null) {
                    toAddresses.clear();
                    toAddresses.add(queueemailId);
                }
            }
            if(!toAddresses.isEmpty()) {
                dataSendEmailList = new List<Messaging.SingleEmailMessage>();
                Messaging.SingleEmailMessage mailMessage = new Messaging.SingleEmailMessage();
                if(DAOH_Case.getCSMSettingData().get(CON_CSM.S_DEFAULT + CON_CSM.SPC_TILDE + CON_CSM.S_CAS_ET_CSM_ATTACHMENT_UPLOAD_NOTIFICATION) != null) {
                    mailMessage.setTemplateId(DAOH_Case.getCSMSettingData().get(CON_CSM.S_DEFAULT + CON_CSM.SPC_TILDE + CON_CSM.S_CAS_ET_CSM_ATTACHMENT_UPLOAD_NOTIFICATION).Component_Id__c);
                }
                String senderId = '';
                if(caseRecord.Origin == CON_CSM.S_CUSTOMER_PORTAL && DAOH_Case.getCSMSettingData().get(CON_CSM.S_CUSTOMER_PORTAL) != null) {
                    senderId = DAOH_Case.getCSMSettingData().get(CON_CSM.S_CUSTOMER_PORTAL).Component_Id__c;
                }
                else if(caseRecord.Origin == CON_CSM.S_AGENT_INITIATED && DAOH_Case.getCSMSettingData().get(CON_CSM.S_AGENT_INITIATED) != null) {
                    senderId = DAOH_Case.getCSMSettingData().get(CON_CSM.S_AGENT_INITIATED).Component_Id__c;
                }
                if(senderId != null && senderId.length() > 0) {
                    mailMessage.setOrgWideEmailAddressId(senderId);
                }
                mailMessage.setSaveAsActivity(false);
                mailMessage.setTargetObjectId(caseRecord.ContactId);
                mailMessage.setTreatTargetObjectAsRecipient(false);
                mailMessage.setToAddresses(toAddresses);
                mailMessage.setWhatId(caseRecord.Id);
                dataSendEmailList.add(mailMessage);
                if(dataSendEmailList != null && dataSendEmailList.size() > 0) {
                    try{
                        Messaging.sendEmail(dataSendEmailList);
                    }
                    catch(Exception ex) {
                        System.debug('Mail Exception: '+ex.getMessage());
                    }
                }
            }
        }
    }

    public class WRP_PRM_SearchResult {
        @AuraEnabled
        public String id {get; set;}
        @AuraEnabled
        public SObject sobj {get; set;}
    }
    @AuraEnabled
    public static List<WRP_PRM_SearchResult> searchForPRMIds(String searchText, String productName) {
        List<User> users = new List<User>();
        List<WRP_PRM_SearchResult> srList = new List<WRP_PRM_SearchResult>();
        users = new SLT_User().selectContactDetailByUser(new Set<Id> {userInfo.getUserId()}, new Set<String>  {'Contact.Portal_Case_Type__c','Contact.Partner_Type__c','AccountId'});
        Id accountId = users[0].AccountId;
        if (users.size() > 0 && users[0].Contact != null && users[0].AccountId != null) {
            Set<String> pillar = new Set<String>(users[0].Contact.Portal_Case_Type__c.split(';'));
            Set<String> ids = new Set<String>();
            List<asset> assets = new SLT_Asset().getAssetsWithFilter(new Set<String> {'Product2Id'}, 'AccountId=\''+ users[0].AccountId +'\' AND Status !=\'Obsolete\' AND Product2Id !=\'\'');
            for (Integer i=0; i<assets.size(); i++) {
                ids.add(assets[i].Product2Id);
            }
            List<List<SObject> > results = new SLT_Knowledge().getSearchResults(searchText, pillar, accountId, ids, productName);
            for (List<SObject> sobjs : results) {
                for (SObject sobj : sobjs) {
                    WRP_PRM_SearchResult sr = new WRP_PRM_SearchResult();
                    sr.id = sobj.Id;
                    sr.sobj = sobj;
                    srList.add(sr);
                }
            }
        }
        return srList;
    }

    @AuraEnabled
    public static List<CSM_QI_Case_Categorization__c> getCategorizationId (String productName,String subtype1,String subtype2,String subtype3){
        List<CSM_QI_Case_Categorization__c> categorizations= new List<CSM_QI_Case_Categorization__c>();
        categorizations = new SLT_CaseCategorization().getCaseCategorizationByFilter('Type__c = \'Categorization\' and ProductName__c=\''+productName+'\' and SubType1__c=\''+subtype1+'\' and SubType2__c=\''+subtype2+'\' and SubType3__c=\''+subtype3+'\'');
        return categorizations;
    }

    @AuraEnabled(cacheable=true)
    public static List<CSM_QI_Case_Categorization__c> getCategorizationIdByLos (String los,String subtype1,String subtype2,String subtype3){
        List<CSM_QI_Case_Categorization__c> categorizations= new List<CSM_QI_Case_Categorization__c>();
        categorizations = new SLT_CaseCategorization().getCaseCategorizationByFilter('Type__c = \'Categorization\' and Los__c=\''+los+'\' and SubType1__c=\''+subtype1+'\' and SubType2__c=\''+subtype2+'\' and SubType3__c=\''+subtype3+'\'');
        return categorizations;
    }
    
    public class WRP_CSM_EscalationFormFields {
        @AuraEnabled
        public String objName {get; set;}
        @AuraEnabled
        public String fieldName {get; set;}
        @AuraEnabled
        public List<EXT_CSM_CheckboxDetails> options {get; set;}
    }
    
    @AuraEnabled
    public static WRP_CSM_EscalationFormFields getObjectPickListOptionValues(String fldName,String fldAPI,String objectName){
        WRP_CSM_EscalationFormFields escField = new WRP_CSM_EscalationFormFields();
        List<EXT_CSM_CheckboxDetails> options = new List<EXT_CSM_CheckboxDetails>();
        Schema.DescribeFieldResult fieldResult = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap().get(fldAPI).getDescribe();
        List<Schema.picklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.picklistEntry f:ple)
        {
            options.add(new EXT_CSM_CheckboxDetails(f.getValue(), f.getLabel(),f.isActive()));
        }
        escField.objName = objectName;
        escField.fieldName = fldName;
        escField.options = options;
        return escField;
    }
    
    @AuraEnabled
    public static List<WRP_CSM_EscalationFormFields> getEscalationFormFields (){
        List<WRP_CSM_EscalationFormFields> escFields = new List<WRP_CSM_EscalationFormFields>();
        escFields.add(getObjectPickListOptionValues('device','Device__c','Case'));
        escFields.add(getObjectPickListOptionValues('onlineorAppVersion','Online_or_AppVersion__c','CSM_Technology_Solutions_Form__c'));
        escFields.add(getObjectPickListOptionValues('browserUsed','Browser_Used__c','CSM_Technology_Solutions_Form__c'));
        return escFields;
    }
    
    @AuraEnabled
    public static List<CSM_QI_Case_Categorization__c> getAffectsVersionList (String productName){
        List<CSM_QI_Case_Categorization__c> categorizations= new List<CSM_QI_Case_Categorization__c>();
        categorizations = new SLT_CaseCategorization().getCaseCategorizationByFilter('Type__c = \'Affects Version\' and Active__c = true and ProductName__c=\''+productName+'\'');
        return categorizations;
    }
    
    @AuraEnabled
    public static void saveTechnologySolutionsForm(String caseId,String onlineorAppVersion,String browserUsed,String iOSVersion,String noUsersImpacted, String username){
        CSM_Technology_Solutions_Form__c tsf = new CSM_Technology_Solutions_Form__c(Case__c = caseId, Form_Type__c = 'T2toT3 Escalation',Online_or_AppVersion__c = onlineorAppVersion, Browser_Used__c = browserUsed, iOS_VERSION__c = iOSVersion, Number_Of_End_Users_Impacted_alpha__c = noUsersImpacted ,User_login__c = username);
        insert tsf;
    }

    @AuraEnabled(cacheable=false)
    public static void deleteContentDocument(String contentDocumentId) {
        try {
            delete new ContentDocument(Id = contentDocumentId);
        } catch(Exception e) {
            throw new AuraHandledException('Error deleting ContentDocument: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static void createContentDocumentLink(List<Id> contentDocumentIds, Id parentId) {
        List<ContentDocumentLink> linksToInsert = new List<ContentDocumentLink>();
        for(Id contentDocumentId : contentDocumentIds) {
            ContentDocumentLink link = new ContentDocumentLink();
            link.ContentDocumentId = contentDocumentId;
            link.LinkedEntityId = parentId;
            link.ShareType = 'V'; 
            link.Visibility = 'AllUsers';
            linksToInsert.add(link);
        }
        insert linksToInsert;
    }

    @AuraEnabled(cacheable=true)
    public static List<Study__c> getAllowedStories() {
        return [SELECT Id, Name FROM Study__c WHERE Study_Visible_in_CSH__c = true];
    }

    @AuraEnabled
    public static Id createCase(Map<String, Object> fields, List<Id> contentDocumentIds) {
        Case caseRecord = new Case();
        for (String field : fields.keySet()) {
            caseRecord.put(field, fields.get(field));
        }
        try {
            insert caseRecord;
            if (contentDocumentIds != null && !contentDocumentIds.isEmpty()) {
                createContentDocumentLink(contentDocumentIds, caseRecord.Id);
            }
            return caseRecord.Id;
        } catch (Exception e) {
            throw new AuraHandledException('Error creating case: ' + e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static String getStaticResourceUrl(String name) {
        String resourceUrl = '';
        List<StaticResource> resources = [SELECT Name, SystemModstamp FROM StaticResource WHERE Name = :name LIMIT 1];
        if (!resources.isEmpty()) {
            String resourceId = String.valueOf(resources[0].SystemModstamp.getTime());
            resourceUrl = '/resource/' + resourceId + '/' + resources[0].Name;
        }
        return resourceUrl;
    }
    
}
