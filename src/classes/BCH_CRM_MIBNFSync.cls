/*
 * Author		: Dheeraj Kumar
 * Purpose		: Batch to maintain MIBNF Record
 */
global class BCH_CRM_MIBNFSync implements Database.Batchable<sObject> {
    
    /*
     * To instantiate the Database.QueryLocator object
     */    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([Select Id, Opportunity__c, OLI_Json_Data_1__c, OLI_Json_Data_2__c, OLI_Json_Data_3__c from MIBNF_Component__c]);
    }
    
    /*
     * process each batch of records
     */
    global void execute(Database.BatchableContext bc, List<MIBNF_Component__c> mibnfList) {
        List<OpportunityLineItem> priorOliWholeList = new  List<OpportunityLineItem>();
        Map<Id, OpportunityLineItem> oliMap = null;
        for(MIBNF_Component__c lastApprovedMIBNF : mibnfList) {
            if(lastApprovedMIBNF.OLI_Json_Data_1__c != null)
                priorOliWholeList.addAll((List<OpportunityLineItem>) json.deserialize(lastApprovedMIBNF.OLI_Json_Data_1__c, List<OpportunityLineItem>.class));
            if(lastApprovedMIBNF.OLI_Json_Data_2__c != null)
                priorOliWholeList.addAll((List<OpportunityLineItem>) json.deserialize(lastApprovedMIBNF.OLI_Json_Data_2__c, List<OpportunityLineItem>.class));
            if(lastApprovedMIBNF.OLI_Json_Data_3__c != null)
                priorOliWholeList.addAll( (List<OpportunityLineItem>) json.deserialize(lastApprovedMIBNF.OLI_Json_Data_3__c, List<OpportunityLineItem>.class));   
            
        }
        if(priorOliWholeList.size() > 0) {
            oliMap = new Map<Id, OpportunityLineItem>([Select Id, Sales_Text__c from OpportunityLineItem	where Id IN :priorOliWholeList]);
        }
        List<MIBNF_Component__c> recordToUpdate = new List<MIBNF_Component__c>();
        for(MIBNF_Component__c lastApprovedMIBNF : mibnfList) {
            priorOliWholeList = new  List<OpportunityLineItem>(); 
            if(lastApprovedMIBNF.OLI_Json_Data_1__c != null)
                priorOliWholeList.addAll((List<OpportunityLineItem>) json.deserialize(lastApprovedMIBNF.OLI_Json_Data_1__c, List<OpportunityLineItem>.class));
            if(lastApprovedMIBNF.OLI_Json_Data_2__c != null)
                priorOliWholeList.addAll((List<OpportunityLineItem>) json.deserialize(lastApprovedMIBNF.OLI_Json_Data_2__c, List<OpportunityLineItem>.class));
            if(lastApprovedMIBNF.OLI_Json_Data_3__c != null)
                priorOliWholeList.addAll( (List<OpportunityLineItem>) json.deserialize(lastApprovedMIBNF.OLI_Json_Data_3__c, List<OpportunityLineItem>.class));   
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
                    lastApprovedMIBNF.oli_Json_Data_1__c = Json.serialize(oliListForJson1);
                if(oliListForJson2.size() > 0)
                    lastApprovedMIBNF.oli_Json_Data_2__c = Json.serialize(oliListForJson2);
                if(oliListForJson3.size() > 0)
                    lastApprovedMIBNF.oli_Json_Data_3__c = Json.serialize(oliListForJson3);
                recordToUpdate.add(lastApprovedMIBNF);
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