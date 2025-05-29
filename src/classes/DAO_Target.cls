/**
 * This is Target__c (Target__c) trigger handler class.
 * version : 1.0
 */
public class DAO_Target extends fflib_SObjectDomain {
    
    private static Map<String, Set<String>> methodToRecordTypeMap = new Map<String, Set<String>>();

    /**
     * Constructor of this class
     * @params sObjectList List<Target__c>
     */
    public DAO_Target(List<Target__c> sObjectList) {
        super(sObjectList);

        methodToRecordTypeMap = new SLT_Apex_RecordType_Control().getRecordTypeControlMap((String)sObjectList.getSObjectType().getDescribe().getName());
    }
 
    /**
     * Constructor Class for construct new Instance of This Class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new DAO_Target(sObjectList);
        }
    }
    
    /**
     * This method is used for before insert of the Target__c trigger.
     * @return void
     */
    public override void onBeforeInsert() {
        if (methodToRecordTypeMap.get('setFieldUpdates') != null) {
            DAOH_Target.setFieldUpdates((List<Target__c>)Records,null, methodToRecordTypeMap);
        }
        
        if (methodToRecordTypeMap.get('manageDatesOnActiveToggle') != null) {
           DAOH_Target.manageDatesOnActiveToggle((List<Target__c>)Records,null, methodToRecordTypeMap);   
        }
        DAOH_Target.targetNamingConvention((List<Target__c>)Records,null);
    }

    /**
     * This method is used for after insert of the Target__c trigger.
     * @return void
     */
    public override void onAfterInsert() {
        DAOH_Target.insertAuditLogOnUpdate((List<Target__c>)Records, null);
        DAOH_Target.updateHAWebsitesReviewRecords((List<Target__c>)Records, null,methodToRecordTypeMap);
        DAOH_Target.pvAgreeMentTargetNamingConvention((List<Target__c>)Records, null);
    }

    /**
     * This method is used for after update of the Target__c trigger.
     * @return  void
     */
    public override void  onAfterUpdate(Map<Id,SObject> existingRecords) {
       DAOH_Target.insertAuditLogOnUpdate((List<Target__c>)Records, (Map<Id,Target__c>) existingRecords);
       DAOH_Target.updateHAWebsitesReviewRecords((List<Target__c>)Records, (Map<Id,Target__c>) existingRecords,methodToRecordTypeMap);
    }

    /**
     * This method is used for after insert of the Target (Target__c) trigger.
     * @return void
     */
    public override void onAfterDelete() {
        DAOH_Target.insertAuditLog((List<Target__c>)Records,'DELETE');
    }

    /**
     * This method is used for after undelete of the Target (Target__c) trigger.
     * @return void
     */
    public override void onAfterUnDelete() {
        DAOH_Target.insertAuditLog((List<Target__c>)Records,'UNDELETE');
    }
    
    /**
     * This method is used for before update of the Target (Target__c) trigger.
     * @return void
     */
    public override void onBeforeUpdate(Map<Id,SObject> existingRecords) {
        if (methodToRecordTypeMap.get('manageDatesOnActiveToggle') != null) {
           DAOH_Target.manageDatesOnActiveToggle((List<Target__c>)Records,null, methodToRecordTypeMap);   
        }
        /*
         *IQVIAPSA-4953 
         */
        DAOH_Target.preventDeactiveTarget((List<Target__c>)Records, (Map<Id,Target__c>) existingRecords);
    }
}
