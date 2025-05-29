/**
* This test class is used to test all methods in CON_OWF.
* version : 1.0
*/
@isTest
private class TST_CON_OWF {
    
    /**
    * This method is testing all constant variables in CON_OWF
    */
    static testMethod void testStageConstant() 
	{
        Test.startTest();
            String semicolon = CON_OWF.SEMI_COLON;
            Integer defaultBatchSize = CON_OWF.DEFAULT_BATCH_SIZE;
            String sObjectTypeAptsAgreement = CON_OWF.SOBJECT_TYPE_APTS_AGREEMENT;
            String opportunityAgreement = CON_OWF.OPPORTUNITY_AGREEMENTS;    
            String agreementProjects = CON_OWF.AGREEMENT_PROJECTS;
            String agreementResourceRequests = CON_OWF.AGREEMENT_RESOURCE_REQUESTS;
            String agreementAssignments = CON_OWF.AGREEMENT_ASSIGNMENTS;
            String assignmentStatus = CON_OWF.ASSIGNMENT_STATUS;
            String resourceRequestAssignments = CON_OWF.RESOURCE_REQUEST_ASSIGNMENTS;
            String owfStatusComplete = CON_OWF.OWF_STATUS_COMPLETE;
            String owfStatusAccepted = CON_OWF.OWF_STATUS_ACCEPTED;
            String owfStatusCompleted = CON_OWF.OWF_STATUS_COMPLETED;
            String owfStatusAssigned = CON_OWF.OWF_STATUS_ASSIGNED;
            String owfStatusPending = CON_OWF.OWF_STATUS_PENDING;
            String OwfResourceRequestRecordTypeName = CON_OWF.OWF_RESOURCE_REQUEST_RECORD_TYPE_NAME;
            String owfAssignmentRecordTypeName = CON_OWF.OWF_ASSIGNMENT_RECORD_TYPE_NAME;
            //Id owfClinicalBidAgreementRecordTypeId = CON_OWF.OWF_CLINICAL_BID_AGREEMENT_RECORD_TYPE_ID;
            Id owfNonRfpBidAgreementRecordTypeId = CON_OWF.OWF_NON_RFP_BID_BID_HISTORY_RECORD_TYPE_ID;
            Id owfAssignmentRecordTypeId = CON_OWF.OWF_ASSIGNMENT_RECORD_TYPE_ID;
        Test.stopTest();
        
        System.assertEquals(';', semicolon);
        System.assertEquals(200, defaultBatchSize);
        System.assertEquals('Apttus__APTS_Agreement__c', sObjectTypeAptsAgreement);
        System.assertEquals('Apttus__R00N50000001Xl0FEAS__r', opportunityAgreement);
        System.assertEquals('Projects__r', agreementProjects);
        System.assertEquals('Resource_Requests__r', agreementResourceRequests);
        System.assertEquals('Assignments__r', agreementAssignments);
        System.assertEquals('pse__Status__c', assignmentStatus);
        System.assertEquals('pse__Assignments__r', resourceRequestAssignments);
        System.assertEquals('Complete', owfStatusComplete);
        System.assertEquals('Accepted', owfStatusAccepted);
        System.assertEquals('Completed', owfStatusCompleted);
        System.assertEquals('Assigned', owfStatusAssigned);
        System.assertEquals('Pending', owfStatusPending);
        System.assertEquals('OWF_Resource_Request', OwfResourceRequestRecordTypeName);
        System.assertEquals('OWF_Assignment', owfAssignmentRecordTypeName);
        //System.assertEquals(Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('Clinical_Bid').getRecordTypeId(), owfClinicalBidAgreementRecordTypeId);
        System.assertEquals(Schema.SObjectType.Bid_History__c.getRecordTypeInfosByDeveloperName().get('Non_RFP_Bid').getRecordTypeId(), owfNonRfpBidAgreementRecordTypeId);
        System.assertEquals(Schema.SObjectType.pse__Assignment__c.getRecordTypeInfosByName().get('OWF Assignment').getRecordTypeId(), owfAssignmentRecordTypeId);
    }
}