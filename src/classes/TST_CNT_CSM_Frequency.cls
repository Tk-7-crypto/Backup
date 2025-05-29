@isTest
private class TST_CNT_CSM_Frequency {

    @testSetup
    private static void dataSetup(){
        UserRole portalRole = [SELECT Id FROM UserRole WHERE DeveloperName = 'CSM' LIMIT 1];
        Profile adminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        User adminUser = New User(Alias = 'su', UserRoleId = portalRole.Id, ProfileId = adminProfile.Id, Email = 'adminUser12@iqvia.com', IsActive =true , Username ='adminUser12@iqvia.com.csm', 
                                  LastName= 'testLastName', EmployeeNumber='4345702', CommunityNickname ='testSuNickname', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', 
                                  LanguageLocaleKey='en_US', Change_Request_Description__c = 'test', Change_Request_Ticket_Number__c ='test description');
        insert adminUser;
        
        System.runAs(adminUser){
            Product2 productRecord = UTL_TestData.createProduct();
            insert productRecord;
            Account accRecord = UTL_TestData.createAccount();
            insert accRecord;
            Asset assetRecord = new Asset(Name = 'TestAsset', AccountId = accRecord.Id, Product2Id = productRecord.Id);
            insert assetRecord;
            Id techRecordTypeId =  Schema.SObjectType.Case.getRecordTypeInfosByName().get('TechnologyCase').getRecordTypeId();
            CSM_QI_Case_Categorization__c categorization = new CSM_QI_Case_Categorization__c(Product__c = productRecord.Id, SubType1__c = 'TestSubtype1', 
                                                                                             SubType2__c = 'TestSubtype2 2', SubType3__c = 'TestSubtype3 2', 
                                                                                             RecordTypeId__c = techRecordTypeId, Pillar__c = CON_CSM.S_TECHNOLOGY_SOLUTIONS, Type__c = 'Categorization');
            insert categorization;
            
            Queue_User_Relationship__c queue = new Queue_User_Relationship__c();
            queue.Name ='Tech Queue';
            queue.QueueName__c ='Tech Queue';
            queue.Type__c ='Queue';
            insert queue;
            Queue_User_Relationship__c queueUser1 = new Queue_User_Relationship__c();
            queueUser1.Name ='Tech Queue';
            queueUser1.TECH_QueueUser__c = queue.id;
            queueUser1.QueueName__c ='Tech Queue';
            queueUser1.Type__c ='User';
            queueUser1.User__c = UserInfo.getUserId();
            insert queueUser1;
            Queue_User_Relationship__c queueUser2 = new Queue_User_Relationship__c();
            queueUser2.Name ='Tech Queue';
            queueUser2.QueueName__c ='Tech Queue';
            queueUser2.Type__c ='User';
            queueUser2.TECH_QueueUser__c = queue.id;
            queueUser2.User__c = adminUser.Id;
            insert queueUser2;
            
            CSM_QI_CaseAutomationScheduler__c caseAutoRecord = new CSM_QI_CaseAutomationScheduler__c();
            caseAutoRecord.Account_Name__c = accRecord.Id;
            caseAutoRecord.Frequency__c = 'Daily';
            caseAutoRecord.Subject__c = 'Test subject';
            caseAutoRecord.Description__c = 'Test description';
            caseAutoRecord.Primary_Owner__c = UserInfo.getUserId();
            caseAutoRecord.Secondary_Owner__c = adminUser.Id;
            caseAutoRecord.Start_Date__c = Date.today();
            caseAutoRecord.Asset_Name__c = assetRecord.Id;
            insert caseAutoRecord;
        }
    }
    
    @isTest
    static void testGetParentRecord(){
        CSM_QI_CaseAutomationScheduler__c autoRecord = [SELECT Id FROM CSM_QI_CaseAutomationScheduler__c LIMIT 1];
        
        Test.startTest();
        CNT_CSM_Frequency.getParentRecord('CSM_QI_CaseAutomationScheduler__c', autoRecord.Id);
        Test.stopTest();
    }
    
    @isTest
    static void testSaveFrequency(){
        CSM_QI_CaseAutomationScheduler__c autoRecord = [SELECT Id,Start_Date__c FROM CSM_QI_CaseAutomationScheduler__c LIMIT 1];
        CSM_QI_Frequency__c freqRecord1 = new CSM_QI_Frequency__c();
        freqRecord1.Frequency__c = 'Daily';
        freqRecord1.Month_Date__c = '';
        freqRecord1.Month_Interval__c = '';
        freqRecord1.Week__c = '';
        freqRecord1.Weekday__c = '';
        
        CSM_QI_Frequency__c freqRecord2 = new CSM_QI_Frequency__c();
        freqRecord2.Frequency__c = 'Weekly';
        freqRecord2.Month_Date__c = '';
        freqRecord2.Month_Interval__c = '';
        freqRecord2.Week__c = '';
        freqRecord2.Weekday__c = 'Tuesday';
        
        CSM_QI_Frequency__c freqRecord3 = new CSM_QI_Frequency__c();
        freqRecord3.Frequency__c = 'Monthly';
        freqRecord3.Month_Date__c = '16';
        freqRecord3.Month_Interval__c = '1';
        freqRecord3.Week__c = '';
        freqRecord3.Weekday__c = '';
        
        CSM_QI_Frequency__c freqRecord4 = new CSM_QI_Frequency__c();
        freqRecord4.Frequency__c = 'Monthly';
        freqRecord4.Month_Date__c = 'last';
        freqRecord4.Month_Interval__c = '1';
        freqRecord4.Week__c = '';
        freqRecord4.Weekday__c = '';
        
        CSM_QI_Frequency__c freqRecord5 = new CSM_QI_Frequency__c();
        freqRecord5.Frequency__c = 'Monthly';
        freqRecord5.Month_Date__c = '';
        freqRecord5.Month_Interval__c = '1';
        freqRecord5.Week__c = '2';
        freqRecord5.Weekday__c = 'Thursday';
        
        CSM_QI_Frequency__c freqRecord6 = new CSM_QI_Frequency__c();
        freqRecord6.Frequency__c = 'Monthly';
        freqRecord6.Month_Date__c = '';
        freqRecord6.Month_Interval__c = '1';
        freqRecord6.Week__c = 'last';
        freqRecord6.Weekday__c = 'Sunday';
        
        CSM_QI_Frequency__c freqRecord7 = new CSM_QI_Frequency__c();
        freqRecord7.Frequency__c = 'Monthly';
        freqRecord7.Month_Date__c = '10';
        freqRecord7.Month_Interval__c = '3';
        freqRecord7.Week__c = '';
        freqRecord7.Weekday__c = '';
        
        CSM_QI_Frequency__c freqRecord8 = new CSM_QI_Frequency__c();
        freqRecord8.Frequency__c = 'Monthly';
        freqRecord8.Month_Date__c = 'last';
        freqRecord8.Month_Interval__c = '3';
        freqRecord8.Week__c = '';
        freqRecord8.Weekday__c = '';
        
        CSM_QI_Frequency__c freqRecord9 = new CSM_QI_Frequency__c();
        freqRecord9.Frequency__c = 'Monthly';
        freqRecord9.Month_Date__c = '';
        freqRecord9.Month_Interval__c = '3';
        freqRecord9.Week__c = '1';
        freqRecord9.Weekday__c = 'Thursday';
        
        CSM_QI_Frequency__c freqRecord10 = new CSM_QI_Frequency__c();
        freqRecord10.Frequency__c = 'Monthly';
        freqRecord10.Month_Date__c = '';
        freqRecord10.Month_Interval__c = '3';
        freqRecord10.Week__c = 'last';
        freqRecord10.Weekday__c = 'Monday';
        
        CSM_QI_Frequency__c freqRecord11 = new CSM_QI_Frequency__c();
        freqRecord11.Frequency__c = 'Monthly';
        freqRecord11.Month_Date__c = '';
        freqRecord11.Month_Interval__c = '1';
        freqRecord11.Week__c = 'last';
        freqRecord11.Weekday__c = 'Monday';
        
        CSM_QI_Frequency__c freqRecord12 = new CSM_QI_Frequency__c();
        freqRecord12.Frequency__c = 'Monthly';
        freqRecord12.Month_Date__c = '';
        freqRecord12.Month_Interval__c = '1';
        freqRecord12.Week__c = 'last';
        freqRecord12.Weekday__c = 'Saturday';
        
        CSM_QI_Frequency__c freqRecord13 = new CSM_QI_Frequency__c();
        freqRecord13.Frequency__c = 'Monthly';
        freqRecord13.Month_Date__c = '';
        freqRecord13.Month_Interval__c = '1';
        freqRecord13.Week__c = 'last';
        freqRecord13.Weekday__c = 'Friday';
        
        
        Test.startTest();
        CNT_CSM_Frequency.fetchFrequencyRecord(freqRecord1.Id);
        
        CNT_CSM_Frequency.saveFrequency(JSON.serialize(freqRecord1), autoRecord.Id);
        CNT_CSM_Frequency.saveFrequency(JSON.serialize(freqRecord2), autoRecord.Id);
        CNT_CSM_Frequency.saveFrequency(JSON.serialize(freqRecord3), autoRecord.Id);
        CNT_CSM_Frequency.saveFrequency(JSON.serialize(freqRecord4), autoRecord.Id);
        CNT_CSM_Frequency.saveFrequency(JSON.serialize(freqRecord5), autoRecord.Id);
        CNT_CSM_Frequency.saveFrequency(JSON.serialize(freqRecord6), autoRecord.Id);
        CNT_CSM_Frequency.saveFrequency(JSON.serialize(freqRecord7), autoRecord.Id);
        CNT_CSM_Frequency.saveFrequency(JSON.serialize(freqRecord8), autoRecord.Id);
        CNT_CSM_Frequency.saveFrequency(JSON.serialize(freqRecord9), autoRecord.Id);
        CNT_CSM_Frequency.saveFrequency(JSON.serialize(freqRecord10), autoRecord.Id);
        CNT_CSM_Frequency.saveFrequency(JSON.serialize(freqRecord11), autoRecord.Id);
        CNT_CSM_Frequency.saveFrequency(JSON.serialize(freqRecord12), autoRecord.Id);
        CNT_CSM_Frequency.saveFrequency(JSON.serialize(freqRecord13), autoRecord.Id);
        date myDate = date.today();
        integer year = myDate.year();
        integer year1 = year+1;
        Date nextDate1 = Date.parse('02/29/2024');
        autoRecord.Start_Date__c = nextDate1;
        update autoRecord;
        
        CNT_CSM_Frequency.saveFrequency(JSON.serialize(freqRecord1), autoRecord.Id);
        CNT_CSM_Frequency.saveFrequency(JSON.serialize(freqRecord2), autoRecord.Id);
        CNT_CSM_Frequency.saveFrequency(JSON.serialize(freqRecord3), autoRecord.Id);
        CNT_CSM_Frequency.saveFrequency(JSON.serialize(freqRecord4), autoRecord.Id);
        CNT_CSM_Frequency.saveFrequency(JSON.serialize(freqRecord5), autoRecord.Id);
        CNT_CSM_Frequency.saveFrequency(JSON.serialize(freqRecord6), autoRecord.Id);
        CNT_CSM_Frequency.saveFrequency(JSON.serialize(freqRecord7), autoRecord.Id);
        CNT_CSM_Frequency.saveFrequency(JSON.serialize(freqRecord8), autoRecord.Id);
        CNT_CSM_Frequency.saveFrequency(JSON.serialize(freqRecord9), autoRecord.Id);
        CNT_CSM_Frequency.saveFrequency(JSON.serialize(freqRecord10), autoRecord.Id);
        CNT_CSM_Frequency.saveFrequency(JSON.serialize(freqRecord11), autoRecord.Id);
        CNT_CSM_Frequency.saveFrequency(JSON.serialize(freqRecord12), autoRecord.Id);
        CNT_CSM_Frequency.saveFrequency(JSON.serialize(freqRecord13), autoRecord.Id);
        nextDate1 = Date.today();
        nextDate1.addDays(1);
        autoRecord.Start_Date__c = nextDate1;
        update autoRecord;
        CNT_CSM_Frequency.nextDateOnStartDateDailyFrequency(nextDate1, Date.today(), freqRecord1, autoRecord);
        CNT_CSM_Frequency.nextDateOnStartDateDailyFrequency(nextDate1, nextDate1, freqRecord1, autoRecord);
        CNT_CSM_Frequency.saveFrequency(JSON.serialize(freqRecord1), autoRecord.Id);
        Date tempDate = Date.today();
        autoRecord.Start_Date__c = tempDate;
        update autoRecord;
        Datetime tempDatetime = tempDate;
        String tempWeekDay = tempDatetime.format('EEEE');
        
        CSM_QI_Frequency__c freqRecord14 = new CSM_QI_Frequency__c();
        freqRecord14.Frequency__c = 'Weekly';
        freqRecord14.Month_Date__c = '';
        freqRecord14.Month_Interval__c = '';
        freqRecord14.Week__c = '';
        freqRecord14.Weekday__c = tempWeekDay;
        CNT_CSM_Frequency.saveFrequency(JSON.serialize(freqRecord14), autoRecord.Id);
        
        Date nextDate2 = Date.parse('12/31/'+year1);
        autoRecord.Start_Date__c = nextDate2;
        update autoRecord;
        
        CNT_CSM_Frequency.saveFrequency(JSON.serialize(freqRecord2), autoRecord.Id);
        CNT_CSM_Frequency.saveFrequency(JSON.serialize(freqRecord3), autoRecord.Id);
        CNT_CSM_Frequency.saveFrequency(JSON.serialize(freqRecord4), autoRecord.Id);
        CNT_CSM_Frequency.saveFrequency(JSON.serialize(freqRecord5), autoRecord.Id);
        CNT_CSM_Frequency.saveFrequency(JSON.serialize(freqRecord6), autoRecord.Id);
        CNT_CSM_Frequency.saveFrequency(JSON.serialize(freqRecord7), autoRecord.Id);
        CNT_CSM_Frequency.saveFrequency(JSON.serialize(freqRecord8), autoRecord.Id);
        CNT_CSM_Frequency.saveFrequency(JSON.serialize(freqRecord9), autoRecord.Id);
        CNT_CSM_Frequency.saveFrequency(JSON.serialize(freqRecord10), autoRecord.Id);
        CNT_CSM_Frequency.saveFrequency(JSON.serialize(freqRecord11), autoRecord.Id);
        CNT_CSM_Frequency.saveFrequency(JSON.serialize(freqRecord12), autoRecord.Id);
        CNT_CSM_Frequency.saveFrequency(JSON.serialize(freqRecord13), autoRecord.Id);
        
        Date nextDate3 = Date.parse('09/30/'+year1);
        autoRecord.Start_Date__c = nextDate3;
        update autoRecord;
        CNT_CSM_Frequency.saveFrequency(JSON.serialize(freqRecord3), autoRecord.Id);
        CNT_CSM_Frequency.saveFrequency(JSON.serialize(freqRecord4), autoRecord.Id);
        
        Date nextDate4 = Date.parse('09/03/'+year1);
        autoRecord.Start_Date__c = nextDate4;
        update autoRecord;
        CNT_CSM_Frequency.saveFrequency(JSON.serialize(freqRecord4), autoRecord.Id);
        
        Date nextDate5 = Date.parse('01/31/'+year1);
        autoRecord.Start_Date__c = nextDate5;
        update autoRecord;
        CNT_CSM_Frequency.saveFrequency(JSON.serialize(freqRecord4), autoRecord.Id);
        
        Date nextDate6 = Date.parse('03/31/'+year1);
        autoRecord.Start_Date__c = nextDate6;
        update autoRecord;
        CNT_CSM_Frequency.saveFrequency(JSON.serialize(freqRecord4), autoRecord.Id);
        integer year4 = 4+year;
        Date nextDate7 = Date.parse('02/29/2028');
        autoRecord.Start_Date__c = nextDate7;
        update autoRecord;
        CNT_CSM_Frequency.saveFrequency(JSON.serialize(freqRecord4), autoRecord.Id);
        
        Date nextDate8 = Date.parse('02/25/'+year4);
        autoRecord.Start_Date__c = nextDate8;
        update autoRecord;
        CNT_CSM_Frequency.saveFrequency(JSON.serialize(freqRecord4), autoRecord.Id);
        integer year2 = 2+year;
        Date nextDate9 = Date.parse('02/28/'+year2);
        autoRecord.Start_Date__c = nextDate9;
        update autoRecord;
        CNT_CSM_Frequency.saveFrequency(JSON.serialize(freqRecord4), autoRecord.Id);
        
        Date nextDate10 = Date.parse('02/24/'+year2);
        autoRecord.Start_Date__c = nextDate10;
        update autoRecord;
        CNT_CSM_Frequency.saveFrequency(JSON.serialize(freqRecord4), autoRecord.Id);
        Test.stopTest();
    }
    
    @isTest
    static void testSaveMonthlyFrequency(){
        CSM_QI_CaseAutomationScheduler__c autoRecord = [SELECT Id,Start_Date__c FROM CSM_QI_CaseAutomationScheduler__c LIMIT 1];
        
        CSM_QI_Frequency__c freqRecord1 = new CSM_QI_Frequency__c();
        freqRecord1.Frequency__c = 'Monthly';
        freqRecord1.Month_Date__c = '';
        freqRecord1.Month_Interval__c = '1';
        freqRecord1.Week__c = '2';
        freqRecord1.Weekday__c = 'Thursday';
        
        CSM_QI_Frequency__c freqRecord2 = new CSM_QI_Frequency__c();
        freqRecord2.Frequency__c = 'Monthly';
        freqRecord2.Month_Date__c = '';
        freqRecord2.Month_Interval__c = '1';
        freqRecord2.Week__c = 'last';
        freqRecord2.Weekday__c = 'Sunday';
        
        CSM_QI_Frequency__c freqRecord3 = new CSM_QI_Frequency__c();
        freqRecord3.Frequency__c = 'Monthly';
        freqRecord3.Month_Date__c = '';
        freqRecord3.Month_Interval__c = '1';
        freqRecord3.Week__c = '1';
        freqRecord3.Weekday__c = 'Monday';
        date myDate = date.today();
        integer year = myDate.year();
        integer yearM1 = year-1;
        Test.startTest();
        Date nextDate1 = Date.parse('03/28/'+year);
        autoRecord.Start_Date__c = nextDate1;
        update autoRecord;
        CNT_CSM_Frequency.saveFrequency(JSON.serialize(freqRecord1), autoRecord.Id);
        CNT_CSM_Frequency.saveFrequency(JSON.serialize(freqRecord3), autoRecord.Id);
        
        Date nextDate2 = Date.parse('12/04/'+yearM1);
        autoRecord.Start_Date__c = nextDate2;
        update autoRecord;
        CNT_CSM_Frequency.saveFrequency(JSON.serialize(freqRecord1), autoRecord.Id);
        CNT_CSM_Frequency.saveFrequency(JSON.serialize(freqRecord3), autoRecord.Id);
        
        Date nextDate3 = Date.parse('06/05/'+yearM1);
        autoRecord.Start_Date__c = nextDate3;
        update autoRecord;
        CNT_CSM_Frequency.saveFrequency(JSON.serialize(freqRecord3), autoRecord.Id);
        CNT_CSM_Frequency.saveFrequency(JSON.serialize(freqRecord2), autoRecord.Id);
        integer year3 = year+3;
        Date nextDate4 = Date.parse('02/06/'+year3);
        autoRecord.Start_Date__c = nextDate4;
        update autoRecord;
        CNT_CSM_Frequency.saveFrequency(JSON.serialize(freqRecord2), autoRecord.Id);
        
        Date nextDate5 = Date.parse('02/28/'+year3);
        autoRecord.Start_Date__c = nextDate5;
        update autoRecord;
        CNT_CSM_Frequency.saveFrequency(JSON.serialize(freqRecord2), autoRecord.Id);
        
        Date nextDate6 = Date.parse('12/31/'+year);
        autoRecord.Start_Date__c = nextDate6;
        update autoRecord;
        CNT_CSM_Frequency.saveFrequency(JSON.serialize(freqRecord2), autoRecord.Id);
        Test.stopTest();
    }
    
    @isTest
    static void testSaveQuarterlyDateFrequency(){
        CSM_QI_CaseAutomationScheduler__c autoRecord = [SELECT Id,Start_Date__c FROM CSM_QI_CaseAutomationScheduler__c LIMIT 1];
        
        CSM_QI_Frequency__c freqRecord1 = new CSM_QI_Frequency__c();
        freqRecord1.Frequency__c = 'Monthly';
        freqRecord1.Month_Date__c = '17';
        freqRecord1.Month_Interval__c = '3';
        freqRecord1.Week__c = '';
        freqRecord1.Weekday__c = '';
        
        CSM_QI_Frequency__c freqRecord2 = new CSM_QI_Frequency__c();
        freqRecord2.Frequency__c = 'Monthly';
        freqRecord2.Month_Date__c = 'last';
        freqRecord2.Month_Interval__c = '3';
        freqRecord2.Week__c = '';
        freqRecord2.Weekday__c = '';
        date myDate = date.today();
        integer year = myDate.year();
        Test.startTest();
        Date nextDate1 = Date.parse('02/14/'+year);
        autoRecord.Start_Date__c = nextDate1;
        update autoRecord;
        CNT_CSM_Frequency.nextDateOnQuarterlyDateFrequency(nextDate1, freqRecord1, autoRecord);
        CNT_CSM_Frequency.nextDateOnQuarterlyDateFrequency(nextDate1, freqRecord2, autoRecord);
        CNT_CSM_Frequency.saveFrequency(JSON.serialize(freqRecord1), autoRecord.Id);
        CNT_CSM_Frequency.saveFrequency(JSON.serialize(freqRecord2), autoRecord.Id);
        
        Date nextDate2 = Date.parse('03/31/'+year);
        autoRecord.Start_Date__c = nextDate2;
        update autoRecord;
        CNT_CSM_Frequency.nextDateOnQuarterlyDateFrequency(nextDate2, freqRecord1, autoRecord);
        CNT_CSM_Frequency.nextDateOnQuarterlyDateFrequency(nextDate2, freqRecord2, autoRecord);
        CNT_CSM_Frequency.saveFrequency(JSON.serialize(freqRecord1), autoRecord.Id);
        CNT_CSM_Frequency.saveFrequency(JSON.serialize(freqRecord2), autoRecord.Id);
        
        Date nextDate3 = Date.parse('03/14/'+year);
        autoRecord.Start_Date__c = nextDate3;
        update autoRecord;
        CNT_CSM_Frequency.nextDateOnQuarterlyDateFrequency(nextDate3, freqRecord1, autoRecord);
        CNT_CSM_Frequency.nextDateOnQuarterlyDateFrequency(nextDate3, freqRecord2, autoRecord);
        CNT_CSM_Frequency.saveFrequency(JSON.serialize(freqRecord1), autoRecord.Id);
        CNT_CSM_Frequency.saveFrequency(JSON.serialize(freqRecord2), autoRecord.Id);
        
        Date nextDate4 = Date.parse('04/14/'+year);
        autoRecord.Start_Date__c = nextDate4;
        update autoRecord;
        CNT_CSM_Frequency.nextDateOnQuarterlyDateFrequency(nextDate4, freqRecord1, autoRecord);
        CNT_CSM_Frequency.nextDateOnQuarterlyDateFrequency(nextDate4, freqRecord2, autoRecord);
        CNT_CSM_Frequency.saveFrequency(JSON.serialize(freqRecord1), autoRecord.Id);
        CNT_CSM_Frequency.saveFrequency(JSON.serialize(freqRecord2), autoRecord.Id);
        
        Date nextDate5 = Date.parse('06/30/'+year);
        autoRecord.Start_Date__c = nextDate5;
        update autoRecord;
        CNT_CSM_Frequency.nextDateOnQuarterlyDateFrequency(nextDate5, freqRecord1, autoRecord);
        CNT_CSM_Frequency.nextDateOnQuarterlyDateFrequency(nextDate5, freqRecord2, autoRecord);
        CNT_CSM_Frequency.saveFrequency(JSON.serialize(freqRecord1), autoRecord.Id);
        CNT_CSM_Frequency.saveFrequency(JSON.serialize(freqRecord2), autoRecord.Id);
        
        Date nextDate6 = Date.parse('06/14/'+year);
        autoRecord.Start_Date__c = nextDate6;
        update autoRecord;
        CNT_CSM_Frequency.nextDateOnQuarterlyDateFrequency(nextDate6, freqRecord1, autoRecord);
        CNT_CSM_Frequency.nextDateOnQuarterlyDateFrequency(nextDate6, freqRecord2, autoRecord);
        CNT_CSM_Frequency.saveFrequency(JSON.serialize(freqRecord1), autoRecord.Id);
        CNT_CSM_Frequency.saveFrequency(JSON.serialize(freqRecord2), autoRecord.Id);
        
        Date nextDate7 = Date.parse('08/14/'+year);
        autoRecord.Start_Date__c = nextDate7;
        update autoRecord;
        CNT_CSM_Frequency.nextDateOnQuarterlyDateFrequency(nextDate7, freqRecord1, autoRecord);
        CNT_CSM_Frequency.nextDateOnQuarterlyDateFrequency(nextDate7, freqRecord2, autoRecord);
        CNT_CSM_Frequency.saveFrequency(JSON.serialize(freqRecord1), autoRecord.Id);
        CNT_CSM_Frequency.saveFrequency(JSON.serialize(freqRecord2), autoRecord.Id);
        
        Date nextDate8 = Date.parse('09/30/'+year);
        autoRecord.Start_Date__c = nextDate8;
        update autoRecord;
         CNT_CSM_Frequency.nextDateOnQuarterlyDateFrequency(nextDate8, freqRecord1, autoRecord);
        CNT_CSM_Frequency.nextDateOnQuarterlyDateFrequency(nextDate8, freqRecord2, autoRecord);
        CNT_CSM_Frequency.saveFrequency(JSON.serialize(freqRecord1), autoRecord.Id);
        CNT_CSM_Frequency.saveFrequency(JSON.serialize(freqRecord2), autoRecord.Id);
        
        Date nextDate9 = Date.parse('09/04/'+year);
        autoRecord.Start_Date__c = nextDate9;
        update autoRecord;
        CNT_CSM_Frequency.nextDateOnQuarterlyDateFrequency(nextDate9, freqRecord1, autoRecord);
        CNT_CSM_Frequency.nextDateOnQuarterlyDateFrequency(nextDate9, freqRecord2, autoRecord);
        CNT_CSM_Frequency.saveFrequency(JSON.serialize(freqRecord1), autoRecord.Id);
        CNT_CSM_Frequency.saveFrequency(JSON.serialize(freqRecord2), autoRecord.Id);
        
        Date nextDate10 = Date.parse('11/16/'+year);
        autoRecord.Start_Date__c = nextDate10;
        update autoRecord;
        CNT_CSM_Frequency.nextDateOnQuarterlyDateFrequency(nextDate10, freqRecord1, autoRecord);
        CNT_CSM_Frequency.nextDateOnQuarterlyDateFrequency(nextDate10, freqRecord2, autoRecord);
        CNT_CSM_Frequency.saveFrequency(JSON.serialize(freqRecord1), autoRecord.Id);
        CNT_CSM_Frequency.saveFrequency(JSON.serialize(freqRecord2), autoRecord.Id);
        
        Date nextDate11 = Date.parse('12/31/'+year);
        autoRecord.Start_Date__c = nextDate11;
        update autoRecord;
        CNT_CSM_Frequency.nextDateOnQuarterlyDateFrequency(nextDate11, freqRecord1, autoRecord);
        CNT_CSM_Frequency.nextDateOnQuarterlyDateFrequency(nextDate11, freqRecord2, autoRecord);
        CNT_CSM_Frequency.saveFrequency(JSON.serialize(freqRecord1), autoRecord.Id);
        CNT_CSM_Frequency.saveFrequency(JSON.serialize(freqRecord2), autoRecord.Id);
        
        Date nextDate12 = Date.parse('12/04/'+year);
        autoRecord.Start_Date__c = nextDate12;
        update autoRecord;
        CNT_CSM_Frequency.nextDateOnQuarterlyDateFrequency(nextDate12, freqRecord1, autoRecord);
        CNT_CSM_Frequency.nextDateOnQuarterlyDateFrequency(nextDate12, freqRecord2, autoRecord);
        CNT_CSM_Frequency.saveFrequency(JSON.serialize(freqRecord1), autoRecord.Id);
        CNT_CSM_Frequency.saveFrequency(JSON.serialize(freqRecord2), autoRecord.Id);
        Test.stopTest();
    }
    
    @isTest
    static void testSaveQuarterlyWeekFrequency(){
        CSM_QI_CaseAutomationScheduler__c autoRecord = [SELECT Id,Start_Date__c FROM CSM_QI_CaseAutomationScheduler__c LIMIT 1];
        
        CSM_QI_Frequency__c freqRecord1 = new CSM_QI_Frequency__c();
        freqRecord1.Frequency__c = 'Monthly';
        freqRecord1.Month_Date__c = '';
        freqRecord1.Month_Interval__c = '3';
        freqRecord1.Week__c = '1';
        freqRecord1.Weekday__c = 'Wednesday';
        
        CSM_QI_Frequency__c freqRecord2 = new CSM_QI_Frequency__c();
        freqRecord2.Frequency__c = 'Monthly';
        freqRecord2.Month_Date__c = '';
        freqRecord2.Month_Interval__c = '3';
        freqRecord2.Week__c = 'last';
        freqRecord2.Weekday__c = 'Friday';
        date myDate = date.today();
        integer year = myDate.year();
        Test.startTest();
        Map<String, Integer> weekMap = new Map<String, Integer>();
        weekMap.put('Sunday', 1); 
        weekMap.put('Monday', 2); 
        weekMap.put('Tuesday', 3); 
        weekMap.put('Wednesday', 4);
        weekMap.put('Thursday', 5); 
        weekMap.put('Friday', 6); 
        weekMap.put('Saturday', 7);
        Date nextDate1 = Date.parse('02/14/'+year);
        autoRecord.Start_Date__c = nextDate1;
        update autoRecord;
        CNT_CSM_Frequency.nextDateOnQuarterlyWeekFrequency(nextDate1, freqRecord1, autoRecord, weekMap);
        CNT_CSM_Frequency.nextDateOnQuarterlyWeekFrequency(nextDate1, freqRecord1, autoRecord, weekMap);
        CNT_CSM_Frequency.saveFrequency(JSON.serialize(freqRecord1), autoRecord.Id);
        CNT_CSM_Frequency.saveFrequency(JSON.serialize(freqRecord2), autoRecord.Id);
        
        Date nextDate2 = Date.parse('03/31/'+year);
        autoRecord.Start_Date__c = nextDate2;
        update autoRecord;
        CNT_CSM_Frequency.nextDateOnQuarterlyWeekFrequency(nextDate2, freqRecord1, autoRecord, weekMap);
        CNT_CSM_Frequency.nextDateOnQuarterlyWeekFrequency(nextDate2, freqRecord2, autoRecord, weekMap);
        CNT_CSM_Frequency.saveFrequency(JSON.serialize(freqRecord1), autoRecord.Id);
        CNT_CSM_Frequency.saveFrequency(JSON.serialize(freqRecord2), autoRecord.Id);
        
        Date nextDate3 = Date.parse('03/04/'+year);
        autoRecord.Start_Date__c = nextDate3;
        update autoRecord;
        CNT_CSM_Frequency.nextDateOnQuarterlyWeekFrequency(nextDate3, freqRecord1, autoRecord, weekMap);
        CNT_CSM_Frequency.nextDateOnQuarterlyWeekFrequency(nextDate3, freqRecord2, autoRecord, weekMap);
        CNT_CSM_Frequency.saveFrequency(JSON.serialize(freqRecord1), autoRecord.Id);
        CNT_CSM_Frequency.saveFrequency(JSON.serialize(freqRecord2), autoRecord.Id);
        
        Date nextDate4 = Date.parse('04/14/'+year);
        autoRecord.Start_Date__c = nextDate4;
        update autoRecord;
        CNT_CSM_Frequency.nextDateOnQuarterlyWeekFrequency(nextDate4, freqRecord1, autoRecord, weekMap);
        CNT_CSM_Frequency.nextDateOnQuarterlyWeekFrequency(nextDate4, freqRecord2, autoRecord, weekMap);
        CNT_CSM_Frequency.saveFrequency(JSON.serialize(freqRecord1), autoRecord.Id);
        CNT_CSM_Frequency.saveFrequency(JSON.serialize(freqRecord2), autoRecord.Id);
        
        Date nextDate5 = Date.parse('06/30/'+year);
        autoRecord.Start_Date__c = nextDate5;
        update autoRecord;
        CNT_CSM_Frequency.nextDateOnQuarterlyWeekFrequency(nextDate5, freqRecord1, autoRecord, weekMap);
        CNT_CSM_Frequency.nextDateOnQuarterlyWeekFrequency(nextDate5, freqRecord2, autoRecord, weekMap);
        CNT_CSM_Frequency.saveFrequency(JSON.serialize(freqRecord1), autoRecord.Id);
        CNT_CSM_Frequency.saveFrequency(JSON.serialize(freqRecord2), autoRecord.Id);
        
        Date nextDate6 = Date.parse('06/03/'+year);
        autoRecord.Start_Date__c = nextDate6;
        update autoRecord;
        CNT_CSM_Frequency.nextDateOnQuarterlyWeekFrequency(nextDate6, freqRecord1, autoRecord, weekMap);
        CNT_CSM_Frequency.nextDateOnQuarterlyWeekFrequency(nextDate6, freqRecord2, autoRecord, weekMap);
        CNT_CSM_Frequency.saveFrequency(JSON.serialize(freqRecord1), autoRecord.Id);
        CNT_CSM_Frequency.saveFrequency(JSON.serialize(freqRecord2), autoRecord.Id);
        
        Date nextDate7 = Date.parse('08/14/'+year);
        autoRecord.Start_Date__c = nextDate7;
        update autoRecord;
        CNT_CSM_Frequency.nextDateOnQuarterlyWeekFrequency(nextDate7, freqRecord1, autoRecord, weekMap);
        CNT_CSM_Frequency.nextDateOnQuarterlyWeekFrequency(nextDate7, freqRecord2, autoRecord, weekMap);
        CNT_CSM_Frequency.saveFrequency(JSON.serialize(freqRecord1), autoRecord.Id);
        CNT_CSM_Frequency.saveFrequency(JSON.serialize(freqRecord2), autoRecord.Id);
        
        Date nextDate8 = Date.parse('09/30/'+year);
        autoRecord.Start_Date__c = nextDate8;
        update autoRecord;
        CNT_CSM_Frequency.nextDateOnQuarterlyWeekFrequency(nextDate8, freqRecord1, autoRecord, weekMap);
        CNT_CSM_Frequency.nextDateOnQuarterlyWeekFrequency(nextDate8, freqRecord2, autoRecord, weekMap);
        CNT_CSM_Frequency.saveFrequency(JSON.serialize(freqRecord1), autoRecord.Id);
        CNT_CSM_Frequency.saveFrequency(JSON.serialize(freqRecord2), autoRecord.Id);
        
        Date nextDate9 = Date.parse('09/01/'+year);
        autoRecord.Start_Date__c = nextDate9;
        update autoRecord;
        CNT_CSM_Frequency.nextDateOnQuarterlyWeekFrequency(nextDate9, freqRecord1, autoRecord, weekMap);
        CNT_CSM_Frequency.nextDateOnQuarterlyWeekFrequency(nextDate9, freqRecord2, autoRecord, weekMap);
        CNT_CSM_Frequency.saveFrequency(JSON.serialize(freqRecord1), autoRecord.Id);
        CNT_CSM_Frequency.saveFrequency(JSON.serialize(freqRecord2), autoRecord.Id);
        
        Date nextDate10 = Date.parse('11/16/'+year);
        autoRecord.Start_Date__c = nextDate10;
        update autoRecord;
        CNT_CSM_Frequency.nextDateOnQuarterlyWeekFrequency(nextDate10, freqRecord1, autoRecord, weekMap);
        CNT_CSM_Frequency.nextDateOnQuarterlyWeekFrequency(nextDate10, freqRecord2, autoRecord, weekMap);
        CNT_CSM_Frequency.saveFrequency(JSON.serialize(freqRecord1), autoRecord.Id);
        CNT_CSM_Frequency.saveFrequency(JSON.serialize(freqRecord2), autoRecord.Id);
        
        Date nextDate11 = Date.parse('12/31/'+year);
        autoRecord.Start_Date__c = nextDate11;
        update autoRecord;
        CNT_CSM_Frequency.nextDateOnQuarterlyWeekFrequency(nextDate11, freqRecord1, autoRecord, weekMap);
        CNT_CSM_Frequency.nextDateOnQuarterlyWeekFrequency(nextDate11, freqRecord2, autoRecord, weekMap);
        CNT_CSM_Frequency.saveFrequency(JSON.serialize(freqRecord1), autoRecord.Id);
        CNT_CSM_Frequency.saveFrequency(JSON.serialize(freqRecord2), autoRecord.Id);
        
        Date nextDate12 = Date.parse('12/03/'+year);
        autoRecord.Start_Date__c = nextDate12;
        update autoRecord;
        CNT_CSM_Frequency.nextDateOnQuarterlyWeekFrequency(nextDate12, freqRecord1, autoRecord, weekMap);
        CNT_CSM_Frequency.nextDateOnQuarterlyWeekFrequency(nextDate12, freqRecord2, autoRecord, weekMap);
        CNT_CSM_Frequency.saveFrequency(JSON.serialize(freqRecord1), autoRecord.Id);
        CNT_CSM_Frequency.saveFrequency(JSON.serialize(freqRecord2), autoRecord.Id);
        Test.stopTest();
    }
}
