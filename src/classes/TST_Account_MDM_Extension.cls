@isTest
private class TST_Account_MDM_Extension
{
    private static Integer NumAddressesPerAccount = 10;
    private static Integer NumAccounts = 40;
    private static List <Account> Account_Array = new List <Account>();
    private static List <Address__c> Address_Array = new List <Address__c>();
    private static User TestUser;
    
    static void Init()
    {
        TestUser = [select Id from User where Profile.Name = 'System Administrator' and IsActive = true limit 1];
        for (Integer i=0; i<NumAccounts; i++)
        {
            Account TempAccount = new Account(Name=String.valueOf(495000+i),Status__c=MDM_Defines.AddressStatus_Map.get('SAP_VALIDATED'),OwnerId=TestUser.Id,AccountCountry__c='AF',CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE');
            Account_Array.add(TempAccount);
        }
        insert Account_Array;       
    }
    
    static testMethod void t1() 
    {       
        Init();
        Set<Id> Account_Id_Set = new Set<Id>();
        for (Account A:Account_Array)
        {
            Account_Id_Set.add(A.Id);
        }
        Integer AccountIterator = 0;
        for (Integer i=0; i<NumAccounts*NumAddressesPerAccount; i++)
        {
            if (i > 0 && Math.mod(i,NumAddressesPerAccount) == 0)
            {
                AccountIterator++;
            }
            Id AccountId = Account_Array[AccountIterator].Id;
            Address__c TempAddress = New Address__c(Name=String.valueOf(i),
                                                    Account__c=AccountId,
                                                    Street__c = 'Street ' + i.format(),
                                                    City__c = 'City '+ i.format(),
                                                    Country__c = 'Country ' + i.format(),
                                                    SAP_Reference__c = String.valueOf(495000+i),
                                                    MDM_Validation_Status__c = 'Validated',
                                                    RecordTypeId = Schema.SObjectType.Address__c.getRecordTypeInfosByDeveloperName().get('MDM_Validated').getRecordTypeId());
            Address_Array.add(TempAddress);

        } 
        Test.startTest();
        CON_GLOBAL.RELEASE_MAY_2021 = 9999.99;
        insert Address_Array;
        Test.stopTest();
        for (Account A:[select Id,Name,SAP_Code__c from Account where Id in :Account_Id_Set])
        {
            Integer ExpectedSapCodeMin = 495000 + (Integer.valueOf(A.Name)-495000)*NumAddressesPerAccount;
            Integer ExpectedSapCodeMax = ExpectedSapCodeMin + NumAddressesPerAccount;  
            system.debug('Account Name: ' + A.Name);
            system.debug('Sap_Code__c: ' + A.Sap_Code__c);
            system.debug('Expected Min Sap Code: ' + String.valueOf(ExpectedSapCodeMin));
            system.debug('Expected Max Sap Code: ' + String.valueOf(ExpectedSapCodeMax));
            //system.assert(Integer.valueOf(A.SAP_Code__c) >= ExpectedSapCodeMin);
            //system.assert(Integer.valueOf(A.SAP_Code__c) < ExpectedSapCodeMax);
        }
    }
    
    /*static testMethod void t2() 
    {       
        TestUser = [select Id from User where Profile.Name like '%Administrator%' and IsActive = true limit 1];
        NumAccounts = 100;
        //Account_Defines DEFINE = new Account_Defines();
        Set<Id> Account_Id_Set = new Set<Id>();
        Account_Array.clear();
        Test.startTest();
        system.runAs(TestUser)
        {
            for (Integer i=0; i<NumAccounts; i++)
            {
                Account TempAccount = new Account(Name=String.valueOf(495000+i),Status__c='New',CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE');
                Account_Array.add(TempAccount);         
            }
            insert Account_Array;
            for (Account A:Account_Array)
            {
                Account_Id_Set.add(A.Id);
            }
            Account_Array = [select Id,RecordTypeId from Account where Id in :Account_Id_set];
            for (Account A:Account_Array)
            {
                system.assertEquals(A.RecordTypeId,MDM_Defines.New_Account_Record_Type_Id);
                A.Status__c = MDM_Defines.AddressStatus_Map.get('SAP_VALIDATED');
            }
            update Account_Array;
            Account_Array = [select Id,RecordTypeId from Account where Id in :Account_Id_set];
            for (Account A:Account_Array)
            {
                system.assertEquals(A.RecordTypeId,MDM_Defines.SAP_Validated_Record_Type_Id);
                A.Status__c = 'New';
            }
            update Account_Array;
            Account_Array = [select Id,RecordTypeId from Account where Id in :Account_Id_set];
            for (Account A:Account_Array)
            {
                system.assertEquals(A.RecordTypeId,MDM_Defines.New_Account_Record_Type_Id);
            }
            Test.stopTest();    
        }   
    }*/
    
    static testMethod void t3() 
    {       
        Init();
        Set<Id> Account_Id_Set = new Set<Id>();
        for (Account A:Account_Array)
        {
            Account_Id_Set.add(A.Id);
        }
        Integer AccountIterator = 0;
        for (Integer i=0; i<NumAccounts*NumAddressesPerAccount; i++)
        {
            if (i > 0 && Math.mod(i,NumAddressesPerAccount) == 0)
            {
                AccountIterator++;
            }
            Id AccountId = Account_Array[AccountIterator].Id;
            Address__c TempAddress = New Address__c(Name=String.valueOf(i),
                                                    Account__c=AccountId,
                                                    Street__c = 'Street ' + i.format(),
                                                    City__c = 'City '+ i.format(),
                                                    Country__c = 'Country ' + i.format(),
                                                    Marked_For_Deletion__c = false,
                                                    SAP_Reference__c = String.valueOf(495000+i),
                                                    MDM_Validation_Status__c = 'Validated');
            Address_Array.add(TempAddress);

        } 
        CON_GLOBAL.RELEASE_MAY_2021 = 9999.99;
        insert Address_Array;
        for (Account A:Account_Array)
        {
            A.Status__c = 'New';            
        }
        Test.startTest();
        update Account_Array;       
        Test.stopTest();
        for (Address__c A:[select Id,Marked_For_Deletion__c from Address__c where Account__c in :Account_Id_Set])
        {
            //system.assertEquals(true,A.Marked_For_Deletion__c); 
        }
    }       
    
    static testMethod void t4() 
    {
        TestUser = [select Id from User where Profile.Name = 'System Administrator' and IsActive = true limit 1];
        Approval.ProcessResult result;
        Approval.ProcessSubmitRequest req1;
        Account TempAccount;
        system.runAs(TestUser)
        {
            TempAccount = new Account(Name='Test Account',Status__c=MDM_Defines.AddressStatus_Map.get('NEW'),OwnerId=TestUser.Id,AccountCountry__c='AF',CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE');
            TempAccount.MDM_Validation_Status__c = 'Unvalidated';
            insert TempAccount;
  
            // Create an approval request for the account
            req1 = new Approval.ProcessSubmitRequest();
            req1.setComments('Submitting request for approval.');
            req1.setObjectId(TempAccount.Id);
            // Submit the approval request for the account
            result = Approval.process(req1);
            // Verify the result
            System.assert(result.isSuccess());
            System.assertEquals('Pending', result.getInstanceStatus(), 'Instance Status'+result.getInstanceStatus());
        }
        // Reject the submitted request
        // First, get the ID of the newly created item
        List<Id> newWorkItemIds = result.getNewWorkitemIds();
        // Instantiate the new ProcessWorkitemRequest object and populate it
        Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
        req2.setComments('Rejecting request.');
        req2.setAction('Reject');
            
        // Use the ID from the newly created item to specify the item to be worked
        req2.setWorkitemId(newWorkItemIds.get(0));
        system.debug('Req2: WorkitemId: ' + newWorkItemIds.get(0));
        system.debug(req2);
        // Submit the request for approval
        Approval.ProcessResult result2 = Approval.process(req2);
        // Verify the results
        System.assert(result2.isSuccess(), 'Result Status:'+result2.isSuccess());
        System.assertEquals('Rejected', result2.getInstanceStatus(), 'Instance Status'+result2.getInstanceStatus());
        Approval.ProcessSubmitRequest req3;

        system.runAs(TestUser)
        {
            Test.startTest();
            ApexPages.CurrentPage().getParameters().put('ApproveReject','1');
            //  Create an instance of the standard controller
            ApexPages.StandardController stc = new ApexPages.StandardController(TempAccount);
            //  Create an instance of the controller extension       
            Account_MDM_Extension controller = new Account_MDM_Extension(stc);
            controller.SubmitAccountForApprovalPage();
            controller.SubmitForMdmApproval();
            controller.getCustomApprovalProcessHistory();
            controller.ApprovalProcessRedirect();
            controller.CreateManualBnf();           
        }
        ProcessInstanceWorkitem[] P = [select Id, ProcessInstance.TargetObjectId from ProcessInstanceWorkitem  where ProcessInstance.Status like 'Pending' and ProcessInstance.TargetObjectId = :TempAccount.Id];
//      system.assertEquals(1,P.size());
        //  Simulate MDM approval
        req2 = new Approval.ProcessWorkitemRequest();
        req2.setComments('Rejecting request.');
        req2.setAction('Approve');
        // Use the ID from the newly created item to specify the item to be worked
        req2.setWorkitemId(P[0].Id);
        // Submit the request for approval
        result2 = Approval.process(req2);
        // Verify the results
        System.assert(result2.isSuccess(), 'Result Status:'+result2.isSuccess());
        //System.assertEquals('Pending', result2.getInstanceStatus(), 'Instance Status'+result2.getInstanceStatus()); 
        //  Simulate informatica upload which sets status to 'SAP Validated'
        TempAccount.Status__c = MDM_Defines.AddressStatus_Map.get('SAP_VALIDATED');
        TempAccount.MDM_Validation_Status__c = 'Validated';
        update TempAccount;
        P = [select Id, ProcessInstance.TargetObjectId from ProcessInstanceWorkitem  where ProcessInstance.Status like 'Pending' and ProcessInstance.TargetObjectId = :TempAccount.Id];
        system.assertEquals(0,P.size());
        TempAccount = [select Id, RecordTypeId from Account where Id = :TempAccount.Id];
        //system.assertEquals(MDM_Defines.SAP_Validated_Record_Type_Id,TempAccount.RecordTypeId);
        TempAccount.Status__c = MDM_Defines.AddressStatus_Map.get('SAP_VALIDATED');
        TempAccount.Exclude_from_Mulesoft_Sync__c = true;
        update TempAccount;
        Test.stopTest();
    }
   
    static testMethod void t5()
    {
        Init();
        for (Account A:Account_Array)
        {
            //A.RecordTypeId = MDM_Defines.Super_Parent_Record_Type_Id;
        }
        update Account_Array;
        system.runAs(TestUser)
        {
            try
            {
                delete Account_Array;
            }
            catch(Exception E)
            {
                system.assert(E.getMessage().contains('Super Parent accounts can only be deleted by system administrators'));
            }
        }
    } 
    
    static testMethod void t6()
    {
        Init();
        for (Account A:Account_Array)
        {
            //A.RecordTypeId = MDM_Defines.SAP_Validated_Record_Type_Id;
            A.Status__c = MDM_Defines.AddressStatus_Map.get('SAP_VALIDATED');
        }
        update Account_Array;
        system.runAs(TestUser)
        {
            try
            {
                delete Account_Array;
            }
            catch(Exception E)
            {
                system.assert(E.getMessage().contains('SAP validated accounts can only be deleted by system administrators'));
            }
        }
    } 
    
    static testMethod void t7() 
    {       
        Init();
        Set<Id> Account_Id_Set = new Set<Id>();
        Set<Id> Address_Id_Set = new Set<Id>();
        for (Account A:Account_Array)
        {
            Account_Id_Set.add(A.Id);
        }
        Integer AccountIterator = 0;
        Integer MaxDummyCode = 900000;
        AggregateResult[] MaxExistingCode = [select max(SAP_reference__c) from Address__c where SAP_Reference__c like '9_____%'];
        if (MaxExistingCode[0].get('expr0') != null)
        {
            MaxDummyCode = Integer.valueOf(MaxExistingCode[0].get('expr0')) + 1;
        }
        for (Integer i=0; i<NumAccounts*NumAddressesPerAccount; i++)
        {
            if (i > 0 && Math.mod(i,NumAddressesPerAccount) == 0)
            {
                AccountIterator++;
            }
            Id AccountId = Account_Array[AccountIterator].Id;
            //  Create addresses with SAP_Reference__c values greater than 700000 to correspond to dummy
            //  base customers in SAP.  These need to be marked for deletion in SFDC to avoid being selected
            //  by users
            Address__c TempAddress = New Address__c(Name=String.valueOf(i),
                                                    Account__c=AccountId,
                                                    Street__c = 'Street ' + i.format(),
                                                    City__c = 'City '+ i.format(),
                                                    Country__c = 'Country ' + i.format(),
                                                    SAP_Reference__c = String.valueOf(MaxDummyCode +i),
                                                    MDM_Validation_Status__c = 'Validated');
            Address_Array.add(TempAddress);
        } 
        Test.startTest();
        CON_GLOBAL.RELEASE_MAY_2021 = 9999.99;
        insert Address_Array;
        Test.stopTest();
        Address_Array = [select Id,SAP_Reference__c,Account__c,Marked_For_Deletion__c from Address__c where Id in :Address_Id_Set];
        for (Address__c A:Address_Array)
        {
            system.assertEquals(true,A.Marked_For_Deletion__c);
            system.assert(A.Account__c == null);
        }
    }
    
   //Quick Opp
    //Added by Himanshu Parashar : 07 oct 2011

    static testMethod void t8() {       
        Profile p = [select id from profile where name = 'System Administrator' Limit 1]; 
        User u = new User(alias = 'jpusr', email='japnalocal@metacube.com',Business_Unit__c='Central East and South Europe',  
                          emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
                          localesidkey='en_US', profileid = p.Id, 
                          timezonesidkey='America/Los_Angeles', username='japnalocal@metacube.com',
                          Change_Request_Description__c = 'test', Change_Request_Ticket_Number__c ='test description'
                         ,EmployeeNumber ='080808081');
        
        System.runAs(u) {
            //RecordType recordtypeId=[SELECT Id FROM RecordType where Name Like 'Quick Opportunity'];
            Opportunity opp;
            opp =new Opportunity(Name='Quick opp',StageName='6 - Close Won',CloseDate=System.today(),
                                 Contract_Term__c='Single-Period');
            opp.LeadSource = 'Account Planning';
            opp.Budget_Available__c = 'Yes';
          //opp.Unique_Business_Value__c = 'Unknown';
          //opp.Compelling_Event__c = 'No';
          //opp.RecordTypeId=recordtypeId.Id;
          //opp.Amount_In_USD__c=9800;
          //opp.Conversion_Rate_To_USD__c=1.0;
            opp.Amount=9800;
            insert opp;  
            ApexPages.CurrentPage().getParameters().put('OpportunityId',opp.id );
            ApexPages.StandardController sc = new ApexPages.StandardController(opp);
            Account TestAccount1 = new Account(Name='TestAccount1', CurrencyIsoCode = 'USD', Region_Territory__c = 'India', Industry_IMS__c = 'Providers',AccountCountry__c='AF',CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE');
            insert TestAccount1;
        //  Create an instance of the standard controller
            PageReference pageRef = ApexPages.currentPage();
            Test.setCurrentPageReference(pageRef);
            sc = new ApexPages.standardController(TestAccount1 );
            Account_MDM_Extension controller = new Account_MDM_Extension(sc);
            controller.CreateManualBnf();
        }
   }
   
     //Quick Opp
    //Added by Himanshu Parashar : 07 oct 2011
    // Method for Checking Japan profile
   /*static testmethod void checkjapanprofile()
   {
        
         Profile p = [select id from profile where name like '%Administrator%' limit 1];  
         User u = new User(alias = 'jpusr', email='japnalocal@metacube.com',Business_Unit__c='Central East and South Europe', 
            emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
            localesidkey='en_US', profileid = p.Id,User_Country__c='Germany', 
            timezonesidkey='America/Los_Angeles', username='japnalocal@metacube.com');


         System.runAs(u) {
                 
          //RecordType recordtypeId=[SELECT Id FROM RecordType where Name Like 'Quick Opportunity'];
          Opportunity opp;
          opp =new Opportunity(Name='Quick opp',StageName='6 - Close Won',CloseDate=System.today(),
          Contract_Term__c='Single-Period');
          opp.LeadSource = 'Account Planning';
          opp.Budget_Available__c = 'Yes';
          //opp.Unique_Business_Value__c = 'Unknown';
          //opp.Compelling_Event__c = 'No';
          //opp.RecordTypeId=recordtypeId.Id;
          //opp.Amount_In_USD__c=9800;
          //opp.Conversion_Rate_To_USD__c=1.0;
          opp.Amount=9800;

          insert opp;    
       
          ApexPages.CurrentPage().getParameters().put('OpportunityId',opp.id );
          ApexPages.StandardController sc = new ApexPages.StandardController(opp);
          Account TestAccount1 = new Account(Name='TestAccount1', CurrencyIsoCode = 'USD', Region_Territory__c = 'India', Industry_IMS__c = 'Providers',CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE');
          insert TestAccount1;
             
             
        //  Create an instance of the standard controller
       
         PageReference pageRef = ApexPages.currentPage();
         Test.setCurrentPageReference(pageRef);
         sc = new ApexPages.standardController(TestAccount1 );
         Account_MDM_Extension controller = new Account_MDM_Extension(sc);
         controller.CreateManualBnf();
         System.assertNotEquals(pageRef,null);   
         }
   }*/
    //-- end of update --
   static testMethod void t31() 
    {     
        NumAccounts = 1;
        Profile p = [select id from profile where name='System Administrator']; 
        User user = new User (FirstName = 'informatica',LastName = 'User1',Username = 'TestUser@metacube.com'+String.valueof(DateTime.now().getTime()),Email =  'TestUser1@metacube.com',Alias = 'TestUsr1',TimeZoneSidKey = 'America/Los_Angeles',LocaleSidKey = 'en_US',EmailEncodingKey = 'UTF-8',ProfileId = p.id ,LanguageLocaleKey ='en_US', Change_Request_Description__c = 'test', Change_Request_Ticket_Number__c ='test description'
                             ,EmployeeNumber ='08080808');
        insert user;
        Init();
        Set<Id> Account_Id_Set = new Set<Id>();
        for (Account A:Account_Array)
        {
            Account_Id_Set.add(A.Id);
        }
        for (Account A:Account_Array)
        {
            A.Status__c = MDM_Defines.AddressStatus_Map.get('SAP_VALIDATED'); 
            //A.RecordTypeId = MDM_Defines.SAP_Validated_Record_Type_Id;
            A.Sap_reference__C = 'Test';
        }
        update Account_Array;
        Test.startTest();
        for (Account A:Account_Array)
        {
            A.Sap_reference__C = '';
            A.Name = 'Test informatica';
        }
        system.runAs(user)
        {
            update Account_Array;
        }
        Test.stopTest();
        for (Address__c A:[select Id,Marked_For_Deletion__c from Address__c where Account__c in :Account_Id_Set])
        {
            system.assertEquals(true,A.Marked_For_Deletion__c); 
        }
    }
}