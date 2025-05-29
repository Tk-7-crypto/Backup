@isTest
public class TST_CNT_PEP_ContractRenewalNotification 
{
    @testSetup
    public static void setup(){     
        Id prmProfileId = [select id from profile where name =: CON_PEP.S_P_PEP_COMMUNITY ].id;
        Account ac = new Account(name ='Acme', CustomerSegment__c = 'GOVERNMENT', Sub_Industry__c = 'STATE') ;
        ac.AccountCountry__c = 'BM' ;
        insert ac;

        Contact con = new Contact(FirstName = 'TestFirstName', LastName ='testCon',AccountId = ac.Id,Email='partneruser@iqvia.partner.com');
        con.Partner_Type__c = 'Integrator Partner; Data Partner';
        con.PRM_Contract_Renewal_Notification__c = True;
        insert con;
        
        User partnerUser = new User(alias = 'test123', email='partneruser@iqvia.partner.com',
                                    emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                                    localesidkey='en_US', profileid = prmProfileId, country='United States',IsActive =true,
                                    ContactId = con.Id,PortalRole='Manager',
                                    timezonesidkey='America/Los_Angeles', username='xyz123490@iqviaTestPartner.com');
        insert partnerUser;
        
        
        User us=[SELECT Contact.AccountId from user WHERE Id= : partnerUser.Id];
        
        Product2 prod = TST_PEP_TestDataFactory.createProduct('Oce Sales');
        prod.Pillar__c = 'Information Offering; Technology Solutions; R&D';
        insert prod;
        
        Agency_Program__c agencyprog = TST_PEP_TestDataFactory.createAgencyProgram(prod);
        agencyprog.Status__c = 'Inactive';
        insert agencyprog;
        
        Contract testContract1 = new Contract(Project_Leader_Region__c='Asia Pacific', 
                                              RecordTypeId=Schema.SObjectType.Contract.getRecordTypeInfosByDeveloperName().get('PRM_Contract').getRecordTypeId(),
                                              AccountId=us.Contact.AccountId,
                                              Status='Assigned - Not Started',
                                              Date_Tracking_started__c=Date.newInstance(2024, 12, 9),
                                              Date_executed_signed_contract_received__c = Date.newInstance(2024, 12, 9),
                                              First_Notification_Date__c=Date.today(),
                                              Notification_Counter__c=1,
                                              Agency_Program__c=agencyprog.Id,
                                              Parent_Contract_Number__c = 1234,
                                              Ultimate_Parent_Contract_Number__c = 5678,
                                              SOW_status__c='Signed',
                                              PRM_Contract_type__c='Agency Program SOW',
                                              Non_Standard_Contract__c=false);
        insert testContract1;
        
        Contract testContract2 = new Contract(Project_Leader_Region__c='Asia Pacific', 
                                              RecordTypeId=Schema.SObjectType.Contract.getRecordTypeInfosByDeveloperName().get('PRM_Contract').getRecordTypeId(),
                                              AccountId=us.Contact.AccountId,
                                              Status='Assigned - Not Started',
                                              Date_Tracking_started__c=Date.newInstance(2024, 12, 9),
                                              Date_executed_signed_contract_received__c = Date.newInstance(2024, 12, 9),
                                              Second_Notification_Date__c=Date.today(),
                                              Notification_Counter__c=2,
                                              Agency_Program__c=agencyprog.Id,
                                              Parent_Contract_Number__c = 1234,
                                              Ultimate_Parent_Contract_Number__c = 5678,
                                              SOW_status__c='Signed',
                                              PRM_Contract_type__c='Agency Program SOW',
                                              Non_Standard_Contract__c=false);
        insert testContract2;
        User adminUser = TST_PEP_TestDataFactory.createAdminUser('admin','adminPartner@iqvia.com');
        
        System.runAs(adminUser){
            EmailTemplate testEmailTemplate1 = TST_PEP_TestDataFactory.createEmailTemplate('Contract Reminder_First', 'Test_Template1', 'custom');
            testEmailTemplate1.Body = 'test1';
            testEmailTemplate1.FolderId = UserInfo.getUserId();
            insert testEmailTemplate1;
            EmailTemplate testEmailTemplate2 = TST_PEP_TestDataFactory.createEmailTemplate('Contract Reminder_Second', 'Test_Template2', 'custom');
            testEmailTemplate2.Body = 'test2';
            testEmailTemplate2.FolderId = UserInfo.getUserId();
            insert testEmailTemplate2;
            EmailTemplate testEmailTemplate3 = TST_PEP_TestDataFactory.createEmailTemplate('Contract Reminder_Third', 'Test_Template3', 'custom');
            testEmailTemplate3.Body = 'test3';
            testEmailTemplate3.FolderId = UserInfo.getUserId();
            insert testEmailTemplate3;
            EmailTemplate testEmailTemplate4 = TST_PEP_TestDataFactory.createEmailTemplate('Contract Reminder_Expired', 'Test_Template4', 'custom');
            testEmailTemplate4.Body = 'test4';
            testEmailTemplate4.FolderId = UserInfo.getUserId();
            insert testEmailTemplate4;
        }
     /*   Contract testContract3 = new Contract(Project_Leader_Region__c='Asia Pacific', 
                                              RecordTypeId=Schema.SObjectType.Contract.getRecordTypeInfosByDeveloperName().get('PRM_Contract').getRecordTypeId(),
                                              AccountId=ac.Id,
                                              Status='Assigned - Not Started',
                                              Date_Tracking_started__c=Date.newInstance(2019, 12, 9),
                                              Date_executed_signed_contract_received__c = Date.newInstance(2019, 12, 9),
                                              Third_Notification_Date__c=Date.today(),
                                              Notification_Counter__c=3,
                                              Agency_Program__c=agencyprog.Id,
                                              Parent_Contract_Number__c = 1234,
                                              Ultimate_Parent_Contract_Number__c = 5678,
                                              PRM_Contract_type__c='Agency Program SOW');
        insert testContract3;*/
        
        /*Contract testContract4 = new Contract(Project_Leader_Region__c='Asia Pacific', 
                                              RecordTypeId=Schema.SObjectType.Contract.getRecordTypeInfosByDeveloperName().get('PRM_Contract').getRecordTypeId(),
                                              AccountId=ac.Id,
                                              Status='Assigned - Not Started',
                                              Date_Tracking_started__c=Date.newInstance(2019, 12, 9),
                                              Date_executed_signed_contract_received__c = Date.newInstance(2019, 12, 9),
                                              EndDate=Date.newInstance(2018, 2, 2),
                                              Notification_Counter__c=3,
                                              Agency_Program__c=agencyprog.Id,
                                              Parent_Contract_Number__c = 1234,
                                              Ultimate_Parent_Contract_Number__c = 5678,
                                              PRM_Contract_type__c='Agency Program SOW');
        insert testContract4;
        
        Contract testContract5 = new Contract(Project_Leader_Region__c='Asia Pacific', 
                                              RecordTypeId=Schema.SObjectType.Contract.getRecordTypeInfosByDeveloperName().get('PRM_Contract').getRecordTypeId(),
                                              AccountId=ac.Id,
                                              Status='Assigned - Not Started',
                                              Date_Tracking_started__c=Date.newInstance(2019, 12, 9),
                                              Date_executed_signed_contract_received__c = Date.newInstance(2019, 12, 9),
                                              EndDate=Date.newInstance(2018, 2, 2),
                                              Notification_Counter__c=4,
                                              Agency_Program__c=agencyprog.Id,
                                              Parent_Contract_Number__c = 1234,
                                              Ultimate_Parent_Contract_Number__c = 5678,
                                              PRM_Contract_type__c='Agency Program SOW');
        insert testContract5;*/
    }
    
    @isTest
    public static void testcontractRenewalNotification()
    { 
        Test.startTest();
        SchedulableContext sc = null;
        CNT_PEP_ContractRenewalNotification crn = new CNT_PEP_ContractRenewalNotification(); 
        crn.execute(sc);
        Test.stopTest();  
    }
}