/*
*@Author  : Chandra Prakash Pandey
*@Purpose : 1. Test class for BCH_TPA_Business_Rule_Notification Batch which sends notification to TP Processor in case of potential vendor to click run tpa business rule button.
	
*/
@isTest(seeAllData = false)
public class TST_SCH_TPA_Run_Business_Rule {
    public static Address__c TestAccount ;
	/*
	Method to test Batch class that sends reminder mails to the vendors to submit their part.
	*/
	public static testMethod void testSendClickBussinessRuleMail() {
		
		UTL_TPA_SetupTestData.createMultilingualTemplateSettingData();
		UTL_TPA_SetupTestData.createTPASettingData();
		TPA_Request__c objTpaReq = getTPARequest();
		AMA_Agreement_Detail__c amaObj = UTL_TPA_SetupTestData.getAMAAgreementDetailBlank(objTpaReq.Id);
        amaObj.Vendor_AMA_Fee_Response__c = 'acknowledged';
		insert amaObj;

		TPA_Request__c objTpaReq1 = getTPARequest();
		AMA_Agreement_Detail__c amaObj1 = UTL_TPA_SetupTestData.getAMAAgreementDetailBlank(objTpaReq1.Id);
		objTpaReq1.Is_Potential_Vendor_Case__c = false;
		update objTpaReq1;
		//amaObj1.Vendor_AMA_Fee_Response__c = 'acknowledged';
		insert amaObj1;

		//UTL_TPA_SetupTestData.addAttachmentToParent(objTpaReq1.id, 'Original_Use Defination Template');
		//UTL_TPA_SetupTestData.addAttachmentToParent(objTpaReq1.id, 'Original TLLA TPA Limited License Agreement');  

		        
		Test.startTest();      
		
		String CRON_EXP = '0 0 0 3 9 ? ' + (Date.Today().year() + 1);
		String jobId = System.schedule('testScheduler', CRON_EXP, new SCH_TPA_Run_Business_Rule());
		
		Test.stopTest();
	}
	

	public static TPA_Request__c getTPARequest()
	{
        List<Address__c> ListAccount = [Select id,Name  From Address__c where Name like 'TPA Test Account' LIMIT 1];
	 	if(ListAccount.size() == 0)
	 	{
           TestAccount = UTL_TPA_SetupTestData.getTestAccount();
        }
        else{
          TestAccount =  ListAccount[0];
        }
		Date todayDate = Date.today();
		TPA_Request__c tpaRequest = new TPA_Request__c(
		OwnerId = UserInfo.getUserId(),
		Client_Region__c = 'US',
		Data_Provided_By__c = 'IQVIA in lieu of Client',
		Is_Data_Accessed_Via_IMS_Software__c = 'Yes',
		AMA_USPrescriberData__c = 'Yes',
		Does_the_request_require_information_con__c = 'Yes',
		Service_Provider_Address__c = TST_UTL_TPA_Multilingual.getTestAccount().Id,
		Vendor_Company_Name__c = 'Test company',
		Is_Submitted__c = true,
		Request_Status__c = 'In Review By IQVIA',
		Data_Access_Start_Date__c = todayDate,
		Data_Access_End_Date__c = todayDate.addDays(3),
		Vendor_e_mail__c = 'test@mail.com',
		Vendor_contact_email_client__c = 'test@mail.com',
		TP_Processor_Email__c = 'test@mail.com',
		Is_Potential_Vendor_Case__c = false,
	//	In_Auto_Approval_Process__c = todayDate.addDays(3),
		In_IMS_Review__c = todayDate.addDays(5)
		//TPA_Approved_Awaiting_AMA_Approval__c = todayDate.addDays(4)
		);
		insert tpaRequest;

		
		return tpaRequest; 
	}
}