public class CNT_CSM_MassEditActivity {
    @AuraEnabled
    public static void updateActivities(String activityListJSON) {
        if(activityListJSON != null && activityListJSON != '') {
            List<Activity__c> activityList = (List<Activity__c>)JSON.deserialize(activityListJSON, List<Activity__c>.class);
            if(activityList != null && activityList.size() > 0) {
                try {
                    update activityList;
                } catch(Exception ex) {
                    throw new AuraHandledException(JSON.serialize(ex.getMessage()));
                } 
            }
        }
    }

    @AuraEnabled
    public static String getAllRelatedActivities(String recordId){
        String parentCaseId;
        Map<Id, Case> childCaseMap;
        Set<Id> caseIdSet = new Set<Id>();
        List<Activity__c> relatedActivityList;
        List<Case> caseList = new SLT_Case().selectByCaseIdList(new Set<Id>{recordId}, new Set<String>{'Id', 'ParentId', 'RecordTypeName__c'});
        Case caseRecord = (caseList != null && caseList.size() > 0) ? caseList[0] : null;
        List<ActivitiyWrapper> activitiyWrapperList = new List<ActivitiyWrapper>();
        if(caseRecord != null) {
            if (caseRecord.ParentId == null) {
                childCaseMap = new Map<Id, Case>(new SLT_Case().getCaseListHierarchy('ParentId', new List<String>{recordId}, null));
                caseIdSet.add(recordId);
                if(childCaseMap != null && !childCaseMap.isEmpty() && childCaseMap.size() > 0) {
                    parentCaseId = recordId;
                    caseIdSet.addAll(childCaseMap.keySet());
                }
                if(!caseIdSet.isEmpty()) {
                    relatedActivityList = new SLT_ActivityC().selectActivityByCaseIdOrdered(caseIdSet);
                }
            }    
        }
        if(relatedActivityList != null && relatedActivityList.size() > 0) {
            for(Activity__c activityRecord: relatedActivityList) {
                ActivitiyWrapper activitiyWrapperInstance = new ActivitiyWrapper();
                activitiyWrapperInstance.activity = activityRecord;
                activitiyWrapperInstance.parentCaseId = parentCaseId;
                activitiyWrapperList.add(activitiyWrapperInstance);
            }
        }
        return JSON.serialize(activitiyWrapperList);
    }
    
    @AuraEnabled
    public static String getPickListValues() {
        PicklistWrapper picklistWrapperInstance = new PicklistWrapper();
        picklistWrapperInstance.statusValues = JSON.serialize(getPickListValuesByFieldName(CON_CSM.S_ACTIVITYC, CON_CSM.S_STATUS_C));
        picklistWrapperInstance.passFailValues = JSON.serialize(getPickListValuesByFieldName(CON_CSM.S_ACTIVITYC, CON_CSM.S_PASS_FAIL_C));
        picklistWrapperInstance.losValues = JSON.serialize(getPickListValuesByFieldName(CON_CSM.S_ACTIVITYC, CON_CSM.S_LOS_C));
        picklistWrapperInstance.emailCategorizationValues = JSON.serialize(getPickListValuesByFieldName(CON_CSM.S_ACTIVITYC, CON_CSM.S_EMAIL_CATEGORIZATION_C));
        picklistWrapperInstance.locationValues = JSON.serialize(getPickListValuesByFieldName(CON_CSM.S_ACTIVITYC, CON_CSM.S_R_AND_D_LOCATION_C));
        picklistWrapperInstance.mapOfLOSAndTypeValues = JSON.serialize(getDependentPicklistMap(CON_CSM.S_ACTIVITYC, CON_CSM.S_LOS_C, CON_CSM.S_TYPE_C));
        picklistWrapperInstance.mapOfTypeAndEscalationTypeValues = JSON.serialize(getDependentPicklistMap(CON_CSM.S_ACTIVITYC, CON_CSM.S_TYPE_C, CON_CSM.S_ESCALATION_TYPE_C));
        return JSON.serialize(picklistWrapperInstance);
    }
    
    @testVisible
    private static List<SelectOption> getPickListValuesByFieldName(String objectName, String fieldName){
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
            selectOptionList.add(option);
        }     
        return selectOptionList;
    }
    
    private static Map<String, List<SelectOption>> getDependentPicklistMap(String objectName, String contrfieldApiName, String depfieldApiName) {
        String controllingField = contrfieldApiName.toLowerCase();
        String dependentField = depfieldApiName.toLowerCase();

        Map<String, List<SelectOption>> objResults = new Map<String, List<SelectOption>>();
        Map<String, SObjectType> globalDescribe = Schema.getGlobalDescribe(); 
        DescribeSObjectResult describeResult = globalDescribe.get(objectName).getDescribe();
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
                    objResults.get(controllingValues.get(i)).add(dependentOption);
                }
            }
        }
        return objResults;
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
    private static List<PicklistEntryWrapper> wrapPicklistEntries(List<Schema.PicklistEntry> PLEs) {
        return (List<PicklistEntryWrapper>)JSON.deserialize(JSON.serialize(PLEs), List<PicklistEntryWrapper>.class);
    }

    public class ActivitiyWrapper{
        @AuraEnabled
        public Activity__c activity{get;set;}
        @AuraEnabled
        public String parentCaseId{get;set;}
        @AuraEnabled
        public List<SelectOption> typeValues{get;set;}
        @AuraEnabled
        public List<SelectOption> escalationTypeValues{get;set;}
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
        @AuraEnabled public String passFailValues{get; set;}
        @AuraEnabled public String emailCategorizationValues{get; set;}
        @AuraEnabled public String locationValues{get; set;}
        @AuraEnabled public String losValues{get; set;}
        @AuraEnabled public String typeValues{get; set;}
        @AuraEnabled public String escalationTypeValues{get; set;}
        @AuraEnabled public String mapOfLOSAndTypeValues{get; set;}
        @AuraEnabled public String mapOfTypeAndEscalationTypeValues{get; set;}
    }

    public class SelectOption {
        @AuraEnabled public String label{get; set;}
        @AuraEnabled public String value{get; set;}
    }
}
