/** 
* Queueable Class for the deletion of migrated folders and files of Box from Contract to Agreement object in case of exception
*/  
global class QUE_CLM_BoxMigration implements Queueable, Database.AllowsCallouts {
    global List<box__FRUP__c> lstFRUP;
    
    global QUE_CLM_BoxMigration(List<box__FRUP__c> lstFRUP) {
        this.lstFRUP = lstFRUP;
    }
    
    global void execute(QueueableContext context) { 
        for(box__FRUP__c frup : lstFRUP) {
            UTL_CLM_Box.deleteAllFilesAndFolders(frup.box__Folder_ID__c);  
        }
    }
}