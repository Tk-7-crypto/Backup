public class CNT_CSM_CorrectiveAction {
    @AuraEnabled
    public static String  getPickListValues(){
        Map<String, List<String>> picklistValuesMap = new Map<String, List<String>>();
        picklistValuesMap = getDependentPicklistMap(CON_CSM.S_CORRECTIVE_ACTION_C, CON_CSM.S_TYPE_C, CON_CSM.S_CORRECTIVE_FIELD_NAME_C);
        return JSON.serialize(picklistValuesMap);
    }
    
    @AuraEnabled
    public static void save(String correctiveActionWrapperJSON) {
        if(correctiveActionWrapperJSON != null && correctiveActionWrapperJSON != '') {
            List<CorrectiveActionWrapper> correctiveActionWrapperList = (List<CorrectiveActionWrapper>) 
            System.JSON.deserialize(correctiveActionWrapperJSON, List<CorrectiveActionWrapper>.class);
            List<Corrective_Action__c> correctiveActionList = new List<Corrective_Action__c>();
            if(correctiveActionWrapperList != null && correctiveActionWrapperList.size() > 0) {
                String caseId;
                for(CorrectiveActionWrapper correctiveActionWrapperInstance: correctiveActionWrapperList) {
                    correctiveActionList.add(correctiveActionWrapperInstance.correctiveAction);
                    caseId = correctiveActionWrapperInstance.caseId;
                }
                List<Corrective_Action__c> correctiveActionsToBeUpserted = getRecordsToBeUpserted(correctiveActionList, caseId);
                if(correctiveActionsToBeUpserted != null && correctiveActionsToBeUpserted.size() > 0) {
                    try {
                        upsert correctiveActionsToBeUpserted;              
                    } catch(Exception ex) {
                        throw new AuraHandledException('Error : '+ex.getMessage());
                    }
                }
            }
        }
    }
    
    private static List<Corrective_Action__c> getRecordsToBeUpserted(List<Corrective_Action__c> correctiveActionList, String caseId) {
        List<Corrective_Action__c> correctiveActionsToBeUpserted = new List<Corrective_Action__c> ();
        List<Corrective_Action__c> caseRelatedCorrectiveActions = [SELECT Id, Corrective_Field_Name__c, Type__c FROM Corrective_Action__c WHERE Case__c =: caseId];
        for(Corrective_Action__c correctiveAction: correctiveActionList) {
            if(caseRelatedCorrectiveActions != null && caseRelatedCorrectiveActions.size() > 0) {
                for(Corrective_Action__c caseRelatedAction: caseRelatedCorrectiveActions) {
                    if(correctiveAction.Corrective_Field_Name__c == caseRelatedAction.Corrective_Field_Name__c && correctiveAction.Type__c == caseRelatedAction.Type__c) {
                        correctiveAction.Id = caseRelatedAction.Id;
                    }
                }
            }
            correctiveActionsToBeUpserted.add(correctiveAction);
        }
        return correctiveActionsToBeUpserted;
    }
    
    @AuraEnabled
    public static Boolean checkComponentVisibility() {
        Boolean isComponentVisible = false;
        Id profileId = [SELECT Id FROM Profile WHERE Name =:CON_CSM.S_P_SYS_ADMIN].Id;
        if(UserInfo.getProfileId() == profileId) {
            isComponentVisible = true;
        } else {
            List<PermissionSetAssignment> assignedPermissionSets = [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId =: UserInfo.getUserId() AND PermissionSet.Name =: CON_CSM.S_DATA_RECORD_TYPE_US_FIELD_ACCESS];
            if(assignedPermissionSets != null && assignedPermissionSets.size() > 0) {
                isComponentVisible = true;
            }
        }
        return isComponentVisible;
    }
    
    public static Map<String, List<String>> getDependentPicklistMap(String objectName, String contrfieldApiName, String depfieldApiName) {
        String controllingField = contrfieldApiName.toLowerCase();
        String dependentField = depfieldApiName.toLowerCase();
        
        Map<String, List<String>> objResults = new Map<String, List<String>>();
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
            objResults.put(label, new List<String>());
            controllingValues.add(label);
        }
        
        for (PicklistEntryWrapper plew : depEntries) {
            String label = plew.label;
            String validForBits = base64ToBits(plew.validFor);
            for (Integer i = 0; i < validForBits.length(); i++) {
                String bit = validForBits.mid(i, 1);
                if (bit == '1') {
                    objResults.get(controllingValues.get(i)).add(label);
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

    public class PicklistEntryWrapper{
        public String active {get;set;}
        public String defaultValue {get;set;}
        public String label {get;set;}
        public String value {get;set;}
        public String validFor {get;set;}
        public PicklistEntryWrapper(){   
            
        }
        
    }
    
    public class CorrectiveActionWrapper {
        @AuraEnabled public Corrective_Action__c correctiveAction{get; set;}
        @AuraEnabled public Boolean isShowFieldNameError{get; set;}
        @AuraEnabled public String caseId{get; set;}
    }
}
