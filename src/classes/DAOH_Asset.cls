public class DAOH_Asset { 
    
    public static void checkForDuplicacy(List<Asset> newAssetList){
        Boolean hasCustomPermission = FeatureManagement.checkPermission('CSM_Bypass_CSM_Validation_Rules');
        Map<String, Asset> assetMap = new Map<String, Asset>();
        Asset newAssetRef = new Asset();
        Set<Id> accountIds = new Set<Id>();
        for(Asset assetVar : newAssetList){
            string keyName = (assetVar.Name).toUpperCase();
            assetMap.put((keyName),assetVar);
            accountIds.add(assetVar.AccountId);
        }
        if((assetMap != null && !assetMap.isEmpty()) && (accountIds != null && !accountIds.isEmpty())){
            for (Asset assetVarFor : [SELECT Name, AccountId FROM Asset WHERE AccountId IN :accountIds 
                                      AND Name IN :assetMap.KeySet() ]) {
                                          newAssetRef  = assetMap.get((assetVarFor.Name).toUpperCase());
                                          if(newAssetRef != null && newAssetRef.AccountId == assetVarFor.AccountId && hasCustomPermission == false)
                                              newAssetRef.addError('A similar asset already exist for this account. Cannot create a duplicate asset.');
                                      }
        }
    }
}
