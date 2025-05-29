/**
 * Update Active Resource on Literature project
 */
public class BCH_PSA_UpdateActiveResourceOnProj implements Database.Batchable<sObject>,Database.Stateful{
    DateTime yesterdayDateTime = System.now().addDays(-1);
    List<String> errorMessageList = new List <String>();
    public String batchMode = '';
    public void ExecuteMode(List<string> mode){
        for(String m : mode){
            batchMode = m;
        }
    }
    public Database.QueryLocator start(Database.BatchableContext BC){
        String query ='';
        if(batchMode == 'UpdateHistoricalDataOnce'){
            query = 'SELECT id FROM pse__Proj__c WHERE Id IN '+
                    '(SELECT pse__Project__c '+
                    'FROM pse__Assignment__c '+
                    'WHERE Active__c = TRUE '+
                    'AND pse__Status__c != \'Closed\' '+
                    'AND pse__Status__c != \'Cancelled\' '+
                    'AND pse__Resource__r.pse__Is_Resource_Active__c = TRUE '+
                    'AND pse__Project__r.Service_Line__r.Name =\'Literature\')';
        }else{
            System.debug('testing');
            query = 'SELECT id FROM pse__Proj__c WHERE Id IN '+
                    '(SELECT pse__Project__c '+
                    'FROM pse__Assignment__c '+
                    'WHERE Active__c = TRUE '+
                    'AND pse__Status__c != \'Closed\' '+
                    'AND pse__Status__c != \'Cancelled\' '+
                    'AND pse__Resource__r.LastModifiedDate >=:yesterdayDateTime '+
                    'AND pse__Project__r.Service_Line__r.Name =\'Literature\')';
        }
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<pse__Proj__c> records) {
        Set<Id> projectIdSet = new Set<Id>();
        for(pse__Proj__c  project : records){
            projectIdSet.add(project.Id);
        }
        if(!projectIdSet.isEmpty()){
            try{
               UTL_PSA.updateActiveResourceLitertureProjectList(projectIdSet); 
            }catch(Exception ex){
                 errorMessageList.add('Errors : ' + ex.getMessage());
            }
        }
    }

    public void finish(Database.BatchableContext BC){
        if (((errorMessageList != null && errorMessageList.size() > 0) || Test.isRunningTest())){
            for(String errMsg : errorMessageList){
                UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, UTL_LogFactory.GUID, errMsg, 'PSA', 'Exception', 'ERROR', ':::BCH_PSA_UpdateActiveResourceOnProj:::Update Active Resource on Literature project Exception', null));
                UTL_LogFactory.saveLogs(UTL_LogFactory.getLogLst(), False); 
            }
        }
    }

}
