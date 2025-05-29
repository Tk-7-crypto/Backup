public with sharing class CNT_CPQ_DiscountThreshold {
    @AuraEnabled(cacheable = true)
    public static List<Approval_Matrix__c> getDiscountThresholdRecords() {
        List<Approval_Matrix__c> appMatrix = new SLT_ApprovalMatrix().getDiscountThresholdMatrix();																	  
        return appMatrix;
    }
    @AuraEnabled
    public static String updateDiscountThresholdRecords(List<Approval_Matrix__c> myRecords) {
        try{
            Database.Update(myRecords);
            return 'Update';
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}