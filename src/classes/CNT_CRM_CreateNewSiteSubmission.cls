/**
* Created by Ronak Mehta on 10-Jan-2025
* Description : Contain common Methods to support LWC componet: LwcCrmCreateNewSiteSubmission
**/
public class CNT_CRM_CreateNewSiteSubmission {
    
    /**
     * This Method create record for Site Submission.
     * @params String selectedAccounts
     * @params String parentId
     * @return Boolean
     **/
    @AuraEnabled(Cacheable = false)
    public static Boolean createSiteSubmissionRecords(String selectedAccounts, String parentId){
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
            new Schema.SObjectType[] {Site_Submission__c.SobjectType}
        );
        Boolean toCommit = false;
        if(selectedAccounts != null && selectedAccounts != ''){
            List<String> listOfAccountId = selectedAccounts.split(',');
            if(listOfAccountId != null && listOfAccountId.size() > 0){
                for(String site: listOfAccountId){
                    Site_Submission__c ss = new Site_Submission__c();
                    ss.Site__c = site;
                    ss.Status__c = 'Submitted';
                    ss.Opportunity__c = parentId;
                    uow.registerNew(ss);
                    toCommit = true;
                }
            }
        }
        if(toCommit) {
            uow.commitWork();
            return true;
        }
        return false;
    }
}