/**
 * @author: Babita Dadarwal
 */
public with sharing class SRV_CDA_CDARequest {

    //Public variables
    public static User logedInUser;
    public static CDA_Request__c cdaRecord;
    public static QI_Legal_Entity__c qiCustomerLegalEntityRecord;
    public static CDA_Approved_Governing_Law_Location__c governingLawRecord;    //Added by Vikram Singh under CR-11576
    public static Map <Id, CDA_Account__c> accountListMap;
    public static Map <String, CDA_Legal_POC_Cross_Walk__c> legalPOCListMap;
    public static Boolean isReminder = false;

    //Added by Vikram Singh under Issue-11681 Start
    public static String query {
        get {
            if(query == null) {
                query = 'SELECT id, CDA_Id__c, Name, CDA_Type__c, Status__c, QI_Legal_Entity_Name__r.Name, Recipient_Account__r.Name, QuintilesIMS_Business__c, ';
                query += 'Competitor_Flag__c, What_is_the_Study_Sponsor_situation__c, Recipient_Account_Address__c, Recipient_Point_of_Contact_Name__c, ';
                query += 'Recipient_Point_of_Contact_Telephone_Num__c, CDA_Effective_Date__c, Negotiator_Assigned_List__c, CreatedBy.Name, ';
                query += 'LastModifiedDate, Recipient_Account_Name_Formula__c, RecordTypeId, RecordType.Name ';
                query += 'FROM CDA_Request__c ';
                query += 'WHERE RecordType.Name != \'' + UTL_CDAUtility.historicalDataRecordType + '\'';

                if(getUserPermission().toLowerCase() == UTL_CDAUtility.REQUESTOR.toLowerCase() || getUserPermission().toLowerCase() == UTL_CDAUtility.REQUESTOR_ADMIN.toLowerCase()){   //Updated by Vikram Singh under CR-11764
                 query += ' AND ownerId = \''+UserInfo.getUserId()+'\'';  //Updated by Vikram Singh under CR-11691
                }
            }
            return query;
        }
        set{ query = value; }
    }

    public static Boolean isNegotiator {
        get {
            return (SRV_CDA_CDARequest.getUserPermission() == UTL_CDAUtility.NEGOTIATOR || SRV_CDA_CDARequest.getUserPermission() == UTL_CDAUtility.SYS_ADMIN);
        }
        set;
    }
    
    public static String setQueryCondition(String query, Map<String, String> searchMap, Boolean isNegotiatorTab) {
        if(query != null) {
            boolean isNegotiatorOwnerFilterApplicable = true;
            if(searchMap != null && searchMap.size() > 0) {
                if(searchMap.get('CDA_ID__c') != null && searchMap.get('CDA_ID__c') != '') {
                    query += ' AND CDA_Id__c LIKE \'%' + String.escapeSingleQuotes(searchMap.get('CDA_ID__c')) + '%\' ';
                    isNegotiatorOwnerFilterApplicable = isNegotiatorTab ? false : isNegotiatorOwnerFilterApplicable;
                }
                if(searchMap.get('QuintilesIMS_Business__c') != null
                   && searchMap.get('QuintilesIMS_Business__c') != ''
                   && String.escapeSingleQuotes(searchMap.get('QuintilesIMS_Business__c')) != '--None--') {
                    query += ' AND QuintilesIMS_Business__c = \'' + String.escapeSingleQuotes(searchMap.get('QuintilesIMS_Business__c')) + '\' ';
                }
                if(searchMap.get('CDA_Type__c') != null
                   && !String.isBlank(searchMap.get('CDA_Type__c'))
                   && String.escapeSingleQuotes(searchMap.get('CDA_Type__c')) != '--None--') {
                    query += ' AND CDA_Type__c = \'' + String.escapeSingleQuotes(searchMap.get('CDA_Type__c')) + '\' ';
                    isNegotiatorOwnerFilterApplicable = isNegotiatorTab ? false : isNegotiatorOwnerFilterApplicable;
                }
                if(searchMap.get('Status__c') != null
                   && searchMap.get('Status__c') != ''
                   && String.escapeSingleQuotes(searchMap.get('Status__c')) != '--None--') {
                    query += ' AND Status__c = \'' + String.escapeSingleQuotes(searchMap.get('Status__c')) + '\' ';
                    isNegotiatorOwnerFilterApplicable = isNegotiatorTab ? false : isNegotiatorOwnerFilterApplicable;
                }
                else if(isNegotiatorTab) {
                    query += ' AND Status__c in (\'' + UTL_CDAUtility.STATUS_INREVIEWBYQUINTILES + '\',\'' + UTL_CDAUtility.STATUS_SIGNATURE_REQUEST_DENIED + '\',\'' + UTL_CDAUtility.STATUS_QUINTILESIMS_VALIDATING_RECIPIENT_RESPONSE + '\',\'' + UTL_CDAUtility.STATUS_AWAITING_OGC_COMPETITOR_APPROVAL + '\',\'' + UTL_CDAUtility.STATUS_ACQUIRING_INTERNAL_SIGNATURE + '\') ';
                }
                if(searchMap.get('Recipient_Account__r.Name') != null && !String.isBlank(searchMap.get('Recipient_Account__r.Name'))) {
                    query += ' AND Recipient_Account_Name_Formula__c LIKE \'%' + String.escapeSingleQuotes(searchMap.get('Recipient_Account__r.Name')) + '%\' ';
                }
                if(searchMap.get('Recipient_Point_of_Contact_Name__c') != null && !String.isBlank(searchMap.get('Recipient_Point_of_Contact_Name__c'))) {
                    query += ' AND Recipient_Point_of_Contact_Name__c LIKE \'%' + String.escapeSingleQuotes(searchMap.get('Recipient_Point_of_Contact_Name__c')) + '%\' ';
                }
                if(searchMap.get('CreatedBy.Name') != null && !String.isBlank(searchMap.get('CreatedBy.Name'))) {
                    query += ' AND CreatedBy.Name LIKE \'%' + String.escapeSingleQuotes(searchMap.get('CreatedBy.Name')) + '%\' ';
                    isNegotiatorOwnerFilterApplicable = isNegotiatorTab ? false : isNegotiatorOwnerFilterApplicable;
                }
                if(searchMap.get('Negotiator_Assigned_List__c') != null
                   && !String.isBlank(searchMap.get('Negotiator_Assigned_List__c'))
                   && String.escapeSingleQuotes(searchMap.get('Negotiator_Assigned_List__c')) != '--None--') {
                    query += ' AND Negotiator_Assigned_List__c = \'' + String.escapeSingleQuotes(searchMap.get('Negotiator_Assigned_List__c')) + '\' ';
                }
                else if(isNegotiatorOwnerFilterApplicable && isNegotiatorTab) {
                    query += ' AND (Negotiator_Assigned_List__c = \'' + UTL_CDAUtility.getUserDetails().Email + '\' OR Negotiator_Assigned_List__c = \'' + UTL_CDAUtility.NEGO_NOT_ASSIGN + '\') ';
                }

                /*if(searchMap.get('Status__c') != null && !String.isBlank(searchMap.get('CDA_Type__c'))) {
                    query += 'CreatedBy.Name LIKE \'%' + String.escapeSingleQuotes(searchMap.get('Recipient_Point_of_Contact_Name__c')) + '%\' AND ';
                }
                if(searchMap.get('Status__c') != null && !String.isBlank(searchMap.get('CDA_Type__c'))) {
                    query += 'What_is_the_Study_Sponsor_situation__c = \'' + String.escapeSingleQuotes(searchMap.get('Recipient_Point_of_Contact_Name__c')) + '\' AND ';
                }*/
            }
            else if(isNegotiatorTab) {
                query += ' AND (Negotiator_Assigned_List__c = \'' + UTL_CDAUtility.getUserDetails().Email + '\' OR Negotiator_Assigned_List__c = \'' + UTL_CDAUtility.NEGO_NOT_ASSIGN + '\') ';
                query += ' AND Status__c in (\'' + UTL_CDAUtility.STATUS_INREVIEWBYQUINTILES + '\',\'' + UTL_CDAUtility.STATUS_SIGNATURE_REQUEST_DENIED + '\',\'' + UTL_CDAUtility.STATUS_QUINTILESIMS_VALIDATING_RECIPIENT_RESPONSE + '\',\'' + UTL_CDAUtility.STATUS_AWAITING_OGC_COMPETITOR_APPROVAL + '\',\'' + UTL_CDAUtility.STATUS_ACQUIRING_INTERNAL_SIGNATURE + '\') ';
            }            
        }
        return query;
    }

 public static Boolean isRequestorAdmin {
        get {
            return (getUserPermission() == UTL_CDAUtility.REQUESTOR_ADMIN || getUserPermission() == UTL_CDAUtility.NEGOTIATOR || getUserPermission() == UTL_CDAUtility.SYS_ADMIN);
        }
        set;
    }
    //Added by Vikram Singh under CR-11764 End

    //Private variables
    private static Map <String, List <CDA_Language_Cross_Walk__c>> langCrossWalkMap;
    private static Map <String, String> supportedLanguageFieldMap;
    private static Map <String, CDA_ML_Field_Mapping__mdt> requestLocalizeFieldMap;
    private static Map <String, List <CDA_Language_Cross_Walk__c>> translationMap {get; set;}
    private static Map <String, String> cdaTypeToTemplateNameMap {
        get {
            if(cdaTypeToTemplateNameMap == null) {
                cdaTypeToTemplateNameMap = new Map <String, String> ();
                for(String cdaTypeToTemplateNameStr: UTL_CDAUtility.cdaTemplateMapping.split(',')) {
                    cdaTypeToTemplateNameMap.put(cdaTypeToTemplateNameStr.split(UTL_CDAUtility.SP_CHAR_TILDE)[0], cdaTypeToTemplateNameStr.split(UTL_CDAUtility.SP_CHAR_TILDE)[1]);
                }
            }
            return cdaTypeToTemplateNameMap;
        }
        private set {
            cdaTypeToTemplateNameMap = value;
        }
    }

    //Public methods
    public static CDA_Request__c getCDARequest(ID cdaRequestId) {
        if(cdaRequestId == null) {
            cdaRecord = new CDA_Request__c();
        }
        else {
            String fieldStr = UTL_CDAUtility.getObjectFieldStr('CDA_Request__c');
            if(UTL_CDAUtility.getRelationObjectFieldStr('QI_Legal_Entity__c', 'QI_Legal_Entity_Name__c') != null) {
                fieldStr += ',' + UTL_CDAUtility.getRelationObjectFieldStr('QI_Legal_Entity__c', 'QI_Legal_Entity_Name__c');
            }
            //Added by Vikram Singh under CR-11576 Start
            if(UTL_CDAUtility.getRelationObjectFieldStr('CDA_Approved_Governing_Law_Location__c', 'Location_of_Governing_Law__c') != null) {
                fieldStr += ',' + UTL_CDAUtility.getRelationObjectFieldStr('CDA_Approved_Governing_Law_Location__c', 'Location_of_Governing_Law__c');
            }
            //Added by Vikram Singh under CR-11576 End
            //Fetching Legal POC Attorney's related fields
            if(UTL_CDAUtility.getRelationObjectFieldStr('CDA_Legal_POC_Cross_Walk__c', 'Legal_POC_Cross_Walk__c') != null) {
                fieldStr += ',' + UTL_CDAUtility.getRelationObjectFieldStr('CDA_Legal_POC_Cross_Walk__c', 'Legal_POC_Cross_Walk__c');
            }
            fieldStr += ',(Select id, name, description, CreatedDate from Attachments order by createdDate desc)'; // to fetch attchement record releated to the request
            fieldStr += ', Owner.Name, Owner.Email, CreatedBy.Name, CreatedBy.Email'; // to fetch record owner detail
            cdaRecord = Database.query('SELECT ' + fieldStr + ' FROM CDA_Request__c WHERE id = \'' + cdaRequestId + '\' LIMIT 1');
        }
        return cdaRecord;
    }

    public static QI_Legal_Entity__c getQILegalEntity(ID qiLegalEntity) {
        if(qiLegalEntity != null) {
            qiCustomerLegalEntityRecord = [SELECT Name, IQVIA_Business_Area__c, Location_of_Governing_Law__c, Court_of_Jurisdiction__c, QI_Legal_Entity_Address__c FROM QI_Legal_Entity__c WHERE id =: qiLegalEntity LIMIT 1];  //Updated by Vikram Singh under CR-11576
            return qiCustomerLegalEntityRecord;
        }
        return new QI_Legal_Entity__c();
    }

    //Added by Vikram Singh under CR-11576 Start
    public static CDA_Approved_Governing_Law_Location__c getGoverningLaw(Id governingLaw) {
        if(governingLaw != null) {
            governingLawRecord = [SELECT Name, Court_of_Jurisdiction__c FROM CDA_Approved_Governing_Law_Location__c WHERE Id =: governingLaw LIMIT 1];
            return governingLawRecord;
        }
        return new CDA_Approved_Governing_Law_Location__c();
    }
    //Added by Vikram Singh under CR-11576 End

    public static void getCDAAccountMap() {
        if(accountListMap == null) {
            List <CDA_Account__c> accountList = [SELECT Id, Name, Complete_Address__c, Street__c, City__c, State__c, Country__c FROM CDA_Account__c];
            if(accountList != null) {
                accountListMap = new Map <Id, CDA_Account__c> (accountList);
            }
        }
    }

    public static CDA_Account__c getCDAAccount(ID cdaAccountID) {
        if(accountListMap == null) {
            getCDAAccountMap();
        }
        if(accountListMap != null && !accountListMap.isEmpty() && accountListMap.containsKey(cdaAccountID)) {
            CDA_Account__c accountMapValue = accountListMap.get(cdaAccountID);
            if(accountMapValue != null) {
                return accountMapValue;
            }
        }
        return null;
    }

    public static void getCDALegalPOCMap() {
        if(legalPOCListMap == null) {
            legalPOCListMap = new Map <String, CDA_Legal_POC_Cross_Walk__c>();
            List <CDA_Legal_POC_Cross_Walk__c> legalPOCList = [SELECT Id, Name, Legal_POC_First_Name__c, Legal_POC_Last_Name__c, Legal_POC_Full_Name__c, Legal_POC_Email_Address__c, CDA_Language__c FROM CDA_Legal_POC_Cross_Walk__c];
            for(CDA_Legal_POC_Cross_Walk__c lp : legalPOCList) {
                legalPOCListMap.put(lp.CDA_Language__c, lp);
            }
        }
    }

    public static CDA_Legal_POC_Cross_Walk__c getCDALegalPOC(String cdaLanguage) {
        if(legalPOCListMap == null) {
            getCDALegalPOCMap();
        }
        if(legalPOCListMap != null && !legalPOCListMap.isEmpty() && legalPOCListMap.containsKey(cdaLanguage)) {
            CDA_Legal_POC_Cross_Walk__c legalPOCMapValue = legalPOCListMap.get(cdaLanguage);
            if(legalPOCMapValue != null) {
                return legalPOCMapValue;
            }
        }
        return null;
    }

    public static Boolean isCdaTypeAuditor(String cdaType) {
        return cdaType == UTL_CDAUtility.AUDITOR;
    }

    public static Boolean isCdaTypeVendor(String cdaType) {
        return cdaType == UTL_CDAUtility.VENDOR;
    }

    public static Boolean isCdaTypeCustomer(String cdaType) {
        return cdaType == UTL_CDAUtility.CUSTOMER;
    }

    public static Boolean isCdaTypeCEVA(String cdaType) {
        return cdaType == UTL_CDAUtility.CEVA;
    }

    public static Boolean isCurrentUserARequestOwner(CDA_Request__c cdaReq) {
        return cdaReq != null && (cdaReq.ownerId == UserInfo.getUserId() || getUserPermission() == UTL_CDAUtility.SYS_ADMIN);
    }

    //Added by Vikram Singh under CR-11188 Start
    public static Boolean isDataAndServices(String qiBusinessPart) {
        return (qiBusinessPart == UTL_CDAUtility.CDA_BUSINESS_PART_LI || qiBusinessPart == UTL_CDAUtility.CDA_BUSINESS_PART_CSMS);
    }

    public static Boolean isClinicalResearch(String qiBusinessPart) {
        return (qiBusinessPart == UTL_CDAUtility.CDA_BUSINESS_PART_LQ || qiBusinessPart == UTL_CDAUtility.CDA_BUSINESS_PART_QS);
    }

    /**
    * Function will retrun that is logged In user is a Requestor or a Negotiator according to the profile and permission set.
    */
    public static String getUserPermission() {
        String retVal = '';
        if(logedInUser == null) {
            logedInUser = new User();
            logedInUser = UTL_CDAUtility.getUserDetails();
        }
        if(logedInUser.Profile.Name != null && logedInUser.Profile.Name.toLowerCase().contains(UTL_CDAUtility.SYS_ADMIN.toLowerCase())) {
            retVal = UTL_CDAUtility.SYS_ADMIN;
        } else if(logedInUser.Profile.Name != null && logedInUser.Profile.Name.toLowerCase().contains(UTL_CDAUtility.NEGOTIATOR.toLowerCase())) {
            retVal = UTL_CDAUtility.NEGOTIATOR;
        } else if(logedInUser.Profile.Name != null && logedInUser.Profile.Name.toLowerCase().contains(UTL_CDAUtility.REQUESTOR_ADMIN.toLowerCase())) {
            retVal = UTL_CDAUtility.REQUESTOR_ADMIN;
            if(logedInUser.PermissionSetAssignments != null && logedInUser.PermissionSetAssignments.size() > 0) {
                for(PermissionSetAssignment PermissionAss: logedInUser.PermissionSetAssignments) {
                    if(PermissionAss.PermissionSet.Label != null && PermissionAss.PermissionSet.Label.toLowerCase().contains(UTL_CDAUtility.NEGOTIATOR.toLowerCase())) {
                        retVal = UTL_CDAUtility.NEGOTIATOR;
                        break;
                    }
                }
            }   
        } else if(logedInUser.Profile.Name != null && logedInUser.Profile.Name.toLowerCase().contains(UTL_CDAUtility.REQUESTOR.toLowerCase()) && !logedInUser.Profile.Name.toLowerCase().contains(UTL_CDAUtility.REQUESTOR_ADMIN.toLowerCase())) {
            retVal = UTL_CDAUtility.REQUESTOR;
            if(logedInUser.PermissionSetAssignments != null && logedInUser.PermissionSetAssignments.size() > 0) {
                for(PermissionSetAssignment PermissionAss: logedInUser.PermissionSetAssignments) {
                    if(PermissionAss.PermissionSet.Label != null && PermissionAss.PermissionSet.Label.toLowerCase().contains(UTL_CDAUtility.REQUESTOR_EXTENDED.toLowerCase()) && retVal == UTL_CDAUtility.REQUESTOR) {
                        retVal = UTL_CDAUtility.REQUESTOR_EXTENDED;
                    }else if(PermissionAss.PermissionSet.Label != null && PermissionAss.PermissionSet.Label.toLowerCase().contains(UTL_CDAUtility.REQUESTOR_ADMIN.toLowerCase()) && (retVal == UTL_CDAUtility.REQUESTOR || retVal == UTL_CDAUtility.REQUESTOR_EXTENDED)) {
                        retVal = UTL_CDAUtility.REQUESTOR_ADMIN;
                    }else if(PermissionAss.PermissionSet.Label != null && PermissionAss.PermissionSet.Label.toLowerCase().contains(UTL_CDAUtility.NEGOTIATOR.toLowerCase())) {
                        retVal = UTL_CDAUtility.NEGOTIATOR;
                        break;
                    }
                }
            }
        } else if(logedInUser.PermissionSetAssignments != null && logedInUser.PermissionSetAssignments.size() > 0) {
            for(PermissionSetAssignment PermissionAss: logedInUser.PermissionSetAssignments) {
                if(PermissionAss.PermissionSet.Label != null && PermissionAss.PermissionSet.Label == UTL_CDAUtility.REQUESTOR_PERMISSIONSET_LABEL && retVal == '') {
                    retVal = UTL_CDAUtility.REQUESTOR;
                }else if(PermissionAss.PermissionSet.Label != null && PermissionAss.PermissionSet.Label.toLowerCase().contains(UTL_CDAUtility.REQUESTOR_EXTENDED.toLowerCase()) && (retVal == UTL_CDAUtility.REQUESTOR || retVal == '')) {
                    retVal = UTL_CDAUtility.REQUESTOR_EXTENDED;
                }else if(PermissionAss.PermissionSet.Label != null && PermissionAss.PermissionSet.Label.toLowerCase().contains(UTL_CDAUtility.REQUESTOR_ADMIN.toLowerCase()) && (retVal == UTL_CDAUtility.REQUESTOR || retVal == UTL_CDAUtility.REQUESTOR_EXTENDED || retVal == '')) {
                    retVal = UTL_CDAUtility.REQUESTOR_ADMIN;
                }else if(PermissionAss.PermissionSet.Label != null && PermissionAss.PermissionSet.Label.toLowerCase().contains(UTL_CDAUtility.NEGOTIATOR.toLowerCase())) {
                    retVal = UTL_CDAUtility.NEGOTIATOR;
                    break;
                }
            }
        }
        return retVal;
    }

    //Updated by Vikram Singh under Item #38(Day-2)
    /**
    * Renders to new cda request page
    */
    public static PageReference goToNewRequest() {
        // PageReference pageRef = new PageReference('/apex/VFP_CDA_RequestEditScreen?reqType=new');
        PageReference pageRef = new PageReference(UTL_CDAUtility.PAGE_EDIT_SCREEN + UTL_CDAUtility.SP_CHAR_QUESTION + UTL_CDAUtility.REQUEST_TYPE_STR + UTL_CDAUtility.SP_CHAR_EQUAL + UTL_CDAUtility.REQUEST_TYPE_NEW);
        pageRef.setRedirect(true);
        return pageRef;
    }

    /**
    * Renders to cda request view page
    */
    public static PageReference goToViewRequest(String idToView) {
        // PageReference pageRef = new PageReference('/apex/VFP_CDA_RequestViewScreen?id='+idToView+'');
        PageReference pageRef = new PageReference(UTL_CDAUtility.PAGE_VIEW_SCREEN + UTL_CDAUtility.SP_CHAR_QUESTION + UTL_CDAUtility.REQUEST_ID_STR + UTL_CDAUtility.SP_CHAR_EQUAL + idToView);
        pageRef.setRedirect(true);
        return pageRef;
    }

    /**
    * Renders to cda request edit page
    */
    public static PageReference goToEditRequest(String idToUpdate) {
        // PageReference pageRef = new PageReference('/apex/VFP_CDA_RequestEditScreen?id='+idToUpdate+'&reqType=edit');
        PageReference pageRef = new PageReference(UTL_CDAUtility.PAGE_EDIT_SCREEN + UTL_CDAUtility.SP_CHAR_QUESTION + UTL_CDAUtility.REQUEST_ID_STR + UTL_CDAUtility.SP_CHAR_EQUAL + idToUpdate + UTL_CDAUtility.SP_CHAR_AMPERSAND + UTL_CDAUtility.REQUEST_TYPE_STR + UTL_CDAUtility.SP_CHAR_EQUAL + UTL_CDAUtility.REQUEST_TYPE_EDIT);
        pageRef.setRedirect(true);
        return pageRef;
    }

    /**
    * Retrives list of record sizes/page to display on the page.
    */
    public static List <SelectOption> getRecordsPerPage() {
        List <SelectOption> recordsPerPag = new List <SelectOption> ();
        recordsPerPag.add(new SelectOption('10', '10'));
        recordsPerPag.add(new SelectOption('20', '20'));
        recordsPerPag.add(new SelectOption('50', '50'));
        recordsPerPag.add(new SelectOption('100', '100'));
        return recordsPerPag;
    }

    //Updated by Vikram Singh under Issue-11681 Start
    /**
    * Returns CDA request records
    */
    public static ApexPages.StandardSetController setCon(String sortField, String sortDir) {
        return new ApexPages.StandardSetController(Database.getQueryLocator(query + ' order by ' + sortField + ' ' + sortDir + ' limit ' + UTL_CDAUtility.MAX_RECORDLIMIT));
    }
    //Updated by Vikram Singh under Issue-11681 End

    /**
    * Handles search feature
    */
    public static ApexPages.StandardSetController runSearch(CDA_Request__c searchRequest, String qiLegalEntityStr, String recipientLegalEntityStr, String sortField, String sortDir, String cdaRequestorName) {
        String cdaId = searchRequest != null ? (String)searchRequest.get('CDA_Id__c') : '';
        String cdaType = searchRequest != null ? searchRequest.CDA_Type__c : '';
        String status = searchRequest != null ? searchRequest.Status__c : '';

        String studySponsorSituation = searchRequest != null ? searchRequest.What_is_the_Study_Sponsor_situation__c : '';
        String recipientPointOfContactName = searchRequest != null ? searchRequest.Recipient_Point_of_Contact_Name__c : '';
        String negotiatorAssigned = searchRequest != null ? searchRequest.Negotiator_Assigned_List__c : '';

        String qiLegalEntity = qiLegalEntityStr;
        String recipientLegalEntityName = recipientLegalEntityStr;

        query += query.contains('WHERE') ? ' AND ': ' WHERE ';  //Updated by Vikram Singh under Issue-11681
        if(!String.isBlank(cdaId)) {
            query += 'CDA_Id__c LIKE \'%' + String.escapeSingleQuotes(cdaId) + '%\' AND ';
        }
        if(!String.isBlank(cdaType)) {
            query += 'CDA_Type__c = \'' + String.escapeSingleQuotes(cdaType) + '\' AND ';
        }
        if(!String.isBlank(status)) {
            query += 'Status__c = \'' + String.escapeSingleQuotes(status) + '\' AND ';
        }
        if(!String.isBlank(cdaRequestorName)) {
            query += 'CreatedBy.Name LIKE \'%' + String.escapeSingleQuotes(cdaRequestorName) + '%\' AND ';
        }
        if(!String.isBlank(studySponsorSituation)) {
            query += 'What_is_the_Study_Sponsor_situation__c = \'' + String.escapeSingleQuotes(studySponsorSituation) + '\' AND ';
        }
        if(!String.isBlank(recipientPointOfContactName)) {
            query += 'Recipient_Point_of_Contact_Name__c LIKE \'%' + String.escapeSingleQuotes(recipientPointOfContactName) + '%\' AND ';
        }
        if(!String.isBlank(qiLegalEntity)) {
            query += 'QI_Legal_Entity_Name__r.Name LIKE \'%' + String.escapeSingleQuotes(qiLegalEntity) + '%\' AND ';
        }
        if(!String.isBlank(recipientLegalEntityName)) {
            query += 'Recipient_Account_Name_Formula__c LIKE \'%' + String.escapeSingleQuotes(recipientLegalEntityName) + '%\' AND ';
        }
        if(!String.isBlank(negotiatorAssigned)) {
            query += 'Negotiator_Assigned_List__c = \'' + String.escapeSingleQuotes(negotiatorAssigned) + '\' AND ';
        }

        if(query.substring(Query.length() - 4, Query.length()).equals('AND ')) {
            query = Query.substring(0, Query.length() - 4);
        }
        if(query.substring(Query.length() - 6, Query.length()).equals('WHERE ')) {
            query = Query.substring(0, Query.length() - 6);
        }
        return setCon(sortField, sortDir);
    }

    /**
    * This function handles the CDA custom report search features
    * @param: cda request filter values.
    * @param: cda requestor name to filter the result.
    * @param: field name based on which sorting will take place
    * @param: sorting direction
    * @return: returns the standard controller context
    */
    public static ApexPages.StandardSetController runSearchForReport(CDA_Request__c searchRequest, String cdaRequestorName, String sortField, String sortDir) {
        buildSearchQueryString(searchRequest, cdaRequestorName, sortField, sortDir);
        return setCon(sortField, sortDir);
    }

    /**
    * This function creates the query string to search the records
    * @param: cda request filter values.
    * @param: cda requestor name to filter the result.
    * @param: field name based on which sorting will take place
    * @param: sorting direction
    */
    public static void buildSearchQueryString(CDA_Request__c searchRequest, String cdaRequestorName, String sortField, String sortDir) {
        String cdaId = searchRequest != null ? (String)searchRequest.get('CDA_Id__c') : '';
        String cdaType = searchRequest != null ? searchRequest.CDA_Type__c : '';
        String status = searchRequest != null ? searchRequest.Status__c : '';
        String negotiatorAssigned = searchRequest != null ? searchRequest.Negotiator_Assigned_List__c : '';

        boolean isNegotiatorOwnerFilterApplicable = true;
        // query += ' WHERE ';
        query += query.contains('WHERE') ? ' AND ': ' WHERE ';  //Updated by Vikram Singh under Issue-11681
        // Uncommented by C.P.Pandey under Day-2 Item-225 start
        if(!String.isBlank(cdaId)) {
            query += 'CDA_Id__c LIKE \'%' + String.escapeSingleQuotes(cdaId) + '%\' AND ';
            isNegotiatorOwnerFilterApplicable = false;
        }
        // Uncommented by C.P.Pandey under Day-2 Item-225 end
        if(!String.isBlank(cdaType)) {
            query += 'CDA_Type__c = \'' + String.escapeSingleQuotes(cdaType) + '\' AND ';
            isNegotiatorOwnerFilterApplicable = false;
        }
        if(!String.isBlank(status)) {
            query += 'Status__c = \'' + String.escapeSingleQuotes(status) + '\' AND ';
            isNegotiatorOwnerFilterApplicable = false;
        }
        else {
            query += 'Status__c in (\'' + UTL_CDAUtility.STATUS_INREVIEWBYQUINTILES + '\',\'' + UTL_CDAUtility.STATUS_SIGNATURE_REQUEST_DENIED + '\',\'' + UTL_CDAUtility.STATUS_QUINTILESIMS_VALIDATING_RECIPIENT_RESPONSE + '\',\'' + UTL_CDAUtility.STATUS_AWAITING_OGC_COMPETITOR_APPROVAL + '\',\'' + UTL_CDAUtility.STATUS_ACQUIRING_INTERNAL_SIGNATURE + '\') AND ';   //Updated by Vikram Singh under Item #254 and C.P.Pandey under Item #43 (Day-2) and Issue-11144
        }
        /*if(!String.isBlank(studySponsorSituation)) {
            query += 'What_is_the_Study_Sponsor_situation__c = \'' + String.escapeSingleQuotes(studySponsorSituation) + '\' AND ';
            isNegotiatorOwnerFilterApplicable = false;
        }
        if(!String.isBlank(recipientPointOfContactName)) {
            query += 'Recipient_Point_of_Contact_Name__c LIKE \'%' + String.escapeSingleQuotes(recipientPointOfContactName) + '%\' AND ';
        }*/
        if(!String.isBlank(cdaRequestorName)) {
            query += 'CreatedBy.Name LIKE \'%' + String.escapeSingleQuotes(cdaRequestorName) + '%\' AND ';
            isNegotiatorOwnerFilterApplicable = false;
        }
        if(!String.isBlank(negotiatorAssigned)) {
            query += 'Negotiator_Assigned_List__c = \'' + String.escapeSingleQuotes(negotiatorAssigned) + '\' AND ';
        }
        else if(isNegotiatorOwnerFilterApplicable) {
            query += '(Negotiator_Assigned_List__c = \'' + UTL_CDAUtility.getUserDetails().Email + '\' OR Negotiator_Assigned_List__c = \'' + UTL_CDAUtility.NEGO_NOT_ASSIGN + '\') AND ';
        }

        if(query.substring(Query.length() - 4, Query.length()).equals('AND ')) {
            query = Query.substring(0, Query.length() - 4);
        }
        if(query.substring(Query.length() - 6, Query.length()).equals('WHERE ')) {
            query = Query.substring(0, Query.length() - 6);
        }
    }


    /**
    * This method will save the translated value of CDA Request in localize fields on update of Records(Calling from trigger before update).
    */
    public static List <CDA_Request__c> saveLocalizeFieldsForCDARequestOnUpdate(Map <id, Sobject> newRequestMap, Map <id, Sobject> oldRequestMap) {
        requestLocalizeFieldMap = getRequestLocalizeFieldMap();
        List <CDA_Request__c> requestToBeLocalizeList = new List <CDA_Request__c> ();
        List <CDA_Request__c> requestToBeUpdated = new List <CDA_Request__c> ();

        //Checking for all fields to be localize are changed or not . if changed than we will call method to fill all localize fields with appropriate value.
        for(CDA_ML_Field_Mapping__mdt mdtObj: requestLocalizeFieldMap.values()) {
            if(oldrequestMap != null && oldrequestMap.size() > 0 && newRequestMap != null && newRequestMap.size() > 0) {
                for(Sobject request: newRequestMap.values()) {
                    if(request.get(mdtObj.Standard_Field__c) != oldrequestMap.get(request.id).get(mdtObj.Standard_Field__c)) {
                        requestToBeLocalizeList.add((CDA_Request__c) request);
                        break;
                    }
                }
            }
        }

        if(requestToBeLocalizeList != null && requestToBeLocalizeList.size() > 0) {
            //Calling of method to translated value of CDA Request in localize fields.
            requestToBeUpdated = saveLocalizeFieldsForCDARequest(requestToBeLocalizeList);
        }
        return requestToBeUpdated;
    }

    /**
    * This method will save the translated value of CDA Request in localize fields on insert of Records (Calling from trigger after Update).
    */
    public static List <CDA_Request__c> saveLocalizeFieldsForCDARequest(List <CDA_Request__c> requestList) {
        Set <string> langSet = new Set <string> ();
        List <CDA_Request__c> requestToBeUpdated = new List <CDA_Request__c> ();
        supportedLanguageFieldMap = getSupportedLanguageFieldMap();
        requestLocalizeFieldMap = getRequestLocalizeFieldMap();
        for(CDA_Request__c request: requestList) {
            if(request != null && request.CDA_Language__c != null && supportedLanguageFieldMap != null && supportedLanguageFieldMap.containsKey(request.CDA_Language__c)) {
                langSet.add(supportedLanguageFieldMap.get(request.CDA_Language__c));
            }
        }
        langCrossWalkMap = getTranslatedValueMap(langSet);
        String mlKey;
        //Logic to fill all the values in localize fields of CDA Object.
        for(CDA_Request__c request: requestList) {
            for(CDA_ML_Field_Mapping__mdt mdtObj: requestLocalizeFieldMap.values()) {
                // Logic to fill all the localize fields if value in piclist is Yes , No and --None--.
                if(request.get(mdtObj.Standard_Field__c) != null && (String.valueOf(request.get(mdtObj.Standard_Field__c)) == UTL_CDAUtility.NONE || String.valueOf(request.get(mdtObj.Standard_Field__c)) == UTL_CDAUtility.YES || String.valueOf(request.get(mdtObj.Standard_Field__c)) == UTL_CDAUtility.NO)) {
                    mlKey = supportedLanguageFieldMap.get(request.CDA_Language__c) + UTL_CDAUtility.SP_CHAR_TILDE + mdtObj.Object_Type__c + UTL_CDAUtility.SP_CHAR_TILDE + UTL_CDAUtility.RECORD + UTL_CDAUtility.SP_CHAR_TILDE + String.valueOf(request.get(mdtObj.Standard_Field__c));
                    if(translationMap.containsKey(mlKey)) {
                        request.put(mdtObj.localize_Field__c, translationMap.get(mlKey)[0].get(supportedLanguageFieldMap.get(request.CDA_Language__c)));
                        requestToBeUpdated.add(request);
                    }
                }
                // Logic to fill all the localize fields if value in piclist is other than Yes , No and --None--.
                else {
                    mlKey = supportedLanguageFieldMap.get(request.CDA_Language__c) + UTL_CDAUtility.SP_CHAR_TILDE + mdtObj.Object_Type__c + UTL_CDAUtility.SP_CHAR_TILDE + mdtObj.control_Type__c + UTL_CDAUtility.SP_CHAR_TILDE + mdtObj.Standard_Field__c;
                    if(translationMap != null && translationMap.size() > 0 && translationMap.containsKey(mlKey)) {
                        for(CDA_Language_Cross_Walk__c cwObj: translationMap.get(mlKey)) {
                            if(request.get(mdtObj.Standard_Field__c) == cwObj.Default_Value__c) {
                                request.put(mdtObj.localize_Field__c, cwObj.get(supportedLanguageFieldMap.get(request.CDA_Language__c)));
                                requestToBeUpdated.add(request);
                                break;
                            }
                        }
                    }
                }
            }
        }
        return requestToBeUpdated;
    }

    /**
    * This field will return map of language supported from custom metadata.
    */
    public static Map <String, String> getSupportedLanguageFieldMap() {
        if(supportedLanguageFieldMap == null) {
            supportedLanguageFieldMap = new Map <String, String> ();
            List <CDA_ML_Code_Field_Mapping__mdt> mlFieldMappingList = new List <CDA_ML_Code_Field_Mapping__mdt> ([Select id, localize_Field_on_Cross_Walk__c, Supporting_Language__c from CDA_ML_Code_Field_Mapping__mdt]);
            if(mlFieldMappingList != null && mlFieldMappingList.size() > 0) {
                for(CDA_ML_Code_Field_Mapping__mdt mdt: mlFieldMappingList) {
                    supportedLanguageFieldMap.put(mdt.Supporting_Language__c, mdt.localize_Field_on_Cross_Walk__c);
                }
            }
        }
        return supportedLanguageFieldMap;
    }

    /**
    * This field will return map of lacalize field v/s actual field mapping from custom metadata.
    */
    public static Map <String, CDA_ML_Field_Mapping__mdt> getRequestLocalizeFieldMap() {
        if(requestLocalizeFieldMap == null) {
            requestLocalizeFieldMap = new Map <String, CDA_ML_Field_Mapping__mdt> ();
            List <CDA_ML_Field_Mapping__mdt> fieldMappingList = new List <CDA_ML_Field_Mapping__mdt> ([Select id, localize_Field__c, Standard_Field__c, Control_Type__c, Object_Type__c from CDA_ML_Field_Mapping__mdt]);
            if(fieldMappingList != null && fieldMappingList.size() > 0) {
                for(CDA_ML_Field_Mapping__mdt mdt: fieldMappingList) {
                    requestLocalizeFieldMap.put(mdt.Standard_Field__c, mdt);
                }
            }
        }
        return requestLocalizeFieldMap;
    }

    /**
    * @param: Language type for which translations needed.
    * @return: Collection of CDA_Language_Cross_Walk__c type records
    */
    public static Map <String, List <CDA_Language_Cross_Walk__c>> getTranslatedValueMap(Set <String> langSet) {
        if(translationMap != null){
        return translationMap;}
        translationMap = new Map <String, List <CDA_Language_Cross_Walk__c>> ();
        string soql = 'SELECT Id, Object_Type__c, Control_Type__c, Field_Type__c, Default_Value__c, Rank__c ';
        for(string lang: langSet){
        soql += ', ' + lang;}
        soql += ' FROM CDA_Language_Cross_Walk__c WHERE IsDeleted__c = false';
        List <CDA_Language_Cross_Walk__c> translatedValueList = Database.query(soql);
        String mlKey = '';
        for(CDA_Language_Cross_Walk__c tlc: translatedValueList) {
            for(string lang: langSet) {
                mlKey = '';
                if(tlc.control_type__c == UTL_CDAUtility.RECORD) {
                    mlKey = lang + UTL_CDAUtility.SP_CHAR_TILDE + tlc.Object_Type__c + UTL_CDAUtility.SP_CHAR_TILDE + tlc.control_type__c + UTL_CDAUtility.SP_CHAR_TILDE + tlc.default_value__c;
                }
                else {
                    mlKey = lang + UTL_CDAUtility.SP_CHAR_TILDE + tlc.Object_Type__c + UTL_CDAUtility.SP_CHAR_TILDE + tlc.control_type__c + UTL_CDAUtility.SP_CHAR_TILDE + tlc.field_type__c;
                }
                if(!translationMap.containsKey(mlKey)) {
                    translationMap.put(mlKey, new List <CDA_Language_Cross_Walk__c> ());
                }
                translationMap.get(mlKey).add(tlc);
            }
        }
        return translationMap;
    }

    /**
    * This Method send the mails as bulkified.
    * @param: cdaIdToCdaRequestMap is map of id of CDA Request and its object.
    * @param: toWhom is string type value expecting which type of receiver it is. for example: Requestor,Recipient and etc.
    * @param: commonBCCRecipientsList are the blind carbon copy list to the whole bulkified emails.
    * @param: templateName is actually the label of the custom setting which will fetch templateId from that custom setting.
    */
    //Updated By Babita Dadarwal under Issue-11280 Start    // Updated by Vikram Singh under Issue-11311 Start  //Updated by Vikram Singh under CR-11764 Start
    public static void sendCdaNotification(Map <Id, CDA_Request__c> cdaIdToCdaRequestMap, string toWhom, List <string> commonBCCRecipientsList, string templateName) {
        if(cdaIdToCdaRequestMap != null && toWhom != null) {
            List <Messaging.SingleEmailMessage> emailsToSendList = new List <Messaging.SingleEmailMessage> ();

            if(UTL_CDAUtility.cntObj == null) {
                UTL_CDAUtility.cntObj = [SELECT ID FROM CONTACT LIMIT 1];
            }

            for(Id cdaRequestId: cdaIdToCdaRequestMap.keySet()) {
                CDA_Request__c cdaRequest = cdaIdToCdaRequestMap.get(cdaRequestId); //Added by Vikram Singh under CR-11764
                List <string> toAddressList = new List <string> ();
                List <String> ccRecipientList = new List<String>();    //Updated by Vikram Singh under CR-11566
                List <string> bccRecipientList = commonBCCRecipientsList;

                String legalEmails = UTL_CDAUtility.legalEmails;
                if(legalEmails != null) {
                    ccRecipientList = legalEmails.split(';');
                }

                //loading Additional IQVIA contact details
                List<UTL_CDAUtility.cdaAdditionalContactWrapper> cdaAdditionalContactWrapperList = UTL_CDAUtility.getAdditionalContactsDetails(cdaRequest.Id);
                List<String> addContatRecipientList = new List<String>();
                if(cdaAdditionalContactWrapperList != null) {
                    for(UTL_CDAUtility.cdaAdditionalContactWrapper con : cdaAdditionalContactWrapperList) {
                        if(con.acEmail != null) {
                            addContatRecipientList.add(con.acEmail);
                        }
                    }
                }
                
                //this if block is specific scenario of non-english CDA where cc recipient should be negotiator 
                if(templateName == UTL_CDAUtility.EMAIL_LEGAL_POC_ASSIGNMENT || templateName == UTL_CDAUtility.EMAIL_LEGAL_POC_REMINDER) {
                    if(cdaRequest.Negotiator_Assigned_List__c != null && cdaRequest.Negotiator_Assigned_List__c != UTL_CDAUtility.NEGO_NOT_ASSIGN && cdaRequest.Negotiator_Assigned_List__c != UTL_CDAUtility.SELF_SERVICE_ONLY ) {
                        ccRecipientList.add(cdaRequest.Negotiator_Assigned_List__c);
                    } else {
                        ccRecipientList.add(UTL_CDAUtility.NegoMailBox);
                    }
                }

                // This will fetch the templateId from the custom setting by its label and language as parameter
                String tempLanguage = cdaRequest.CDA_Language__c != null ? cdaRequest.CDA_Language__c : 'English';
                Id templateId = UTL_CDAUtility.getTemplateId(templateName, tempLanguage);
                Messaging.SingleEmailMessage emailToSend = new Messaging.SingleEmailMessage();
                List <Messaging.Emailfileattachment> fileAttachments = new List <Messaging.Emailfileattachment> ();
                List <Attachment> attachments = new List <Attachment> ();
                if(templateName == UTL_CDAUtility.EMAIL_REQ_EXCU8_AGGR_RECVD || templateName == UTL_CDAUtility.EMAIL_RECIPIENT_EXC8_CONFIRM) {
                    String queryToExecute = 'SELECT Id, Name, Body FROM Attachment where ParentId = \'' + cdaRequestId + '\' AND (Name LIKE \'%' + UTL_CDAUtility.COMPLETED_KEYWORD + '%\' OR Name LIKE \'%' + UTL_CDAUtility.UPLOADED_AUDIT_SCOPE_AGENDA_FILE + '%\' OR Name LIKE \'%' + UTL_CDAUtility.UPLOADED_CUSTOMER_CONSENT_TO_DISCLOSE_FILE + '%\') order by createdDate desc';
                    attachments = Database.query(queryToExecute);
                }
                else if(templateName == UTL_CDAUtility.EMAIL_RECIPIENT_REVIEW_REQUEST || templateName == UTL_CDAUtility.EMAIL_RECIPIENT_REVIEW_REMINDER || templateName == UTL_CDAUtility.EMAIL_LEGAL_POC_ASSIGNMENT || templateName == UTL_CDAUtility.EMAIL_LEGAL_POC_REMINDER) { // Updated by Babita Dadarwal under CR-11169
                    String queryToExecute = 'SELECT Id, Name, Body, CreatedDate FROM Attachment where ParentId = \'' + cdaRequestId + '\' AND (Name LIKE \'%' + UTL_CDAUtility.UPLOADED_AUDIT_SCOPE_AGENDA_FILE + '%\' OR Name LIKE \'%' + UTL_CDAUtility.UPLOADED_CUSTOMER_CONSENT_TO_DISCLOSE_FILE + '%\' OR Name LIKE \'%' + UTL_CDAUtility.RED_LINE_KEYWORD_NEW + '%\' OR Name LIKE \'%' + UTL_CDAUtility.RED_LINE_KEYWORD + '%\' OR Name LIKE \'%' + UTL_CDAUtility.CLEANED_DOC_KEYWORD_NEW + '%\' OR Name LIKE \'%' + UTL_CDAUtility.CLEANED_DOC_KEYWORD + '%\' OR Name LIKE \'%' + UTL_CDAUtility.GENERATED_DOCUMENT_KEYWORD + '%\' OR Name LIKE \'%' + UTL_CDAUtility.EXTERNAL_KEYWORD + '%\') order by createdDate desc'; // Updated by Ajinkya Pande Under Item #114
                    attachments = Database.query(queryToExecute);
                }
                
                Boolean isCompletedDocInPDF = false;
                Boolean isCDAHandledByDocusign = false;
                if(attachments != null && attachments.size() > 0) {
                    if(attachments[0].Name.toLowerCase().contains(UTL_CDAUtility.COMPLETED_KEYWORD.toLowerCase()) && attachments[0].Name.toLowerCase().contains(UTL_CDAUtility.CDA_FORMAT_PDF.toLowerCase())) {
                        isCompletedDocInPDF = true;
                    }
                }
                
                //Getting docusign envelope status to identify whether this CDA is handled by Docusign or Manually.
                if(isCompletedDocInPDF) {
                    List < dsfs__DocuSign_Status__c > listDocusignEnvelope = new List < dsfs__DocuSign_Status__c > ();
                    String dsQry = 'SELECT id, Name, CDA_Request__c, dsfs__Envelope_Status__c, CreatedDate  FROM dsfs__DocuSign_Status__c WHERE CDA_Request__r.id = \''+cdaRequestId+'\' order by CreatedDate desc';
                    listDocusignEnvelope = Database.query(dsQry);

                    if(listDocusignEnvelope != null && listDocusignEnvelope.size() > 0 && listDocusignEnvelope[0].dsfs__Envelope_Status__c == 'Completed') {
                        isCDAHandledByDocusign = true;
                    }
                }

                if(attachments != null && attachments.size() > 0 && (templateName == UTL_CDAUtility.EMAIL_RECIPIENT_REVIEW_REQUEST || templateName == UTL_CDAUtility.EMAIL_RECIPIENT_REVIEW_REMINDER || templateName == UTL_CDAUtility.EMAIL_LEGAL_POC_ASSIGNMENT || templateName == UTL_CDAUtility.EMAIL_LEGAL_POC_REMINDER)) { // Updated by Babita Dadarwal under CR-11169
                    Messaging.EmailFileAttachment redLineEmailFileAttach = new Messaging.EmailFileAttachment();
                    Messaging.EmailFileAttachment cleanedEmailFileAttach = new Messaging.EmailFileAttachment();
                    Messaging.EmailFileAttachment generatedFileAttach = new Messaging.EmailFileAttachment();
                    Messaging.EmailFileAttachment auditScopeAgendaFileAttach = getFileAttachmentByName(attachments, UTL_CDAUtility.UPLOADED_AUDIT_SCOPE_AGENDA_FILE);
                    Messaging.EmailFileAttachment customerConsentFileAttach = getFileAttachmentByName(attachments, UTL_CDAUtility.UPLOADED_CUSTOMER_CONSENT_TO_DISCLOSE_FILE);
                    Messaging.EmailFileAttachment externalPaperFileAttach = getFileAttachmentByName(attachments, UTL_CDAUtility.EXTERNAL_KEYWORD);
                    for(Attachment attach: attachments) {
                        if(attach.Name.contains(UTL_CDAUtility.GENERATED_DOCUMENT_KEYWORD) && attach.Name.contains(UTL_CDAUtility.EXTENTION_DOC) && (UTL_CDAUtility.buttonType == UTL_CDAUtility.BUTTON_TYPE_SUBMIT || templateName == UTL_CDAUtility.EMAIL_RECIPIENT_REVIEW_REMINDER || templateName == UTL_CDAUtility.EMAIL_LEGAL_POC_ASSIGNMENT || templateName == UTL_CDAUtility.EMAIL_LEGAL_POC_REMINDER)) { // Updated by Babita Dadarwal under CR-11169
                            generatedFileAttach.setFileName(attach.Name);
                            generatedFileAttach.setBody(attach.Body);
                            fileAttachments.add(generatedFileAttach);
                            break;
                        } else if(attach.Name.contains(UTL_CDAUtility.EXTERNAL_KEYWORD) && attach.Name.contains(UTL_CDAUtility.EXTENTION_DOC) && (UTL_CDAUtility.buttonType == UTL_CDAUtility.BUTTON_TYPE_SUBMIT || templateName == UTL_CDAUtility.EMAIL_LEGAL_POC_ASSIGNMENT || templateName == UTL_CDAUtility.EMAIL_LEGAL_POC_REMINDER)) {
                            externalPaperFileAttach.setFileName(attach.Name);
                            externalPaperFileAttach.setBody(attach.Body);
                            fileAttachments.add(externalPaperFileAttach);
                            break;
                        } else if((attach.Name.contains(UTL_CDAUtility.RED_LINE_KEYWORD) || attach.Name.contains(UTL_CDAUtility.RED_LINE_KEYWORD_NEW)) || (attach.Name.contains(UTL_CDAUtility.CLEANED_DOC_KEYWORD) || attach.Name.contains(UTL_CDAUtility.CLEANED_DOC_KEYWORD_NEW))) { //Updated by Ajinkya Pande Under Item #114  //Updated by Vikram Singh under CR-11146
                            //Added by Vikram Singh under CR-11146 Start
                            if(cdaRequest.What_documents_would_you_like_to_provide__c == UTL_CDAUtility.CDA_RESPONSE_DOCTYPE_REDLINED && (attach.Name.contains(UTL_CDAUtility.RED_LINE_KEYWORD) || attach.Name.contains(UTL_CDAUtility.RED_LINE_KEYWORD_NEW))) {    //Updated by Vikram Singh under CR-11764
                                redLineEmailFileAttach.setFileName(attach.Name);
                                redLineEmailFileAttach.setBody(attach.Body);
                                fileAttachments.add(redLineEmailFileAttach);
                                break;
                            } else if(cdaRequest.What_documents_would_you_like_to_provide__c == UTL_CDAUtility.CDA_RESPONSE_DOCTYPE_CLEANED && (attach.Name.contains(UTL_CDAUtility.CLEANED_DOC_KEYWORD) || attach.Name.contains(UTL_CDAUtility.CLEANED_DOC_KEYWORD_NEW))) {    //Updated by Vikram Singh under CR-11764
                                cleanedEmailFileAttach.setFileName(attach.Name);
                                cleanedEmailFileAttach.setBody(attach.Body);
                                fileAttachments.add(cleanedEmailFileAttach);
                                break;
                            //Added by Vikram Singh under CR-11146 End
                            } else if(cdaRequest.What_documents_would_you_like_to_provide__c == UTL_CDAUtility.CDA_RESPONSE_DOCTYPE_REDLINED_AND_CLEANED && (attach.Name.contains(UTL_CDAUtility.RED_LINE_KEYWORD) || attach.Name.contains(UTL_CDAUtility.RED_LINE_KEYWORD_NEW))) {  //Updated by Ajinkya Pande Under Item #114 //Updated by Vikram Singh under CR-11764
                                redLineEmailFileAttach.setFileName(attach.Name);
                                redLineEmailFileAttach.setBody(attach.Body);
                                fileAttachments.add(redLineEmailFileAttach);
                                for(Attachment attach2: attachments) {
                                    if(attach2.Name.contains(UTL_CDAUtility.CLEANED_DOC_KEYWORD) || attach2.Name.contains(UTL_CDAUtility.CLEANED_DOC_KEYWORD_NEW) && attach2.CreatedDate > attach.CreatedDate) { //Updated by Ajinkya Pande Under Item #114
                                        cleanedEmailFileAttach.setFileName(attach2.Name);
                                        cleanedEmailFileAttach.setBody(attach2.Body);
                                        fileAttachments.add(cleanedEmailFileAttach);
                                        break;
                                    }
                                }
                                break;
                            }
                        }
                    }
                    if(!isCompletedDocInPDF || !isCDAHandledByDocusign) {
                        if(auditScopeAgendaFileAttach != null) {
                            fileAttachments.add(auditScopeAgendaFileAttach);    // Adding UTL_CDAUtility.UPLOADED_AUDIT_SCOPE_AGENDA_FILE
                        }
                        if(customerConsentFileAttach != null) {
                            fileAttachments.add(customerConsentFileAttach);     // Adding UTL_CDAUtility.UPLOADED_AUDIT_SCOPE_AGENDA_FILE
                        }
                    }
                    emailToSend.setFileAttachments(fileAttachments);
                } else if(attachments != null && attachments.size() > 0 && (templateName != UTL_CDAUtility.EMAIL_RECIPIENT_REVIEW_REQUEST || templateName != UTL_CDAUtility.EMAIL_RECIPIENT_REVIEW_REMINDER || templateName != UTL_CDAUtility.EMAIL_LEGAL_POC_ASSIGNMENT || templateName != UTL_CDAUtility.EMAIL_LEGAL_POC_REMINDER)) { // Updated by Babita Dadarwal under CR-11169
                    for(Attachment attachment: attachments) {
                        Messaging.EmailFileAttachment efa;
                        Boolean isCompletedDocInPDFAttached = false;
                        if(isCompletedDocInPDF && isCDAHandledByDocusign && !isCompletedDocInPDFAttached) {
                            if(!attachment.Name.contains(UTL_CDAUtility.UPLOADED_AUDIT_SCOPE_AGENDA_FILE) && !attachment.Name.contains(UTL_CDAUtility.UPLOADED_CUSTOMER_CONSENT_TO_DISCLOSE_FILE)) {
                                efa = new Messaging.EmailFileAttachment();
                                efa.setFileName(attachment.Name);
                                efa.setBody(attachment.Body);
                                isCompletedDocInPDFAttached = true;
                            }
                        } else {
                            efa = new Messaging.EmailFileAttachment();
                            efa.setFileName(attachment.Name);
                            efa.setBody(attachment.Body);
                        }
                        if(efa != null) {
                            fileAttachments.add(efa);
                        }
                    }
                    emailToSend.setFileAttachments(fileAttachments);
                }
                if(toWhom == UTL_CDAUtility.REQUESTOR) {
                    //Added by Vikram Singh under Issue-11881 Start
                    if(cdaRequest != null && isRequestorAdmin && cdaRequest.Originating_Requestor_Flag__c == UTL_CDAUtility.YES && cdaRequest.Originating_Requestor_IQVIA_Email__c != null) {
                        toAddressList.add(cdaRequest.Originating_Requestor_IQVIA_Email__c);
                    }
                    //Added by Vikram Singh under Issue-11881 End
                    else if(cdaRequest != null && cdaRequest.Owner.Email != null) {  //Updated by Vikram Singh under CR-11764   //Updated by Vikram Singh under CR-11881
                        toAddressList.add(cdaRequest.Owner.Email);  //Updated by Vikram Singh under CR-11764
                    }
                }
                else if(toWhom == UTL_CDAUtility.RECIPIENT) {
                    toAddressList.add(cdaRequest.Recipient_Point_of_Contact_Email_Address__c);  //Updated by Vikram Singh under CR-11764
                }
                else if(toWhom == UTL_CDAUtility.AUTH_SIGN) {
                    toAddressList.add(cdaRequest.Recipient_Authorized_Signer_Email_Addres__c);  //Updated by Vikram Singh under CR-11764
                }
                else if(toWhom == UTL_CDAUtility.NEGO_ASSIGNED) {
                    if(cdaIdToCdaRequestMap.get(cdaRequestId) != null && cdaRequest.Negotiator_Assigned_List__c != null && cdaRequest.Negotiator_Assigned_List__c != UTL_CDAUtility.NEGO_NOT_ASSIGN && cdaRequest.Negotiator_Assigned_List__c != UTL_CDAUtility.SELF_SERVICE_ONLY) { // Updated by Ajinkya Pande under Item #258    //Updated by Vikram Singh under CR-11764
                        toAddressList.add(cdaRequest.Negotiator_Assigned_List__c); // Updated by Ajinkya Pande under Item #258  //Updated by Vikram Singh under CR-11764
                    }
                }
                else if(toWhom == UTL_CDAUtility.LEGAL_POC) {
                    CDA_Legal_POC_Cross_Walk__c cdaLegalPOC = getCDALegalPOC(cdaRequest.CDA_Language__c);
                    if(cdaLegalPOC != null) {
                        toAddressList.add(cdaLegalPOC.Legal_POC_Email_Address__c);
                    }
                }
                else if(toWhom == UTL_CDAUtility.CENTRALMAILBOX) {
                    toAddressList.add(UTL_CDAUtility.NegoMailBox);
                }
                emailToSend.setToAddresses(toAddressList);
                
                //Updated by Vikram Singh under Issue-11881 Start
                //Updated by Vikram Singh under Issue-11834 Start
                //Added by Vikram Singh under CR-11764 Start
                if(!(templateName == UTL_CDAUtility.EMAIL_CANCEL_BY_REQUESTOR
                     || templateName == UTL_CDAUtility.EMAIL_OGC_COMPETITOR_REVW_REQ
                     || templateName == UTL_CDAUtility.EMAIL_EXTERNAL_PAPER_REVIEW
                     || templateName == UTL_CDAUtility.EMAIL_RESPONSE_RECEIVED
                     || templateName == UTL_CDAUtility.EMAIL_NEGOTIATOR_ASSIGNED)) {
                    if(isRequestorAdmin && cdaRequest.Originating_Requestor_Flag__c == UTL_CDAUtility.YES) {
                        if(!toAddressList.contains(cdaRequest.Originating_Requestor_IQVIA_Email__c)) {
                            ccRecipientList.add(cdaRequest.Originating_Requestor_IQVIA_Email__c);
                        }
                        if(cdaRequest.Requestor_Admin_Email_Flag__c == UTL_CDAUtility.YES && cdaRequest.Owner.Email != null && !toAddressList.contains(cdaRequest.Owner.Email)) {
                            ccRecipientList.add(cdaRequest.Owner.Email);
                        }
                    } else if(cdaRequest.Requestor_Carbon_Copies__c == true && cdaRequest.Owner.Email != null && !toAddressList.contains(cdaRequest.Owner.Email)) {
                        ccRecipientList.add(cdaRequest.Owner.Email);
                    }
                    //Adding additional contacts as cc recipient
                    if(addContatRecipientList != null && addContatRecipientList.size() > 0) {
                        ccRecipientList.addAll(addContatRecipientList);
                    }
                }
                //Added by Vikram Singh under CR-11764 End
                //Updated by Vikram Singh under Issue-11834 End
                //Updated by Vikram Singh under Issue-11881 End
                if(ccRecipientList != null) {
                    emailToSend.setCcAddresses(ccRecipientList);
                }

                // Added by Vikram Singh under Issue-11311 Start
                if(bccRecipientList != null) {
                    emailToSend.setBccAddresses(bccRecipientList);
                }
                // Added by Vikram Singh under Issue-11311 End
                if(UTL_CDAUtility.multiLingualTemplateSettingsMap.get(UTL_CDAUtility.CDA_ORG_WIDE_EMAIL_ID) != null && UTL_CDAUtility.multiLingualTemplateSettingsMap.get(UTL_CDAUtility.CDA_ORG_WIDE_EMAIL_ID).Template_Id__c != null) {
                    emailToSend.setOrgWideEmailAddressId(UTL_CDAUtility.multiLingualTemplateSettingsMap.get(UTL_CDAUtility.CDA_ORG_WIDE_EMAIL_ID).Template_Id__c);
                }

                emailToSend.setTargetObjectId(UTL_CDAUtility.cntObj.Id);
                emailToSend.setTreatTargetObjectAsRecipient(false); //donot send email to targetObjectId
                emailToSend.setWhatId(cdaRequestId); // CDA Request Id
                emailToSend.setTemplateId(templateId); // template Id
                emailToSend.setSaveAsActivity(true); // save to activity history
                emailToSend.setUseSignature(false);
                if(isReminder){
                    Messaging.SingleEmailMessage emailNotToSend = new Messaging.SingleEmailMessage();
                    emailNotToSend = Messaging.renderStoredEmailTemplate(templateId, NULL, cdaRequestId);
                    String sub = 'Reminder: ' + emailNotToSend.getSubject();
                    emailToSend.setSubject(sub);
                    emailToSend.setHTMLBody(emailNotToSend.getHtmlBody());
                }
                emailsToSendList.add(emailToSend);
            }
            // isSendOutgoingEmails is flag in custom setting which give power to admin to stop the email communication.
            if(emailsToSendList != null && emailsToSendList.size() > 0 && UTL_CDAUtility.isSendOutgoingEmails) {
                UTL_CDAUtility.sendNotificationEmail(emailsToSendList);
            }
        }
    }
    //Updated by Babita Dadarwal under Issue-11280 End  // Updated by Vikram Singh under Issue-11311 End    //Updated by Vikram Singh under CR-11764 End

    /**
    *   generates CDA teamplate using apttus
    */
    public static void generateCDADocument(CDA_Request__c request) {
        string adminUser = UTL_CDAUtility.userNameContract;
        string adminUserPwd = UTL_CDAUtility.passwordContract;
        string sessionId = UTL_CDAUtility.login(adminUser, adminUserPwd);
        string serverUrl = UTL_CDAUtility.serverUrl;

        String templateName = cdaTypeToTemplateNameMap.get(request.CDA_Type__c); //'e.g. Customer Mutual CDA Template';
        
        //fetch the CDA template
        List <Apttus__APTS_Template__c> templates = [SELECT Id, Name, Apttus__Language__c FROM Apttus__APTS_Template__c WHERE Name =: templateName and Apttus__Keywords__c =: UTL_CDAUtility.CDA_KEYWORD and Apttus__Language__c =: request.CDA_Language__c and Apttus__IsActive__c = TRUE LIMIT 1];
        try {
            //generate document
            Id docId;
            String docFormat = UTL_CDAUtility.CDA_FORMAT_DOC;
            if(EXT_CDA_RequestViewController.isGenerateDocAgreementBtnHit){
                docFormat = UTL_CDAUtility.CDA_FORMAT_DOC;
            }else if(request.CDA_Source__c != UTL_CDAUtility.EXTERNAL_KEYWORD && request.CDA_Format__c != null) {
                docFormat = request.CDA_Format__c.toLowerCase() != UTL_CDAUtility.CDA_FORMAT_PDF.toLowerCase() ? UTL_CDAUtility.CDA_FORMAT_DOC : request.CDA_Format__c;
            }
            boolean isDisplayWatermark = false;
            if(UTL_CDAUtility.settingObject.Is_Template_Watermark_Automated__c) {
                isDisplayWatermark = UTL_CDAUtility.isSandboxOrg;
            }
            docId = Apttus.MergeWebService.generateCustomDoc(templates[0].Id, request.id, 'CDA_Request__c', UTL_CDAUtility.CDA_DOC_COMMENT_FOR_APTTUS, docFormat, isDisplayWatermark, sessionId, serverUrl);

            // update attachment description to avoid regeneration for same request.
            List<Attachment> lstAtt = new List<Attachment>();
            List<ContentDocument> setContentDocument = new List<ContentDocument>();
            if(docId != null) {
                // fetch attachment we got from webservice
                lstAtt = [Select Id, Body, Name, ContentType, BodyLength from Attachment where id =: docId];
            }
            if(lstAtt == Null || lstAtt.size() == 0) {
                List<contentversion> cVersionList = [SELECT title, PathOnClient, versiondata, ContentDocumentId, FileExtension FROM contentversion WHERE ContentDocumentId =: docId];
                if(cVersionList != null && cVersionList.size() > 0) {
                    lstAtt = new List<Attachment>();
                    blob fileBody = cVersionList[0].versiondata;
                    Attachment attach = new Attachment();
                    attach.Body = fileBody;
                    attach.IsPrivate = false;
                    attach.ParentId = request.Id;
                    attach.Name = cVersionList[0].title;
                    insert attach;
                    lstAtt.Add(attach);
                    setContentDocument.Add(new ContentDocument(Id = docId));
                }
            }
            if(lstAtt != Null && lstAtt.size() > 0) {
                lstAtt[0].description = UTL_CDAUtility.GENERATED_DOCUMENT;
                lstAtt[0].Name = UTL_CDAUtility.getDocumentName(request, UTL_CDAUtility.CDASOURCE_QUINTILESIMS);  //Added by Ajinkya Pande under Item #114
                update lstAtt;
            }
            if(setContentDocument != null && setContentDocument.size() > 0) {
                delete setContentDocument;
            }
        }
        catch(Exception ex) {
            UTL_CDAUtility.logRef().logToInsert().Log_Type__c = 'Exception';
            UTL_CDAUtility.setLogObject(request.Id, 'Exception Occurred in SRV_CDA_CDARequest : ' + ex.getMessage(), 'Line :' + ex.getLineNumber() + ' Cause :' + ex.getCause());
            UTL_CDAUtility.logRef().generateLog();
        }
    }

    /**
     *   Added by C.P.Pandey under CR-11525
     *   Generates CDA teamplate using Apttus through BCH_CDA_ProcessRequests
     */
    @future(callout=true)
    public static void generateCDADocumentThroughBatch(string strRequest) {
        CDA_Request__c request = (CDA_Request__c)JSON.deserialize(strRequest, CDA_Request__c.class);
        string adminUser = UTL_CDAUtility.userNameContract;
        string adminUserPwd = UTL_CDAUtility.passwordContract;
        string sessionId = UTL_CDAUtility.login(adminUser, adminUserPwd);
        string serverUrl = UTL_CDAUtility.serverUrl;

        String templateName = cdaTypeToTemplateNameMap.get(request.CDA_Type__c); //'Customer Mutual CDA Template';
        //fetch the CDA template
        List <Apttus__APTS_Template__c> templates = [SELECT Id, Name, Apttus__Language__c FROM Apttus__APTS_Template__c WHERE Name =: templateName and Apttus__Keywords__c =: UTL_CDAUtility.CDA_KEYWORD and Apttus__Language__c =: request.CDA_Language__c and Apttus__IsActive__c = TRUE LIMIT 1];
        try {
            //generate document
            String docId;
            String docFormat = UTL_CDAUtility.CDA_FORMAT_DOC;
            if(request.CDA_Source__c != UTL_CDAUtility.EXTERNAL_KEYWORD && request.CDA_Format__c != null) {
                docFormat = request.CDA_Format__c.toLowerCase() != UTL_CDAUtility.CDA_FORMAT_PDF.toLowerCase() ? UTL_CDAUtility.CDA_FORMAT_DOC : request.CDA_Format__c;
            }
            boolean isDisplayWatermark = false;
            if(UTL_CDAUtility.settingObject.Is_Template_Watermark_Automated__c) {
                isDisplayWatermark = UTL_CDAUtility.isSandboxOrg;
            }
            docId = Apttus.MergeWebService.generateCustomDoc(templates[0].Id, request.id, 'CDA_Request__c', UTL_CDAUtility.CDA_DOC_COMMENT_FOR_APTTUS, docFormat, isDisplayWatermark, sessionId, serverUrl);
            // update attachment description to avoid regeneration for same request.
            List<Attachment> lstAtt = new List<Attachment>();
            List<ContentDocument> setContentDocument = new List<ContentDocument>();
            if(docId != null) {
                // fetch attachment we got from webservice
                lstAtt = [SELECT Id, Body, Name, ContentType, BodyLength FROM Attachment WHERE id =: docId];
            }
            if(lstAtt == Null || lstAtt.size() == 0) {
                List<contentversion> cVersionList = [SELECT title, PathOnClient, versiondata, ContentDocumentId, FileExtension FROM contentversion WHERE ContentDocumentId =: docId];
                if(cVersionList != null && cVersionList.size() > 0) {
                    lstAtt = new List<Attachment>();
                    blob fileBody = cVersionList[0].versiondata;
                    Attachment attach = new Attachment();
                    attach.Body = fileBody;
                    attach.IsPrivate = false;
                    attach.ParentId = request.Id;
                    attach.Name = cVersionList[0].title;
                    insert attach;
                    lstAtt.Add(attach);
                    setContentDocument.Add(new ContentDocument(Id = docId));
                }
            }
            if(lstAtt != Null && lstAtt.size() > 0) {
                lstAtt[0].description = UTL_CDAUtility.GENERATED_DOCUMENT;
                lstAtt[0].Name = UTL_CDAUtility.getDocumentName(request, UTL_CDAUtility.CDASOURCE_QUINTILESIMS);
                UTL_CDAUtility.isBatchProcessing = true;
                update lstAtt;
            }
            if(setContentDocument != null && setContentDocument.size() > 0) {
                delete setContentDocument;
            }
        }
        catch(Exception ex) {
            UTL_CDAUtility.logRef().logToInsert().Log_Type__c = 'Exception';
            UTL_CDAUtility.setLogObject(request.Id, 'Exception Occurred in SRV_CDA_CDARequest : ' + ex.getMessage(), 'Line :' + ex.getLineNumber() + ' Cause :' + ex.getCause());
            UTL_CDAUtility.logRef().generateLog();
        }
    }

    /**
     * Added by Vikram Singh under CR-11525 Start
     * Returns whether user is having Apptus Contract Management License
     * @type {Boolean}
     */
    public static Boolean isUserHavingApttusLicense() {
        //Gets details of current logged in user dealing with CDA Request.
        if(logedInUser == null) {
            logedInUser = new User();
            logedInUser = UTL_CDAUtility.getUserDetails();
        }

        //Checks whether above user having Apptus license or not
        if(UTL_CDAUtility.setOfUserIdsHavingApttusLicense.size() > 0 && UTL_CDAUtility.setOfUserIdsHavingApttusLicense.contains(logedInUser.Id)){
            return true;
        }
        return false;
    }
    //Added by Vikram Singh under CR-11525 End
    public static Boolean isUserHavingCongaPermissionSet() {
        //Gets details of current logged in user dealing with CDA Request.
        if(logedInUser == null) {
            logedInUser = new User();
            logedInUser = UTL_CDAUtility.getUserDetails();
        }

        if(logedInUser.PermissionSetAssignments != null && logedInUser.PermissionSetAssignments.size() > 0) {
            for(PermissionSetAssignment PermissionAss: logedInUser.PermissionSetAssignments) {
                if(PermissionAss.PermissionSet.Label != null && PermissionAss.PermissionSet.Label.toLowerCase().contains(UTL_CDAUtility.CONGA_PERMISSION.toLowerCase())) {
                    return true;
                }
            }
        }  
        return false;
    }
    //Added by Vikram Singh under CR-11691 Start
    public PageReference redirectHistoricalDataLayout(CDA_Request__c cdaRequest, String reqType) {
        if(cdaRequest != null) {
            String retUrl = UTL_CDAUtility.SP_CHAR_SLASH + cdaRequest.Id + UTL_CDAUtility.SP_CHAR_QUESTION + UTL_CDAUtility.NOOVERRIDE;
            if(reqType == 'e') {    //'e' stands for edit page rendering
                retUrl = UTL_CDAUtility.SP_CHAR_SLASH + cdaRequest.Id + UTL_CDAUtility.SP_CHAR_SLASH + reqType + UTL_CDAUtility.SP_CHAR_QUESTION + UTL_CDAUtility.NOOVERRIDE;
            }
            if(cdaRequest.RecordTypeId != null && cdaRequest.RecordTypeId == Schema.SObjectType.CDA_Request__c.getRecordTypeInfosByName().get(UTL_CDAUtility.historicalDataRecordType).getRecordTypeId()) {
                return new PageReference(retUrl).setRedirect(true);
            }
        }
        return null;
    }
    //Added by Vikram Singh under CR-11691 End

    public static Messaging.EmailFileAttachment getFileAttachmentByName(List<Attachment> attachments, String attachmentType) {
        Messaging.EmailFileAttachment fileAttachement;
        for(Attachment attach: attachments) {
            if(attach.Name.contains(attachmentType)) {
                fileAttachement = new Messaging.EmailFileAttachment();
                fileAttachement.setFileName(attach.Name);
                fileAttachement.setBody(attach.Body);
                break;
            }
        }
        return fileAttachement;
    }
    
    public static void cancelRequest(String cdaRequestId) {
        try {
            Map <Id, CDA_Request__c> cdaIdToCdaRequestMap = new Map <Id, CDA_Request__c>();
            CDA_Request__c cdaRequest = getCDARequest(cdaRequestId);
            
            cdaIdToCdaRequestMap.put(cdaRequestId, cdaRequest);
            string devEmails = UTL_CDAUtility.devEmails;
            List <string> ccAddress;
            if(devEmails != null) {
                ccAddress = devEmails.split(';');
            }
            string templateName = UTL_CDAUtility.EMAIL_CANCEL_BY_REQUESTOR;
            string toWhom = UTL_CDAUtility.NEGO_ASSIGNED;
            cdaRequest.Status__c = UTL_CDAUtility.STATUS_CANCELEDBYREQUESTOR;
            //EXT_CDA_RequestViewController.isCancelClicked = true;
            //EXT_CDA_RequestViewController.voidDocusignEnvpAndResubmit();
            Set<string> cdaIds = new Set<string>();
            cdaIds.add((String)cdaRequest.get('CDA_Id__c'));
            SRV_CDA_DocusignStatus.setVoidToDocusignEnvelope(cdaIds);
            update cdaRequest;
            if(!isNegotiator) {
                SRV_CDA_CDARequest.sendCdaNotification(cdaIdToCdaRequestMap, toWhom, ccAddress, templateName);
            }
        } catch (Exception ex) {
            UTL_CDAUtility.logRef().logToInsert().Log_Type__c = 'Exception';
            UTL_CDAUtility.setLogObject(cdaRequestId, 'Exception Occurred in SRV_CDA_CDARequest : ' + ex.getMessage(), 'Line :' + ex.getLineNumber() + ' Cause :' + ex.getCause());
            UTL_CDAUtility.logRef().generateLog();
            Apexpages.addMessage(new Apexpages.Message(ApexPages.severity.INFO, ex.getMessage()));
        }
    }
}
