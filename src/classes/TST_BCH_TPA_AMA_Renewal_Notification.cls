@isTest(seeAllData = false)
public class TST_BCH_TPA_AMA_Renewal_Notification {    
    public static String CRON_EXP = '0 0 0 15 3 ? ' + (Date.Today().year() + 1);
    private static TPA_Request__c testTpaRequest;   
    private static AMA_Agreement_Detail__c amaObj;
    private static Date todayDate;
    
    // constructor
    private TST_BCH_TPA_AMA_Renewal_Notification() {}
    
    public static testMethod void test1() {
   
        Test.startTest();
        
        setupTestDataForRenewalForCancellation();
        // Schedule the test job
        String jobId = System.schedule('ScheduleApexClassTest', CRON_EXP, new SCH_TPA_AMA_Renewal_Notification());
          
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

    public static EmailTemplate getEmailTemplate(String name)
    {
        EmailTemplate emailTemp =  [select Id, Name from EmailTemplate where Name = :name];
        return emailTemp;
    }
    
    static void setupTestDataForRenewalForCancellation() {        
        Account  testNewClientAccount = new Account(Name = 'Test_New Client', BillingStreet = 'test', BillingCity = 'test', BillingCountry = 'test', BillingPostalCode = 'test', CustomerSegment__c = 'GOVERNMENT', Sub_Industry__c = 'STATE');
        insert testNewClientAccount;
        Address__c testAddress = new Address__c( name = 'Test_New Client',
                                          recordTypeId = UTL_TPA_SetupTestData.getTPAVendorAddressRecordTypeId,
                                          Is_TPA_Account__c = true,
                                          Account__c = testNewClientAccount.Id,
                                          Vendor_Registration_Number__c = 9999,
                                          Street__c = 'Test',
                                          City__c = 'Test',
                                          State__c = 'Test',
                                          Country__c = 'Test',
                                          PostalCode__c = 'Test',
                                          TPA_Local_Address_Required__c = false  
                                        );
            insert testAddress;

        UTL_TPA_SetupTestData.createAMASetting();
        
        testTpaRequest = new TPA_Request__c(OwnerId = UserInfo.getUserId(),
                                         AMA_USPrescriberData__c = 'Yes',
                                         Service_Provider_Address__c = testAddress.Id, 
                                         Client_Address__c = testAddress.Id,
                                         Vendor_Company_Name__c = 'AMA Vendor SB II',
                                         Vendor_Contact_Name_f__c = 'test',
                                         Vendor_Contact_Last_Name__c = 'test',
                                         data_access_start_date__c = Date.newInstance(System.Today().year(), 10 ,20),
                                         data_access_end_date__c = Date.newInstance(System.Today().year()+1, 8, 20),
                                         IMS_Data_Country_Location__c = 'United States',
                                         Employee_Accessing_Data_Location__c = 'Japan',
                                            Vendor_e_mail__c = 'supriya.johari@metacube.com',
                                            TP_Processor_Email__c = 'supriya.johari@metacube.com',
                                                      Vendor_Contact_e_mail__c = 'supriya.johari@metacube.com',
                                                      Vendor_Contact_Email_Client__c = 'supriya.johari@metacube.com',
                                                      Request_Status__c = 'In Effect',
                                                      Authorized_Signer_Email__c = 'test@metacube.com'
                                        );
        insert testTpaRequest;

        todayDate = Date.today();
        amaObj = new AMA_Agreement_Detail__c(TPA_Request__c = testTpaRequest.Id,
                                             Agreement_Start_Date__c = Date.newInstance(System.Today().year() , 10 ,20) , 
                                             Agreement_End_Date__c = Date.newInstance(System.Today().year()+1 , 12 ,31), 
                                             Date_Agreement_Activated__c = Date.newInstance(System.Today().year() , 10 ,22),
                                             AMA_Howlong_SP_has_Data_Access__c = '90 days or less', 
                                             FrequencyOfDeliveryToServiceProvider__c = 'Quarterly',
                                             AMA_TypeOfPrescriberLevelData__c='Birth Year;Gender Code',
                                             AMA_Services_Provided__c='Telemarketing;Labeling',
                                             //Status_of_Offshore_Questionnaire__c = 'Awaiting Vendor Response: AMA Offshore Questionnaire has been sent to Vendor',
                                             Last_Vendor_Offshore_Reminder_Mail_Sent__c = todayDate.addDays(-1),
                                             Vendor_Reasons_for_Termination__c  = 'No AMA data was shared',
                                             Next_Year_Fees__c = 1500,
                                             DBL__c = 'IQVIA',
                                             Invoice_Contact_Email__c = 'testInvoice@metacube.com'
                                             );
        insert amaObj;  

    } 
}