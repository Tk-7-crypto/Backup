public class DAOH_IMS_Legal_Entity {
    public static void onBeforeDelete(List<IMS_Legal_Entity__c> oldRecords) {
        List<TPA_Additional_Term__c> relatedAdditionalTerms = [SELECT Id, Name FROM TPA_Additional_Term__c WHERE TPA_Legal_Entity_1__c IN : oldRecords];

        if(relatedAdditionalTerms.size() > 0) {
            delete relatedAdditionalTerms;
        }        
    }
}