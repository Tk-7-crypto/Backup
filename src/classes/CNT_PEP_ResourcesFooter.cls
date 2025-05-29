public class CNT_PEP_ResourcesFooter {
    @AuraEnabled
    public static String checkLeadProductExistence(String product)
    {
        Boolean productExists = false;
        String returnProduct = '';
        Schema.DescribeFieldResult fieldResult = Lead.Product__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            if(pickListVal.getLabel() == product)
            {
                productExists = true;
                returnProduct = product;
            }
        }
        
        if(productExists){
            return product;
        }
        else
        {
            List<User> users = new List<User>();
            users = new SLT_User().selectContactDetailByUser(new Set<Id> {userInfo.getUserId()}, new Set<String> {'AccountId'});
            List<asset> assets = new SLT_Asset().getAssetsWithFilter(new Set<String>{'Product2Id'}, 'AccountId=\''+ users[0].AccountId +'\' AND Product2.Community_Topic__r.Name =\''+ product +'\' AND Status !=\'Obsolete\' AND Product2Id !=\'\'');
            List<Product2> prod = new List<Product2>();
            if(assets.size() > 0)
            {
                Set<Id> prodId = new Set<Id>{assets[0].Product2Id};
                prod = new SLT_Product2().selectById(prodId);
            }
            if(prod.size()>0)
            {
                for( Schema.PicklistEntry pickListVal : ple){
                    if(pickListVal.getLabel() == prod[0].Name)
                    {
                        returnProduct = prod[0].Name;
                    }
                }
            }
        }
        
        return returnProduct;
    }
}