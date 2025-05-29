public class OWF_GenericCollectionToolHelper {
    private final static String BID_HISTORY = 'Bid_History__c';
    private final static String COLLECTION_TOOL = 'CollectionTool__c';
                                         
    private String bidHistoryId{get; set;}
    private String metadatConfigName{get; set;}
    private String type{get; set;}
    @testVisible private CollectionToolConfig config{get; set;}
    private Map<String, Set<String>> fields{get; set;}
    private Bid_History__c bidHistory{get; set;} 
    
    public OWF_GenericCollectionToolHelper(String bidHistoryId,  String metadatConfigName) {
        this.bidHistoryId = bidHistoryId;
        this.metadatConfigName = metadatConfigName;
        this.initializeData();
    }
    
    private void initializeData() {
        this.getConfig(); 
        this.getType(); 
        this.getQueryFields();
        this.getBidHistory();
    }
    
    public CollectionToolData getCollectionData() {
        CollectionToolData data = new CollectionToolData();
        data.config = this.config;
        data.bidHistory = this.bidHistory;
        data.tables = getCollectionTablesData();
        return data;
    }
    
    public List<CollectionTable> saveCollectionData(String collectionTablesJSON){
        List<CollectionTable> collectionTables = (List<CollectionTable>) JSON.deserialize(collectionTablesJSON, List<CollectionTable>.class);
        Id recordTypeId = Schema.SObjectType.CollectionTool__c.getRecordTypeInfosByName().get(config.collectionRecordTypeName).getRecordTypeId();
        List<CollectionTool__c> recordsToUpsert = new List<CollectionTool__c>();
        List<CollectionTool__c> recordsToDelete = new List<CollectionTool__c>();
        Map<String, Integer> recordIdMapByRowIndex = new Map<String, Integer>();
        Set<Integer> tableCounts = new  Set<Integer>();

        for(CollectionTable table : collectionTables) {
            tableCounts.add(table.tableNumber);
            for(CollectionRow row : table.rows) {
                CollectionTool__c collectionRecord;
                if(row.action == 'UPDATE' || row.action == 'INSERT') {
                    collectionRecord = new CollectionTool__c(
                        Bid_History__c = bidHistoryId,
                        recordTypeId = recordTypeId
                    );
                    if(row.action == 'UPDATE') {
                        collectionRecord.Id = row.recordId;
                    }
                    collectionRecord.put(config.collectionTableNumberFieldName, table.tableNumber);
                    buildCollectionRecord(collectionRecord, row);
                    recordsToUpsert.add(collectionRecord);
                    if(row.recordId != null && config.sendEmailNotificationOnFieldsUpdate != null && config.sendEmailNotificationOnFieldsUpdate) {
                        recordIdMapByRowIndex.put(row.recordId, row.rowIndex);
                    }
                } else if(row.action == 'DELETE') {
                    collectionRecord = new CollectionTool__c(Id = row.recordId);
                    recordsToDelete.add(collectionRecord);
                }                
            }
        }
        if(config.validationRule != null && config.validationRule.className != null) {
            System.Type t = System.Type.forName(config.validationRule.className);
		    INT_OWF_CollectionToolValidation validationClass = (INT_OWF_CollectionToolValidation) t.newInstance();
            Set<String> errors = validationClass.validate(config, recordsToUpsert);
            if(errors.size() > 0) {
                throw new CPQ_CustomException(String.join(new List<String>(errors), ','));
            }
        }
        List<CollectionTool__c> oldCollectionData;
        List<UTL_OWF.workflowEmailRecordWrapper> workflowEmailRecordWrapperMessageList;
        if(config.sendEmailNotificationOnFieldsUpdate != null && config.sendEmailNotificationOnFieldsUpdate && !recordsToUpsert.isEmpty()) {
            oldCollectionData = getCollectionTablesDataList();     
        }
        if(!recordsToUpsert.isEmpty()) {
			UPSERT recordsToUpsert;
        }
        if(!recordsToDelete.isEmpty()) {
            DELETE recordsToDelete;
        }
        if(config.sendEmailNotificationOnFieldsUpdate != null && config.sendEmailNotificationOnFieldsUpdate && !recordsToUpsert.isEmpty() ) {
            if(config.collectionRecordTypeName == 'GCC'){
                workflowEmailRecordWrapperMessageList = sendMailForGccCountriesInScope(oldCollectionData, recordsToUpsert, recordIdMapByRowIndex);
            }
            if(workflowEmailRecordWrapperMessageList != null ) {
            UTL_OWF.sendEmailByWorkflowEmailRecord(workflowEmailRecordWrapperMessageList);
            }   
        
        }
        
        return getCollectionTablesData();
    }

    private List<UTL_OWF.workflowEmailRecordWrapper> sendMailForGccCountriesInScope(List<CollectionTool__c> oldCollectionData,List<CollectionTool__c> recordsToUpsert, Map<String, Integer> recordIdMapByRowIndex ) {
        String emailOverallBodyContent = '<div>Please be informed that below fields has been edited in the Countries in Scope table in the below bid:<br>';
        emailOverallBodyContent += '<b>Bid Link: </b><span style = "font-weight: normal;"><a href = \'' + URL.getOrgDomainUrl().toExternalForm() + '/' + (bidHistory.Id != null ? bidHistory.Id : '') + '\'> Bid Defence</a></span><br>';
        Boolean sendMailForGccBid = false;
        Map<String,String> mailnotificationFileds = new Map<String, String>();
        for(String mailNotificationFieLd : config.emailNotificationFieLds) {
            mailnotificationFileds.put(mailNotificationFieLd,Schema.CollectionTool__c.SObjectType.getDescribe().fields.getMap().get(mailNotificationFieLd).getDescribe().getLabel());
        }
        Map<Id,CollectionTool__c> newCollectionDataMap = new Map<Id,CollectionTool__c>(recordsToUpsert);
        for(CollectionTool__c collectionTool : oldCollectionData) {
            if(newCollectionDataMap.containsKey(collectionTool.Id)) {
                CollectionTool__c newCollectionData = newCollectionDataMap.get(collectionTool.Id);
                String emailRowIndex = '<span>row '+(recordIdMapByRowIndex.containsKey(collectionTool.Id) ? recordIdMapByRowIndex.get(collectionTool.Id)+'' : '') + ': </span> ';
                String emailRow = '';
                for(String mailNotificationFieLd : config.emailNotificationFieLds) {
                   
                    if(collectionTool.get(mailNotificationFieLd) != newCollectionData.get(mailNotificationFieLd)) {
                        sendMailForGccBid = true;
                        emailRow += mailnotificationFileds.get(mailNotificationFieLd) +':<b> Old Value:</b> '+collectionTool.get(mailNotificationFieLd) +'  <b>  New Value: </b>'+ newCollectionData.get(mailNotificationFieLd)+ ' <br>';
                    }
                }
                if(emailRow != ''){
                    emailOverallBodyContent += (emailRowIndex + emailRow) +'<br>';
                }
            }
        }
        emailOverallBodyContent += '</div>';
        if(sendMailForGccBid){
            List<UTL_OWF.workflowEmailRecordWrapper> workflowEmailRecordWrapperMessageList = new List<UTL_OWF.workflowEmailRecordWrapper>();
            UTL_OWF.workflowEmailRecordWrapper workflowEmailRecordWrapperMessage = new UTL_OWF.workflowEmailRecordWrapper();
            workflowEmailRecordWrapperMessage.subject = oldCollectionData[0].Bid_History__r.Opportunity_Name__c+' - Changes made to Proposal - Please Review';
            workflowEmailRecordWrapperMessage.whatId = bidHistory.Id;
            List<String> toEmailList = new List<String>();
            OWF_Generic_Setting__c additionalEmail = OWF_Generic_Setting__c.getValues(CON_OWF.BHR_OWF_NotificationToGCCOnCollectionToolFieldUpdate);
            if(additionalEmail != null && additionalEmail.Value__c != null){
                toEmailList = (additionalEmail.Value__c).split(',');
            }
            workflowEmailRecordWrapperMessage.toEmails = toEmailList;
            workflowEmailRecordWrapperMessage.emailAction = CON_OWF.BUDGET_TOOLS_BIDHISTORY_ALERT_EMAIL_ACTION;
            workflowEmailRecordWrapperMessage.staticContent = emailOverallBodyContent;
            workflowEmailRecordWrapperMessageList.add(workflowEmailRecordWrapperMessage);
            return workflowEmailRecordWrapperMessageList;
        }
        return null;
    }

    private CollectionTool__c buildCollectionRecord(CollectionTool__c collectionRecord, CollectionRow row) {        
        for(Column column : config.columns) {
            if(column.type != 'formula') {
                collectionRecord.put(column.apiName, getFieldValue(column.dataType, row.cells.get(column.apiName).value));
            }            
        }
        for(Column column : config.defaultValues) {
            collectionRecord.put(column.apiName, getFieldValue(column.dataType, column.value));
        }
        return collectionRecord;
    }
    
    private  List<CollectionTool__c> getCollectionTablesDataList() {
        List<CollectionTool__c> collections = 
        new SLT_CollectionTool(false, false).getCollectionToolsByBidHistoryId(bidHistoryId, fields.get(COLLECTION_TOOL));
        return collections;
    }

    private List<CollectionTable> getCollectionTablesData() {
        List<CollectionTool__c> collections = 
            new SLT_CollectionTool(false, false).getCollectionToolsByBidHistoryIdandType(bidHistoryId, fields.get(COLLECTION_TOOL),type);
        Boolean populateRecordsFromLastBid = false;
        if(config.autopopulate && collections.size() == 0) {
            collections = getPreviousBidCollectionRecord();
            populateRecordsFromLastBid = true;
        }
        Integer tableCount = Integer.valueOf(bidHistory.get(config.displayTablesFieldName));
        Map<Integer, CollectionTable> tablesMap = new Map<Integer, CollectionTable>();
        for(Integer i=1; i<=tableCount; i++) {
            tablesMap.put(i, new CollectionTable(i));
        }
        prepareCollectionTable(tablesMap, collections, populateRecordsFromLastBid);
        return tablesMap.values();
    }
    
    private List<CollectionTool__c> getPreviousBidCollectionRecord() {
        String autopopulateCriteria = 
            ' Bid_History_Related_Opportunity__c =\'' + bidHistory.Bid_History_Related_Opportunity__c + '\'' + 
            ' AND Id !=\'' + bidHistory.Id + '\'' +
            ' AND ' + config.autopopulateCriteria;
        List<CollectionTool__c> collections = new List<CollectionTool__c>();
        List<Bid_History__c> bidHistories = 
            new SLT_Bid_History(false, false).getLatestBidHistory(fields.get(BID_HISTORY), autopopulateCriteria);
        if(bidHistories.size() > 0) {
            collections = 
                new SLT_CollectionTool(false, false).getCollectionToolsByBidHistoryIdandType(bidHistories[0].Id, fields.get(COLLECTION_TOOL),type);
        }
        return collections;
    }
    
    private void prepareCollectionTable(Map<Integer, CollectionTable> tablesMap, List<CollectionTool__c> collections,
		Boolean populateRecordsFromLastBid) {
        for(CollectionTool__c collection : collections) {
            Integer tableNumber = Integer.valueOf(collection.get(config.collectionTableNumberFieldName));
            String action;
            CollectionTable table;
            if(tablesMap.containsKey(tableNumber)) { 
                table = tablesMap.get(tableNumber);
                action = populateRecordsFromLastBid ? 'INSERT' : 'NO_ACTION';
            } else if(!populateRecordsFromLastBid) {
                table = tablesMap.get(1);
                action = 'DELETE';
            }
            if(table != null) {
               	CollectionRow row =  new CollectionRow(
                    table.rows.Size() + 1, 
                    (action == 'INSERT' ?  null : collection.Id), 
                    action, 
                    (action == 'DELETE')
                );
                
                for(Column col : config.columns) {
                    row.cells.put(
                        col.apiName, 
                        new CollectionCell(String.valueOf(collection.get(col.apiName)))
                    );
                }
                table.rows.add(row); 
            }            
        }
        for(CollectionTable table : tablesMap.values()) {
            if(table.rows.size() == 0) {
                CollectionRow row = new CollectionRow(1, null, 'INSERT', false);
                for(Column col : config.columns) { 
                    String value = '';
                    if(col.type == 'formula') {
                        value = getFormulaFieldValue(col.apiName, table.tableNumber);
                    }       
                    else if(col.showOnlyOnce != null && col.showOnlyOnce && col.fetchOptionsFromOtherField !=null && col.fetchOptionsFromOtherField ) {
                        value = String.valueOf(bidHistory.get(col.fetchOptionsOtherFieldName));
                    }
                    row.cells.put(
                        col.apiName, 
                        new CollectionCell(value)
                    );
                }
                table.rows.add(row); 
            }
            CollectionRow fixedrow = new CollectionRow(0, null, 'NO_ACTION', false);
            String value;
            for(Column col : config.columns) {  
                if(col.showOnlyOnce == true){
                    value = table.rows[0].cells.get(col.apiName).value;
                    fixedrow.cells.put(
                    col.apiName, 
                    new CollectionCell(value)
                    );
                }
            }
            table.fixedRow = fixedrow;
            
        }
        if(config.showSumOfRows != null && config.showSumOfRows) {
            prepareCollectionSumTable(tablesMap);
        }
    }
    private void prepareCollectionSumTable(Map<Integer, CollectionTable> tablesMap) {
        for(CollectionTable table : tablesMap.values()) {
            Map<String,Integer> columnNameToSumMap = new Map<String,Integer>();
            boolean isAlreadyCalculate = false;
            for(CollectionRow row: table.rows) {
                    Integer count =0;
                    for(String cellLabel: row.cells.keySet()) {
                        if(!config.columns[count].showOnlyOnce) {
                            try {
                                if(row.cells.get(cellLabel).value != null && row.cells.get(cellLabel).value !='') {
                                    if(columnNameToSumMap.containsKey(cellLabel)){
                                        columnNameToSumMap.put(cellLabel,columnNameToSumMap.get(cellLabel) + Integer.valueOf(row.cells.get(cellLabel).value));
                                    }
                                    else {
                                        columnNameToSumMap.put(cellLabel, Integer.valueOf(row.cells.get(cellLabel).value));
                                    }
                                }
                                else if(!columnNameToSumMap.containsKey(cellLabel)) {
                                    columnNameToSumMap.put(cellLabel, 0);
                                    }
                            }
                            catch(Exception e) {
                                if(!isAlreadyCalculate) {
                                    columnNameToSumMap.put(cellLabel,table.rows.size());
                                }
                            }
                        }
                        count++;
                    }
                isAlreadyCalculate = true;
            }
            List<CollectionSum> sum = new List<CollectionSum>();
            for(String name: columnNameToSumMap.keySet()){
                sum.add(new CollectionSum(name,columnNameToSumMap.get(name)));
            }
            table.sums = sum;
        }
    } 
    
    public String getFormulaFieldValue(String column, Integer tableNumber) {
        String value  = '';
        switch on column {
            when 'Bid_History_Study_Number__c' {	
                CollectionTool__c collection = new CollectionTool__c(
                	Bid_History__c = bidHistory.Id,
                    Study_Number__c = tableNumber
                );
                Formula.recalculateFormulas(new List<CollectionTool__c>{collection});
                value = (String)collection.get('Bid_History_Study_Number__c');
            }
            when else {
                value = '';
            }
        }
        return value;
    }
    
    private Object getFieldValue(String dataType, String value) {
        Object fieldValue;
        if(!String.isBLANK(value)) {
            switch on dataType {
                when 'Integer' {	
                    fieldValue = Integer.valueOf(value);
                }
                when 'Decimal' {	
                    fieldValue = Decimal.valueOf(value);
                }
                when 'Date' {	
                    fieldValue = Date.valueOf(value);
                }
                when else {
                    fieldValue = value;
                }
            }
        }        
        return fieldValue;
    }


    private void getConfig() {
        OWF_Collection_Tool_Configuration__mdt configMetaData =
            [SELECT Config_JSON__c from OWF_Collection_Tool_Configuration__mdt Where DeveloperName =: this.metadatConfigName]; 
        String configJson = configMetaData.Config_JSON__c;            
        config = (CollectionToolConfig) System.JSON.deserialize(configJson, CollectionToolConfig.class);
    }

    private void getType() {           
        for(Column column : config.defaultValues) {
            if(column.apiName == 'Type__c'){
                type = column.value;
            }
        }
    }
    
    private void getQueryFields() {
        fields = new Map<String, Set<String>>();
        fields.put(BID_HISTORY, new Set<String>{});
        fields.put(COLLECTION_TOOL, new Set<String>{});
        fields.get(BID_HISTORY).add('Bid_History_Related_Opportunity__c');
        fields.get(BID_HISTORY).add('Bid_Type__c');
        fields.get(BID_HISTORY).add('Q2_Budget_Tools__c');
        fields.get(BID_HISTORY).add(config.displayTablesFieldName);
        fields.get(COLLECTION_TOOL).add(config.collectionTableNumberFieldName);
        fields.get(COLLECTION_TOOL).add('Bid_History__r.Opportunity_Name__c');
        for (Column col : config.columns) {
            if(col.fetchOptionsFromOtherField !=null && col.fetchOptionsFromOtherField) {
                fields.get(BID_HISTORY).add(col.fetchOptionsOtherFieldName);
            }
            fields.get(COLLECTION_TOOL).add(col.apiName);
        }
    }
    
    private void getBidHistory() {
        bidHistory = new SLT_Bid_History(false, false).getBidHistoryDetails(this.bidHistoryId, this.fields.get(BID_HISTORY));        
    }
    
    public class CollectionToolConfig{
        @AuraEnabled
        public String headerText{get; set;}
        @AuraEnabled
        public String tableHeading{get; set;}
        @AuraEnabled
        public Boolean enableNewRow{get; set;}
        @AuraEnabled
        public String newRowButtonLabel{get; set;}
        @AuraEnabled
        public String showTableNumber{get; set;}
        @AuraEnabled
        public Boolean enableDeleteRow{get; set;}
        @AuraEnabled
        public Boolean enableClearRow{get; set;}
        @AuraEnabled
        public Boolean enableCloneTable{get; set;}
        @AuraEnabled
        public Boolean allowAllRowDeletion{get; set;}
        @AuraEnabled
        public Boolean showSumOfRows{get; set;}
        @AuraEnabled
        public Boolean displayDeleteFirstRow{get; set;}
        @AuraEnabled
        public String cloneTableButtonLabel{get; set;}
        @AuraEnabled
        public Boolean displayUnsaveDataMessage{get; set;}
        @AuraEnabled
        public Boolean redirectToBid{get; set;}
        @AuraEnabled
        public String unsavedDataInformationMessage{get; set;}
        @AuraEnabled
        public String displayTablesFieldName{get; set;}
        @AuraEnabled
        public String collectionTableNumberFieldName{get; set;}
        @AuraEnabled
        public String collectionRecordTypeName{get; set;}
        @AuraEnabled
        public Boolean autopopulate{get; set;}  
        @AuraEnabled
        public String autopopulateCriteria{get; set;}
        @AuraEnabled
        public String keyMessage{get; set;}
        @AuraEnabled
        public List<Column> columns{get; set;}
        @AuraEnabled
        public List<Column> defaultValues{get; set;}
        @AuraEnabled
        public boolean requiredValidationFirstRowOnly{get; set;}
        @AuraEnabled
        public String requiredErrorMessage{get; set;}
        @AuraEnabled
        public Boolean sendEmailNotificationOnFieldsUpdate{get; set;}
        @AuraEnabled
        public List<String> emailNotificationFieLds{get; set;}
        @AuraEnabled
        public Boolean showRowNumber{get; set;}
        @AuraEnabled
        public Validation validationRule{get; set;}   
        @AuraEnabled
        public String displayTemplate{get; set;}     
    }
    
    public class Validation{
        @AuraEnabled
        public String className{get; set;}
        @AuraEnabled
        public List<ValidationRule> validationRules{get; set;}
    }
    
    public class ValidationRule {
        @AuraEnabled
        public String ruleName{get; set;}
        @AuraEnabled
        public List<String> ruleAttributes{get; set;}
        @AuraEnabled
        public String errorMessage{get; set;}
    } 

    
    public class Column {
        @AuraEnabled
        public String label{get; set;}
        @AuraEnabled
        public String type{get; set;}
        @AuraEnabled
        public String dataType{get; set;}
        @AuraEnabled
        public String apiName{get; set;}
        @AuraEnabled
        public Boolean dependentField{get; set;}
        @AuraEnabled
        public String controllingValue{get; set;}
        @AuraEnabled
        public String helpText{get; set;}
        @AuraEnabled
        public Boolean fetchOptionsFromOtherField{get; set;}
        @AuraEnabled
        public Boolean showOnlyOnce{get; set;}
        @AuraEnabled
        public String fetchOptionsOtherFieldName{get; set;}
        @AuraEnabled
        public String multiSelect{get; set;}
        @AuraEnabled
        public Boolean required{get; set;}
        @AuraEnabled
        public Integer minValue{get; set;}
        @AuraEnabled
        public Integer maxValue{get; set;}
        @AuraEnabled
        public Decimal stepValue{get; set;}
        @AuraEnabled
        public Integer length{get; set;}
        @AuraEnabled
        public String value{get; set;}
        @AuraEnabled
        public Boolean hide{get; set;}
        @AuraEnabled
        public RecordPicker recordPicker{get; set;}
        @AuraEnabled
        public String width{get; set;}
        @AuraEnabled
        public Integer displayRowNumber{get; set;}
        @AuraEnabled
        public Integer maxSelectedValue{get; set;}
        @AuraEnabled
        public Boolean validateSelectedValue{get; set;}
        @AuraEnabled
        public String defaultValue{get; set;}   
    }
    public class RecordPicker {
        @AuraEnabled
        public String objectApiName{get; set;}
        @AuraEnabled
        public List<Criteria> criteria{get; set;}
    }
    public class Criteria {
        @AuraEnabled
        public String fieldPath{get; set;}
        @AuraEnabled
        public String operator{get; set;}
        @AuraEnabled
        public List<String>  value{get; set;}
    }
    public class CollectionToolData{
        @AuraEnabled
        public CollectionToolConfig config{get; set;}
        
        @AuraEnabled
        public Bid_History__c bidHistory{get; set;}
        
        @AuraEnabled
        public List<CollectionTable> tables{get; set;}
        
    }
    
    public class CollectionTable{
        @AuraEnabled
        public Integer tableNumber{get; set;}
        @AuraEnabled
        public List<CollectionSum> sums{get; set;}
        @AuraEnabled
        public CollectionRow fixedRow{get; set;}
        @AuraEnabled
        public List<CollectionRow> rows{get; set;}
        public CollectionTable(Integer tableNumber) {
            this.tableNumber = tableNumber;
            this.rows = new List<CollectionRow>();
        }
    }

    public class CollectionSum{
        @AuraEnabled
        public Integer value{get; set;}
        @AuraEnabled
        public String column{get; set;}
        public CollectionSum( String APIName,Integer sum) {
            this.column = APIName;
            this.value = sum;
        }
    }
    
    public class CollectionRow{
        @AuraEnabled
        public Integer rowNumber{get; set;}
        @AuraEnabled
        public String recordId{get; set;}
        @AuraEnabled
        public String action{get; set;}
        @AuraEnabled
        public Boolean isDeleted{get; set;}
        @AuraEnabled
        public Map<String, CollectionCell> cells{get; set;}
        @AuraEnabled
        public Integer rowIndex{get; set;}
        public CollectionRow(Integer rowNumber, String recordId, String action, Boolean isDeleted) {
            this.rowNumber = rowNumber;
            this.recordId = recordId;
            this.action = action;
            this.isDeleted = isDeleted;
            this.cells = new Map<String, CollectionCell>();
        }
    }

   	public class CollectionCell{
        @AuraEnabled
        public String value{get; set;}
        @AuraEnabled
        public boolean error{get; set;}
        public CollectionCell(String value) {
            this.value = value;
        }
    }
}
