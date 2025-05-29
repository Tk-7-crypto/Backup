public class DAOH_IQVIA_Agreement {
    
    public static void setSharing(List<IQVIA_Agreement__c> newAgreementList, Map<Id, IQVIA_Agreement__c> oldMap){
        UTL_Sharing.setSharing(newAgreementList, oldMap, 'IQVIA_Agreement__c');
    }
    
    public static void setDummyCreatorAccess(List<IQVIA_Agreement__c> newAgreementList) {
        UTL_Sharing.setDummyCreatorAccess(newAgreementList, 'IQVIA_Agreement__Share', 'Agreement_Territory__c');
    }
    
    public static void setAccountCountry(List<IQVIA_Agreement__c> newAgreementList, Map<Id, IQVIA_Agreement__c> oldMap) {
        Set<Id> accountIdSet = new Set<id>();
        List<IQVIA_Agreement__c> updatedList = new List<IQVIA_Agreement__c>();
        SObject_Sharing_Settings__c sharingSetting = SObject_Sharing_Settings__c.getOrgDefaults();
        Set<String> recordTypeDeveloperNameSet = new Set<String>();
        Map<Id,Schema.RecordTypeInfo>  rtMapById = Schema.SObjectType.IQVIA_Agreement__c.getRecordTypeInfosById();
        if (sharingSetting.Bypass_Agreement_RecordType__c != null) {
            recordTypeDeveloperNameSet.addALL(sharingSetting.Bypass_Agreement_RecordType__c.split(','));
        }
        for(IQVIA_Agreement__c agr : newAgreementList) {
            if(oldMap == null || (oldMap != null && agr.Account__c != oldMap.get(agr.Id).Account__c)) {
                if(agr.Account__c != null) {
                    accountIdSet.add(agr.Account__c);
                    updatedList.add(agr);
                } else if(agr.Account__c == null) { 
                    agr.Account_Country__c = null; 
                }
            }
        }
        if(!accountIdSet.isEmpty()) {
            Set<String> fieldSet = new Set<String> {'Id', 'AccountCountry__c', 'RecordTypeId'};
            Map<Id,Account> accountIdMap = new Map<Id,Account>(new SLT_Account().selectByAccountId(accountIdSet, fieldSet));
            for (IQVIA_Agreement__c agr : updatedList) {
                if (accountIdMap.containsKey(agr.Account__c) && accountIdMap.get(agr.Account__c).RecordTypeId != CON_CRM.GLOBAL_CUSTOMER_ACCOUNT_RECORD_TYPE_ID 
                    && !recordTypeDeveloperNameSet.contains(rtMapById.get(agr.RecordTypeId).getDeveloperName())) {
                    agr.Account_Country__c = accountIdMap.get(agr.Account__c).AccountCountry__c;    
                } 
            }   
        }
    }
    
    public static void setLastSharingCalculationTimestamp(List<IQVIA_Agreement__c> newAgreementList, Map<Id, IQVIA_Agreement__c> oldMap) {
        Boolean isFieldToUpdate = true;
        Set<Id> recordIdSet = new Set<Id>();
        if(Trigger.isUpdate) {
            recordIdSet = UTL_Sharing.checkFieldSetValueChange(newAgreementList, oldMap, 'IQVIA_Agreement__c', 'SHR_Parent_FieldSet');
            if(recordIdSet.size() == 0) {
                isFieldToUpdate = false;
            }
        }
        if(isFieldToUpdate) {
            for(IQVIA_Agreement__c agr :newAgreementList) {
                if (Trigger.isInsert || recordIdSet.contains(agr.Id)) {
                    agr.Last_Sharing_Calculation_Timestamp__c = System.Now();    
                }
            }   
        }
    }
    
    public static void setLastManualSharingFieldUpdate(List<IQVIA_Agreement__c> newAgreementList, Map<Id, IQVIA_Agreement__c> oldMap) {
        for (IQVIA_Agreement__c agr : newAgreementList) {
            if(agr.Run_Sharing__c) {
                agr.Run_Sharing__c = false;
                agr.Last_Manual_Sharing_Execution__c = System.now();
            }
        }
    }
    
}