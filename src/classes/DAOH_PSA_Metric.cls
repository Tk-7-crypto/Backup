/**
* This is Target trigger handler class.
* version : 1.0
*/
public class DAOH_PSA_Metric {	
    public static void setNonStandardField(List<PSA_Metric__c> newList,Map<Id,PSA_Metric__c> oldMap){
        for(PSA_Metric__c pm : newList){
            if(pm.Account__c != null && ( trigger.isInsert || ( trigger.isUpdate && pm.Account__c != oldMap.get(pm.id).Account__c))){
                pm.Non_Standard__c = true;
            }
        }
    }
}
