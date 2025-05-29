public class TGRH_TPADocuSignRecipientStatus {

    public Map<Id,String> agreementIdTaskSubjectMap;
    public Map<Id,dsfs__DocuSign_Recipient_Status__c> oldRecordsMap;
    
    public void onAfterInsert(List<dsfs__DocuSign_Recipient_Status__c> listRecipientStatus) {
        for(dsfs__DocuSign_Recipient_Status__c recStatusObj: listRecipientStatus) {
            this.updateRecipientDetailInTPARequest(new List<dsfs__DocuSign_Recipient_Status__c> {recStatusObj});
        }
    }

    public void onAfterUpdate(List<dsfs__DocuSign_Recipient_Status__c> listRecipientStatus) {
        for(dsfs__DocuSign_Recipient_Status__c recStatusObj: listRecipientStatus) {
            this.updateRecipientDetailInTPARequest(new List<dsfs__DocuSign_Recipient_Status__c> {recStatusObj});
            this.captureActivityInAgreementForReadReceipt(new List<dsfs__DocuSign_Recipient_Status__c> {recStatusObj});
        }
    }

    private void updateRecipientDetailInTPARequest(List<dsfs__DocuSign_Recipient_Status__c> listRecipientStatus) {
        System.debug('Method updateRecipientDetailInTPARequest Called');
        List<id> parentOfatt = new List<id>();   
        Map<String, String> recipientStatusRequestMap = new Map<String, String>(); 
        List<TPA_Request__c> requestToUpdate = new List<TPA_Request__c>();
        Map<Id,String> statusId = new Map<Id,String>();
        for(dsfs__DocuSign_Recipient_Status__c recipientStatus: [SELECT Id, 
                                                                        dsfs__Parent_Status_Record__c,
                                                                        dsfs__Date_Signed__c,
                                                                        dsfs__DocuSign_Recipient_Email__c,
                                                                        dsfs__Recipient_Status__c,
                                                                        dsfs__Parent_Status_Record__r.Undelivered_Email_Addresses__c,
                                                                        dsfs__Parent_Status_Record__r.Recipient_Signed_on_Paper__c, 
                                                                        dsfs__Parent_Status_Record__r.TPA_Request__c,
                                                                        LastActivityDate, 
                                                                        LastModifiedById, 
                                                                        LastModifiedDate,  
                                                                        SystemModstamp,
                                                                        dsfs__Parent_Status_Record__r.Related_Agreement_s_Record_Type__c 
                                                                FROM dsfs__DocuSign_Recipient_Status__c
                                                                where id IN : listRecipientStatus]) {
            if(recipientStatus.dsfs__Recipient_Status__c == 'Sent' || recipientStatus.dsfs__Date_Signed__c != null) {
                if(recipientStatus.dsfs__Parent_Status_Record__r.TPA_Request__c != null) {
                    parentOfatt.add(recipientStatus.dsfs__Parent_Status_Record__r.TPA_Request__c);
                    recipientStatusRequestMap.put(recipientStatus.dsfs__Parent_Status_Record__r.TPA_Request__c, recipientStatus.Id+','+recipientStatus.dsfs__Parent_Status_Record__r.Recipient_Signed_on_Paper__c);
                } 
            }
            if(recipientStatus.dsfs__Recipient_Status__c == 'AutoResponded') {
                statusId.put(recipientStatus.dsfs__Parent_Status_Record__c, recipientStatus.dsfs__DocuSign_Recipient_Email__c);
            }
        }
            
        List<dsfs__DocuSign_Status__c> lstStatus =  new List<dsfs__DocuSign_Status__c>();
        lstStatus = [select id,dsfs__Envelope_Status__c,Undelivered_Email_Addresses__c from dsfs__DocuSign_Status__c where id in: statusId.keySet()];
        for(dsfs__DocuSign_Status__c objStatus : lstStatus) {
            if(objStatus.dsfs__Envelope_Status__c != 'Voided') {
                if(objStatus.Undelivered_Email_Addresses__c == null) {
                    objStatus.Undelivered_Email_Addresses__c = '';
                }
                if(objStatus.Undelivered_Email_Addresses__c != null &&  objStatus.Undelivered_Email_Addresses__c != '') {
                    objStatus.Undelivered_Email_Addresses__c = objStatus.Undelivered_Email_Addresses__c +',';
                }
                objStatus.Undelivered_Email_Addresses__c = objStatus.Undelivered_Email_Addresses__c + statusId.get(objStatus.id);
            }
        }
        if(lstStatus.size() > 0) {
            update lstStatus;
        }
            
        for(TPA_Request__c request: [select id, Signer__c from TPA_Request__c where id IN : parentOfatt AND Request_Status__c != 'In Effect']) {
            String temp = recipientStatusRequestMap.get(request.id);
            List<String> lst = new List<String>();
            lst = temp.split(',');
            if(lst.size() > 0) {
                request.signer__c = lst[0];
            }             
            requestToUpdate.add(request);              
        }
           
        if(requestToUpdate.size() >0 ) {
            TGRH_TPARequest.updateTpaAfterSignature = true;
            update requestToUpdate;
            TGRH_TPARequest.updateTpaAfterSignature = false;
        }
    }    

    private void captureActivityInAgreementForReadReceipt(List<dsfs__DocuSign_Recipient_Status__c> listRecipientStatus) {
        String envId;
        Id statusId; 
        String subject; 
        Boolean IsUpdateAgreemnt = False; 
        Date newDateSigned; 
        String agreementId = ''; 
        String activityHistorySubject = '';
        
        agreementIdTaskSubjectMap = new Map<Id,String>();
        
        for(dsfs__DocuSign_Recipient_Status__c recipientObject: [SELECT Id,
                                                                        Name, 
                                                                        dsfs__Parent_Status_Record__c, 
                                                                        dsfs__Parent_Status_Record__r.TPA_Request__c,
                                                                        dsfs__Envelope_Id__c,
                                                                        LastActivityDate, 
                                                                        LastModifiedById, 
                                                                        LastModifiedDate,  
                                                                        SystemModstamp, 
                                                                        dsfs__Date_Delivered__c, 
                                                                        dsfs__Date_Signed__c 
                                                                FROM dsfs__DocuSign_Recipient_Status__c
                                                                where id IN : listRecipientStatus]) {
            agreementId = recipientObject.dsfs__Parent_Status_Record__r.TPA_Request__c;
            if(recipientObject.dsfs__Date_Delivered__c != oldRecordsMap.get( recipientObject.Id ).dsfs__Date_Delivered__c) {
                activityHistorySubject = 'Read Receipt of ' + recipientObject.Name;
                agreementIdTaskSubjectMap.put(recipientObject.dsfs__Parent_Status_Record__r.TPA_Request__c, 'Read Receipt of ' + recipientObject.Name );   
            }
            if(recipientObject.dsfs__Date_Signed__c != oldRecordsMap.get( recipientObject.Id ).dsfs__Date_Signed__c) {
                if(!agreementIdTaskSubjectMap.containskey(recipientObject.dsfs__Parent_Status_Record__r.TPA_Request__c)) {
                    activityHistorySubject = 'Agreement Signed by ' + recipientObject.Name;
                    agreementIdTaskSubjectMap.put(recipientObject.dsfs__Parent_Status_Record__r.TPA_Request__c, 'Agreement Signed by ' + recipientObject.Name); 
                } else {
                    subject = agreementIdTaskSubjectMap.get(recipientObject.dsfs__Parent_Status_Record__r.TPA_Request__c);                
                    activityHistorySubject = subject + ': Agreement Signed by ' + recipientObject.Name;
                    agreementIdTaskSubjectMap.put(recipientObject.dsfs__Parent_Status_Record__r.TPA_Request__c, subject + ': Agreement Signed by ' + recipientObject.Name);
                }
                
                if(recipientObject.dsfs__Date_Signed__c != null) {
                    IsUpdateAgreemnt = true;
                }
                
                newDateSigned = recipientObject.dsfs__Date_Signed__c.date();
                agreementId = recipientObject.dsfs__Parent_Status_Record__r.TPA_Request__c;
                envId = recipientObject.dsfs__Envelope_Id__c;
                statusId = recipientObject.dsfs__Parent_Status_Record__c;                
            }
        }
        
        if(activityHistorySubject != null && activityHistorySubject != '' && agreementId != null && agreementId != '') {
            SRV_TPA_TPARequest.updateActivityHistory(agreementId, activityHistorySubject, true);
        }
    }
}