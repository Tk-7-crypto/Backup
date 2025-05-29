@IsTest
private class TST_SLT_ProductGroupRelationship {
    @testSetup
    static void setup() {
        Community_topic__c topic = new Community_topic__c(Name='DDD');
        insert topic;
        
        Product2 p1 = UTL_TestData.createProduct();
        p1.Name = 'DDD';
        p1.SpecificToCSM__c = True;
        p1.Community_Topic__c = topic.Id;
        insert p1;
        
        CollaborationGroup chatterGroup = new CollaborationGroup(
            Name = 'Community Chatter Group', 
            Description = 'test chatter',
            CollaborationType = 'Public',
            CanHaveGuests = false,
            IsArchived = false,
            IsAutoArchiveDisabled = true
        );
        insert chatterGroup;
        
        Product_Group_Relationship__c productRelationship = new Product_Group_Relationship__c(Name = 'DDD-Community Chatter Group', Product__c = p1.Id, Collaboration_Group_Id__c = chatterGroup.Id);
        insert productRelationship;
    }
    
    @IsTest
    private static void testGetProductRelationships() {
        String groupId = [SELECT Id FROM CollaborationGroup WHERE Name = 'Community Chatter Group' LIMIT 1].Id;
        String condition = 'Collaboration_Group_Id__c = \''+ groupId + '\'';
        
        Test.startTest();
            List<Product_Group_Relationship__c> productRelationshipList = new SLT_ProductGroupRelationship().getProductRelationships(new Set<String>{'Id', 'Name'}, condition);
        Test.stopTest();
        
        System.assertEquals(true, productRelationshipList != null, 'Should get product relationship by condition');
    }
}