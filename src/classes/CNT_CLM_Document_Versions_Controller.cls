public class CNT_CLM_Document_Versions_Controller {
    @AuraEnabled(cacheable=true)
    public static List<Apttus__DocumentVersion__c> getAllDocVersions(Id recordId){
        Set<Id> docVersionIDS = new Set<Id>();
        if(recordId.getSObjectType().getDescribe().getName() == CON_CLM.IQVIA_AGR_OBJ_NAME) {
            List<IQVIA_Agreement__c> iqAGRList = new SLT_IQVIA_Agreement().getIQVIAAgreementFieldsById(
                new Set<Id>{recordId}, new Set<String>{'Id','Conga_Agreement_Id__c'});
            if(!iqAGRList.isEmpty() && iqAGRList.get(0).Conga_Agreement_Id__c != null) {
                recordId = iqAGRList.get(0).Conga_Agreement_Id__c;
            }
        }
        List<Apttus__APTS_Agreement__c> agreementList = new SLT_Agreement().getAgreementListWithDocumentVersions(new Set<Id>{recordId}, new Set<String>{'Id', 'Name'});
        for(Apttus__APTS_Agreement__c agr: agreementList) {
            for(Apttus__DocumentVersion__c doc: agr.Apttus__DocumentVersions__r){
                docVersionIDS.add(doc.Id);
            }
        }
        List<Apttus__DocumentVersion__c> docVersionList = new SLT_DocumentVersion().getDocumentVersionWithDetails(docVersionIDS, new Set<String>{'Id', 'Name', 
            'Apttus__Title__c', 'Apttus__LatestVersion__c', 'Apttus__ReviewStatus__c', 'Apttus__LatestReviewCycleStatus__c', 'Apttus__View__c', 
            'Title_Click_to_view__c', 'Apttus__LatestVersionId__c', 'LastModifiedBy.Name', 'LastModifiedDate', 'Apttus__CheckoutById__c', 'Apttus__CheckoutDate__c',
            'Apttus__CheckoutVersionDetailId__c', 'Apttus__CheckoutById__r.Name','Apttus__LatestVersionId__r.Apttus__ContentId__c'},
            new Set<String>{'Id', 'Apttus__DocumentVersionId__c', 'Apttus__ContentVersionId__c', 'Apttus__DocumentInfo__c', 'Name','Apttus__Title__c', 'Apttus__Action2__c', 
            'View__c', 'Apttus__ContentId__c', 'Apttus__FileType__c', 'LastModifiedBy.Name', 'LastModifiedDate' });
        for(Apttus__DocumentVersion__c dv: docVersionList) {
            if(dv.Apttus__LatestReviewCycleStatus__c == null) {
                dv.Apttus__LatestReviewCycleStatus__c = 'Null';
            } 
        }
        return docVersionList;
    }
    
    /**
    * This method is used to update title of the content document
    * @param String docVerId 
    * @param String title
    */ 
    @AuraEnabled
    public static void updateDocumentTitle(String docVerId, String title) {
        try {
            Apttus__DocumentVersion__c docVer = new SLT_DocumentVersion().getDocumentVersionById(docVerId, new Set<String>{'Id', 'Apttus__Title__c', 'Apttus__LatestVersionId__c'});
            docVer.Apttus__Title__c = title;
            Apttus__DocumentVersionDetail__c dvd = new SLT_Document_Version_Detail(false, false).getDocumentVersionDetailById(docVer.Apttus__LatestVersionId__c, 
                new Set<String>{'Id', 'Apttus__ContentId__c', 'Apttus__Title__c'});
            dvd.Apttus__Title__c = title;
            String condition = 'ID IN: docIds';
            List<ContentDocument> lstContentDocument = new SLT_ContentDocument().selectById(new Set<String>{'Id', 'Title'}, condition, new Set<Id>{dvd.Apttus__ContentId__c});
            lstContentDocument[0].Title = title;
            fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
                new Schema.SObjectType[] {
                    Apttus__DocumentVersion__c.SObjectType, Apttus__DocumentVersionDetail__c.SObjectType, ContentDocument.SObjectType
                }
            );
            uow.registerDirty(docVer);
            uow.registerDirty(dvd);
            uow.registerDirty(lstContentDocument);
            uow.commitWork();
        }
        catch(QueryException q) {
            throw new AuraHandledException('No Document Exists');
        }
        catch(DMLException dmlExp) {
            throw new AuraHandledException('Failed to update! Refresh and try again '+dmlExp.getMessage());
        }              
        catch(ListException q) {
            throw new AuraHandledException('No Document Exists');
        }        
    }
    
    /**
    * This method is used to delete document versions from agreement
    * @param Set<Id> docVerIds
    */ 
    @AuraEnabled
    public static void deleteDocumentVersions(List<Id> docVerIds) {
        List<Apttus__DocumentVersion__c> lstDocVer = new SLT_DocumentVersion().getDocumentVersionWithDetails(new Set<Id>(docVerIds), 
            new Set<String>{'Id', 'AgreementId__c', 'Apttus__AgreementId__c'}, new Set<String>{'Id'});
        for(Apttus__DocumentVersion__c docVer : lstDocVer) {
            docVer.AgreementId__c = docVer.Apttus__AgreementId__c;
            docVer.Apttus__AgreementId__c = null;
        }
        try {  
            fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
                new Schema.SObjectType[] {
                    Apttus__DocumentVersion__c.SObjectType
                }
            );
            uow.registerDirty(lstDocVer);
            uow.commitWork();
        } 
        catch(DMLException dmlExp) {
            throw new AuraHandledException('Failed to delete ! Refresh and try again '+ dmlExp.getMessage());
        }    
    }

    /**
     * This method is used to unlock document version.
     * @param String docVerId
     */
    @AuraEnabled
    public static void unlockDocumentVersion(String docVerId) {
        Apttus__DocumentVersion__c docVer = new SLT_DocumentVersion().getDocumentVersionById(docVerId, new Set<String>{'Id', 'Apttus__CheckoutById__c', 'Apttus__CheckoutDate__c', 'Apttus__CheckoutVersionDetailId__c'});
        docVer.Apttus__CheckoutById__c = null;
        docVer.Apttus__CheckoutDate__c = null;
        docVer.Apttus__CheckoutVersionDetailId__c = null;		
        try {  
            fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
                new Schema.SObjectType[] {
                    Apttus__DocumentVersion__c.SObjectType
                }
            );
            uow.registerDirty(docVer);
            uow.commitWork();
        } 
        catch(DMLException dmlExp) {
            throw new AuraHandledException('Failed to unlock ! Refresh and try again '+ dmlExp.getMessage());
        }
    }
}