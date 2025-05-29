/*
 * Version       : 1.0
 * Description   : Queueable Apex for create box folder for Contract object.
 */
public class QUE_CRM_ContractBoxFoldersJob implements Queueable, Database.allowsCallouts {
    
    private List<Contract> contractList;
    
    /**
     * Constructor
     * @params  Set<Id> contractIdSet
     */
    public QUE_CRM_ContractBoxFoldersJob(List<Contract> contractList) {
        Set<Id> contractIdSet = new Set<Id>();
        for(Contract ctr : contractList) {
            contractIdSet.add(ctr.Id);
        }
        Set<String> fieldSet = new Set<String>{'Account.Name', 'Opportunity__r.Legacy_Quintiles_Opportunity_Number__c', 'ContractNumber'};
        Map<Id, Contract> contractMap = new SLT_Contract().selectByContractId(contractIdSet, fieldSet);
        this.contractList = contractMap.values(); 
    }
    
    /**
     * Execute Method
     * @params  QueueableContext context
     * @return  void
     */
    public void execute(QueueableContext context) {
        Box.Toolkit toolkit = new Box.Toolkit();
        for (Contract ctr : this.contractList) {
            String folderName = ctr.Account.Name + ' ' + ctr.Opportunity__r.Legacy_Quintiles_Opportunity_Number__c + ' ' + ctr.ContractNumber;
            String contractFolderId = toolkit.createFolderForRecordId(ctr.Id, folderName, false);
            if(contractFolderId == null) {
                system.debug('most recent error: ' + toolkit.mostRecentError);
            }
        }
        toolkit.commitChanges();
    }
}