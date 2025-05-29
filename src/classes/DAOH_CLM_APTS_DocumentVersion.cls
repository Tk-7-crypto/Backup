public class DAOH_CLM_APTS_DocumentVersion {
    /**
     * This method is used to create sharing records 
     *  @param List<Apttus__DocumentVersion__c> newAgreementList
     *  @param Map<Id, Apttus__DocumentVersion__c> oldMap
     *  @return void
     */
	public static void setSharing(List<Apttus__DocumentVersion__c> newAgreementList, Map<Id, Apttus__DocumentVersion__c> oldMap){
        UTL_Sharing.setSharing(newAgreementList, oldMap, 'Apttus__DocumentVersion__c');
    }
    /**
     * This method is used to create sharing records similar to owner id
     *  @param List<Apttus__DocumentVersion__c> newAgreementList
     *  @param Map<Id, Apttus__DocumentVersion__c> oldMap
     * @return void
     */
    public static void setDummyCreatorAccess(List<Apttus__DocumentVersion__c> newAgreementList) {
        UTL_Sharing.setDummyCreatorAccess(newAgreementList, 'Apttus__DocumentVersion__Share', 'DocumentVersion_Territory__c');
    }
    /**
     * This method is used for setting Last_Sharing_Calculation_Timestamp__c field
     *  @param List<Apttus__DocumentVersion__c> newAgreementList
     *  @param Map<Id, Apttus__DocumentVersion__c> oldMap
     *  @return void
     */
    public static void setLastSharingCalculationTimestamp(List<Apttus__DocumentVersion__c> newAgreementList, Map<Id, Apttus__DocumentVersion__c> oldMap) {
        Boolean isFieldToUpdate = true;
        Set<Id> recordIdSet = new Set<Id>();
        if(oldMap != null) {
            recordIdSet = UTL_Sharing.checkFieldSetValueChange(newAgreementList, oldMap, 'Apttus__DocumentVersion__c', 'SHR_Parent_FieldSet');
            if(recordIdSet.size() == 0) {
                isFieldToUpdate = false;
            }
        }
        if(isFieldToUpdate) {
            for(Apttus__DocumentVersion__c apts :newAgreementList) {
                if (oldMap == null || recordIdSet.contains(apts.Id)) {
                    apts.Last_Sharing_Calculation_Timestamp__c = System.Now();    
                }
            }   
        }
    }
    /**
     * This method is used for setting Last_Manual_Sharing_Execution__c field
     *  @param List<Apttus__DocumentVersion__c> newAgreementList
     *  @param Map<Id, Apttus__DocumentVersion__c> oldMap
     *  @return void
     */
    public static void setLastManualSharingFieldUpdate(List<Apttus__DocumentVersion__c> newAgreementList, Map<Id, Apttus__DocumentVersion__c> oldMap) {
        for (Apttus__DocumentVersion__c apts : newAgreementList) {
            if(apts.Run_Sharing__c) {
                apts.Run_Sharing__c = false;
                apts.Last_Manual_Sharing_Execution__c = System.now();
            }
        }
    }

    /**
     * This method is used for updating Agreement status to Internal Review/Internal Legal Review
     *  @param List<Apttus__DocumentVersion__c> newAgreementList
     *  @param Map<Id, Apttus__DocumentVersion__c> oldMap
     *  @return void
     */
    public static void updateAgreements(List<Apttus__DocumentVersion__c> newList, Map<Id, Apttus__DocumentVersion__c> oldMap) {
        Set<Id> agreementIds = new Set<Id>();
        Set<Id> agreementIdsToUpdate = new Set<Id>();
        Map<Id, Apttus__APTS_Agreement__c> agreementsMap = new Map<Id, Apttus__APTS_Agreement__c>();
        Map<Id, String> iqAgreementStatusMap = new Map<Id, String>();
        
        for (Apttus__DocumentVersion__c documentVersion : newList) {
            if(oldMap != null && ((documentVersion.Apttus__LatestReviewCycleStatus__c == CON_CLM.IN_PROGRESS
                && oldMap.get(documentVersion.Id).Apttus__LatestReviewCycleStatus__c == CON_CLM.NOT_STARTED) 
                || (documentVersion.Apttus__LatestReviewCycleStatus__c == CON_CLM.COMPLETED
                && oldMap.get(documentVersion.Id).Apttus__LatestReviewCycleStatus__c == CON_CLM.IN_PROGRESS) 
                || (documentVersion.Apttus__LatestReviewCycleStatus__c == CON_CLM.CANCELLED
                && oldMap.get(documentVersion.Id).Apttus__LatestReviewCycleStatus__c == CON_CLM.IN_PROGRESS) 
                || (documentVersion.Apttus__LatestReviewCycleStatus__c == CON_CLM.NOT_STARTED
                && documentVersion.Apttus__LatestReviewCycleStatus__c != oldMap.get(documentVersion.Id).Apttus__LatestReviewCycleStatus__c))) {
                agreementIds.add(documentVersion.Apttus__AgreementId__c);
            }
        }
        if(!agreementIds.isEmpty()){
            agreementsMap.putAll(new SLT_Agreement().getAgreementListWithDocumentVersions(agreementIds, new Set<String> {'Id', 'IQVIA_Agreement__c', 'IQVIA_Agreement__r.OwnerId'}));
            for (Apttus__DocumentVersion__c documentVersion : newList) {
                if(agreementsMap.containsKey(documentVersion.Apttus__AgreementId__c) 
                    && agreementsMap.get(documentVersion.Apttus__AgreementId__c).IQVIA_Agreement__c == null 
                    && oldMap != null 
                    && documentVersion.Apttus__LatestReviewCycleStatus__c != oldMap.get(documentVersion.Id).Apttus__LatestReviewCycleStatus__c
                    && documentVersion.Apttus__LatestReviewCycleStatus__c == CON_CLM.NOT_STARTED) {
                    agreementIdsToUpdate.add(documentVersion.Apttus__AgreementId__c);
                }
            }
            for(Apttus__APTS_Agreement__c agr : agreementsMap.values()){
                if(agr.IQVIA_Agreement__c != null) {
                    Boolean isInProgress = false;
                    Boolean isCompleted = false;
                    Boolean isCancelled = false;
                    for(Apttus__DocumentVersion__c doc: agr.Apttus__DocumentVersions__r){
                        if(doc.Apttus__LatestReviewCycleStatus__c == 'In Progress'){
                            isInProgress = true;
                            break;
                        } else if(doc.Apttus__LatestReviewCycleStatus__c == 'Cancelled'){
                            isCancelled = true;
                        } else if(doc.Apttus__LatestReviewCycleStatus__c == 'Completed'){
                            isCompleted = true;
                        }
                    }
                    if(isInProgress){
                        iqAgreementStatusMap.put(agr.IQVIA_Agreement__c, CON_CLM.INTERNAL_LEGAL_REVIEW);
                    } else if (isCompleted){
                        iqAgreementStatusMap.put(agr.IQVIA_Agreement__c, CON_CLM.INTERNAL_REVIEW + ' - Owner Update');
                    } else if(isCancelled){
                        iqAgreementStatusMap.put(agr.IQVIA_Agreement__c, CON_CLM.INTERNAL_REVIEW);
                    }
            	}
            }
        }
        
        if(!agreementIdsToUpdate.isEmpty()) {
            updateAgreements(agreementIdsToUpdate); 
        }
        if(!iqAgreementStatusMap.isEmpty()) {
            updateIQAgreements(iqAgreementStatusMap);
        }
    }
    
    public static void updateAgreements(Set<Id> agreementIds) {
        List<Apttus__APTS_Agreement__c> lstAgreements = new List<Apttus__APTS_Agreement__c>();
        for(Id agreementId: agreementIds) {
            Apttus__APTS_Agreement__c agreement = new Apttus__APTS_Agreement__c();
            agreement.Id = agreementId;
            agreement.Apttus__Status_Category__c = CON_CLM.IN_AUTHORING;
            agreement.Apttus__Status__c = CON_CLM.INTERNAL_REVIEW;
            lstAgreements.add(agreement);
        }
        if(!lstAgreements.isEmpty()) {
            System.enqueueJob(new QUE_CLM_UpdateAgreement(lstAgreements));
        }
    }

    @future
    public static void updateIQAgreements(Map<Id, String> iqAgreementStatusMap) {
        List<IQVIA_Agreement__c> iqvAgreementsToUpdate = new List<IQVIA_Agreement__c>();
        Map<Id, String> updatedIQAgreementToOwnerMap = new Map<Id, String>();
        Set<Id> iqviaAgrIdsForOwnerUpdate = new Set<Id>();
        
        for(Id iqvId: iqAgreementStatusMap.KeySet()){
            if(iqAgreementStatusMap.get(iqvId) == CON_CLM.INTERNAL_REVIEW + ' - Owner Update'){
                iqviaAgrIdsForOwnerUpdate.add(iqvId);
            }
        }
        
        if(!iqviaAgrIdsForOwnerUpdate.isEmpty()){
            updatedIQAgreementToOwnerMap = UTL_CLM.assignOwnerBasedOnAgreementTeam(iqviaAgrIdsForOwnerUpdate);
        }
        
        for(Id iqvId: iqAgreementStatusMap.KeySet()){
            IQVIA_Agreement__c iqvAgreement = new IQVIA_Agreement__c();
            iqvAgreement.Id = iqvId;
            iqvAgreement.Status_Category__c = CON_CLM.IN_AUTHORING;
            if(iqAgreementStatusMap.get(iqvId) == CON_CLM.INTERNAL_REVIEW + ' - Owner Update'){
                if(updatedIQAgreementToOwnerMap.containsKey(iqvId) && updatedIQAgreementToOwnerMap.get(iqvId) != null){
                    iqvAgreement.OwnerId = updatedIQAgreementToOwnerMap.get(iqvId);
                }
                iqvAgreement.Status__c = CON_CLM.INTERNAL_REVIEW;
            } else {
                iqvAgreement.Status__c = iqAgreementStatusMap.get(iqvId);
            }
            iqvAgreementsToUpdate.add(iqvAgreement);
        }
        
        if(!iqvAgreementsToUpdate.isEmpty()) {
            try {  
                fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
                    new Schema.SObjectType[] {
                        IQVIA_Agreement__c.SObjectType
                    }
                );
                uow.registerDirty(iqvAgreementsToUpdate);
                uow.commitWork();
            } catch(Exception e) {
                for(SObject record : iqvAgreementsToUpdate) {
                    EventBus.publish(new Apex_Error_Log_Event__e(
                    Object__c = 'IQVIA_Agreement__c',
                    Error_Message__c = 'Error in DocumentVersion trigger future call' +'\n'+e.getMessage() + '\n' + e.getStackTraceString(),
                    Record_Id__c = record.Id,
                    Running_User__c = UserInfo.getUserId(),
                    Source_Module__c = 'CLM'));
                }
            }
        }
    }

    public static void unlockDocumentVersion(List<Apttus__DocumentVersion__c> newAgreementList, Map<Id, Apttus__DocumentVersion__c> oldMap) {
        for(Apttus__DocumentVersion__c documentVersion :newAgreementList) {
            if(documentVersion.Apttus__LatestReviewCycleStatus__c != oldMap.get(documentVersion.Id).Apttus__LatestReviewCycleStatus__c
                && documentVersion.Apttus__LatestReviewCycleStatus__c == CON_CLM.NOT_STARTED
                && documentVersion.Apttus__CheckoutById__c != null 
                && documentVersion.Apttus__CheckoutDate__c != null 
                && documentVersion.Apttus__CheckoutVersionDetailId__c != null) { 
                    documentVersion.Apttus__CheckoutById__c = null;
                    documentVersion.Apttus__CheckoutDate__c = null;
                    documentVersion.Apttus__CheckoutVersionDetailId__c = null;
            }
        }   
    }
    /**
     * This method is used for populating IQ_Agreement_Record_Type_Developer_Name__c with the record type of associated IQ AGR
     *  @param List<Apttus__DocumentVersion__c> newAgreementList
     *  @return void
     */
    public static void updateIQAGRRecordTypeName(List<Apttus__DocumentVersion__c> newList) {
        Set<Id> setofAgrIds = new Set<Id>();  

        for (Apttus__DocumentVersion__c documentVersion : newList) {
            if(documentVersion.Apttus__AgreementId__c != null) {
                setofAgrIds.add(documentVersion.Apttus__AgreementId__c);
            }
        }

        if(!setofAgrIds.isEmpty()) {
            String condition = 'IQVIA_Agreement__c != null';
            Map<Id,Apttus__APTS_Agreement__c> mapAgreement = new Map<Id,Apttus__APTS_Agreement__c>(new SLT_Agreement().getAgreementListByCondition(
                new Set<String>{'Id', 'IQVIA_Agreement__r.Record_Type_Developer_Name__c'}, condition, setofAgrIds));
            if(!mapAgreement.isEmpty()) {
                for (Apttus__DocumentVersion__c documentVersion : newList) {
                    if(mapAgreement.containsKey(documentVersion.Apttus__AgreementId__c)) {
                        documentVersion.IQ_Agreement_Record_Type_Developer_Name__c = mapAgreement.get(documentVersion.Apttus__AgreementId__c).IQVIA_Agreement__r.Record_Type_Developer_Name__c;
                    }
                }
            }
        }
    }
}