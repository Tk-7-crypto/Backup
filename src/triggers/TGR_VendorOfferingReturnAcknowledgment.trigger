trigger TGR_VendorOfferingReturnAcknowledgment on Vendor_Offering_Return_Acknowledgment__c (before insert,after insert) {
    fflib_SObjectDomain.triggerHandler(DAO_VendorOfferingReturnAcknowledgment.class);
}
