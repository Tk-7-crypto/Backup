public class CNT_CPQ_CustomLookup {
    @AuraEnabled
    public static List<LookupValues> setSelectedData(String objectName, String searchField, String displayField, String subTextField, String whereClause, String preSelectedField, String preSelectedRecords) {
        List<LookupValues> returnList = new List<LookupValues>();
        Set<String> selectedValues = new Set<String>();
        
        for (String selectedValue : preSelectedRecords.split(CON_CPQ.COMMA)) {
            if (selectedValue != null && selectedValue.trim() != '') {
                selectedValues.add(selectedValue.trim());
            }
        }
        
        String fields = displayField;
        if (searchField != displayField) {
            fields = fields + CON_CPQ.COMMA + ' ' + searchField;
        }
        if (subTextField != '' && subTextField != displayField && subTextField != searchField) {
            fields = fields + CON_CPQ.COMMA + ' ' + subTextField;
        }
        
        String sQuery =  'SELECT Id, ' + fields + ' FROM ' + objectName + ' WHERE ' + preSelectedField + ' IN : selectedValues ' + (whereClause != null && whereClause != '' ? ' AND ' + whereClause : '') + ' order by createdDate DESC';
        List<sObject> lstOfRecords = Database.query(sQuery);
        
        for (sObject obj : lstOfRecords) {
            returnList.add(new LookupValues(obj, searchField, displayField, subTextField));
        }
        return returnList;
    }
    
    @AuraEnabled
    public static List<LookupValues> fetchLookUpData(String searchKeyWord, String objectName, String searchField, String displayField, String subTextField, String whereClause, Boolean showRecordsOnTypeOnly, Integer queryLimit) {
        List<LookupValues> returnList = new List<LookupValues>();
        if (!showRecordsOnTypeOnly || (showRecordsOnTypeOnly && searchKeyWord != null && searchKeyWord != '')) {
            String searchKey = searchKeyWord + '%';
            
            String fields = displayField;
            if (searchField != displayField) {
                fields = fields + CON_CPQ.COMMA + ' ' + searchField;
            }
            if (subTextField != '' && subTextField != displayField && subTextField != searchField) {
                fields = fields + CON_CPQ.COMMA + ' ' + subTextField;
            }
            
            if (queryLimit != null) {
                queryLimit = queryLimit == 0 ? 5 : queryLimit;
                queryLimit = queryLimit > 20 ? 20 : queryLimit;
            }
            String sQuery =  'SELECT Id, ' + fields + ' FROM ' + objectName + ' WHERE ' + searchField + ' LIKE: searchKey ' + (whereClause != null && whereClause != '' ? ' AND ' + whereClause : '') + ' order by createdDate DESC limit ' + queryLimit;
            List<sObject> lstOfRecords = Database.query(sQuery);
            
            for (sObject obj : lstOfRecords) {
                returnList.add(new LookupValues(obj, searchField, displayField, subTextField));
            }
        }
        return returnList;
    }
    
    public class LookupValues {
        @AuraEnabled
        public Id recordId {get; set;}
        @AuraEnabled
        public String searchField {get; set;}
        @AuraEnabled
        public String Name {get; set;}
        @AuraEnabled
        public String subTextField {get; set;}
        public LookupValues(sObject objRecord, String searchField, String displayField, String subTextField) {
            this.recordId = (Id)objRecord.get(CON_CPQ.ID);
            this.Name = (String)objRecord.get(displayField);
            this.searchField = (String)objRecord.get(searchField);
            if (subTextField != '' && subTextField != displayField) {
            	this.subTextField = (String)objRecord.get(subTextField);
            }
        }
    }
}