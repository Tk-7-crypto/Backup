/*
* Version       : 1.0
* Description   : Apex Controller for LXC_PEP_CertificationPage
*/
public with sharing class CNT_PEP_AccountCertifications {
    
    @AuraEnabled
    public static List<Partner_Certification__c> getAccountCertifications(){
        Date todayDate=Date.today();
        Id userInfo=UserInfo.getUserId();
        User contactUser = new SLT_User().selectUserByLoggedInUser(userInfo);
        String userAccountId=contactUser.Contact.AccountId;
        Id certificationRecordTypeId = Schema.SObjectType.Partner_Certification__c.getRecordTypeInfosByName().get('Partner Certification Record').getRecordTypeId();
        Id adminCertificationRecordTypeId = Schema.SObjectType.Partner_Certification__c.getRecordTypeInfosByName().get('Admin Record').getRecordTypeId();
        List<Partner_Certification__c> lstAccountCertification = new List<Partner_Certification__c>();
        List<Partner_Certification__c> lstValidCertification = new List<Partner_Certification__c>();
        List<Partner_Certification__c> lstAdminCert = new List<Partner_Certification__c>();
        List<Partner_Certification__c> updateBadgeURL = new List<Partner_Certification__c>();
        
        lstAccountCertification= new SLT_Partner_Certification().getAccountCertifications(certificationRecordTypeId,userAccountId);
        
        Set<String> setOfCertificationNames=new Set<String>();
        if(lstAccountCertification.size()>0)
        {
            for(Partner_Certification__c pc:lstAccountCertification)
            {
                if(pc.Certification_End_Date__c==NULL)
                {
                    lstValidCertification.add(pc);
                    setOfCertificationNames.add(pc.Certification_Name__c);
                }
                else if(pc.Certification_End_Date__c!=NULL && pc.Certification_End_Date__c>= todayDate)
                {
                    lstValidCertification.add(pc);
                    setOfCertificationNames.add(pc.Certification_Name__c);
                }
            }
        }
        map<String, String> mapOfCertificationNameAndAdmin = new map<String, String>();
        lstAdminCert=new SLT_Partner_Certification().getAdminBadgeURL(adminCertificationRecordTypeId,setOfCertificationNames);
        
        for(Partner_Certification__c adminRecord : lstAdminCert) {
            if(!mapOfCertificationNameAndAdmin.containsKey(adminRecord.Certification_Name__c )){
                mapOfCertificationNameAndAdmin.put(adminRecord.Certification_Name__c, adminRecord.Badge_Url__c);
            }
        }
        
        for(Partner_Certification__c pc: lstValidCertification)
        {
            if(mapOfCertificationNameAndAdmin.containsKey(pc.Certification_Name__c) && 
               mapOfCertificationNameAndAdmin.get(pc.Certification_Name__c) != pc.Badge_URL__c) {
                   pc.Badge_URL__c=mapOfCertificationNameAndAdmin.get(pc.Certification_Name__c);
                   updateBadgeURL.add(pc);
               }
        }
        update updateBadgeURL;
        return lstValidCertification;
    }
    
    @AuraEnabled
    public static List<Partner_Certification__c> getBadgeVariations(String certificationName){
        Id certificationRecordTypeId = Schema.SObjectType.Partner_Certification__c.getRecordTypeInfosByName().get('Admin Record').getRecordTypeId();
        List<Partner_Certification__c> badgeVariations = new List<Partner_Certification__c>();
        
        badgeVariations=new SLT_Partner_Certification().getBadgeListByCertificationName(certificationName,certificationRecordTypeId);
        
        return badgeVariations;
    }
    
    @AuraEnabled
    public static String getBadgeDownloadURL(String certificationName,String imageFormat,String badgeVariation){
        Id certificationRecordTypeId = Schema.SObjectType.Partner_Certification__c.getRecordTypeInfosByName().get('Admin Record').getRecordTypeId();
        List<Partner_Certification__c> badgeImageFormatList = new List<Partner_Certification__c>();
        String badgeURL='';
        
        badgeImageFormatList=new SLT_Partner_Certification().getImageFormatList(certificationRecordTypeId,certificationName,badgeVariation);
        
        if(imageFormat=='JPEG')
        {
            badgeURL=badgeImageFormatList[0].JPEG__C;
        }
        else if(imageFormat=='PNG')
        { 
            badgeURL=badgeImageFormatList[0].PNG__c;
        }
        else if(imageFormat=='SVG')
        {
            badgeURL=badgeImageFormatList[0].SVG__c;
        }
        return badgeURL;
    }
}