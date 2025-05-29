/*
 * Version       : 1.0
 * Description   : This Apex class is selector layer for OWF_ReBidFieldMapping Metadata Type.
 */
public class SLT_OWF_ReBidFieldMapping extends fflib_SObjectSelector {

    public SLT_OWF_ReBidFieldMapping(Boolean enforceCRUD, Boolean enforceFLS) {
       super(false, enforceCRUD, enforceFLS);
   }
    
    /**
     * This method used to set field list of ReBidFieldMapping metadata.
     */
    public Set<String> fieldSet{
        get{
            fieldSet = new Set<String>();
            fieldSet.add('BidType__c');
            fieldSet.add('RecordType__c');
            fieldSet.add('SourceObject__c');
            fieldSet.add('SourceType__c');
            fieldSet.add('SourceValue__c');
            fieldSet.add('TargetField__c');
            fieldSet.add('DeveloperName');
            return fieldSet;
        } 
        set {
              fieldSet = value;        
        }
    }
        
    /**
     * This method used to get field list of sobject
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>();
    }
    
    /**
     * This method used to set up type of sobject
     * @return  Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return OWF_ReBidFieldMapping__mdt.sObjectType;
    }
    
    /**
     * This method used to get all records of ReBidFieldMapping
     * @return  List<OWF_ReBidFieldMapping__mdt>
     */
    public List<OWF_ReBidFieldMapping__mdt> getReBidFieldMapping() { 
        return (List<OWF_ReBidFieldMapping__mdt>) Database.query(newQueryFactory(true).selectFields(fieldSet).toSOQL());
    }
}