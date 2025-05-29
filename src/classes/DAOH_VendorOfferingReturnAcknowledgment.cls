public class DAOH_VendorOfferingReturnAcknowledgment {
    public static void onAfterInsert(List<Vendor_Offering_Return_Acknowledgment__c> newRecords) {
        TGRH_VendorOfferingReturnAck.updateAddressExtensionRecords(newRecords);
    }
    public static void onBeforeInsert(List<Vendor_Offering_Return_Acknowledgment__c> newRecords) {
        TGRH_VendorOfferingReturnAck.updateExcludedOfferingsDetails(newRecords);
    }
}
