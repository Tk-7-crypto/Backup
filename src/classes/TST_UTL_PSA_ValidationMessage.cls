@istest
public class TST_UTL_PSA_ValidationMessage {
    
    @testSetup
    static void dataSetup(){
        LR_Project_Overview__c lrRec = UTL_PSA_TestData.createLRProjectOverview();
        insert lrRec;
        
        CFI_Meetings__c cm = UTL_PSA_TestData.createCfiMeetings();
        cm.LR_Project_Overview__c = lrRec.Id;
        insert cm;
        
    }
    
    @isTest
    static void testAddErrorAndGenerate() {
        Test.startTest();
            LR_Project_Overview__c lrRec = [Select Id,Status__c,Countries__c,Abstracts_Reviewed__c from LR_Project_Overview__c where LR_Database__c = 'DistillerSR' limit 1];
            lrRec.Status__c = 'In Progress';
            update lrRec;
            Validation_Mapping_Generate_Message__c vmg = new Validation_Mapping_Generate_Message__c();
            vmg.Name = 'Test';
            vmg.Object_Name__c = 'LR_Project_Overview__c';
            vmg.Parent_Condition_Field_Value__c = 'In Progress';
            vmg.Parent_Condition_Field_Api_Name__c = 'Status__c';
            vmg.Required_Parent_Fields__c ='Countries__c,Abstracts_Reviewed__c';
            vmg.Unique_Number__c = '01';
            vmg.Is_Required_Child__c = true;
            vmg.Required_Child_Fields__c = 'Account__c,Project_Codes__c,AR_Type__c,Date_Held__c,LR_Represented_CFI_Attendance__c,Rationale_of_LR_Non_Attendance__c';
            vmg.Required_Child_Objects__c = 'CFI_Meetings__c';
            insert vmg;
            
            Validation_Mapping_Generate_Message__c vmg1 = new Validation_Mapping_Generate_Message__c();
            vmg1.Name = 'Test 1';
            vmg1.Object_Name__c = 'LR_Project_Overview__c';
            vmg1.Parent_Condition_Field_Value__c = 'In Progress';
            vmg1.Parent_Condition_Field_Api_Name__c = 'Status__c';
            vmg1.Required_Parent_Fields__c ='Countries__c,Abstracts_Reviewed__c';
            vmg1.Unique_Number__c = '01';
            vmg1.Is_Required_Child__c = true;
            vmg1.Required_Child_Fields__c = 'Account__c,Project_Codes__c,AR_Type__c,Date_Held__c,LR_Represented_CFI_Attendance__c,Rationale_of_LR_Non_Attendance__c';
            vmg1.Required_Child_Objects__c = 'CFI_Meetings__c';
            insert vmg1;
            UTL_PSA_ValidationMessage.addErrorAndGenerate( true,'LR_Project_Overview__c',true, new List<Sobject>{lrRec},true);
        Test.stopTest();
    }
}
 
