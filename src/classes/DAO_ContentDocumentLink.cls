/**
 * This is Content Document Link Domain class.
 * version : 1.0
 */
public with sharing class DAO_ContentDocumentLink extends fflib_SObjectDomain {

     /**
     * Constructor of this class
     * @params sObjectList List<SObject>
     */
    public DAO_ContentDocumentLink(List<SObject> sObjectList) {
        super(sObjectList);
    }
    
    /**
     * Constructor Class for construct new Instance of This Class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new DAO_ContentDocumentLink(sObjectList);
        }
    }
    
    /**
     * This method is used for before insert of the Content Document Link trigger.
     * @return void
     */
    public override void onBeforeInsert() {
        DAOH_CLM_ContentDocumentLink.shareDocusignDocumentsWithAgreement((List<ContentDocumentLink>)Records);
        DAOH_ContentDocumentLink.defineSharingRuleCTRPRM((List<ContentDocumentLink>)Records);
    }
    
    /**
     * This method is used for before insert of the ContentDocumentLink trigger.
     * @return void
     */
    public override void onAfterInsert() {
        DAOH_ContentDocumentLink.onAfterInsert((List<ContentDocumentLink>)Records);
        DAOH_ContentDocumentLink.sendEmailNotificationOnNewAttachment((List<ContentDocumentLink>)Records);
        DAOH_ContentDocumentLink.countForAttachmentOnRDCaseActivities((List<ContentDocumentLink>)Records);
        DAOH_ContentDocumentLink.deleteSignatureImageFromInboundEmail((List<ContentDocumentLink>)Records);
        DAOH_CLM_ContentDocumentLink.cloneGeneratedFileForRequestor((List<ContentDocumentLink>)Records);
    }
    
    public override void onAfterUpdate(Map<Id,SObject> existingRecords){
        DAOH_ContentDocumentLink.sendEmailNotificationOnNewAttachment((List<ContentDocumentLink>)Records);
    }
    
    /**
    * This method is used for before delete of the ContentDocumentLink trigger.
    */        
    public override void onBeforeDelete() {
    }
}