@IsTest
private class TST_CNT_CSM_CommunityGroupPage {
    @testSetup
    static void setup() {
        User adminUser = UTL_TestData.createUser('System Administrator', 1)[0];
        adminUser.IsActive = true;
        Insert adminUser;
        
        CollaborationGroup chatterGroup = new CollaborationGroup(
            Name = 'Community Chatter Group', 
            Description = 'test chatter',
            CollaborationType = 'Public',
            CanHaveGuests = false,
            IsArchived = false,
            IsAutoArchiveDisabled = true
        );
        insert chatterGroup;
        CollaborationGroupMember member = new CollaborationGroupMember(CollaborationGroupId = chatterGroup.Id, CollaborationRole = 'Admin',
                                                                      MemberId = adminUser.Id);
        insert member;
        
        Product2 p1 = UTL_TestData.createProduct();
        p1.Name = 'DDD';
        p1.SpecificToCSM__c = True;
        insert p1;
        
        Product2 p2 = UTL_TestData.createProduct();
        p2.Name = 'Nexxus MI';
        p2.SpecificToCSM__c = True;
        insert p2;
    }
    
    @IsTest
    private static void testGetGroupDetails() {
        String groupId = [SELECT Id FROM CollaborationGroup WHERE Name = 'Community Chatter Group' LIMIT 1].Id;
        
        Test.startTest();
            CollaborationGroup chatterGroup = CNT_CSM_CommunityGroupPage.getGroupDetails(groupId);
        Test.stopTest();
        
        System.assertEquals(true, chatterGroup.MemberCount > 0, 'Should get group details');
    }
    
    @IsTest
    private static void testCheckGroupManagerExistence() {
        String groupId = [SELECT Id FROM CollaborationGroup WHERE Name = 'Community Chatter Group' LIMIT 1].Id;
        
        Test.startTest();
            Boolean groupManagerExist = CNT_CSM_CommunityGroupPage.checkGroupManagerExistence(groupId);
        Test.stopTest();
        
        System.assertEquals(true, groupManagerExist, 'Should get group manager existance');
    }
    
    @IsTest
    private static void testSearchProducts() {
        String searchString = 'DD';
        
        Test.startTest();
            List<CNT_CSM_CommunityGroupPage.ProductData> productDataList = CNT_CSM_CommunityGroupPage.searchProducts(searchString);
        Test.stopTest();
        
        System.assertEquals(true, productDataList != null, 'Should search products');
    }
    
    @IsTest
    private static void testSaveProductRelationship() {
        String groupId = [SELECT Id FROM CollaborationGroup WHERE Name = 'Community Chatter Group' LIMIT 1].Id;
        Product2 product = [SELECT Id, Name FROM Product2 WHERE Name = 'DDD' LIMIT 1];
        CNT_CSM_CommunityGroupPage.ProductData selectedProduct = new CNT_CSM_CommunityGroupPage.ProductData();
        selectedProduct.label = product.Name;
        selectedProduct.value = product.Id;
        selectedProduct.product = product;
        
        Test.startTest();
            Product_Group_Relationship__c productRelationship = CNT_CSM_CommunityGroupPage.saveProductRelationship(groupId, selectedProduct);
        Test.stopTest();
        
        System.assertEquals(true, productRelationship != null, 'Should save product group relationship');
    }
    
    @IsTest
    private static void testUpdateProductRelationship() {
        String groupId = [SELECT Id FROM CollaborationGroup WHERE Name = 'Community Chatter Group' LIMIT 1].Id;
        Product2 productDDD = [SELECT Id, Name FROM Product2 WHERE Name = 'DDD' LIMIT 1];
        Product2 productNexxusMI = [SELECT Id, Name FROM Product2 WHERE Name = 'Nexxus MI' LIMIT 1];
        CNT_CSM_CommunityGroupPage.ProductData selectedProduct = new CNT_CSM_CommunityGroupPage.ProductData();
        selectedProduct.label = productNexxusMI.Name;
        selectedProduct.value = productNexxusMI.Id;
        selectedProduct.product = productNexxusMI;
        
        Product_Group_Relationship__c productRelationship = new Product_Group_Relationship__c(Name = 'DDD-Community Chatter Group', Product__c = productDDD.Id, Collaboration_Group_Id__c = groupId);
        insert productRelationship;
        
        Test.startTest();
            Product_Group_Relationship__c updatedProductRelationship = CNT_CSM_CommunityGroupPage.updateProductRelationship(groupId, selectedProduct, productRelationship);
        Test.stopTest();
        
        System.assertEquals(productNexxusMI.Id, updatedProductRelationship.Product__c, 'Should update product group relationship');
    }
    
    @IsTest
    private static void testGetProductRelationship() {
        String groupId = [SELECT Id FROM CollaborationGroup WHERE Name = 'Community Chatter Group' LIMIT 1].Id;
        Product2 productDDD = [SELECT Id, Name FROM Product2 WHERE Name = 'DDD' LIMIT 1];
        
        Product_Group_Relationship__c productRelationship = new Product_Group_Relationship__c(Name = 'DDD-Community Chatter Group', Product__c = productDDD.Id, Collaboration_Group_Id__c = groupId);
        insert productRelationship;
        
        Test.startTest();
            Product_Group_Relationship__c productRelationshipRecord = CNT_CSM_CommunityGroupPage.getProductRelationship(groupId);
        Test.stopTest();
        
        System.assertEquals(true, productRelationshipRecord != null, 'Should get product group relationship');
    }
    
    @IsTest
    private static void testGetCurrentUserInfo() {
        
        Test.startTest();
            User currentUser = CNT_CSM_CommunityGroupPage.getCurrentUserInfo();
        Test.stopTest();
        
        System.assertEquals(true, currentUser != null, 'Should get current user');
    }
}