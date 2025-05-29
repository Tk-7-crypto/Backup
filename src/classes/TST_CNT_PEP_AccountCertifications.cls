/*
* Version       : 1.0
* Description   : Test class for CNT_PEP_AccountCertifications
*/
@isTest
public class TST_CNT_PEP_AccountCertifications {
    @testSetup
    static void dataSetup() { 
        Id prmProfileId = [select id from profile where name =: CON_PEP.S_P_PEP_COMMUNITY ].id;
        
        Account ac = new Account(Name = 'Acme',AccountCountry__c='BM', CustomerSegment__c = 'GOVERNMENT', Sub_Industry__c = 'STATE');
        insert ac; 
        
        Contact con = new Contact(FirstName = 'TestFirstName', LastName ='testCon',AccountId = ac.Id,Email='partneruser@iqvia.partner.com');
        con.Partner_Type__c = 'Integrator Partner; Data Partner';
        insert con; 
        
        User partnerUser = new User(alias = 'test123', email='partneruser@iqvia.partner.com',
                                    emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                                    localesidkey='en_US', profileid = prmProfileId, country='United States',IsActive =true,
                                    ContactId = con.Id,
                                    timezonesidkey='America/Los_Angeles', username='xyz123490@iqviaTestPartner.com');
        insert partnerUser;
        System.runAs(partnerUser){
            
            Id certificationRecordTypeId = Schema.SObjectType.Partner_Certification__c.getRecordTypeInfosByName().get('Admin Record').getRecordTypeId();
            Partner_Certification__c pc = new Partner_Certification__c();
            pc.RecordTypeId=certificationRecordTypeId;
            pc.Partner_Type__c='Integration Partner';
            pc.Certification_Name__c='ePromo - Integration Partner';
            pc.Badge_Variation__c='B1';
            pc.JPEG__c='Test Link1';
            pc.PNG__c='Test Link2';
            pc.SVG__c='Test Link3';
            pc.Is_Active__c=True;
            
            insert pc;
            
            Id certificationRecordTypeIdPSO = Schema.SObjectType.Partner_Certification__c.getRecordTypeInfosByName().get('Partner Certification Record').getRecordTypeId();
            Partner_Certification__c pcPSO = new Partner_Certification__c();
            pc.RecordTypeId=certificationRecordTypeIdPSO;
            pcPSO.Partner_Type__c='Integration Partner';
            pcPSO.Certification_Name__c='ePromo - Integration Partner';
            User us=[SELECT Contact.AccountId from user WHERE Id= : partnerUser.Id];
            pcPSO.Account__c=us.Contact.AccountId;
            pcPSO.Certification_Start_Date__c=Date.today();
            insert pcPSO;   
        }
    }
    
    @isTest
    public static void testGetAccountCertifications(){
        User partnerUser = [SELECT id FROM User WHERE email='partneruser@iqvia.partner.com'];
        System.runAs(partnerUser){
            Test.startTest();
            List<Partner_Certification__c> partnerCertifications = CNT_PEP_AccountCertifications.getAccountCertifications();
            Test.stopTest();
            
            System.assertEquals(1, partnerCertifications.size());
        }
    }
    
    @isTest
    public static void testGetBadgeVariations(){
        List<Partner_Certification__c> certificationName=[SELECT Certification_Name__c FROM Partner_Certification__c
                                                          WHERE Certification_Name__c='ePromo - Integration Partner'];
        
        Test.startTest();
        List<Partner_Certification__c> partnerCertifications = CNT_PEP_AccountCertifications.getBadgeVariations(certificationName[0].Certification_Name__c);
        Test.stopTest();
        
        System.assertEquals(1, partnerCertifications.size());
    }
    
    @isTest
    public static void testGetBadgeDownloadURL(){
        List<Partner_Certification__c> certificationDetail=[SELECT Certification_Name__c,Badge_Variation__c FROM Partner_Certification__c
                                                            WHERE Certification_Name__c='ePromo - Integration Partner'];
        String imageFormat1='JPEG';
        String imageFormat2='PNG';
        String imageFormat3='SVG';
        Test.startTest();
        String badgeURL1 = CNT_PEP_AccountCertifications.getBadgeDownloadURL(certificationDetail[0].Certification_Name__c,imageFormat1,certificationDetail[0].Badge_Variation__c);
        String badgeURL2  = CNT_PEP_AccountCertifications.getBadgeDownloadURL(certificationDetail[0].Certification_Name__c,imageFormat2,certificationDetail[0].Badge_Variation__c);
        String badgeURL3  = CNT_PEP_AccountCertifications.getBadgeDownloadURL(certificationDetail[0].Certification_Name__c,imageFormat3,certificationDetail[0].Badge_Variation__c);
        Test.stopTest();
        
        System.assertEquals('Test Link1',  badgeURL1);
        System.assertEquals('Test Link2', badgeURL2);
        System.assertEquals('Test Link3', badgeURL3);
    }
}