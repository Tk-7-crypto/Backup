/**
* This test class is used to test all methods in BCH_OWF_UpdateSkillCert Class.
* version : 1.0
*/
@isTest
private class TST_BCH_OWF_UpdateSkillCert {
   
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
        insert skillCertificationRating1;
    }
    
    /**
    * This test method used for checkIfRatingAlreadyExists method
    */
    @isTest
    static void testBatchExecuteMethod() 
	{
        Test.startTest();
            BCH_OWF_UpdateSkillCert batch = new BCH_OWF_UpdateSkillCert();
            database.executeBatch(batch, 10);    
        Test.stopTest();
        
		Boolean expected = False;
        List<pse__Skill_Certification_Rating__c> SkillCertificationList = [select Id, Is_Duplicate__c from pse__Skill_Certification_Rating__c limit 10];
        Boolean actual = SkillCertificationList[0].Is_Duplicate__c;
        system.assertEquals(expected, actual,'Verifying BCH_OWF_UpdateSkillCert Functionality');
    }
}