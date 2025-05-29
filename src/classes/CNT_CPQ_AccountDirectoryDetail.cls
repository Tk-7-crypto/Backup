public without sharing class CNT_CPQ_AccountDirectoryDetail {
    
    @AuraEnabled
    public static List<AccountDirectoryWrapper> getAccountDirectoryData(String role,String account,String customerName){
        Map<Id,Map<String, AccountDirectoryCustomerWrapper>> customerToAccountDirectoryListMap = new Map<Id,Map<String, AccountDirectoryCustomerWrapper>>();
        Set<String> roleSet = CON_CPQ.ROLE_PICKLIST_SET;
        Map<String, String> accountIdToNameMap = new Map<String, String>();
        List<AccountDirectoryWrapper> accountDirectoryWrapperList = new List<AccountDirectoryWrapper>();
        List<Account_Directory__c> accountDirectoryList = SLT_AccountDirectory.selectAccountDirectoryByCondition(role, account, customerName);
        
        for(Account_Directory__c accountDirector : accountDirectoryList) {
            accountIdToNameMap.put(accountDirector.Account__c, accountDirector.Account__r.Name);
            if(customerToAccountDirectoryListMap.containsKey(accountDirector.Account__c)){
                Map<String, AccountDirectoryCustomerWrapper> roleToAccDirMAP = customerToAccountDirectoryListMap.get(accountDirector.Account__c);
                roleToAccDirMAP.get(accountDirector.Role__c).accountDirectory = accountDirector;     
            } else {  
                Map<String, AccountDirectoryCustomerWrapper> roleToAccDirMAP = new Map<String, AccountDirectoryCustomerWrapper>();
                for(String roleName : roleSet){
                    roleToAccDirMAP.put(roleName,new AccountDirectoryCustomerWrapper(new Account_Directory__c(Account__c = accountDirector.Account__c, Approver_Name__c = CON_CPQ.N_A, Role__c = roleName)));
                }  
                roleToAccDirMAP.get(accountDirector.Role__c).accountDirectory = accountDirector;
                customerToAccountDirectoryListMap.put(accountDirector.Account__c, roleToAccDirMAP);  
            }
        }
        
        for(Id accountId: customerToAccountDirectoryListMap.keyset()){
            Map<String, AccountDirectoryCustomerWrapper> roleToAccDirMAP = customerToAccountDirectoryListMap.get(accountId);
            List<AccountDirectoryCustomerWrapper> accDirectoryCustomerWrapperList= roleToAccDirMAP.Values();
            accountDirectoryWrapperList.add(new AccountDirectoryWrapper(accountIdToNameMap.get(accountId),accDirectoryCustomerWrapperList,false,false));
        }         
        return accountDirectoryWrapperList;
    }
    
    @AuraEnabled
    public static List<String> getSelectOptions(sObject objObject, String fieldName) {
        
        List <String> allOptions = new List <String> ();
        Schema.sObjectType objType = objObject.getSObjectType();
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
        Map < String, Schema.SObjectField > fieldMap = objDescribe.fields.getMap();
        List < Schema.PicklistEntry > values = fieldMap.get(fieldName).getDescribe().getPickListValues();            
        for (Schema.PicklistEntry a: values) {
            allOptions.add(a.getValue());
        }        
        allOptions.sort();
        return allOptions;
    }
    
    @AuraEnabled
    public static List<String> getValueSet(sObject objObject, String fieldName) {
        Set <String> allOptions = new Set <String> ();
        List<Account_Directory__c> accountDirectoryList = SLT_AccountDirectory.selectAccountDirectoryByCondition(CON_CPQ.NONE, CON_CPQ.NONE, CON_CPQ.NONE);
        for(Account_Directory__c accountDirectory : accountDirectoryList){
            if(fieldName == CON_CPQ.ACCOUNT_FIELD){
                allOptions.add(accountDirectory.Account__r.name);
            } else if(fieldName == CON_CPQ.CUSTOMER_NAME_FIELD){     
                allOptions.add(accountDirectory.Approver_Name__c);
            }
        }
        return new List<String>(allOptions);
    }
    
    @AuraEnabled
    public static void updateAccountDirectory(String accountDirectoryData) {
        List<AccountDirectoryWrapper> accountDirectoryWrapperList = (List<AccountDirectoryWrapper>)JSON.deserialize(accountDirectoryData, List<AccountDirectoryWrapper>.class);
        List<Account_Directory__c> accountDirectoryUpdateList = new List<Account_Directory__c>();
        List<Account_Directory__c> accountDirectoryDeleteList = new List<Account_Directory__c>();
        for(AccountDirectoryWrapper accountDirectorywrapperObject : accountDirectoryWrapperList) {   
            if(accountDirectorywrapperObject.isEdit == true) {
                for(AccountDirectoryCustomerWrapper accountDirectoryCustomerWrapObj : accountDirectorywrapperObject.accDirectoryCustomerWrapperList){
                    if(accountDirectoryCustomerWrapObj.accountDirectory.Approver_Name__c != null && accountDirectoryCustomerWrapObj.accountDirectory.Approver_Name__c != CON_CPQ.N_A && accountDirectoryCustomerWrapObj.accountDirectory.Approver_Name__c != ''){
                        accountDirectoryUpdateList.add(accountDirectoryCustomerWrapObj.accountDirectory);
                    } else if(accountDirectoryCustomerWrapObj.accountDirectory != null && accountDirectoryCustomerWrapObj.accountDirectory.Id != null){
                        accountDirectoryDeleteList.add(accountDirectoryCustomerWrapObj.accountDirectory);
                    }
                }
            }
        }
        if(accountDirectoryUpdateList.size() > 0){
            upsert accountDirectoryUpdateList;     
        }
        if(accountDirectoryDeleteList.size() > 0){
            delete accountDirectoryDeleteList;  
        }
         
    }
    
    @AuraEnabled
    public static void deleteAccountDirectory(String accountDirectoryData) {
        List<AccountDirectoryWrapper> accountDirectoryWrapperList =
            (List<AccountDirectoryWrapper>)JSON.deserialize(accountDirectoryData, List<AccountDirectoryWrapper>.class);
        List<Account_Directory__c> accountDirectoryDeleteList = new List<Account_Directory__c>();
        for(AccountDirectoryWrapper accountDirectorywrapperObject : accountDirectoryWrapperList) {  
            if(accountDirectorywrapperObject.isDelete == true) {
                for(AccountDirectoryCustomerWrapper accountDirectoryCustomerWrapObj : accountDirectorywrapperObject.accDirectoryCustomerWrapperList){
                    if(accountDirectoryCustomerWrapObj.accountDirectory != null && accountDirectoryCustomerWrapObj.accountDirectory.Id != null){
                        accountDirectoryDeleteList.add(accountDirectoryCustomerWrapObj.accountDirectory);
                    }
                }
            }
        }
        if(accountDirectoryDeleteList.size() > 0){
            delete accountDirectoryDeleteList;
        }
    }
    
    public class AccountDirectoryWrapper{
        @AuraEnabled public String account{get;set;}
        @AuraEnabled public List<AccountDirectoryCustomerWrapper> accDirectoryCustomerWrapperList{get;set;} 
        @AuraEnabled public Boolean isEdit{get;set;}
        @AuraEnabled public Boolean isDelete{get;set;}
        public AccountDirectoryWrapper(String account, List<AccountDirectoryCustomerWrapper> accDirectoryCustomerWrapperList, Boolean isEdit, Boolean isDelete){
            this.account = account;
            this.accDirectoryCustomerWrapperList = accDirectoryCustomerWrapperList;
            this.isEdit = isEdit;
            this.isDelete = isDelete;
        }
    }
    
    public class AccountDirectoryCustomerWrapper{     
        @AuraEnabled public Account_Directory__c accountDirectory{get;set;}  
        public AccountDirectoryCustomerWrapper(Account_Directory__c accountDirectory){
            this.accountDirectory = accountDirectory;  
        }
    }
}