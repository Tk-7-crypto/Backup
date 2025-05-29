public class BCH_CSM_RemoveDuplicateAsset implements Database.Batchable<sObject> {
    public BCH_CSM_RemoveDuplicateAsset(){
    }
    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT Id FROM Account WHERE Asset_Checked__c = false ORDER BY Createddate ASC';
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext bc, List<Account> accountList){
       	Map<Id, Map<String, Asset>> accToAssetMap = new Map<Id, Map<String, Asset>>();
        Map<Id, Id> assetRefMap = new Map<Id, Id>();
        List<Asset> assetsToDelete = new List<Asset>();
        Set<Id> assetIds = new Set<Id>();
        Set<Id> accountIds = new Set<Id>();
        
        for(Account accountObj : accountList){
            accountIds.add(accountObj.id);
        }
        List<Asset> assetList = [SELECT id, AccountId, Name FROM Asset WHERE AccountId IN: accountIds ORDER BY Createddate ASC];
        for(Asset asset : assetList){
            if(accToAssetMap.get(asset.AccountId) != null){
                Map<String, Asset> assetMap = accToAssetMap.get(asset.AccountId);
                if(assetMap.get(asset.Name) != null){
                    assetRefMap.put(asset.Id, assetMap.get(asset.Name).Id);
                    assetsToDelete.add(asset);
                    assetIds.add(asset.Id);
                }else{
                    assetMap.put(asset.Name, asset);
                }
            }else{
               	Map<String, Asset> assetMap = new Map<String, Asset>();
                assetMap.put(asset.Name, asset);
                accToAssetMap.put(asset.AccountId, assetMap);
            }
        }
        List<Case> cases = [SELECT Id, AccountId, AssetId FROM Case WHERE AssetId IN : assetIds];
        For(Case cs : cases){
            cs.assetId = assetRefMap.get(cs.assetId);
        }
        List<Account> accountsToUpdate = [SELECT Id FROM Account WHERE Id IN : accountIds];
        For(Account acc : accountsToUpdate){
            acc.Asset_Checked__c = true;
        }
		update cases;
        update accountsToUpdate;
        delete assetsToDelete;
    }
    public void finish(Database.BatchableContext bc){
        if(!Test.isRunningTest())
       Database.executeBatch(new BCH_CSM_RemoveDuplicateAsset(),1);
    }
   
    public class MyException extends Exception {}
}