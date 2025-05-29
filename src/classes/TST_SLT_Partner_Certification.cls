/*
* Version       : 1.0
* Description   : Test class for SLT_Partner_Certification
*/ 
@isTest
public class TST_SLT_Partner_Certification {
    @testSetup 
    static void dataSetup() { 
        User partnerUser = TST_PEP_TestDataFactory.createPartnerUser('partneruser@iqvia.partner.com');
        System.runAs(partnerUser){
            Account ac = new Account(name ='Acme1',CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE') ;
            ac.AccountCountry__c = 'BM' ;
            insert ac; 
            
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
            pc.Is_Default__c=True;
            
            insert pc;
            
            Id certificationRecordTypeIdPSO = Schema.SObjectType.Partner_Certification__c.getRecordTypeInfosByName().get('Partner Certification Record').getRecordTypeId();
            Partner_Certification__c pcPSO = new Partner_Certification__c();
            pc.RecordTypeId=certificationRecordTypeIdPSO;
            pcPSO.Partner_Type__c='Integration Partner';
            pcPSO.Certification_Name__c='ePromo - Integration Partner';
            pcPSO.Account__c=partnerUser.AccountId;
            pcPSO.Certification_Start_Date__c=Date.today();
            insert pcPSO;   
        }
    }
    
    
    @isTest
    static void testGetAccountCertifications(){
        User partnerUser = [SELECT id,AccountId FROM User WHERE email='partneruser@iqvia.partner.com'];
        String userAccountId=partnerUser.AccountId;
        Id certificationRecordTypeIdPSO = Schema.SObjectType.Partner_Certification__c.getRecordTypeInfosByName().get('Partner Certification Record').getRecordTypeId();
        Test.startTest();
        List<Partner_Certification__c> partnerCertifications =new SLT_Partner_Certification().getAccountCertifications(certificationRecordTypeIdPSO,userAccountId);
        Test.stopTest();
        
        System.assertEquals(0, partnerCertifications.size());
        
    }
    
    @isTest
    static void testGetBadgeListByCertificationName(){
        Id certificationRecordTypeId = Schema.SObjectType.Partner_Certification__c.getRecordTypeInfosByName().get('Admin Record').getRecordTypeId();
        List<Partner_Certification__c> certificationName=[SELECT Certification_Name__c FROM Partner_Certification__c
                                                          WHERE Certification_Name__c='ePromo - Integration Partner'];
        Test.startTest();
        List<Partner_Certification__c> partnerCertifications = new SLT_Partner_Certification().getBadgeListByCertificationName(certificationName[0].Certification_Name__c,certificationRecordTypeId);
        Test.stopTest();
        
        System.assertEquals(1, partnerCertifications.size());
    }
    
    @isTest
    static void testGetImageFormatList(){
        Id certificationRecordTypeId = Schema.SObjectType.Partner_Certification__c.getRecordTypeInfosByName().get('Admin Record').getRecordTypeId();
        List<Partner_Certification__c> certificationName=[SELECT Certification_Name__c,Badge_Variation__c FROM Partner_Certification__c
                                                          WHERE Certification_Name__c='ePromo - Integration Partner'];
        Test.startTest();
        List<Partner_Certification__c> partnerCertifications = new SLT_Partner_Certification().getImageFormatList(certificationRecordTypeId,certificationName[0].Certification_Name__c,certificationName[0].Badge_Variation__c);
        Test.stopTest();
        
        System.assertEquals(1, partnerCertifications.size());
    }
    
    @isTest
    static void testGetAdminBadgeURL(){
        Id certificationRecordTypeId = Schema.SObjectType.Partner_Certification__c.getRecordTypeInfosByName().get('Admin Record').getRecordTypeId();
        List<Partner_Certification__c> certificationName=[SELECT Certification_Name__c,Badge_Variation__c FROM Partner_Certification__c
                                                          WHERE Certification_Name__c='ePromo - Integration Partner'];
        Set<String> setOfCertificationNames=new Set<String>{certificationName[0].Certification_Name__c};
        Test.startTest();
        List<Partner_Certification__c> partnerCertifications = new SLT_Partner_Certification().getAdminBadgeURL(certificationRecordTypeId,setOfCertificationNames);
        Test.stopTest();
        
        System.assertEquals(1, partnerCertifications.size());
    }
}