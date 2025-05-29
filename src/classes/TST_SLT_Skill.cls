/**
 * This test class is used to test all methods in Skill selector class
 * version : 1.0
 */
 
@isTest
private class TST_SLT_Skill {
    
	/**
     * This test method used to cover basic methods
     */ 
    static testMethod void testGetAllSkillRecords() 
	{   
        Set<String> fieldSet = new Set<String>{'Id'};
        Map<Id, pse__Skill__c> skillIdToSkillMap = new SLT_Skill().getAllSkillRecords(fieldSet);
        Map<Id, pse__Skill__c> skillIdToSkillsMap = new SLT_Skill(false, false).getAllSkillRecords(fieldSet);
        
        Integer expected = 0;
		System.assertEquals(expected, skillIdToSkillMap.size());
    }   
}