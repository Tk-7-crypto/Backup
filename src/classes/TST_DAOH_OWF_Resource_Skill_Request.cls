/**
* This test class is used to test all methods in DAOH_OWF_Resource_Skill_Request.
* version : 1.0
*/
@isTest
private class TST_DAOH_OWF_Resource_Skill_Request {
    
	/**
    * This method used to set up testdata
    */ 
    @testSetup
    static void dataSetup() 
	{
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        User testUser = new User(
        Alias = 'testuser',
        FirstName ='fistwww11',
        LastName = 'lastNamess123',
        Email = 'test.' + System.currentTimeMillis() + '@iqvia.com',
        Username = 'testuser'+ System.currentTimeMillis() +'@example.com.iqvia',
        ProfileId = p.Id,
        TimeZoneSidKey = 'America/Los_Angeles',
        LocaleSidKey = 'en_US',
        EmailEncodingKey = 'UTF-8',
        LanguageLocaleKey = 'en_US',
        IsActive = true, 
        employeeNumber= '8800',
        Change_Request_Description__c = 'test',
        Change_Request_Ticket_Number__c ='test description',
        Audit_Employee_Number_Reason__c ='test',
        SUBREGION__c = 'United States of America' // Setting the SUBREGION__c field
        );
        insert testUser;
        pse__Region__c region = new pse__Region__c();
    	region.Name = 'United States of America';
        insert region;       
        Account acc = UTL_OWF_TestData.createAccount();
        insert acc;
        pse__Grp__c grp = UTL_OWF_TestData.createGroup();
        insert grp;
        Contact contact = UTL_OWF_TestData.createContact(acc.Id);
        Contact.FirstName = 'TestFirstName11';
        Contact.LastName = 'TestContact11';
        contact.pse__Is_Resource__c = true;
        contact.pse__Is_Resource_Active__c = true;
        contact.pse__Group__c = grp.Id;
        contact.pse__Salesforce_User__c = testUser.Id;
        contact.sub_group__c = 'TSL-Japan';
        contact.Available_For_Triage_Flag__c = true;
        contact.pse__Region__c = region.Id; 
        insert contact;
        Indication_List__c indication = UTL_OWF_TestData.createIndication('Test Indication', 'Acute Care');
        insert indication;
        Contact cont = UTL_OWF_TestData.createContact(acc.Id);
        cont.pse__Is_Resource__c = true;
        cont.pse__Is_Resource_Active__c = true;
        cont.pse__Group__c = grp.Id;
        cont.pse__Salesforce_User__c = UserInfo.getUserId();
        cont.sub_group__c = 'TSL';
        cont.pse__Region__c = region.Id; 
        cont.Region__c ='Latin America';         	
        cont.Available_For_Triage_Flag__c = true;
        insert cont;
        pse__Permission_Control__c permissionControlGroup = UTL_OWF_TestData.createPermissionControl(null, null, grp, null);
        insert permissionControlGroup;     
        Opportunity opp = UTL_OWF_TestData.createOpportunity(acc.Id);
        opp.Potential_Regions__c = 'Japan';
        opp.Line_of_Business__c = 'Clinical';
        insert opp;
        
        Bid_History__c agreement = UTL_OWF_TestData.createBidHistoryByRecordType(acc.Id, opp.Id, CON_OWF.OWF_CLINICAL_BID_BID_HISTORY_RECORD_TYPE_ID);
        agreement.Bid_Due_Date__c = Date.today().addDays(7);
        agreement.Opportunity_Type__c = CON_OWF.OPPORTUNITY_TYPE;
        agreement.RFP_Ranking__c = '2';
        agreement.Budget_Deliverable__c= CON_OWF.BUDGET_DELIVERABLE;
        agreement.Requested_Services__c = CON_OWF.OWF_BID_HISTORY_REQUESTED_INTERNAL_SERVICES_CLINICAL_MONITORING;
        agreement.Pricing_Monitoring_Model__c = CON_OWF.OWF_BID_HISTORY_PRICING_MONITORING_MODEL_IQVIA_RBM;
        agreement.DTE_Study__c = CON_OWF.OWF_BID_HISTORY_DTE_STUDY_NO;

        Test.startTest();
        insert agreement;
        pse__Proj__c bidProject = [Select id from pse__Proj__c where Bid_History__c =: agreement.Id];
        Id recordTypeId = Schema.SObjectType.pse__Resource_Request__c.getRecordTypeInfosByName().get('OWF Resource Request').getRecordTypeId();
        pse__Resource_Request__c resourceRequest = UTL_OWF_TestData.createResourceRequestForBidHistory(agreement.Id, opp.Id, bidProject.Id);
        resourceRequest.RecordTypeId = recordTypeId;
        resourceRequest.pse__Group__c = grp.Id;
        resourceRequest.pse__Resource__c = cont.Id;
        resourceRequest.SubGroup__c = 'TSL';
        resourceRequest.Complexity_Score_Total__c = 50;
        insert resourceRequest;
        pse__Schedule__c schedule = UTL_OWF_TestData.createSchedule();
        insert schedule;
        pse__Assignment__c assignement =  UTL_OWF_TestData.createAssignmentForBidHistory(agreement.Id, bidProject.Id, schedule.Id, cont.Id, resourceRequest.Id);
        insert assignement;
        Test.stopTest();
    }
    
	
    /**
    * This method used to test the CreateResourceCandidateMatchScore method
    */ 
    @isTest
    static void testCreateResourceCandidateMatchScoreWithIndication() 
    {
        pse__Skill__c skill = UTL_OWF_TestData.createSkills('Test Skill', CON_OWF.SKILL_TYPE_INDICATION);
        insert skill; 
        Test.startTest();
        List<Contact> contactList = [Select Id From Contact where sub_group__c = 'TSL'];
        List<pse__Resource_Request__c> resRequestList = [Select Id From pse__Resource_Request__c where SubGroup__c = 'TSL'];
        pse__Skill_Certification_Rating__c skillCertRating = UTL_OWF_TestData.createSkillCertificationRating(skill.Id, contactList.get(0).Id);
        insert skillCertRating;
        pse__Resource_Skill_Request__c resourceSkillRequest = UTL_OWF_TestData.createResourceSkillRequest(skill.Id, resRequestList.get(0).Id);
        insert resourceSkillRequest;
        List<pse__Resource_Skill_Request__c> resourceSkillRequestList = [Select Id, pse__Resource_Request__c,pse__Resource_Request__r.SubGroup__c FROM pse__Resource_Skill_Request__c limit 1000];
        List<DAOH_OWF_Resource_Skill_Request.ResourceCandidateMatchScore> resourceCandidateMatchScoreList = DAOH_OWF_Resource_Skill_Request.createResourceCandidateMatchScore(resourceSkillRequestList);
        DAOH_OWF_Resource_Skill_Request.createResourceCandidateMatchScoreForTSSU(resourceSkillRequestList);    
        Test.stopTest();
        
        system.assertNotEquals(0, resourceCandidateMatchScoreList.size(), 'Verifying CreateResourceCandidateMatchScoreWithIndication Functionality');
    }
    
	
    /**
    * This method used to test the CreateResourceCandidateMatchScore method
    */ 
    @isTest
    static void testCreateResourceCandidateMatchScoreWithTherapyArea() 
    {
        pse__Skill__c skill = UTL_OWF_TestData.createSkills('Test Skill', CON_OWF.SKILL_TYPE_THERAPY_AREA);
        insert skill;
        Test.startTest();
        List<Contact> contactList = [Select Id From Contact where sub_group__c = 'TSL'];
        List<pse__Resource_Request__c> resRequestList = [Select Id From pse__Resource_Request__c  where SubGroup__c = 'TSL'];
        pse__Skill_Certification_Rating__c skillCertRating = UTL_OWF_TestData.createSkillCertificationRating(skill.Id, contactList.get(0).Id);
        insert skillCertRating;
        pse__Resource_Skill_Request__c resourceSkillRequest = UTL_OWF_TestData.createResourceSkillRequest(skill.Id, resRequestList.get(0).Id);
        insert resourceSkillRequest;    
        List<pse__Resource_Skill_Request__c> resourceSkillRequestList = [Select Id, pse__Resource_Request__c,pse__Resource_Request__r.SubGroup__c FROM pse__Resource_Skill_Request__c limit 1000];
        List<DAOH_OWF_Resource_Skill_Request.ResourceCandidateMatchScore> resourceCandidateMatchScoreList = DAOH_OWF_Resource_Skill_Request.createResourceCandidateMatchScore(resourceSkillRequestList);
        Test.stopTest();
        
        system.assertNotEquals(0, resourceCandidateMatchScoreList.size(), 'Verifying CreateResourceCandidateMatchScoreWithTherapyArea Functionality');
    }
    
    @isTest
    static void testCreateResourceCandidateMatchScoreWithGradeLevel() 
	{
            List<pse__Skill__c> skillList = new List<pse__Skill__c>();
            pse__Skill__c skill4 = UTL_OWF_TestData.createSkills('USA/Canada', CON_OWF.SKILL_TYPE_POTENTIAL_REGION);
            pse__Skill__c skill5 = UTL_OWF_TestData.createSkills('RFP Ranking', CON_OWF.SKILL_TYPE_GRADE_LEVEL);
            skillList.add(skill4);
            skillList.add(skill5);
        		Test.startTest();
        		insert skillList;
        		Bid_History__c agreement = [SELECT Id, Name FROM Bid_History__c limit 1];
        		Contact cont = [Select Id From Contact Where LastName = 'TestContact' limit 1];
        		cont.sub_group__c=CON_OWF.RES_REQ_TYPE_GBO_LEAD_PD;
                update cont;
                Opportunity oppty = [SELECT Id FROM Opportunity WHERE name = 'TestOpportunity'];
                oppty.Potential_Regions__c ='USA/Canada';
                update oppty;
                pse__Proj__c project = [Select Id From pse__Proj__c Where Bid_History__c =: agreement.Id limit 1];
                pse__Grp__c grp1 = [Select Id From pse__Grp__c Where Name = 'TestGroup'];
                pse__Resource_Request__c resourceRequest = UTL_OWF_TestData.createResourceRequestForBidHistory(agreement.Id, oppty.Id, project.Id);
                resourceRequest.pse__Group__c = grp1.Id;
                resourceRequest.Is_Created_Automatically__c = true;
                resourceRequest.SubGroup__c =CON_OWF.RES_REQ_TYPE_GBO_LEAD_PD;
                List<pse__Skill_Certification_Rating__c> skillCertRatingList = new List<pse__Skill_Certification_Rating__c>();
                pse__Skill_Certification_Rating__c skillCertRating = UTL_OWF_TestData.createSkillCertificationRating(skill4.Id,cont.Id);
                skillCertRatingList.add(skillCertRating);
                pse__Skill_Certification_Rating__c skillCertRating1 = UTL_OWF_TestData.createSkillCertificationRating(skill5.Id,cont.Id);
                skillCertRating1.RFP_Ranking__c = 'RFP Ranking 2';
                skillCertRatingList.add(skillCertRating1);
                insert skillCertRatingList;
                insert resourceRequest;			
            	List<pse__Resource_Skill_Request__c> rsr = [select id,  pse__Resource_Request__c  from pse__Resource_Skill_Request__c where pse__Resource_Request__c =: resourceRequest.Id];
       		Test.stopTest();    
        
        	system.assertNotEquals(0, rsr.size(), 'Verifying CreateResourceCandidateMatchScoreWithGradeLevel Functionality');
    }
	
    @isTest
    static void testWrapperClassResourceCandidateMatchScore() 
    {
        DAOH_OWF_Resource_Skill_Request.ResourceCandidateMatchScore rrCMScore = new DAOH_OWF_Resource_Skill_Request.ResourceCandidateMatchScore(null, null);
        test.startTest();
			Integer compareResult = rrCMScore.compareTo(rrCMScore);
        test.stopTest();
		
        system.assertEquals(0, compareResult, 'Verifying WrapperClassResourceCandidateMatchScore Functionality');
    }

    @isTest
	static void testMatchingLineOfBusinessAndTherapyArea() {
    // Step 1: Create Skills
        User user = [Select id, name, email from User where id=: UserInfo.getUserId()];
        user.SUBREGION__c = 'Australia & NZ';
        update user;
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'TestOpportunity' LIMIT 1];
        Contact contactList = [SELECT Id FROM Contact WHERE sub_group__c = 'TSL'];
        List<pse__Resource_Request__c> resRequestList = [SELECT Id, pse__Opportunity__c FROM pse__Resource_Request__c WHERE SubGroup__c = 'TSL'];
        Contact contact = [Select Id From Contact where sub_group__c = 'TSL-Japan' limit 1];
        contact.Region__c='Asia Pacific';
        update contact;
        Bid_History__c bidHistory = [SELECT Id FROM Bid_History__c WHERE Bid_History_Related_Opportunity__c = :opp.Id LIMIT 1];
        pse__Proj__c project = [SELECT Id FROM pse__Proj__c WHERE Bid_History__c = :bidHistory.Id LIMIT 1];
        pse__Resource_Request__c resourceRequest = UTL_OWF_TestData.createResourceRequestForBidHistory(
            bidHistory.Id, 
            opp.Id, 
            project.Id
        );
        resourceRequest.SubGroup__c = 'TSL-Japan';
        insert resourceRequest;
        resourceRequest.pse__Resource__c = contact.Id;
        update resourceRequest;
        pse__Skill__c therapyAreaSkill = UTL_OWF_TestData.createSkills('Test Skill22', CON_OWF.SKILL_TYPE_THERAPY_AREA);
        pse__Skill__c lineOfBusinessSkill = UTL_OWF_TestData.createSkills('Test Skill2', CON_OWF.SKILL_TYPE_LINE_OF_BUSINESS);
        pse__Skill__c iqviaBiotechSkill = UTL_OWF_TestData.createSkills(CON_OWF.IQVIA_BIOTECH_SKILL,CON_OWF.SKILL_TYPE_OPPORTUNITY_LEVEL);
        pse__Skill__c indicationSkill = UTL_OWF_TestData.createSkills('Test Skill2331', CON_OWF.SKILL_TYPE_INDICATION);
        insert new List<pse__Skill__c>{therapyAreaSkill, lineOfBusinessSkill,iqviaBiotechSkill,indicationSkill};

        Test.startTest();
        System.assert(resRequestList.size() > 0, 'Resource request list should not be empty.');

        // Step 3: Process Therapy Area Skill
        pse__Skill_Certification_Rating__c skillCertRating1 = UTL_OWF_TestData.createSkillCertificationRating(therapyAreaSkill.Id, contactList.Id);
        insert skillCertRating1;

        pse__Resource_Skill_Request__c resourceSkillRequest1 = UTL_OWF_TestData.createResourceSkillRequest(therapyAreaSkill.Id, resRequestList[0].Id);
        insert resourceSkillRequest1;

        therapyAreaSkill.Name = resourceSkillRequest1.pse__Resource_Request__r.pse__Opportunity__r.TherapyArea__c;
        update therapyAreaSkill;

        List<pse__Resource_Skill_Request__c> therapyResourceRequests = [
            SELECT Id, pse__Resource_Request__c, pse__Resource_Request__r.SubGroup__c 
            FROM pse__Resource_Skill_Request__c 
            WHERE pse__Skill_Certification__c = :therapyAreaSkill.Id
        ];

        List<DAOH_OWF_Resource_Skill_Request.ResourceCandidateMatchScore> therapyMatchScores = DAOH_OWF_Resource_Skill_Request.createResourceCandidateMatchScore(therapyResourceRequests);
        DAOH_OWF_Resource_Skill_Request.createResourceCandidateMatchScoreForTSSU(therapyResourceRequests);

        // Step 4: Process Line of Business Skill
        pse__Skill_Certification_Rating__c skillCertRating2 = UTL_OWF_TestData.createSkillCertificationRating(lineOfBusinessSkill.Id, contactList.Id);
        insert skillCertRating2;

        pse__Resource_Skill_Request__c resourceSkillRequest2 = UTL_OWF_TestData.createResourceSkillRequest(lineOfBusinessSkill.Id, resRequestList[0].Id);
        insert resourceSkillRequest2;

        lineOfBusinessSkill.Name = resourceSkillRequest2.pse__Resource_Request__r.pse__Opportunity__r.Line_Of_Business__c;
        update lineOfBusinessSkill;

        List<pse__Resource_Skill_Request__c> lobResourceRequests = [
            SELECT Id, pse__Resource_Request__c, pse__Resource_Request__r.SubGroup__c 
            FROM pse__Resource_Skill_Request__c 
            WHERE pse__Skill_Certification__c = :lineOfBusinessSkill.Id
        ];

        List<DAOH_OWF_Resource_Skill_Request.ResourceCandidateMatchScore> lobMatchScores = DAOH_OWF_Resource_Skill_Request.createResourceCandidateMatchScore(lobResourceRequests);
        DAOH_OWF_Resource_Skill_Request.createResourceCandidateMatchScoreForTSSU(lobResourceRequests);
        // 5
        pse__Skill_Certification_Rating__c skillCertRating3 = UTL_OWF_TestData.createSkillCertificationRating(iqviaBiotechSkill.Id, contactList.Id);
        insert skillCertRating3;

        pse__Resource_Skill_Request__c resourceSkillRequest3 = UTL_OWF_TestData.createResourceSkillRequest(iqviaBiotechSkill.Id, resRequestList[0].Id);
        insert resourceSkillRequest3;

    
        List<pse__Resource_Skill_Request__c> iqviaBiotechSkillResourceRequests = [
            SELECT Id, pse__Resource_Request__c, pse__Resource_Request__r.SubGroup__c 
            FROM pse__Resource_Skill_Request__c 
            WHERE pse__Skill_Certification__c = :iqviaBiotechSkill.Id
        ];

        List<DAOH_OWF_Resource_Skill_Request.ResourceCandidateMatchScore> iqviaMatchScores = DAOH_OWF_Resource_Skill_Request.createResourceCandidateMatchScore(iqviaBiotechSkillResourceRequests);
        DAOH_OWF_Resource_Skill_Request.createResourceCandidateMatchScoreForTSSU(iqviaBiotechSkillResourceRequests);
        contactList.sub_group__c ='DSB-LCS';
        update contactList;        
        pse__Skill_Certification_Rating__c indicationSkillCertRating2 = UTL_OWF_TestData.createSkillCertificationRating(indicationSkill.Id, contact.Id);
        insert indicationSkillCertRating2;
        pse__Resource_Skill_Request__c indicationResourceSkillRequest2 = UTL_OWF_TestData.createResourceSkillRequest(indicationSkill.Id, resourceRequest.Id);
        insert indicationResourceSkillRequest2;
        List<pse__Resource_Skill_Request__c> indicationResourceRequests = [
            SELECT Id, pse__Resource_Request__c, pse__Resource_Request__r.SubGroup__c 
            FROM pse__Resource_Skill_Request__c 
            WHERE pse__Skill_Certification__c = :indicationSkill.Id
        ];
        List<DAOH_OWF_Resource_Skill_Request.ResourceCandidateMatchScore> indicationMatchScores = DAOH_OWF_Resource_Skill_Request.createResourceCandidateMatchScore(indicationResourceRequests);
        DAOH_OWF_Resource_Skill_Request.createResourceCandidateMatchScoreForTSSU(indicationResourceRequests);
        Test.stopTest();
        System.assertNotEquals(0, therapyMatchScores.size(), 'Therapy Area match score list should not be empty.');
        System.assertNotEquals(0, lobMatchScores.size(), 'Line of Business match score list should not be empty.');
        System.assertNotEquals(0, iqviaBiotechSkillResourceRequests.size(), 'IQVIA Biotech Skill match score list should not be empty.');
        System.assertNotEquals(0, indicationResourceRequests.size(), 'IQVIA Biotech Skill match score list should not be empty.');


    }
    
    @isTest
    static void testMatchingPotencialRegion() {
        Contact contactList = [Select Id From Contact where sub_group__c = 'TSL' limit 1];
        pse__Grp__c grp = [Select Id From pse__Grp__c limit 1];
        Account acc = [Select Id From Account Where Name = 'TestAccount'];
        Opportunity opp = [Select Id From Opportunity Where Name = 'TestOpportunity'];
        pse__Skill__c skill = UTL_OWF_TestData.createSkills('Global', CON_OWF.SKILL_TYPE_POTENTIAL_REGION);
        insert skill;
        Bid_History__c bidHistory =[Select Id From Bid_History__c Where Bid_History_Related_Opportunity__c = :opp.id];
        pse__Proj__c project =[Select id from pse__Proj__c where Bid_History__c =: bidHistory.Id];
        Test.startTest();
        pse__Resource_Request__c resRequest = UTL_OWF_TestData.createResourceRequest(bidHistory.id,opp.id,project.id);
        resRequest.SubGroup__c = 'TSL';
        insert resRequest; 
        skill.name = resRequest.BD_Lead_Sub_Region__c;
    	update skill;
        pse__Skill_Certification_Rating__c skillCertRating = UTL_OWF_TestData.createSkillCertificationRating(skill.id, contactList.id);
       	insert skillCertRating;
        pse__Resource_Skill_Request__c resourceSkillRequest = UTL_OWF_TestData.createResourceSkillRequest(skill.Id, resRequest.Id);
        insert resourceSkillRequest;
        List<pse__Resource_Skill_Request__c> resourceSkillRequestList = [Select Id, pse__Resource_Request__c,pse__Resource_Request__r.SubGroup__c FROM pse__Resource_Skill_Request__c limit 1000];
        List<DAOH_OWF_Resource_Skill_Request.ResourceCandidateMatchScore> resourceCandidateMatchScoreList = DAOH_OWF_Resource_Skill_Request.createResourceCandidateMatchScore(resourceSkillRequestList);

        DAOH_OWF_Resource_Skill_Request.createResourceCandidateMatchScoreForTSSU(resourceSkillRequestList);    
    
        Test.stopTest(); 
 		System.assertNotEquals(0, resourceCandidateMatchScoreList.size(), 'Therapy Area match score list should not be empty.');
    
    }
    
    @isTest
    static void TestBdLeadSubRegion() {
       User user = [Select id, name, email from User where id=: UserInfo.getUserId()];
	   user.SUBREGION__c = 'Australia & NZ';
       update user;
       Contact contact = [Select Id From Contact where sub_group__c = 'TSL' limit 1];
       pse__Skill__c skill = UTL_OWF_TestData.createSkills('Test Skill', CON_OWF.SKILL_TYPE_THERAPY_AREA);
        insert skill;
        Test.startTest();
        List<pse__Resource_Request__c> resRequestList = [Select Id From pse__Resource_Request__c  where SubGroup__c = 'TSL'];
        pse__Skill_Certification_Rating__c skillCertRating = UTL_OWF_TestData.createSkillCertificationRating(skill.Id, contact.Id);
        insert skillCertRating;
        pse__Resource_Skill_Request__c resourceSkillRequest = UTL_OWF_TestData.createResourceSkillRequest(skill.Id, resRequestList.get(0).Id);
        insert resourceSkillRequest;    
        List<pse__Resource_Skill_Request__c> resourceSkillRequestList = [Select Id, pse__Resource_Request__c,pse__Resource_Request__r.SubGroup__c FROM pse__Resource_Skill_Request__c limit 1000];
        List<DAOH_OWF_Resource_Skill_Request.ResourceCandidateMatchScore> resourceCandidateMatchScoreList = DAOH_OWF_Resource_Skill_Request.createResourceCandidateMatchScore(resourceSkillRequestList);
        Test.stopTest();        
        system.assertNotEquals(0, resourceCandidateMatchScoreList.size(), 'Verifying TestBdLeadSubRegion Functionality');
    }

}
