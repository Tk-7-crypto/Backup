global class BCH_CRM_CreateBoxAssociations_Contr implements Database.Batchable<sObject>, Database.AllowsCallouts { 
    global Database.QueryLocator start( Database.BatchableContext BC ) {
        String sQuery = 'SELECT Id, Quintiles_Contract_Box_ID__c FROM Contract WHERE Quintiles_Contract_Box_ID__c != null';
        return Database.getQueryLocator(sQuery);
    }
    
    global void execute( Database.BatchableContext BC, List<Contract> scope ) {
        box.Toolkit boxToolkit = new box.Toolkit();
        for(Contract con : scope) {
            if(con.Quintiles_Contract_Box_ID__c != null) {
                boxToolkit.createFolderAssociation(con.Id, con.Quintiles_Contract_Box_ID__c);
            }
        }
        boxToolkit.commitChanges();
    }
    
    global void finish( Database.BatchableContext BC ) {}
}