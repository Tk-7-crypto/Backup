/*
 * Version       : 1.0
 * Description   : This Apex class is selector layer for KB Translation Setting Metadata Type.
 */
public class SLT_KBTranslationSetting extends fflib_SObjectSelector {
        
    /**
     * This method used to get field list of sobject
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>();
    }
    
    /**
     * This method used to set up type of sobject
     * @return  Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return CSM_KB_Translation_Setting__mdt.sObjectType;
    }
    
    /**
     * This method used to get all records of KB Translation Setting Metadata
     * @return  Map<String, String>
     */
    public Map<String, String> getDisclaimerByLanguage() {
        List<CSM_KB_Translation_Setting__mdt> kbTranslationSettings = [SELECT Language__c, Disclaimer__c FROM CSM_KB_Translation_Setting__mdt];
        Map<String, String> disclaimerByLanguage = new Map<String, String>();
        for(CSM_KB_Translation_Setting__mdt translationSetting: kbTranslationSettings) {
            disclaimerByLanguage.put(translationSetting.Language__c, translationSetting.Disclaimer__c);
        }
        return disclaimerByLanguage;
    }
}