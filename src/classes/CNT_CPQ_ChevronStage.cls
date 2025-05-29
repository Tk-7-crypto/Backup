public class CNT_CPQ_ChevronStage {

    @AuraEnabled(cacheable=true)
    public static List<String> getPicklistValues(Id recordId) {
        List<String> stageList =new List<String>();
        SLT_IQVIA_Quote sltIqviaQuote = new SLT_IQVIA_Quote();
        Quote__c quote = sltIqviaQuote.getQuoteDetails(recordId);
        CPQ_Chevron_Stages__mdt cpqChevronStage = [Select Approval_Stage_By_GBU__c from CPQ_Chevron_Stages__mdt where GBU__c =: quote.GBU__c];
        stageList.addAll(cpqChevronStage.Approval_Stage_By_GBU__c.split(';'));
        return stageList;
    }
    
    @AuraEnabled(cacheable=false)
    public static List<Field_History__c> getCurrentAndPreviousStage(Id recordId) {
        List<Field_History__c> listOfFieldHistory = new List<Field_History__c>();
        SLT_IQVIA_Quote sltIqviaQuote = new SLT_IQVIA_Quote();
        String currentStage = sltIqviaQuote.getQuoteDetails(recordId).Approval_Stage__c;
        listOfFieldHistory = [SELECT Id, Old_Value__c, New_Value__c FROM Field_History__c WHERE Tracked_Record_Id__c =: recordId ORDER BY CreatedDate DESC];
        if (listOfFieldHistory.size() > 0) {
            return listOfFieldHistory;
        }
        Field_History__c fHistory = new Field_History__c();
        fHistory.New_Value__c = currentStage;
        fHistory.Old_Value__c ='';
        fHistory.Tracked_Record_Id__c = recordId;
        listOfFieldHistory.add(fHistory);
        return listOfFieldHistory;
    }
}