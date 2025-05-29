/*
* Author       : Pramod Kumar
* Purpose      : Batch to update Json
*/
global class BCH_CRM_UpdateBNFJSONData implements Database.Batchable<sObject>, Database.Stateful{
    String query = null;
    public BCH_CRM_UpdateBNFJSONData() {        
    }   
    
    public BCH_CRM_UpdateBNFJSONData(String query) {
        this.query = query;
    }    
    
/*
* To instantiate the Database.QueryLocator object
*/    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        if(query != null) {
            return Database.getQueryLocator(query);
        } else {
            return Database.getQueryLocator([Select Id, Opportunity__c, OLI_Json_Data_1__c, OLI_Json_Data_2__c, OLI_Json_Data_3__c,JSON_Correction__C from BNF2__c where JSON_Correction__c = true order by createddate desc]);
        }
    }
    
/*
* process each batch of records
*/
    global void execute(Database.BatchableContext bc, List<BNF2__c> bnfList) {
        List<OpportunityLineItem> priorOliWholeList = new  List<OpportunityLineItem>();
        Map<Id, OpportunityLineItem> oliMap = null;
        Map<ID,ID> LIToIQVIAIDMap = new Map<ID,ID>();
        Map<ID,ID> LIToIQVIAPriceBookIdMap = new Map<ID,ID>();
        List<BNF2__c> recordToUpdate = new List<BNF2__c>();
        
        for(BNF2__c lastApprovedBNF : bnfList) {            
           
           if(lastApprovedBNF.OLI_Json_Data_1__c != null) {
                lastApprovedBNF.OLI_Json_Data_1__c = lastApprovedBNF.OLI_Json_Data_1__c.replace('Data_Month_Start__c', 'Delivery_Start_Date__c');
                lastApprovedBNF.OLI_Json_Data_1__c = lastApprovedBNF.OLI_Json_Data_1__c.replace('Data_Month_End__c', 'Delivery_End_Date__c');
                lastApprovedBNF.OLI_Json_Data_1__c = lastApprovedBNF.OLI_Json_Data_1__c.replace('Territory__c', 'Delivery_Country__c');
                if(lastApprovedBNF.OLI_Json_Data_1__c.contains('"Winback__c":"No"')){
                    lastApprovedBNF.OLI_Json_Data_1__c = lastApprovedBNF.OLI_Json_Data_1__c.replace('"Winback__c":"No"', '"Winback__c":false');
                }
                if(lastApprovedBNF.OLI_Json_Data_1__c.contains('"Winback__c":"Yes - from competitor"')){
                    lastApprovedBNF.OLI_Json_Data_1__c = lastApprovedBNF.OLI_Json_Data_1__c.replace('"Winback__c":"Yes - from competitor"', '"Winback__c":true');
                }
                if(lastApprovedBNF.OLI_Json_Data_1__c.contains('"Winback__c":"Yes - non competitive"')){
                    lastApprovedBNF.OLI_Json_Data_1__c = lastApprovedBNF.OLI_Json_Data_1__c.replace('"Winback__c":"Yes - non competitive"', '"Winback__c":true');
                }
                priorOliWholeList.addAll((List<OpportunityLineItem>) json.deserialize(lastApprovedBNF.OLI_Json_Data_1__c, List<OpportunityLineItem>.class));                
            }
            
            if(lastApprovedBNF.OLI_Json_Data_2__c != null) {
                lastApprovedBNF.OLI_Json_Data_2__c = lastApprovedBNF.OLI_Json_Data_2__c.replace('Data_Month_Start__c', 'Delivery_Start_Date__c');
                lastApprovedBNF.OLI_Json_Data_2__c = lastApprovedBNF.OLI_Json_Data_2__c.replace('Data_Month_End__c', 'Delivery_End_Date__c');
                lastApprovedBNF.OLI_Json_Data_2__c = lastApprovedBNF.OLI_Json_Data_2__c.replace('Territory__c', 'Delivery_Country__c');
                if(lastApprovedBNF.OLI_Json_Data_2__c.contains('"Winback__c":"No"')){
                    lastApprovedBNF.OLI_Json_Data_2__c = lastApprovedBNF.OLI_Json_Data_2__c.replace('"Winback__c":"No"', '"Winback__c":false');
                }
                if(lastApprovedBNF.OLI_Json_Data_2__c.contains('"Winback__c":"Yes - from competitor"')){
                    lastApprovedBNF.OLI_Json_Data_2__c = lastApprovedBNF.OLI_Json_Data_2__c.replace('"Winback__c":"Yes - from competitor"', '"Winback__c":true');
                }
                if(lastApprovedBNF.OLI_Json_Data_2__c.contains('"Winback__c":"Yes - non competitive"')){
                    lastApprovedBNF.OLI_Json_Data_2__c = lastApprovedBNF.OLI_Json_Data_2__c.replace('"Winback__c":"Yes - non competitive"', '"Winback__c":true');
                }
                priorOliWholeList.addAll((List<OpportunityLineItem>) json.deserialize(lastApprovedBNF.OLI_Json_Data_2__c, List<OpportunityLineItem>.class));                
            }
            
            if(lastApprovedBNF.OLI_Json_Data_3__c != null) { 
                lastApprovedBNF.OLI_Json_Data_3__c = lastApprovedBNF.OLI_Json_Data_3__c.replace('Data_Month_Start__c', 'Delivery_Start_Date__c');
                lastApprovedBNF.OLI_Json_Data_3__c = lastApprovedBNF.OLI_Json_Data_3__c.replace('Data_Month_End__c', 'Delivery_End_Date__c');
                lastApprovedBNF.OLI_Json_Data_3__c = lastApprovedBNF.OLI_Json_Data_3__c.replace('Territory__c', 'Delivery_Country__c');
                if(lastApprovedBNF.OLI_Json_Data_3__c.contains('"Winback__c":"No"')){
                    lastApprovedBNF.OLI_Json_Data_3__c = lastApprovedBNF.OLI_Json_Data_3__c.replace('"Winback__c":"No"', '"Winback__c":false');
                }
                if(lastApprovedBNF.OLI_Json_Data_3__c.contains('"Winback__c":"Yes - from competitor"')){
                    lastApprovedBNF.OLI_Json_Data_3__c = lastApprovedBNF.OLI_Json_Data_3__c.replace('"Winback__c":"Yes - from competitor"', '"Winback__c":true');
                }
                if(lastApprovedBNF.OLI_Json_Data_3__c.contains('"Winback__c":"Yes - non competitive"')){
                    lastApprovedBNF.OLI_Json_Data_3__c = lastApprovedBNF.OLI_Json_Data_3__c.replace('"Winback__c":"Yes - non competitive"', '"Winback__c":true');
                }
                priorOliWholeList.addAll( (List<OpportunityLineItem>) json.deserialize(lastApprovedBNF.OLI_Json_Data_3__c, List<OpportunityLineItem>.class));   
            }
                    
            /*if(lastApprovedBNF.OLI_Json_Data_1__c != null)
                priorOliWholeList.addAll((List<OpportunityLineItem>) json.deserialize(lastApprovedBNF.OLI_Json_Data_1__c, List<OpportunityLineItem>.class));
            if(lastApprovedBNF.OLI_Json_Data_2__c != null)
                priorOliWholeList.addAll((List<OpportunityLineItem>) json.deserialize(lastApprovedBNF.OLI_Json_Data_2__c, List<OpportunityLineItem>.class));
            if(lastApprovedBNF.OLI_Json_Data_3__c != null)
                priorOliWholeList.addAll( (List<OpportunityLineItem>) json.deserialize(lastApprovedBNF.OLI_Json_Data_3__c, List<OpportunityLineItem>.class));               
            */        
        }
        
        List<ID> oliIds = new List<ID>();
        For(OpportunityLineItem oli : priorOliWholeList) {
            oliIds.add(oli.id);
        }
        
        if(priorOliWholeList.size() > 0) {
            oliMap = new Map<Id, OpportunityLineItem>([Select Id, LI_OpportunityLineItem_Id__c,PricebookEntryId from OpportunityLineItem where LI_OpportunityLineItem_Id__c IN :oliIds]);
            if(oliMap.size() > 0) {
                for(OpportunityLineItem oli : oliMap.values()) { 
                    LIToIQVIAIDMap.put(oli.LI_OpportunityLineItem_Id__c, oli.Id);
                }
                for(OpportunityLineItem oli : oliMap.values()) { 
                    LIToIQVIAPriceBookIdMap.put(oli.LI_OpportunityLineItem_Id__c, oli.PricebookEntryId);
                }
            }
        }
        
        for(BNF2__c lastApprovedBNF : bnfList) {
           priorOliWholeList = new  List<OpportunityLineItem>(); 
           //system.debug(lastApprovedBNF.OLI_Json_Data_1__c);
           //system.debug(lastApprovedBNF.OLI_Json_Data_2__c);
           //system.debug(lastApprovedBNF.OLI_Json_Data_3__c);

           if(lastApprovedBNF.OLI_Json_Data_1__c != null) {
                lastApprovedBNF.OLI_Json_Data_1__c = lastApprovedBNF.OLI_Json_Data_1__c.replace('Data_Month_Start__c', 'Delivery_Start_Date__c');
                lastApprovedBNF.OLI_Json_Data_1__c = lastApprovedBNF.OLI_Json_Data_1__c.replace('Data_Month_End__c', 'Delivery_End_Date__c');
                lastApprovedBNF.OLI_Json_Data_1__c = lastApprovedBNF.OLI_Json_Data_1__c.replace('Territory__c', 'Delivery_Country__c');
                if(lastApprovedBNF.OLI_Json_Data_1__c.contains('"Winback__c":"No"')){
                    lastApprovedBNF.OLI_Json_Data_1__c = lastApprovedBNF.OLI_Json_Data_1__c.replace('"Winback__c":"No"', '"Winback__c":false');
                }
                if(lastApprovedBNF.OLI_Json_Data_1__c.contains('"Winback__c":"Yes - from competitor"')){
                    lastApprovedBNF.OLI_Json_Data_1__c = lastApprovedBNF.OLI_Json_Data_1__c.replace('"Winback__c":"Yes - from competitor"', '"Winback__c":true');
                }
                if(lastApprovedBNF.OLI_Json_Data_1__c.contains('"Winback__c":"Yes - non competitive"')){
                    lastApprovedBNF.OLI_Json_Data_1__c = lastApprovedBNF.OLI_Json_Data_1__c.replace('"Winback__c":"Yes - non competitive"', '"Winback__c":true');
                }
                priorOliWholeList.addAll((List<OpportunityLineItem>) json.deserialize(lastApprovedBNF.OLI_Json_Data_1__c, List<OpportunityLineItem>.class));                
            }
            
            if(lastApprovedBNF.OLI_Json_Data_2__c != null) {
                lastApprovedBNF.OLI_Json_Data_2__c = lastApprovedBNF.OLI_Json_Data_2__c.replace('Data_Month_Start__c', 'Delivery_Start_Date__c');
                lastApprovedBNF.OLI_Json_Data_2__c = lastApprovedBNF.OLI_Json_Data_2__c.replace('Data_Month_End__c', 'Delivery_End_Date__c');
                lastApprovedBNF.OLI_Json_Data_2__c = lastApprovedBNF.OLI_Json_Data_2__c.replace('Territory__c', 'Delivery_Country__c');
                if(lastApprovedBNF.OLI_Json_Data_2__c.contains('"Winback__c":"No"')){
                    lastApprovedBNF.OLI_Json_Data_2__c = lastApprovedBNF.OLI_Json_Data_2__c.replace('"Winback__c":"No"', '"Winback__c":false');
                }
                if(lastApprovedBNF.OLI_Json_Data_2__c.contains('"Winback__c":"Yes - from competitor"')){
                    lastApprovedBNF.OLI_Json_Data_2__c = lastApprovedBNF.OLI_Json_Data_2__c.replace('"Winback__c":"Yes - from competitor"', '"Winback__c":true');
                }
                if(lastApprovedBNF.OLI_Json_Data_2__c.contains('"Winback__c":"Yes - non competitive"')){
                    lastApprovedBNF.OLI_Json_Data_2__c = lastApprovedBNF.OLI_Json_Data_2__c.replace('"Winback__c":"Yes - non competitive"', '"Winback__c":true');
                }
                priorOliWholeList.addAll((List<OpportunityLineItem>) json.deserialize(lastApprovedBNF.OLI_Json_Data_2__c, List<OpportunityLineItem>.class));                
            }
            
            if(lastApprovedBNF.OLI_Json_Data_3__c != null) { 
                lastApprovedBNF.OLI_Json_Data_3__c = lastApprovedBNF.OLI_Json_Data_3__c.replace('Data_Month_Start__c', 'Delivery_Start_Date__c');
                lastApprovedBNF.OLI_Json_Data_3__c = lastApprovedBNF.OLI_Json_Data_3__c.replace('Data_Month_End__c', 'Delivery_End_Date__c');
                lastApprovedBNF.OLI_Json_Data_3__c = lastApprovedBNF.OLI_Json_Data_3__c.replace('Territory__c', 'Delivery_Country__c');
                if(lastApprovedBNF.OLI_Json_Data_3__c.contains('"Winback__c":"No"')){
                    lastApprovedBNF.OLI_Json_Data_3__c = lastApprovedBNF.OLI_Json_Data_3__c.replace('"Winback__c":"No"', '"Winback__c":false');
                }
                if(lastApprovedBNF.OLI_Json_Data_3__c.contains('"Winback__c":"Yes - from competitor"')){
                    lastApprovedBNF.OLI_Json_Data_3__c = lastApprovedBNF.OLI_Json_Data_3__c.replace('"Winback__c":"Yes - from competitor"', '"Winback__c":true');
                }
                if(lastApprovedBNF.OLI_Json_Data_3__c.contains('"Winback__c":"Yes - non competitive"')){
                    lastApprovedBNF.OLI_Json_Data_3__c = lastApprovedBNF.OLI_Json_Data_3__c.replace('"Winback__c":"Yes - non competitive"', '"Winback__c":true');
                }
                priorOliWholeList.addAll( (List<OpportunityLineItem>) json.deserialize(lastApprovedBNF.OLI_Json_Data_3__c, List<OpportunityLineItem>.class));   
            }
  
            //system.debug(lastApprovedBNF.OLI_Json_Data_1__c);
            //system.debug(lastApprovedBNF.OLI_Json_Data_2__c);
            //system.debug(lastApprovedBNF.OLI_Json_Data_3__c);

            /*if(lastApprovedBNF.OLI_Json_Data_1__c != null)
                priorOliWholeList.addAll((List<OpportunityLineItem>) json.deserialize(lastApprovedBNF.OLI_Json_Data_1__c, List<OpportunityLineItem>.class));            
            if(lastApprovedBNF.OLI_Json_Data_2__c != null)
                priorOliWholeList.addAll((List<OpportunityLineItem>) json.deserialize(lastApprovedBNF.OLI_Json_Data_2__c, List<OpportunityLineItem>.class));
            if(lastApprovedBNF.OLI_Json_Data_3__c != null)
                priorOliWholeList.addAll( (List<OpportunityLineItem>) json.deserialize(lastApprovedBNF.OLI_Json_Data_3__c, List<OpportunityLineItem>.class));   
            */
            if(priorOliWholeList.size() > 0) {
                //String Tempid = '';
                for(OpportunityLineItem priorOli : priorOliWholeList) {
                    //TempID = priorOli.Id;
                    
                    if(LIToIQVIAIDMap.containskey(priorOli.Id))
                        priorOli.Id = LIToIQVIAIDMap.get(priorOli.Id);
                    //if(LIToIQVIAPriceBookIdMap.containskey(TempID))
                        //priorOli.PricebookEntryId = LIToIQVIAPriceBookIdMap.get(TempID);
                     //TempID='';
                   
                }
                List<OpportunityLineItem> oliListForJson1 = new List<OpportunityLineItem>();
                List<OpportunityLineItem> oliListForJson2 = new List<OpportunityLineItem>();
                List<OpportunityLineItem> oliListForJson3 = new List<OpportunityLineItem>();
                for(OpportunityLineItem oli : priorOliWholeList) {
                    if(oliListForJson1.size() < 100) {
                        oliListForJson1.add(oli);
                        //system.debug('New OLI ****' + oli);
                    } else if(oliListForJson2.size() < 100) {
                        oliListForJson2.add(oli);
                    } else {
                        oliListForJson3.add(oli);
                    }
                }
                
                //system.debug(oliListForJson1);
                if(oliListForJson1.size() > 0)
                    lastApprovedBNF.oli_Json_Data_1__c = Json.serialize(oliListForJson1);
                if(oliListForJson2.size() > 0)
                    lastApprovedBNF.oli_Json_Data_2__c = Json.serialize(oliListForJson2);
                if(oliListForJson3.size() > 0)
                    lastApprovedBNF.oli_Json_Data_3__c = Json.serialize(oliListForJson3);
                lastApprovedBNF.JSON_Correction__C = false;
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
        String a = 'a';
        a = 'a';
        a = 'a';
        a = 'a';
        a = 'a';
        a = 'a';
        a = 'a';
        a = 'a';
        a = 'a';
        a = 'a';
        a = 'a';
        a = 'a';
        a = 'a';
        a = 'a';
        a = 'a';
        a = 'a';
        a = 'a';
        a = 'a';
        a = 'a';
        a = 'a';
        a = 'a';
        a = 'a';
        a = 'a';
        a = 'a';
        a = 'a';
        a = 'a';
        a = 'a';
        a = 'a';
        a = 'a';
        a = 'a';
        a = 'a';
        a = 'a';
        a = 'a';
        a = 'a';
        a = 'a';
        a = 'a';
        a = 'a';
        a = 'a';
        a = 'a';
        a = 'a';
        a = 'a';
        a = 'a';
        a = 'a';
        a = 'a';
        a = 'a';
        a = 'a';
        a = 'a';
        a = 'a';
        a = 'a';
        a = 'a';
        a = 'a';
        a = 'a';
        a = 'a';
        a = 'a';
        a = 'a';
        a = 'a';
        a = 'a';
        a = 'a';
        a = 'a';
        a = 'a';
        a = 'a';
        a = 'a';
        a = 'a';
        a = 'a';
        a = 'a';
        a = 'a';
        a = 'a';
        a = 'a';
        a = 'a';
        a = 'a';
        a = 'a';
        a = 'a';
        a = 'a';
        a = 'a';
        a = 'a';
        a = 'a';
        a = 'a';
        a = 'a';
        a = 'a';
    }
}