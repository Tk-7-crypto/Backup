@isTest
private class TST_TGR_Case {

   /** Entitlement Test start*/
    public testmethod static void TestAccEntitlement() {
        
        Account acct = new Account(
            Name = 'TestAcc',
            RDCategorization__c = 'Site',
            CustomerSegment__c = 'GOVERNMENT',
            Sub_Industry__c = 'STATE');
        insert acct;
        
        Account acct1 = new Account(
            Name = 'TestAcc',
            RDCategorization__c = 'Site',
            CustomerSegment__c = 'GOVERNMENT',
            Sub_Industry__c = 'STATE');
        insert acct1;
        /* Added Start */
        Account acct2 = new Account(
            Name = 'TestAcc2',
            RDCategorization__c = 'Sponsor',
            CustomerSegment__c = 'GOVERNMENT',
            Sub_Industry__c = 'STATE');
        insert acct2;
        Study__c study= new Study__c(Name = 'CaseTestStudy', Sponsor__c = acct2.Id);
        insert study;
        /* Added End */
        Contact Con = new Contact( 
            Firstname='Brian', 
            Lastname='Dent', 
            Phone='(619)852-4569', 
            Department='Mission Control', 
            Title='Mission Specialist - Neptune', 
            Email='briandent@trailhead.com');
        insert Con;
        
        
        Entitlement ent = new Entitlement(Name='Testing', AccountId=acct2.Id,Type = 'R_D',
                                          BusinessHoursId = [select id from BusinessHours where Name = 'Default'].Id,
                                          StartDate=Date.valueof(System.now().addDays(-2)), 
                                          EndDate=Date.valueof(System.now().addYears(2)));
        insert ent;
        
        User u = [Select id from User where Id = :UserInfo.getUserId()];
        
        Queue_User_Relationship__c queues=new Queue_User_Relationship__c();
        queues.Name ='Q1';
        queues.QueueName__c ='Q1';
        queues.Type__c ='Queue';
        queues.User__c = UserInfo.getUserId(); 
        insert queues;
        Queue_User_Relationship__c queueUser=new Queue_User_Relationship__c();
        queueUser.Name ='Q1';
        queueUser.QueueName__c ='Q1';
        queueUser.Type__c ='User';
        queueUser.TECH_QueueUser__c = queues.Id;
        queueUser.User__c = UserInfo.getUserId();
        insert queueUser;
        
        Id RecordTypeIdCase = Schema.SObjectType.case.getRecordTypeInfosByName().get('R&D - Assistance Request Case').getRecordTypeId();
        
        Case c = new Case(
            AccountId = acct2.Id,
            ContactId = con.Id,
            Study__c =study.Id,
            Sponsor__c = acct2.Id,   
            Origin = 'Chat',
            Status = 'In Progress',
            AssignCaseToCurrentUser__c = false,
            RandD_Location__c = 'Dalian',
            CurrentQueue__c=queues.Id,
            InitialQueue__c = 'Q1',
            OwnerId = u.Id,
            //EntitlementId = ent.Id,
            RecordTypeId = RecordTypeIdCase
        );
        try{
            insert c;  
        }catch (DmlException e) {
            System.debug('Failed to Insert :'+e);
        }
        
        /* Commented */
        Case c1 = new Case(
            AccountId = acct.Id,
            ContactId = con.Id,
            Study__c =study.Id,
            Sponsor__c = acct2.Id,
            Origin = 'Chat',
            Status = 'In Progress',
            AssignCaseToCurrentUser__c = false,
            RandD_Location__c = 'Dalian',
            InitialQueue__c = 'Q1',
            OwnerId = u.Id,
            //EntitlementId = '',
            RecordTypeId = RecordTypeIdCase
        );
        insert c1; 
        
        /* c = [select EntitlementId from case where AccountId =: acct.Id ];
        System.assertEquals (ent.Id, c.EntitlementId); */
        
        
    }
    
    public testmethod static void TestAccEntitlement1() {
        
        Account acct = new Account(
            Name = 'TestAcc',
            RDCategorization__c = 'Site',
            CustomerSegment__c = 'GOVERNMENT',
            Sub_Industry__c = 'STATE');
        insert acct;
        
        Contact Con = new Contact( 
            Firstname='Brian', 
            Lastname='Dent', 
            Phone='(619)852-4569', 
            Department='Mission Control', 
            Title='Mission Specialist - Neptune', 
            Email='briandent@trailhead.com',
            AccountId = acct.Id);
        insert Con;
        
        Entitlement ent = new Entitlement(Name='Testing', AccountId=acct.Id,Type = 'TECHNO',
                                          BusinessHoursId = [select id from BusinessHours where Name = 'Default'].Id,
                                          StartDate=Date.valueof(System.now().addDays(-2)), 
                                          EndDate=Date.valueof(System.now().addYears(2)));
        insert ent;
        
        User u = [Select id from User where Id = :UserInfo.getUserId()];
        
        Id RecordTypeIdCase = Schema.SObjectType.case.getRecordTypeInfosByName().get('TechnologyCase').getRecordTypeId();
        Queue_User_Relationship__c queues=new Queue_User_Relationship__c();
        queues.Name ='Q1';
        queues.QueueName__c ='Q1';
        queues.Type__c ='Queue';
        queues.User__c = UserInfo.getUserId(); 
        insert queues;
        Queue_User_Relationship__c queueUser=new Queue_User_Relationship__c();
        queueUser.Name ='Q1';
        queueUser.QueueName__c ='Q1';
        queueUser.Type__c ='User';
        queueUser.TECH_QueueUser__c = queues.Id;
        queueUser.User__c = UserInfo.getUserId();
        insert queueUser;
        Queue_User_Relationship__c queues2=new Queue_User_Relationship__c();
        queues2.Name ='Q2';
        queues2.QueueName__c ='Q2';
        queues2.Type__c ='Queue';
        queues2.User__c = UserInfo.getUserId();
        insert queues2; 
        Queue_User_Relationship__c queueUser2=new Queue_User_Relationship__c();
        queueUser2.Name ='Q2';
        queueUser2.QueueName__c ='Q2';
        queueUser2.Type__c ='User';
        queueUser.TECH_QueueUser__c = queues2.Id;
        queueUser2.User__c = UserInfo.getUserId();
        insert queueUser2;
        
        Case c = new Case(
            AccountId = acct.Id,
            ContactId = con.Id,
            Origin = 'Chat',
            Status = 'In Progress',
            AssignCaseToCurrentUser__c = false,
            CurrentQueue__c=queues.Id,
            InitialQueue__c = 'Q1',
            OwnerId = u.Id,
            EntitlementId = ent.Id,
            RecordTypeId = RecordTypeIdCase
        );
        insert c;
        
        Case c1 = new Case(
            AccountId = acct.Id,
            ContactId = con.Id,
            Origin = 'Chat',
            Status = 'In Progress',
            AssignCaseToCurrentUser__c = false,
            CurrentQueue__c=queues.Id,
            InitialQueue__c = 'Q1',
            OwnerId = u.Id,
            RecordTypeId = RecordTypeIdCase
        );
        insert c1;
        
        c = [select EntitlementId from case where AccountId =: acct.Id Limit 1];
        
        System.assertEquals (ent.Id, c.EntitlementId);
        
        
    }
    
    public testmethod static void TestAccEntitlement2() {
        
        Account acct = new Account(
            Name = 'TestAcc',
            RDCategorization__c = 'Site',
            CustomerSegment__c = 'GOVERNMENT',
            Sub_Industry__c = 'STATE');
        insert acct;
        
        Contact Con = new Contact( 
            Firstname='Brian', 
            Lastname='Dent', 
            Phone='(619)852-4569', 
            Department='Mission Control', 
            Title='Mission Specialist - Neptune', 
            Email='briandent@trailhead.com',
            AccountId = acct.Id);
        insert Con;
        
        Entitlement ent = new Entitlement(Name='Testing', AccountId=acct.Id,Type = 'DATA',
                                          BusinessHoursId = [select id from BusinessHours where Name = 'Default'].Id,
                                          StartDate=Date.valueof(System.now().addDays(-2)), 
                                          EndDate=Date.valueof(System.now().addYears(2)));
        insert ent;
        
        User u = [Select id from User where Id = :UserInfo.getUserId()];
        
        Id RecordTypeIdCase = Schema.SObjectType.case.getRecordTypeInfosByName().get('DATA Case').getRecordTypeId();
        Queue_User_Relationship__c queues=new Queue_User_Relationship__c();
        queues.Name ='Q1';
        queues.QueueName__c ='Q1';
        queues.Type__c ='Queue';
        queues.User__c = UserInfo.getUserId(); 
        insert queues;
        Queue_User_Relationship__c queueUser=new Queue_User_Relationship__c();
        queueUser.Name ='Q1';
        queueUser.QueueName__c ='Q1';
        queueUser.Type__c ='User';
        queueUser.TECH_QueueUser__c = queues.Id;
        queueUser.User__c = UserInfo.getUserId();
        insert queueUser;
        Queue_User_Relationship__c queues2=new Queue_User_Relationship__c();
        queues2.Name ='Q2';
        queues2.QueueName__c ='Q2';
        queues2.Type__c ='Queue';
        queues2.User__c = UserInfo.getUserId();
        insert queues2; 
        Queue_User_Relationship__c queueUser2=new Queue_User_Relationship__c();
        queueUser2.Name ='Q2';
        queueUser2.QueueName__c ='Q2';
        queueUser2.Type__c ='User';
        queueUser2.TECH_QueueUser__c = queues2.Id;
        queueUser2.User__c = UserInfo.getUserId();
        insert queueUser2;
        
        Case c = new Case(
            AccountId = acct.Id,
            ContactId = con.Id,
            Origin = 'Chat',
            Status = 'In Progress',
            AssignCaseToCurrentUser__c = false,
            CurrentQueue__c=queues.Id,
            InitialQueue__c = 'Q1',
            OwnerId = u.Id,
            EntitlementId = ent.Id,
            RecordTypeId = RecordTypeIdCase
        );
        insert c;
        
        Case c1 = new Case(
            AccountId = acct.Id,
            ContactId = con.Id,
            Origin = 'Chat',
            Status = 'In Progress',
            AssignCaseToCurrentUser__c = false,
            CurrentQueue__c=queues.Id,
            InitialQueue__c = 'Q1',
            OwnerId = u.Id,
            RecordTypeId = RecordTypeIdCase
        );
        insert c1;
        
        c = [select EntitlementId from case where AccountId =: acct.Id Limit 1];
        
        System.assertEquals (ent.Id, c.EntitlementId);
        
    }
    
    public testmethod static void TestAccEntitlement3() {
        
        Account acct = new Account(
            Name = 'TestAcc',
            RDCategorization__c = 'Site',
            CustomerSegment__c = 'GOVERNMENT',
            Sub_Industry__c = 'STATE');
        insert acct;
        /* Added Start */
        Account acct2 = new Account(
            Name = 'TestAcc2',
            RDCategorization__c = 'Sponsor',
            CustomerSegment__c = 'GOVERNMENT',
            Sub_Industry__c = 'STATE');
        insert acct2;
        Study__c study= new Study__c(Name = 'CaseTestStudy', Sponsor__c = acct2.Id);
        insert study;
        /* Added End */ 
        Contact Con = new Contact( 
            Firstname='Brian', 
            Lastname='Dent', 
            Phone='(619)852-4569', 
            Department='Mission Control', 
            Title='Mission Specialist - Neptune', 
            Email='briandent@trailhead.com');
        insert Con;
        
        StudySiteContactRelationship__c siteConR=new StudySiteContactRelationship__c(Study__c = study.Id,Investigator_Name__c = con.Id,Site_Name__c = acct.Id);
        siteConR.SiteNumber__c = 'SSCN123123';
        insert siteConR;
        Entitlement ent = new Entitlement(Name='Testing', AccountId=acct.Id,Type = 'R_D',
                                          BusinessHoursId = [select id from BusinessHours where Name = 'Default'].Id,
                                          StartDate=Date.valueof(System.now().addDays(-2)), 
                                          EndDate=Date.valueof(System.now().addYears(2)));
        insert ent;
        
        User u = [Select id from User where Id = :UserInfo.getUserId()];
        
        Id RecordTypeIdCase = Schema.SObjectType.case.getRecordTypeInfosByName().get('R&D - Activity Plan Case').getRecordTypeId();
        Queue_User_Relationship__c queues=new Queue_User_Relationship__c();
        queues.Name ='Q1';
        queues.QueueName__c ='Q1';
        queues.Type__c ='Queue';
        queues.User__c = UserInfo.getUserId(); 
        insert queues;
        Queue_User_Relationship__c queueUser=new Queue_User_Relationship__c();
        queueUser.Name ='Q1';
        queueUser.QueueName__c ='Q1';
        queueUser.Type__c ='User';
        queueUser.TECH_QueueUser__c = queues.Id;
        queueUser.User__c = UserInfo.getUserId();
        insert queueUser;
        Queue_User_Relationship__c queues2=new Queue_User_Relationship__c();
        queues2.Name ='Q2';
        queues2.QueueName__c ='Q2';
        queues2.Type__c ='Queue';
        queues2.User__c = UserInfo.getUserId();
        insert queues2; 
        Queue_User_Relationship__c queueUser2=new Queue_User_Relationship__c();
        queueUser2.Name ='Q2';
        queueUser2.QueueName__c ='Q2';
        queueUser2.Type__c ='User';
        queueUser2.User__c = UserInfo.getUserId();
        queueUser2.TECH_QueueUser__c = queues2.Id;
        insert queueUser2;
        
        Case c = new Case(
            AccountId = acct.Id,
            Study__c=study.Id,
            Site_Related_to_the_Study__c = siteConR.Id,
            Sponsor__c = acct2.Id,
            ContactId = con.Id,
            Origin = 'Chat',
            AssignCaseToCurrentUser__c = false,
            Status = 'In Progress',
            RandD_Location__c = 'Dalian',
            CurrentQueue__c=queues.Id,
            InitialQueue__c = 'Q1',
            OwnerId = u.Id,
            //EntitlementId = ent.Id,
            RecordTypeId = RecordTypeIdCase
        );
        insert c;
        /* Commented */ 
        Case c1 = new Case(
            AccountId = acct.Id,
            ContactId = con.Id,
            Study__c=study.Id,
            Site_Related_to_the_Study__c = siteConR.Id,
            Sponsor__c = acct2.Id,
            Origin = 'Chat',
            Status = 'In Progress',
            RandD_Location__c = 'Dalian',
            CurrentQueue__c=queues.Id,
            AssignCaseToCurrentUser__c = false,
            InitialQueue__c = 'Q1',
            OwnerId = u.Id,
            RecordTypeId = RecordTypeIdCase
        );
        insert c1; 
        
        /*  c = [select EntitlementId from case where AccountId =: acct.Id Limit 1];
         System.assertEquals (ent.Id, c.EntitlementId); */
        
        
    }
    /** Entitlement Test End*/
    /** Milestone Test start*/
    static testMethod void TestCompleteMilestoneCase(){
        List<Account> acts = new List<Account>();
        Account myAcc = new Account(Name='TestAct', phone='1001231234', RDCategorization__c = 'Site',CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE');
        acts.add(myAcc);
        Account busAcc = new Account(Name = 'TestForMS', phone='4567890999', RDCategorization__c = 'Site',CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE');
        acts.add(busAcc);
        insert acts;
        
        Account acct2 = new Account(
            Name = 'TestAcc2',
            RDCategorization__c = 'Sponsor',
            CustomerSegment__c = 'GOVERNMENT',
            Sub_Industry__c = 'STATE');
        insert acct2;
        Study__c study= new Study__c(Name = 'CaseTestStudy', Sponsor__c = acct2.Id);
        insert study;
        
       
        Contact cont = new Contact(FirstName = 'Test', LastName = 'LastName', phone='4567890999',
                                   accountid = busAcc.id);
        insert(cont);
        Id contactId = cont.Id;
        StudySiteContactRelationship__c siteConR=new StudySiteContactRelationship__c(Study__c = study.Id,Investigator_Name__c = cont.Id,Site_Name__c = acts[1].Id);
        siteConR.SiteNumber__c = 'SSCN123123';
        insert siteConR;
        Entitlement entl = new Entitlement(Name='TestEntitlement', AccountId=busAcc.Id, BusinessHoursId = [select id from BusinessHours where Name = 'Default'].Id);
        insert entl;
        Id RecordTypeIdCase = Schema.SObjectType.case.getRecordTypeInfosByName().get('R&D - Activity Plan Case').getRecordTypeId();
        Queue_User_Relationship__c queues=new Queue_User_Relationship__c();
        queues.Name ='Q1';
        queues.QueueName__c ='Q1';
        queues.Type__c ='Queue';
        queues.User__c = UserInfo.getUserId(); 
        insert queues;
        Queue_User_Relationship__c queueUser=new Queue_User_Relationship__c();
        queueUser.Name ='Q1';
        queueUser.QueueName__c ='Q1';
        queueUser.Type__c ='User';
        queueUser.TECH_QueueUser__c = queues.Id;
        queueUser.User__c = UserInfo.getUserId();
        insert queueUser;
        Queue_User_Relationship__c queues2=new Queue_User_Relationship__c();
        queues2.Name ='Q2';
        queues2.QueueName__c ='Q2';
        queues2.Type__c ='Queue';
        queues2.User__c = UserInfo.getUserId();
        insert queues2; 
        Queue_User_Relationship__c queueUser2=new Queue_User_Relationship__c();
        queueUser2.Name ='Q2';
        queueUser2.QueueName__c ='Q2';
        queueUser2.Type__c ='User';
        queueUser2.TECH_QueueUser__c = queues2.Id;
        queueUser2.User__c = UserInfo.getUserId();
        insert queueUser2;
        
        String entlId;
        if (entl != null)
            entlId = entl.Id;
        List<Case> cases = new List<Case>{};
            if (entlId != null){
                Case c = new Case(Subject = 'Test Case with Entitlement ',
                                  Study__c=study.Id,
                                  Sponsor__c = acct2.Id,
                                  Site_Related_to_the_Study__c = siteConR.Id,
                                  Origin = 'Chat',
                                  Status = 'In Progress',
                                  RandD_Location__c = 'Dalian',
                                  CurrentQueue__c=queues.Id,
                                  AssignCaseToCurrentUser__c = false,
                                  InitialQueue__c = 'Q1',
                                  EntitlementId = entlId, 
                                  ContactId = contactId,
                                  RecordTypeId = RecordTypeIdCase);
                cases.add(c);
            }
        insert cases;
        List<Id> caseIds = new List<Id>();
        if (cases.isEmpty()==false){
            //insert cases;            
            for (Case cL : cases){
                //caseIds.add(cL.Id);
                cL.Status = 'Closed';
                cL.SlaStartDate = Date.today().addMonths(-2);
                
            }
            
            // update cases;
            DAOH_Case.completeMilestone(caseIds, 'First Response Time', System.now());
        }
        
    }
    
    static testMethod void testCompleteMilestoneViaCase(){
        List<Account> acts = new List<Account>();
        Account myAcc = new Account(Name='TestAct', phone='1001231234', RDCategorization__c = 'Site',CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE');
        acts.add(myAcc);
        Account busAcc = new Account(Name = 'TestForMS', phone='4567890999', RDCategorization__c = 'Site',CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE');
        acts.add(busAcc);
        insert acts;
        
        Contact cont = new Contact(FirstName = 'Test', LastName = 'LastName', phone='4567890999',
                                   accountid = busAcc.id);
        insert(cont);
        Id contactId = cont.Id;
        
        Entitlement entl = new Entitlement(Name='TestEntitlement', AccountId=busAcc.Id, BusinessHoursId = [select id from BusinessHours where Name = 'Default'].Id);
        insert entl;
        
        Queue_User_Relationship__c queues=new Queue_User_Relationship__c();
        queues.Name ='Q1';
        queues.QueueName__c ='Q1';
        queues.Type__c ='Queue';
        queues.User__c = UserInfo.getUserId(); 
        insert queues;
        Queue_User_Relationship__c queueUser=new Queue_User_Relationship__c();
        queueUser.Name ='Q1';
        queueUser.QueueName__c ='Q1';
        queueUser.Type__c ='User';
        queueUser.TECH_QueueUser__c = queues.Id;
        queueUser.User__c = UserInfo.getUserId();
        insert queueUser;
        Queue_User_Relationship__c queues2=new Queue_User_Relationship__c();
        queues2.Name ='Q2';
        queues2.QueueName__c ='Q2';
        queues2.Type__c ='Queue';
        queues2.User__c = UserInfo.getUserId();
        insert queues2; 
        Queue_User_Relationship__c queueUser2=new Queue_User_Relationship__c();
        queueUser2.Name ='Q2';
        queueUser2.QueueName__c ='Q2';
        queueUser2.TECH_QueueUser__c = queues2.Id;
        queueUser2.Type__c ='User';
        queueUser2.User__c = UserInfo.getUserId();
        insert queueUser2;
        
        String entlId;
        
        if (entl != null)
            entlId = entl.Id;
        
        List<Case> cases = new List<Case>{};
            
            for(Integer i = 0; i < 1; i++){
                
                Case c = new Case(Subject = 'Test Case ' + i,AssignCaseToCurrentUser__c = false,CurrentQueue__c=queues.Id);
                
                cases.add(c);
                
                if (entlId != null){
                    
                    c = new Case(Subject = 'Test Case with Entitlement ' + i,
                                 CurrentQueue__c=queues.Id,AssignCaseToCurrentUser__c = false,
                                 EntitlementId = entlId);
                    
                    cases.add(c);
                }
            }
    }
    /** Milestone Test End*/
    /**
    * This method is used to setup data for all methods.
    */
    @testSetup
    static void dataSetup() {
        Account acc = CSM_Util.createAccount();
        insert acc;
        Contact cnt = CSM_Util.createContact(acc.Id,'CaseTestContact');
        insert cnt;
        /*Audit trail Log Added Start */
        Account acct2 = CSM_Util.createRDAccount();
        insert acct2;
        
        /*Audit trail Log Added End */
        
    }
    
    /**
    * This test method used for insert and update Case record
    */ 
    static testMethod void testAuditforCase() {
        CNT_CSM_FieldHistoryTracking.saveFields('Case','AccessionNumber__c,Account_Name_Article__c,AccountCountry__c,ACN__c,ActionDescription__c,Activity__c,AdditionalAction__c,AdditionalActionsCompleted__c,AdditionalThirdPartyCase2__c,AdditionalThirdPartyCase__c,AgeGrouping__c,AlignmentName__c,Approach__c,AreyouquestioningcomparingProjected__c,AssetName__c,AssignCaseToCurrentUser__c,ATCLevel__c,AttachMarketDefinitionToTicket__c,Auditsquestioningcomparing__c,AutoClosed__c,BusinessHours__c,BusinessHoursId,BusinessUntilDueDate__c,Case_CategorizationId__c,CaseCreator__c,CaseRequestBy__c,CaseSource__c,CaseSubType1__c,CaseSubType2__c,CaseSubType3__c,CFM10CFM7__c,Channel__c,Channelsquestioningcomparing__c,ChildCaseDescription__c,ClientInq__c,ClientObjectiveBusinessNeed__c,ClientRefMaterial__c,ClosedBy__c,ClosedByGroup__c,CloseNotes__c,CMFProd__c,Comments,ComplexityLevel__c,ConfigurationItem__c,ConsumerHealthData__c,ContactBusinessTerritory__c,ContactEmail,ContactFax,ContactMobile,ContactPhone,COREClassification__c,CORESubClassification__c,CoreTicket__c,CreatedByGroup__c,CreatedDate__c,CRMSolutionSupportPriority__c,CrossauditDIsales__c,CrossDatabase__c,CurrencyIsoCode,InitialQueue__c,CurrentQueue1__c,CurrentQueue__c,Customer_Requested_Date__c,CustomerQualityAlert__c,CustomerRequiredDate__c,CustomerUrgency__c,CycleFrom__c,CycleTo__c,DataDeliveryEndDate__c,DataDeliveryFrequency__c,DataMeasurement__c,DataSourceSPP__c,DataTimePeriodInQuestion__c,DataTypeIMSOne__c,DataWeekMonthOfReport__c,DateCorrected__c,DateofAction__c,DateResolved__c,DEA__c,Describetheissuedifferenceindetail__c,DidthisRequireCorrectiveAction__c,DueDate__c,EmailCC__c,EntitlementId,EnvironmentType__c,ExternalContacts__c,ExternalTeamStatusNE__c,FillinthenameoftheClientCompanyt__c,FirstCallResolution__c,FlexibleFields__c,FollowUpDateLevel__c,ForeignCallerId__c,FoundBy__c,From_EmailToCase__c,GlobalCaseType__c,HCRS_DaaS_Manual_Match_ID__c,HCRSWebID__c,HelpDeskWarmTransfer__c,HospitalsIncluded__c,HOTFix__c,IfOtherChannelPleasespecify__c,IfOtherMetricsPleaseSpecify__c,IfOtherPEPTPleaseSpecify__c,IfyeshowmanylookupsrequiredCorrec__c,Impact__c,ImplementationCenterRequester__c,Imputation__c,IMSDr__c,IMSPrescriberNumber__c,InitialQueue__c,InternalOrExternalDI__c,IsClosedOnCreate,IsStopped,Issue__c,IssueCausedBy__c,IssuedDifferencepreresearchconducted__c,IsThisASpecialHandlingClient__c,ItemNumber__c,JIRANotes__c,LastModifiedDate__c,LevelOfService__c,LookBackPeriod__c,LOS__c,ManagerEvaluation__c,MarketNameOnWeb__c,Metric__c,Metricsquestioningcomparing__c,MilestoneStatus,MIVersion__c,MonoComboTherapy__c,MonthofRework__c,NDC_Number__c,NextMilestoneFlag__c,NextMilestonePriorValue__c,NextMilestoneStatus__c,NextNotificationDate__c,NoContactKnown__c,NovartisCaseType__c,Numberaffected__c,NumberofDatabasesReworked__c,NumberOfNotifications__c,OpsHourEstimated__c,OpsRunbookIMSOne__c,OpsStackRank__c,ParentId,PEPTOnOff__c,Phone_Number__c,PhoneVerification__c,Plan__c,Plan_Name__c,PlanEndDate__c,PlannedFixDate__c,PlanStartDate__c,PrimaryOrSecondaryFactory__c,PriorityDefinitionDate__c,ProductId,ProductMarketorOther__c,ProductMarketOrOtherName__c,ProductName__c,ProductOutletToResearch__c,ProductPackSize__c,ProjectCategoryNS__c,PRSNumber__c,PSACode__c,QualityIssue__c,QuintilesIMSRefMaterial__c,Reason,RecordTypeId,RecordTypeName__c,Release__c,ReOpenDate__c,ReOpened__c,ReOpener__c,ReportCustomisation__c,ReportLocations__c,ReportsTo__c,RequireAction__c,RequiredCallbackCompleted__c,RequiredReprocess__c,ResolutionCode__c,ResolutionsharedwithCustomer__c,ResolutionSubType__c,ResolvedBy__c,ResolvedWithinSLP__c,Retail__c,RootCause__c,RootCauseCommentsinternal__c,RootCauseToClients__c,RunDateOfReport__c,ScheduledDate__c,SendAutomaticAcknowledgmentEmail__c,SendResolutionEmail__c,ServiceNow_Group__c,Site__c,SlaExitDate,SlaStartDate,SLPTurnaroundTime__c,SolvedBY__c,SOTC__c,SourceId,SpecialtyGrouping__c,StatusAtFirstSubmission__c,StatusDefinitionDate__c,StopStartDate,SubcaseClasification__c,SubType1__c,SubType2__c,SubType3__c,SuppliedCompany,SuppliedEmail,SuppliedName,SuppliedPhone,Supplier__c,SupplierCustom__c,SupplierName__c,SupportTier__c,Survey_Link__c,SwitchAddGracePeriod__c,Tag__c,Target_Date__c,Template__c,Territory__c,TerritoryIDNE__c,ThirdPartyCase__c,TimeIntervalsquestioningcomparing__c,Timeline__c,TimingofReportChanges__c,TotalTimeinhours__c,Type,TypeCustom__c,UrgentForCustomer__c,USC3__c,USC5__c,USC_Code__c,UserTrainedDate__c,What_limitsdoesyourdatainclude__c,WhatChannelIsConcerned__c,WhatLimitsDoesYourDataInclude__c,WhatMetricsIsConcerned__c,WhatTimePeriodareyouquestioning__c,WhySLPWasMissed__c,WhySLPwasMissedDescription__c,Workaround__c,XponentPrescribingDynamics__c,ZipOutlet__c');
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'CaseTestAccount' LIMIT 1];
        Account acct2= [SELECT Id, Name FROM Account WHERE Name = 'CaseRDTestAccount' LIMIT 1];
        Contact cnt = [SELECT Id, Name FROM Contact WHERE Name = 'CaseTestContact CaseTestContact' LIMIT 1];
        Contact cnt2 = CSM_Util.createContact(acc.Id,'CaseTestContact2');
        insert cnt2;
        Study__c study = CSM_Util.createStudy(acct2.Id);
        insert study;
        Study__c study2 = CSM_Util.createStudy(acct2.Id);
        insert study2;
        Product2 product = CSM_Util.createProduct2();
        product.Name ='CSMProd1';
        product.Pillar__c = 'Information Offering; Technology Solutions';
        insert product;
        //Id productId,Id accountId,Id contactId,Id studyId
        Asset aset = CSM_Util.createAsset('CSMProd1',product.Id,acc.Id,cnt.Id,study.Id);
        insert aset;
        ServiceNow_Group__c service=new ServiceNow_Group__c();
        service.Group_ID__c='GRP123';
        service.Name = 'Service GRP123';
        insert service;
        
        ServiceNow_Group__c service2=new ServiceNow_Group__c();
        service2.Group_ID__c='GRP123';
        service2.Name = 'Service GRP123';
        insert service2;
        
        BusinessHours bHours = [select Id,Name,IsActive,IsDefault from BusinessHours where IsActive=true and name='Default' LIMIT 1];
        BusinessHours bHours2 = [select Id,Name,IsActive,IsDefault from BusinessHours where IsActive=true and name='EU Business Hours' LIMIT 1];
        
        Entitlement ent = new Entitlement(Name='Testing', AccountId=acc.Id,Type = 'R_D',
                                          BusinessHoursId = bHours.Id,
                                          StartDate=Date.valueof(System.now().addDays(-2)), 
                                          EndDate=Date.valueof(System.now().addYears(2)));
        
        Entitlement ent2 = new Entitlement(Name='Testing2', AccountId=acc.Id,Type = 'R_D',
                                           BusinessHoursId = bHours2.Id,
                                           StartDate=Date.valueof(System.now().addDays(-2)), 
                                           EndDate=Date.valueof(System.now().addYears(2)));
        
        Queue_User_Relationship__c queues=new Queue_User_Relationship__c();
        queues.Name ='Q1';
        queues.QueueName__c ='Q1';
        queues.Type__c ='Queue';
        queues.User__c = UserInfo.getUserId(); 
        insert queues;
        Queue_User_Relationship__c queueUser=new Queue_User_Relationship__c();
        queueUser.Name ='Q1';
        queueUser.QueueName__c ='Q1';
        queueUser.Type__c ='User';
        queueUser.TECH_QueueUser__c = queues.Id;
        queueUser.User__c = UserInfo.getUserId();
        insert queueUser;
        Queue_User_Relationship__c queues2=new Queue_User_Relationship__c();
        queues2.Name ='Q2';
        queues2.QueueName__c ='Q2';
        queues2.Type__c ='Queue';
        queues2.User__c = UserInfo.getUserId();
        insert queues2; 
        Queue_User_Relationship__c queueUser2=new Queue_User_Relationship__c();
        queueUser2.Name ='Q2';
        queueUser2.QueueName__c ='Q2';
        queueUser2.Type__c ='User';
        queueUser2.TECH_QueueUser__c = queues2.Id;
        queueUser2.User__c = UserInfo.getUserId();
        insert queueUser2; 
        
        Id RecordTypeIdCase = Schema.SObjectType.case.getRecordTypeInfosByName().get('R&D - Assistance Request Case').getRecordTypeId();
        Id RecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByName().get('R&D - Activity Plan Case').getRecordTypeId();
        StudySiteContactRelationship__c siteConR=new StudySiteContactRelationship__c(Study__c = study.Id,Investigator_Name__c = cnt.Id,Site_Name__c = acc.Id);
        siteConR.SiteNumber__c = 'SSCN123123';
        insert siteConR;
        StudySiteContactRelationship__c siteConR2=new StudySiteContactRelationship__c(Study__c = study2.Id,Investigator_Name__c = cnt.Id,Site_Name__c = acc.Id);
        siteConR2.SiteNumber__c = 'SSCN121121';
        insert siteConR2;
        List<Case> csList=new List<Case>();
        Case cse =null,cseParent=null;
        
        cse = new Case(
            AccountId = acc.Id,
            ContactId = cnt.Id,
            Study__c =study.Id,
            Site_Related_to_the_Study__c = siteConR.Id,
            Sponsor__c = acct2.Id,
            ServiceNow_Group__c=service.Id,
            CurrentQueue__c=queues.Id,
            AssignCaseToCurrentUser__c = false,
            Origin = 'Chat',
            Status = 'In Progress',
            InitialQueue__c = 'Q1',
            RandD_Location__c = 'Dalian',
            OwnerId = UserInfo.getUserId(),
            EntitlementId = ent.Id,
            RecordTypeId = RecordTypeId
        );
        csList.add(cse);
        cseParent = new Case(
            AccountId = acc.Id,
            ContactId = cnt.Id,
            Study__c =study.Id,
            Site_Related_to_the_Study__c = siteConR.Id,
            Sponsor__c = acct2.Id,
            ServiceNow_Group__c=service.Id,
            CurrentQueue__c=queues.Id,
            AssignCaseToCurrentUser__c = false,
            Origin = 'Chat',
            Status = 'In Progress',
            RandD_Location__c = 'Dalian',
            InitialQueue__c = 'Q1',
            OwnerId = UserInfo.getUserId(),
            EntitlementId = ent.Id,
            RecordTypeId = RecordTypeIdCase
        );
        
        csList.add(cseParent);
        
        
        
        Test.startTest();
        insert csList;
        cse.CurrentQueue__c = queues2.Id;
        cse.InitialQueue__c  =  'Q2';
        cse.Study__c  =  study2.Id;
        cse.Site_Related_to_the_Study__c = siteConR2.Id;
        cse.AssetId =  aset.Id;
        cse.ServiceNow_Group__c =  service2.Id;
        cse.EntitlementId  =  ent2.Id;
        cse.BusinessHoursId  =  bHours2.Id;
        update cse;
        cseParent.CurrentQueue__c = queues2.Id;
        cse.InitialQueue__c  =  'Q2';
        cseParent.Status = 'In Progress';
        cseParent.Description = 'Test Case for Trigger';
        cseParent.CaseSubType2__c = 'tbd';
        cseParent.EntitlementId  =  ent2.Id;
        cseParent.BusinessHoursId  =  bHours2.Id;
        update cseParent;
        Test.stopTest();
    }

    @isTest
    static void testCheckActivityStatusForOpen() {
        CSM_case_Trigger_Handler__c trigeerHandler = new CSM_case_Trigger_Handler__c(CSM_Activity_Open_Validation__c = true);
        insert trigeerHandler;
        Test.startTest();
        List<User> listOfUser = UTL_TestData.createUser('Service User',1);
        insert listOfUser[0];
        SLT_RecordType sltRecordType = new SLT_RecordType();
        case newCase1 = UTL_TestData.createCase();
        newCase1.InitialQueue__c = 'Data MX Client Services';
        newCase1.RecordTypeId = sltRecordType.getRecordType('RandDCase')[0].Id;
        try{
            insert newCase1;
            Activity__C newActivity = new Activity__C(Case__c = newCase1.Id, status__c = 'Open', 
                                                      LOS__c = 'EDC Support',Type__c = 'Quality Check' );
            insert newActivity;
            newCase1.Status = 'Resolved';
            update newCase1;
        }
        catch(Exception ex){
            Boolean expectedExceptionThrown = ex.getMessage().contains(Label.CSM_Activity_Open_Validation) ? true : false;
            System.assertEquals(true,expectedExceptionThrown,'case is updated' );
        }
        Test.stopTest();
	}
    
    @isTest
    static void testCheckActivityStatusForClosed() {
        CSM_case_Trigger_Handler__c trigeerHandler = new CSM_case_Trigger_Handler__c(CSM_Activity_Open_Validation__c = true);
        insert trigeerHandler;
        Test.startTest();
        List<User> listOfUser = UTL_TestData.createUser('Service User',1);
        insert listOfUser[0];
        SLT_RecordType sltRecordType = new SLT_RecordType();
        case newCase1 = UTL_TestData.createCase();
        newCase1.InitialQueue__c = 'Data MX Client Services';
        newCase1.RecordTypeId = sltRecordType.getRecordType('RandDCase')[0].Id;
        try{
            insert newCase1;
            Activity__C newActivity = new Activity__C(Case__c = newCase1.Id, status__c = 'Closed');
            insert newActivity;
            newCase1.Status = 'Resolved';
            update newCase1;
        }
        catch(Exception ex){
            Boolean expectedExceptionThrown = ex.getMessage().contains(Label.CSM_Activity_Open_Validation) ? true : false;
            System.assertEquals(false,expectedExceptionThrown,'case is updated' );
        }
        Test.stopTest();
	}
    
    @isTest
    static void testCheckActivityStatusNotTrigger() {
        Test.startTest();
        List<User> listOfUser = UTL_TestData.createUser('Service User',1);
        insert listOfUser[0];
        SLT_RecordType sltRecordType = new SLT_RecordType();
        case newCase1 = UTL_TestData.createCase();
        newCase1.InitialQueue__c = 'Data MX Client Services';
        newCase1.RecordTypeId = sltRecordType.getRecordType('RandDCase')[0].Id;
        try{
            insert newCase1;
            Activity__C newActivity = new Activity__C(Case__c = newCase1.Id, status__c = 'Closed');
            insert newActivity;
            newCase1.Status = 'Resolved';
            update newCase1;
        }
        catch(Exception ex){
            Boolean expectedExceptionThrown = ex.getMessage().contains(Label.CSM_Activity_Open_Validation) ? true : false;
            System.assertEquals(false,expectedExceptionThrown,'case is updated' );
        }
        Test.stopTest();
	}
}