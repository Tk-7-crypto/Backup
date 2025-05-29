public class TGRH_TPA_IMSSecondaryDataAsset {
    public String createKey(TPA_Secondary_Data_Asset__c tpaSecDa){
        String Key = '';
        Key+= tpaSecDa.TPA_Data_Asset__r.A_Column_Use_For_Template__c + ';';
        Key+= tpaSecDa.TPA_Data_Asset__r.Purpose__r.Purpose_Category_Name__c + ';';
        Key+= tpaSecDa.Geo_Level__c + ';';
        Key+= tpaSecDa.BU__c + ';';
        if(tpaSecDa.Secondary_Asset_Name__c != null && tpaSecDa.Secondary_Asset_Name__c.contains(':')){
            Key+= tpaSecDa.Secondary_Asset_Name__c.split(':')[0];
        }
        else{
            Key+= tpaSecDa.Secondary_Asset_Name__c;
        }
        return Key;
    }
    public void onAfterUpdate(List<IMS_Secondary_Data_Asset__c> oldSecDataAssetList, List<IMS_Secondary_Data_Asset__c> newSecDataAssetList, Map<Id,IMS_Secondary_Data_Asset__c> oldDataAssetMap, Map<Id,IMS_Secondary_Data_Asset__c> newDataAssetMap) {
        Map<String,String> keysWithNewId = new Map<String,String>();
        Set<Id> reqsSet = new Set<Id>();
        for(TPA_Secondary_Data_Asset__c tpaSecDataAsset : [Select Id,TPA_Request_Secondary_Assets__c,Purpose__c,BU__c,Secondary_Asset_Name__c,Geo_Level__c,TPA_Data_Asset__r.A_Column_Use_For_Template__c,TPA_Data_Asset__r.Purpose__r.Purpose_Category_Name__c,IMS_Secondary_Data_Asset__c From TPA_Secondary_Data_Asset__c where IMS_Secondary_Data_Asset__c in: newDataAssetMap.KeySet() and TPA_Request_Secondary_Assets__r.Request_Status__c in ('Awaiting Account Mgmt Communication',:UTL_TPA.AWAITING_CLIENT_CONFIRMATION,'Awaiting Client Modification','Awaiting Final Review','In Review By IQVIA','Pending Vendor AMA Fee Acknowledgement','Pending - Vendor Declined AMA Fees','TPA Approved Awaiting AMA Approval','Pending Vendor Response on Data Destruction from Prior TPAs','Hold for TPA non-compliance')]){
            String Key = createKey(tpaSecDataAsset);
            String emails = '';
            if(newDataAssetMap.get(tpaSecDataAsset.IMS_Secondary_Data_Asset__c).Is_Active__c == true && newDataAssetMap.get(tpaSecDataAsset.IMS_Secondary_Data_Asset__c).Commercial_Manager_Email__c != oldDataAssetMap.get(tpaSecDataAsset.IMS_Secondary_Data_Asset__c).Commercial_Manager_Email__c && newDataAssetMap.get(tpaSecDataAsset.IMS_Secondary_Data_Asset__c).Requires_Secondary_Review__c == true && newDataAssetMap.get(tpaSecDataAsset.IMS_Secondary_Data_Asset__c).Secondary_Commercial_Reviewer_Email__c != oldDataAssetMap.get(tpaSecDataAsset.IMS_Secondary_Data_Asset__c).Secondary_Commercial_Reviewer_Email__c){
                emails = newDataAssetMap.get(tpaSecDataAsset.IMS_Secondary_Data_Asset__c).Commercial_Manager_Email__c + '~' + newDataAssetMap.get(tpaSecDataAsset.IMS_Secondary_Data_Asset__c).Secondary_Commercial_Reviewer_Email__c;
            }
            else if(newDataAssetMap.get(tpaSecDataAsset.IMS_Secondary_Data_Asset__c).Is_Active__c == true && newDataAssetMap.get(tpaSecDataAsset.IMS_Secondary_Data_Asset__c).Commercial_Manager_Email__c != oldDataAssetMap.get(tpaSecDataAsset.IMS_Secondary_Data_Asset__c).Commercial_Manager_Email__c){
                emails = newDataAssetMap.get(tpaSecDataAsset.IMS_Secondary_Data_Asset__c).Commercial_Manager_Email__c + '~ ';
            }
            else if(newDataAssetMap.get(tpaSecDataAsset.IMS_Secondary_Data_Asset__c).Is_Active__c == true && newDataAssetMap.get(tpaSecDataAsset.IMS_Secondary_Data_Asset__c).Requires_Secondary_Review__c == true && newDataAssetMap.get(tpaSecDataAsset.IMS_Secondary_Data_Asset__c).Secondary_Commercial_Reviewer_Email__c != oldDataAssetMap.get(tpaSecDataAsset.IMS_Secondary_Data_Asset__c).Secondary_Commercial_Reviewer_Email__c){
                emails = ' ~'+newDataAssetMap.get(tpaSecDataAsset.IMS_Secondary_Data_Asset__c).Secondary_Commercial_Reviewer_Email__c;
            }
            keysWithNewId.put(Key,emails);
            reqsSet.add(tpaSecDataAsset.TPA_Request_Secondary_Assets__c);
        }
        if(keysWithNewId != null && keysWithNewId.size() > 0 && TGRH_TPA_IMSDataAsset.batchToExecute){
            BCH_TPA_Update_Commercial_Review bchObj = new BCH_TPA_Update_Commercial_Review();
            bchObj.keysWithNewId = keysWithNewId;
            bchObj.reqsSet = reqsSet;
            Database.executeBatch(bchObj,1);
        }
        
    }
}
