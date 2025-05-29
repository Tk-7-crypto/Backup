/**
 * @author Vlad Tyazhov
 * Apex trigger for copado__Promotion__c. Use DAO_TriggerHandlerProvider to call handlers from metadata.
 */
trigger TGR_CopadoPromotion on copado__Promotion__c (after insert) {
    DAO_TriggerHandlerProvider.execute();  // calls DAO_CopadoPromotionHandler
}