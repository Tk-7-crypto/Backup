/**
 * @description DAOH for IQVIA_Agreement__c Object
 */
public class DAOH_CLM_IQVIA_Agreement {
    public static partnerSoapSforceCom.Soap atUpdate;
    
    /**
    * This method is used to set agreement number with its autonumber
    * @param 
    * @return
    */ 
    public static void setIQVIAAgreementNumber(Set<Id> agreementIds) {
        List<IQVIA_Agreement__c> updateAgrList = new List<IQVIA_Agreement__c>();
        List<IQVIA_Agreement__c> lstAgr = new SLT_IQVIA_Agreement().getIQVIAAgreementFieldsById(agreementIds, new Set<String>{'Id', 'Name', 'Conga_Agreement_Id__c', 'Contract_Auto_Number__c','Version_Number__c',
            'Account__c', 'Account__r.Name', 'FF_Agreement_Number__c', 'Agreement_Number__c'});
        for(IQVIA_Agreement__c iqa : lstAgr) {
            if(iqa.Version_Number__c == 0) {
                iqa.Agreement_Number__c = iqa.Contract_Auto_Number__c;
            } 
            if(iqa.Account__c != null) {
                iqa.Search_Field__c = iqa.Account__r.Name+''+iqa.Agreement_Number__c+'.'+iqa.Version_Number__c;
            } else {
                iqa.Search_Field__c = iqa.Agreement_Number__c+'.'+iqa.Version_Number__c;
            }
            updateAgrList.add(iqa);
        }
        if(!updateAgrList.isEmpty()) {
            try {  
                fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
                    new Schema.SObjectType[] {
                        IQVIA_Agreement__c.SObjectType
                            }
                );
                UTL_ExecutionControl.hasTraversedTrigger = true;
                uow.registerDirty(updateAgrList);
                uow.commitWork();
            } catch(DMLException dmlExp) {
                System.debug(System.LoggingLevel.ERROR, dmlExp.getMessage() + ' \n ' + dmlExp.getStackTraceString());
            }
        }
    }
    /**
    * This method is used to create Conga Agreement from IQVIA Agreement
    * @param 
    * @return
    */ 
	public static void createCongaAgreementFromIqvAgreement(List<IQVIA_Agreement__c> agreementList, Map<Id, IQVIA_Agreement__c> oldMap) {
        //Set<Id> congaAgreementIDs = new Set<Id>();
        String recordId;
        String congaId;
        Map<Id, IQVIA_Agreement__c> iqvAgreementMap;
        List<Log_History__c> lstLogsForError = new List<Log_History__c>();
        Set<Id> agreementIds = new Set<Id>();
        for(IQVIA_Agreement__c agreement : agreementList) {
            if(((oldMap == null && agreement.Status__c == CON_CLM.STATUS_OTHER_PARTY_REVIEW && agreement.Helper__c.contains(CON_CLM.SELF_SERVICE_SOW))
                || (oldMap != null && agreement.Status__c != oldMap.get(agreement.Id).Status__c && agreement.Status__c == CON_CLM.ASSIGNED))
                && agreement.Conga_Agreement_Id__c == null) {
				agreementIds.add(agreement.Id);
            }
        }
     
        iqvAgreementMap = new Map<Id, IQVIA_Agreement__c>(new SLT_IQVIA_Agreement().getIQVIAAgreementFieldsById(agreementIds, 
            new Set<String>{'Id', 'Name', 'Subtype__c', 'RecordTypeId', 'OwnerId', 'Requestor__c', 'Conga_Agreement_Id__c', 
            'Contract_Auto_Number__c','Account_Country__c'}));   
        Map<Id, Apttus__APTS_Agreement__c> IqviaAgreementIdtoCongaAgreement = new Map<Id, Apttus__APTS_Agreement__c>();
        for(Id iqvAgr: agreementIds) {
            if(iqvAgreementMap.containsKey(iqvAgr)){
                IqviaAgreementIdtoCongaAgreement.put(iqvAgr, createAPTSAgreement(iqvAgreementMap.get(iqvAgr)));
                recordId = iqvAgr;
            }
        }
        if(!IqviaAgreementIdtoCongaAgreement.isEmpty()) {
            try{
                fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
                    new Schema.SObjectType[] {
                        Apttus__APTS_Agreement__c.SObjectType
                    }
                );
                uow.registerNew(IqviaAgreementIdtoCongaAgreement.values());
                uow.commitWork();
            }
            catch(Exception e) {
                System.debug('In creation execption list'+e);
                lstLogsForError.add(UTL_LogFactory.generateAndCommitLog(false, false, null, e.getMessage(), 'CLM',
                    'Exception', 'ERROR', 'Agreement creation failure!', recordId));
            }
            updateIqvAgreementAsync(iqvAgreementMap, IqviaAgreementIdtoCongaAgreement);
        }
        try {
            UTL_LogFactory.saveLogs(lstLogsForError, false);
        }
        catch(Exception e){
            System.debug(e);   
        }
        
    }
    
    /**
     * This method is to create instance of conga agreement temp
     * @param iqvAgr
     * @return sobjectPartnerSoapSforceCom.sObject_x
    */
    @TestVisible
    private static Apttus__APTS_Agreement__c createAPTSAgreement(IQVIA_Agreement__c iqvAgr) {
        Apttus__APTS_Agreement__c tempObj = new Apttus__APTS_Agreement__c();
        //tempObj.type_x = 'Apttus__APTS_Agreement__c';
        tempObj.Name = iqvAgr.Name;
        tempObj.Apttus__Subtype__c = iqvAgr.Subtype__c;
        tempObj.Account_Country__c = iqvAgr.Account_Country__c;
        tempObj.RecordTypeId = CON_CLM.Generic_RECORDTYPEID;
        tempObj.OwnerId = iqvAgr.OwnerId;
        tempObj.Apttus__Requestor__c = iqvAgr.Requestor__c;
        tempObj.IQVIA_Agreement__c = iqvAgr.Id;
        tempObj.Apttus__Perpetual__c = true;
        tempObj.Apttus__Agreement_Number__c = iqvAgr.Contract_Auto_Number__c;
        tempObj.CreatedById = iqvAgr.OwnerId;
        tempObj.LastModifiedById = iqvAgr.OwnerId;
        return tempObj;
    }
    /**
    * This method is used to update IQVIA AGreement
    * @param 
    * @return
    */ 
    public static void updateIqvAgreementAsync(Map<Id, IQVIA_Agreement__c> iqvAgreementMap, 
        Map<Id, Apttus__APTS_Agreement__c> IqviaAgreementIdtoCongaAgreement) {
        List<IQVIA_Agreement__c> iqvAgrToUpdate = new List<IQVIA_Agreement__c>();
            
        for(Apttus__APTS_Agreement__c agr: IqviaAgreementIdtoCongaAgreement.values()) {
            IQVIA_Agreement__c iqvAgr = iqvAgreementMap.get(agr.IQVIA_Agreement__c);
            iqvAgr.Conga_Agreement_Id__c = agr.Id;
            iqvAgrToUpdate.add(iqvAgr);
        }
        
        if(!iqvAgrToUpdate.isEmpty()) {
            try {  
                fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
                    new Schema.SObjectType[] {
                    	IQVIA_Agreement__c.SObjectType
                    }
                );
                uow.registerDirty(iqvAgrToUpdate);
                uow.commitWork();
            } catch(DMLException dmlExp) {
                System.debug(System.LoggingLevel.ERROR, dmlExp.getMessage() + ' \n ' + dmlExp.getStackTraceString());
            }
        }
	}

    /**
    * This method is used to update Request Date
    * @param 
    * @return
    */ 
    public static void updateRequestDate(List<IQVIA_Agreement__c> agreementList, Map<Id, IQVIA_Agreement__c> oldMap) {
         
        for(IQVIA_Agreement__c agr: agreementList) {
            if(oldMap != null && oldMap.get(agr.Id).Status__c == CON_CLM.STATUS_OTHER_PARTY_REVIEW 
                && agr.Status__c == CON_CLM.INTERNAL_REVIEW) {
                agr.Request_Date__c = Datetime.now();
            }
        }
	}
    
    /**
    * This method is used to update status and status category for parallel change order amendments 
    * @param List<IQVIA_Agreement__c> agreementList
    * @param Map<Id, IQVIA_Agreement__c> oldMap
    */ 
    public static void updateParallelChangeOrderAmendments(List<IQVIA_Agreement__c> agreementList, 
        Map<Id, IQVIA_Agreement__c> oldMap) {
        Set<String> agreementNumbers = new Set<String>();
        Set<Id> agrIds = new Set<Id>();
        Set<Id> previousAgrIds = new Set<Id>();
        Set<Id> cancelledAgrIds = new Set<Id>();
        List<IQVIA_Agreement__c> lstAgreement = new List<IQVIA_Agreement__c>();
        Map<Id, String> idToStatusCategoryMap = new Map<Id, String>();
        Map<String, Set<Id>> agrNoToInFlightAgrIdsMap = new Map<String, Set<Id>>();
        Map<Id, Id> inFlightCOIdToPreviousId = new Map<Id, Id>();
            
        for(IQVIA_Agreement__c agr : agreementList) {
            if(oldMap != null && agr.Status_Category__c != oldMap.get(agr.Id).Status_Category__c 
                && agr.Status__c != oldMap.get(agr.Id).Status__c && agr.Version_Number__c > 0
                && (agr.Status_Category__c == CON_CLM.CANCELLED || agr.Status_Category__c == CON_CLM.IN_EFFECT)) {
                agreementNumbers.add(agr.Agreement_Number__c);
                agrIds.add(agr.Id);
                if(agr.Status_Category__c == CON_CLM.IN_EFFECT) {
                    idToStatusCategoryMap.put(agr.Agreement_Cloned_From__c, CON_CLM.AMENDED);
                }
                if(agr.Status_Category__c == CON_CLM.CANCELLED) {
                    cancelledAgrIds.add(agr.Id);
                }
            }
        }
        if(!agrIds.isEmpty()) {
            Set<String> fieldSet = new Set<String>{'Id', 'Status_Category__c', 'Status__c', 'Agreement_Cloned_From__c',
                'Agreement_Number__c'}; 
            String condition = 'Agreement_Number__c IN: strSet AND (Id NOT IN: agrIds)' 
                + 'AND (Status_Category__c IN (\'' + CON_CLM.REQUEST + '\', \'' 
                + CON_CLM.IN_AUTHORING + '\' ,\'' + CON_CLM.IN_SIGNATURES + '\'))';
            lstAgreement = new SLT_IQVIA_Agreement().getAgreementListByConditions(fieldSet, agreementNumbers, agrIds, condition);
        }
        for(IQVIA_Agreement__c agr : lstAgreement) {
            if(!agrNoToInFlightAgrIdsMap.containsKey(agr.Agreement_Number__c)) {
                agrNoToInFlightAgrIdsMap.put(agr.Agreement_Number__c, new Set<Id>{agr.Id});
            } else {
                agrNoToInFlightAgrIdsMap.get(agr.Agreement_Number__c).add(agr.Id);
            }
        }
        for(IQVIA_Agreement__c agr : agreementList) {
            if(agrNoToInFlightAgrIdsMap.containsKey(agr.Agreement_Number__c)){
                if(agr.Status_Category__c == CON_CLM.IN_EFFECT) {
                    agr.Status__c = CON_CLM.BEING_AMENDED;
                    for(Id inFlightCOId: agrNoToInFlightAgrIdsMap.get(agr.Agreement_Number__c)) {
                        inFlightCOIdToPreviousId.put(inFlightCOId, agr.Id);
                    }
                }
            }
            if(!agrNoToInFlightAgrIdsMap.containsKey(agr.Agreement_Number__c) && cancelledAgrIds.contains(agr.Id)) {
                idToStatusCategoryMap.put(agr.Agreement_Cloned_From__c, CON_CLM.IN_EFFECT);
            }
        }
        if(!idToStatusCategoryMap.isEmpty()) {
            updatePreviousAgrForParallelCO(idToStatusCategoryMap);
        }
        if(!inFlightCOIdToPreviousId.isEmpty()) {
            changePreviousAgrForParallelCO(inFlightCOIdToPreviousId);
        }
    }
    
    @future
    public static void updatePreviousAgrForParallelCO(Map<Id, String> idToStatusCategoryMap) {
        Set<String> fieldSet = new Set<String>{'Id', 'Status_Category__c', 'Status__c'};
        List<IQVIA_Agreement__c> lstAgreement = new SLT_IQVIA_Agreement().getIQVIAAgreementFieldsById(
            idToStatusCategoryMap.keySet(), fieldSet);
        for(IQVIA_Agreement__c agr : lstAgreement) {
            if(idToStatusCategoryMap.get(agr.Id) == CON_CLM.AMENDED) {
                agr.Status_Category__c = CON_CLM.AMENDED;
                agr.Status__c = CON_CLM.SUPERSEDED;
            }
            if(idToStatusCategoryMap.get(agr.Id) == CON_CLM.IN_EFFECT) {
                agr.Status__c = CON_CLM.ACTIVATED;
            }
        }
        if(!lstAgreement.isEmpty()) {
            try {  
                fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
                    new Schema.SObjectType[] {
                        IQVIA_Agreement__c.SObjectType
                    }
                );
                uow.registerDirty(lstAgreement);
                uow.commitWork();
            } 
            catch(DMLException dmlExp) {
                System.debug(System.LoggingLevel.ERROR, dmlExp.getMessage() + ' \n ' + dmlExp.getStackTraceString());
            }
        }
    }
    
    @future
    public static void changePreviousAgrForParallelCO(Map<Id, Id> inFlightCOIdToPreviousId) {
        Set<String> fieldSet = new Set<String>{'Id', 'Agreement_Cloned_From__c'};
        List<IQVIA_Agreement__c> lstAgreement = new List<IQVIA_Agreement__c>();
        for(Id inFlightCoId : inFlightCOIdToPreviousId.keySet()) {
            IQVIA_Agreement__c agr = new IQVIA_Agreement__c();
            agr.Id = inFlightCoId;
            agr.Agreement_Cloned_From__c = inFlightCOIdToPreviousId.get(inFlightCoId);
            lstAgreement.add(agr);
        }
        if(!lstAgreement.isEmpty()) {
            try {  
                fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
                    new Schema.SObjectType[] {
                        IQVIA_Agreement__c.SObjectType
                    }
                );
                uow.registerDirty(lstAgreement);
                uow.commitWork();
            } 
            catch(DMLException dmlExp) {
                System.debug(System.LoggingLevel.ERROR, dmlExp.getMessage() + ' \n ' + dmlExp.getStackTraceString());
            }
        }
	}

    /**
     * This method updates conga agreement's name related to the iqvia agreement
     * @param List<IQVIA_Agreement__c> lstAgreements
     * @param Map<Id, IQVIA_Agreement__c> oldMap
     */
    public static void updateCongaAgreementName(List<IQVIA_Agreement__c> lstAgreements, Map<Id, IQVIA_Agreement__c> oldMap) {
        List<Apttus__APTS_Agreement__c> agreementListToUpdate = new List<Apttus__APTS_Agreement__c>();
        for(IQVIA_Agreement__c iqvAgr: lstAgreements) {
            if(oldMap != null && iqvAgr.Conga_Agreement_Id__c != null && iqvAgr.Name != oldMap.get(iqvAgr.Id).Name) {
                Apttus__APTS_Agreement__c agreement = new Apttus__APTS_Agreement__c();
                agreement.Id = iqvAgr.Conga_Agreement_Id__c;
                agreement.Name = iqvAgr.Name;
                agreementListToUpdate.add(agreement);
            }
        }
        if(!agreementListToUpdate.isEmpty()) {
            try {
                fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
                    new Schema.SObjectType[] {
                        Apttus__APTS_Agreement__c.SObjectType
                    }
                );
                uow.registerDirty(agreementListToUpdate);
                UTL_ExecutionControl.disableTriggerCRUDAGR = true;
                uow.commitWork();
                UTL_ExecutionControl.disableTriggerCRUDAGR = false;
            } catch(Exception e) {
                throw e;
            }
        }
    }
    /**
    * This method is used to update search field
    * @param 
    * @return
    */ 
    public static void updateSearchField(List<IQVIA_Agreement__c> agreementList, Map<Id, IQVIA_Agreement__c> oldMap) {
        Set<Id> accountIds = new Set<Id>();
        Map<Id, Account> accountMap = new Map<Id, Account>();
        for(IQVIA_Agreement__c iqAGR : agreementList) {
            if(oldMap != null && (oldMap.get(iqAGR.Id).Account__c != iqAGR.Account__c
                || oldMap.get(iqAGR.Id).Agreement_Number__c != iqAGR.Agreement_Number__c
                || oldMap.get(iqAGR.Id).Version_Number__c != iqAGR.Version_Number__c)) {
                if(iqAGR.Account__c != null) {
                    accountIds.add(iqAGR.Account__c);
                }
            }
        }
        if(!accountIds.isEmpty()) {
            accountMap = new SLT_Account().selectByAccountId(accountIds, new Set<String>{'Id', 'Name'});
        }
        for(IQVIA_Agreement__c iqAGR : agreementList) {
            if(oldMap != null && (oldMap.get(iqAGR.Id).Account__c != iqAGR.Account__c
                || oldMap.get(iqAGR.Id).Agreement_Number__c != iqAGR.Agreement_Number__c
                || oldMap.get(iqAGR.Id).Version_Number__c != iqAGR.Version_Number__c)) {
                if(accountMap.containsKey(iqAGR.Account__c)) {
                    iqAGR.Search_Field__c = accountMap.get(iqAGR.Account__c).Name+''+iqAGR.Agreement_Number__c+'.'+iqAGR.Version_Number__c;               
                } else {
                    iqAGR.Search_Field__c = iqAGR.Agreement_Number__c+'.'+iqAGR.Version_Number__c;
                }
            }
        }
    }
    
    /**
    * This method is used to activate the fully signed agreements
    * @param 
    * @return
    */ 
    public static void activateFullySignedAgreements(List<IQVIA_Agreement__c> agreementList, Map<Id, IQVIA_Agreement__c> oldMap) {
        List<IQVIA_Agreement__c> updatedAgreementList = new List<IQVIA_Agreement__c>();
        for(IQVIA_Agreement__c iqAGR : agreementList) {
            if(oldMap != null && (oldMap.get(iqAGR.Id).Status_Category__c != iqAGR.Status_Category__c
                || oldMap.get(iqAGR.Id).Status__c != iqAGR.Status__c)
                && iqAGR.Status_Category__c == CON_CLM.IN_SIGNATURES && iqAGR.Status__c == CON_CLM.FULLY_SIGNED) {
                IQVIA_Agreement__c agreement = new IQVIA_Agreement__c();
                agreement.Id = iqAGR.Id;
                agreement.Status_Category__c = CON_CLM.IN_EFFECT;
                agreement.Status__c = CON_CLM.ACTIVATED;
                updatedAgreementList.add(agreement); 
            }
        }
        if(!updatedAgreementList.isEmpty()) {
            try {  
                fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
                    new Schema.SObjectType[] {
                        IQVIA_Agreement__c.SObjectType
                    }
                );
                uow.registerDirty(updatedAgreementList);
                uow.commitWork();
            } catch(DMLException dmlExp) {
                System.debug(System.LoggingLevel.ERROR, dmlExp.getMessage() + ' \n ' + dmlExp.getStackTraceString());
            }
        }
    }

    /**
    * This method is used to make Requestor as owner of the agreement when it is fully signed
    * @param 
    * @return
    */ 
    public static void updateAGROnFullySigned(List<IQVIA_Agreement__c> agreementList, Map<Id, IQVIA_Agreement__c> oldMap) {
        for(IQVIA_Agreement__c iqAGR : agreementList) {
            if(oldMap != null && (oldMap.get(iqAGR.Id).Status_Category__c != iqAGR.Status_Category__c
                || oldMap.get(iqAGR.Id).Status__c != iqAGR.Status__c)
                && iqAGR.Status_Category__c == CON_CLM.IN_SIGNATURES && iqAGR.Status__c == CON_CLM.FULLY_SIGNED
				&& iqAGR.Requestor__c != null) {
                iqAGR.OwnerId = iqAGR.Requestor__c;
            }
        }
    }

    /**
    * This method is used to update activated by and activation field on ineffect/activated
    * @param 
    * @return
    */ 
    public static void updateActivationFields(List<IQVIA_Agreement__c> agreementList, Map<Id, IQVIA_Agreement__c> oldMap) {
        Set<Id> accountIds = new Set<Id>();
        Map<Id, Account> accountMap = new Map<Id, Account>();
        for(IQVIA_Agreement__c iqAGR : agreementList) {
            if(oldMap != null && oldMap.get(iqAGR.Id).Status_Category__c != iqAGR.Status_Category__c
                && oldMap.get(iqAGR.Id).Status__c != iqAGR.Status__c
                && iqAGR.Status_Category__c == CON_CLM.IN_EFFECT
                && iqAGR.Status__c == CON_CLM.ACTIVATED) {
                iqAGR.Activated_By__c = UserInfo.getUserId();
                iqAGR.Activated_Date__c = System.today();
            }
        }
    }
    
    /**
    * This method is used to set default account from site submission record.
    * @param List<IQVIA_Agreement__c> agreementList
    */
    public static void setDefaultAccount(List<IQVIA_Agreement__c> agreementList) {
        Set<Id> siteSubmissionIds = new Set<Id>();
        Map<Id, Site_Submission__c> siteSubmissionMap = new Map<Id, Site_Submission__c>();
        Set<String> fieldSet = new Set<String>{'Id', 'Opportunity__r.Account.Id', 'PI__c', 'Site__c'};
        for(IQVIA_Agreement__c agr : agreementList) {
            if(agr.Site_Submission__c != null) {
                siteSubmissionIds.add(agr.Site_Submission__c); 
            }
        }
        if(!siteSubmissionIds.isEmpty()) {
            siteSubmissionMap = new Map<Id, Site_Submission__c>(new SLT_SiteSubmission().getSiteSubmissionById(siteSubmissionIds, fieldSet)); 
        }
        if(siteSubmissionMap != null && !siteSubmissionMap.isEmpty()) {
            for(IQVIA_Agreement__c agr : agreementList) {
                if(agr.Site_Submission__c != null && siteSubmissionMap.containsKey(agr.Site_Submission__c)) {
                    if(agr.Subtype__c == CON_CLM.CLINIC_CONTRACT) {
                        agr.Account__c = siteSubmissionMap.get(agr.Site_Submission__c).Site__c;
                    }
                    else if(agr.Subtype__c == CON_CLM.CUSTOMER_CONTRACT) {
                        agr.Account__c = siteSubmissionMap.get(agr.Site_Submission__c).Opportunity__r.Account.Id;
                    }
                    else if(agr.Subtype__c == CON_CLM.INVESTIGATOR_CONTRACT) {
                        agr.Account__c = siteSubmissionMap.get(agr.Site_Submission__c).PI__c;
                    }
                }
            }
        }
    }

    public static void createAROnActivation(List<IQVIA_Agreement__c> agreements, Map<Id, IQVIA_Agreement__c> oldMap) {
        Set<Id> agrIds = new Set<Id>();
        CLM_Configuration__c configuration = CLM_Configuration__c.getOrgDefaults();
        if(configuration.Enable_Agreement_Repository__c) {
            for(IQVIA_Agreement__c agr: agreements) {
                if((oldMap != null && oldMap.get(agr.Id).Status_Category__c != agr.Status_Category__c && oldMap.get(agr.Id).Status__c != agr.Status__c)
                    && (agr.Status_Category__c == CON_CLM.IN_EFFECT && agr.Status__c == CON_CLM.ACTIVATED && agr.Agreement_Repository_Number__c == null)) {
                    agrIds.add(agr.Id);
                }
            }
            if(!agrIds.isEmpty()) {
                createAgreementRepository(agrIds);
            }
        }
    }
    
    @future
    public static void createAgreementRepository(Set<Id> agreementIds) {
        Map<Id, Agreement_Repository__c> agrARMap = new Map<Id, Agreement_Repository__c>();
        Map<Id, Id> cdIdToagrIdMap = new Map<Id, Id>();
        Map<Id, ContentVersion> agrIdToCVMap = new Map<Id, ContentVersion>();
        Map<Id, AR_Document__c> arToARDocMap = new Map<Id, AR_Document__c>();
        Map<Id, Agreement_Repository__c> newARMap = new Map<Id, Agreement_Repository__c>();
        Map<Id, ContentVersion> newCVMap = new Map<Id, ContentVersion>();
        List<ContentDocumentLink> newCDLList = new List<ContentDocumentLink>();
        List<AR_Document__c> newARDoc = new List<AR_Document__c>();
        List<Agreement_Repository_Event__e> arEventList = new List<Agreement_Repository_Event__e>();
        List<Agreement_Repository_Event__e> arEventForOppList = new List<Agreement_Repository_Event__e>();
        Map<Id, Id> agrToExistingARs = new Map<Id, Id>();
        Set<Id> cvIds = new Set<Id>();
        List<ContentVersion> cvList = new List<ContentVersion>();
        try{
            List<IQVIA_Agreement__c> iqAGRList = new SLT_IQVIA_Agreement().getIQVIAAgreementFieldsById(
                agreementIds, new Set<String>{'Id','Account__c','Subtype__c','Related_Opportunity__c', 'Related_Opportunity__r.AR_Comments__c',
                'Original_Agreement__c', 'Original_Agreement__r.Agreement_Repository_Number__c', 'Agreement_Cloned_From__c', 
                'Agreement_Cloned_From__r.Agreement_Repository_Number__c', 'Version_Number__c'});
            if(!iqAGRList.isEmpty()) {
                Set<String> arNumbers = new Set<String>();
                for(IQVIA_Agreement__c agr: iqAGRList) {
                    if(agr.Original_Agreement__c != null) {
                        arNumbers.add(agr.Original_Agreement__r.Agreement_Repository_Number__c);
                    }
                    if(agr.Agreement_Cloned_From__c != null) {
                        arNumbers.add(agr.Agreement_Cloned_From__r.Agreement_Repository_Number__c);
                    }
                }
                List<Agreement_Repository__c> existingARs = new SLT_Agreement_Repository(false, false).getAgreementRepositoryByARNumbers('AR_Number__c IN : arNumbers', arNumbers,
                    new Set<String>{'Id', 'IQVIA_Agreement__c', 'AR_Number__c'});
                for(Agreement_Repository__c ar : existingARs) {
                    if(ar.IQVIA_Agreement__c != null) {
                        agrToExistingARs.put(ar.IQVIA_Agreement__c, ar.Id);
                    }
                }
                List<ContentDocumentLink> cdlList = new SLT_ContentDocumentLink().getContentDocumentBasedOnLinkedEntity(agreementIds);
                if(!cdlList.isEmpty()) {
                    for(ContentDocumentLink cdl: cdlList) {
                        cdIdToagrIdMap.put(cdl.ContentDocumentId, cdl.LinkedEntityId);
                    }
                    String condition = 'ContentDocumentId IN :IdSet AND Description= \''+CON_CLM.FINAL_SIGNED_DOCUMENT+'\' AND FileType = \''+CON_CLM.PDF+'\''	;
                    Set<String> fieldSet = new Set<String>{'Title', 'VersionData', 'ContentLocation', 'PathOnClient'};
                    cvList = new SLT_ContentVersion().getContentVersionByCondition(fieldSet, condition, cdIdToagrIdMap.keySet());
                }
                if(!cvList.isEmpty()) {
                    for(ContentVersion cv : cvList) {
                        ContentVersion newCV = new ContentVersion(Title = cv.Title, VersionData = cv.VersionData, ContentLocation = cv.ContentLocation, PathOnClient = cv.PathOnClient);
                        agrIdToCVMap.put(cdIdToagrIdMap.get(cv.ContentDocumentId), newCV);
                    }
                    for(IQVIA_Agreement__c agreement: iqAGRList) {
                        Agreement_Repository__c agreementRepository = new Agreement_Repository__c(Name = agrIdToCVMap.get(agreement.Id).Title, Account__c = agreement.Account__c, 
                            Agreement_Type__c = agreement.Subtype__c, Related_Opportunity__c = agreement.Related_Opportunity__c, IQVIA_Agreement__c = agreement.Id);  
                            if(agreement.Version_Number__c > 0) {
                                if(agrToExistingARs.containsKey(agreement.Original_Agreement__c)) {
                                    agreementRepository.Original_Agreement__c = agrToExistingARs.get(agreement.Original_Agreement__c);
                                }
                                if(agrToExistingARs.containsKey(agreement.Agreement_Cloned_From__c)){
                                    agreementRepository.Previous_Agreement__c = agrToExistingARs.get(agreement.Agreement_Cloned_From__c);
                                }                               
                            }               
                        agrARMap.put(agreement.id, agreementRepository);
                    }
                }
                if(!agrARMap.isEmpty()) {
                    fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
                        new Schema.SObjectType[] {Agreement_Repository__c.SObjectType}
                    );
                    uow.registerNew(agrARMap.values());
                    uow.commitWork();
                    for(Agreement_Repository__c ar: agrARMap.values()) {
                        if(ar.Id != null) {
                            AR_Document__c arDocument = new AR_Document__c(Name = ar.Name, AR_Name__c = ar.Id);
                            arToARDocMap.put(ar.Id, arDocument);
                        }
                    }
                }               
                if(!arToARDocMap.isEmpty()) {
                    fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
                        new Schema.SObjectType[] {AR_Document__c.SObjectType}
                    );
                    uow.registerNew(arToARDocMap.values());
                    uow.commitWork();
                }
                if(!agrIdToCVMap.isEmpty()) {
                    fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
                        new Schema.SObjectType[] {ContentVersion.SObjectType}
                    );
                    uow.registerNew(agrIdToCVMap.values());
                    uow.commitWork();
                }
                if(!arToARDocMap.isEmpty()) {
                    String condsn = 'Id IN: docIds';
                    List<Agreement_Repository__c> insertedARList = new SLT_Agreement_Repository(false, false).getAgreementRepository(condsn, artoARDocMap.keySet());
                    newARMap = new Map<Id, Agreement_Repository__c>(insertedARList);
                }
                if(!agrIdToCVMap.isEmpty()) {
                    for(ContentVersion cv: agrIdToCVMap.values()) {
                        cvIds.add(cv.Id);
                    }
                    Set<String> fields = new Set<String>{'ContentDocumentId'};
                    List<ContentVersion> latestCVList = new SLT_ContentVersion().getContentVersionByIds(cvIds, fields);
                    newCVMap = new Map<Id, ContentVersion>(latestCVList);
                }
                for(IQVIA_Agreement__c agr: iqAGRList) {
                    if(agrARMap.containsKey(agr.Id) && newARMap.containsKey(agrARMap.get(agr.Id).Id)) {
                        Agreement_Repository_Event__e arEvent = new Agreement_Repository_Event__e(Object_Name__c = CON_CLM.IQVIA_AGR_OBJ_NAME, 
                            Record_Id__c = agr.Id, AR_Comments__c = newARMap.get(agrARMap.get(agr.Id).Id).AR_Number__c);  
                        arEventList.add(arEvent);
                    }
                    if(agrIdToCVMap.containsKey(agr.Id) && newCVMap.containsKey(agrIdToCVMap.get(agr.Id).Id) && agrARMap.containsKey(agr.Id) 
                        && arToARDocMap.containsKey(agrARMap.get(agr.Id).Id)) {
                        ContentDocumentLink cDocLink = new ContentDocumentLink(ContentDocumentId = newCVMap.get(agrIdToCVMap.get(agr.Id).Id).ContentDocumentId, 
                            LinkedEntityId = arToARDocMap.get(agrARMap.get(agr.Id).Id).Id, ShareType = 'I');
                        newCDLList.add(cDocLink);
                        AR_Document__c arDOC = new AR_Document__c(Id = arToARDocMap.get(agrARMap.get(agr.Id).Id).Id, Content_Document_Id__c = cDocLink.ContentDocumentId);
                        newARDoc.add(arDOC);
                    }                   
                }
                if(!arEventList.isEmpty()) {
                    EventBus.publish(arEventList);
                }
                for(IQVIA_Agreement__c agr: iqAGRList) {
                    if(agr.Related_Opportunity__r.AR_Comments__c == null && agrARMap.containsKey(agr.Id) 
                        && newARMap.containsKey(agrARMap.get(agr.Id).Id)) {
                        Agreement_Repository_Event__e arEvent = new Agreement_Repository_Event__e(Object_Name__c = CON_CLM.OPP_OBJ_API_NAME, Record_Id__c = agr.Related_Opportunity__c,
                            AR_Comments__c = newARMap.get(agrARMap.get(agr.Id).Id).AR_Number__c);
                        arEventForOppList.add(arEvent);
                    }
                }
                if(!arEventForOppList.isEmpty()) {
                    EventBus.publish(arEventForOppList);
                }
                if(!newCDLList.isEmpty() && !newARDoc.isEmpty()) {
                    fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
                        new Schema.SObjectType[] {ContentDocumentLink.SObjectType, AR_Document__c.SObjectType}
                    );
                    uow.registerNew(newCDLList);
                    uow.registerDirty(newARDoc);
                    uow.commitWork();
                }	
            } 
        }
        catch(Exception e) {
            System.debug(System.LoggingLevel.ERROR, e.getMessage() + ' \n ' + e.getStackTraceString());
            EventBus.publish(new Apex_Error_Log_Event__e(
                Object__c = CON_CLM.AR_OBJECT_API_NAME,
                Error_Message__c = e.getMessage() + '\n' + e.getStackTraceString(),
                Running_User__c = UserInfo.getUserId(),
                Source_Module__c = 'CLM'
            ));
        }   
    }
}