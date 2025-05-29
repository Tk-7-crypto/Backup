/**
* This is Journals Main Catalogue trigger DAO class.
* version : 1.0
*/
public class DAO_PSA_Journals_Main_Catalogue extends fflib_SObjectDomain{
    /**
     * Constructor of this class
     * @params sObjectList List<Journals_Main_Catalogue__c>
     */
    public DAO_PSA_Journals_Main_Catalogue(List<Journals_Main_Catalogue__c> sObjectList) {
        super(sObjectList);
    }
    
    /**
     * Constructor Class for construct new Instance of This Class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new DAO_PSA_Journals_Main_Catalogue(sObjectList);
        }
    }
    
    /**
     * This method is used for after insert of the Journals Main Catalogue trigger.
     * @return void
     */
    public override void onAfterInsert() {
        DAOH_PSA_Journals_Main_Catalogue.insertAuditLogOnUpdate((List<Journals_Main_Catalogue__c>)Records, null);
    }
    
    /**
    * This method is used for after update of the Journals Main Catalogue trigger.
    * @return void
    */
    public override void onAfterUpdate(Map<Id,SObject> existingRecords) {
        DAOH_PSA_Journals_Main_Catalogue.synchValueForEJ((List<Journals_Main_Catalogue__c>)Records, (Map<Id,Journals_Main_Catalogue__c>) existingRecords);
        DAOH_PSA_Journals_Main_Catalogue.insertAuditLogOnUpdate((List<Journals_Main_Catalogue__c>)Records, (Map<Id,Journals_Main_Catalogue__c>) existingRecords);
    }
    
    /**
     * This method is used for after Delete of the Journals Main Catalogue trigger.
     * @return void
     */
    public override void onAfterDelete() {
        DAOH_PSA_Journals_Main_Catalogue.insertAuditLog((List<Journals_Main_Catalogue__c>)Records,'DELETE');
    }
    
    /**
     * This method is used for after undelete of the Journals Main Catalogue trigger.
     * @return void
     */
    public override void onAfterUnDelete() {
        DAOH_PSA_Journals_Main_Catalogue.insertAuditLog((List<Journals_Main_Catalogue__c>)Records,'UNDELETE');
    }

}