/**
 * This is OpportunityLineItemSchedule Domain handler class.
 * version : 1.0
 */
public class DAOH_OpportunityLineItemSchedule {
    
    /**
     * This method is used to update Outbound Message Deletion Queue
     * @params  List<OpportunityLineItemSchedule> deleteList
     * @return  void
     */
    public static void createOutboundMessageDeletionQueue(List<OpportunityLineItemSchedule> deleteList) {
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork( new Schema.SObjectType[] { Outbound_Message_Deletion_queue__c.SobjectType });
        Boolean toCommit = false;
        Outbound_Message_Deletion_queue__c outBound;
        for(OpportunityLineItemSchedule olis : deleteList) {
            outBound = new Outbound_Message_Deletion_queue__c();
            outBound.Operation__c = CON_CRM.DELETE_LABEL;
            outBound.SObjectType__c = CON_CRM.OPPORTUNITYLINEITEMSCHEDULE_OBJECT_API;
            outBound.RecordID__c = olis.Id;
            outBound.LI_Id__c = olis.OpportunityLineItemId;
            uow.registerNew(outBound);
            toCommit = true;
        }
        
        if(toCommit) {
            uow.commitWork();
        }
    }
}