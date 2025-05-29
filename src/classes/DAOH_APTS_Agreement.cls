public class DAOH_APTS_Agreement {
    
    public static void setSharing(List<Apttus__APTS_Agreement__c> newAgreementList, Map<Id, Apttus__APTS_Agreement__c> oldMap){
        UTL_Sharing.setSharing(newAgreementList, oldMap, 'Apttus__APTS_Agreement__c');
    }
    
    public static void setDummyCreatorAccess(List<Apttus__APTS_Agreement__c> newAgreementList) {
        UTL_Sharing.setDummyCreatorAccess(newAgreementList, 'Apttus__APTS_Agreement__Share', 'Agreement_Territory__c');
    }
    
    public static void setAccountCountry(List<Apttus__APTS_Agreement__c> newAgreementList, Map<Id, Apttus__APTS_Agreement__c> oldMap) {
        Set<Id> accountIdSet = new Set<id>();
        List<Apttus__APTS_Agreement__c> updatedList = new List<Apttus__APTS_Agreement__c>();
        SObject_Sharing_Settings__c sharingSetting = SObject_Sharing_Settings__c.getOrgDefaults();
        Set<String> recordTypeDeveloperNameSet = new Set<String>();
        if (sharingSetting.Bypass_Agreement_RecordType__c != null) {
            recordTypeDeveloperNameSet.addALL(sharingSetting.Bypass_Agreement_RecordType__c.split(','));
        }
        for(Apttus__APTS_Agreement__c apts :newAgreementList) {
            if(apts.IQVIA_Agreement__c == null) {
                if((Trigger.isInsert || Trigger.isUpdate) && apts.Apttus__Account__c != null) { 
                    accountIdSet.add(apts.Apttus__Account__c);
                    updatedList.add(apts);
                } else if (Trigger.isUpdate && apts.Apttus__Account__c == null) {
                    apts.Account_Country__c = null;    
                }
            }
        }
        if(accountIdSet.size() > 0) {
            Map<Id,Account> accountIdMap = new Map<Id,Account>([select Id, AccountCountry__c, RecordType.Id from Account where Id In :accountIdSet]);
            for (Apttus__APTS_Agreement__c apts : updatedList) {
                if (accountIdMap.containsKey(apts.Apttus__Account__c) && accountIdMap.get(apts.Apttus__Account__c).RecordType.Id != CON_CRM.GLOBAL_CUSTOMER_ACCOUNT_RECORD_TYPE_ID 
                    && !recordTypeDeveloperNameSet.contains(apts.Record_Type_Developer_Name__c) && (apts.Record_Type_Developer_Name__c != CON_CLM.AMESA_RECORD_TYPE_NAME
                    && apts.Record_Type_Developer_Name__c != CON_CLM.AMA_RECORD_TYPE_NAME)) {
                    apts.Account_Country__c = accountIdMap.get(apts.Apttus__Account__c).AccountCountry__c;    
                } else {
                    apts.Account_Country__c = null;
                }
            }   
        }
    }
    
    public static void setLastSharingCalculationTimestamp(List<Apttus__APTS_Agreement__c> newAgreementList, Map<Id, Apttus__APTS_Agreement__c> oldMap) {
        Boolean isFieldToUpdate = true;
        Set<Id> recordIdSet = new Set<Id>();
        if(Trigger.isUpdate) {
            recordIdSet = UTL_Sharing.checkFieldSetValueChange(newAgreementList, oldMap, 'Apttus__APTS_Agreement__c', 'SHR_Parent_FieldSet');
            if(recordIdSet.size() == 0) {
                isFieldToUpdate = false;
            }
        }
        if(isFieldToUpdate) {
            for(Apttus__APTS_Agreement__c apts :newAgreementList) {
                if (Trigger.isInsert || recordIdSet.contains(apts.Id)) {
                    apts.Last_Sharing_Calculation_Timestamp__c = System.Now();    
                }
            }   
        }
    }
    
    public static void setLastManualSharingFieldUpdate(List<Apttus__APTS_Agreement__c> newAgreementList, Map<Id, Apttus__APTS_Agreement__c> oldMap) {
        for (Apttus__APTS_Agreement__c apts : newAgreementList) {
            if(apts.Run_Sharing__c) {
                apts.Run_Sharing__c = false;
                apts.Last_Manual_Sharing_Execution__c = System.now();
            }
        }
    }
    
}