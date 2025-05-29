public class CNT_CSM_CommunityDocumentationMenu {
    
    @AuraEnabled
    public static List<Product2> getProductDetails(String category)
    {
        category = category.replaceAll('%20', ' ');
        List<User> users = new List<User>();
        users = new SLT_User().selectContactDetailByUser(new Set<Id> {userInfo.getUserId()}, new Set<String> {'AccountId'});
        List<asset> assets = new SLT_Asset().getAssetsWithFilter(new Set<String>{'Product2Id'}, 'AccountId=\''+ users[0].AccountId +'\' AND Product2.Community_Topic__r.Name =\''+ category +'\' AND Status !=\'Obsolete\' AND Product2Id !=\'\''); 
        List<Product2> prod = new List<Product2>();
        if(assets.size() > 0)
        {
            Set<Id> prodId = new Set<Id>{assets[0].Product2Id};
            prod = new SLT_Product2().selectById(prodId);
        }
        
        return prod;
    }
    
}