/**
 * This is Address trigger handler class.
 * version : 1.0
 */
public class TGRH_Address {
    
    /**
     * This method is used to set Address fields.
     * @params  newList List<Address__c>
     * @params  oldMap Map<Id, Address__c>
     * @return  void
     */
    public static void setAddressFields(List<Address__c> newList, Map<Id, Address__c> oldMap) {
        for (Address__c add :newList) {
            if(Trigger.isInsert) {
                if(add.RecordTypeId != CON_CRM.TPA_Unvalidated_Address_RecordId) {
                    if(add.MDM_Validation_Status__c == CON_CRM.MDM_VALIDATION_STATUS_VALIDATED) {
                        add.RecordTypeId = CON_CRM.Validated_Address_RecordId;
                    } else if(add.MDM_Validation_Status__c == CON_CRM.MDM_UNVALIDATION_STATUS_VALIDATED || add.MDM_Validation_Status__c == CON_CRM.MDM_VALIDATION_STATUS_REJECTED) {
                        add.RecordTypeId = CON_CRM.Unvalidated_Address_RecordId;
                    }
                }
            }
            if(Trigger.isUpdate) {
                if(add.RecordTypeId != CON_CRM.TPA_Unvalidated_Address_RecordId) {
                    if(add.MDM_Validation_Status__c == CON_CRM.MDM_VALIDATION_STATUS_VALIDATED && add.SAP_Reference__c != NULL) {
                        add.RecordTypeId = CON_CRM.Validated_Address_RecordId;
                    } else if(add.MDM_Validation_Status__c == CON_CRM.MDM_VALIDATION_STATUS_VALIDATED && add.SAP_Reference__c == NULL) {
                        throw new SapReferenceNotFoundException('Sap reference is required in order to approve an address record.');
                    } else if(add.MDM_Validation_Status__c == CON_CRM.MDM_UNVALIDATION_STATUS_VALIDATED || add.MDM_Validation_Status__c == CON_CRM.MDM_VALIDATION_STATUS_REJECTED) {
                        add.RecordTypeId = CON_CRM.Unvalidated_Address_RecordId;
                    }
                }
            }
        }
    }

    /**
     * This method is used to set Address MDM status when approved and rejected by Informatica.
     * @params  newList List<Address__c>
     * @params  oldMap Map<Id, Address__c>
     * @return  void
     */
    public static void setAddressApprovalStatus(List<Address__c> newList, Map<Id, Address__c> oldMap) {
        Set<Id> addressIds = new Set<Id>();
        for(Address__c addressObj : newList) {
            addressIds.add(addressObj.Id);
        }
        Set<String> fieldSet = new Set<String>();
        fieldSet.add('id');
        fieldSet.add('Account__r.MDM_Validation_Status__c');
        
        SLT_Address sltAddres = new SLT_Address();
        Map<Id, Address__c> addMap = sltAddres.selectByAddressId(addressIds, fieldSet);
        
        Id recordTypeId = Schema.SObjectType.Address__c.getRecordTypeInfosByDeveloperName().get('Unvalidated').getRecordTypeId();
        for(Address__c add : newList) {
            try{
                if(Trigger.isInsert){
                    if(add.MDM_Validation_Status__c == CON_CRM.MDM_UNVALIDATION_STATUS_VALIDATED && add.RecordTypeId == recordTypeId ){
                        if(addMap.containsKey(add.Id) && addMap.get(add.Id).Account__r.MDM_Validation_Status__c == CON_CRM.MDM_UNVALIDATION_STATUS_VALIDATED) {
                            submitForApprovalAccount(add.Account__c);
                        }
                        submitForApproval(add);
                    }
                    else if(add.MDM_Validation_Status__c == CON_CRM.MDM_VALIDATION_STATUS_VALIDATED ){
                        approveRecord(add);
                    }
                    else if(add.MDM_Validation_Status__c == CON_CRM.MDM_VALIDATION_STATUS_REJECTED && add.RecordTypeId == recordTypeId ){
                        rejectRecord(add);
                    }
                }
                else if(Trigger.isUpdate){
                    Address__c addOld=oldMap.get(add.Id);
                    if( add.MDM_Validation_Status__c == CON_CRM.MDM_UNVALIDATION_STATUS_VALIDATED && addOld.MDM_Validation_Status__c != CON_CRM.MDM_UNVALIDATION_STATUS_VALIDATED && add.RecordTypeId == recordTypeId ) {
                        if(addMap.containsKey(add.Id) && addMap.get(add.Id).Account__r.MDM_Validation_Status__c == CON_CRM.MDM_UNVALIDATION_STATUS_VALIDATED) {
                            submitForApprovalAccount(add.Account__c);
                        }
                        submitForApproval(add);
                    }
                    else if(add.MDM_Validation_Status__c == CON_CRM.MDM_VALIDATION_STATUS_VALIDATED && addOld.MDM_Validation_Status__c != CON_CRM.MDM_VALIDATION_STATUS_VALIDATED ){
                        approveRecord(add);
                    }
                    else if(add.MDM_Validation_Status__c == CON_CRM.MDM_VALIDATION_STATUS_REJECTED && addOld.MDM_Validation_Status__c != CON_CRM.MDM_VALIDATION_STATUS_REJECTED && add.RecordTypeId == recordTypeId ){
                        rejectRecord(add);
                    }
                }
            }
            catch(Exception e){
                add.addError(e.getMessage());
            }
        }
    }
    
    /**
    * This method will submit the Account for approval
    * @param Id accountId
    * @return void
    **/
    public static void submitForApprovalAccount(Id accountId){        
        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();          
        req.setObjectId(accountId);
        Approval.ProcessResult result = Approval.process(req);        
    }
    
    /**
    * This method will submit the Address for approval
    * @param Address__c addressObj
    * @return void
    **/
    public static void submitForApproval(Address__c addressObj){        
        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();          
        req.setObjectId(addressObj.id);
        Approval.ProcessResult result = Approval.process(req);        
    }     
    
    /**
    * Get ProcessInstanceWorkItemId using SOQL
    * @param targetObjectId Id
    * @return Id
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
    * This method will Approve the Address
    * @param Address__c addressObj
    * @return void
    **/
    public static void approveRecord(Address__c addressObj){
        Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
        req.setAction(CON_CRM.MDM_VALIDATION_STATUS_APPROVE);
        //if(addressObj.MDM_Validation_Comments__c != NULL) {
        	//req.setComments(addressObj.MDM_Validation_Comments__c);
        //}
        Id workItemId = getWorkItemId(addressObj.id); 
        if(workItemId != null) {
            req.setWorkitemId(workItemId);
            Approval.ProcessResult result =  Approval.process(req);
        }
    }

    /**
    * This method will Reject the Address
    * @param Address__c addressObj
    * @return void
    **/
    public static void rejectRecord(Address__c addressObj){
        Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
        req.setAction(CON_CRM.MDM_VALIDATION_STATUS_REJECT);  
        if(addressObj.MDM_Validation_Comments__c != NULL) {
        	req.setComments(addressObj.MDM_Validation_Comments__c);
        }
        Id workItemId = getWorkItemId(addressObj.id);
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