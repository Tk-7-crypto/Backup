/**
 * @author Vlad Tyazhov
 * Apex trigger for copado__Sprint__c. Use DAO_TriggerHandlerProvider to call handlers from metadata.
 */
trigger TGR_CopadoSprint on copado__Sprint__c (after insert) {
    DAO_TriggerHandlerProvider.execute();  // calls DAO_CopadoSprintHandler
}