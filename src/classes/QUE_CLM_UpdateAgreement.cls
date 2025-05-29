/*
    Queueable for updating the agreement
*/
public class QUE_CLM_UpdateAgreement implements Queueable {
    List<Apttus__APTS_Agreement__c> agreementList = new List<Apttus__APTS_Agreement__c>();
    public QUE_CLM_UpdateAgreement(List<Apttus__APTS_Agreement__c> agreementList) {
        this.agreementList = agreementList;
    }
    
    public void execute(QueueableContext qc) {
        if(!agreementList.isEmpty()) {
            try {  
                UTL_ExecutionControl.skipValidate = true;
                fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
                    new Schema.SObjectType[] {
                        Apttus__APTS_Agreement__c.SObjectType
                    }
                );
                uow.registerDirty(agreementList);
                uow.commitWork();
            } catch(Exception e) {
                System.debug(System.LoggingLevel.ERROR, e.getMessage() + ' \n ' + e.getStackTraceString());
                for(SObject record : agreementList) {
                    EventBus.publish(new Apex_Error_Log_Event__e(
                    Object__c = 'Apttus__APTS_Agreement__c',
                    Error_Message__c = 'Error in DocumentVersion trigger future call' +'\n'+e.getMessage() + '\n' + e.getStackTraceString(),
                    Record_Id__c = record.Id,
                    Running_User__c = UserInfo.getUserId(),
                    Source_Module__c = 'CLM'));
                }
                UTL_ExecutionControl.skipValidate = false;
            }
        }
    }
}