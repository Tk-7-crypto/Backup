/*
* This class is used as helper class for DAO_ContentDocumentLink for CLM Module
*/
public class DAOH_CLM_ContentDocumentLink {

    /**
    * This method is used to clone generated files from action panel for the requestor
    * @param List<ContentDocumentLink> lstConDocLink
    */
    public static void cloneGeneratedFileForRequestor(List<ContentDocumentLink> lstConDocLink) {
        Map<Id, Id> linkedEntityIdToConDocIdMap = new Map<Id, Id>();
        Map<Id, Id> oldConDocIdToIQAgrIdMap = new Map<Id, Id>();
        List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>();  
        Set<Id> cvIds = new Set<Id>();  
        Map<Id, ContentVersion> iqAgrIdToContentVersionMap = new Map<Id, ContentVersion>();
        for(ContentDocumentLink cdl : lstConDocLink) {
            if(FeatureManagement.checkPermission('CLM_IQVIA_Licensed_User')
                && FeatureManagement.checkPermission('CLM_USBU')
                && !FeatureManagement.checkPermission('USBU_Contract_Analyst')
                && cdl.LinkedEntityId != null 
                && cdl.LinkedEntityId.getSObjectType() == Schema.Apttus__DocumentVersionDetail__c.getSObjectType()) {
                linkedEntityIdToConDocIdMap.put(cdl.LinkedEntityId, cdl.ContentDocumentId);          
            }
        }
        if(!linkedEntityIdToConDocIdMap.isEmpty()) {
            Set<String> fields = new Set<String>{'Apttus__Action2__c', 'Apttus__DocumentVersionId__c', 'Apttus__DocumentVersionId__r.Apttus__AgreementId__c', 'Apttus__DocumentVersionId__r.Apttus__AgreementId__r.IQVIA_Agreement__c', 
                'Apttus__DocumentVersionId__r.Apttus__AgreementId__r.IQVIA_Agreement__r.RecordTypeId'};
            for(Apttus__DocumentVersionDetail__c dvd : new SLT_Document_Version_Detail().getDocumentVersionDetailByIds(fields, linkedEntityIdToConDocIdMap.keySet(), 'Id IN: idSet')) {
                if((dvd.Apttus__Action2__c == CON_CLM.REGENERATE_AGREEMENT || dvd.Apttus__Action2__c == CON_CLM.GENERATE_AGREEMENT)
                    && dvd.Apttus__DocumentVersionId__r.Apttus__AgreementId__c != null 
                    && dvd.Apttus__DocumentVersionId__r.Apttus__AgreementId__r.IQVIA_Agreement__c != null
                    && (dvd.Apttus__DocumentVersionId__r.Apttus__AgreementId__r.IQVIA_Agreement__r.RecordTypeId == CON_CLM.USBU_IQVIA_RECORDTYPEID 
                    || dvd.Apttus__DocumentVersionId__r.Apttus__AgreementId__r.IQVIA_Agreement__r.RecordTypeId == CON_CLM.MSA_IQVIA_RECORDTYPEID) 
                    && linkedEntityIdToConDocIdMap.containsKey(dvd.Id)) {
                    oldConDocIdToIQAgrIdMap.put(linkedEntityIdToConDocIdMap.get(dvd.Id), dvd.Apttus__DocumentVersionId__r.Apttus__AgreementId__r.IQVIA_Agreement__c);
                }        
            }
            for(ContentVersion c : new SLT_ContentVersion().getContentVersionByDocumentIds(oldConDocIdToIQAgrIdMap.keySet(), 
                new Set<String>{'VersionData', 'PathOnClient', 'Title', 'ContentDocumentId'})) {
                if(oldConDocIdToIQAgrIdMap.containsKey(c.ContentDocumentId)) {
                    ContentVersion cv = new ContentVersion();
                    cv.PathOnClient = c.PathOnClient;
                    cv.Title = c.Title;
                    cv.VersionData = c.VersionData;
                    cv.Description = CON_CLM.GENERATED_FILE;    
                    iqAgrIdToContentVersionMap.put(oldConDocIdToIQAgrIdMap.get(c.ContentDocumentId), cv);                                                                   
                }
            }
            try {
                if(!iqAgrIdToContentVersionMap.isEmpty()) {
                    fflib_SObjectUnitOfWork uow1 = new fflib_SObjectUnitOfWork(new Schema.SObjectType[] {
                        ContentVersion.SObjectType
                    });
                    uow1.registerNew(iqAgrIdToContentVersionMap.values());
                    uow1.commitWork();   
                }
                for(ContentVersion c : iqAgrIdToContentVersionMap.values()) {
                    cvIds.add(c.Id);
                }
                Map<Id, ContentVersion> cvNewMap = new Map<Id, ContentVersion>(new SLT_ContentVersion().getContentVersionByIds(cvIds, new Set<String>{'Id', 'ContentDocumentId'})); 
                for(Id agrId : iqAgrIdToContentVersionMap.keySet()) {
                    ContentDocumentLink cdl = new ContentDocumentLink();
                    cdl.ContentDocumentId = cvNewMap.get(iqAgrIdToContentVersionMap.get(agrId).Id).ContentDocumentId; 
                    cdl.LinkedEntityId = agrId;
                    cdl.Visibility = 'AllUsers';
                    cdlList.add(cdl); 
                } 
                if(!cdlList.isEmpty()) {
                    fflib_SObjectUnitOfWork uow2 = new fflib_SObjectUnitOfWork(new Schema.SObjectType[] {
                        ContentDocumentLink.SObjectType
                    });
                    uow2.registerNew(cdlList);
                    uow2.commitWork();   
                }
            }
            catch(DMLException dmlExp) {
                System.debug(System.LoggingLevel.ERROR, dmlExp.getMessage() + ' \n ' + dmlExp.getStackTraceString());
            }
        } 
    }
     
    /**
    * This method is used to share documents with agreement after signatures are completed
    * @param List<ContentDocumentLink> cdlList
    */
    public static void shareDocusignDocumentsWithAgreement(List<ContentDocumentLink> cdlList) {
        Set<Id> envIds = new Set<Id>();
        Set<Id> conDocIds = new Set<Id>(); 
        for(ContentDocumentLink cdl : cdlList) {
            if(cdl.LinkedEntityId != null && cdl.LinkedEntityId.getSObjectType() == Schema.IQ_DocuSignEnvelope__c.getSObjectType()) {
                envIds.add(cdl.LinkedEntityId);
                conDocIds.add(cdl.ContentDocumentId);
            }
        }
        if(!envIds.isEmpty()) {
            Map<Id, IQ_DocuSignEnvelope__c> docEnvMap = new Map<Id, IQ_DocuSignEnvelope__c>(new SLT_IQDocuSignEnvelope()
                .getDocusignEnvelopeByConditionAndAgreementIds('Id IN: agreementIds', envIds, new Set<String>{'Agreement__c'}));           
            for(ContentDocumentLink cdl : cdlList)  {
                if(docEnvMap.containsKey(cdl.LinkedEntityId) && docEnvMap.get(cdl.LinkedEntityId).Agreement__c != null) {
                    cdl.LinkedEntityId = docEnvMap.get(cdl.LinkedEntityId).Agreement__c;
                }
            }  
            UTL_CLM_Docusign.updateDocusignDocuments(conDocIds);
        }
    }
}