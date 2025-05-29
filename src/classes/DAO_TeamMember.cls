/**
 * This is Team Member trigger handler class.
 * version : 1.0 
 */
public class DAO_TeamMember extends fflib_SObjectDomain
{    
    /**
     * Constructor of this class
     * @params sObjectList List<Team_Member__c>
     */
    public DAO_TeamMember(List<Team_Member__c> sObjectList)
    {
        super(sObjectList);
    }
    
    /**
     * Constructor Class for construct new Instance of This Class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable
    {
        public fflib_SObjectDomain construct(List<SObject> sObjectList)
        {
            return new DAO_TeamMember(sObjectList);
        }
    }

    /**
    * Unit of Work instance for CRUD operation
    */
    public static fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork
    (
        new Schema.SObjectType[] 
        {
            Outbound_Message_Deletion_queue__c.SobjectType
        }
    );
    
    public override void onApplyDefaults() {}

    /**
     * This method is used for before insert of the Team Member trigger.
     * @return void
     */
     
    public override void onBeforeInsert() {
    }
    /**
     * This method is used for after update of the Team Member trigger.
     * @return void
     */
    public override void onAfterUpdate(Map<Id,SObject> existingRecords) 
    {
        /*Commented under LC-11457 to deactivate approval process
        DAOH_TeamMember.recallOldAndSubmitProposalForNewApproval((List<Team_Member__c>)Records, 
                                                             (Map<Id, Team_Member__c>)existingRecords);*/
        /*Commented under LC-10187 to remove ref of Reviewer/Final Reviewer picklist value from Team Member object
        DAOH_TeamMember.sendQCNotification((List<Team_Member__c>)Records, 
                                                             (Map<Id, Team_Member__c>)existingRecords);*/
    }
    
    public override void onAfterDelete() {
        /*Commented under LC-11457 to deactivate approval process
        DAOH_TeamMember.recallApprovalProcessOnDeletion((List<Team_Member__c>)Records);*/
    }
    
    public override void onBeforeUpdate(Map<Id, SObject> existingRecords) {
    }


}