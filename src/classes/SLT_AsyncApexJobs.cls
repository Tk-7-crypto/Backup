/*
 * Version       : 1.0
 * Description   : This Apex class is selector layer for AsyncApexJobs
 */
public class SLT_AsyncApexJobs extends fflib_SObjectSelector{
    
    /**
     * constructor to initialize CRUD and FLS
     */
    public SLT_AsyncApexJobs() {
        super(false, true, true);
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
    public Schema.SObjectType getSObjectType(){
        return AsyncApexJob.sObjectType;
    }
    
     /**
     * Retrieves a list of AsyncApexJob records with specific fields.
     * @return Map<Id, AsyncApexJob> of AsyncApexJob records
     */ 
    public Map<Id, AsyncApexJob> Asyncdata (Set<Id> jobIds , Set<String> fieldSet) {
        return new Map<Id, AsyncApexJob>((List<AsyncApexJob>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Id in :jobIds').toSOQL()));
    }

}