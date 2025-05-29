@isTest
private class TST_DAOH_DataPortalQueueUserdetails {
    @isTest
    static void testcheckDefaultQueue(){
        Account acct = new Account(Name = 'TestAcc', RDCategorization__c = 'Site',CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE');
        insert acct;
        
        Contact Con = new Contact( Firstname='Brian', Lastname='Dent', Phone='(619)852-4569', 
            Department='Mission Control', Title='Mission Specialist - Neptune', Email='briandent@trailhead.com',
            AccountId = acct.Id);
        insert Con;
        
        User u = [Select id from User where Id = :UserInfo.getUserId() and ProfileId = :UserInfo.getProfileId()];
        
        system.runAs(u) {
            
            Group g1 = new Group(Name='Q1', type='Queue');
            insert g1;
            QueuesObject q1 = new QueueSObject(QueueID = g1.id, SobjectType = 'Case');
            insert q1;
            GroupMember grpUser = new GroupMember (UserOrGroupId = UserInfo.getUserId(), GroupId = g1.Id);
            insert grpUser;
            Queue_User_Relationship__c qur = new Queue_User_Relationship__c(
                Name = grpUser.group.Name,Type__c = 'Queue',Group_Id__c = grpUser.groupId);
            insert qur;
            
            
            Test.startTest();
            CSM_QI_Data_Portal_Queue_User_details__c c = new CSM_QI_Data_Portal_Queue_User_details__c(Account__c = acct.Id, All_Current_Users__c = true ,Queue_User_Relationship__c = qur.Id, Order__c = 1,Type__c ='Queue Assignment' ,CaseRecordType__c ='TechnologyCase');
            CSM_QI_Data_Portal_Queue_User_details__c c2 = new CSM_QI_Data_Portal_Queue_User_details__c(Account__c = acct.Id, Queue_User_Relationship__c = qur.Id, Order__c = 2,Type__c ='Queue Assignment' ,CaseRecordType__c ='TechnologyCase');
            CSM_QI_Data_Portal_Queue_User_details__c c3 = new CSM_QI_Data_Portal_Queue_User_details__c(Account__c = acct.Id, All_Current_Users__c = true ,Queue_User_Relationship__c = qur.Id, Order__c = 2,Type__c ='Queue Assignment' ,CaseRecordType__c ='DATACase');
            CSM_QI_Data_Portal_Queue_User_details__c c4 = new CSM_QI_Data_Portal_Queue_User_details__c(Account__c = acct.Id, All_Current_Users__c = true ,Queue_User_Relationship__c = qur.Id, Order__c = 1,Type__c ='Queue Assignment' ,CaseRecordType__c ='DATACase');
            try{
                insert c;
                insert c2;
                insert c3;
                insert c4;
            }catch(System.DmlException e){
                System.debug('Exception Dml Operation : '+ e.getMessage());
            }
                
            }
            
            Test.stopTest();
        }

}