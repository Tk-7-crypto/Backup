public class BCH_TPA_AMA_ContractDtl_CSV_import implements Database.Batchable<sObject>,Database.Stateful{

    List<AMA_Contract_Detail__c> listOfContracts = new List<AMA_Contract_Detail__c>();
    public List<AMA_Contract_Detail__c> contractsListToInsert = new list<AMA_Contract_Detail__c>();
    public List<AMA_Contract_Detail__c> contractsListToDelete = new list<AMA_Contract_Detail__c>();
    public String action = '';


    public BCH_TPA_AMA_ContractDtl_CSV_import(){
    }

    public Iterable<sObject> start(Database.BatchableContext context) {
        if(action == 'deleteRecords'){
            return contractsListToDelete;
        }
        else {
            return contractsListToInsert;
        }
    }

    public void execute(Database.BatchableContext context, List<sObject> scope) {
        if(action == 'deleteRecords'){
            try{
                delete scope;
                System.debug('data deleted successfully');
            }
            catch(Exception e){
                UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, UTL_LogFactory.GUID, e.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + e.getLineNumber() + ':::BCH_TPA_AMA_ContractDtl_CSV_import:::in delete records', ''));
                UTL_LogFactory.saveLogs(UTL_LogFactory.getLogLst(), TRUE);
                System.debug('Following Exception Occue In IF---------> ' + e);
            }
            
        }
        else if(action == 'insertRecords'){
            try{
                insert scope;
                System.debug('data inserted successfully');
            }
            catch(Exception e){
                UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, UTL_LogFactory.GUID, e.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + e.getLineNumber() + ':::BCH_TPA_AMA_ContractDtl_CSV_import:::in insert records', ''));
                UTL_LogFactory.saveLogs(UTL_LogFactory.getLogLst(), TRUE);
                System.debug('Following Exception Occue In IF---------> ' + e);
            }
            
        }
    }

    public void finish(Database.BatchableContext context) {
        if(action == 'deleteRecords'){
            BCH_TPA_AMA_ContractDtl_CSV_import bchObj = new BCH_TPA_AMA_ContractDtl_CSV_import();
            bchObj.action = 'insertRecords';
            bchObj.contractsListToInsert = contractsListToInsert;
            Database.executeBatch(bchObj);
        }
        else if(action == 'insertRecords'){
            Database.executeBatch(new BCH_TPA_AMA_New_Client_Vendor_Script(), 200);
        }
    }
}