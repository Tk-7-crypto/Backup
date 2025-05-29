public class DAOH_PSA_Budget {
    
    public static void updateFieldsOnStatusUpdate(List<pse__Budget__c> newList, Map<Id, pse__Budget__c> oldMap){
        for(pse__Budget__c budgetRecord : newList){
            if(budgetRecord.RecordTypeId == CON_PSA.BUDGET_REC_TYPE_ID_RDS
               && budgetRecord.pse__Status__c != null
               && (trigger.isInsert || (trigger.isUpdate && budgetRecord.pse__Status__c != oldMap.get(budgetRecord.id).pse__Status__c))){
                   if(budgetRecord.pse__Status__c == CON_PSA.BUDGET_STATUS_DRAFT || budgetRecord.pse__Status__c == CON_PSA.BUDGET_STATUS_REJECTED){
                       budgetRecord.pse__Approved__c = false;
                       budgetRecord.pse__Include_In_Financials__c = false;
                   }
                else if(budgetRecord.pse__Status__c == CON_PSA.BUDGET_STATUS_OPEN || budgetRecord.pse__Status__c == CON_PSA.BUDGET_STATUS_APPROVED){
                         budgetRecord.pse__Approved__c = true;
                         budgetRecord.pse__Include_In_Financials__c = true;
                }
               }
        }
    }
}
