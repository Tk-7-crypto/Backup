public with sharing class CNT_CSM_CustomLookup {
    @AuraEnabled(cacheable=true)
    public static List<RecordsData> fetchRecords( String objectName, String filterField, String searchString ) {
        List<RecordsData> recordsDataList = new List<RecordsData>();
        List<RecordsData> recordsDataUserList = new List<RecordsData>();
        List<User> userList = new List<User>();
        list<String> storeValue = new list<String>();
        try {
            String query = '';
            if(objectName == CON_CSM.S_GROUP){
                query = 'SELECT Id, ' + filterField+
                    ' FROM '+objectName+
                    ' WHERE '+filterField+' LIKE ' + '\'' + '%'+String.escapeSingleQuotes(searchString.trim()) + '%\'' + ' AND Type = \'Queue\' LIMIT 50'; 
            }
            else{
                query = 'SELECT Id, ' + filterField+
                    ' FROM '+objectName+
                    ' WHERE '+filterField+' LIKE ' + '\'' + '%'+String.escapeSingleQuotes(searchString.trim()) + '%\'' + ' LIMIT 50'; 
            } 
            
            for(SObject s : Database.query(query)){
                RecordsData recordsData = new RecordsData();
                recordsData.value = String.valueOf(s.get('id'));
                recordsData.label = String.valueOf(s.get(filterField));
                recordsDataList.add(recordsData);
                storeValue.add(recordsData.label);
            } 
        } catch (Exception err) {
            throw new AuraHandledException(err.getMessage());
        }
        
        if(objectName == 'User'){
            userList = [select id ,Name ,Profile.Name from User where Profile.Name NOT IN('CSM Customer Community Plus Login User','Partner Community User') and name IN :storeValue];
            for(User s : userList){
                RecordsData recordsData = new RecordsData();
                recordsData.value = String.valueOf(s.id);
                recordsData.label =s.Name;
                recordsDataUserList.add(recordsData);
            }
            return recordsDataUserList;
        }
        else{
            return recordsDataList;
        }
    }
    
    public class RecordsData{
        @AuraEnabled public String label {get;set;}
        @AuraEnabled public String value {get;set;}
    }
}