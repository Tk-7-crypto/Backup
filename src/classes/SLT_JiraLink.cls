/*
 * Version       : 1.0
 * Description   : This Apex class is selector layer for JiraLink
 */
public class SLT_JiraLink extends fflib_SObjectSelector {
    /**
     * This method used to get field list of sobject
     */

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
                   CSM_QI_JiraLink__c.Id
        };
    }

    /**
     * This method used to set up type of sobject
     * @return  Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return CSM_QI_JiraLink__c.sObjectType;
    }

    /**
     * This method used to get CSM_QI_JiraLink__c by Id
     * @return  List<CSM_QI_JiraLink__c>
     */
    public List<CSM_QI_JiraLink__c> selectById(Set<ID> idSet) {
        return (List<CSM_QI_JiraLink__c>) selectSObjectsById(idSet);
    }

    /**
     * This method used to get CSM_QI_JiraLink__c by CaseId
     * @return  List<CSM_QI_JiraLink__c>
     */
    public List<CSM_QI_JiraLink__c> selectByCaseId(Set<ID> CaseId) {
        return [SELECT Id, CreatedDate, assignee__c, case_recordId__c, description__c, issue_type__c, jira_base_url__c, jira_key__c, priority__c, reporter__c, status__c, summary__c, fixVersions__c, PSA_Project__c, country__c, customer__c, due_date__c, CSM_User_Reporter__c,CSM_User_Reporter__r.Name, Sprint__c, Sprint_Time_Stamp__c, Days_Open__c, Jira_Created_Date__c, Jira_Updated_Date__c, Epic_Link__c, Epic_Name__c FROM CSM_QI_JiraLink__c WHERE case_recordId__c=: CaseId];
    }
}