/**
 * @author Vlad Tyazhov
 * Apex trigger for copado__User_Story__c. Use DAO_TriggerHandlerProvider to call handlers from metadata.
 */
trigger TGR_CopadoUserStory on copado__User_Story__c (after insert, after update) {
    DAO_TriggerHandlerProvider.execute();  // calls DAO_CopadoUserStoryHandler
}