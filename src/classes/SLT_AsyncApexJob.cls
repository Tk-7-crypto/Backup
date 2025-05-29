/*
 * Version       : 1.0
 * Description   : This Apex class is selector layer for AsyncApexJob batch job object
 */
public with sharing class SLT_AsyncApexJob extends fflib_SObjectSelector {

    /**
     * constructor to initialize include Fieldset fields
     */
    public SLT_AsyncApexJob() {
        super(true);
    }

    /**
     * This method used to get field list of sobject
     * @return  List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>();
    }

    /**
     * This method used to set up type of sobject
     * @return  Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return AsyncApexJob.SObjectType;
    }

    /**
     * This method used to get the Apex Job with the specified id
     * @param   Id jobId
     * @param   List<String> fieldSet
     * @return  List<OCE_Bundle_Clone_Settings__mdt>
     */
    public AsyncApexJob getJobFieldsForId(Id jobId, Set<String> fieldSet) {
        return (AsyncApexJob) Database.query(
            newQueryFactory(true)
            .setCondition('Id = :jobId')
            .selectFields(fieldSet)
            .setLimit(1)
            .toSOQL());
    }

    /**
     * Returns job information for sepcific job ids
     */
    public Map<Id, AsyncApexJob> findJobs(Set<Id> asyncApexJobIds, Set<String> fieldSet) {
        return new Map<Id,AsyncApexJob>((AsyncApexJob[])
            Database.query(
                newQueryFactory(true)
                .setCondition('Id in :asyncApexJobIds')
                .selectFields(fieldSet)
                .toSOQL()
            )
        );
    }

}