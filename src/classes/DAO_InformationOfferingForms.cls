public class DAO_InformationOfferingForms extends fflib_SObjectDomain {

    /**
     * Constructor of this class
     * @params sObjectList List<Information_Offering_Forms__c>
     */
    public DAO_InformationOfferingForms(List<Information_Offering_Forms__c> sObjectList) {
        super(sObjectList);
    }

    /**
     * Constructor Class for construct new Instance of This Class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new DAO_InformationOfferingForms(sObjectList);
        }
    }

    /**
     * This method is used for before insert of the Information_Offering_Forms__c trigger.
     * @return void
     */
    public override void onBeforeInsert() {
        DAOH_InformationOfferingForms.checkOfferingRecords((List<Information_Offering_Forms__c>)Records);
    }
    /**
     * This method is used for after insert of the Information_Offering_Forms__c trigger.
     * @return void
     */
    public override void onAfterInsert() {
        DAOH_InformationOfferingForms.updateParentCaseFields((List<Information_Offering_Forms__c>)Records, null);
    }
    
    /**
     * This method is used for before update of the Information_Offering_Forms__c trigger.
     * @return void
     */
    public override void onBeforeUpdate(Map<Id, SObject> existingRecords) {
        DAOH_InformationOfferingForms.updateParentCaseFields((List<Information_Offering_Forms__c>)Records, (Map<Id, Information_Offering_Forms__c>)existingRecords);
    }

    /**
     * This method is used for before delete of the Information_Offering_Forms__c trigger.
     * @return void
     */    
    public override void onBeforeDelete() {
       DAOH_InformationOfferingForms.updateParentCaseFields((List<Information_Offering_Forms__c>)Records, null);
    }

}