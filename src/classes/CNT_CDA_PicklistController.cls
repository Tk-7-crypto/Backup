public with Sharing class CNT_CDA_PicklistController {
	@AuraEnabled
    public static List<String> getPicklistValues(String objectType, String selectedField) {
        List<String> picklistValuesList = new List<String>();
        Schema.SObjectType objectDetail = Schema.getGlobalDescribe().get(objectType);
        Schema.DescribeSObjectResult objectResult = objectDetail.getDescribe();
        Schema.DescribeFieldResult fieldResult = objectResult.fields.getMap().get(selectedField).getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry picklistVal : ple){
            picklistValuesList.add(picklistVal.getLabel());
        }
        return picklistValuesList; 
    }
    
    @AuraEnabled
    public static Map<String, List<String>> getAllPicklistValuesMap(String objectType) {
        Map<String, List<String>> picklistValuesMap = new Map<String, List<String>>();
        
        Schema.SObjectType objectDetail = Schema.getGlobalDescribe().get(objectType);
        Schema.DescribeSObjectResult objectResult = objectDetail.getDescribe();
        
        for(String objField : objectResult.fields.getMap().keySet()) {
            List<String> picklistValuesList = new List<String>();
            Schema.DescribeFieldResult fieldResult = objectResult.fields.getMap().get(objField).getDescribe();
            if(fieldResult.getType() == Schema.DisplayType.PICKLIST) {
                List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
                for(Schema.PicklistEntry picklistVal : ple) {
                    picklistValuesList.add(picklistVal.getLabel());
                }
                picklistValuesMap.put(fieldResult.getName(), picklistValuesList);
            }
        }        
        return picklistValuesMap; 
    }
}