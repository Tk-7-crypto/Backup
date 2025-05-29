public class CNT_CSM_CAPACloseAction {
    @AuraEnabled
    public static String getRecord(String caseId) {
        CaseWrapper caseWrapper = new CaseWrapper();
        try {
            List<Case> caseList = new SLT_Case().selectByCaseIdList(new Set<Id>{caseId}, new Set<String>{'Id', 'SubType3__c', 
                'Status', 'SubStatus__c', 'Country_of_the_requester2__c', 'Query_Type_Area__c', 'Query_Type_Area_Free_Text__c',
                'Resolution__c', 'ResolutionCode__c', 'Corrective_Action__c', 'Corrective_Action_Free_Text__c', 'Response_to_Client__c', 
                'RootCause__c', 'Root_Cause_Free_Text__c', 'Force_CSAT_Email_Survey__c'});
            Case caseRecord = (caseList != null && caseList.size() > 0) ? caseList[0] : null;
            if(caseRecord != null && caseRecord.SubType3__c != null && caseRecord.SubType3__c != CON_CSM.S_PLEASE_SPECIFY && caseRecord.SubType3__c != '') {
                caseWrapper.caseRecord = caseRecord;
                caseWrapper.isSubType3Exist = true;
                List<CSM_QI_CAPA__c> csmDataCAPAList = [SELECT Id FROM CSM_QI_CAPA__c WHERE Sub_Type_3__c =: caseRecord.SubType3__c];
                if(csmDataCAPAList != null && csmDataCAPAList.size() > 0) {
                    caseWrapper.isSubType3Matching = true;
                } 
            } 
        } catch(Exception ex) {
            throw new AuraHandledException(JSON.serialize(ex.getMessage()));
        }  
        return JSON.serialize(caseWrapper);
    }
    
    @AuraEnabled
    public static List<AggregateResult> getCAPAValuesWithAggregate(String query){
        try {
           return Database.query(query);
        } catch(Exception ex) {
            throw new AuraHandledException(JSON.serialize(ex.getMessage()));
        }
    }
    
    @AuraEnabled
    public static Boolean checkFieldRequirement() {
        Boolean allFieldsRequired = false;
        Map<Id, Profile> profileMap = new SLT_Profile().selectProfileById(new Set<Id>{CON_CSM.S_SYSTEM_ADMIN_PROFILE_ID}, new Set<String>{'Id'});
        if(profileMap != null && profileMap.size() > 0 && profileMap.containsKey(CON_CSM.S_SYSTEM_ADMIN_PROFILE_ID) && 
           profileMap.get(CON_CSM.S_SYSTEM_ADMIN_PROFILE_ID) != null && UserInfo.getProfileId() == profileMap.get(CON_CSM.S_SYSTEM_ADMIN_PROFILE_ID).Id) {
            allFieldsRequired = false;
        }
        else{
            List<PermissionSetAssignment> assignedPermissionSets = [SELECT Id FROM PermissionSetAssignment 
                                                                    WHERE AssigneeId =: UserInfo.getUserId()
                                                                    AND PermissionSet.Name =: CON_CSM.S_CSM_DATA_CAPA_CLOSE_CASE_ACCESS];
            if(assignedPermissionSets != null && assignedPermissionSets.size() > 0) {
                allFieldsRequired = true;
            }
        }
        return allFieldsRequired;
    }
    
    @AuraEnabled
    public static void saveRecord(String caseWrapperJSON) {
        if(caseWrapperJSON != null && caseWrapperJSON != '') {
            CaseWrapper caseWrapperInstance = (CaseWrapper)System.JSON.deserialize(caseWrapperJSON, CaseWrapper.class);
            Case caseToBeUpdated = caseWrapperInstance.caseRecord;
            if(caseToBeUpdated != null) {
                caseToBeUpdated.Query_Type_Area__c = caseWrapperInstance.queryTypeArea;
                caseToBeUpdated.ResolutionCode__c = caseWrapperInstance.resolutionCode;
                caseToBeUpdated.Corrective_Action__c = caseWrapperInstance.correctiveAction;
                caseToBeUpdated.RootCause__c = caseWrapperInstance.rootCause;
                try {
                    update caseToBeUpdated;
                } catch(Exception ex) {
                    throw new AuraHandledException(JSON.serialize(ex.getMessage()));
                }
            }
        }
    } 
    
    @AuraEnabled
    public static String getPickListValues() {
        PicklistWrapper picklistWrapperInstance = new PicklistWrapper();
        picklistWrapperInstance.statusValues = JSON.serialize(getPickListValuesByFieldName(CON_CSM.S_CASE, CON_CSM.S_STATUS));
        picklistWrapperInstance.subStatusValues = JSON.serialize(getPickListValuesByFieldName(CON_CSM.S_CASE, CON_CSM.S_SUB_STATUSC));
        picklistWrapperInstance.countries = JSON.serialize(getPickListValuesByFieldName(CON_CSM.S_CASE, CON_CSM.S_COUNTRY_OF_REQUESTER2C));
        return JSON.serialize(picklistWrapperInstance);
    }
    
    @testVisible
    private static List<SelectOption> getPickListValuesByFieldName(String objectName, String fieldName){
        Set<String> picklistValuesForData;
        CSM_RecordType_Based_Picklist_Setting__mdt recordTypeBasedSettings = [SELECT DeveloperName, PicklistValues__c FROM CSM_RecordType_Based_Picklist_Setting__mdt WHERE RecordType_Name__c =: CON_CSM.S_DATACASE AND ObjectName__c =: objectName AND PicklistFieldName__c =: fieldName];
        if(recordTypeBasedSettings != null) {
            picklistValuesForData = new Set<String>(recordTypeBasedSettings.PicklistValues__c.split(';'));
        }

        List<SelectOption> selectOptionList = new List<SelectOption>();
        Map<String, SObjectType> globalDescribe = Schema.getGlobalDescribe(); 
        DescribeSObjectResult describeResult = globalDescribe.get(objectName).getDescribe();
        Map<String, Schema.SObjectField> fieldsMap = describeResult.fields.getMap();
        Schema.SObjectField field = fieldsMap.get( fieldName );
        Schema.DescribeFieldResult fieldResult = field.getDescribe();
        List<String> pickListValuesList = new List<String>();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            SelectOption option = new SelectOption();
            pickListValuesList.add(pickListVal.getLabel());
            option.label = pickListVal.getLabel();
            option.value = pickListVal.getValue();
            Boolean isValid = true;
            if(picklistValuesForData != null && !picklistValuesForData.isEmpty()) {
                isValid = picklistValuesForData.contains(option.value) ? true : false;
            } 
            if(isValid) {
                selectOptionList.add(option);
            }
        }     
        return selectOptionList;
    }

    @AuraEnabled 
    public static String getDependentPicklistMap(String objectName, String contrfieldApiName, String depfieldApiName) {
        String controllingField = contrfieldApiName.toLowerCase();
        String dependentField = depfieldApiName.toLowerCase();
        
        Set<String> subStatusValuesForData;
        if(depfieldApiName == CON_CSM.S_SUB_STATUSC) {
            CSM_RecordType_Based_Picklist_Setting__mdt recordTypeBasedSettings = [SELECT DeveloperName, PicklistValues__c FROM CSM_RecordType_Based_Picklist_Setting__mdt WHERE RecordType_Name__c =: CON_CSM.S_DATACASE AND ObjectName__c =: objectName AND PicklistFieldName__c =: depfieldApiName];
            if(recordTypeBasedSettings != null) {
                subStatusValuesForData = new Set<String>(recordTypeBasedSettings.PicklistValues__c.split(';'));
            }
        }

        Map<String, List<SelectOption>> objResults = new Map<String, List<SelectOption>>();
        Map<String, SObjectType> globalDescribe = Schema.getGlobalDescribe(); 
        //DescribeSObjectResult describeResult = globalDescribe.get(objectName).getDescribe();
        Schema.sObjectType objType = globalDescribe.get(objectName);
        if (objType == null){
            return null;
        }
        
        Map<String, Schema.SObjectField> objFieldMap = objType.getDescribe().fields.getMap();
        
        if (!objFieldMap.containsKey(controllingField) || !objFieldMap.containsKey(dependentField)){
            return null;     
        }
        
        Schema.SObjectField theField = objFieldMap.get(dependentField);
        Schema.SObjectField ctrlField = objFieldMap.get(controllingField);
        
        List<Schema.PicklistEntry> contrEntries = ctrlField.getDescribe().getPicklistValues();
        List<PicklistEntryWrapper> depEntries = wrapPicklistEntries(theField.getDescribe().getPicklistValues());
        List<String> controllingValues = new List<String>();

        for (Schema.PicklistEntry ple : contrEntries) {
            String label = ple.getLabel();
            objResults.put(label, new List<SelectOption>());
            controllingValues.add(label);
        }
        
        for (PicklistEntryWrapper plew : depEntries) {
            String label = plew.label;
            String validForBits = base64ToBits(plew.validFor);
            for (Integer i = 0; i < validForBits.length(); i++) {
                String bit = validForBits.mid(i, 1);
                if (bit == '1') {
                    SelectOption dependentOption = new SelectOption();
                    dependentOption.label = label;
                    dependentOption.value = plew.value;
                    Boolean isValid = true;
                    if(depfieldApiName == CON_CSM.S_SUB_STATUSC ) {
                        isValid = subStatusValuesForData != null && !subStatusValuesForData.isEmpty() && subStatusValuesForData.contains(plew.value) ? true : false;                        
                    }
                    if(isValid) {
                        objResults.get(controllingValues.get(i)).add(dependentOption);
                    }
                }
            }
        }
        return JSON.serialize(objResults);
    }
    
    @testVisible
    private static String decimalToBinary(Integer val) {
        String bits = '';
        while (val > 0) {
            Integer remainder = Math.mod(val, 2);
            val = Integer.valueOf(Math.floor(val / 2));
            bits = String.valueOf(remainder) + bits;
        }
        return bits;
    }
    
    @testVisible
    private static String base64ToBits(String validFor) {
        if (String.isEmpty(validFor)){
            return '';
        }
        
        String validForBits = '';
        
        for (Integer i = 0; i < validFor.length(); i++) {
            String thisChar = validFor.mid(i, 1);
            Integer val = base64Chars.indexOf(thisChar);
            String bits = decimalToBinary(val).leftPad(6, '0');
            validForBits += bits;
        }
        
        return validForBits;
    }
    
    @testVisible
    private static final String base64Chars = '' +
        'ABCDEFGHIJKLMNOPQRSTUVWXYZ' +
        'abcdefghijklmnopqrstuvwxyz' +
        '0123456789+/';
    
    @testVisible
    private static List<PicklistEntryWrapper> wrapPicklistEntries(List<Schema.PicklistEntry> pLEs) {
        return (List<PicklistEntryWrapper>)
            JSON.deserialize(JSON.serialize(pLEs), List<PicklistEntryWrapper>.class);
    }
    
    public class PicklistEntryWrapper{
        public String active {get;set;}
        public String defaultValue {get;set;}
        public String label {get;set;}
        public String value {get;set;}
        public String validFor {get;set;}
        public PicklistEntryWrapper(){   
            
        }
        
    }    
    public class PicklistWrapper {
        @AuraEnabled public String statusValues{get; set;}
        @AuraEnabled public String subStatusValues{get; set;}
        @AuraEnabled public String countries{get; set;}
        @AuraEnabled public String rootCauses{get; set;}
        @AuraEnabled public List<String> subType3Values{get; set;}
        @AuraEnabled public List<String> queryTypeAreas{get; set;}
        @AuraEnabled public List<String> correctiveActions{get; set;}
        @AuraEnabled public List<String> resolutionCodes{get; set;}
    }
    
    public class CaseWrapper {
        @AuraEnabled public Case caseRecord{get; set;}
        @AuraEnabled public String queryTypeArea{get; set;}
        @AuraEnabled public String resolutionCode{get; set;}
        @AuraEnabled public String correctiveAction{get; set;}
        @AuraEnabled public String rootCause{get; set;}
        @AuraEnabled public Boolean isSubType3Exist{get; set;}
        @AuraEnabled public Boolean isSubType3Matching{get; set;}
        @AuraEnabled public Boolean isCaseClosed{get; set;}
        public CaseWrapper() {
            isSubType3Exist = false;
            isSubType3Matching = false;
            isCaseClosed = false;
        }
    }
    
    public class SelectOption {
        @AuraEnabled public String label{get; set;}
        @AuraEnabled public String value{get; set;}
    }
    @AuraEnabled
    public static Boolean checkPermission(){
        return FeatureManagement.checkPermission('CSM_Bypass_CSM_Validation_Rules');
    }

}
