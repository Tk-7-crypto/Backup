public class CNT_CPQ_PreviewDocumentController {
    @AuraEnabled 
    public static ContractDetails fetchContentDocument(Id contractId) {
        ContractDetails contractDetailsObj = new ContractDetails();
        Set<String> fieldSet = new Set<String> {
            CON_CPQ.ID,
            CON_CPQ.LINKEDENTITY_ID,
            CON_CPQ.CONTENT_DOCUMENT_ID,
            CON_CPQ.CONTENT_DOCUMENT_TITLE,
            CON_CPQ.CONTENT_DOCUMENT_FILE_TYPE
        };
        if(contractId != null) {
            contractDetailsObj.contractId = contractId;
            contractDetailsObj.documentList = new SLT_ContentDocumentLink().getContentDocumentLinkDetailByLinkedEntityId(contractId, fieldSet);
            contractDetailsObj.isDocumentListNotEmpty = contractDetailsObj.documentList.size() > 0 ;
        }
        return contractDetailsObj;
    }
    
    public class ContractDetails {
        @AuraEnabled
        public List<ContentDocumentLink> documentList {get; set;}
        @AuraEnabled
        public String contractId {get; set;}
        @AuraEnabled
        public Boolean isDocumentListNotEmpty {get; set;}
    }
}