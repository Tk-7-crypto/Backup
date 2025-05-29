@isTest
private class TST_SCM_GetUserProfileController {
    private static User testUser;
    private static void setUpData(){
        insert new pse__Region__c(name='xz',pse__Hierarchy_Depth__c = 0);   
        List<User> listOfUsers = new List<User>();
        List<Profile> profiles = [select id from profile where name = 'System Administrator']; 
        testUser = new User(FirstName = 'testM',LastName = 'testM',Username = 'testSCM@metacube.com',EmployeeNumber='0707073',
                            Email =  'testMetacube@metacube.com',Alias = 'TestUsr1',TimeZoneSidKey = 'America/Los_Angeles',
                            LocaleSidKey = 'en_US',EmailEncodingKey = 'UTF-8',ProfileId = profiles.get(0).id ,LanguageLocaleKey ='en_US',
                            Change_Request_Description__c = 'test', Change_Request_Ticket_Number__c ='test description');
        listOfUsers.add(testUser);
        insert listOfUsers;
    }
    
    @isTest
    private static void testSaveLineItemShouldSaveLineItemWhenExecutedThroughSystemAdminAndNotCloned()
    {   
        setUpData();
        System.runAs(testUser)
        { 
            Contract_Management_Setting__c mycs = Contract_Management_Setting__c.getValues(UserInfo.getUserId());
  
            if(mycs == null) {
                mycs = new Contract_Management_Setting__c(Name= UserInfo.getUserId());
                mycs.Perform_SCM_Functions_Flag__c = true;
                insert mycs;
            } 
            
            List<PermissionSet> permissionSetList = [   SELECT Id, Name
                                                        FROM PermissionSet
                                                        WHERE Name = 'Japan_Contract_Management_SCM'];//change permission set name
           
            if(!permissionSetList.isEmpty())
            {
                PermissionSetAssignment permissionSetAssignment = new PermissionSetAssignment(AssigneeId = testUser.id, 
                	PermissionSetId = permissionSetList[0].Id);
                insert permissionSetAssignment;
            }

            
            Test.startTest();
            	SCM_GetUserProfileController controller = new SCM_GetUserProfileController();
            Test.stopTest();
            
            System.assertEquals(true,controller.hasAggNameEditPermission, 
            	'hasAggNameEditPermission is false, when true expected');
                        
        }  
    }
}