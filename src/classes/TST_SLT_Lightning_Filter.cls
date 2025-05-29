/*
 * Version       : 1.0
 * Description   : Test Class for TST_SLT_Lightning_Filter
 */
@isTest
public class TST_SLT_Lightning_Filter {

    /**
     * This method used to get a filter for a program
     */
    @IsTest
    static void testGetLightningFilterByProgram() {

        Program__c program = new Program__c(Name = 'TestClassProgram');
        insert program;  

        Lightning_Filter__c newFilter = new Lightning_Filter__c(Program__c=program.Id);
        insert newFilter;

        Test.startTest();
        Set<String> fieldSet = new SLT_Lightning_Filter().getSObjectFieldSet();
        Lightning_Filter__c filter = new SLT_Lightning_Filter().getLightningFilterByProgram(program.Id, fieldSet);
        Test.stopTest();

        System.assert(filter != null, 'Expected to get a filter, but got null');
        System.assertEquals(newFilter.Id, filter.Id); 
    }
}