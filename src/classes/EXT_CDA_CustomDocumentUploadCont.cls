/**
 *   Author    : Sweta Sharma
 *   This class serves as a extension for VFP_CDA_CustomDocumentUploadPage page. (created under ER-3556 on 06/04/2017)
 */

public with sharing class EXT_CDA_CustomDocumentUploadCont {

    //Public variables
    public transient Blob filebody {get;set;}
    public String fileName {get;set;}
    public String contentType {get;set;}
    public Boolean isShowException{get;set;}
    public String UploadFileName {get;set;}
    public String attachmentType {get;set;} // Added by Babita Dadarwal under CR-11458
    public String cdaRequestName {get;set;} // Added by Babita Dadarwal under CR-11659

    //Private variables
    private CDA_Request__c request;
    private CDA_Request__c cdaRequest;  //Added by Ajinkya Pande under Item #114
    private transient Attachment attachment;  //Updated by Vikram Singh under issue-11324
    // private String attachmentType; // Commented by Babita Dadarwal under CR-11458


    //Constructor
    public EXT_CDA_CustomDocumentUploadCont(ApexPages.StandardController controller) {
        request = (CDA_Request__c) controller.getRecord();
        //Added by Ajinkya Pande under Item #114 Start
        if(request != null && request.Id != null) {
            cdaRequest = SRV_CDA_CDARequest.getCDARequest(request.Id);
            cdaRequestName = (String)cdaRequest.get('CDA_Id__c'); // Added by Babita Dadarwal under CR-11659
        }
        //Added by Ajinkya Pande under Item #114 End
        attachmentType = Apexpages.currentPage().getParameters().get('attachmentType');
        isShowException = false;
        if (attachmentType != null && attachmentType != '') {
            UploadFileName = 'Uploaded ' + attachmentType + ' File.';
        } else {
            UploadFileName = 'Uploaded File.';
        }
    }


    //Public methods

    /**
     *    Function to return back to agreement detail page .
     */
    public PageReference doCancel() {
        return new pageReference('/' + request.id);
    }

    /**
     *   Function to save the attachment or replace the schedule1 or schedule 2 attachments.
     */
    public pageReference doSave() {
        try {
            attachment = new Attachment();
            attachment.OwnerId = UserInfo.getUserId();
            attachment.ParentId = request.ID;
            attachment.body = filebody;
            attachment.contentType = contentType;
            String extension = fileName.substring(fileName.lastIndexOf('.') + 1, fileName.length());
            //Updated by Ajinkya Pande under Item #114 Start //
            if(UploadFileName.contains(UTL_CDAUtility.RED_LINE_KEYWORD) || UploadFileName.contains(UTL_CDAUtility.RED_LINE_KEYWORD_NEW)) {
                attachment.Name = UTL_CDAUtility.getDocumentName(cdaRequest, UTL_CDAUtility.RED_LINE_KEYWORD) + '.' + extension;
            } else if(UploadFileName.contains(UTL_CDAUtility.CLEANED_DOC_KEYWORD) || UploadFileName.contains(UTL_CDAUtility.CLEANED_DOC_KEYWORD_NEW)) {
                attachment.Name = UTL_CDAUtility.getDocumentName(cdaRequest, UTL_CDAUtility.CLEANED_DOC_KEYWORD) + '.' + extension;
            }
            // Added by Babita Dadarwal under CR-11458 Start
            else if(attachmentType == UTL_CDAUtility.CDA_PARTIALLY_EXECUTED_DOC_KEYWORD) {
                attachment.Name = UTL_CDAUtility.getDocumentName(cdaRequest, UTL_CDAUtility.CDA_PARTIALLY_EXECUTED_DOC_KEYWORD) + '.' + extension;
            }
            // Added by Babita Dadarwal under CR-11458 End
            else {
                attachment.Name = UploadFileName + extension;
            }
            //Updated by Ajinkya Pande under Item #114 End //
            if (attachmentType != null && attachmentType != '') {
                attachment.Description = attachmentType;
            }
            if (attachmentType != null && attachmentType != '' && (attachmentType == UTL_CDAUtility.EXTERNAL_DOCUMENT || UploadFileName.contains(UTL_CDAUtility.RED_LINE_KEYWORD) || UploadFileName.contains(UTL_CDAUtility.RED_LINE_KEYWORD_NEW)) && extension != null && !extension.toLowerCase().contains('doc') && !extension.toLowerCase().contains('docx')) {
                this.isShowException = true;
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, LABEL.CDA_The_system_has_detected_that_the_selected_document_is_NOT_in_the_required_fu);
                ApexPages.addMessage(myMsg);
                return null;
            } else if(attachmentType != null && attachmentType != '' && (UploadFileName.contains(UTL_CDAUtility.CLEANED_DOC_KEYWORD) || UploadFileName.contains(UTL_CDAUtility.CLEANED_DOC_KEYWORD_NEW)) && extension != null && !extension.toLowerCase().contains('doc') && !extension.toLowerCase().contains('docx') && !extension.toLowerCase().contains('pdf')) {
                this.isShowException = true;
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, LABEL.CDA_The_system_has_detected_that_the_selected_document_is_NOT_in_the_required_fu);
                ApexPages.addMessage(myMsg);
                return null;
            } else if(UploadFileName.contains(UTL_CDAUtility.CDASOURCE_EXTERNAL)) { //Updated by Ajinkya Pande under Item #114 Start
                attachment.Name = UTL_CDAUtility.getDocumentName(cdaRequest, UTL_CDAUtility.CDASOURCE_EXTERNAL) + '.' + extension;
            }
            else if(UploadFileName.contains(UTL_CDAUtility.RED_LINE_KEYWORD) || UploadFileName.contains(UTL_CDAUtility.RED_LINE_KEYWORD_NEW)) {
                attachment.Name = UTL_CDAUtility.getDocumentName(cdaRequest, UTL_CDAUtility.RED_LINE_KEYWORD) + '.' + extension;
            }
            
            if(attachmentType != null && attachmentType != '' && (attachmentType == UTL_CDAUtility.MANAGER_APPROVAL_DOC_KEYWORD)){
                attachment.Name = UTL_CDAUtility.getDocumentName(cdaRequest, UTL_CDAUtility.MANAGER_APPROVAL_DOC_KEYWORD) + '.' + extension;
            }
            //Updated by Ajinkya Pande under Item #114 End
            if (attachment != null) {
                insert attachment;
                // Added by Babita Dadarwal under CR-11458 Start
                if(attachmentType == UTL_CDAUtility.CDA_PARTIALLY_EXECUTED_DOC_KEYWORD) {
                    SRV_CDA_DocusignStatus.createAndSendEnvelope(cdaRequest.ID);
                }
                // Added by Babita Dadarwal under CR-11458 End
            }
        } catch (Exception e) {
            this.isShowException = true;
            ApexPages.addMessages(e);
            return null;
        }

        // Added by Babita Dadarwal under CR-11659 Start
        if(attachmentType == UTL_CDAUtility.CDA_PARTIALLY_EXECUTED_DOC_KEYWORD) {
            //return new pageReference('/' + request.id + '?attachmentType=' + attachmentType );
            return new pageReference('/' + request.id + '?status=Sent for Recipient Signature');
        }
        // Added by Babita Dadarwal under CR-11659 End

        return new pageReference('/' + request.id);
    }
}
