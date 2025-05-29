/**
 * This is Apttus_DocuApi__DocuSignEnvelopeRecipientStatus__c helper class.
 * version : 1.0 
 */
public class DAOH_APTS_DocuApi_DocuSignEnvelopeRS {
    /**
    * This method is used to update Signer Details in Agreement
    * @param List<Apttus_DocuApi__DocuSignEnvelopeRecipientStatus__c> recipientStatusList
    * @return void  
    */
    public static void updateSignerDetailsInAgreement(List<Apttus_DocuApi__DocuSignEnvelopeRecipientStatus__c> recipientStatusList) {
        Set<Id> recipientStatusIds = new Set<Id>(); 
        Set<String> emailIds = new Set<String>(); 
        Map<String, Contact> conMap = new Map<String, Contact>();
        List<Apttus_DocuApi__DocuSignEnvelopeRecipientStatus__c> recipientStatusListToIterate = new List<Apttus_DocuApi__DocuSignEnvelopeRecipientStatus__c>();

        for(Apttus_DocuApi__DocuSignEnvelopeRecipientStatus__c drs : recipientStatusList){
            if(drs.Apttus_DocuApi__RoleName__c == CON_CLM.APTS_DOCUAPI_ROLENAME_SIGNER){
               recipientStatusIds.add(drs.Id); 
            }
        }

        recipientStatusListToIterate = new SLT_APTS_DocuApi_DS_EnvRecipientStatus().getDocuSignEnvelopeByIdAndStatus(recipientStatusIds, new Set<String>{'Id', 'Apttus_DocuApi__RecipientName__c', 'Apttus_DocuApi__SignedDateTime__c', 'Apttus_DocuApi__Email__c',
            'Apttus_DocuApi__Status__c', 'Apttus_DocuApi__DocuSignEnvelopeId__r.Apttus_CMDSign__Agreement__c', 'Apttus_DocuApi__DocuSignEnvelopeId__r.Apttus_CMDSign__Agreement__r.Apttus__Other_Party_Signed_By__r.Email',
            'Apttus_DocuApi__DocuSignEnvelopeId__r.Apttus_CMDSign__Agreement__r.Apttus__Company_Signed_By__r.Email', 'Apttus_DocuApi__Title__c'});

        for(Apttus_DocuApi__DocuSignEnvelopeRecipientStatus__c drs : recipientStatusListToIterate){
            emailIds.add(drs.Apttus_DocuApi__Email__c);
        }

        Map<Id,Apttus__APTS_Agreement__c> agreementDetailsMap = new Map<Id,Apttus__APTS_Agreement__c>();
        for(Contact con : new SLT_Contact().selectByEmailIdSet(emailIds)){
            conMap.put(con.Email, con);
        }

        for(Apttus_DocuApi__DocuSignEnvelopeRecipientStatus__c drs : recipientStatusListToIterate) {
            if(conMap.get(drs.Apttus_DocuApi__Email__c) != NULL && drs.Apttus_DocuApi__Status__c.equalsIgnoreCase('Completed')){
                Contact cont = conMap.get(drs.Apttus_DocuApi__Email__c);
                if((cont.RecordTypeId == CON_CLM.CONTACT_CONTACT_RECORDTYPEID) && (drs.Apttus_DocuApi__DocuSignEnvelopeId__r.Apttus_CMDSign__Agreement__r.Apttus__Other_Party_Signed_By__r.Email != drs.Apttus_DocuApi__Email__c)){
                    if(agreementDetailsMap.get(drs.Apttus_DocuApi__DocuSignEnvelopeId__r.Apttus_CMDSign__Agreement__c)!=NULL){
                        agreementDetailsMap.get(drs.Apttus_DocuApi__DocuSignEnvelopeId__r.Apttus_CMDSign__Agreement__c).Apttus__Other_Party_Signed_By__c = cont.Id;
                        agreementDetailsMap.get(drs.Apttus_DocuApi__DocuSignEnvelopeId__r.Apttus_CMDSign__Agreement__c).Apttus__Other_Party_Signed_Title__c = drs.Apttus_DocuApi__Title__c;
                        DateTime dT = drs.Apttus_DocuApi__SignedDateTime__c;
                        agreementDetailsMap.get(drs.Apttus_DocuApi__DocuSignEnvelopeId__r.Apttus_CMDSign__Agreement__c).Apttus__Other_Party_Signed_Date__c = (dT != null) ? (date.newinstance(dT.year(), dT.month(), dT.day())) : null;
                    } else{
                        Apttus__APTS_Agreement__c agr = new Apttus__APTS_Agreement__c();
                        agr.Id = drs.Apttus_DocuApi__DocuSignEnvelopeId__r.Apttus_CMDSign__Agreement__c;
                        agr.Apttus__Other_Party_Signed_By__c = cont.Id;
                        agr.Apttus__Other_Party_Signed_Title__c = drs.Apttus_DocuApi__Title__c;
                        DateTime dT = drs.Apttus_DocuApi__SignedDateTime__c;
                        agr.Apttus__Other_Party_Signed_Date__c = (dT != null) ? (date.newinstance(dT.year(), dT.month(), dT.day())) : null;
                        agreementDetailsMap.put(agr.Id,agr);
                    }
                }
                if((cont.RecordTypeId == CON_CLM.CONTACT_IQVIA_USER_CONTACT_RECORDTYPEID) && (drs.Apttus_DocuApi__DocuSignEnvelopeId__r.Apttus_CMDSign__Agreement__r.Apttus__Company_Signed_By__r.Email != drs.Apttus_DocuApi__Email__c)){
                    if(agreementDetailsMap.get(drs.Apttus_DocuApi__DocuSignEnvelopeId__r.Apttus_CMDSign__Agreement__c) != NULL){
                        agreementDetailsMap.get(drs.Apttus_DocuApi__DocuSignEnvelopeId__r.Apttus_CMDSign__Agreement__c).Apttus__Company_Signed_By__c = cont.Id;
                        DateTime dT = drs.Apttus_DocuApi__SignedDateTime__c;
                        agreementDetailsMap.get(drs.Apttus_DocuApi__DocuSignEnvelopeId__r.Apttus_CMDSign__Agreement__c).Apttus__Company_Signed_Date__c = (dT != null) ? (date.newinstance(dT.year(), dT.month(), dT.day())) : null;
                    } else{
                        Apttus__APTS_Agreement__c agr = new Apttus__APTS_Agreement__c();
                        agr.Id = drs.Apttus_DocuApi__DocuSignEnvelopeId__r.Apttus_CMDSign__Agreement__c;
                        agr.Apttus__Company_Signed_By__c = cont.Id;
                        DateTime dT = drs.Apttus_DocuApi__SignedDateTime__c;
                        agr.Apttus__Company_Signed_Date__c = (dT != null) ? (date.newinstance(dT.year(), dT.month(), dT.day())) : null;
                        agreementDetailsMap.put(agr.Id,agr);
                    }
                }
            }
        }
        if(agreementDetailsMap.size()>0){
            try {  
                fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
                    new Schema.SObjectType[] {
                        Apttus__APTS_Agreement__c.SObjectType
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