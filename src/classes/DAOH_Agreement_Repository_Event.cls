public class DAOH_Agreement_Repository_Event {
    public static void updateARComments(List<Agreement_Repository_Event__e> Records) {
        List<sObject> sobjectList = new List<sObject>();        
        for(Agreement_Repository_Event__e arEvent : (List<Agreement_Repository_Event__e>)Records) {
            if(arEvent.Object_Name__c == CON_CLM.OPP_OBJ_API_NAME) {
                Opportunity opp = new Opportunity(Id = arEvent.Record_Id__c, AR_Comments__c = arEvent.AR_Comments__c);
                sobjectList.add(opp);
            }              
            else if(arEvent.Object_Name__c == CON_CLM.IQVIA_AGR_OBJ_NAME) {
                IQVIA_Agreement__c agreement = new IQVIA_Agreement__c(Id = arEvent.Record_Id__c, Agreement_Repository_Number__c = arEvent.AR_Comments__c);
                sobjectList.add(agreement);
            }               
            else if(arEvent.Object_Name__c == CON_CLM.BNF_OBJ_API_NAME) {
                BNF2__c bnf = new BNF2__c(Id = arEvent.Record_Id__c, AR_Comments__c = arEvent.AR_Comments__c);
                sobjectList.add(bnf);
            }               
            else if(arEvent.Object_Name__c == CON_CLM.MIBNF_OBJ_API_NAME) {
                MIBNF_Component__c miBnf = new MIBNF_Component__c(Id = arEvent.Record_Id__c, AR_Comments__c = arEvent.AR_Comments__c);
                sobjectList.add(miBnf);
            }
        }
        if(!sobjectList.isEmpty()) {
            try{
                fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
                    new List<SObjectType> {Opportunity.SObjectType, IQVIA_Agreement__c.SObjectType, BNF2__c.SObjectType, MIBNF_Component__c.SobjectType}
                );
                uow.registerDirty(sobjectList);
                uow.commitWork();
            }
            catch(DMLException dmlExp) {
                System.debug(System.LoggingLevel.ERROR, dmlExp.getMessage() + ' \n ' + dmlExp.getStackTraceString());
                EventBus.publish(new Apex_Error_Log_Event__e(
                    Object__c = CON_CLM.AR_EVENT_API_NAME,
                    Error_Message__c = dmlExp.getMessage() + '\n' + dmlExp.getStackTraceString(),
                    Running_User__c = UserInfo.getUserId(),
                    Source_Module__c = 'CLM'
                ));
            } 
        }                   
    }
}