@isTest
public class TST_BCH_CLM_AMA_AmendEmailNotification {

    @testSetup
    static void dataSetup() {
        Account testAccount = UTL_TestData.createAccount();
        insert testAccount;
        
        Contact testContact = UTL_TestData.createContact(testAccount.Id);
        testContact.Email = 'xyz@gmail.com';
        insert testContact; 
    
        Apttus__APTS_Agreement__c agreement = TST_CLM_TestDataFactory.createAgreement(CON_CLM.AMA_RECORDTYPEID, false);
        agreement.Apttus__Primary_Contact__c = testContact.Id;
        agreement.Apttus__Activated_Date__c = System.today();
        agreement.Apttus__Perpetual__c = true;
        agreement.Apttus__Subtype__c = 'EMERGING MARKET-LARGE';
        agreement.Record_Based_Cost__c = 18878.75;
        agreement.Number_Of_Records__c = 34325;
        agreement.Sales_Rep_Cost__c = 21325;
        agreement.Sales_Rep_Count__c = 340;
        agreement.Apttus__Total_Contract_Value__c = 40203.75; 
        agreement.Apttus__Auto_Renewal__c = true;
        agreement.Apttus__Contract_Start_Date__c = System.today();
        insert agreement;

        agreement.Apttus__Status_Category__c = CON_CLM.IN_EFFECT; 
        agreement.Apttus__Status__c = CON_CLM.ACTIVATED;
        update agreement;
        
        CLM_Configuration__c clmConfiguration = TST_CLM_TestDataFactory.createClmConfigurationSetting(false);
        clmConfiguration.AMA_Email_Template__c = 'AGR_ET19_CLM_AMA_Annual_Renewal_Notification_Template';
        clmConfiguration.AMA_Send_Amend_Email__c = false;
        insert clmConfiguration;
    }
    
    @isTest
    private static void testCreateHTMLTableForAMABulkAmendEmailNotification() {
        Apttus__APTS_Agreement__c agreement = [SELECT Apttus__Primary_Contact__r.Email, Agreement_Year_Plus_One__c, Agreement_Year__c, Apttus__Subtype__c, Record_Based_Cost__c, 
            Number_Of_Records__c, Sales_Rep_Cost__c, Sales_Rep_Count__c, Proration_Type__c, Apttus__Total_Contract_Value__c, Apttus__Primary_Contact__c FROM Apttus__APTS_Agreement__c 
            WHERE RecordTypeId =: CON_CLM.AMA_RECORDTYPEID LIMIT 1];
        String query = 'SELECT Apttus__Primary_Contact__c, Apttus__Primary_Contact__r.Email, Id, Agreement_Year_Plus_One__c, Agreement_Year__c, Apttus__Subtype__c, '
            +'Record_Based_Cost__c, Number_Of_Records__c, Sales_Rep_Cost__c, Sales_Rep_Count__c, Apttus__Total_Contract_Value__c, Proration_Type__c FROM Apttus__APTS_Agreement__c'
            +' WHERE RecordTypeId = \'' + CON_CLM.AMA_RECORDTYPEID +'\' AND Apttus__Status_Category__c =\'In Effect\' AND Apttus__Status__c = \'Activated\' AND Apttus__Auto_Renewal__c = true'; 
        BCH_CLM_AMA_AmendEmailNotification bulkEmail = new BCH_CLM_AMA_AmendEmailNotification(query);
        String resultTable = '<html>Sample</html>';
        
        Test.startTest();
            resultTable = bulkEmail.createHTMLTableForAMABulkAmendEmailNotification(agreement, resultTable);
        Test.stopTest();
         
        System.assertNotEquals(null, resultTable, 'The value should not be null');
    }
       
    @isTest
    private static void testTaskCreationForAMAAmendEmailNotification() {
        Map<Messaging.SingleEmailMessage, Apttus__APTS_Agreement__c> emailToAgreementMap = new Map<Messaging.SingleEmailMessage, Apttus__APTS_Agreement__c>();
        Apttus__APTS_Agreement__c agreement = [SELECT Id, Apttus__Primary_Contact__c FROM Apttus__APTS_Agreement__c WHERE 
            RecordTypeId =: CON_CLM.AMA_RECORDTYPEID LIMIT 1];  
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setSubject('Test');
        email.setHtmlBody('Sample');
        emailToAgreementMap.put(email, agreement);
        String query = 'SELECT Apttus__Primary_Contact__c, Apttus__Primary_Contact__r.Email, Id, Agreement_Year_Plus_One__c, Agreement_Year__c, Apttus__Subtype__c, '
            + 'Record_Based_Cost__c, Number_Of_Records__c, Sales_Rep_Cost__c, Sales_Rep_Count__c, Apttus__Total_Contract_Value__c, Proration_Type__c FROM Apttus__APTS_Agreement__c'
            + ' WHERE RecordTypeId = \'' + CON_CLM.AMA_RECORDTYPEID +'\' AND Apttus__Status_Category__c =\'In Effect\' AND Apttus__Status__c = \'Activated\' AND Apttus__Auto_Renewal__c = true'; 
        BCH_CLM_AMA_AmendEmailNotification bulkEmail = new BCH_CLM_AMA_AmendEmailNotification(query);
        
        Test.startTest();
            bulkEmail.taskCreationForAMAAmendEmailNotification(emailToAgreementMap, new List<Messaging.SingleEmailMessage>{email});
        Test.stopTest();
         
        List<Task> lstTask = [SELECT Id FROM Task LIMIT 1];
        System.assertNotEquals(0, lstTask.size(), 'The task must be created');
    }
    
    @isTest
    private static void testAmendEmailNotification() {
        Apttus__APTS_Agreement__c agreement = [SELECT Id FROM Apttus__APTS_Agreement__c LIMIT 1];
        String query = 'SELECT Apttus__Primary_Contact__c, Apttus__Primary_Contact__r.Email, Id, Agreement_Year_Plus_One__c, Agreement_Year__c, Apttus__Subtype__c, '
            +'Record_Based_Cost__c, Number_Of_Records__c, Sales_Rep_Cost__c, Sales_Rep_Count__c, Apttus__Total_Contract_Value__c, Proration_Type__c FROM Apttus__APTS_Agreement__c'
            +' WHERE RecordTypeId = \'' + CON_CLM.AMA_RECORDTYPEID +'\' AND Apttus__Status_Category__c =\'In Effect\' AND Apttus__Status__c = \'Activated\' AND Apttus__Auto_Renewal__c = true'; 
        BCH_CLM_AMA_AmendEmailNotification bulkEmail = new BCH_CLM_AMA_AmendEmailNotification(query);
        
        Test.startTest();
            Database.executeBatch(bulkEmail, 30);
        Test.stopTest();
        
        List<Task> lstTask = [SELECT Id FROM Task WHERE WhatId =: agreement.Id];
        System.assertNotEquals(0, lstTask.size(), 'The task should be created');
    }
}