public class CNT_CRM_RelationshipList {
	@AuraEnabled
    public static List<AccountContactRelation> getActiveRelations(Id accountId, string contactType) {
        Set<String> fieldSet = new Set<String>{
            'Id','Contact.Name', 'Function__c', 'Focus__c', 'User_Country__c', 'Geographic_Responsibility__c', 'Responsibility__c'
        };
        List<AccountContactRelation> activeRelations = new SLT_AccountContactRelation().getAccountContactRelations(fieldSet, accountId, contactType, True);
        return activeRelations;
    }
    
    @AuraEnabled
    public static List<AccountContactRelation> getInactiveRelations(Id accountId, string contactType) {
        Set<String> fieldSet = new Set<String>{
            'Id','Contact.Name', 'Function__c', 'Focus__c', 'User_Country__c', 'Geographic_Responsibility__c', 'Responsibility__c', 'EndDate'
        };
        List<AccountContactRelation> inactiveRelations = new SLT_AccountContactRelation().getAccountContactRelations(fieldSet, accountId, contactType, False);
        return inactiveRelations;
    }
    
    @AuraEnabled
    public static boolean getRecordType(Id accountId) {
        boolean flag = false;        
        Set<Id> accIdSet = new Set<Id>();
        accIdSet.add(accountId);        
        Set<String> fieldSet = new Set<String>{
            'Id','Name', 'RecordType.Name'
        };
        Map<Id, Account> accRecord = new SLT_Account().selectByAccountId(accIdSet,fieldSet);        
        for (Account acc : accRecord.values()) {
            if(acc.RecordType.Name == 'Global Customer Account'){
                flag = true;
            }
        }
        return flag;
    }
    
    @AuraEnabled
    public static String getGlobal_Account_Team_Roll_Up_Report() {
        CRM_Report_Links__c bnfSetting = CRM_Report_Links__c.getInstance();
        return bnfSetting.Global_Account_Team_Roll_Up_Report__c;
    }
    
    @AuraEnabled
    public static String getAccountNameById(Id accountId) {
        String accName = '';
        Set<Id> accIdSet = new Set<Id>();
        accIdSet.add(accountId);        
        Set<String> fieldSet = new Set<String>{
            'Id','Name'
        };
        Map<Id, Account> accRecord = new SLT_Account().selectByAccountId(accIdSet,fieldSet);        
        for (Account acc : accRecord.values()) {
             accName= acc.Name;
        }
        return accName;
    }
}