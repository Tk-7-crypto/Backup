/**
 * This is Account Domain class.
 * version : 1.0
 */
public class DAO_Account extends fflib_SObjectDomain {

    
    /**
     * Constructor of this class
     * @params sObjectList List<SObject>
     */
    public DAO_Account(List<SObject> sObjectList) {
        super(sObjectList);
    }

    /**
     * Constructor Class for construct new Instance of This Class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new DAO_Account(sObjectList);
        }
    }
    
    /**
     * Override method After Delete Call
     */
    public override void onAfterDelete() {
        createOutboundMessageDeletionQueue((List<Account>)Records);
    } 
    
    /**
     * This method is used for before insert of the Account trigger.
     * @return void
     */
    public override void onBeforeInsert() {
        setMulesoftIntegrationFields((List<Account>)Records, null, null); 
        changeAccountRecordTypeOnApproval((List<Account>)Records, null); 
        
        //ZK
        setAccountCountrySiteLabel((List<Account>)Records, null, null);
        DAOH_Account.setAccountFields((List<Account>)Records, null);

        DAOH_Account.checkIfCSHSelfRegistration((List<Account>)Records);
        DAOH_Account.validateRiskRating((List<Account>)Records,null);
        //User Story - ESPSFDCQI-4268
        DAOH_Account.setRiskRatingForGlobalCustomerAccount((List<Account>)Records,null);
        DAOH_Account.setLastSharingCalculationTimestamp((List<Account>)Records,null);
    }
    
    /**
     * This method is used for before update of the Account trigger.
     * @params  existingRecords Map<Id,SObject>
     * @return  void
     */
    public override void onBeforeUpdate(Map<Id,SObject> existingRecords) {
        setMulesoftIntegrationFields((List<Account>)Records, new Map<Id,Account>((List<Account>)Records), (Map<Id, Account>)existingRecords);
        changeAccountRecordTypeOnApproval((List<Account>)Records, (Map<Id, Account>)existingRecords);    
        
        //ZK
        setAccountCountrySiteLabel((List<Account>)Records, new Map<Id,Account>((List<Account>)Records), (Map<Id, Account>)existingRecords);   
        DAOH_Account.setAccountFields((List<Account>)Records, (Map<Id, Account>)existingRecords);

        DAOH_Account.checkIfCSHSelfRegistration((List<Account>)Records);
        DAOH_Account.validateDescartesApproval(new Map<Id,Account>((List<Account>)Records),(Map<Id, Account>)existingRecords);
        DAOH_Account.validateRiskRating((List<Account>)Records,(Map<Id, Account>)existingRecords);
        //User Story - ESPSFDCQI-4268
        DAOH_Account.setRiskRatingForGlobalCustomerAccount((List<Account>)Records,(Map<Id, Account>)existingRecords);
        DAOH_Account.setLastSharingCalculationTimestamp((List<Account>)Records,(Map<Id, Account>)existingRecords);
        /** User Story - CSM-3224 */
        DAOH_Account.updateCSHAccountAssets((List<Account>)Records,(Map<Id, Account>)existingRecords);
    }
    
    /**
     * Override method Before Delete Call
     */
    public override void onBeforeDelete() {
        DAOH_Account.preventDeletionOfAccounts((List<Account>)Records);
    }
    
    /**
     * This method is used for after update of the Account trigger.
     * @return void
     */    
    public override void onAfterUpdate(Map<Id,SObject> existingRecords) { 
        //IQVIACBEX-1804:Added a call to process the sync logic between Salesforce and Unity.
        DAOH_Account.setUnityFlagSyncMechanism(new Map<Id, Account>((List<Account>)Records), (Map<Id, Account>)existingRecords);
        setAccountApprovalStatus(new Map<Id,Account>((List<Account>)Records), (Map<Id, Account>)existingRecords); 
        List<FieldDefinition> fields = new EXT_CSM_FieldDefination().getFieldDetails(CON_CSM.s_account);
        if(fields != null) {
            DAOH_Account.saveAuditLogAfterUpdateAccountFields((List<Account>)Records, (Map<Id, Account>)existingRecords, fields); 
        }
        DAOH_Account.mergeAccounts(new Map<Id,Account>((List<Account>)Records), (Map<Id, Account>)existingRecords);
        //ESPSFDCQI-4267
        DAOH_Account.sendEmailToOppOwner((List<Account>)Records, (Map<Id, Account>)existingRecords);
        //ESPSFDCQI-7474
        DAOH_Account.creditAssessmentCheck((List<Account>)Records, (Map<Id, Account>)existingRecords);
        DAOH_Account.updateAccountTerritory((List<Account>)Records, (Map<Id, Account>)existingRecords);
        DAOH_Account.updateOpportunitySharing((List<Account>)Records, (Map<Id, Account>)existingRecords);
    }
    
    
    /**
     * This method is used to update Outbound Message Deletion Queue
     * @params  List<Account> deleteList
     * @return  void
     */
    public static void createOutboundMessageDeletionQueue(List<Account> deleteList) {
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
            new Schema.SObjectType[] {
                Outbound_Message_Deletion_queue__c.SobjectType
                    }
        );
        Outbound_Message_Deletion_queue__c outBound;
        Boolean toCommit = false;
        for(Account acc : deleteList) {
            outBound = new Outbound_Message_Deletion_queue__c();
            outBound.Operation__c = CON_CRM.DELETE_LABEL;
            if(acc.LI_Account_Id__c!= null) {
                outBound.LI_Id__c = acc.LI_Account_Id__c;
            }
            if(acc.LQ_Account_Id__c != null) {
                outBound.LQ_Id__c = acc.LQ_Account_Id__c;
            }
            outBound.SObjectType__c = CON_CRM.ACCOUNT_OBJECT;
            outBound.RecordID__c = acc.Id;
            outBound.MasterRecordId__c = acc.MasterRecordId;
            uow.registerNew(outBound);
            toCommit = true;
        }
        
        if(toCommit) {
            uow.commitWork();
        }
    }
    
    /**
     * This method is used to set Mulesoft Integration Fields on Account.
     * @param newList List<Account>
     * @params  newMap Map<Id, Account>
     * @params  oldMap Map<Id, Account>
     * @return  void
     */
    public static void setMulesoftIntegrationFields(List<Account> newList, Map<Id, Account> newMap, Map<Id, Account> oldMap) {
        Boolean setFlag = false;
        String fieldAPI ='';
        for(Account acc : newList) {
            setFlag = false;
            if(Trigger.isUpdate) {
                acc.Send_Mulesoft_Outbound_Msg__c = false;
                for( Schema.FieldSetMember sf : Schema.SObjectType.Account.fieldSets.Mulesoft_Synced_Fields.getFields()) {
                    fieldAPI = sf.getFieldPath();
                    if(oldMap.get(acc.Id).get(fieldAPI) != newMap.get(acc.Id).get(fieldAPI)) {
                        setFlag = true ;
                        break;
                    }
                }
            }
            if(Trigger.isInsert || setFlag) {
                acc.Send_Mulesoft_Outbound_Msg__c = true;
                acc.LI_Mulesoft_Update_GUID__c = UTL_Guid.newGuid();
                acc.LQ_Mulesoft_Update_GUID__c = UTL_Guid.newGuid();
                acc.LI_Mulesoft_Sync_Status__c = 'PENDING';
                acc.LQ_Mulesoft_Sync_Status__c = 'PENDING';
                acc.LI_Mulesoft_Sync_Timestamp__c = null;
                acc.LQ_Mulesoft_Sync_Timestamp__c = null;
                acc.LI_Mulesoft_Error_Message__c = null;
                acc.LQ_Mulesoft_Error_Message__c = null;
            }
        }
    }
    
    /**
     * This method is used to concatenate Account Name & Account Country in Account_Label__c Field on Account. This field is used for Global Search.
     * @param newList List<Account>
     * @params  newMap Map<Id, Account>
     * @params  oldMap Map<Id, Account>
     * @return  void
     */
    public static void setAccountCountrySiteLabel(List<Account> newList, Map<Id, Account> newMap, Map<Id, Account> oldMap) {
        Boolean hasChangedLabel = false;
        Boolean hasChangedSite = false;
        Map<String, String> valuesLabelsMap = new Map<String, String>();
        
        //Get Label values of Picklist, AccountCountry__c
        for(Schema.PicklistEntry f : Account.AccountCountry__c.getDescribe().getPicklistValues()){
            valuesLabelsMap.put(f.getValue(), f.getLabel());
        }
        
        for(Account acc : newList) {
            if(Trigger.isUpdate) {
                hasChangedLabel = false;
                hasChangedSite = false;
                
                if(oldMap.get(acc.Id).Name != newMap.get(acc.Id).Name || oldMap.get(acc.Id).AccountCountry__c != newMap.get(acc.Id).AccountCountry__c) {
                    hasChangedLabel = true;
                } 
                if(oldMap.get(acc.Id).MDMID__c != newMap.get(acc.Id).MDMID__c || oldMap.get(acc.Id).AccountCountry__c != newMap.get(acc.Id).AccountCountry__c) {
                    hasChangedSite = true;
                }
            }
            
            if(Trigger.isInsert || hasChangedLabel){
                acc.Account_Label__c = acc.Name + ' ' + ((acc.AccountCountry__c != null) ? valuesLabelsMap.get(acc.AccountCountry__c) :'');
            }
            
            if(Trigger.isInsert || hasChangedSite){
                if(acc.AccountCountry__c != null && acc.MDMID__c != null){
                    acc.Site = valuesLabelsMap.get(acc.AccountCountry__c) + ' - ' + acc.MDMID__c;    
                }else if(acc.AccountCountry__c == null && acc.MDMID__c != null){
                    acc.Site = acc.MDMID__c; 
                }else if(acc.AccountCountry__c != null && acc.MDMID__c == null){
                    acc.Site = valuesLabelsMap.get(acc.AccountCountry__c); 
                }
                
            }
            
        }
    }
    
    /**
     * This method is used for after insert of the case trigger.
     * @return void
     */
    public override void onAfterInsert() {
        DAOH_Account.validateDescartesApproval(new Map<Id,Account>((List<Account>)Records), NULL);
        DAOH_Account.saveAuditLogAfterInsertAccount((List<Account>)Records); 
    }
     
    /**
     * This method is used to change aaccount record type while MDM status is approved.
     * @params  newList List<Account>
     * @params  oldMap Map<Id, Account>
     * @return  void
     */
    public static void changeAccountRecordTypeOnApproval(List<Account> newList, Map<Id, Account> oldMap) {
        Mulesoft_Integration_Control__c mulesoftSetting = Mulesoft_Integration_Control__c.getInstance();
        for (Account acc : newList) {  
            if ((Trigger.isInsert || oldMap.get(acc.Id).MDM_Validation_Status__c != acc.MDM_Validation_Status__c) && acc.MDM_Validation_Status__c == CON_CRM.MDM_VALIDATION_STATUS_VALIDATED && acc.RecordTypeId != CON_CRM.GLOBAL_CUSTOMER_ACCOUNT_RECORD_TYPE_ID) {
                RecordType recordType = new SLT_ProcessInstanceWorkitem().getRecordTypeIdByName(CON_CRM.VALIDATED_ACCOUNT_RECORD_TYPE_NAME);
                acc.RecordTypeId = recordType.id;
            }
            else if ((Trigger.isInsert || oldMap.get(acc.Id).MDM_Validation_Status__c != acc.MDM_Validation_Status__c) && acc.MDM_Validation_Status__c == CON_CRM.MDM_UNVALIDATION_STATUS_VALIDATED && acc.RecordTypeId != CON_CRM.GLOBAL_CUSTOMER_ACCOUNT_RECORD_TYPE_ID) {
                RecordType recordType = new SLT_ProcessInstanceWorkitem().getRecordTypeIdByName(CON_CRM.UNVALIDATED_ACCOUNT_RECORD_TYPE_NAME);
                acc.RecordTypeId = recordType.id;
            }
            if(Trigger.isUpdate && mulesoftSetting.Is_Mulesoft_User__c){
                acc.Name = oldMap.get(acc.Id).Name;
            }
        }
    }       
   
    /**
     * This method is used to set aaccount MDM status when approved and rejected by Informatica.
     * @params  newMap Map<Id, Account>
     * @params  oldMap Map<Id, Account>
     * @return  void
     */
    public static void setAccountApprovalStatus(Map<Id, Account> newMap, Map<Id, Account> oldMap) {
        
        Map<Id, Id> processInstanceWorkitem_Map = new Map<Id, Id>();
        for (ProcessInstanceWorkitem  p : new SLT_ProcessInstanceWorkitem().getAllPendingWorkItems(newMap.keySet())) {
            processInstanceWorkitem_Map.put(p.ProcessInstance.TargetObjectId,p.Id);
        }   

        for (Account acc : newMap.values()) {  
            if (oldMap.get(acc.Id).MDM_Validation_Status__c != acc.MDM_Validation_Status__c && acc.MDM_Validation_Status__c == CON_CRM.MDM_VALIDATION_STATUS_VALIDATED) {
                if (processInstanceWorkitem_Map.containsKey(acc.Id)) {
                    Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
                    req2.setComments(CON_CRM.MDM_VALIDATION_COMMENT_APPROVE);
                    req2.setAction(CON_CRM.MDM_VALIDATION_STATUS_APPROVE);   
                    req2.setWorkitemId(processInstanceWorkitem_Map.get(acc.Id));
                    Approval.ProcessResult result2 = Approval.process(req2);
                }
            }
            
            if (oldMap.get(acc.Id).MDM_Validation_Status__c != acc.MDM_Validation_Status__c && acc.MDM_Validation_Status__c == CON_CRM.MDM_VALIDATION_STATUS_REJECTED) {
                if (processInstanceWorkitem_Map.containsKey(acc.Id)) {
                    Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
                    req2.setComments(CON_CRM.MDM_VALIDATION_COMMENT_REJECT);
                    req2.setAction(CON_CRM.MDM_VALIDATION_STATUS_REJECT);    
                    req2.setWorkitemId(processInstanceWorkitem_Map.get(acc.Id));
                    req2.setComments(acc.MDM_Validation_Comments__c);
                    Approval.ProcessResult result2 = Approval.process(req2);
                }
            }
        }
    }
}