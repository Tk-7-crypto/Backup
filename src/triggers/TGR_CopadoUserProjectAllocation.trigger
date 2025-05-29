/**
 * @author Vlad Tyazhov
 * Apex trigger for User_Project_Allocation__c. Use DAO_TriggerHandlerProvider to call handlers from metadata.
 */
trigger TGR_CopadoUserProjectAllocation on User_Project_Allocation__c (before insert, before update, after insert, after update, after delete) {
    DAO_TriggerHandlerProvider.execute();  // calls DAO_CopadoUserProjectAllocationHandler
}