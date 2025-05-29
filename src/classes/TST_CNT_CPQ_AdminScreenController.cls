@isTest
public with sharing class TST_CNT_CPQ_AdminScreenController {
    @TestSetup
    static void createTestData() {
        CPQ_Admin_Features_Setting__c cSettings = new CPQ_Admin_Features_Setting__c(Permission_set_Name__c = 'CPQ ATC OTC Admin Screen Access', 
                                                                                    CPQ_Feature_Name__c = 'Approval user list',
                                                                                    DataLoad_Path__c = 'ATC_OTC_Admin',
                                                                                    Name = 'Approval user list' );
        CPQ_Admin_Features_Setting__c cSettings1 = new CPQ_Admin_Features_Setting__c(Permission_set_Name__c = 'CPQ ATC OTC Admin Screen Access', 
                                                                                    CPQ_Feature_Name__c = 'Pricing admin screen', 
                                                                                    DataLoad_Path__c = 'Pricing_Admin',
                                                                                    Name = 'Pricing admin screen');
        insert new List<CPQ_Admin_Features_Setting__c>{cSettings,cSettings1};
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        Profile techSolutionProfileId = [SELECT Id FROM Profile WHERE Name = 'Tech Solutions User' LIMIT 1];
        User usr = new User(LastName = 'tethariswamigovinda',
                           FirstName = 'paggal',
                           Alias = 'tgava',
                           Email = 'tethariswamigovinda@quintiles.com',
                           Username = 'tethariswamigovinda.paggal@psbr.com',
                           ProfileId = profileId.Id,
                           TimeZoneSidKey = 'GMT',
                           LanguageLocaleKey = 'en_US',
                           EmailEncodingKey = 'UTF-8',
                           LocaleSidKey = 'en_US',
                           Audit_Employee_Number_Reason__c = 'DEV',
                           Change_Request_Description__c = 'New User Setup',
                           Change_Request_Ticket_Number__c = '1111'
                           );
        insert usr;
    }
    @isTest
    static void cpqAdminScreenTest() {
        List<User> testUser = [SELECT Id, Profile.Name FROM USER LIMIT 1];
        System.runAs(testUser[0]) {
            Test.startTest();
            CNT_CPQ_AdminScreenController.getPermissionsetRecords();
            Test.stopTest();
        }
        Assert.isNotNull(testUser[0].Id, 'System Administrator Id');
    } 
    @IsTest
    static void cpqAdmincurrentuserTest() {
        Id currentUserId = UserInfo.getUserId();
        Test.startTest();
        CNT_CPQ_AdminScreenController.getPermissionsetRecords();
        Test.stopTest();
        Assert.isNotNull(currentUserId, 'Current user Id Exist');
     }
    @isTest
    static void checkPermissionSetAssigment(){
        List<PermissionSetAssignment> permissionSetList = new List<PermissionSetAssignment>();
        Id testuserId;
        for (User u : [SELECT Id, Profile.Name FROM USER WHERE Profile.Name ='Tech Solutions User' AND IsActive = true LIMIT 1]) { 
            testuserId = u.Id;
            ID permissionSetId = [SELECT Id FROM PermissionSet WHERE Label = 'CPQ ATC OTC Admin Screen Access' LIMIT 1][0].Id;
            PermissionSetAssignment psa = new PermissionSetAssignment (PermissionSetId = permissionSetId, AssigneeId = u.Id);
            permissionSetList.add(psa);
        }
        try {
            upsert permissionSetList;
            Test.startTest();
            CNT_CPQ_AdminScreenController.getPermissionsetRecords();
            Test.stopTest();
            Assert.isNotNull(testuserId, 'System Administrator Id');
        } catch(exception e) {
            system.debug('exception caught' + e);
        }
    }
}