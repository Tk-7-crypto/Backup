/**
 * This is Report Country (Report_Country__c) trigger handler class.
 * version : 1.0
 */
public class DAO_Report_Country extends fflib_SObjectDomain {
    
    private static Map<String, Set<String>> methodToRecordTypeMap = new Map<String, Set<String>>();

    /**
     * Constructor of this class
     * @params sObjectList List<Report_Country__c>
     */
    public DAO_Report_Country(List<Report_Country__c> sObjectList) {
        super(sObjectList);

    }

    /**
     * Constructor Class for construct new Instance of This Class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new DAO_Report_Country(sObjectList);
        } 
    }
    
    /**
     * This method is used for after insert of the Report_Country__c  trigger.
     * @return void
     */
    public override void onAfterInsert() {
        DAOH_Report_Country.insertAuditLogOnUpdate((List<Report_Country__c>)Records, null);
    }

    /**
     * This method is used for after update of the Report_Country__c trigger.
     * @return  void
     */
    public override void  onAfterUpdate(Map<Id,SObject> existingRecords) {
        DAOH_Report_Country.insertAuditLogOnUpdate((List<Report_Country__c>)Records, (Map<Id,Report_Country__c>) existingRecords);
    }

    /**
     * This method is used for after insert of the Report_Country__c trigger.
     * @return void
     */
    public override void onAfterDelete() {
        DAOH_Report_Country.insertAuditLog((List<Report_Country__c>)Records,'DELETE');
    }

    /**
     * This method is used for after undelete of the Report_Country__c trigger.
     * @return void
     */
    public override void onAfterUnDelete() {
        DAOH_Report_Country.insertAuditLog((List<Report_Country__c>)Records,'UNDELETE');
    }
    
    /**
     * This method is used for before insert of the Aggregate_Report__c  trigger.
     * @return void
     */
    public override void onBeforeInsert() {
        DAOH_Report_Country.fieldValidations((List<Report_Country__c>)Records,null);
    }
    
    /**
     * This method is used for before update of the Aggregate_Report__c  trigger.
     * @return void
     */
    public override void onBeforeUpdate(Map<Id,SObject> existingRecords) {
        DAOH_Report_Country.fieldValidations((List<Report_Country__c>)Records,(Map<Id,Report_Country__c>) existingRecords);
    }
}
