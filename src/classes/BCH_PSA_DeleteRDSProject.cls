/*
 * Batch class to delete a set of DSSR projects
 */
global class BCH_PSA_DeleteRDSProject implements Database.Batchable<SObject>{

    global Set<Id> programsToDelete;

    global BCH_PSA_DeleteRDSProject(Set<Id> toDeleteSet) {
        programsToDelete = toDeleteSet;
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator([SELECT Id,Name FROM Program__c WHERE Id IN :programsToDelete]);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope){
        for(sObject s : scope){
            system.debug('Batch deleting program '+s.get('Name'));
            UTL_PSA.deleteProjectHierarchy(s.Id);
        }
    }

    global void finish(Database.BatchableContext BC){
    }
}