/*
 * Version       : 1.0
 * Description   : This Apex class is selector layer for Case
 */
public class SLT_Apex_RecordType_Control extends fflib_SObjectSelector {

    /**
     * constructor to initialize CRUD and FLS
     */
    public SLT_Apex_RecordType_Control() {
        super(false, false, false);
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
        return Apex_RecordType_Control__mdt.sObjectType;
    }

    /**
     * This method used to get Apex RecordType Control by Id
     * @return  Map<Id, Apex_RecordType_Control__mdt>
     */
    public List<Apex_RecordType_Control__mdt> getRecordTypeControls(string objectType) {
        Set<String> fieldset = new Set<String>{'Label', 'Method_Name__c','RecordType__c'};
        return (List<Apex_RecordType_Control__mdt>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Object__c = :objectType and Active__c = true').toSOQL());
    }

    /**
     * This returns a map of methods to list of recordtypes for the object
     */
      public Map<String, Set<String>> getRecordTypeControlMap (string objectType) {
        Map<String, Set<String>> methodToRecordTypeMap = new Map<String, Set<String>>();
        List<Apex_RecordType_Control__mdt> recordTypeControlList = getRecordTypeControls(objectType);

        for (Apex_RecordType_Control__mdt arc : recordTypeControlList) {
            Set<String> tempRecordTypeSet = methodToRecordTypeMap.get(arc.Method_Name__c);

            if (tempRecordTypeSet != null) {
                tempRecordTypeSet.add(arc.RecordType__c);
                methodToRecordTypeMap.put(arc.Method_Name__c,tempRecordTypeSet);
            } else {
                methodToRecordTypeMap.put(arc.Method_Name__c, new Set<String>{arc.RecordType__c});
            }
        }
        
        return methodToRecordTypeMap;
    }
}