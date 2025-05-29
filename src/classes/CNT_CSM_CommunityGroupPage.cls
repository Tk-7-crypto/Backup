public class CNT_CSM_CommunityGroupPage {
    @AuraEnabled(cacheable=true)
    public static List<ProductData> searchProducts(String searchString) {
        List<ProductData> productDataList = new List<ProductData>();
        try {
            String query = 'SELECT Id, Name, ProductCode FROM Product2 WHERE Name LIKE ' + 
                '\'' +String.escapeSingleQuotes(searchString.trim()) + '%\'' + 'AND SpecificToCSM__c = true LIMIT 50'; 
            
            for(Product2 product : Database.query(query)){
                ProductData productData = new ProductData();
                productData.value = String.valueOf(product.get('id'));
                productData.label = String.valueOf(product.get('Name'));
                productData.product = product;
                productDataList.add(productData);
            } 
        } catch (Exception err) {
            throw new AuraHandledException(err.getMessage());
        }
        return productDataList;
    }
    
    @AuraEnabled
    public static Boolean checkGroupManagerExistence(String groupId) {
        List<CollaborationGroupMember> chatterGroupManagers = [SELECT Id, Member.Name FROM CollaborationGroupMember WHERE CollaborationGroupId =: groupId AND CollaborationRole = 'Admin'];
        if(chatterGroupManagers != null && chatterGroupManagers.size() > 0 && chatterGroupManagers.size() > 1) {
            return true;
        } else {
            return false;
        }
        
    }
    
    @AuraEnabled
    public static Product_Group_Relationship__c saveProductRelationship(String groupId, ProductData selectedProduct) {
        String condition = 'Collaboration_Group_Id__c = \'' +groupId + '\'';
        List<Product_Group_Relationship__c> productRelationshipList = new SLT_ProductGroupRelationship().getProductRelationships(
            new Set<String> {'Id', 'Name', 'Product__c', 'Product__r.Name', 'Collaboration_Group_Id__c'}, condition);
        
        Product_Group_Relationship__c productRelationship;
        if(productRelationshipList != null && productRelationshipList.size() > 0) {
            String message = CON_CSM.S_PRODUCT_RELATIONSHIP_ALREADY_EXIST;
            throw new AuraHandledException(message);
        } else {
            String groupCondition = 'Id = \'' +groupId + '\'';
            List<CollaborationGroup> chatterGroupList = new SLT_CollaborationGroup().getChatterGroups(new Set<String>{'Name'}, groupCondition);
            CollaborationGroup chatterGroup = (chatterGroupList != null && chatterGroupList.size() > 0) ? chatterGroupList[0] : null;
            if(chatterGroup != null) {
                productRelationship = new Product_Group_Relationship__c();
                productRelationship.Name = selectedProduct.label +'-'+ chatterGroup.Name;
                productRelationship.Collaboration_Group_Id__c = groupId;
                productRelationship.Product__c = selectedProduct.value;
            }
            if(productRelationship != null) {
                try{
                    insert productRelationship;
                } catch(Exception ex) {
                    throw new AuraHandledException(ex.getMessage());
                }
            }
        }
        return productRelationship;
    }
    
    @AuraEnabled
    public static Product_Group_Relationship__c updateProductRelationship(String groupId, ProductData selectedProduct, Product_Group_Relationship__c productRelationship) {
        String condition = 'Id = \'' +productRelationship.Id + '\'';
        Product_Group_Relationship__c productRelationshipToBeUpdated;
        List<Product_Group_Relationship__c> productRelationshipList = new SLT_ProductGroupRelationship().getProductRelationships(
            new Set<String> {'Id', 'Name', 'Product__c', 'Product__r.Name', 'Collaboration_Group_Id__c'}, condition);
        if(productRelationshipList != null && productRelationshipList.size() > 0) {
            productRelationshipToBeUpdated = productRelationshipList[0];
            if(productRelationshipToBeUpdated != null && productRelationshipToBeUpdated.Collaboration_Group_Id__c == groupId) {
                CollaborationGroup chatterGroup = [SELECT Name FROM CollaborationGroup WHERE Id =: groupId];
                if(chatterGroup != null) {
                    productRelationshipToBeUpdated.Name = selectedProduct.label +'-'+ chatterGroup.Name;
                    productRelationshipToBeUpdated.Product__c = selectedProduct.value;
                    try{
                        update productRelationshipToBeUpdated;
                    } catch(Exception ex) {
                        throw new AuraHandledException(ex.getMessage());
                    }
                }
            }
        }
        return productRelationshipToBeUpdated;
    }
            
    @AuraEnabled
    public static Product_Group_Relationship__c getProductRelationship(String groupId) {
        String condition = 'Collaboration_Group_Id__c = \'' +groupId + '\'';
        List<Product_Group_Relationship__c> productRelationshipList = new SLT_ProductGroupRelationship().getProductRelationships(
            new Set<String> {'Id', 'Name', 'Product__c', 'Product__r.Name', 'Collaboration_Group_Id__c'}, condition);
        Product_Group_Relationship__c productRelationship;
        if(productRelationshipList != null && productRelationshipList.size() > 0) {
            productRelationship = productRelationshipList[0];
        }
        return productRelationship;
    }
    
    @AuraEnabled
    public static User getCurrentUserInfo() {
        Map<Id, User> userMap = new SLT_User().selectByUserId(new Set<Id> {userInfo.getUserId()}, new Set<String>{'Profile.Name', 'Name'});
        User currentUser = userMap != null && userMap.size() > 0 && userMap.containsKey(userInfo.getUserId()) ? userMap.get(userInfo.getUserId()) : null;
        return currentUser;
    }
    
    @AuraEnabled
    public static CollaborationGroup getGroupDetails(String groupId) {
        CollaborationGroup chatterGroup;
        if(groupId != null && groupId != '') {
            String groupCondition = 'Id = \'' +groupId + '\'';
            List<CollaborationGroup> chatterGroupList = new SLT_CollaborationGroup().getChatterGroups(
                new Set<String>{'Id', 'Name', 'MemberCount', 'LastFeedModifiedDate', 'LastModifiedDate', 'OwnerId','Owner.Name', 'CollaborationType', 'MediumPhotoUrl'},
                groupCondition);
            chatterGroup = (chatterGroupList != null && chatterGroupList.size() > 0) ? chatterGroupList[0] : null;
        }
        return chatterGroup;
    }
    
    public class ProductData{
        @AuraEnabled public String label {get;set;}
        @AuraEnabled public String value {get;set;}
        @AuraEnabled public Product2 product {get;set;}
    }
}
