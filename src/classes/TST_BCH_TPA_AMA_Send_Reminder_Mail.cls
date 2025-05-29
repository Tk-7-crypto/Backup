@isTest(seeAllData = false)
public class TST_BCH_TPA_AMA_Send_Reminder_Mail {

    public static String CRON_EXP = '0 0 0 15 3 ? ' + (Date.Today().year() + 1);
    private static TPA_Request__c testTpaRequest;   
    private static AMA_Agreement_Detail__c amaObj;
    private static Date todayDate;

    
    static void setupTestDataForCancellation() {
      
        Address__c testNewClientAccount = UTL_TPA_SetupTestData.getAccount();
        testNewClientAccount.Name = 'test New Client';
        testNewClientAccount.is_TPA_Account__c = true;
        testNewClientAccount.Street__c = 'test';
        testNewClientAccount.City__c = 'test';
        testNewClientAccount.Country__c = 'test';
        testNewClientAccount.PostalCode__c = 'test';
        insert testNewClientAccount;
       
        UTL_TPA_SetupTestData.createAMASetting();
        UTL_TPA_SetupTestData.createTPASettingData();

        

        testTpaRequest = UTL_TPA_SetupTestData.getTPARequestBlank(false);
        testTpaRequest.OwnerId = UserInfo.getUserId();
        testTpaRequest.AMA_USPrescriberData__c = 'Yes';
        testTpaRequest.Service_Provider_Address__c = testNewClientAccount.Id;
        testTpaRequest.Client_Address__c = testNewClientAccount.Id;
        testTpaRequest.Vendor_Company_Name__c = 'AMA Vendor SB II';
        testTpaRequest.data_access_start_date__c = Date.newInstance(2016 , 10 ,20);
        testTpaRequest.data_access_end_date__c = Date.newInstance(2017, 8, 20);
        testTpaRequest.IMS_Data_Country_Location__c = 'United States';
        testTpaRequest.Employee_Accessing_Data_Location__c = 'United States';
        testTpaRequest.Vendor_Contact_Name_f__c = 'JEREMY';
        testTpaRequest.Vendor_Contact_Last_Name__c = 'MAYORS';
        testTpaRequest.TP_Processor_Email__c = 'supriya.johari@metacube.com';
        testTpaRequest.Vendor_Contact_e_mail__c = 'supriya.johari@metacube.com';
        testTpaRequest.Vendor_Contact_Email_Client__c = 'supriya.johari@metacube.com';
        testTpaRequest.Request_Status__c = 'Pending Vendor AMA Fee Acknowledgement';
        insert testTpaRequest;
        

    }
    
    public static void createAMAagreementForVendor()
    {
        todayDate = Date.today();
        amaObj = UTL_TPA_SetupTestData.getAMAAgreementDetailBlank(testTpaRequest.Id);
        amaObj.Agreement_Start_Date__c = Date.newInstance(2016 , 10 ,20);
        amaObj.Agreement_End_Date__c = Date.newInstance(2017 , 12 ,31);
        amaObj.AMA_Howlong_SP_has_Data_Access__c = '90 days or less';
        amaObj.FrequencyOfDeliveryToServiceProvider__c = 'Quarterly';
        amaObj.AMA_TypeOfPrescriberLevelData__c = 'Birth Year;Gender Code';
        amaObj.AMA_Services_Provided__c = 'Telemarketing;Labeling';
        amaObj.Status_of_Cancelation_Request__c = 'Awaiting Vendor Cancelation Acknowledgement';
        amaObj.Last_Vendor_Reminder_Mail_Sent__c =  todayDate.addDays(-1);
        amaObj.Vendor_Reasons_for_Termination__c  = 'No AMA data was shared';
        insert amaObj; 
    }
    
    public static void createAMAagreementForAMA()
    {
        todayDate = Date.today();
        amaObj = UTL_TPA_SetupTestData.getAMAAgreementDetailBlank(testTpaRequest.Id);
        amaObj.Agreement_Start_Date__c = Date.newInstance(2016 , 10 ,20);
        amaObj.Agreement_End_Date__c = Date.newInstance(2017 , 12 ,31);
        amaObj.AMA_Howlong_SP_has_Data_Access__c = '90 days or less';
        amaObj.FrequencyOfDeliveryToServiceProvider__c = 'Quarterly';
        amaObj.AMA_TypeOfPrescriberLevelData__c = 'Birth Year;Gender Code';
        amaObj.AMA_Services_Provided__c = 'Telemarketing;Labeling';
        amaObj.Status_of_Cancelation_Request__c = 'Awaiting AMA Response to Vendor Cancelation Request';
        amaObj.Last_AMA_Reminder_Mail_Sent__c = todayDate.addDays(-3);
        amaObj.Vendor_Reasons_for_Termination__c  = 'No AMA data was shared';
        insert amaObj; 
    }
    
    
    public static Contact createContact(String name, id AccountID){
        
        Contact c1 = UTL_TPA_SetupTestData.getContact();
        c1.firstName = name;
        c1.lastName = name + '12';       
        c1.Accountid = AccountID;
        insert c1;
        
        return c1;
  }
    
    
    public static EmailTemplate getEmailTemplate(String name)
    {
        EmailTemplate emailTemp =  [select Id, Name from EmailTemplate where Name = :name];
        return emailTemp;
    }
   
   
    public static testMethod void test1() {
   
        Test.startTest();
        
        setupTestDataForCancellation();
        createAMAagreementForVendor();
        
        // Schedule the test job
        String jobId = System.schedule('ScheduleApexClassTest', CRON_EXP, new SCH_TPA_AMA_Send_Reminder_Mail());
          
        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
          
        // Verify the expressions are the same
        System.assertEquals(CRON_EXP, ct.CronExpression);
          
        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);
          
        // Verify the next time the job will run
        DateTime calculatedFireTime = DateTime.newinstance(dateTime.now().year() + 1 , 3, 15);
        System.assertEquals(String.valueOf(calculatedFireTime), String.valueOf(ct.NextFireTime));

        Test.stopTest();
  
     }
    public static testMethod void test2() {
   
        Test.startTest();
        
        setupTestDataForCancellation();
        createAMAagreementForAMA();
        // Schedule the test job
        String jobId = System.schedule('ScheduleApexClassTest', CRON_EXP, new SCH_TPA_AMA_Send_Reminder_Mail());
          
        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
          
        // Verify the expressions are the same
        System.assertEquals(CRON_EXP, ct.CronExpression);
          
        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);
          
        // Verify the next time the job will run
        DateTime calculatedFireTime = DateTime.newinstance(dateTime.now().year() + 1 , 3, 15);
        System.assertEquals(String.valueOf(calculatedFireTime), String.valueOf(ct.NextFireTime));
          
        Test.stopTest();
          
   }
   
   // added by supriya Johari under ER-2906 starts
   
    static void setupTestDataForOffshore() {
        
        Address__c testNewClientAccount = UTL_TPA_SetupTestData.getAccount();
        testNewClientAccount.Name = 'test New Client';
        testNewClientAccount.is_TPA_Account__c = true;
        testNewClientAccount.Street__c = 'test';
        testNewClientAccount.City__c = 'test';
        testNewClientAccount.Country__c = 'test';
        testNewClientAccount.PostalCode__c = 'test';
        insert testNewClientAccount;
 
        UTL_TPA_SetupTestData.createAMASetting();
        UTL_TPA_SetupTestData.createTPASettingData();

        
        // Create test Tpa Request
        testTpaRequest = UTL_TPA_SetupTestData.getTPARequestBlank(false);
        testTpaRequest.OwnerId = UserInfo.getUserId();
        testTpaRequest.AMA_USPrescriberData__c = 'Yes';
        testTpaRequest.Service_Provider_Address__c = testNewClientAccount.Id;
        testTpaRequest.Client_Address__c = testNewClientAccount.Id;
        testTpaRequest.Vendor_Company_Name__c = 'AMA Vendor SB II';
        testTpaRequest.data_access_start_date__c = Date.newInstance(2016 , 10 ,20);
        testTpaRequest.data_access_end_date__c = Date.newInstance(2017, 8, 20);
        testTpaRequest.IMS_Data_Country_Location__c = 'United States';
        testTpaRequest.Employee_Accessing_Data_Location__c = 'Japan';
         testTpaRequest.Vendor_Contact_Name_f__c = 'JEREMY';
        testTpaRequest.Vendor_Contact_Last_Name__c = 'MAYORS';
        testTpaRequest.TP_Processor_Email__c = 'supriya.johari@metacube.com';
        testTpaRequest.Vendor_Contact_e_mail__c = 'supriya.johari@metacube.com';
        testTpaRequest.Vendor_Contact_Email_Client__c = 'supriya.johari@metacube.com';
        testTpaRequest.Request_Status__c = 'Pending - Vendor Declined AMA Fees';
        insert testTpaRequest;

        
    } 
   
    public static void createAMAagreementForOffshore(String offshoreStatus)
    {
        todayDate = Date.today();
        amaObj = UTL_TPA_SetupTestData.getAMAAgreementDetailBlank(testTpaRequest.Id);
        amaObj.Agreement_Start_Date__c = Date.newInstance(2016 , 10 ,20);
        amaObj.Agreement_End_Date__c = Date.newInstance(2017 , 12 ,31);
        amaObj.AMA_Howlong_SP_has_Data_Access__c = '90 days or less';
        amaObj.FrequencyOfDeliveryToServiceProvider__c = 'Quarterly';
        amaObj.AMA_TypeOfPrescriberLevelData__c = 'Birth Year;Gender Code';
        amaObj.AMA_Services_Provided__c = 'Telemarketing;Labeling';
        //amaObj.Status_of_Offshore_Questionnaire__c = 'Awaiting Vendor Response: AMA Offshore Questionnaire has been sent to Vendor';
        amaObj.Status_of_Offshore_Process__c = offshoreStatus;
        amaObj.Last_Vendor_Offshore_Reminder_Mail_Sent__c = todayDate.addDays(-1);
        amaObj.Vendor_Reasons_for_Termination__c  = 'No AMA data was shared';
        amaObj.Last_AMA_offshore_reminder_mail_sent__c = todayDate.addDays(-3);
        insert amaObj; 
    }
    
    public static testMethod void test5() {
        setupTestDataForCancellation();
        createAMAagreementForAMA();
        BCH_TPA_AMA_Send_Reminder_Mail bch = new BCH_TPA_AMA_Send_Reminder_Mail();
        bch.SendReminderWithRevisedOffshoreLink(amaObj);
    }
   // For Offshore Reminder Mail
    public static testMethod void test3() {
   
        Test.startTest();
        
        setupTestDataForOffshore();
        createAMAagreementForOffshore('Awaiting Vendor Response: AMA Offshore Consent form has been sent to Vendor');
        // Schedule the test job
        String jobId = System.schedule('ScheduleApexClassTest', CRON_EXP, new SCH_TPA_AMA_Send_Reminder_Mail());
          
        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
          
        // Verify the expressions are the same
        System.assertEquals(CRON_EXP, ct.CronExpression);
          
        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);
          
        // Verify the next time the job will run
        DateTime calculatedFireTime = DateTime.newinstance(dateTime.now().year() + 1 , 3, 15);
        System.assertEquals(String.valueOf(calculatedFireTime), String.valueOf(ct.NextFireTime));
          
        Test.stopTest();
          
   } 
   
    public static testMethod void test4() {
   
        Test.startTest();
        
        setupTestDataForOffshore();
        createAMAagreementForOffshore('Awaiting AMA Response: Offshore Consent form requires AMA review/approval');
        // Schedule the test job
        String jobId = System.schedule('ScheduleApexClassTest', CRON_EXP, new SCH_TPA_AMA_Send_Reminder_Mail());
          
        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
          
        // Verify the expressions are the same
        System.assertEquals(CRON_EXP, ct.CronExpression);
          
        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);
          
        // Verify the next time the job will run
        System.assertEquals((Date.Today().year() + 1) + '-03-15 00:00:00', String.valueOf(ct.NextFireTime));
          
        Test.stopTest();
          
   } 
}
