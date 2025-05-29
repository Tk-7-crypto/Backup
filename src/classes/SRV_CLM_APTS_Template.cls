/*
 * Version       : 1.0
 * Description   : Service Class for Apttus__APTS_Template__c sObject.
 */
public class SRV_CLM_APTS_Template {
    
    public static List<Apttus__APTS_Template__c> getTemplates(Set<String> fields, String condition, Integer recordLimit) {
        return new SLT_Apttus_APTS_Template().getTemplates(fields, condition, recordLimit);
    }
}