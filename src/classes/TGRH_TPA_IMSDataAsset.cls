public class TGRH_TPA_IMSDataAsset {
    public Static Boolean batchToExecute = true;
    
    public String createKey(TPA_Data_Asset__c tpaDa){
        String Key = '';
        Key+= tpaDa.A_Column_Use_For_Template__c + ';';
        Key+= tpaDa.Purpose__r.Purpose_Category_Name__c + ';';
        Key+= tpaDa.Primary_Asset_Geo_Level__c + ';';
        Key+= tpaDa.BU__c + ';';
        if(tpaDa.Asset_Name__c != null && tpaDa.Asset_Name__c.contains(':')){
            Key+= tpaDa.Asset_Name__c.split(':')[0];
        }
        else{
            Key+= tpaDa.Asset_Name__c;
        }
        return Key;
    }

    public void onAfterUpdate(List<IMS_Data_Asset__c> oldDataAssetList, List<IMS_Data_Asset__c> newDataAssetList, Map<Id,IMS_Data_Asset__c> oldDataAssetMap, Map<Id,IMS_Data_Asset__c> newDataAssetMap) {
        Map<String,String> keysWithNewId = new Map<String,String>();
        Set<Id> reqsSet = new Set<Id>();
        for(TPA_Data_Asset__c tpaDataAsset : [Select Id,Asset_Name__c,Data_Asset__c,BU__c,A_Column_Use_For_Template__c,Primary_Asset_Geo_Level__c,Purpose__r.Name,Purpose__r.Purpose_Category_Name__c,Request__c From TPA_Data_Asset__c where Data_Asset__c in: newDataAssetMap.KeySet() and Request__r.Request_Status__c in ('Awaiting Account Mgmt Communication',:UTL_TPA.AWAITING_CLIENT_CONFIRMATION,'Awaiting Client Modification','Awaiting Final Review','In Review By IQVIA','Pending Vendor AMA Fee Acknowledgement','Pending - Vendor Declined AMA Fees','TPA Approved Awaiting AMA Approval','Pending Vendor Response on Data Destruction from Prior TPAs','Hold for TPA non-compliance')]){
            String Key = createKey(tpaDataAsset);
            String emails = '';
            if(newDataAssetMap.get(tpaDataAsset.Data_Asset__c).Is_Active__c == true && newDataAssetMap.get(tpaDataAsset.Data_Asset__c).Commercial_Owner_Email__c != oldDataAssetMap.get(tpaDataAsset.Data_Asset__c).Commercial_Owner_Email__c && newDataAssetMap.get(tpaDataAsset.Data_Asset__c).Requires_Secondary_Review__c == true && newDataAssetMap.get(tpaDataAsset.Data_Asset__c).Secondary_Commercial_Reviewer_Email__c != oldDataAssetMap.get(tpaDataAsset.Data_Asset__c).Secondary_Commercial_Reviewer_Email__c){
                emails = newDataAssetMap.get(tpaDataAsset.Data_Asset__c).Commercial_Owner_Email__c + '~' + newDataAssetMap.get(tpaDataAsset.Data_Asset__c).Secondary_Commercial_Reviewer_Email__c;
            }
            else if(newDataAssetMap.get(tpaDataAsset.Data_Asset__c).Is_Active__c == true && newDataAssetMap.get(tpaDataAsset.Data_Asset__c).Commercial_Owner_Email__c != oldDataAssetMap.get(tpaDataAsset.Data_Asset__c).Commercial_Owner_Email__c){
                emails = newDataAssetMap.get(tpaDataAsset.Data_Asset__c).Commercial_Owner_Email__c + '~ ';
            }
            else if(newDataAssetMap.get(tpaDataAsset.Data_Asset__c).Is_Active__c == true && newDataAssetMap.get(tpaDataAsset.Data_Asset__c).Requires_Secondary_Review__c == true && newDataAssetMap.get(tpaDataAsset.Data_Asset__c).Secondary_Commercial_Reviewer_Email__c != oldDataAssetMap.get(tpaDataAsset.Data_Asset__c).Secondary_Commercial_Reviewer_Email__c){
                emails = ' ~'+newDataAssetMap.get(tpaDataAsset.Data_Asset__c).Secondary_Commercial_Reviewer_Email__c;
            }
            keysWithNewId.put(Key,emails);
            reqsSet.add(tpaDataAsset.Request__c);
        }
        // && batchToExecute
        if(keysWithNewId != null && keysWithNewId.size() > 0){
            BCH_TPA_Update_Commercial_Review bchObj = new BCH_TPA_Update_Commercial_Review();
            bchObj.keysWithNewId = keysWithNewId;
            bchObj.reqsSet = reqsSet;
            Database.executeBatch(bchObj,1);
        }
        
    }
}
