/**
 * This is SAP Contact trigger handler class.
 * version : 1.0
 */
public class DAOH_SAP_Contact {
    
    /**
     * This method is used to set SAP_Contact fields.
     * @params  newList List<SAP_Contact__c>
     * @params  oldMap Map<Id, SAP_Contact__c>
     * @return  void
     */
    public static void setSAPContactFields(List<SAP_Contact__c> newList, Map<Id, SAP_Contact__c> oldMap) {
        Set<Id> addressIds = new Set<Id>();
        for(SAP_Contact__c sap : newList) {
            addressIds.add(sap.Address__c);
        }
        Set<String> fieldSet = new Set<String>();
        fieldSet.add('Id');
        fieldSet.add('Language__c');
        SLT_Address sltAddress = new SLT_Address();
        Map<Id, Address__c> addMap = sltAddress.selectByAddressId(addressIds, fieldSet);
        
        for (SAP_Contact__c sap :newList) {
            if (Trigger.isInsert) {
                if(sap.MDM_Validation_Status__c == CON_CRM.MDM_VALIDATION_STATUS_VALIDATED) {
                    sap.RecordTypeId = CON_CRM.Validated_SAP_Contact_RecordId;
                } else if(sap.MDM_Validation_Status__c == CON_CRM.MDM_UNVALIDATION_STATUS_VALIDATED || sap.MDM_Validation_Status__c == CON_CRM.MDM_VALIDATION_STATUS_REJECTED) {
                    sap.RecordTypeId = CON_CRM.Unvalidated_SAP_Contact_RecordId;
                }
                if(sap.Language__c == NULL) {
                    if(addMap.get(sap.Address__c).Language__c != NULL) {
                        sap.Language__c = addMap.get(sap.Address__c).Language__c;
                    }
                }
            }
            if(Trigger.isUpdate) {
                if(sap.MDM_Validation_Status__c == CON_CRM.MDM_VALIDATION_STATUS_VALIDATED && sap.SAP_External_KEY__c != null) {
                    sap.RecordTypeId = CON_CRM.Validated_SAP_Contact_RecordId;
                } else if(sap.MDM_Validation_Status__c == CON_CRM.MDM_VALIDATION_STATUS_VALIDATED && sap.SAP_External_KEY__c == NULL) {
                    throw new SapReferenceNotFoundException('Sap reference is required in order to approve a sap contact record.');
                } else if(sap.MDM_Validation_Status__c == CON_CRM.MDM_UNVALIDATION_STATUS_VALIDATED || sap.MDM_Validation_Status__c == CON_CRM.MDM_VALIDATION_STATUS_REJECTED) {
                    sap.RecordTypeId = CON_CRM.Unvalidated_SAP_Contact_RecordId;
                }
            }
        }
    }

    /**
     * This method is used to set SAP_Contact MDM status when approved and rejected by Informatica.
     * @params  newList List<SAP_Contact__c>
     * @params  oldMap Map<Id, SAP_Contact__c>
     * @return  void
     */
    public static void setSAPContactApprovalStatus(List<SAP_Contact__c> newList, Map<Id, SAP_Contact__c> oldMap) {
        Set<Id> sapIds = new Set<Id>();
        for(SAP_Contact__c sap : newList) {
            sapIds.add(sap.Id);
        }
        Set<String> fieldSet = new Set<String>();
        fieldSet.add('id');
        fieldSet.add('Address__r.MDM_Validation_Status__c');
        fieldSet.add('Address__r.Account__r.MDM_Validation_Status__c');
        fieldSet.add('Address__r.Account__c');
        
        SLT_SAP_Contact sltSapContact = new SLT_SAP_Contact();
        Map<Id, SAP_Contact__c> sapMap = sltSapContact.selectBySapContactId(sapIds, fieldSet);

        Id recordTypeId = Schema.SObjectType.SAP_Contact__c.getRecordTypeInfosByDeveloperName().get('Unvalidated').getRecordTypeId();
        for(SAP_Contact__c sap : newList) {
            try{
                if(Trigger.isInsert){
                    if(sap.MDM_Validation_Status__c == CON_CRM.MDM_UNVALIDATION_STATUS_VALIDATED && sap.RecordTypeId == recordTypeId && sap.Address__c != NULL){
                        if(sapMap.containsKey(sap.Id) && sapMap.get(sap.Id).Address__r.MDM_Validation_Status__c == CON_CRM.MDM_VALIDATION_STATUS_REJECTED) {
                            if(sapMap.containsKey(sap.Id) && sapMap.get(sap.Id).Address__r.Account__r.MDM_Validation_Status__c == CON_CRM.MDM_UNVALIDATION_STATUS_VALIDATED) {
                                submitForApprovalAccount(sapMap.get(sap.Id).Address__r.Account__c);
                            }
                            submitForApprovalAddress(sap.Address__c);
                        }
                        submitForApproval(sap);
                    }
                    else if(sap.MDM_Validation_Status__c == CON_CRM.MDM_VALIDATION_STATUS_VALIDATED ){
                        approveRecord(sap);
                    }
                    else if(sap.MDM_Validation_Status__c == CON_CRM.MDM_VALIDATION_STATUS_REJECTED && sap.RecordTypeId == recordTypeId ){
                        rejectRecord(sap);
                    }
                }
                else if(Trigger.isUpdate){
                    SAP_Contact__c sapOld=oldMap.get(sap.Id);
                    if( sap.MDM_Validation_Status__c == CON_CRM.MDM_UNVALIDATION_STATUS_VALIDATED && sapOld.MDM_Validation_Status__c != CON_CRM.MDM_UNVALIDATION_STATUS_VALIDATED && sap.RecordTypeId == recordTypeId ) {
                        if(sapMap.containsKey(sap.Id) && sapMap.get(sap.Id).Address__r.MDM_Validation_Status__c == CON_CRM.MDM_VALIDATION_STATUS_REJECTED) {
                            if(sapMap.containsKey(sap.Id) && sapMap.get(sap.Id).Address__r.Account__r.MDM_Validation_Status__c == CON_CRM.MDM_UNVALIDATION_STATUS_VALIDATED) {
                                submitForApprovalAccount(sapMap.get(sap.Id).Address__r.Account__c);
                            }
                            submitForApprovalAddress(sap.Address__c);
                        }
                        submitForApproval(sap);
                    }
                    else if(sap.MDM_Validation_Status__c == CON_CRM.MDM_VALIDATION_STATUS_VALIDATED && sapOld.MDM_Validation_Status__c != CON_CRM.MDM_VALIDATION_STATUS_VALIDATED ){
                        approveRecord(sap);
                    }
                    else if(sap.MDM_Validation_Status__c == CON_CRM.MDM_VALIDATION_STATUS_REJECTED && sapOld.MDM_Validation_Status__c != CON_CRM.MDM_VALIDATION_STATUS_REJECTED && sap.RecordTypeId == recordTypeId ){
                        rejectRecord(sap);
                    }
                }
            }
            catch(Exception e){
                sap.addError(e.getMessage());
            }
        }
    }
    
	/**
    * This method will submit the Account for approval
    * @param accountId Id
    * @return void
    **/
    public static void submitForApprovalAccount(Id accountId){        
        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();          
        req.setObjectId(accountId);
        Approval.ProcessResult result = Approval.process(req);        
    }
    
    /**
    * This method will submit the Address for approval
    * @param addressId Id
    * @return void
    **/
    public static void submitForApprovalAddress(Id addressId){        
        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();          
        req.setObjectId(addressId);
        Approval.ProcessResult result = Approval.process(req);        
    }    
    
    /**
    * This method will submit the SAP Contact for approval
    * @param sapContact SAP_Contact__c
    * @return void
    **/
    public static void submitForApproval(SAP_Contact__c sapContact){        
        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();          
        req.setObjectId(sapContact.id);
        Approval.ProcessResult result = Approval.process(req);        
    }     
    
    /**
    * Get ProcessInstanceWorkItemId using SOQL
    * @param targetObjectId Id
    **/
    public static Id getWorkItemId(Id targetObjectId){
        Id workItemId = null;
        Set<Id> setOfTargetId = new Set<Id>();
        setOfTargetId.add(targetObjectId);
        SLT_ProcessInstanceWorkitem sltProcessInstanceWorkitem = new SLT_ProcessInstanceWorkitem();
        for(ProcessInstanceWorkitem workItem : sltProcessInstanceWorkitem.getProcessInstanceWorkitemsByTargetIdAndStatus(setOfTargetId, 'Pending')){
            workItemId = workItem.Id;
        }
        return workItemId;
    }

    /**
    * This method will Approve the SAP Contact
    * @param sapContact SAP_Contact__c
    * @return void
    **/
    public static void approveRecord(SAP_Contact__c sapContact){
        Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
        req.setAction(CON_CRM.MDM_VALIDATION_STATUS_APPROVE);
        //if(sapContact.MDM_Validation_Comments__c != NULL) {
        	//req.setComments(sapContact.MDM_Validation_Comments__c);
        //}
        Id workItemId = getWorkItemId(sapContact.id); 
        if(workItemId != null){
            req.setWorkitemId(workItemId);
            Approval.ProcessResult result = Approval.process(req);
        }
    }

    /**
    * This method will Reject the SAP Contact
    * @param sapContact SAP_Contact__c
    * @return void
    **/
    public static void rejectRecord(SAP_Contact__c sapContact){
        Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
        req.setAction(CON_CRM.MDM_VALIDATION_STATUS_REJECT);  
        if(sapContact.MDM_Validation_Comments__c != NULL) {
        	req.setComments(sapContact.MDM_Validation_Comments__c);
        }
        Id workItemId = getWorkItemId(sapContact.id);
        if(workItemId != null){
            req.setWorkitemId(workItemId);
            Approval.ProcessResult result =  Approval.process(req);
        }
    }
    
    /**
    * This inner class is used to throw the custom exception.
    **/
    public class SapReferenceNotFoundException extends Exception {}
}