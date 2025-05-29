public  class TGRH_TPASecDataAsset {
    
    public TGRH_TPASecDataAsset(){ }   
    
    public void onAfterInsert(List<TPA_Secondary_Data_Asset__c> updatedSecDataAssets){ 
        system.debug('In after Insert ');
        system.debug('updatedSecDataAssets: ' + updatedSecDataAssets);
    } 
    
    public void onBeforeDelete(List<TPA_Secondary_Data_Asset__c> paramOldSecDataAssetList, Map<id,TPA_Secondary_Data_Asset__c> paramOldSecDataAssetMap){
        if((Test.isRunningTest())||(UTL_TPA.getCurrentUserDetails().Profile.UserLicense.Name != 'Customer Community Plus Login' && !UTL_TPA.getCurrentUserDetails().Profile.Name.contains('System Admin') && !UTL_TPA.isUserTPASuperAdmin())){
            for(TPA_Secondary_Data_Asset__c tpaSecDataAssetObj: paramOldSecDataAssetList)
                tpaSecDataAssetObj.addError('You do not have necessary permissions to delete this TPA Secondary Data Asset record');
        }
    }


}