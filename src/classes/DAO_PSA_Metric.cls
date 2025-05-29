/**
 * This is PSA_Metric__c (PSA_Metric__c) trigger handler class.
 * version : 1.0
 */
public class DAO_PSA_Metric extends fflib_SObjectDomain {
    
    private static Map<String, Set<String>> methodToRecordTypeMap = new Map<String, Set<String>>();

    /**
     * Constructor of this class
     * @params sObjectList List<PSA_Metric__c>
     */
    public DAO_PSA_Metric(List<PSA_Metric__c> sObjectList) {
        super(sObjectList);
		methodToRecordTypeMap = new SLT_Apex_RecordType_Control().getRecordTypeControlMap((String)sObjectList.getSObjectType().getDescribe().getName());
    }
 
    /**
     * Constructor Class for construct new Instance of This Class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new DAO_PSA_Metric(sObjectList);
        }
    }
    
    /**
     * This method is used for before insert of the PSA_Metric__c trigger.
     * @return void
     */
    public override void onBeforeInsert() {
        DAOH_PSA_Metric.setNonStandardField((List<PSA_Metric__c>)Records,null);
    }
    
    /**
     * This method is used for before update of the Target (Target__c) trigger.
     * @return void
     */
    public override void onBeforeUpdate(Map<Id,SObject> existingRecords) {
        DAOH_PSA_Metric.setNonStandardField((List<PSA_Metric__c>)Records, (Map<Id,PSA_Metric__c>) existingRecords);
    }
}
