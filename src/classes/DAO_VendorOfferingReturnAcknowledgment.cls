public class DAO_VendorOfferingReturnAcknowledgment extends fflib_SObjectDomain {
    /**
     * Constructor of this class
     * @params sObjectList List<SObject>
     */
    public DAO_VendorOfferingReturnAcknowledgment(List<SObject> sObjectList) {
        super(sObjectList);
    }

    /**
     * Constructor Class for construct new Instance of This Class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new DAO_VendorOfferingReturnAcknowledgment(sObjectList);
        }
    }
    
    /**
     * This method is used for before update of the Vendor_Offering_Return_Acknowledgment__c trigger.
     * @params  existingRecords Map<Id,SObject>
     * @return  void
     */
    public override void onafterinsert() {
        if(!UTL_TPA.tpaSetting.Is_Skip_TPA_Triggers__c) {
            DAOH_VendorOfferingReturnAcknowledgment.onAfterInsert((List<Vendor_Offering_Return_Acknowledgment__c>)Records);
        }
    }

    public override void onbeforeinsert() {
        if(!UTL_TPA.tpaSetting.Is_Skip_TPA_Triggers__c) {
            DAOH_VendorOfferingReturnAcknowledgment.onBeforeInsert((List<Vendor_Offering_Return_Acknowledgment__c>)Records);
        }
    }

}
