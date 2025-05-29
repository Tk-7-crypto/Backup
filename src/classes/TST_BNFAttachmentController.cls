@isTest
public class TST_BNFAttachmentController{
   
    private static BNF2__c TestBnf;
    
    static void setupData(){
        Profile p = [select id from profile where name like '%sales%' limit 1];
        
        User u = new User(FirstName = 'Test' + System.now(),ProfileId = p.id, LastName = 'User' + System.now(),
                          alias ='testusr', Username = 'testusr1231231987'+Math.Random()+'@gmail.com', Email = 'testusr@iqvia.com', 
                          CommunityNickname = 'testusr.User', TimeZoneSidKey = 'Asia/Kolkata', LocaleSidKey = 'en_US', 
                          EmailEncodingKey = 'ISO-8859-1', LanguageLocaleKey = 'en_US', Change_Request_Description__c = 'test', Change_Request_Ticket_Number__c ='test description', employeeNumber= String.valueOf(System.currentTimeMillis()));
        insert u;
        
        Account NewAccount = new Account();
        NewAccount.Name = 'Test Account';
        NewAccount.OwnerId = u.Id;
        NewAccount.CustomerSegment__c = 'GOVERNMENT';
        NewAccount.Sub_Industry__c = 'STATE';
        insert NewAccount;
        
        Revenue_Analyst__c ra = new Revenue_Analyst__c(User__c = u.id);
        insert ra;
                
        //upsert new  PseSecurityConfig__c(DisableSecurityTriggers__c=true, DefaultOwnerUsername__c='integration@uk.imshealth.com.uat');
        upsert new BNF_Attachment_Type__c(name='ABC', label__c='ABC');
        
        Opportunity TestOpp = new Opportunity(Name='test',StageName='1 - Identify Opportunity',CloseDate=System.today());
        TestOpp.LeadSource = 'Account Planning';
        //TestOpp.Budget_Available__c = 'Yes';
        //TestOpp.Unique_Business_Value__c = 'Unknown';
        //TestOpp.Compelling_Event__c = 'No';
        //TestOpp.StageName='5 - Negotiate Contract Ts & Cs';
        TestOpp.AccountId = NewAccount.Id;
        //TestOpp.Contract_Term__c='Single-Period';
        TestOpp.Contract_End_Date__c = system.today();
        TestOpp.Contract_Start_Date__c = system.today();
        //TestOpp.Win_Loss_Reason__c='Win - Competitive Situation';
        //TestOpp.Contract_Type__c='Individual';
        TestOpp.LeadSource = 'Account Planning';
        //TestOpp.Win_Additional_Details__c = 'Additional details';
        //TestOpp.Win_Loss_Reason_Details__c = 'Win Loss Reason Details'; 
        TestOpp.CurrencyIsoCode = 'USD';
        insert TestOpp;
        
        /*List<OpportunityLineItem> OLI_Array = new List<OpportunityLineItem> ();
        OpportunityLineItem OLI1 = new OpportunityLineItem();
        OLI1.OpportunityId = TestOpp.Id;
        PricebookEntry PE1 = [select Id, CurrencyIsoCode from PricebookEntry where CurrencyIsoCode = 'USD' and IsActive = true and Product2.IsActive = true and Product2.Material_Type__c = 'ZPUB' limit 1][0];
        OLI1.PricebookEntryId = PE1.Id;
        OLI1.Quantity = 1.00;
        OLI1.UnitPrice = 10000;
        OLI1.Delivery_Country__c = 'USA';
        OLI_Array.add(OLI1);
        //insert OLI1;
        OpportunityLineItem OLI2 = new OpportunityLineItem();
        OLI2.OpportunityId = TestOpp.Id;
        PricebookEntry PE2 = [select Id, CurrencyIsoCode from PricebookEntry where CurrencyIsoCode = 'USD' and IsActive = true and Product2.IsActive = true and Product2.Material_Type__c = 'ZPUB' limit 1][0];
        OLI2.PricebookEntryId = PE2.Id;
        OLI2.Quantity = 1.00;
        OLI2.UnitPrice = 10000;
        OLI2.Delivery_Country__c = 'USA';
        OLI_Array.add(OLI2);        
        insert OLI_Array;*/
        
        
        TestBnf = new BNF2__c(Opportunity__c=TestOpp.Id);
        TestBnf.BNF_Status__c = MDM_Defines.BnfStatus_Map.get('NEW');
        TestBnf.Sales_Org_Code__c = 'ES51';
        TestBnf.IMS_Sales_Org__c = 'IMS Spain';
        //TestBnf.RecordTypeId = MDM_Defines.SAP_SD_Integrated_Record_Type_Id;
        TestBnf.RecordTypeId  = Schema.SObjectType.BNF2__c.getRecordTypeInfosByName().get('SAP SD Integrated').getRecordTypeId();
        TestBnf.Revenue_Analyst__c = Ra.Id;
        insert TestBnf;
    }
    
    static testMethod void testSaveAttachment(){
        setupData();
        //BNFAttachmentController bController = new BNFAttachmentController(new ApexPages.StandardController(TestBnf));
        ApexPages.CurrentPage().getParameters().put('id',TestBnf.id);
        BNFAttachmentController bController = new BNFAttachmentController();
        bController.fileContent = Blob.valueOf('xxxxxxxx');
        bController.fileName = 'abc.txt';
        bController.filesize = 7;
        bController.selDocType = 'ABC';
        bController.save();
        
        List<Attachment> aList = [select id from Attachment where parentId =: TestBnf.id limit 1];
        system.assertEquals(True, aList != null && aList.size() == 1);
    }
    // updated by dheeraj kumar
    static testMethod void testSaveAttachmentNULL(){
        setupData();
        //BNFAttachmentController bController = new BNFAttachmentController(new ApexPages.StandardController(TestBnf));
        BNFAttachmentController bController = new BNFAttachmentController();
        bController.save();
    }
}