/**
 * This test class is used to test all methods in FRUP trigger.
 * version : 1.0
 */
@isTest
public class TST_TGR_box_FRUP {
	/**
     * This test method used for insert FRUP record
     */
    @isTest
    static void testFRUPInsert(){
        box__FRUP__c boxFrup = new box__FRUP__c(box__Object_Name__c = 'Opportunity');
        Test.startTest();
        	insert boxFrup;
        Test.stopTest();
        List<box__FRUP__c> boxFrupList = [SELECT id, box__Object_Name__c FROM box__FRUP__c WHERE box__Object_Name__c = 'Opportunity'];
        Integer expected = 1;
        Integer actual = boxFrupList.size();
        System.assertEquals(expected, actual);
    }
}