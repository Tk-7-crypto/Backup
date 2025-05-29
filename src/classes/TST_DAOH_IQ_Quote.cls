@IsTest
public class TST_DAOH_IQ_Quote {
    @testSetup
    static void dataSetup() {
        List<Account> accounts = new List<Account>();
        Account acc1 = UTL_TestData.createAccount();
        acc1.AccountCountry__c = CON_CPQ.AL;
        acc1.MDMID__c = 'test1';
        accounts.add(acc1);

        Account acc = UTL_TestData.createAccount();
        acc.AccountCountry__c = 'AF';
        acc.MDMID__c = 'test2';
        accounts.add(acc);
        insert accounts;
       
        Opportunity testOpportunity= UTL_TestData.createOpportunity(accounts[1].Id);
        insert testOpportunity;
        
        Apttus_Config2__PriceList__c pl = TST_TestGeneratorClass.buildTestPriceList('DPS - USD');
        pl.CurrencyIsoCode = CON_CPQ.USD;
        insert pl;

        Quote__c quote = UTL_TestData.createIqviaQuote(accounts[1].Id, testOpportunity.Id, null, CON_CPQ.Complete_Consent, CON_CPQ.GBU_DPS, false);
        quote.CurrencyIsoCode = CON_CPQ.USD;
        insert quote;

        Quote_Requisites__c qr1 = UTL_TestData.createQuoteRequisites(quote.Id, CON_CPQ.COUNTRY_INPUT, true);
        
        Id recordTypeId  = UTL_TestData.getProposalRecordtypeId(CON_CPQ.TECH_SOLUTION);
       
        Apttus_Proposal__Proposal__c budget = UTL_TestData.createProposalData(accounts[1].Id, testOpportunity.Id, quote.Id, recordTypeId, CON_CPQ.Complete_Consent, null, false);
        budget.Apttus_QPConfig__PriceListId__c = pl.Id;
        budget.CurrencyIsoCode = CON_CPQ.USD;
        insert budget;

        List<Currency_Exchange_Rates__c> currencyRateList = new List<Currency_Exchange_Rates__c>();
        Currency_Exchange_Rates__c currencyRate = UTL_TestData.getCurrencyExchangeRate(false);
        currencyRate.Conversion_rate__c = 0.9281;
        currencyRate.Iso_Code__c = CON_CPQ.USD;
        currencyRateList.add(currencyRate);
        Currency_Exchange_Rates__c currencyRate1 = UTL_TestData.getCurrencyExchangeRate(false);
        currencyRate1.Conversion_rate__c = 1.9281;
        currencyRate1.Iso_Code__c = 'EGP';
        currencyRateList.add(currencyRate1);
        insert currencyRateList;
        
        Id userId = userInfo.getUserId();
        
        List<Approval_Matrix__c> approvalMatrixList = new List<Approval_Matrix__c>();
        Approval_Matrix__c approvalMatrix = new Approval_Matrix__c(
            Object_Name__c = 'Quote__c',
            levels__c = 'Level 1',
            priority__c = 1,
            Min_Amount__c = 200,
            Approver_1__c = userId,
            Approver_2__c = userId,
            Approver_3__c = userId,
            Approver_4__c = userId,
            Approver_5__c = userId,
            Notifier_1__c = 'test@gmail.com',
            Notifier_2__c = 'test@gmail.com',
            Notifier_3__c = 'test@gmail.com',
            Notifier_4__c = 'test@gmail.com',
            Notifier_5__c = 'test@gmail.com',
            Approve_On_First_Response__c = false,
            Auto_Approve__c = false,
            Track_Name__c = CON_CPQ.CPQ,
            Process_Type__c = CON_CPQ.APPROVAL_PROCESS
        );
        approvalMatrixList.add(approvalMatrix);
        
        Approval_Matrix__c approvalMatrix2 = new Approval_Matrix__c(
            Object_Name__c = 'Quote__c',
            levels__c = 'Level 1',
            priority__c = 2,
            Min_Amount__c = 200,
            Notifier_1__c = 'test@gmail.com',
            Notifier_2__c = 'test@gmail.com',
            Notifier_3__c = 'test@gmail.com',
            Notifier_4__c = 'test@gmail.com',
            Notifier_5__c = 'test@gmail.com',
            Approve_On_First_Response__c = false,
            Auto_Approve__c = true,
            Track_Name__c = CON_CPQ.CPQ,
            Process_Type__c = CON_CPQ.APPROVAL_PROCESS
        );
        approvalMatrixList.add(approvalMatrix2);
        
        Approval_Matrix__c approvalMatrix3 = new Approval_Matrix__c(
            Object_Name__c = 'Quote__c',
            levels__c = 'Level 2',
            priority__c = 3,
            Min_Amount__c = 200,
            Approver_1__c = userId,
            Approver_2__c = userId,
            Approver_3__c = userId,
            Approver_4__c = userId,
            Approver_5__c = userId,
            Notifier_1__c = 'test@gmail.com',
            Notifier_2__c = 'test@gmail.com',
            Notifier_3__c = 'test@gmail.com',
            Notifier_4__c = 'test@gmail.com',
            Notifier_5__c = 'test@gmail.com',
            Approve_On_First_Response__c = false,
            Auto_Approve__c = false,
            Track_Name__c = CON_CPQ.CPQ,
            Process_Type__c = CON_CPQ.APPROVAL_PROCESS
        );
        approvalMatrixList.add(approvalMatrix3);
        
        insert approvalMatrixList;
		
        CPQ_Proposal_Create_Settings__c customSettingsObjforDPS = UTL_TestData.createCPQProposalCreateSettings(CON_CPQ.Complete_Consent, 'CPQ_RDS_DPS_ReadWrite', CON_CPQ.Complete_Consent , true, 'DPS - USD', false);
        customSettingsObjforDPS.Conga_Setup__c = true;
        customSettingsObjforDPS.FX_Rate_Type__c = CON_CPQ.MONTHLY;
        insert customSettingsObjforDPS;
        
        CPQ_Settings__c cus1 =  new CPQ_Settings__c();
        cus1.Name =  CON_CPQ.NAMESPACE_PREFIX;
        cus1.Package_Namespace_Prefix__c = CON_CPQ.CONGA_PACKAGE_NAMESPACE_PREFIX;
        insert cus1;
        
        Product2 prod = TST_TestGeneratorClass.buildTestProduct('COMPLETE CONSENT LICENSES', CON_CPQ.BUNDLE, 'US_DD_STUDLIC', '', '');       
        prod.CanUseRevenueSchedule = true;
        prod.Billing_System__c = CON_CPQ.SAP;
        insert prod;
        
        Quote_Line_Item__c testQLI = UTL_TestData.createIqviaQuoteLineItem(quote.Id, CON_CPQ.COMPLETE_CONSENT, false);
        testQLI.Bundle_Product__c = prod.Id;
        testQLI.Country__c = CON_CPQ.USA;
        testQLI.Pathway__c = CON_CPQ.CONGA_PATHWAY;
        testQLI.Start_Date__c = Date.today();
        testQLI.End_Date__c = Date.Today().addMonths(3);
        testQLI.BasePrice__c = 100;
        testQLI.Discount_Amount__c = 10;
        testQLI.CurrencyIsoCode = CON_CPQ.USD;
        testQLI.Include_In_Summary__c = true;
        insert testQLI;
    }
    
    @IsTest
    static void testSetCurrency (){
        Quote__c quote = [SELECT Id, CurrencyIsoCode FROM Quote__c LIMIT 1];
        Apttus_Config2__PriceList__c pl2 = TST_TestGeneratorClass.buildTestPriceList('DPS - EGP');
        pl2.Migration_Id__c = 'PL-13';
        insert pl2;
        
        Test.startTest();
            quote.CurrencyIsoCode = 'EGP';
            update quote;
        Test.stopTest();
         
        Apttus_Proposal__Proposal__c proposal1 = [SELECT Id, IQVIA_Quote__c, CurrencyIsoCode, Apttus_QPConfig__PriceListId__c FROM Apttus_Proposal__Proposal__c WHERE IQVIA_Quote__c =:quote.Id  LIMIT 1];
        System.assertEquals(pl2.Id, proposal1.Apttus_QPConfig__PriceListId__c, 'Currency should be updated.');
    }

    @IsTest
    static void testUpdateIterationOnQuote (){
        Quote__c quote = [SELECT Id, Scenario__c FROM Quote__c LIMIT 1];
        
        Test.startTest();
            quote.Scenario__c = 1;
            update quote;
        Test.stopTest();
         
        Quote__c updatedQuote = [SELECT Id, Iteration__c FROM Quote__c WHERE Id =:quote.Id LIMIT 1];
        System.assertEquals('1.1', updatedQuote.Iteration__c, 'The desired result should be 1.1');
    }
    
    @IsTest
    static void testConversionRate () {
        Quote__c quote = [SELECT Id, CurrencyIsoCode FROM Quote__c LIMIT 1];
        
        Test.startTest();
            quote.CurrencyIsoCode = 'USD';
            update quote;
        Test.stopTest();
        
        Quote__c updatedQuote = [SELECT Id, Conversion_Rate__c FROM Quote__c WHERE Id =:quote.Id LIMIT 1];
        System.assertEquals(1.00, updatedQuote.Conversion_Rate__c, 'The desired result should be 1.00');  
    }

    @isTest
    static void testSetSharing(){
        Account acc = [SELECT Id, AccountCountry__c FROM Account LIMIT 1];
        Quote__c quote = [SELECT Id, CurrencyIsoCode FROM Quote__c LIMIT 1];
        
        Test.startTest();
            quote.Related_Account__c = acc.Id;
            update quote;
        Test.stopTest();
    }
    
    @isTest
    static void testSetAccountCountry(){
        Account acc = [SELECT Id, AccountCountry__c FROM Account LIMIT 1];
        Quote__c quote = [SELECT Id, CurrencyIsoCode FROM Quote__c LIMIT 1];
        
        Test.startTest();
            quote.Related_Account__c = acc.Id;
            update quote;
        Test.stopTest();

        Quote__c result = [SELECT Id, Account_Country__c FROM Quote__c WHERE Id = :quote.Id LIMIT 1];
        System.assertEquals(acc.AccountCountry__c, result.Account_Country__c, 'The desired result should be '+ acc.AccountCountry__c);
    }
    
    @isTest
    static void testSetLastSharingCalculationTimestamp(){
        Account acc = [SELECT Id, AccountCountry__c FROM Account WHERE AccountCountry__c = 'AL' LIMIT 1];
        Quote__c quote = [SELECT Id, CurrencyIsoCode FROM Quote__c LIMIT 1];
        
        Test.startTest();
            quote.Related_Account__c = acc.Id;
            update quote;
        Test.stopTest();
        
        Quote__c result = [SELECT Id, Last_Sharing_Calculation_Timestamp__c FROM Quote__c WHERE Id = :quote.Id LIMIT 1];
        Date expected = Date.today(); 
        DateTime dT = result.Last_Sharing_Calculation_Timestamp__c;
        Date actual = date.newinstance(dT.year(), dT.month(), dT.day());
        System.assertEquals(expected,actual, 'The desired result should be '+ expected);
    }
    
    @isTest
    static void testSetLastManualSharingFieldUpdate(){
        Account acc = [SELECT Id, AccountCountry__c FROM Account WHERE AccountCountry__c = 'AL' LIMIT 1];
        Quote__c quote = [SELECT Id, CurrencyIsoCode FROM Quote__c LIMIT 1];
        
        Test.startTest();
            quote.Related_Account__c = acc.Id;
            quote.Run_Sharing__c = true;
            update quote;
        Test.stopTest();

        Quote__c result = [SELECT Id, Last_Manual_Sharing_Execution__c FROM Quote__c WHERE Id = :quote.Id LIMIT 1];
        Date expected = Date.today(); 
        DateTime dT = result.Last_Manual_Sharing_Execution__c;
        Date actual = date.newinstance(dT.year(), dT.month(), dT.day());
        System.assertEquals(expected,actual, 'The desired result should be '+ expected);
    }
    
    
    @isTest
    static void testSetTotolICFDocuments() {
        Quote__c quote = [SELECT Id, CurrencyIsoCode FROM Quote__c LIMIT 1];
        
        Test.startTest();
            quote.ICFs__c = 10;
            update quote;
        Test.stopTest();
        
        Quote__c result = [SELECT Id, Total_ICF_Documents__c FROM Quote__c WHERE Id = :quote.Id];
        Assert.isNotNull(result.Total_ICF_Documents__c, 'Total_ICF_Documents__c should not be null');
    }

    @isTest
    static void testsetDefaults() {
        Quote__c quote = [SELECT Id, CurrencyIsoCode, Pricing_Tools__c, Sponsor_Tablets__c, No_of_Countries__c, Enrollment_Period__c, Patient_Videos__c, Participant_Comprehension_Quizzes__c, Webinars__c, Site_Tablets__c, Amendments_to_ICF_Documents__c, Study_Duration__c, Total_ICF_Documents__c, Patient_Education_Glossary_Definitions__c, On_Site_Training_Days__c, Languages__c, Amendments_to_Patient_Videos__c, Adjusted_Languages__c FROM Quote__c LIMIT 1];
        quote.Sponsor_Tablets__c = null;
        quote.No_of_Countries__c = null;
        quote.Enrollment_Period__c = null;
        quote.Patient_Videos__c = null;
        quote.Participant_Comprehension_Quizzes__c = null;
        quote.Webinars__c = null;
        quote.Site_Tablets__c = null;
        quote.Amendments_to_ICF_Documents__c = null;
        quote.Study_Duration__c = null;
        quote.Total_ICF_Documents__c = null;
        quote.Patient_Education_Glossary_Definitions__c = null;
        quote.On_Site_Training_Days__c = null;
        quote.Languages__c = null;
        quote.Amendments_to_Patient_Videos__c = null;
        quote.Adjusted_Languages__c = null;
        quote.CurrencyIsoCode = CON_CPQ.USD;
        quote.Pricing_Tools__c = CON_CPQ.Complete_Consent;
        Update quote;
        quote = [SELECT Id, CurrencyIsoCode, Pricing_Tools__c, Sponsor_Tablets__c, No_of_Countries__c, Enrollment_Period__c, Patient_Videos__c, Participant_Comprehension_Quizzes__c, Webinars__c, Site_Tablets__c, Amendments_to_ICF_Documents__c, Study_Duration__c, Total_ICF_Documents__c, Patient_Education_Glossary_Definitions__c, On_Site_Training_Days__c, Languages__c, Amendments_to_Patient_Videos__c, Adjusted_Languages__c FROM Quote__c WHERE Id = :quote.Id];
        System.assertEquals(0, quote.Sponsor_Tablets__c, 'Sponsor_Tablets__c should be 0');
        System.assertEquals(0, quote.No_of_Countries__c, 'No_of_Countries__c should be 0');
        System.assertEquals(0, quote.Enrollment_Period__c, 'Enrollment_Period__c should be 0');
        System.assertEquals(0, quote.Patient_Videos__c, 'Patient_Videos__c should be 0');
        System.assertEquals(0, quote.Participant_Comprehension_Quizzes__c, 'Participant_Comprehension_Quizzes__c should be 0');
        System.assertEquals(0, quote.Webinars__c, 'Webinars__c should be 0');
        System.assertEquals(0, quote.Site_Tablets__c, 'Site_Tablets__c should be 0');
        System.assertEquals(0, quote.Amendments_to_ICF_Documents__c, 'Amendments_to_ICF_Documents__c should be 0');
        System.assertEquals(0, quote.Study_Duration__c, 'Study_Duration__c should be 0');
        System.assertEquals(0, quote.Total_ICF_Documents__c, 'Total_ICF_Documents__c should be 0');
        System.assertEquals(0, quote.Patient_Education_Glossary_Definitions__c, 'Patient_Education_Glossary_Definitions__c should be 0');
        System.assertEquals(0, quote.On_Site_Training_Days__c, 'On_Site_Training_Days__c should be 0');
        System.assertEquals(0, quote.Languages__c, 'Languages__c should be 0');
        System.assertEquals(0, quote.Amendments_to_Patient_Videos__c, 'Amendments_to_Patient_Videos__c should be 0');
        System.assertEquals(0, quote.Adjusted_Languages__c, 'Adjusted_Languages__c should be 0');
    }
    @isTest
    static void testQuoteApprovalProcess() {
        Quote__c quote = [SELECT Id, CurrencyIsoCode FROM Quote__c LIMIT 1];
        Test.startTest();
            quote.Approval_Stage__c = 'Finalized';
            update quote;
        Test.stopTest();
    }
    @isTest
    static void testSetApprovalStage() {
        Quote__c quote = [SELECT Id,GBU__c,Status__c,Approval_Stage__c FROM Quote__c LIMIT 1];
        quote.GBU__c = CON_CPQ.GBU_RDS_NON_SF_WRF;
        quote.Quote_Type__c = CON_CPQ.CNF;
        quote.Status__c = CON_CPQ.STATUS_IN_PROGRESS;
        Test.startTest();
        update quote;
        Quote__c quoteRes = [SELECT Id,Approval_Stage__c,GBU__c,Quote_Type__c FROM Quote__c Where GBU__c = :CON_CPQ.GBU_RDS_NON_SF_WRF AND Quote_Type__c = :CON_CPQ.CNF LIMIT 1];
        System.assertEquals(CON_CPQ.DRAFT, quoteRes.Approval_Stage__c, 'Approval_Stage__c should be Draft');
        
        quote.Status__c = CON_CPQ.STATUS_EXECUTED;
        quote.Approval_Rejected_Completed_Date__c = system.today();
        update quote;
        Quote__c quoteRes1 = [SELECT Id,Approval_Stage__c FROM Quote__c Where GBU__c = :CON_CPQ.GBU_RDS_NON_SF_WRF AND Quote_Type__c = :CON_CPQ.CNF LIMIT 1];
        System.assertEquals(CON_CPQ.ACCEPTED, quoteRes1.Approval_Stage__c, 'Approval_Stage__c should be Accepted');

        quote.Status__c = CON_CPQ.ON_HOLD;
        quote.Approval_Rejected_Completed_Date__c = null;
        update quote;
        Quote__c quoteRes2 = [SELECT Id,Approval_Stage__c FROM Quote__c Where GBU__c = :CON_CPQ.GBU_RDS_NON_SF_WRF AND Quote_Type__c = :CON_CPQ.CNF LIMIT 1];
        System.assertEquals(CON_CPQ.DRAFT, quoteRes2.Approval_Stage__c, 'Approval_Stage__c should be Draft');

        try {
            quote.Status__c = CON_CPQ.REJECTED_STATUS;
            update quote;
        } catch(Exception e) {
            Boolean expectedExceptionThrown =  (e.getMessage().contains(CON_CPQ.ERROR_MSG_FOR_STATUS_REJECTED)) ? true : false; 
            System.AssertEquals(true, expectedExceptionThrown, e.getMessage());
        }
        quote.Status__c = CON_CPQ.REJECTED_STATUS;
        quote.Approval_Rejected_Completed_Date__c = system.today();
        update quote;
        Quote__c quoteRes3 = [SELECT Id,Approval_Stage__c FROM Quote__c Where GBU__c = :CON_CPQ.GBU_RDS_NON_SF_WRF AND Quote_Type__c = :CON_CPQ.CNF LIMIT 1];
        System.assertEquals(CON_CPQ.CANCELLED_STATUS, quoteRes3.Approval_Stage__c, 'Approval_Stage__c should be Cancelled');
        Test.stopTest();
    }
}