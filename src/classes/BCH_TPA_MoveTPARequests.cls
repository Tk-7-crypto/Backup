global class BCH_TPA_MoveTPARequests implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {
    private Set<Id> stTPAId = new Set<Id>();
    private String accId;
    private String contId;
    private String userId;
    global String newContactName;
    private Set<String> clientContactEmails = new Set<String>();
    global List<TPA_request__c> lstTPAToBeUpdated = new List<TPA_request__c>();
   
    global BCH_TPA_MoveTPARequests(Set<Id> requestList, String aId, String cId, String uId, String contactName) {
        stTPAId = requestList;
        accId = aId;
        contId = cId;
        userId = uId;
        newContactName = contactName;
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        Set<String> fieldSet = new Set<String>{'ClientContact__r.Name', 'ClientContact__r.Email'};
        return SLT_TPARequest.instance.queryLocatorTPARequestById(stTPAId, fieldSet);
    }

    global void execute(Database.BatchableContext BC, List<sObject> objList) {
        List<Agreement_Contact__c> lstAgreementContact = new List<Agreement_Contact__c>();//Added by Govind under CR-9411
        List<TPA_Contact__c> lstTPAContacts = new List<TPA_Contact__c>();//Added by Govind under CR-9411
        for(sObject sObj : objList) {
            TPA_request__c objRequest = (TPA_request__c)sObj;
            objRequest.Client_Address__c = accId;
            objRequest.ClientContact__c = contId;
            objRequest.OwnerId = userId;
            clientContactEmails.add(objRequest.ClientContact__r.Email);//Added by Govind under CR-9411
            if(objRequest.Client_Company_Name_Address__c != null) {
                objRequest.Client_Company_Name_Address__c = accId;
            }
            lstTPAToBeUpdated.add(objRequest);
            //TPAQueryHelper.updateActivityHistory(new Map<Id,String>{objRequest.Id=>''}, 'TPA Request Moved from ' + objRequest.ClientContact__r.Name+' to ' + newContactName);
        }
        try {
            system.debug('lstTPAToBeUpdated : ' + lstTPAToBeUpdated); 
            update lstTPAToBeUpdated;
            // Added by Govind under CR-9411 Start
            lstAgreementContact = [select id from Agreement_Contact__c where TPA_Request__c in: stTPAId  and Email__c in: clientContactEmails];
            system.debug('lstAgreementContact size : ' + lstAgreementContact);
            if(lstAgreementContact.size() > 0) {
                delete lstAgreementContact;
            }
            lstTPAContacts = [select id from TPA_Contact__c where TPA_Request__c in: stTPAId and Email__c in: clientContactEmails];
            system.debug('lstAgreementContact size## : ' + lstAgreementContact);
            if(lstTPAContacts.size() > 0)
                delete lstTPAContacts;
             // Added by Govind under CR-9411 End
        }
        catch(Exception exp) {
            System.debug(exp);
        }        
    }

    global void finish(Database.BatchableContext BC) {
        boolean isLastRecord = false;
        for(integer i = 0; i < lstTPAToBeUpdated.size(); i++) {
            TPA_request__c tpaReqObj = lstTPAToBeUpdated[i];
            if(i == lstTPAToBeUpdated.size() - 1) {
                isLastRecord = true;
            }
            SRV_TPA_TPARequest.updateActivityHistory(tpaReqObj.Id, 'TPA Request Moved from ' + tpaReqObj.ClientContact__r.Name+' to ' + newContactName, isLastRecord);
        }
        TPA_Settings__c objTPASetting = TPA_Settings__c.getInstance();
        TPA_Settings__c toggleTPASetting = [select Id,TPA_Send_Emails__c,Modify_Agreement_Request__c from TPA_Settings__c where Id =: objTPASetting.SystemAdminId__c];
        toggleTPASetting.TPA_Send_Emails__c = true;
       // toggleTPASetting.Modify_Agreement_Request__c = false;
        update toggleTPASetting;
    }
}