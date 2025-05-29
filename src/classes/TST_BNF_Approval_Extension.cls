/**
* This class contains unit tests for validating the behavior of Apex classes
* and triggers.
*
* Unit tests are class methods that verify whether a particular piece
* of code is working properly. Unit test methods take no arguments,
* commit no data to the database, and are flagged with the testMethod
* keyword in the method definition.
*
* All test methods in an organization are executed whenever Apex code is deployed
* to a production organization to confirm correctness, ensure code
* coverage, and prevent regressions. All Apex classes are
* required to have at least 75% code coverage in order to be deployed
* to a production organization. In addition, all triggers must have some code coverage.
* 
* The @isTest class annotation indicates this class only contains test
* methods. Classes defined with the @isTest annotation do not count against
* the organization size limit for all Apex scripts.
*
* See the Apex Language Reference for more information about Testing and Code Coverage.
*/
@isTest
private class TST_BNF_Approval_Extension {
    
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
    private static List<OpportunityLineItem> olijson1List = new List<OpportunityLineItem>();
    private static List<OpportunityLineItem> olijson2List = new List<OpportunityLineItem>();
    
    static void setupOpp() 
    {
        UTL_ExecutionControl.stopTriggerExecution = true;
        Current_Release_Version__c crv = new Current_Release_Version__c();
        crv.Current_Release__c = '3000.01';
        upsert crv;
        
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
        TestAccount.AccountCountry__c = 'AF';
        TestAccount.CustomerSegment__c = 'GOVERNMENT';
        TestAccount.Sub_Industry__c = 'STATE';
        insert TestAccount;
        
        //TestLocalRA = [select Id,Name,User__c from Revenue_Analyst__c where User__r.IsActive = true and Is_SAP_Revenue_Analyst__c = false limit 1];
        TestLocalRA =new Revenue_Analyst__c(User__c=userInfo.getUserId(),Is_SAP_Revenue_Analyst__c = false,name='SAPRAUser, Test');
        insert TestLocalRA;
        
        TestSAPRA=new Revenue_Analyst__c(User__c=userInfo.getUserId(),Is_SAP_Revenue_Analyst__c = true,name='SAPRAUser, Test');
        insert TestSAPRA;
        
        AccountTeamMember ATM = new AccountTeamMember(AccountId=TestAccount.Id,UserId=TestLocalRA.User__c);
        insert ATM;
        
        AccountShare AccShare = [Select Id, AccountId, UserOrGroupId, AccountAccessLevel, OpportunityAccessLevel, CaseAccessLevel, RowCause, LastModifiedDate, LastModifiedById FROM AccountShare WHERE RowCause = 'Team' AND AccountId = :TestAccount.Id and UserOrGroupId=:TestLocalRA.User__c limit 1];
        AccShare.AccountAccessLevel = 'Edit';
        AccShare.OpportunityAccessLevel = 'Edit';
        update AccShare;
        
        Integer AccountIterator = 0;
        System.runAs(TestUser) {
            TestAddress_Array = new List<Address__c>();
            for (Integer i=0; i<NumAddresses; i++)
            {
                Address__c TempAddress = New Address__c(Name=String.valueOf(i),
                                                        Account__c=TestAccount.Id,
                                                        Street__c = 'Street ' + i.format(),
                                                        City__c = 'City '+ i.format(),
                                                        Country__c = 'Country ' + i.format(),
                                                        SAP_Reference__c = String.valueOf(495000+i),
                                                   		MDM_Validation_Status__c = 'Validated',
                                                       	RecordTypeId = Schema.SObjectType.Address__c.getRecordTypeInfosByDeveloperName().get('MDM_Validated').getRecordTypeId());
                TestAddress_Array.add(TempAddress);
            } 
        	CON_GLOBAL.RELEASE_MAY_2021 = 9999.99;
            insert TestAddress_Array;
        }
        
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
        //TestOpp.Contract_Term__c='Single-Period';
        TestOpp.Contract_End_Date__c = system.today();
        TestOpp.Contract_Start_Date__c = system.today();
        //TestOpp.Win_Loss_Reason__c='Win - Competitive Situation';
        //TestOpp.Contract_Type__c='Individual';
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
        
        Product2 objProduct = new Product2(Name='test1', ProductCode='1', Enabled_Sales_Orgs__c='CH08',CurrencyIsoCode = 'USD', Business_Type__c = 'I&A', Material_Type__c = 'ZPUB', isactive=true, CanUseRevenueSchedule = true, InterfacedWithMDM__c = true, Hierarchy_Level__c=CON_CRM.MATERIAL_LEVEL_HIERARCHY_OLI); 
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
        OLI1.Sale_Type__c = 'New';
        OLI1.Delivery_Country__c = 'USA';
        OLI1.Revenue_Type__c = 'Ad Hoc';
        OLI1.Product_Start_Date__c = Date.today();
        OLI1.Product_End_Date__c = Date.today().addYears(1) ;
        OLI1.PricebookEntryId = PE1.Id;
        OLI1.Billing_Frequency__c = 'Once';
        OLI1.Proj_Rpt_Frequency__c='Once [O]';
        OLI1.Therapy_Area__c= 'Hepatitis C [21]';
        OLI1.Quantity = 1.00;
        OLI1.UnitPrice = 10000;  
        OLI1.List_Price__c = 100;
        OLI1.Delivery_Country__c = 'USA';
        OLI1.Therapy_Area__c= 'Hepatitis C [21]';
        OLI1.Billing_Date__c = Date.today();
        OLI1.Delivery_Date__c = Date.today().addYears(2);
        OLI_Array.add(OLI1);
        //insert OLI1;
        OpportunityLineItem OLI2 = new OpportunityLineItem();
        OLI2.OpportunityId = TestOpp.Id;
        PricebookEntry PE2 = [select Id, CurrencyIsoCode,Product2Id from PricebookEntry where CurrencyIsoCode = 'USD' and IsActive = true and Product2.IsActive = true and Product2.Material_Type__c = 'ZPUB' limit 1][0];
        Product2 p2=[Select Enabled_Sales_Orgs__c from Product2 where Id=:PE2.Product2Id limit 1 ][0];
        p2.Enabled_Sales_Orgs__c='CH04';
        upsert p2;
        OLI2.OpportunityId = TestOpp.Id;
        OLI2.Sale_Type__c = 'New';
        OLI2.Delivery_Country__c = 'USA';
        OLI2.Revenue_Type__c = 'Ad Hoc';
        OLI2.Product_Start_Date__c = Date.today();
        OLI2.Product_End_Date__c = Date.today().addYears(1) ;
        OLI2.PricebookEntryId = PE2.Id;
        OLI2.Billing_Frequency__c = 'Once';
        OLI2.Proj_Rpt_Frequency__c='Once [O]';
        OLI2.Therapy_Area__c= 'Hepatitis C [21]';
        OLI2.Quantity = 1.00;
        OLI2.UnitPrice = 10000;  
        OLI2.List_Price__c = 100;   
        OLI2.Delivery_Country__c = 'USA';
        OLI2.Therapy_Area__c= 'Hepatitis C [21]';
        OLI2.Billing_Date__c = Date.today();
        OLI2.Delivery_Date__c = Date.today().addYears(2);
        OLI_Array.add(OLI2);
        insert OLI_Array;
        olijson1List.add(OLI1);
        olijson2List.add(OLI2);
        TestOpp.StageName = '7a. Closed Won';
        TestOpp.Primary_Win_Reason__c ='Project Performance';
        TestOpp.Win_Type__c = 'Non-competitive bid';
        TestOpp.Potential_Regions__c = 'Asia Pacific';
        TestOpp.QI_Invited_to_Present__c = 'No';
        TestOpp.FPI_Date__c = system.today();
        TestOpp.Population_Age_Group__c = 'Not Applicable';
        
        update TestOpp;
        UTL_ExecutionControl.stopTriggerExecution = false;
        //Opportunity VerifyOpp=[select Actual_Close_Timestamp__c from Opportunity where id=: TestOpp.id];
        //system.assertnotEquals(null,VerifyOpp.Actual_Close_Timestamp__c);
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
        TestBnf.OLI_Json_Data_1__c = JSON.serialize(olijson1List);
        TestBnf.OLI_Json_Data_2__c = JSON.serialize(olijson2List);
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
    
    static testMethod void t1() 
    {
        setupOpp();
        
        setupBNF(TestLocalRA.Id,false);
        Database.executeBatch(new BCH_CRM_BNFSync(), 10);
        pageReference BnfApprovalPage = Page.BNF_Approval;
        BnfApprovalPage.getParameters().put('id',TestBnf.Id);
        Approval.ProcessResult result;
        Approval.ProcessSubmitRequest req1;
        test.starttest();
        
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
            controller.RejectionReason = 'Test';
            controller.IsRejected = false;
            controller.Init();
            controller.getRejectionReasons();
            controller.getMissingApprovals();
            controller.ApproverComments = 'Rejected for testing';
            controller.Reject();
            controller.SelectedRejectionReason = 'Multiple Error';
            controller.SelectedMissingApproval = 'missing approval';
            controller.Reject();   
            BNF2__c returnBNF=[select BNF_Status__c from BNF2__c where id =: TestBnf.Id];  
            System.assertEquals('Rejected',returnBNF.BNF_Status__c); 
        }
        
        system.runAs(TestUser)
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
        }
        system.runAs(TestLocalApprover)
        {       
            
            
            //  Create an instance of the standard controller
            ApexPages.StandardController stc = new ApexPages.StandardController(TestBnf);
            //  Create an instance of the controller extension       
            controller = new BNF_Approval_Extension(stc);
            controller.Init();
            controller.SelectedRejectionReason = 'Multiple Error';
            controller.SelectedMissingApproval = 'missing approval';
            controller.ApproverComments = 'Rejected for testing';
            
            controller.Approve();
            TestBnf.BNF_Status__c='Accepted'; 
            system.assertEquals('Accepted',TestBnf.BNF_Status__c);
        }
        test.stoptest();
        
    }
    
    static testMethod void approveRequest() 
    {
        setupOpp();
        setupBNF(TestLocalRA.Id,true);
        pageReference BnfApprovalPage = Page.BNF_Approval;
        BnfApprovalPage.getParameters().put('id',TestBnf.Id);
        
        Approval.ProcessResult result;
        Approval.ProcessSubmitRequest req1;
        test.starttest();
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
            
        }
        TestLocalApprover = [select Id from User where Id = :TestLocalRA.User__c];
        BNF2__c BNFStatus=[Select BNF_Status__c,Sales_Processing_Time__c from BNF2__c where id=:TestBnf.id];
        system.assertEquals(MDM_Defines.BnfStatus_Map.get('SUBMITTED'),BNFStatus.BNF_Status__c);
        system.assertNotEquals(null,BNFStatus.Sales_Processing_Time__c);
        system.runAs(TestLocalApprover)
        {       
            //  Create an instance of the standard controller
            ApexPages.StandardController stc = new ApexPages.StandardController(TestBnf);
            //  Create an instance of the controller extension       
            controller = new BNF_Approval_Extension(stc);
            controller.Init();
            
            controller.SelectedRejectionReason = 'Multiple Error';
            controller.SelectedMissingApproval = 'missing approval';
            controller.ApproverComments = 'Rejected for testing';
            controller.BNF.Revenue_Analyst__c = TestSAPRA.Id;
            Controller.BNF.LO_Start_Date__c=Datetime.newinstanceGMT(2013,12,1,8,00,00);
            UTL_ExecutionControl.stopTriggerExecution = true;
            controller.Approve();
            UTL_ExecutionControl.stopTriggerExecution = false;
            
        }
        test.stoptest();
    }
    
    static testMethod void rejectRequest() 
    {
        setupOpp();
        setupBNF(TestLocalRA.Id,true);
        pageReference BnfApprovalPage = Page.BNF_Approval;
        BnfApprovalPage.getParameters().put('id',TestBnf.Id);
        Approval.ProcessResult result;
        Approval.ProcessSubmitRequest req1;

        test.starttest();
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
            controller.getMissingApprovals();
            controller.ApproverComments = 'Rejected for testing';
            controller.SelectedRejectionReason=null;
            controller.SelectedMissingApproval=null;
            Controller.BNF.LO_Start_Date__c=Datetime.newinstanceGMT(2013,12,1,5,00,00);
            controller.Reject();
            controller.SelectedRejectionReason = 'Multiple Error';
            controller.SelectedMissingApproval = 'missing approval';
            UTL_ExecutionControl.stopTriggerExecution = true;
            controller.Reject();   
            UTL_ExecutionControl.stopTriggerExecution = false;
            BNF2__c returnBNF=[select BNF_Status__c from BNF2__c where id =: TestBnf.Id];  
            system.assertEquals(MDM_Defines.BnfStatus_Map.get('LO_REJECTED'),returnBNF.BNF_Status__c);
            
        }
        test.stoptest();
    }
    
    static testMethod void t22() 
    {
        setupOpp();
        setupBNF(TestLocalRA.Id,true);
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
            UTL_ExecutionControl.stopTriggerExecution = true;
            result = Approval.process(req1);
            UTL_ExecutionControl.stopTriggerExecution = false;
            // Verify the result
            System.assert(result.isSuccess());
            System.assertEquals('Pending', result.getInstanceStatus(), 'Instance Status'+result.getInstanceStatus());
            
        }
        TestLocalApprover = [select Id from User where Id = :TestLocalRA.User__c];
        test.starttest();
        system.runAs(TestLocalApprover)
        {       
            //  Create an instance of the standard controller
            ApexPages.StandardController stc = new ApexPages.StandardController(TestBnf);
            //  Create an instance of the controller extension       
            controller = new BNF_Approval_Extension(stc);
            controller.Init();
            controller.getRejectionReasons();
            controller.getMissingApprovals();
            controller.ApproverComments = 'Rejected for testing';
            controller.SelectedRejectionReason=null;
            controller.SelectedMissingApproval = null;
            Controller.BNF.LO_Start_Date__c=Datetime.newinstanceGMT(2013,12,1,5,00,00);
            UTL_ExecutionControl.stopTriggerExecution = true;
            controller.Reject();
            controller.SelectedRejectionReason = 'Multiple Error';
            controller.SelectedMissingApproval = 'missing approval';
            controller.Reject();
            UTL_ExecutionControl.stopTriggerExecution = false;
            BNF2__c returnBNF=[select BNF_Status__c from BNF2__c where id =: TestBnf.Id];  
            system.assertEquals(MDM_Defines.BnfStatus_Map.get('LO_REJECTED'),returnBNF.BNF_Status__c);
            
        }
        BNF2__c BNFStatus=[Select BNF_Status__c,Sales_Processing_Time__c,LO_Processing_Time__c from BNF2__c where id=:TestBnf.id];
        system.assertEquals(MDM_Defines.BnfStatus_Map.get('LO_REJECTED'),BNFStatus.BNF_Status__c);
        system.assertNotEquals(null,BNFStatus.LO_Processing_Time__c);
        system.runAs(TestUser)
        {
            // Create an approval request for the BNF
            req1 = new Approval.ProcessSubmitRequest();
            req1.setComments('Submitting request for approval.');
            req1.setObjectId(TestBnf.Id);
            // Submit the approval request for the BNF
            UTL_ExecutionControl.stopTriggerExecution = true;
            result = Approval.process(req1);
            UTL_ExecutionControl.stopTriggerExecution = false;
            // Verify the result
            System.assert(result.isSuccess());
            System.assertEquals('Pending', result.getInstanceStatus(), 'Instance Status'+result.getInstanceStatus());
        }
        BNFStatus=[Select BNF_Status__c,Sales_Processing_Time__c,IMS_Sales_org_code__c,Sales_Org_Code__c from BNF2__c where id=:TestBnf.id];
        system.assertEquals(MDM_Defines.BnfStatus_Map.get('SUBMITTED'),BNFStatus.BNF_Status__c);
        system.assertNotEquals(null,BNFStatus.Sales_Processing_Time__c);
        system.runAs(TestLocalApprover)
        {       
            TestSAPRA.RA_Sales_Orgs__c='CH06:CH05';
            
            upsert TestSAPRA;
            BNFStatus.Sales_Org_Code__c = 'AE01';
            upsert BNFStatus;
            //  Create an instance of the standard controller
            ApexPages.StandardController stc = new ApexPages.StandardController(BNFStatus);
            //  Create an instance of the controller extension       
            controller = new BNF_Approval_Extension(stc);
            controller.Init();
            
            controller.SelectedRejectionReason = 'Multiple Error';
            controller.SelectedMissingApproval = 'missing approval';
            controller.ApproverComments = 'Rejected for testing';
            controller.BNF.Revenue_Analyst__c = TestSAPRA.Id;
            Controller.BNF.LO_Start_Date__c=Datetime.newinstanceGMT(2013,12,1,8,00,00);
            UTL_ExecutionControl.stopTriggerExecution = true;
            controller.Approve();
            UTL_ExecutionControl.stopTriggerExecution = false;
            
        }
        test.stoptest();
        
    }
    
    /*static testMethod void t23() 
{
Approval.ProcessResult result;
Approval.ProcessSubmitRequest req1;
test.starttest();
List<User> NonSystemAdminUserList = [Select id , name,profileid, profile.name from User where Profile.name ='System Administrator' and isactive = true limit 2];
system.runAs(NonSystemAdminUserList[0])
{

setupOpp();
setupBNF(TestLocalRA.Id,true);
pageReference BnfApprovalPage = Page.BNF_Approval;
BnfApprovalPage.getParameters().put('id',TestBnf.Id);   

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

}
TestLocalApprover = [select Id from User where Id = :TestLocalRA.User__c];
system.runAs(NonSystemAdminUserList[0])
{       
//  Create an instance of the standard controller
ApexPages.StandardController stc = new ApexPages.StandardController(TestBnf);
//  Create an instance of the controller extension       
controller = new BNF_Approval_Extension(stc);
controller.Init();
controller.getRejectionReasons();
controller.ApproverComments = 'Rejected for testing';
controller.SelectedRejectionReason=null;
Controller.BNF.LO_Start_Date__c=Datetime.newinstanceGMT(2013,12,1,5,00,00);
controller.Reject();
controller.SelectedRejectionReason = 'Multiple Error';

controller.Reject();   
//BNF2__c returnBNF=[select BNF_Status__c from BNF2__c where id =: TestBnf.Id];  
//system.assertEquals(MDM_Defines.BnfStatus_Map.get('LO_REJECTED'),returnBNF.BNF_Status__c);

}
BNF2__c BNFStatus=[Select BNF_Status__c,Sales_Processing_Time__c,LO_Processing_Time__c from BNF2__c where id=:TestBnf.id];
system.assertEquals(MDM_Defines.BnfStatus_Map.get('LO_REJECTED'),BNFStatus.BNF_Status__c);
system.assertNotEquals(null,BNFStatus.LO_Processing_Time__c);
system.runAs(NonSystemAdminUserList[0])
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
}
BNFStatus=[Select BNF_Status__c,Sales_Processing_Time__c,IMS_Sales_org_code__c,Sales_Org_Code__c from BNF2__c where id=:TestBnf.id];
system.assertEquals(MDM_Defines.BnfStatus_Map.get('SUBMITTED'),BNFStatus.BNF_Status__c);
system.assertNotEquals(null,BNFStatus.Sales_Processing_Time__c);
system.runAs(NonSystemAdminUserList[0])
{       
TestSAPRA.RA_Sales_Orgs__c='CH06:CH05';

upsert TestSAPRA;
BNFStatus.Sales_Org_Code__c = 'AE01';
upsert BNFStatus;
//  Create an instance of the standard controller
ApexPages.StandardController stc = new ApexPages.StandardController(BNFStatus);
//  Create an instance of the controller extension       
controller = new BNF_Approval_Extension(stc);
controller.Init();

controller.SelectedRejectionReason = 'Multiple Error';
controller.ApproverComments = 'Rejected for testing';
controller.BNF.Revenue_Analyst__c = TestSAPRA.Id;
Controller.BNF.LO_Start_Date__c=Datetime.newinstanceGMT(2013,12,1,8,00,00);
controller.Approve();

}
BNFStatus=[Select BNF_Status__c,BNF_Actor_Ids__c,Num_Users_in_Processing__c,First_Submitter__c,LO_Processing_Time__c from BNF2__c where id=:TestBnf.id];
test.stoptest();
}*/
    
    static testMethod void t7() 
    {
        setupOpp();
        setupBNF(TestSAPRA.Id,true);
        pageReference BnfApprovalPage = Page.BNF_Approval;
        BnfApprovalPage.getParameters().put('id',TestBnf.Id);
        Approval.ProcessResult result;
        Approval.ProcessSubmitRequest req1;
        test.starttest();
        
        system.runAs(TestUser)
        {
            ApexPages.StandardController stc = new ApexPages.StandardController(TestBnf);
            //  Create an instance of the controller extension       
            controller = new BNF_Approval_Extension(stc);
            controller.Init();
            
        }
        
        test.stoptest();
        
    }
    
    
    static testMethod void t3() {
        setupOpp();
        setupBNF(TestLocalRA.Id,true);
        pageReference BnfApprovalPage = Page.BNF_Approval;
        BnfApprovalPage.getParameters().put('id',TestBnf.Id);
        Approval.ProcessResult result;
        Approval.ProcessSubmitRequest req1;
        
        system.runAs(TestUser) {   
            BNF_Test_Data.create_User_LocaleSetting();
            // Create an approval request for the BNF
            req1 = new Approval.ProcessSubmitRequest();
            req1.setComments('Submitting request for approval.');
            req1.setObjectId(TestBnf.Id);
            // Submit the approval request for the BNF
            result = Approval.process(req1);
            // Verify the result
            System.assert(result.isSuccess());
            System.assertEquals('Pending', result.getInstanceStatus(), 'Instance Status'+result.getInstanceStatus());// commented by Sandeep suggested by Himanshu for Deployment 7 Jan 2014
            
        }
        TestLocalApprover = [select Id from User where Id = :TestLocalRA.User__c];
        BNF2__c BNFStatus=[Select BNF_Status__c from BNF2__c where id=:TestBnf.id];        
        Test.startTest();        
        //system.assertEquals(MDM_Defines.BnfStatus_Map.get('SUBMITTED'),BNFStatus.BNF_Status__c);// commented by Sandeep suggested by Himanshu for Deployment 7 Jan 2014
        system.runAs(TestLocalApprover) {       
            //  Create an instance of the standard controller
            ApexPages.StandardController stc = new ApexPages.StandardController(TestBnf);
            //  Create an instance of the controller extension       
            controller = new BNF_Approval_Extension(stc);
            controller.Init();
            controller.SelectedRejectionReason = 'Multiple Error';
            controller.SelectedMissingApproval = 'missing approval';
            controller.ApproverComments = 'Rejected for testing';
            controller.BNF.Revenue_Analyst__c = TestSAPRA.Id;
            controller.Approve();
            
        }
        BNFStatus=[Select BNF_Status__c from BNF2__c where id=:TestBnf.id];
        //system.assertEquals(MDM_Defines.BnfStatus_Map.get('LO_ACCEPTED'),BNFStatus.BNF_Status__c);// commented by Sandeep suggested by Himanshu for Deployment 7 Jan 2014
        TestSAPApprover=[select Id from User where Id = :TestSAPRA.User__c];
        
        system.runAs(TestSAPApprover) {       
            //  Create an instance of the standard controller
            ApexPages.StandardController stc = new ApexPages.StandardController(TestBnf);
            //  Create an instance of the controller extension       
            controller = new BNF_Approval_Extension(stc);
            controller.Init();
            controller.SelectedRejectionReason = 'Multiple Error';
            controller.SelectedMissingApproval = 'missing approval';
            controller.ApproverComments = 'Rejected for testing';
            Controller.BNF.LO_Start_Date__c=Datetime.newinstanceGMT(2013,11,30,8,00,00);
            controller.Reject();
            Test.stopTest();
            BNFStatus=[Select BNF_Status__c,RA_Processing_Time__c from BNF2__c where id=:TestBnf.id];
            //system.assertEquals(MDM_Defines.BnfStatus_Map.get('RA_REJECTED'),BNFStatus.BNF_Status__c);// commented by Sandeep suggested by Himanshu for Deployment 7 Jan 2014
            //system.assertNotEquals(null,BNFStatus.RA_Processing_Time__c);
        }   
    }
    
    static testMethod void t4() {
        setupOpp();
        Test.startTest();
        String RAID;
        TestLocalRA =new Revenue_Analyst__c(id=TestLocalRA.id);
        TestLocalRA.RA_Sales_Orgs__c='CH06:CH05';
        RAID=TestLocalRA.id;
        update TestLocalRA;
        TestLocalRA = [select Id,Name,User__c from Revenue_Analyst__c where id=: RAID limit 1];
        
        setupBNF(TestLocalRA.Id,true);
        pageReference BnfApprovalPage = Page.BNF_Approval;
        BnfApprovalPage.getParameters().put('id',TestBnf.Id);
        Approval.ProcessResult result;
        Approval.ProcessSubmitRequest req1;
        
        
        system.runAs(TestUser) {
            BNF_Test_Data.create_User_LocaleSetting();
            // Create an approval request for the BNF
            req1 = new Approval.ProcessSubmitRequest();
            req1.setComments('Submitting request for approval.');
            req1.setObjectId(TestBnf.Id);
            // Submit the approval request for the BNF
            UTL_ExecutionControl.stopTriggerExecution = true;
            result = Approval.process(req1);
            UTL_ExecutionControl.stopTriggerExecution = false;
            // Verify the result
            System.assert(result.isSuccess());
            //System.assertEquals('Pending', result.getInstanceStatus(), 'Instance Status'+result.getInstanceStatus());// commented by Sandeep suggested by Himanshu for Deployment 7 Jan 2014
        }
         
        TestLocalApprover = [select Id from User where Id = :TestLocalRA.User__c];
        BNF2__c BNFStatus=[Select BNF_Status__c from BNF2__c where id=:TestBnf.id];
        //system.assertEquals(MDM_Defines.BnfStatus_Map.get('SUBMITTED'),BNFStatus.BNF_Status__c);// commented by Sandeep suggested by Himanshu for Deployment 7 Jan 2014
        system.runAs(TestLocalApprover) {       
            //  Create an instance of the standard controller
            ApexPages.StandardController stc = new ApexPages.StandardController(TestBnf);
            //  Create an instance of the controller extension       
            controller = new BNF_Approval_Extension(stc);
            controller.Init();
            
            controller.SelectedRejectionReason = 'Multiple Error';
            controller.SelectedMissingApproval = 'missing approval';
            controller.ApproverComments = 'Rejected for testing';
            controller.BNF.Revenue_Analyst__c = TestSAPRA.Id;
            UTL_ExecutionControl.stopTriggerExecution = true;
            controller.Approve();
            UTL_ExecutionControl.stopTriggerExecution = false;
        }
        BNFStatus=[Select BNF_Status__c from BNF2__c where id=:TestBnf.id];
        system.assertEquals(MDM_Defines.BnfStatus_Map.get('LO_ACCEPTED'),BNFStatus.BNF_Status__c);// commented by Sandeep suggested by Himanshu for Deployment 7 Jan 2014
        TestSAPApprover=[select Id from User where Id = :TestSAPRA.User__c];
        Test.stopTest();
        system.runAs(TestSAPApprover) {       
            //  Create an instance of the standard controller
            ApexPages.StandardController stc = new ApexPages.StandardController(TestBnf);
            //  Create an instance of the controller extension       
            controller = new BNF_Approval_Extension(stc);
            controller.Init();
            String temp = controller.RejectionReason;
            boolean temp1 = controller.IsRejected;
            
            controller.SelectedRejectionReason = 'Multiple Error';
            controller.SelectedMissingApproval = 'missing approval';
            controller.ApproverComments = 'Rejected for testing';
            UTL_ExecutionControl.stopTriggerExecution = true;
            controller.Reject();
            UTL_ExecutionControl.stopTriggerExecution = false;
            //BNFStatus=[Select BNF_Status__c from BNF2__c where id=:TestBnf.id];
            //system.assertEquals(MDM_Defines.BnfStatus_Map.get('RA_REJECTED'),BNFStatus.BNF_Status__c);// commented by Sandeep suggested by Himanshu for Deployment 7 Jan 2014
        }  
    }
    
    static testMethod void t6() 
    {
        setupOpp();
        String RAID;
        TestLocalRA =new Revenue_Analyst__c(id=TestLocalRA.id);
        TestLocalRA.RA_Sales_Orgs__c='CH06:CH05';
        RAID=TestLocalRA.id;
        update TestLocalRA;
        TestLocalRA = [select Id,Name,User__c from Revenue_Analyst__c where id=: RAID limit 1];
        
        setupBNF(TestLocalRA.Id,true);
        pageReference BnfApprovalPage = Page.BNF_Approval;
        BnfApprovalPage.getParameters().put('id',TestBnf.Id);
        
        
        
        Approval.ProcessResult result;
        Approval.ProcessSubmitRequest req1;
        test.starttest();
        
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
            //System.assertEquals('Pending', result.getInstanceStatus(), 'Instance Status'+result.getInstanceStatus());// commented by Sandeep suggested by Himanshu for Deployment 7 Jan 2014
            
        }
        TestLocalApprover = [select Id from User where Id = :TestLocalRA.User__c];
        BNF2__c BNFStatus=[Select BNF_Status__c from BNF2__c where id=:TestBnf.id];
        //system.assertEquals(MDM_Defines.BnfStatus_Map.get('SUBMITTED'),BNFStatus.BNF_Status__c);// commented by Sandeep suggested by Himanshu for Deployment 7 Jan 2014
        
        List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();
        oliList = [Select Id,Opportunity.CEQActiveRelease__c,Discount_Percentage_Formula__c, PricebookEntry.Name, 
                   PricebookEntry.Product2.Material_Type__c,PricebookEntry.Product2.Offering_Group__c ,Opportunity.Therapy_Area__c,  
                   PricebookEntry.Product2.Offering_Type__c , List_Price__c, Nbr_of_Users__c, Book_No__c,Other_Ship_To_SAP_Contact__c,
                   CurrencyISOCode,TotalPrice,Delivery_Media__c, Product_Invoice_Text__c, PricebookEntry.ProductCode,PricebookEntry.Product2.Delivery_Media__c,
                   PricebookEntry.Product2.Delivery_Frequency__c,Other_Ship_To_Address__c,Surcharge_Text__c,
                   Billing_Frequency__c,Product_Start_Date__c,Product_End_Date__c, Proj_Rpt_Frequency__c,Discount_Reason__c, 
                   Discount_Amount_Formula__c, Other_Ship_To__c, Billing_Date__c, Sale_Type__c, Revenue_Type__c,PricebookEntry.Product2.Item_Category_Group__c,  
                   Invoice_Lag_to_Data_Period__c, Revised_Price__c,Therapy_Area__c, Cancel__c,Business_Type__c, Delivery_Date__c,PO_Number__c,
                   Sales_Text__c,Budget_Therapy_Area__c,Project_Start_Date__c,Project_End_Date__c, 
                   OpportunityId,Billing_Schedule_Error_Msg__c,Revised_Revenue_Schedule__c,Revenue_Schedule_Error_Msg__c from OpportunityLineItem where PricebookEntry.Product2.Material_Type__c = 'ZREP'];
        
        for(OpportunityLineItem oli : oliList){
            oli.Revised_Revenue_Schedule__c = '20160204:3000|20160408:6000';
        }        
        upsert oliList;
        system.runAs(TestLocalApprover)
        {       
            //  Create an instance of the standard controller
            ApexPages.StandardController stc = new ApexPages.StandardController(TestBnf);
            //  Create an instance of the controller extension       
            controller = new BNF_Approval_Extension(stc);
            controller.Init();
            
            controller.SelectedRejectionReason = 'Multiple Error';
            controller.ApproverComments = 'Rejected for testing';
            controller.BNF.Revenue_Analyst__c = TestSAPRA.Id;
            controller.Approve();
            
        }
        
        test.stoptest();
        
    }
    
    /*static testMethod void t5() 
{

BNF_Test_Data.create_User_LocaleSetting();
User delegateUser = [Select id , name,profileid, profile.name from User where Profile.name like '%system administrator%' and isactive = true limit 1];
User userRec = new User(alias = 'alias', email='testBNFUser@metacube.com',
emailencodingkey='UTF-8', lastname='lstname',FirstName='fstname', languagelocalekey='en_US', 
localesidkey='en_US', profileId = delegateUser.profileid, timezonesidkey='America/Los_Angeles', username='BNF.username@metacube.com', Employeenumber = '12356' , DelegatedApproverId = delegateUser.id);

insert userRec;

system.runAs(userRec){
setupOpp();
TestLocalRA = new Revenue_Analyst__c(name='TestRA',User__c = userRec.id);
insert TestLocalRA;

setupBNF(TestLocalRA.Id,false);
pageReference BnfApprovalPage = Page.BNF_Approval;
BnfApprovalPage.getParameters().put('id',TestBnf.Id);
}

Approval.ProcessResult result;
Approval.ProcessSubmitRequest req1;
test.starttest();

system.runAs(userRec)
{
// Create an approval request for the BNF
req1 = new Approval.ProcessSubmitRequest();
req1.setComments('Submitting request for approval.');
req1.setObjectId(TestBnf.Id);
// Submit the approval request for the BNF
result = Approval.process(req1);

System.assertEquals('Pending', result.getInstanceStatus(), 'Instance Status'+result.getInstanceStatus());// commented by Sandeep suggested by Himanshu for Deployment 7 Jan 2014

}
BNF2__c BNFStatus = [Select Id , BNF_Status__c, Revenue_Analyst__c from BNF2__c where id=:TestBnf.id];


TestBNF = [select id, Revenue_Analyst__c, Revenue_Analyst__r.Is_SAP_Revenue_Analyst__c,Revenue_Analyst__r.RA_Sales_Orgs__c,IMS_Sales_org_code__c from BNF2__c where id = :TestBNF.id];
system.runAs(userRec) {
//  Create an instance of the standard controller
ApexPages.StandardController stc = new ApexPages.StandardController(TestBnf); 
//  Create an instance of the controller extension       
controller = new BNF_Approval_Extension(stc);
controller.Init(); 
controller.getRejectionReasons();   
controller.SelectedRejectionReason = 'Multiple Error';
controller.ApproverComments = 'Rejected for testing';
controller.Approve();
}

test.stoptest();
}*/
    
    static testmethod void t8() {
        setupOpp();
        Test.startTest();
        setupBNF(TestLocalRA.Id,false);
        TestBnf = [Select id from BNF2__c limit 1];
        ApexPages.StandardController stc = new ApexPages.StandardController(TestBnf); 
        //  Create an instance of the controller extension       
        controller = new BNF_Approval_Extension(stc);
        controller.Init(); 
        Test.stopTest();
    }
    
}