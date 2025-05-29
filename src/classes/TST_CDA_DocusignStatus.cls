/**
 * @author      : Babita Dadarwal
 * Test class for TGRH_DocusignStatus
 */

@isTest(seeAllData=false)
public class TST_CDA_DocusignStatus {

    @testSetup
    static void setupData() {
        TST_CDA_SetupData testSetup = new TST_CDA_SetupData();
        //Added by Vikram Singh under CR-11576 Start
        testSetup.setUpCustomSetting();
		CDA_Approved_Governing_Law_Location__c governingLaw = TST_CDA_SetupData.getGoverningLaw('Test GL');
		insert governingLaw;
		QI_Legal_Entity__c testQiLegalEntity = TST_CDA_SetupData.createQiLegalEntity('Test Entity1', UTL_CDAUtility.CDA_BUSINESS_PART_LQ, governingLaw);
		insert testQiLegalEntity;
		//Added by Vikram Singh under CR-11576 End
        testSetup.setupTestDataForCustomer(testQiLegalEntity);  //Updated by Vikram Singh under CR-11576
    }

    @isTest
    static void docusignStatusTest() {
        Test.startTest();
        List<CDA_Request__c> cdaRequestList = [SELECT id, Name, RecordTypeId
                                               FROM CDA_Request__c
                                               LIMIT 1];
        dsfs__DocuSign_Status__c DSStatus = TST_CDA_SetupData.getDSStatusByRequestId(cdaRequestList[0].Name);
        system.assertNotEquals(null, DSStatus.Id);

        DSStatus.dsfs__Envelope_Status__c = 'Declined';
        update DSStatus;
        system.assertEquals('Declined',[Select id,dsfs__Envelope_Status__c from dsfs__DocuSign_Status__c  where id= : DSStatus.id][0].dsfs__Envelope_Status__c);

        list<dsfs__DocuSign_Status__c> dsStatusList = [SELECT id FROM dsfs__DocuSign_Status__c];
        system.assertEquals(1, dsStatusList.size());
		try {
             delete dsStatusList ;
        }
        catch (Exception e) { 
        }
        Test.stopTest();
    }

    @isTest
    static void updateDocuSign_SignedStatusRecordsTest() {
       
        List<CDA_Request__c> cdaRequestList = [SELECT id, Name, RecordTypeId
                                               FROM CDA_Request__c
                                               LIMIT 1];
        dsfs__DocuSign_Status__c DSStatus = TST_CDA_SetupData.getDSStatusByRequestId(cdaRequestList[0].Name);
        
        List<dsfs__DocuSign_Status__c> statusList = new List<dsfs__DocuSign_Status__c>();
        statusList.add(DSStatus);
        Contract testContract = new Contract();
        testContract.Name = 'Test Contract';
        List<Contract> cnt= new List<Contract>{testContract};
        DAOH_DocusignStatus.testContractList=cnt;
        DAOH_DocusignStatus.useMock = true; 
        
        Test.startTest();
            DAOH_DocusignStatus.updateDocuSign_SignedStatusRecords(statusList);
        Test.stopTest();
        
        DAOH_DocusignStatus.useMock = false;
        
        System.assertNotEquals(Null, DSStatus.dsfs__DocuSign_Envelope_ID__c, 'Error while updating Docusgin Status!!');
    }
}