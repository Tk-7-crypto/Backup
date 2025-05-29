/**
 * This test class is used to test all methods in Skill Certificaiton Rating service class
 * version : 1.0
 */
@isTest
private class TST_SLT_Skill_Certification_Rating {

    /**
     * This method is used to setup data for all methods.
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
        }
    }
	
    
    /**
     * This test method used to cover basic methods
     */ 
    static testMethod void testServiceResourceRequest() {   
        List<Schema.SObjectField> resourceRequestList = new SLT_Skill_Certification_Rating().getSObjectFieldList();
        Schema.SObjectType resourceRequest = new SLT_Skill_Certification_Rating(true).getSObjectType();
        
        Integer expected = 0;
        System.assertEquals(expected, resourceRequestList.size());
    }
    
	
    /**
    * This method used to test the getSkillCertificationRatingsBySkills method
    */ 
    static testmethod void testGetSkillCertificationRatingsBySkills() {
        System.runAs(new User(Id = UserInfo.getUserId())) {
            pse__Skill__c skill = UTL_OWF_TestData.createSkills('Test Skill', CON_OWF.SKILL_TYPE_THERAPY_AREA);
            insert skill;
            List<Contact> contactList = [Select Id,Sub_Group__c From Contact];
            pse__Skill_Certification_Rating__c skillCertRating = UTL_OWF_TestData.createSkillCertificationRating(skill.Id, contactList.get(0).Id);
            insert skillCertRating;
            Set<ID> sObjectIdset = new Set<Id>{skill.Id};
            String skillCertRatingCondition = ' pse__Skill_Certification__c IN :sObjectIdSet ';
            Set<String> skillCertRatingFieldSet = new Set<String>{'Id', 'pse__Resource__c',  'pse__Skill_Certification__c', 'pse__Rating__c', 'pse__Skill_Certification__r.pse__Type__c'};
                Map<Id, pse__Skill_Certification_Rating__c> skillCertificationRatingsMap = new SLT_Skill_Certification_Rating(false).getSkillCertificationRatingsBySkills(sObjectIdset, skillCertRatingCondition, skillCertRatingFieldSet,new Set<String>{contactList.get(0).Sub_Group__c});
            
            String expected = skill.Id;
			String actual = String.valueof(skillCertificationRatingsMap.values()[0].get('pse__Skill_Certification__c'));
            system.assertEquals(expected, actual);
        }
    }
    
	
     /**
    * This method used to test the getSkillCertificationRatingsByContactIdsOrdering method
    */ 
    static testmethod void testGetSkillCertificationRatingsByContactIdsOrdering() 
	{
        System.runAs(new User(Id = UserInfo.getUserId())) 
		{
			pse__Skill__c skill = UTL_OWF_TestData.createSkills('Test Skill', CON_OWF.SKILL_TYPE_THERAPY_AREA);
			insert skill;
			List<Contact> contactList = [Select Id From Contact];
			pse__Skill_Certification_Rating__c skillCertRating = UTL_OWF_TestData.createSkillCertificationRating(skill.Id, contactList.get(0).Id);
			insert skillCertRating;
			Set<Id> resourceId = (new Map<Id,Contact>(contactList)).keySet();
			String skillCertRatingCondition = ' pse__Skill_Certification__c IN :resourceIdSet ';
			Set<String> skillCertRatingFieldSet = new Set<String>{'Id', 'pse__Resource__c',  'pse__Skill_Certification__c', 'pse__Rating__c', 'pse__Skill_Certification__r.pse__Type__c'};
			Map<Id, pse__Skill_Certification_Rating__c> skillCertificationRatingsMap = new SLT_Skill_Certification_Rating(false).getSkillCertificationRatingsByContactIdsOrdering(resourceId, new Set<Id> {}, skillCertRatingCondition, skillCertRatingFieldSet);

			Integer expected = 0;
			System.assertEquals(expected, skillCertificationRatingsMap.size());             
        }
    }
}