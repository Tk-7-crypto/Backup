/*
 * Version       : 1.0
 * Description   : This Apex class is selector layer for Record Type
 */
public class SLT_RecordType {
    
    /**
     * This method used to get Id of recordType by Developer Name
     * @return  List<RecordType>
     * @param Developer Name of record type
     */
    public List<RecordType> getRecordType(String developerName) {
        list<RecordType> listOfRecordType = [SELECT Id, Name
                                            FROM RecordType
                                            WHERE DeveloperName =: developerName];
        return listOfRecordType;
    }
    
    /**
     * This method used to get Id of recordType by set of Developer Names
     * @param SObject Type name
     * @param List<String> Developer name of Record Types
     * @return List<RecordType>
     */
    public List<RecordType> getRecordTypesBySObjectType(String sobjectTypeName, List<String> developerNames) {
        List<RecordType> recordTypeList = [SELECT Id, Name, RecordType.DeveloperName
                                           FROM RecordType
                                           WHERE SobjectType =: sobjectTypeName 
                                           AND DeveloperName IN: developerNames];
        return recordTypeList;
    }
    
}