public class DAOH_AccountDirectory {
    public static void inActiveOldRecord(List<Account_Directory__c> records){
        List<Account_Directory__c> inActiveAccountDirectory = new List<Account_Directory__c>();
        Map<Id,String> idToAccountNameMap = new Map<Id,String>();
        Set<Id> accountIdSet = new Set<Id>();
        Set<String> roleSet = new Set<String>();
        Set<String> accountNameSet = new Set<String>();

        for(Account_Directory__c accountDirectory : records){
            accountIdSet.add(accountDirectory.Account__c);
            roleSet.add(accountDirectory.Role__c);
        }
        for(Account acc : [SELECT Id,Name FROM Account WHERE Id IN : accountIdSet]){
            idToAccountNameMap.put(acc.Id,acc.Name);
            accountNameSet.add(acc.Name);
        }

        Map<String, Account_Directory__c> roleAccountNameToAccountDirectoryMap = new Map<String, Account_Directory__c>();
        for(Account_Directory__c accountDirectory : SLT_AccountDirectory.selectAccountDirectory(roleSet, accountNameSet, new Set<String>())){
            roleAccountNameToAccountDirectoryMap.put(accountDirectory.Role__c+'-'+idToAccountNameMap.get(accountDirectory.Account__c), accountDirectory);
        }

        if(roleAccountNameToAccountDirectoryMap.size() > 0){
            for(Account_Directory__c accountDirectory :records){
                if(roleAccountNameToAccountDirectoryMap.containsKey(accountDirectory.Role__c+'-'+idToAccountNameMap.get(accountDirectory.Account__c)))
                    accountDirectory.addError(CON_CPQ.ACCOUNT_DIRECTORY_ERROR);
            }
        }
    }
}