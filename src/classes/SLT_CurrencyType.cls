/*
 * Version       : 1.0
 * Description   : This Apex class is selector layer for CurrencyType
 */
public class SLT_CurrencyType extends fflib_SObjectSelector {
    
    /**
     * This method used to get field list of sobject
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            CurrencyType.Id,
            CurrencyType.ConversionRate,
            CurrencyType.IsoCode,
            CurrencyType.IsActive,
            CurrencyType.DecimalPlaces
        };
    }
    
     /**
     * This method used to set up type of sobject
     * @return  Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return CurrencyType.sObjectType;
    }

    /**
     * This method used to selectByTopicId
     * @return  Map<Id, CurrencyType>
     */
    public Map<Id, CurrencyType> selectAllCurrencyType() {
        return new Map<Id, CurrencyType>((List<CurrencyType>) Database.query(newQueryFactory(true).setCondition('isActive = true').toSOQL()));
    }
    
    public List<CurrencyType> getAllCurrencyTypeByIsoCode(Set<String> setOfIsoCode){
        return [select Id,ConversionRate,IsoCode from CurrencyType where IsoCode in : setOfIsoCode];
    }
    
    public Map<String,CurrencyType> getSelectedCurrencyTypeByIsoCode(Set<String> setOfIsoCode){
        Map<String, CurrencyType> isoCodeTocurrencyTypeMap = new Map<String, CurrencyType>();
        List<CurrencyType> currencyTypeList = [SELECT Id,conversionRate,isoCode FROM CurrencyType WHERE isoCode IN : setOfIsoCode];
        for(CurrencyType currencyType : currencyTypeList) {
            isoCodeTocurrencyTypeMap.put(currencyType.isoCode,currencyType);
        }
        return isoCodeTocurrencyTypeMap;
    }
    
    public Map<String,CurrencyType> getSelectedCurrencyTypeByIsoCodeAndActive(Set<String> setOfIsoCode){
        Map<String, CurrencyType> isoCodeTocurrencyTypeMap = new Map<String, CurrencyType>();
        List<CurrencyType> currencyTypeList = (List<CurrencyType>) Database.query(newQueryFactory(true).setCondition('isoCode IN : setOfIsoCode AND isActive = true').toSOQL());
        for(CurrencyType currencyType : currencyTypeList) {
            isoCodeTocurrencyTypeMap.put(currencyType.isoCode,currencyType);
        }
        return isoCodeTocurrencyTypeMap;
    }
    public Map<String,CurrencyType> getAllCurrencyTypeByIsoCode(){
        Map<String, CurrencyType> isoCodeTocurrencyTypeMap = new Map<String, CurrencyType>();
        List<CurrencyType> currencyTypeList = [SELECT Id, ConversionRate, IsoCode, DecimalPlaces FROM CurrencyType];
        for(CurrencyType currencyType : currencyTypeList) {
            isoCodeTocurrencyTypeMap.put(currencyType.isoCode,currencyType);
        }
        return isoCodeTocurrencyTypeMap;
    }
}