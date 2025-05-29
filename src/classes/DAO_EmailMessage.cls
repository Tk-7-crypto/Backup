public class DAO_EmailMessage  extends fflib_SObjectDomain {

    /**
     * Constructor of this class
     * @params sObjectList List<Task>
     */
    public DAO_EmailMessage(List<EmailMessage> sObjectList) {
        super(sObjectList);
    }

    /**
     * Constructor Class for construct new Instance of This Class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new DAO_EmailMessage(sObjectList);
        }
    }

    public override void onBeforeInsert() {
        DAOH_EmailMessage.caseClosedRnDRestrictEmail((List<EmailMessage>) Records);
    }
    /**
     * This method is used for after insert of the EmailMessage trigger.
     * @return void filterOppRelatedTask
     */
    public override void onAfterInsert() {
        //DAOH_EmailMessage.createActivityofEmailMessageOutgoing((List<EmailMessage>) Records);
        DAOH_EmailMessage.updateCasefromEmailMessageIncoming((List<EmailMessage>) Records);
        //DAOH_EmailMessage.updateStatusforEmailMessageonCase((List<EmailMessage>) Records);
        DAOH_EmailMessage.cloneCaseStatusIsClosedEmailMessageonCase((List<EmailMessage>) Records);
        //DAOH_EmailMessage.MailSenderWhenEmailReceivedOnTechClosedCase((List<EmailMessage>) Records);
        /*CSM-1246 Moved updateCaseOnOutboundMail() code updateStatusforEmailMessageonCase*/
        // DAOH_EmailMessage.updateCaseOnOutboundMail((List<EmailMessage>)Records);
        DAOH_EmailMessage.checkTagsInEmailMessageForCaseFields((List<EmailMessage>)Records);
        //DAOH_EmailMessage.createCaseCollabration((List<EmailMessage>) Records);
        DAOH_EmailMessage.improveQ1CaseCreation((List<EmailMessage>) Records);
        DAOH_EmailMessage.deleteCasesCreatedBySpamMails((List<EmailMessage>) Records);
        //DAOH_EmailMessage.stopDuplicateCaseCreationinToAddress((List<EmailMessage>)Records);
    }  
    
    /**
     * This method is used for after update of the EmailMessage trigger.
     * @params  existingRecords Map<Id,SObject>
     * @return  void
     */
   public override void  onAfterUpdate(Map<Id,SObject> existingRecords) {
       //DAOH_EmailMessage.updateCaseDetailsformEmailMessageOutgoing((List<EmailMessage>) Records,(Map<Id,EmailMessage>)existingRecords);
       //DAOH_EmailMessage.afterupdatetoCreateActivityforRD((List<EmailMessage>) Records,(Map<Id,EmailMessage>)existingRecords);
       //DAOH_EmailMessage.caseCommentasOnOutboundMail((List<EmailMessage>) Records,(Map<Id,EmailMessage>)existingRecords);
   }
    
    public override void onBeforeDelete() {
        DAOH_EmailMessage.deleteEmailMessagefromCaseorNot((List<EmailMessage>)Records);
        DAOH_EmailMessage.updateDeletedEmailAttachmentCountOnCase((List<EmailMessage>)Records);
    }
}
