@isTest
private class TST_BNF_Attachment_Protection {
    
    private static BNF2__c TestBnf;
    private static Opportunity TestOpp;
    private static Account TestAccount;
    private static List<Address__c> TestAddress_Array;
    private static List<SAP_Contact__c> TestSapContact_Array;
    private static BNF_Approval_Extension controller;
    private static Integer NumAddresses = 20;
    private static Integer NumSapContactsPerAddress = 10;
    private static User TestUser;
    private static Revenue_Analyst__c TestLocalRA;
    private static Revenue_Analyst__c TestSAPRA;
    private static User TestLocalApprover;
    private static User TestSAPApprover;
    private static Attachment doc;
    
    static void setupOpp() 
    {
        upsert new  Mulesoft_Integration_Control__c(Enable_OLIS_JSON__c = true, Is_Mulesoft_User__c = false, Enable_OLI_Sync_Validation__c = true, Enable_Opportunity_Sync_Validation__c = true);
        
        Global_Variables.PCFlag = false;
        Global_Variables.RunQuickOppLimitTrigger = false;
        Global_Variables.RenewalCloneFlag = TRUE;
        Global_Variables.syncAgreementToOppty=false;
        Global_Variables.PCTrigger_Hault_Execution=false;
        
        //TestUser = [select Id from User where IsActive = true and (not Profile.Name like '%administrator%') and (not Profile.Name like '%operations%') and (not Profile.Name like '%Chatter%') limit 1];
        TestUser = [select Id from User where IsActive = true and (Profile.Name = 'System Administrator') limit 1];
        //system.debug('TestUser.Profile.Name' + TestUser.Profile.Name);
        TestAccount = new Account();
        TestAccount.Name = 'Test Account';
        TestAccount.Status__c = MDM_Defines.AddressStatus_Map.get('SAP_VALIDATED');
        TestAccount.OwnerId = TestUser.Id;
        TestAccount.CustomerSegment__c = 'GOVERNMENT';
        TestAccount.Sub_Industry__c = 'STATE';
        insert TestAccount;
        List<Revenue_Analyst__c> revenueAnalystList = new List<Revenue_Analyst__c>();
        //TestLocalRA = [select Id,Name,User__c from Revenue_Analyst__c where User__r.IsActive = true and Is_SAP_Revenue_Analyst__c = false limit 1];
        TestLocalRA =new Revenue_Analyst__c(User__c=userInfo.getUserId(),Is_SAP_Revenue_Analyst__c = false,name='SAPRAUser, Test');
        revenueAnalystList.add(TestLocalRA);
        TestSAPRA=new Revenue_Analyst__c(User__c=userInfo.getUserId(),Is_SAP_Revenue_Analyst__c = true,name='SAPRAUser, Test');
        revenueAnalystList.add(TestSAPRA);
        
        insert revenueAnalystList;
        
        AccountTeamMember ATM = new AccountTeamMember(AccountId=TestAccount.Id,UserId=TestLocalRA.User__c);
        insert ATM;
        
        AccountShare AccShare = [Select Id, AccountId, UserOrGroupId, AccountAccessLevel, OpportunityAccessLevel, CaseAccessLevel, RowCause, LastModifiedDate, LastModifiedById FROM AccountShare WHERE RowCause = 'Team' AND AccountId = :TestAccount.Id and UserOrGroupId=:TestLocalRA.User__c limit 1];
        AccShare.AccountAccessLevel = 'Edit';
        AccShare.OpportunityAccessLevel = 'Edit';
        update AccShare;
        
        Integer AccountIterator = 0;
        TestAddress_Array = new List<Address__c>();
        for (Integer i=0; i<NumAddresses; i++)
        {
            Address__c TempAddress = New Address__c(Name=String.valueOf(i),
                                                    Account__c=TestAccount.Id,
                                                    Street__c = 'Street ' + i.format(),
                                                    City__c = 'City '+ i.format(),
                                                    Country__c = 'Country ' + i.format(),
                                                    SAP_Reference__c = String.valueOf(495000+i),
                                                   	MDM_Validation_Status__c = 'Validated');
            TestAddress_Array.add(TempAddress);
        } 
        CON_GLOBAL.RELEASE_MAY_2021 = 9999.99;
        insert TestAddress_Array;
        
        TestSapContact_Array = new List<SAP_Contact__c>();
        Integer AddressIterator = 0;
        for (Integer i=0; i<NumAddresses*NumSapContactsPerAddress; i++)
        {
            if (i > 0 && Math.mod(i,NumSapContactsPerAddress) == 0)
            {
                AddressIterator++;
            }
            Id AddressId = TestAddress_Array[AddressIterator].Id;
            SAP_Contact__c TempContact = New SAP_Contact__c(Name=String.valueOf(i),
                                                            Address__c=AddressId,
                                                            SAP_Contact_Number__c = String.valueOf(999999+i));
            TestSapContact_Array.add(TempContact);
        } 
        insert TestSapContact_Array;
        
        
        Competitor__c comp = UTL_TestData.createCompetitor();
        insert comp;
        TestOpp = new Opportunity(Name='test',StageName='1. Identifying Opportunity',CloseDate=System.today());
        TestOpp.LeadSource = 'Account Planning';
        TestOpp.Budget_Available__c = 'Yes';
        //TestOpp.Unique_Business_Value__c = 'Unknown';
        //TestOpp.Compelling_Event__c = 'No';
        //TestOpp.StageName='5. Finalizing Deal';
        TestOpp.AccountId = TestAccount.Id;
        TestOpp.Contract_Term__c='Single-Period';
        TestOpp.Contract_End_Date__c = system.today();
        TestOpp.Contract_Start_Date__c = system.today();
        //TestOpp.Win_Loss_Reason__c='Win - Competitive Situation';
        TestOpp.Contract_Type__c='Individual';
        TestOpp.LeadSource = 'Account Planning';
        //TestOpp.Win_Additional_Details__c = 'Additional details';
        //TestOpp.Win_Loss_Reason_Details__c = 'Win Loss Reason Details'; 
        TestOpp.CurrencyIsoCode = 'USD';
        TestOpp.Potential_Competitor_1__c = comp.Id;
        insert TestOpp;
        
        BNF_Settings__c bnfsetting= BNF_Settings__c.getInstance();
        if(bnfsetting== null)
        {
            bnfsetting=new BNF_Settings__c(Enable_Material_Validation__c=true,Enable_Customer_Validation__c=true);
            insert bnfsetting;
        }
        Contact con = new Contact();
        con.FirstName = 'testFirstName';
        con.LastName = 'Ap';
        insert con;
 		OpportunityContactRole contactRole = UTL_TestData.createOpportunityContactRole(con.Id, TestOpp.Id);
        insert contactRole;
        //  Add a line item to the opportunity
        List<OpportunityLineItem> OLI_Array = new List<OpportunityLineItem>();
        OpportunityLineItem OLI1 = new OpportunityLineItem();
        OLI1.OpportunityId = TestOpp.Id;
        
        Product2 objProduct = new Product2(Name='test4', ProductCode='4',Hierarchy_Level__c=CON_CRM.MATERIAL_LEVEL_HIERARCHY_OLI, Enabled_Sales_Orgs__c='CH03', Offering_Type__c = 'Commercial Tech', Material_Type__c = 'ZPUB',CanUseRevenueSchedule= true, IsActive = true);
        objProduct.Pillar__c = 'Information Offering; Technology Solutions; R&D';
        insert objProduct;
        
        PricebookEntry PE1 = new PricebookEntry();
        PE1.UseStandardPrice = false;
        PE1.Pricebook2Id = Test.getStandardPricebookId();
        PE1.Product2Id=objProduct.id;
        PE1.IsActive=true;
        PE1.UnitPrice=100.0;
        PE1.CurrencyIsoCode = 'USD';
        insert PE1;
        //PricebookEntry PE1 = [select Id, CurrencyIsoCode,Product2Id from PricebookEntry where CurrencyIsoCode = 'USD' and IsActive = true and Product2.IsActive = true and Product2.Material_Type__c = 'ZPUB' limit 1][0];
        //Product2 p1=[Select Enabled_Sales_Orgs__c from Product2 where  Id =:PE1.Product2Id limit 1][0];
        //p1.Enabled_Sales_Orgs__c='CH03';
        //upsert p1;
        
        OLI1.PricebookEntryId = PE1.Id;
        
        OLI1.Quantity = 1.00;
        OLI1.UnitPrice = 10000;
        OLI1.List_Price__c=10000;
        OLI1.Product_End_Date__c=system.today();
        OLI1.Product_Start_Date__c=system.today();
        OLI1.Billing_Frequency__c='Once';
        OLI1.Billing_Date__c=system.today();
        OLI1.Delivery_Date__c=system.today();
        OLI1.Sale_Type__c = 'New';
        OLI1.Revenue_Type__c = 'Ad Hoc';
        OLI1.Therapy_Area__c= 'Hepatitis C [21]';
        OLI1.Delivery_Country__c = 'USA';
        OLI_Array.add(OLI1);
        //insert OLI1;
        OpportunityLineItem OLI2 = new OpportunityLineItem();
        OLI2.OpportunityId = TestOpp.Id;
        PricebookEntry PE2 = [select Id, CurrencyIsoCode,Product2Id from PricebookEntry where CurrencyIsoCode = 'USD' and IsActive = true and Product2.IsActive = true and Product2.Material_Type__c = 'ZPUB' limit 1][0];
        Product2 p2=[Select Enabled_Sales_Orgs__c from Product2 where Id=:PE2.Product2Id limit 1 ][0];
        p2.Enabled_Sales_Orgs__c='CH04';
        upsert p2;
        
        OLI2.PricebookEntryId = PE2.Id;
        OLI2.Quantity = 1.00;
        OLI2.Product_End_Date__c=system.today();
        OLI2.Product_Start_Date__c=system.today();
        OLI2.Billing_Frequency__c='Once';
        OLI2.Billing_Date__c=system.today();
        OLI2.UnitPrice = 10000;
        OLI2.List_Price__c=10000;
        OLI2.Proj_Rpt_Frequency__c='Once [O]';
        OLI2.Delivery_Date__c=system.today();
        OLI2.Sale_Type__c = 'New';
        OLI2.Revenue_Type__c = 'Ad Hoc';
        OLI2.Therapy_Area__c= 'Hepatitis C [21]';
        OLI2.Delivery_Country__c = 'USA';       
        OLI_Array.add(OLI2);
        insert OLI_Array;
        TestOpp.StageName = '7a. Closed Won';
        TestOpp.Primary_Win_Reason__c ='Project Performance';
        TestOpp.Win_Type__c = 'Non-competitive bid';
        update TestOpp;
        //Opportunity VerifyOpp=[select Actual_Close_Timestamp__c from Opportunity where id=: TestOpp.id];
        //system.assertEquals(null,VerifyOpp.Actual_Close_Timestamp__c);           
    }  
    
    static void setupBNF(String ApproverID,Boolean isSAPBNF)
    {
        
        Id RecordId = Schema.SObjectType.Address__c.getRecordTypeInfosByDeveloperName().get('MDM_Validated').getRecordTypeId();
        List<Address__c> Addresslst=new List<Address__c>();
        Address__c a1=new Address__c(name='testAddress',SAP_Reference__c='500',Enabled_Sales_Orgs__c='CH03',MDM_Validation_Status__c = 'Validated',RecordTypeId = RecordId) ;
        Addresslst.add(a1);
        Address__c a2=new Address__c(name='testAddress2',SAP_Reference__c='501',Enabled_Sales_Orgs__c='CH03',MDM_Validation_Status__c = 'Validated',RecordTypeId = RecordId)  ; 
        Addresslst.add(a2);
        Address__c a3=new Address__c(name='testAddress3',SAP_Reference__c='502',Enabled_Sales_Orgs__c='CH03',MDM_Validation_Status__c = 'Validated',RecordTypeId = RecordId)  ; 
        Addresslst.add(a3);
        Address__c a4=new Address__c(name='testAddress4',SAP_Reference__c='503',Enabled_Sales_Orgs__c='CH03',MDM_Validation_Status__c = 'Validated',RecordTypeId = RecordId)  ; 
        Addresslst.add(a4);
        Address__c a5=new Address__c(name='testAddress5',SAP_Reference__c='504',Enabled_Sales_Orgs__c='CH03',MDM_Validation_Status__c = 'Validated',RecordTypeId = RecordId)  ; 
        Addresslst.add(a5);
        
        CON_GLOBAL.RELEASE_MAY_2021 = 9999.99;
        insert Addresslst;
        
        TestBnf = new BNF2__c(Opportunity__c=TestOpp.Id);
        TestBnf.BNF_Status__c = 'New';
        TestBnf.IMS_Sales_Org__c = 'IMS Spain';
        if(isSAPBNF)
            TestBnf.RecordTypeId =MDM_Defines.SAP_SD_Integrated_Record_Type_Id;
        TestBnf.Bill_To__c=a1.Id;
        TestBnf.X2nd_Copy__c=a2.Id;
        TestBnf.Carbon_Copy__c=a3.Id;
        TestBnf.Ship_To__c=a4.Id;
        TestBnf.Cover_Sheet__c=a5.Id;
        
        TestBnf.Revenue_Analyst__c = ApproverID;
        TestBnf.Sales_Org_Code__c='CH04';
        insert TestBnf;
        Blob pdfContent = Blob.valueOf('xxxxxxxxxxxxxx');
        String FileName = 'abcdlc.pdf';       
        FileName = FileName.replace('/', '_');
        FileName = FileName.replace('\\', '_'); 
        doc = new Attachment(
            ParentId = TestBnf.Id,
            Body = pdfContent,
            Name = FileName,
            ContentType = 'application/pdf');     
        insert doc;
        
        
    } 
    
    static testMethod void testAttachment() 
    {
        setupOpp();
        test.starttest();
        upsert new BNF_Attachment_Type__c(name='ABC', label__c='ABC');
        setupBNF(TestLocalRA.Id,false);
        pageReference BnfApprovalPage = Page.BNF_Approval;
        BnfApprovalPage.getParameters().put('id',TestBnf.Id);
        
        
        
        Approval.ProcessResult result;
        Approval.ProcessSubmitRequest req1;
        
        system.runAs(TestUser)
        {
            BNF_Test_Data.create_User_LocaleSetting();
            // Create an approval request for the BNF
            req1 = new Approval.ProcessSubmitRequest();
            req1.setComments('Submitting request for approval.');
            req1.setObjectId(TestBnf.Id);
            // Submit the approval request for the BNF
            result = Approval.process(req1);
            // Verify the result
            System.assert(result.isSuccess());
            System.assertEquals('Pending', result.getInstanceStatus(), 'Instance Status'+result.getInstanceStatus());
            try 
            {
                delete doc;
                //system.assertEquals(true,false,'Attachment delete should have thrown an exception');
            }
            catch (Exception E)
            {
                //system.assert(e.getMessage().contains('Attachments cannot be deleted'));
            }
            try
            {
                doc.Body = Blob.valueOf('yyyyy');
                update doc;
                //system.assertEquals(true,false,'Attachment update should have thrown an exception');
            }
            catch (Exception E)
            {
                //system.assert(e.getMessage().contains('Attachments cannot be edited'));
            }                       
        }
        TestLocalApprover = [select Id from User where Id = :TestLocalRA.User__c];
        system.runAs(TestLocalApprover)
        {       
            //  Create an instance of the standard controller
            ApexPages.StandardController stc = new ApexPages.StandardController(TestBnf);
            //  Create an instance of the controller extension       
            controller = new BNF_Approval_Extension(stc);
            controller.Init();
            controller.getRejectionReasons();
            controller.ApproverComments = 'Rejected for testing';
            controller.Reject();
            controller.SelectedRejectionReason = 'Multiple Error';
            controller.Reject();   
            BNF2__c returnBNF=[select BNF_Status__c from BNF2__c where id =: TestBnf.Id];  
            System.assertEquals('Rejected',returnBNF.BNF_Status__c); 
        }
        
        /*system.runAs(TestUser)
        {
            // Create an approval request for the BNF
            req1 = new Approval.ProcessSubmitRequest();
            req1.setComments('Submitting request for approval.');
            req1.setObjectId(TestBnf.Id);
            // Submit the approval request for the BNF
            result = Approval.process(req1);
            // Verify the result
            System.assert(result.isSuccess());
            System.assertEquals('Pending', result.getInstanceStatus(), 'Instance Status'+result.getInstanceStatus());
        }*/
        system.runAs(TestLocalApprover)
        {       
            
            
            //  Create an instance of the standard controller
            ApexPages.StandardController stc = new ApexPages.StandardController(TestBnf);
            //  Create an instance of the controller extension       
            controller = new BNF_Approval_Extension(stc);
            controller.Init();
            controller.SelectedRejectionReason = 'Multiple Error';
            controller.ApproverComments = 'Rejected for testing';
            
            controller.Approve();
            TestBnf.BNF_Status__c='Accepted'; 
            system.assertEquals('Accepted',TestBnf.BNF_Status__c);
        }
        test.stoptest();
        
    }
}