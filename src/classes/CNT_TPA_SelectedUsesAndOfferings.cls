public class CNT_TPA_SelectedUsesAndOfferings {
    public static string currentUserProfileName {
        get {
            if(currentUserProfileName == null) {
                currentUserProfileName = currentLoggedInUser.Profile.Name;
            }
            return currentUserProfileName;
        }
        set;
    }
    public static User currentLoggedInUser {
        get {
            if(currentLoggedInUser == null) {
                currentLoggedInUser = UTL_TPA.getCurrentUserDetails();
            }
            return currentLoggedInUser;
        }
        set;
    }
    public static string tpaCommunityUrl {
        get {
            if(tpaCommunityUrl == null && UTL_TPA.tpaSetting != null && !String.isEmpty(UTL_TPA.tpaSetting.TPA_Client_Community_Url__c)) {
                tpaCommunityUrl = UTL_TPA.tpaSetting.TPA_Client_Community_Url__c;
            }
            return tpaCommunityUrl;
        }
        set;
    }
    
    
    @remoteAction
    public static List<TPA_Data_Asset__c> fetchUseOffRecords(String reqId){
        String SelectedUseOffwrapperList = '';
        String queryForRecs = 'Select Id,CreatedDate,Asset_Name__c,Geo_Level__c, BU__c,Purpose__r.Purpose_Category_Name__c, Purpose__r.Name,Purpose__r.Other_Details__c,Other_Text__c,(Select Id,Secondary_Asset_Name__c From TPA_Secondary_Data_Assets__r)  From TPA_Data_Asset__c where Request__c =: reqId ';
       
        List<TPA_Data_Asset__c> offeringRecords = Database.query(queryForRecs);
        return offeringRecords;
    }
        
}