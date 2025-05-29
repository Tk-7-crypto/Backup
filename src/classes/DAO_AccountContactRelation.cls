/**
 * This is AccountContactRelation trigger handler class.
 * version : 1.0
 */ 
public class DAO_AccountContactRelation extends fflib_SObjectDomain{
    
    /**
     * Constructor of this class
     * @params sObjectList List<AccountContactRelation>
     */
	public DAO_AccountContactRelation(List<SObject> sObjectList) {
        super(sObjectList);
    }
    
    /**
     * Constructor Class for construct new Instance of This Class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new DAO_AccountContactRelation(sObjectList);
        }
    }
    
    /**
     * Override method before Insert Call
     */
    public override void onBeforeInsert(){
        DAOH_AccountContactRelation.preventDuplicateAccountContactRelationOnAccount((List<AccountContactRelation>)records, null);
    } 
    
    /**
     * Override method before update Call
     */
    public override void onBeforeUpdate(Map<Id,SObject> existingRecords){
        DAOH_AccountContactRelation.preventDuplicateAccountContactRelationOnAccount((List<AccountContactRelation>)records, (Map<Id, AccountContactRelation>)existingRecords);
    }
    
}