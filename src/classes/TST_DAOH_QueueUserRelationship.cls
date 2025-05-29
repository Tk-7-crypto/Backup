@isTest
private class TST_DAOH_QueueUserRelationship {

    @isTest
    private static void testCustomEmailAddressValidation(){
        List<Queue_User_Relationship__c> qList = new List<Queue_User_Relationship__c>();
        Queue_User_Relationship__c QURecord = new Queue_User_Relationship__c();
        QURecord.Name = 'Test Queue';
        QURecord.AFU_Queue_Email__c = 'testuser@mail.com';
        QuRecord.Group_Id__c = '00G6A000000nv2XUAQ';
        QURecord.Queue_Emails_Text__c = 'demodata@mail.com; userrecord@co.in';
        QURecord.Type__c = 'Queue';
        QURecord.OwnerId = UserInfo.getUserId();
        qList.add(QURecord);
        Queue_User_Relationship__c quR = new Queue_User_Relationship__c();
        quR.Name = 'Test Queue';
        quR.AFU_Queue_Email__c = 'testuser@mail.com';
        quR.Group_Id__c = '00G6A000000nv2XUAQ';
        quR.Queue_Emails_Text__c = 'demodata@mail.com; userrecord@co.in';
        quR.Type__c = 'User';
        quR.IsDefaultQueue__c = false;
        quR.OwnerId = UserInfo.getUserId();
        qList.add(quR);
        Test.startTest();
        insert qList;
        List<Queue_User_Relationship__c> quList = Database.query('Select Id,IsDefaultQueue__c from Queue_User_Relationship__c where Type__c =\'User\'');
        for(Queue_User_Relationship__c q : quList){
            q.IsDefaultQueue__c = true;
        }
        try{
            update quList;    
        }catch(DmlException e){
            
        }
        
        Test.stopTest();
    }
}