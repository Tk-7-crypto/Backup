/**
 * This is IQ_DocuSignEnvelopeRecipientStatus__c helper class.
 * version : 1.0 
 */
public class DAOH_CLM_IQ_DocuSignEnvelopeRS {
    /**
    * This method is used to update Signer Details in Agreement
    * @param List<IQ_DocuSignEnvelopeRecipientStatus__c> recipientStatusList
    * @return void  
    */
    public static void updateSignerDetailsInAgreement(List<IQ_DocuSignEnvelopeRecipientStatus__c> recipientStatusList) {
        Set<Id> recipientStatusIds = new Set<Id>(); 
        Set<String> emailIds = new Set<String>(); 
        Map<String, Contact> conMap = new Map<String, Contact>();
        List<IQ_DocuSignEnvelopeRecipientStatus__c> recipientStatusListToIterate = new List<IQ_DocuSignEnvelopeRecipientStatus__c>();

        for(IQ_DocuSignEnvelopeRecipientStatus__c drs : recipientStatusList){
            if(drs.RoleName__c == CON_CLM.APTS_DOCUAPI_ROLENAME_SIGNER){
               recipientStatusIds.add(drs.Id); 
            }
        }

        recipientStatusListToIterate = new SLT_IQ_DS_EnvRecipientStatus().getDocuSignEnvelopeByIdAndStatus(recipientStatusIds, new Set<String>{'Id', 'RecipientName__c', 'SignedDateTime__c', 'Email__c',
            'Status__c', 'DocuSignEnvelopeId__r.Agreement__c', 'DocuSignEnvelopeId__r.Agreement__r.Other_Party_Signed_By__r.Email',
            'DocuSignEnvelopeId__r.Agreement__r.Company_Signed_By__r.Email', 'Title__c'});

        for(IQ_DocuSignEnvelopeRecipientStatus__c drs : recipientStatusListToIterate){
            emailIds.add(drs.Email__c);
        }
        Map<Id,IQVIA_Agreement__c> agreementDetailsMap = new Map<Id,IQVIA_Agreement__c>();
        for(IQVIA_Agreement_Team__c iqAgrTeam : new SLT_Agreement_Team().getAgreementTeamByCondition(emailIds,'Email__c IN :firstParam',new Set<String>{'Contact__r.Id', 'Contact__r.Email', 'Contact__r.AccountId', 'Contact__r.RecordTypeId'})){
            Contact con = new Contact(Id = iqAgrTeam.Contact__r.Id, Email = iqAgrTeam.Contact__r.Email, AccountId =iqAgrTeam.Contact__r.AccountId, RecordTypeId=iqAgrTeam.Contact__r.RecordTypeId);
            conMap.put(con.Email, con);
        }
        emailIds.removeAll(conMap.keySet());
        if(!emailIds.isEmpty()){
        	for(Contact con : new SLT_Contact().selectByEmailIdSet(emailIds)){
            	conMap.put(con.Email, con);
            }
        }

        for(IQ_DocuSignEnvelopeRecipientStatus__c drs : recipientStatusListToIterate) {
            if(conMap.get(drs.Email__c) != NULL && drs.Status__c.equalsIgnoreCase(CON_CLM.COMPLETED_STATUS)){
                Contact cont = conMap.get(drs.Email__c);
                if((cont.RecordTypeId == CON_CLM.CONTACT_CONTACT_RECORDTYPEID) && (drs.DocuSignEnvelopeId__r.Agreement__r.Other_Party_Signed_By__r.Email != drs.Email__c)){
                    if(agreementDetailsMap.get(drs.DocuSignEnvelopeId__r.Agreement__c)!=NULL){
                        agreementDetailsMap.get(drs.DocuSignEnvelopeId__r.Agreement__c).Other_Party_Signed_By__c = cont.Id;
                        agreementDetailsMap.get(drs.DocuSignEnvelopeId__r.Agreement__c).Other_Party_Signed_Title__c = drs.Title__c;
                        DateTime dT = drs.SignedDateTime__c;
                        agreementDetailsMap.get(drs.DocuSignEnvelopeId__r.Agreement__c).Other_Party_Signed_Date__c = (dT != null) ? (date.newinstance(dT.year(), dT.month(), dT.day())) : null;
                    } else{
                        IQVIA_Agreement__c agr = new IQVIA_Agreement__c();
                        agr.Id = drs.DocuSignEnvelopeId__r.Agreement__c;
                        agr.Other_Party_Signed_By__c = cont.Id;
                        agr.Other_Party_Signed_Title__c = drs.Title__c;
                        DateTime dT = drs.SignedDateTime__c;
                        agr.Other_Party_Signed_Date__c = (dT != null) ? (date.newinstance(dT.year(), dT.month(), dT.day())) : null;
                        agreementDetailsMap.put(agr.Id,agr);
                    }
                }
                if((cont.RecordTypeId == CON_CLM.CONTACT_IQVIA_USER_CONTACT_RECORDTYPEID) && (drs.DocuSignEnvelopeId__r.Agreement__r.Company_Signed_By__r.Email != drs.Email__c)){
                    if(agreementDetailsMap.get(drs.DocuSignEnvelopeId__r.Agreement__c) != NULL){
                        agreementDetailsMap.get(drs.DocuSignEnvelopeId__r.Agreement__c).Company_Signed_By__c = cont.Id;
                        DateTime dT = drs.SignedDateTime__c;
                        agreementDetailsMap.get(drs.DocuSignEnvelopeId__r.Agreement__c).Company_Signed_Date__c = (dT != null) ? (date.newinstance(dT.year(), dT.month(), dT.day())) : null;
                    } else{
                        IQVIA_Agreement__c agr = new IQVIA_Agreement__c();
                        agr.Id = drs.DocuSignEnvelopeId__r.Agreement__c;
                        agr.Company_Signed_By__c = cont.Id;
                        DateTime dT = drs.SignedDateTime__c;
                        agr.Company_Signed_Date__c = (dT != null) ? (date.newinstance(dT.year(), dT.month(), dT.day())) : null;
                        agreementDetailsMap.put(agr.Id,agr);
                    }
                }
            }
        }
        if(agreementDetailsMap.size()>0){
            try {  
                fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
                    new Schema.SObjectType[] {
                        IQVIA_Agreement__c.SObjectType
                    }
                );
                uow.registerDirty(agreementDetailsMap.values());
                uow.commitWork();
            } catch(DMLException dmlExp) {
                System.debug(System.LoggingLevel.ERROR, dmlExp.getMessage() + ' \n ' + dmlExp.getStackTraceString());
            }
        }
    }
}