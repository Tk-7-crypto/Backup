/*
 * Version       : 1.0
 * Description   : Test class for CNT_PEP_Attachments
 */ 
@isTest
public class TST_CNT_PEP_Attachments {

    @testSetup
    public static void setup(){ 
               
        User partnerUser = TST_PEP_TestDataFactory.createPartnerUser('partneruser@iqvia.partner.com');
        User partnerUser1 = TST_PEP_TestDataFactory.createPartnerUser('partneruser1@iqvia.partner.com');
        User adminUser = TST_PEP_TestDataFactory.createAdminUser('admin','adminPartner@iqvia.com');

        List<User> lstUsers = new List<User>{partnerUser,partnerUser1, adminUser};
        insert lstUsers;

        system.runAs(partnerUser){
            Id ctcId = partnerUser.contactId;
            List<Contact> ctc = [SELECT AccountId FROM Contact WHERE Id = :ctcId ];

            Contract ctr = TST_PEP_TestDataFactory.createContract('Contract1', ctc[0].AccountId );
            ctr.Parent_Contract_Number__c = 123;
            ctr.Ultimate_Parent_Contract_Number__c = 345;
            List<Contract> lstContract = new List<Contract>{ctr};
            insert lstContract;

            Attachment atch = TST_PEP_TestDataFactory.createAttachment('Attachment 1',ctr.id );
            insert atch;
        }
        
        system.runAs(partnerUser1){
            Id ctcId = partnerUser1.contactId;
            List<Contact> ctc = [SELECT AccountId FROM Contact WHERE Id = :ctcId ];

            Contract ctr = TST_PEP_TestDataFactory.createContract('Contract2', ctc[0].AccountId );
            ctr.Parent_Contract_Number__c = 123;
            ctr.Ultimate_Parent_Contract_Number__c = 345;
            List<Contract> lstContract = new List<Contract>{ctr};
            insert lstContract;
        }
        
        System.runAs(adminUser){
            Contract ctr = [SELECT Id from Contract where name = 'Contract1' limit 1];
            ContentDocumentLink cdl = TST_PEP_TestDataFactory.createContentDocLink(ctr.Id);
            insert cdl;
        }
    }

     @isTest
     public static void testFoundAttachments(){         
        User partnerUser = [SELECT id FROM User WHERE email='partneruser@iqvia.partner.com'];
        Id createdById = partnerUser.Id;
        Contract contractRec = [SELECT id FROM Contract WHERE createdbyId =: createdById limit 1 ];
        List<sObject> lstAttachment = new List<sObject>();

        System.runAs(partnerUser){
            
            Test.startTest();                 
                  lstAttachment = CNT_PEP_Attachments.getContentDoc(contractRec.Id);
            Test.stopTest();
         }       
        System.assertEquals(2,lstAttachment.size());       
    }

    @isTest
     public static void testFoundNoAttachments(){         
        User partnerUser = [SELECT id FROM User WHERE email='partneruser1@iqvia.partner.com'];
        Id createdById = partnerUser.Id;
        Contract contractRec = [SELECT id FROM Contract WHERE createdbyId =: createdById limit 1];
        List<sObject> lstAttachment = new List<sObject>();

        System.runAs(partnerUser){
            
            Test.startTest();               
                 lstAttachment = CNT_PEP_Attachments.getContentDoc(contractRec.Id);
            Test.stopTest();
         }       
        System.assertEquals(0,lstAttachment.size());       
    }
}