public with sharing class CNT_CPQ_ApprovalMatrixController {
    @AuraEnabled(cacheable=true)
    public static WPR_CPQ_ApprovalMatrixWrapper fetchApprovalMatrix() {
        WPR_CPQ_ApprovalMatrixWrapper approvalMatrixObj = new WPR_CPQ_ApprovalMatrixWrapper();
        
        Map<String, List<Approval_Matrix__c>> countryAppMap = new Map<String, List<Approval_Matrix__c>>();
        Map<String, String> countryLabelMap = new Map<String, String>();
        Map<String, Set<String>> pricingToolToCountryList = new Map<String, Set<String>>();
        List<PermissionSetAssignment> assignedPermissionSets = new SLT_PermissionSetAssignment().selectByUserIds(
            new Set<String> {CON_CPQ.ID, 'PermissionSet.Name'},
            new Set<Id>{UserInfo.getUserId()}
        );
        
        List<String> assignedPermissionSetNames = new List<String>();
        for(PermissionSetAssignment psa : assignedPermissionSets){
            assignedPermissionSetNames.add(psa.PermissionSet.Name);
        }
        String objectName = 'Apttus_Config2__ProductAttributeValue__c';
        String fieldName = 'Eligible_Countries__c';
        List<String> assignedPricingTools = new List<String>();
        for (CPQ_Proposal_Create_Settings__c customSetting : CPQ_Proposal_Create_Settings__c.getall().values()) {
            if (assignedPermissionSetNames.contains(customSetting.Permission_Set_Name__c) && customSetting.Available_Pricing_Tools__c != null) {
                if (customSetting.Available_Pricing_Tools__c == CON_CPQ.AMESA) {
                    Schema.SObjectType objSobjectType = Schema.getGlobalDescribe().get(objectName);
                    Schema.DescribeSObjectResult objDescribeSobject = objSobjectType.getDescribe();
                    Map<String,Schema.SObjectField> fields = objDescribeSobject.fields.getMap();
                    Schema.DescribeFieldResult fieldResult = fields.get(fieldName).getDescribe();
                    List<Schema.PicklistEntry> pickListEntryList = fieldResult.getPicklistValues();
                    for(Schema.PicklistEntry pickListVal : pickListEntryList){
                        if(pickListVal.getValue() != CON_CPQ.NONE){
                            countryLabelMap.put(pickListVal.getValue(), pickListVal.getLabel());
                        }
                    }
                }
                if (!assignedPricingTools.contains(customSetting.Available_Pricing_Tools__c)) {
                    assignedPricingTools.add(customSetting.Available_Pricing_Tools__c);
                }
            }
        }
        
        Set<String> fieldSet = new Set<String> {CON_CPQ.ID , CON_CPQ.APPROVE_ON_FIRST_RESPONSE, CON_CPQ.LEVELS, CON_CPQ.PRIORITY,CON_CPQ.COUNTRY, CON_CPQ.MIN_AMOUNT, CON_CPQ.MAX_AMOUNT, CON_CPQ.MIN_GORSS_MARGIN, CON_CPQ.MAX_GORSS_MARGIN, CON_CPQ.MIN_DISCOUNT_PERCENT, CON_CPQ.MAX_DISCOUNT_PERCENT,
                                                CON_CPQ.MIN_DISCOUNT_AMOUNT, CON_CPQ.MAX_DISCOUNT_AMOUNT, CON_CPQ.APPROVER1, CON_CPQ.APPROVER2, CON_CPQ.APPROVER3, CON_CPQ.APPROVER4, CON_CPQ.APPROVER5, CON_CPQ.OBJECT_NAME, CON_CPQ.TRACK_NAME, CON_CPQ.PRICING_TOOL, CON_CPQ.AUTO_APPROVE, CON_CPQ.NOTIFIER1, 
                                                CON_CPQ.NOTIFIER2, CON_CPQ.NOTIFIER3, CON_CPQ.NOTIFIER4, CON_CPQ.NOTIFIER5, CON_CPQ.APPROVER1Id, CON_CPQ.APPROVER2Id, CON_CPQ.APPROVER3Id, CON_CPQ.APPROVER4Id, CON_CPQ.APPROVER5Id, CON_CPQ.APPROVER1Name, CON_CPQ.APPROVER2Name, CON_CPQ.APPROVER3Name, CON_CPQ.APPROVER4Name, CON_CPQ.APPROVER5Name};
        String condition = 'Pricing_Tool__c in :assignedPricingTools' + ' AND Process_Type__c = ' + '\'' + CON_CPQ.APPROVAL_PROCESS + '\'';

        List<Approval_Matrix__c> approvalMatrixList = new SLT_ApprovalMatrix().getApproverByPricingTool(fieldSet, condition, assignedPricingTools);
        List<Approval_Matrix__c> approvalMatrixForAll = new List<Approval_Matrix__c>();
        for(Approval_Matrix__c app : approvalMatrixList){
            if (pricingToolToCountryList.containsKey(app.Pricing_Tool__c)) {
                Set<String> countrySet = pricingToolToCountryList.get(app.Pricing_Tool__c);
                countrySet.add(app.Country__c);
                pricingToolToCountryList.put(app.Pricing_Tool__c, countrySet);
            } else {
                pricingToolToCountryList.put(app.Pricing_Tool__c, new Set<String> {app.Country__c});
            }
            String key = app.Country__c + ':' + app.Pricing_Tool__c;
            if(countryAppMap.containsKey(key)) {
                List<Approval_Matrix__c> appMatrixList = countryAppMap.get(key);
                appMatrixList.add(app);
                countryAppMap.put(key, appMatrixList);
            } else {
                countryAppMap.put(key, new List<Approval_Matrix__c> {app});
            }
        }
        
        approvalMatrixObj.countryToApprovalMatrixMap = countryAppMap;
        approvalMatrixObj.countryLabelAndCodeMap = countryLabelMap;
        approvalMatrixObj.pricingToolList = new List<String>(pricingToolToCountryList.keySet());
        return approvalMatrixObj;
    }
    
    public class WPR_CPQ_ApprovalMatrixWrapper {
        @AuraEnabled
        public List<String> pricingToolList {get;set;}
        @AuraEnabled
        public Map<String, String> countryLabelAndCodeMap {get;set;}
        @AuraEnabled
        public Map<String, List<Approval_Matrix__c>> countryToApprovalMatrixMap {get;set;}
    }
}