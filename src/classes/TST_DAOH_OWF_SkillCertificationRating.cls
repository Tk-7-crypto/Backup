/**
* This test class is used to test all methods in DAOH_OWF_SkillCertificationRating Class.
* version : 1.0
*/
@isTest
private class TST_DAOH_OWF_SkillCertificationRating {
    
    @testSetup
    static void dataSetup() 
    {
        
        Account acc = UTL_OWF_TestData.createAccount();
        insert acc;
        pse__Grp__c grp = UTL_OWF_TestData.createGroup();
        insert grp;
        Contact cont = UTL_OWF_TestData.createContact(acc.Id);
        cont.pse__Is_Resource__c = true;
        cont.pse__Is_Resource_Active__c = true;
        cont.pse__Group__c = grp.Id;
        cont.FirstName = UserInfo.getFirstName();
        cont.LastName = UserInfo.getLastName();
        cont.pse__Salesforce_User__c = userInfo.getUserId();
        insert cont;
        pse__Skill__c skill = UTL_OWF_TestData.createSkills('Test Skill',CON_OWF.SKILL_TYPE_INDICATION);
        insert skill;
        pse__Skill__c skillInstance = UTL_OWF_TestData.createSkills('Test Skill New',CON_OWF.SKILL_TYPE_INDICATION);
        insert skillInstance;
        pse__Skill_Certification_Rating__c skillCertificationRating1 = UTL_OWF_TestData.createSkillCertificationRating(skill.Id, cont.Id);
        skillCertificationRating1.Language__c ='ar';
        insert skillCertificationRating1;
        pse__Skill_Certification_Rating__c skillCertificationRating3 = UTL_OWF_TestData.createSkillCertificationRating(skillInstance.Id, cont.Id);
        insert skillCertificationRating3;
    }
    
    
    /**
    * This test method used for setDefaultFields method
    */
    static testmethod void testsetDefaultFields()
    {
        Date toadys_Date = System.today();
        List<pse__Skill_Certification_Rating__c> skillCertList = [select Id,pse__Evaluation_Date__c,pse__Skill_Certification__r.Name from pse__Skill_Certification_Rating__c];
        Boolean assertionResult = true;     
        Test.startTest();
        if(skillCertList.size() > 0){   
            for(pse__Skill_Certification_Rating__c unitRecord: skillCertList){
                if(unitRecord.pse__Evaluation_Date__c != toadys_Date){
                    assertionResult = false;
                    break;
                }
            }
        }
        Test.stopTest();
        
        system.assertEquals(true, assertionResult,'The result should be true');  
    }
    
    
    /**
    * This test method used for checkIfRatingAlreadyExists method
    */
    static testmethod void testCheckIfRatingAlreadyExists() 
    {
        List<pse__Skill_Certification_Rating__c> skillCertificationList = [Select id, pse__Resource__c, pse__Skill_Certification__c FROM pse__Skill_Certification_Rating__c];                                                                 
        pse__Skill_Certification_Rating__c skillCertificationRating2 = UTL_OWF_TestData.createSkillCertificationRating(skillCertificationList[0].pse__Skill_Certification__c , skillCertificationList[0].pse__Resource__c);
        Test.startTest();
        Database.insert( skillCertificationRating2,false);
        Test.stopTest();
        
        skillCertificationList = [Select id, pse__Resource__c, pse__Skill_Certification__c FROM pse__Skill_Certification_Rating__c];
        system.assertEquals(2, skillCertificationList.size());
    }
    
    
    /**
    * This test method used for setSelfIsDuplicateFlag method
    */
    static testmethod void testupdateDuplicateFlag_update() 
    {
        List<pse__Skill_Certification_Rating__c> skillCertificationList = [Select id, pse__Resource__c, pse__Skill_Certification__c, pse__Numerical_Rating__c, pse__Rating__c FROM pse__Skill_Certification_Rating__c LIMIT 1];
        Test.startTest();
        skillCertificationList[0].pse__Rating__c = '2 - Some Familiarity';
        skillCertificationList[0].Language__c = 'ar';
        update skillCertificationList[0];
        Test.stopTest();
        
        skillCertificationList = [Select id, Is_Duplicate__c FROM pse__Skill_Certification_Rating__c where Id =: skillCertificationList[0].Id ];
        system.assertEquals(false, skillCertificationList[0].Is_Duplicate__c);
    }
    
    
    /**
    * This test method used for setIsDuplicateFlag method
    */
    static testmethod void testupdateDuplicateFlag_delete() 
    {
        List<pse__Skill_Certification_Rating__c> skillCertificationList = [Select id, pse__Resource__c, pse__Skill_Certification__c FROM pse__Skill_Certification_Rating__c LIMIT 1];
        Test.startTest();
        delete skillCertificationList;
        Test.stopTest();
        
        skillCertificationList = [Select id, pse__Resource__c, pse__Skill_Certification__c FROM pse__Skill_Certification_Rating__c  where Id =: skillCertificationList[0].Id];
        system.assertEquals(0, skillCertificationList.size());
    }
    
    /**
    * This test method used for bindRFPRankingWithRating method
    */
    static testmethod void testbindRFPRankingWithRating() 
    {
        List<pse__Skill_Certification_Rating__c> skillCertificationList = [Select id, pse__Resource__c, pse__Skill_Certification__c,RFP_Ranking__c FROM pse__Skill_Certification_Rating__c LIMIT 1];
        skillCertificationList[0].RFP_Ranking__c ='RFP Ranking 5';
        
        Test.startTest();
        update skillCertificationList;
        skillCertificationList[0].RFP_Ranking__c ='RFP Ranking 1';
        update skillCertificationList;
 		 skillCertificationList[0].RFP_Ranking__c ='RFP Ranking 2';
        update skillCertificationList;
          skillCertificationList[0].RFP_Ranking__c ='RFP Ranking 3';
        update skillCertificationList;
          skillCertificationList[0].RFP_Ranking__c ='RFP Ranking 4';
        update skillCertificationList;
        Test.stopTest();
        
        skillCertificationList = [Select id, pse__Resource__c, pse__Skill_Certification__c,pse__Rating__c FROM pse__Skill_Certification_Rating__c  where Id =: skillCertificationList[0].Id];
        system.assertEquals(1, skillCertificationList.Size());
    }
}
