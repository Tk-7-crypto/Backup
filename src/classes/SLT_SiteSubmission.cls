/*
 * Version       : 1.0
 * Description   : This Apex class is selector layer for Site Submission
 */
public class SLT_SiteSubmission extends fflib_SObjectSelector {
     /**
     * constructor to initialize CRUD and FLS
     */
    public SLT_SiteSubmission() {
        super(false, true, false);
    }
    
    /**
     * This method used to set up type of sobject
     * @return  Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return Site_Submission__c.sObjectType;
    }
    
    /**
     * This method used to get field list of sobject
     * @return  List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>();
    }
    
    public List<Site_Submission__c> getSiteSubmissionByOppId(Set<Id> oppIdSet,Set<String> fieldSet){
        return (List<Site_Submission__c>) Database.query(newQueryFactory(false).selectFields(fieldSet).setCondition('Opportunity__c in :oppIdSet').toSOQL());
    }
    
    /**
     * This method used to Select Site Submission By Id
     * @param Set<Id> IdSet
     * @param Set<String> fieldSet
    */
    public List<Site_Submission__c> getSiteSubmissionById(Set<Id> IdSet,Set<String> fieldSet){
        return (List<Site_Submission__c>) Database.query(newQueryFactory(false).selectFields(fieldSet).setCondition('Id in :IdSet').toSOQL());
    }
    
}