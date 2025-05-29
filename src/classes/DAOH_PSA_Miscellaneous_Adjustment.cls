public class DAOH_PSA_Miscellaneous_Adjustment {
    public static void updateFieldsOnStatusUpdate(List<pse__Miscellaneous_Adjustment__c> newList, Map<Id, pse__Miscellaneous_Adjustment__c> oldMap){
        for(pse__Miscellaneous_Adjustment__c maRecord : newList){
            if(trigger.isInsert || (trigger.isUpdate && maRecord.pse__Status__c != oldMap.get(maRecord.id).pse__Status__c)){
                if(maRecord.pse__Status__c == CON_PSA.MISCELLANEOUS_ADJUSTMENT_STATUS_APPROVED){
                    maRecord.pse__Approved__c = true;
                    maRecord.pse__Include_In_Financials__c = true;
                }
                if(maRecord.pse__Status__c != CON_PSA.MISCELLANEOUS_ADJUSTMENT_STATUS_APPROVED){
                    maRecord.pse__Approved__c = false;
                    maRecord.pse__Include_In_Financials__c = false;
                }
            }
            if(trigger.isInsert || (trigger.isUpdate && maRecord.pse__Amount__c != oldMap.get(maRecord.id).pse__Amount__c)){
                if(maRecord.pse__Amount__c == 0){
                    maRecord.pse__Exclude_from_Billing__c = true;
                }
                if(maRecord.pse__Amount__c != 0){
                    maRecord.pse__Exclude_from_Billing__c = false;
                }
            }
        }
    }
}
