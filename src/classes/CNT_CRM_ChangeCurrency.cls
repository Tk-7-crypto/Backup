/*
 * Version       : 1.0
 * Description   : Apex Controller for change currency screen.
 */
public class CNT_CRM_ChangeCurrency {
	
    public CNT_CRM_ChangeCurrency(ApexPages.StandardController controller) {
        
    }
    
    /**
     * This method used to get field detail of Oli object
     * @params  String objectName
     * @params  List<String> fieldList
     * @return  List<UTL_Sobject.ObjectFieldsWrapper>
     */
    @AuraEnabled
    public static List<ObjectFieldsWrapper> getSobjectFieldDetail(String objectName, List<String> fieldList) {
        List<ObjectFieldsWrapper> objectSelectedFieldList = new List<ObjectFieldsWrapper>();
        try {
            objectSelectedFieldList = new UTL_Sobject(objectName).getSobjectFieldDetails(fieldList);
        } catch(Exception ex) {
            throw new AuraHandledException(JSON.serialize(ex));
        }
        return objectSelectedFieldList;
    }
    
    /**
     * This method is used to change currency of Opportunity records. 
     * @params  Id oppId
     * @params  CurrencyType requestedCurrencyType
     */    
    @AuraEnabled
    public static void changeCurrencyOfOpportunity(Id opportunityId, String requestedCurrencyType) {
        try {
            SRV_CRM_Opportunity.changeCurrencyOfOpportunity(opportunityId, requestedCurrencyType);
        } catch(Exception ex) {
            throw new AuraHandledException(JSON.serialize(ex));
        }
    }
    
    /**
     * This method is used to validate the proxy object on Opportunity. 
     * @params  Id oppId
     * @return  String 
     */
    @AuraEnabled
    public static String validateProxyObjectRecords(Id opportunityId) {
        try {
            String errorMsg = SRV_CRM_Opportunity.validateProxyObjectRecordsForOpportunity(opportunityId);
            return errorMsg;
        } catch(Exception ex) {
            throw new AuraHandledException(JSON.serialize(ex));
        }
    }
}