public class SLT_Partner_Certification
{  
    public List<Partner_Certification__c> getAccountCertifications(String certificationRecordTypeId,String userAccountId)
    {
        Date todayDate=Date.today();
        return  Database.query('SELECT Id,Certification_Name__c,Certification_Start_Date__c,Certification_End_Date__c,Badge_URL__c FROM Partner_Certification__c WHERE RecordTypeId =:certificationRecordTypeId AND Account__c =:userAccountId AND Certification_Start_Date__c <=: todayDate AND Is_Active__c=True ORDER BY Partner_Type__c DESC,Certification_Name__c DESC');
    }
    
    public List<Partner_Certification__c> getBadgeListByCertificationName(String certificationName,String certificationRecordTypeId)
    {
        return  Database.query('SELECT Id,Name,Certification_Name__c,Badge_URL__c,Badge_Variation__c FROM Partner_Certification__c WHERE Certification_Name__c=: certificationName AND RecordTypeId =:certificationRecordTypeId AND Is_Active__c=True ORDER BY Badge_Variation__c');
    }
    
    public List<Partner_Certification__c> getImageFormatList(String certificationRecordTypeId,String certificationName,String badgeVariation)
    {
        return  Database.query('SELECT Id,Certification_Name__c,Badge_URL__c,Badge_Variation__c,JPEG__c,PNG__c,SVG__c FROM Partner_Certification__c WHERE Certification_Name__c=:certificationName  AND RecordTypeId =:certificationRecordTypeId AND Badge_Variation__c =:badgeVariation AND Is_Active__c=True LIMIT 1');
    }
    
    public List<Partner_Certification__c> getAdminBadgeURL(String adminCertificationRecordTypeId,Set<String> setOfCertificationNames)
    {
        return  Database.query('SELECT Badge_Url__c,Certification_Name__c FROM Partner_Certification__c WHERE RecordTypeId =:adminCertificationRecordTypeId AND Certification_Name__c  IN : setOfCertificationNames AND Is_Default__c=True');
    }
}
