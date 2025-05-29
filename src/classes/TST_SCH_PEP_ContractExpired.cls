@isTest
public class TST_SCH_PEP_ContractExpired {
    @testSetup
    public static void setup(){     
        Id prmProfileId = [select id from profile where name =: CON_PEP.S_P_PEP_COMMUNITY ].id;
        Account ac = new Account(name ='Acme') ;
        ac.AccountCountry__c = 'BM' ;
        ac.CustomerSegment__c = 'GOVERNMENT';
        ac.Sub_Industry__c = 'STATE';
        insert ac;
        
        Contact con = new Contact(FirstName = 'TestFirstName', LastName ='testCon',AccountId = ac.Id,Email='partneruser@iqvia.partner.com');
        con.Partner_Type__c = 'Integrator Partner; Data Partner';
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
        insert agencyprog;
        
        Contract testContract1 = new Contract(Project_Leader_Region__c = 'Asia Pacific', 
                                              RecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByDeveloperName().get('PRM_Contract').getRecordTypeId(),
                                              AccountId = us.Contact.AccountId,
                                              Status = 'Not Started',
                                              StartDate = Date.newInstance(2019, 12, 9),
                                              EndDate = Date.newInstance(2019, 12, 9),
                                              Date_executed_signed_contract_received__c = Date.newInstance(2019, 12, 9),
                                              First_Notification_Date__c = Date.today(),
                                              Notification_Counter__c = 1,
                                              Agency_Program__c = agencyprog.Id,
                                              Parent_Contract_Number__c = 1234,
                                              Ultimate_Parent_Contract_Number__c = 5678,
                                              SOW_status__c = 'Signed',
                                              PRM_Contract_type__c = 'Agency Program SOW');
        insert testContract1;
        
        Account ac1 = new Account(Name = 'IQVIA CONSOLIDATED ACCOUNT');
        ac1.AccountCountry__c = 'IN';
        ac1.CustomerSegment__c = 'GOVERNMENT';
        ac1.Sub_Industry__c = 'STATE';
        insert ac1;
        
        Contact con1 = new Contact(FirstName = 'TestFirstName1234', LastName = 'testCon', AccountId = ac1.Id, Email = 'partneruser1@iqvia.partner.com');
        con1.Partner_Type__c = 'Data Partner';
        insert con1;
        
        TS_LMS_Training_Management__c trainingMgmt = new TS_LMS_Training_Management__c();
        trainingMgmt.Subscription_Start_Date__c = Date.today();
        trainingMgmt.Subscription_End_Date__c = Date.today() + 1;
        trainingMgmt.IQVIA_Key_Contact__c = con1.Id;
        trainingMgmt.Account_Name__c = ac1.Id;
        trainingMgmt.SOW__c = true;
        trainingMgmt.Status__c = 'new';
        insert trainingMgmt;
    }
    
    @isTest
    public static void testUpdateContractStatus()
    { 
        Test.startTest();
        SchedulableContext sc = null;
        SCH_PEP_ContractExpired sch = new SCH_PEP_ContractExpired(); 
        sch.execute(sc);
        Test.stopTest();  
    }
}