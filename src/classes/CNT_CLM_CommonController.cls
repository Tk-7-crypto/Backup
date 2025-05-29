/*
* This is common controller class for aura and lwc
*/ 
public class CNT_CLM_CommonController {
    
    /**
    * This method is used to fetch services for flow.
    * @param String objName
    * @param String fieldName
    * @param String recordTypeId
    * @param String pathway
    * @return List<String>
    */
    @AuraEnabled
    public static List<String> getServiceList(String objName, String fieldName, String recordTypeId, String pathway) {
        Set<String> services = UTL_CLM.getPicklistOptionsByRecordTypeId(objName, recordTypeId, fieldName).keySet().clone();
        if(pathway == CON_CLM.CLINICAL_PATHWAY || pathway == CON_CLM.OSA_PATHWAY) {
            services.removeAll(CON_CLM.EXCLUDE_SERVICE);
        }
        List<String> finalServices = new List<String>(services);
        finalServices.sort();
        return finalServices;
    }

    /**
    * This method is used to navigate to IQVIA Agreement from Conga Agreement
    * @param Id agreementId
    * @return String  
    */
    @AuraEnabled(cacheable=true)
    public static String redirectToIQVIAAgreement(Id agreementId) {
        Set<String> fields = new Set<String>{'IQVIA_Agreement__c'};
        Apttus__APTS_Agreement__c agreement = SRV_CLM_Agreement.getAgreementDetailById(agreementId, fields);
        return agreement.IQVIA_Agreement__c;
    }
    
    /**
    * This method is used to delete file
    * @param String conDocId
    */ 
    @AuraEnabled
    public static void deleteFile(String conDocId) {
        try {
            List<ContentDocument> lstConDoc = new SLT_ContentDocument().selectById(new Set<Id>{conDocId});
            fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
                new Schema.SObjectType[] {
                    ContentDocument.SObjectType
                }
            );
            if(!lstConDoc.isEmpty()) {
                uow.registerDeleted(lstConDoc);
                uow.commitWork();         
            }
        }
        catch(DMLException dmlExp) {
            throw new AuraHandledException('Failed to delete ! '+ dmlExp.getMessage());
        }    
    }  
    
    /**
    * This method is used to fetch records for custom lookup
    * @param String recordId  
    * @return List<Apttus__APTS_Agreement__c>
    */
    @AuraEnabled(cacheable=true)
    public static List<Apttus__APTS_Agreement__c> getRecords(String recordId) {
        List<Apttus__APTS_Agreement__c> result = new List<Apttus__APTS_Agreement__c>();
        Apttus__APTS_Agreement__c currentAgr = new SLT_Agreement().getAgreementDetails(recordId, new Set<String>{'Id', 'Apttus__Account__c', 
            'Parent_Account__c', 'RecordTypeId'});
        if(currentAgr != null) {
            String accId = currentAgr.Apttus__Account__c != null ? currentAgr.Apttus__Account__c : '';
            String parentAccId = currentAgr.Parent_Account__c != null ? currentAgr.Parent_Account__c : '';
            String accCondition = '((RecordTypeId = \'' + CON_CRM.GLOBAL_CUSTOMER_ACCOUNT_RECORD_TYPE_ID + '\' AND MDMID__c Like \'HN%\' AND Name Like \'Local%\') AND ' 
                + '((ParentId = null AND (Id = \'' + accId + '\' OR Id = \'' + parentAccId + '\')) OR (ParentId != null AND' 
                +  ' (ParentId = \'' + accId + '\' OR ParentId = \'' + parentAccId+ '\'))))'; 
            Set<Id> dummyAccountIds = new SLT_Account().getAccounts(new Set<String>{'Id'}, accCondition).keySet();
            String msaCondition = '(Record_Type_Developer_Name__c = \'MSA\' AND Apttus__Status_Category__c = \'' + CON_CLM.IN_EFFECT + '\' AND (((Parent_Account__c IN: agrIds) AND Apttus__Account__c = \'' + accId + '\')' 
                + ' OR (Parent_Account__c != null AND (Parent_Account__c NOT IN: agrIds) AND (Parent_Account__c = \'' + accId + '\' OR Parent_Account__c = \'' + parentAccId + '\'))' 
                + ' OR (Parent_Account__c = null AND (Apttus__Account__c = \'' + accId + '\' OR Apttus__Account__c = \'' + parentAccId + '\'))))';   
            String vendorCondition = '(Record_Type_Developer_Name__c = \'Vendor_Agreement\' AND Apttus__Subtype__c = \'' + CON_CLM.REQUESTED_AGREEMENT_TYPE_MSA +'\' AND Apttus__Status_Category__c = \'' + CON_CLM.IN_EFFECT 
                + '\' AND (((Parent_Account__c IN: agrIds) AND Apttus__Account__c = \'' + accId + '\')' 
                + ' OR (Parent_Account__c != null AND (Parent_Account__c NOT IN: agrIds) AND (Parent_Account__c = \'' + accId + '\' OR Parent_Account__c = \'' + parentAccId + '\'))' 
                + ' OR (Parent_Account__c = null AND (Apttus__Account__c = \'' + accId + '\' OR Apttus__Account__c = \'' + parentAccId + '\'))))';          
            result = new SLT_Agreement().getAgreementListByConditions(new Set<String>{'Id', 'Name', 'Lookup_Dialog_Text__c'}, null, dummyAccountIds, 
                (currentAgr.RecordTypeId == CON_CLM.VENDOR_RECORDTYPEID ? vendorCondition : msaCondition), CON_CLM.LAST_VIEWED_DATE);
        }
        return result;
    }
}