/**
 * This is Attachment DAO class.
 * version: 1.0
 */
public class DAO_Attachment extends fflib_SObjectDomain {

    /**
     * Constructor of this class
     * @params sObjectList List<Attachment>
     */
    public DAO_Attachment(List<Attachment> sObjectList) {
        super(sObjectList);
    }

    /**
     * Constructor Class to construct new Instance of This Class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new DAO_Attachment(sObjectList);
        }
    }

    /**
     * This method is used for before insert of the Attachment trigger.
     * @return void
     */
    public override void onBeforeInsert() {
        //This is the section where all the methods that needs to be run at first are included.
        //This should be at the top since the trigger execution flags are reset in this method

        //This is the section where all the methods that needs to be run in a normal sequence are included.
        DAOH_Attachment.handleOnBeforeInsertAttachment((List<Attachment>)Records);
        DAOH_Attachment.updateContractOnAttachment((List<Attachment>)Records);
        //This is the section where all the methods that needs to be run at last are included.
        //This should be at the last since it will integrate the opp with the latest changes
    }

    /**
     * This method is used for before update of the Attachment trigger.
     * @params  existingRecords Map<Id,SObject>
     * @return  void
     */
    public override void onBeforeUpdate(Map<Id, SObject> existingRecords) {
        DAOH_Attachment.handleOnBeforeUpdateAttachment((List<Attachment>)Records, existingRecords.values(), new Map<Id, Attachment>((List<Attachment>)Records), (Map<Id, Attachment>)existingRecords);
        
    }
    
    /**
     * Override method Before Delete Call
     */
    public override void onBeforeDelete() {
        //This is the section where all the methods that needs to be run at first are included.
        
        //This is the section where all the methods that needs to be run in a normal sequence are included.
        DAOH_Attachment.handleOnBeforeDeleteAttachment((List<Attachment>)Records);
        DAOH_Attachment.updateDeletedAttachmentCountOnCase((List<Attachment>)Records);
        //This is the section where all the methods that needs to be run at last are included.
    } 

     /**
     * Override method After Delete Call
     */
    public override void onAfterDelete() {
        DAOH_Attachment.handleOnAfterDeleteAttachment((List<Attachment>)Records, new Map<Id,Attachment>((List<Attachment>)Records));
    } 
    
    /**
     * Override method After Update Call
     */
    public override void onAfterUpdate(Map<Id,SObject> existingRecords) {
        //This is the section where all the methods that needs to be run at first are included.
        
        //This is the section where all the methods that needs to be run in a normal sequence are included.
        //DAOH_Opportunity.createTeamMemberForPICUser(new Map<Id, Opportunity>((List<Opportunity>)Records), (Map<Id, Opportunity>)existingRecords);
        DAOH_Attachment.handleOnAfterUpdateAttachment(existingRecords.values(), (List<Attachment>)Records,  new Map<Id,Attachment>((List<Attachment>)Records) , (Map<Id, Attachment>)existingRecords); 
        
        //This is the section where all the methods that needs to be run at last are included.
        //This should be at the last since it will set the sync fields with the latest changes    
    }
    
    /**
    * This method is used for after insert of the Attachment trigger.
    * @return void
    */
    public override void onAfterInsert() {
        //This is the section where all the methods that needs to be run at first are included.
        //This should be at the top since the trigger execution flags are reset in this method

        //This is the section where all the methods that needs to be run in a normal sequence are included.
        DAOH_Attachment.handleOnAfterInsertAttachment((List<Attachment>)Records);
        //This is the section where all the methods that needs to be run at last are included.
        //This should be at the last since it will integrate the opp with the latest changes
        DAOH_Attachment.updateCaseStatusToAbandoned((List<Attachment>)Records);
        DAOH_Attachment.deleteSignatureImageFromInboundEmail((List<Attachment>)Records);
        DAOH_Attachment.updateAttachmentCountOnCase((List<Attachment>)Records);
    }
}