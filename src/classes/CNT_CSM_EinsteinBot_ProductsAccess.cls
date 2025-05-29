public class CNT_CSM_EinsteinBot_ProductsAccess {

    public class ChatScriptInput{
        @InvocableVariable(required=true)
        public Id routableId;
    }
    
    @InvocableMethod(label='ProductAccess')
    public static List<List<Product2>> getProductListOfLoggedInUser(List<ChatScriptInput> chatScriptIds){
        Id chatSessionId = chatScriptIds[0].routableId;
        LiveChatTranscript chatContactRecord = [SELECT ContactId FROM LiveChatTranscript WHERE Id = :chatSessionId LIMIT 1];
        Id contactId = chatContactRecord.ContactId;
        User userRecord = [SELECT Id, UserType FROM User WHERE ContactId = :contactId LIMIT 1];
        List<User> users = new List<User>();
        List<Product2> productNameList = new List<Product2>();
        if(userRecord.UserType.contains(CON_CSM.S_CUSTOMER_SUCCCESS)) {
            users = new SLT_User().selectContactDetailByUser(new Set<Id> {userRecord.Id}, new Set<String> {'Contact.Portal_Case_Type__c', 'Contact.Account.AccountCountry__c'});
            if (users.size() > 0 && users[0].Contact != null && users[0].Contact.Account != null) {
                String query = 'SELECT Id, Name, Community_Topic__r.Name FROM Product2 WHERE Id IN (SELECT Product2Id FROM Asset WHERE AccountId = \''+ users[0].AccountId +'\' AND Status != \'Obsolete\' AND Topic_Visible_in_CSH_Homepage__c = true) AND Community_Topic__r.Name != null ORDER BY Community_Topic__r.Name ASC';
                List<Product2> productsList = (List<Product2>)Database.query(query);
                List<CSM_EinsteinBot_Products__c> einsteinProductList = CSM_EinsteinBot_Products__c.getall().values();
                if(productsList != null && einsteinProductList != null && !productsList.isEmpty() && !einsteinProductList.isEmpty()){
                    for(Product2 productRecord : productsList){
                        for(CSM_EinsteinBot_Products__c einsteinRecord : einsteinProductList){
                            if(einsteinRecord.ProductId__c == productRecord.Id && einsteinRecord.ProductName__c == productRecord.Name){
                                if(!productNameList.contains(productRecord)){
                                    productNameList.add(productRecord);
                                }
                            }
                        }
                    }
                }
            }
        }
        return new List<List<Product2>>{productNameList};
    }
    public static List<Product2> getContactProducts(Id contactId){
        User userRecord = [SELECT Id, UserType FROM User WHERE ContactId = :contactId LIMIT 1];
        List<User> users = new List<User>();
        List<Product2> productNameList = new List<Product2>();
        if(userRecord.UserType.contains(CON_CSM.S_CUSTOMER_SUCCCESS)) {
            users = new SLT_User().selectContactDetailByUser(new Set<Id> {userRecord.Id}, new Set<String> {'Contact.Portal_Case_Type__c', 'Contact.Account.AccountCountry__c'});
            if (users.size() > 0 && users[0].Contact != null && users[0].Contact.Account != null) {
                String query = 'SELECT Id, Name, Community_Topic__r.Name FROM Product2 WHERE Id IN (SELECT Product2Id FROM Asset WHERE AccountId = \''+ users[0].AccountId +'\' AND Status != \'Obsolete\' AND Topic_Visible_in_CSH_Homepage__c = true) AND Community_Topic__r.Name != null ORDER BY Community_Topic__r.Name ASC';
                productNameList = (List<Product2>)Database.query(query);
                /*List<CSM_EinsteinBot_Products__c> einsteinProductList = CSM_EinsteinBot_Products__c.getall().values();
                if(productsList != null && einsteinProductList != null && !productsList.isEmpty() && !einsteinProductList.isEmpty()){
                    for(Product2 productRecord : productsList){
                        for(CSM_EinsteinBot_Products__c einsteinRecord : einsteinProductList){
                            if(einsteinRecord.ProductId__c == productRecord.Id && einsteinRecord.ProductName__c == productRecord.Name){
                                if(!productNameList.contains(productRecord)){
                                    productNameList.add(productRecord);
                                }
                            }
                        }
                    }
                }*/
            }
        }
        return productNameList;
    }
}