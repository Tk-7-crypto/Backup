@isTest
private class TST_CUF_FLW_PEP_CommunityUserFeedback {
    @testSetup
    static void dataSetup() {
        Group g1 = new Group(Name='SendAllEmailAlerts', type='Queue');
        insert g1;
        QueuesObject q1 ;
        system.runAs(new User(id = UserInfo.getUserId())){
            q1 = new QueueSObject(QueueID = g1.id, SobjectType = 'Case');
            insert q1;
        }
        CSM_case_Trigger_Handler__c triggerControlSetting = new CSM_case_Trigger_Handler__c(SetupOwnerId=UserInfo.getOrganizationId(),Disable_Case_Trigger__c = true, Name='IQVIA',Difference_By_Last_Created_Time_Case__c = 60);
        insert triggerControlSetting;
        Account acct = new Account(Name = 'TestAccSendAllEmailAlerts',AccountCountry__c = 'BR', CustomerSegment__c = 'GOVERNMENT', Sub_Industry__c = 'STATE');
        insert acct;
        List<Contact> conList = new List<Contact>();
        Contact cont1 = new Contact( FirstName = 'EmailAlertsFirstName', Lastname='EN', Phone='(619)852-4569', Department='Mission Control', 
                                  Title='Mission Specialist - Neptune', Email='SendAllEmailAlertsEN@iqvia.com', AccountId = acct.Id,PreferredLanguage__c = 'en_US', Portal_Case_Type__c = 'Information Offering; Technology Solutions', Contact_User_Type__C = 'Ho User');       
        conList.add(cont1);
        insert conList;
        
        List<Asset> aList = new List<Asset>();
        Product2 p1 = new Product2( Name = 'DDD', Pillar__c = 'Information Offering; Technology Solutions',SpecificToCSM__c = True);
        insert p1;
        Product2 p2 = new Product2(Name = 'Nexxus MI', Pillar__c = 'Technology Solutions',SpecificToCSM__c = True);
        insert p2;
        
        Asset a1 = new Asset(Name = 'DDD', AccountId = acct.Id, Product2Id = p1.id, Status ='Installed');
        aList.add(a1);
        
        Asset a2 = new Asset(Name = 'Nexxus MI', AccountId = acct.Id, Product2Id = p2.id, Status ='Installed');
        aList.add(a2);
        insert aList;
        
        conList = [Select Id, PreferredLanguage__c,Email,Name from Contact where FirstName = 'EmailAlertsFirstName'];
        String profilId = [select id from Profile where Name='PRM Community User'].Id;
        User user = null;
        List<User> lstUser = new List<User>();
        User autoUser = [select Id,Name from user where Name ='System' Limit 1 ];
        for(Contact con : conList){
            user = new User(Alias = 'as'+con.PreferredLanguage__c, Email = con.Email ,IsActive =true , ContactId = con.Id, ProfileId = profilId,Username =con.Email, LastName= con.Name, CommunityNickname =con.PreferredLanguage__c, TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US');
            lstUser.add(user);
        }
        insert lstUser;
        List<Community_User_Feedback__c> cufList = new List<Community_User_Feedback__c>();
        Community_User_Feedback__c cuf1 = new Community_User_Feedback__c();
        cuf1.Subject__c = 'TST_CAS_FLW_CSM_Case_SendAllEmailAlerts:Agent ';
        cuf1.Body__c = 'Test Body';
        cuf1.Contact__c =  cont1.id;
        cuf1.ProductName__c = p1.id;
        cuf1.PRM_User__c = User.id;
        cuf1.Type__c = 'File';
        cuf1.PRM_Sales_Collateral__c = True; 
        cuf1.Source__c = 'PRM';
        cufList.add(cuf1);
        Community_User_Feedback__c cuf2 = new Community_User_Feedback__c();
        cuf2.Subject__c = 'TST_CAS_FLW_CSM_Case_SendAllEmailAlerts:Agent ';
        cuf2.Body__c = 'Test Body';
        cuf2.Type__c = 'File';
        cuf2.PRM_Sales_Collateral__c = False;
        cuf2.Source__c = 'PRM';
        cufList.add(cuf2);
        insert cufList;
    }
    
    
    @isTest
    static void testFeedbackFromPortalUser(){
        Test.startTest();
        try{
            List<Community_User_Feedback__c> cuflist = [Select Id,Type__c,PRM_Sales_Collateral__c from Community_User_Feedback__c where Subject__c like 'TST_CUF_FLW_PEP_CommunityUserFeedback:System%'];
            for(Community_User_Feedback__c cs : cuflist){
                cs.Subject__c = 'TST_CAS_FLW_CSM_Case_SendAllEmailAlerts:Agent ';
                cs.Type__c = 'File';
                cs.PRM_Sales_Collateral__c = True;
                cs.Body__c = 'Test Body';
				cs.Source__c = 'PRM';
                
            }
            insert cuflist;
        }
        catch(Exception ex){
            
        }
        
        Test.stopTest();
    }
    
    @isTest
    static void testFeedbackFromPortalUser1(){
        Test.startTest();
        try{
            List<Community_User_Feedback__c> cuflist = [Select Id,Type__c,PRM_Sales_Collateral__c,Source__c from Community_User_Feedback__c where Subject__c like 'TST_CUF_FLW_PEP_CommunityUserFeedback:System%'];
            for(Community_User_Feedback__c cs : cuflist){
                cs.Subject__c = 'TST_CAS_FLW_CSM_Case_SendAllEmailAlerts:Agent ';
                cs.Type__c = 'Test Comment ';
                cs.PRM_Sales_Collateral__c = True;
                
            }
            update cuflist;
        }
        catch(Exception ex){
            
        }
        
        Test.stopTest();
    }

}