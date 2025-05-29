global class BCH_CRM_CreateBoxAssociations_Opp implements Database.Batchable<sObject>, Database.AllowsCallouts {
    global Database.QueryLocator start( Database.BatchableContext BC ) {
        String sQuery = 'SELECT Id, Quintiles_Opportunity_Box_ID__c FROM Opportunity WHERE Quintiles_Opportunity_Box_ID__c != null';
        return Database.getQueryLocator(sQuery);
    }
    
    global void execute( Database.BatchableContext BC, List<Opportunity> scope ) {
        box.Toolkit boxToolkit = new box.Toolkit();
        for(Opportunity opp : scope) {
            if(opp.Quintiles_Opportunity_Box_ID__c != null) {
                boxToolkit.createFolderAssociation(opp.Id, opp.Quintiles_Opportunity_Box_ID__c);
            }
        }
        boxToolkit.commitChanges();
    }
    
    global void finish( Database.BatchableContext BC ) {}
}