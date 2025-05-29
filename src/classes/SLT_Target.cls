/*
 * Version       : 1.0
 * Description   : This Apex class is selector layer for SLT_Target
 */
public class SLT_Target extends fflib_SObjectSelector {
    
    /**
     * constructor to initialize CRUD and FLS
     */
    public SLT_Target () {
        super(false, true, false);
    }
    
    /**
     * This method used to get field list of sobject
     * @return  List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList () {
        Schema.DescribeSObjectResult describeResult = getSObjectType().getDescribe(); 
        Map<String,Schema.SObjectField> fieldsMap = describeResult.fields.getMap();   
        return fieldsMap.values();
    }

    /**
     * This method used to get field set of field names for the sobject
     * @return  Set<String>
     */
    public Set<String> getSObjectFieldSet () {
        Set<String> fieldNames = new Set<String>();
        List<Schema.SObjectField> fields = getSObjectFieldList();
        if (fields != null && fields.size() > 0) {
            for (Schema.SObjectField sobjField : fields) {
                fieldNames.add(String.valueof(sobjField));
            }
        }        
        return fieldNames;
    }    
    
    /**
     * This method used to set up type of sobject
     * @return  Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType () {
        return Target__c.sObjectType;
    }

    /**
     * This method used to get Target by Program Id
     * @return  List<Target__c>
     */
    public List<Target__c> getTargetByProgram(Id programId) {
        return getTargetByProgram(programId, getFields());
    }

    public List<Target__c> getTargetByProgram(Id programId, Set<String> fieldSet) {
        return (List<Target__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Program__c = :programId').toSOQL());
    }

    public List<Target__c> getTargetByProgram(Id programId, Id recordTypeId, Set<String> fieldSet){
        String condition = 'Program__c = :programId AND RecordTypeId = :recordTypeId';
        return (List<Target__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition(condition).toSOQL());
    }

    public Map<Id, List<Target__c>> getTargetByProgram(Set<id> setProgramIds, Id recordTypeId, Set<String> fieldSet){
        Map<Id, List<Target__c>> returnMap = new Map<Id, List<Target__c>>();
        String condition = 'Program__c in: setProgramIds AND RecordTypeId = :recordTypeId AND Active__c = true';

        for (Target__c tar : (List<Target__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition(condition).toSOQL())) {
            List<Target__c> tempList = returnMap.get(tar.Program__c);
            
            if (tempList != null) {
                tempList.add(tar);
                returnMap.put(tar.Program__c, tempList);
            } else {
                returnMap.put(tar.Program__c, new List<Target__c>{tar});
            }
        }
        return returnMap;
    }
    
    public list<Target__c> getTargetById(Set<ID> idSet, Set<String> fieldSet) {
        return (List<Target__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Id in :idSet').toSOQL());
    }

    public Set<String> getFields(){
        return new Set<String>{'Id', 'Name', 'API__c', 'Strength__c', 'Dosage_Form__c'};
    }
} 
