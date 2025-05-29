/*
* Author       : Arun Parmar
* Purpose      : Batch to update Json
*/
global class BCH_CRM_UpdateOLIJSONData  implements Database.Batchable<sObject>, Database.Stateful{
    String query = null;
    public BCH_CRM_UpdateOLIJSONData() {        
    }   
    
    public BCH_CRM_UpdateOLIJSONData(String query) {
        this.query = query;
    }    
    
    /*
    * To instantiate the Database.QueryLocator object
    */    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        if(query != null) {
            return Database.getQueryLocator(query);
        } else {
            return Database.getQueryLocator([Select Id,Billing_Schedule__c, BSI_Json_Data_LAB__c from OpportunityLineItem where JSON_Correction__c = true order by createddate desc]);
        }
    }
    /*
    * process each batch of records
    */
    global void execute(Database.BatchableContext bc, List<OpportunityLineItem> oliList) {
        Set<Id> oliBillingSchIdSet = new Set<Id>();
        List<OpportunityLineItem> oliToUpdate= new List<OpportunityLineItem>();
        for(OpportunityLineItem oli : oliList){
            oliBillingSchIdSet.add(oli.Billing_Schedule__c);
        }
        if(oliBillingSchIdSet.size() > 0){
            List<Billing_Schedule_Item__c> billingSchItemList = [select id,Legacy_ID__c from Billing_Schedule_Item__c where Billing_Schedule__c IN : oliBillingSchIdSet];
            Map<String,String> bsiMap = new Map<String,String>(); 
            for(Billing_Schedule_Item__c bsic : billingSchItemList){
                bsiMap.put(bsic.Legacy_ID__c, bsic.Id);
            }
            if(bsiMap.size() > 0){
                for(OpportunityLineItem oli : oliList){
                    List<Billing_Schedule_Item__c> olisBillingSchItemList = ((List<Billing_Schedule_Item__c>)json.deserialize(oli.BSI_Json_Data_LAB__c, List<Billing_Schedule_Item__c>.class));
                    for(Billing_Schedule_Item__c bsi : olisBillingSchItemList){
                        bsi.Id = bsiMap.get(bsi.Id);
                    }
                    oli.BSI_Json_Data_LAB__c = JSON.serialize(olisBillingSchItemList);
					oli.JSON_Correction__c = false;
                    oliToUpdate.add(oli);
                }
                if(oliToUpdate.size() > 0){
                    update oliToUpdate;
                }
            }
        }
    }
    /*
    * To send emails on exception. This method is called after all batches are processed.
    */
    global void finish(Database.BatchableContext BC) {  
    }
}