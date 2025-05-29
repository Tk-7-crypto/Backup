public without sharing class CNT_CSM_DocQCForm {
    public static Map<String, List<String>> getDependentValuesByControllingValue(String objectName, String dependentFieldName) {
        Schema.DescribeFieldResult dependentField = Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().fields.getMap().get(dependentFieldName).getDescribe().getSObjectField().getDescribe();
        Schema.DescribeFieldResult controlField = dependentField.getController().getDescribe();
        List<Schema.PicklistEntry> controlEntries =(controlField.getType() == Schema.DisplayType.Boolean ? null : controlField.getPicklistValues());
        String base64map = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
        Map<String,List<String>> dependentPicklistByControllingPickListMap = new Map<String,List<String>>();
        for (Schema.PicklistEntry entry: dependentField.getPicklistValues()) {
            if (entry.isActive()) {
                List<String> base64chars = String.valueOf(((Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(entry))).get('validFor')).split('');
                if(base64chars.size() > 0 && base64chars[0] != '') {
                    for (Integer index = 0; index < (controlEntries != null ? controlEntries.size() : 2); index++) {
                        Object controlValue = (controlEntries == null ? (Object)(index == 1) : (Object)(controlEntries[index].isActive() ? controlEntries[index].getLabel() : null));
                        Integer bitIndex = index / 6;
                        Integer bitShift = 5 - Math.mod(index, 6);
                        if (controlValue == null || (base64map.indexOf(base64chars[bitIndex]) & (1 << bitShift)) == 0) {
                            continue;
                        }
                        if (!dependentPicklistByControllingPickListMap.containsKey((String)controlValue)) {
                            dependentPicklistByControllingPickListMap.put((String)controlValue, new List<String>());
                        }
                        dependentPicklistByControllingPickListMap.get((String)controlValue).add(entry.getLabel());
                    }
                }
            }
        }
        return dependentPicklistByControllingPickListMap;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<FieldWrapper> Convert(){
        
        Integer flag = 1;
        Map<String, List<String>> abc = CNT_CSM_DocQCForm.getDependentValuesByControllingValue('CSM_R_D_Form__c','Remediation_Points__c');
        List<FieldWrapper> Fields = new List<FieldWrapper>();
        
        for (string key : abc.keySet()) {
            for(string point :  abc.get(key)){
                FieldWrapper fw = new FieldWrapper();
                fw.SectionName=key;
                fw.RemediationPoints=point;
                fw.UniqueNumber = flag;
                Fields.add(fw);
                flag = flag + 1;
            }
        }
        return Fields;
    }
    
    @AuraEnabled
    public static string saveRecord(String jsonData, Id caseId, String ogData) {
        
        Map<Integer, FieldWrapper> fieldWrapByKey = new Map<Integer, FieldWrapper>();
        
        for(FieldWrapper fw: (List<FieldWrapper>)JSON.deserialize(ogData, List<FieldWrapper>.class)) {
            fieldWrapByKey.put(fw.UniqueNumber, fw);
        }
        
        List<FieldWrapper> Fields = (List<FieldWrapper>)JSON.deserialize(jsonData, List<FieldWrapper>.class);
        List<CSM_R_D_Form__c> testRecordList = new List<CSM_R_D_Form__c>();
        
        for(FieldWrapper fw: Fields) {
            if(fw.numberOfErrors != null && fw.numberOfErrors != ''){
                CSM_R_D_Form__c testRecord = new CSM_R_D_Form__c();
                testRecord.Remediation_Points__c = fieldWrapByKey.get(fw.UniqueNumber).RemediationPoints;
                testRecord.Section__c = fieldWrapByKey.get(fw.UniqueNumber).SectionName;
                testRecord.Case__c = caseId;
                testRecord.Number_Of_Issues__c = Decimal.valueOf(fw.numberOfErrors);
                testRecordList.add(testRecord);
            }
        }
        
        if(testRecordList.size() > 0) {
            insert testRecordList;
        }
        return 'Success';
    }
    
    public class FieldWrapper{
        @AuraEnabled
        public Integer UniqueNumber{get;set;}
        @AuraEnabled
        public  string SectionName{get;set;}
        @AuraEnabled
        public  string RemediationPoints{get;set;}
        @AuraEnabled
        public string numberOfErrors{get;set;}
    }
}