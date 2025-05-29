/**
* Created by Ronak Mehta on 16-Nov-2023
* Description : Contain common Methods to support LWC componet: lwcCrmAutoCompleteSearch
*/
public class CNT_CRM_AutoCompleteSearch {
    
    /**
     * This Method to return records based on the parameter
     * @params String searchKey
     * @params String objectName
     * @params String filterField
     * @params String fieldSet
     * @params String recordLimit
     * @return List<sobject>
     */
    @AuraEnabled(cacheable=true)
    public static List<sobject> findRecords(String searchKey, String objectName, String filterField, String fieldSet, String recordLimit){
        string searchText = '\'' + '%'+ String.escapeSingleQuotes(searchKey) + '%\'';
        string strfilterField;
        string strQuery = 'SELECT Id, ' + fieldSet + ' FROM ' + objectName;
        if(filterField != null && filterField != ''){
            if(objectName == 'Drug_product__c'){
                strQuery += ' WHERE (Status__c != \'Deprecated\') AND (';
            }else if(objectName == 'Account'){
                strQuery += ' WHERE (Parent.Name = \'Avacare\' AND Type__c like \'%Clinical Site%\') AND (';
            }else{
                strQuery += ' WHERE (Id != NULL) AND (';
            }
            List<String> lstFilterField = filterField.split(',');
            if(lstFilterField != null && lstFilterField.size() > 0){
                for(String filterFieldName: lstFilterField ){ 
                    strfilterField = (strfilterField != null ? strfilterField : '') + filterFieldName + ' LIKE '+ searchText + ' OR ';
                }
            }
            strfilterField = strfilterField.removeEnd('OR ');
            strQuery = strQuery + strfilterField + ')';
            System.debug(strQuery);
        }
        if(objectName == 'Drug_product__c' && searchKey.length() > 2){
            if(searchKey.contains('!') || searchKey.contains('#')){
                searchKey = searchKey.replaceAll('!','%');
                searchKey = searchKey.replaceAll('#','%');
            }
            
            Pattern validaChar = Pattern.compile('[^a-zA-Z0-9 %()]');
            Matcher matcher = validaChar.matcher(searchKey);
            searchKey = matcher.replaceAll('*');
            if(searchKey.contains('%')){ //contains Molecule Name
                searchKey = '{'+ String.escapeSingleQuotes(searchKey)+'}';
            }else{
                searchKey = '{*'+ String.escapeSingleQuotes(searchKey)+'*}';
            }
            
            String searchquery='FIND '+ searchKey +' IN ALL FIELDS RETURNING Drug_product__c( '+ fieldSet + ' WHERE Status__c != \'Deprecated\' LIMIT '+ recordLimit +' )'; 
            System.debug(searchquery);
            List<List<SObject>> listOfResults =SEARCH.query(searchquery);
            return listOfResults[0];
        }else{
            return Database.query(strQuery + ' LIMIT ' + recordLimit + '');
        }
    }
    
}