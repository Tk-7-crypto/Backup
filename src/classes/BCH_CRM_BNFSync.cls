/*
 * Author       : Dheeraj Kumar
 * Purpose      : Batch to maintain BNF Record
 */
global class BCH_CRM_BNFSync implements Database.Batchable<sObject> {
    
    /*
     * To instantiate the Database.QueryLocator object
     */    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([Select Id, Opportunity__c, OLI_Json_Data_1__c, OLI_Json_Data_2__c, OLI_Json_Data_3__c from BNF2__c]);
    }
    
    /*
     * process each batch of records
     */
    global void execute(Database.BatchableContext bc, List<BNF2__c> bnfList) {
        List<OpportunityLineItem> priorOliWholeList = new  List<OpportunityLineItem>();
        Map<Id, OpportunityLineItem> oliMap = null;
        for(BNF2__c lastApprovedBNF : bnfList) {
            if(lastApprovedBNF.OLI_Json_Data_1__c != null)
                priorOliWholeList.addAll((List<OpportunityLineItem>) json.deserialize(lastApprovedBNF.OLI_Json_Data_1__c, List<OpportunityLineItem>.class));
            if(lastApprovedBNF.OLI_Json_Data_2__c != null)
                priorOliWholeList.addAll((List<OpportunityLineItem>) json.deserialize(lastApprovedBNF.OLI_Json_Data_2__c, List<OpportunityLineItem>.class));
            if(lastApprovedBNF.OLI_Json_Data_3__c != null)
                priorOliWholeList.addAll( (List<OpportunityLineItem>) json.deserialize(lastApprovedBNF.OLI_Json_Data_3__c, List<OpportunityLineItem>.class));   
            
        }
        if(priorOliWholeList.size() > 0) {
            oliMap = new Map<Id, OpportunityLineItem>([Select Id, Sales_Text__c from OpportunityLineItem    where Id IN :priorOliWholeList]);
        }
        List<BNF2__c> recordToUpdate = new List<BNF2__c>();
        for(BNF2__c lastApprovedBNF : bnfList) {
            priorOliWholeList = new  List<OpportunityLineItem>(); 
            if(lastApprovedBNF.OLI_Json_Data_1__c != null)
                priorOliWholeList.addAll((List<OpportunityLineItem>) json.deserialize(lastApprovedBNF.OLI_Json_Data_1__c, List<OpportunityLineItem>.class));
            if(lastApprovedBNF.OLI_Json_Data_2__c != null)
                priorOliWholeList.addAll((List<OpportunityLineItem>) json.deserialize(lastApprovedBNF.OLI_Json_Data_2__c, List<OpportunityLineItem>.class));
            if(lastApprovedBNF.OLI_Json_Data_3__c != null)
                priorOliWholeList.addAll( (List<OpportunityLineItem>) json.deserialize(lastApprovedBNF.OLI_Json_Data_3__c, List<OpportunityLineItem>.class));   
            if(priorOliWholeList.size() > 0) {
                for(OpportunityLineItem priorOli : priorOliWholeList) {
                    if(oliMap.containskey(priorOli.Id))
                        priorOli.Sales_Text__c = oliMap.get(priorOli.Id).Sales_Text__c;
                }
                List<OpportunityLineItem> oliListForJson1 = new List<OpportunityLineItem>();
                List<OpportunityLineItem> oliListForJson2 = new List<OpportunityLineItem>();
                List<OpportunityLineItem> oliListForJson3 = new List<OpportunityLineItem>();
                for(OpportunityLineItem oli : priorOliWholeList) {
                    if(oliListForJson1.size() < 100)
                        oliListForJson1.add(oli);
                    else if(oliListForJson2.size() < 100)
                        oliListForJson2.add(oli);
                    else
                        oliListForJson3.add(oli);
                }
                if(oliListForJson1.size() > 0)
                    lastApprovedBNF.oli_Json_Data_1__c = Json.serialize(oliListForJson1);
                if(oliListForJson2.size() > 0)
                    lastApprovedBNF.oli_Json_Data_2__c = Json.serialize(oliListForJson2);
                if(oliListForJson3.size() > 0)
                    lastApprovedBNF.oli_Json_Data_3__c = Json.serialize(oliListForJson3);
                recordToUpdate.add(lastApprovedBNF);
            }
            
        }
        if(recordToUpdate.size() > 0) {
            update recordToUpdate;
        }
    }
    
    /*
     * To send emails on exception. This method is called after all batches are processed.
     */
    global void finish(Database.BatchableContext BC) {  
    }
}