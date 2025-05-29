/**
* This test class is used to test all methods in Assignment trigger.
* version : 1.0
*/
@isTest
private class TST_TGR_SkillCertificationRating {
    
	/**
    * This method used to set up testdata
    */ 
    @testSetup
    static void dataSetup() 
    {
        PermissionSet ps = [SELECT ID From PermissionSet WHERE Name = 'OWF_Triage_Manager'];
        List<PermissionSetAssignment> psa = [Select id from PermissionSetAssignment where AssigneeId =:UserInfo.getUserId() AND PermissionSetId =:ps.Id];
        if(psa.size() == 0)
            insert new PermissionSetAssignment(AssigneeId = UserInfo.getUserId(), PermissionSetId = ps.Id);
        
		System.runAs(new User(Id = UserInfo.getUserId())) 
		{
            Account acc = UTL_OWF_TestData.createAccount();
            insert acc;
            pse__Grp__c grp = UTL_OWF_TestData.createGroup();
            insert grp;
            Contact cont = UTL_OWF_TestData.createContact(acc.Id);
            cont.pse__Is_Resource__c = true;
            cont.pse__Is_Resource_Active__c = true;
            cont.pse__Group__c = grp.Id;
            cont.pse__Salesforce_User__c = userInfo.getUserId();
            insert cont;     
            pse__Skill__c skill = UTL_OWF_TestData.createSkills('Test Skill','Indication');  
            insert skill;
		} 
    }
    
	
    /**
    * This test method used for insert Assignment record
    */
    static testmethod void testAssignmentInsert() 
    {
        System.runAs(new User(Id = UserInfo.getUserId())) 
		{
            Contact cont = [Select Id From Contact order by CreatedDate asc][0];
            pse__Skill__c skill = [select id from pse__Skill__c];
            pse__Skill_Certification_Rating__c rating1 = UTL_OWF_TestData.createSkillCertificationRating(skill.id,cont.id);
            pse__Skill_Certification_Rating__c rating2 = UTL_OWF_TestData.createSkillCertificationRating(skill.id,cont.id);
            Test.startTest();
				insert rating1;
				try{
					insert rating2;
				}catch(DMLException ex) {}
			Database.executeBatch(new BCH_OWF_UpdateSkillCert());
            Test.stopTest();
            
			Integer expected = 1;
            Integer actual = [Select Id From pse__Skill_Certification_Rating__c].size();
            system.assertEquals(expected, actual);
		}
    }
}