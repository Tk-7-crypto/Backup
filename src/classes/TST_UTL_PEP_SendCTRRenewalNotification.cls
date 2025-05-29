/*
 * Version       : 1.0
 * Description   : Test class for UTL_PEP_SendCTRRenewalNotification
 */
@isTest
public class TST_UTL_PEP_SendCTRRenewalNotification {
   
	@testSetup
    public static void setup(){        
        User partnerUser = TST_PEP_TestDataFactory.createPartnerUser('partneruser@iqvia.partner.com');
        partnerUser.PortalRole = 'Manager';
       
        User adminUser = TST_PEP_TestDataFactory.createAdminUser('admin','adminPartner@iqvia.com');
        List<User> lstUsers = new List<User>{partnerUser, adminUser};
        insert lstUsers;
        
        System.runAs(adminUser){
	        Id ctcId = partnerUser.contactId;
            Contact ctc = [SELECT AccountId FROM Contact WHERE Id = :ctcId ];

            Contract ctr = TST_PEP_TestDataFactory.createContract('Contract1', ctc.AccountId );
            Contract ctr2 = TST_PEP_TestDataFactory.createContract('Contract2', ctc.AccountId );
             List<Contract> lstContract = new List<Contract>{ctr, ctr2};
            insert lstContract;
	     }       
     }
    
     @isTest
     public static void testContractRenewal(){ 
         List<Contract> ctrList = new List<Contract>();
         User partnerUser = [SELECT id, contactId FROM User WHERE email='partneruser@iqvia.partner.com'];
         Id ctcId = partnerUser.contactId;
         Contact ctc = [SELECT AccountId, Email FROM Contact WHERE Id = :ctcId ];
         List<Contract> lstCtr = [SELECT Id, renewal_date__c , recordtypeId , AccountId from Contract where AccountId=: ctc.AccountId ];
         User adminUser = [SELECT id, contactId FROM User WHERE email='adminPartner@iqvia.com'];

        System.runAs(adminUser){
            lstCtr[0].renewal_date__c = system.today();
            update(lstCtr);
            Test.startTest();	
            UTL_PEP_SendCTRRenewalNotification.contractDetails ctrDet = new UTL_PEP_SendCTRRenewalNotification.contractDetails();
            //ctrDet.aContact = ctc;
            ctrDet.aContract = lstCtr[0];
            List<UTL_PEP_SendCTRRenewalNotification.contractDetails> lstCtrDet = new List<UTL_PEP_SendCTRRenewalNotification.contractDetails>();
            lstCtrDet.add(ctrDet);
            UTL_PEP_SendCTRRenewalNotification.sendNotifToManager(lstCtrDet);
            Integer invocations = Limits.getEmailInvocations();
	        Test.stopTest();
            system.assertEquals(1, invocations, 'message');
	     }          
    }
}