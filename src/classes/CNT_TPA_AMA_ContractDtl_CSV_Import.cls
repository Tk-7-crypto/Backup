/**
 * Author: Sunny Bansal
 * Since: October 12, 2015
 * Name: CNT_TPA_AMA_ContractDtl_CSV_Import
 * Description: Controller Class to import CSV File contains 'AMA Contract Details' records.
**/
public class CNT_TPA_AMA_ContractDtl_CSV_Import {

    //To store file data
    transient public Blob csvFileBody{get;set;}
    //String array to store each line of file
    transient private String[] contractDataLines;
    //To Store each AMA Contract record to be inserted
    public List < AMA_Contract_Detail__c > lstContracts {get;set;}
    //To store API names of each field
    public List<String> lstFieldNames{get;set;}
    public Boolean isDataSaved{ get; set; }
    //To store labels of each field
    public List<String> lstFieldLables{get;set;}
    //Map to get field type from field API Name
    public Map<String,String> fieldNameToTypeMap{get;set;}
    // To get all the possible names of Contract type to verify
    private map<string,string> mapContractTypeNames ;
    //To store the contract list type
    //public string contractListTypeTemp {get; set;}
    //public string contractListType = '';
    public string contractListType {get; set;}
    public string hiddenContractListType {get;set;}
    public Integer totalRecordsToInsert{get;set;}
    // to attach the success and error records
    public string inputString {get;set;}
    public string successRecordAsString {get;set;}
    public string errorRecordAsString {get;set;}
    public  Blob successRecordCSVFile;
    public  Blob errorRecordCSVFile;
    private set<String> multipleContractTypeSet = new Set<String>();
    private set<String> invalidMultipleContractTypes = new set<String>();


    private AMA_Contract_Detail__c amaContractObj;
    private map<String,String> contractTypePicklistValues = new map<String,String>();
    @testvisible transient private String contractDataAsString;
    private String fieldValue;
    private Integer fieldNumber;
    //Map to store the field position(position field occuring in csv file) with its corresponding field label
    private Map < String, Integer > fieldNumberMap = new Map < String, Integer > ();
    private static final String FIELD_LABEL_CLIENT = 'Client';
    private static final String LETTERSHOP_LITERAL = 'Lettershop';
    private static final String FIELD_HEADER_ON_BEHALF_OF = 'ON BEHALF OF';
    private static final String FIELD_LABEL_CLIENT_SERVICES = 'CLIENT SERVICES - ON BEHALF OF';
    private static final String FIELD_LABEL_MAX_FEE_REACHED = 'MAX FEE REACHED';
    private static final String FIELD_LABEL_MAX_SBII_FEE = 'MAX SB-II FEE (Y)';
    private static final String FIELD_HEADER_OFFSHORE_APPOVAL = 'OFFSHORE APPOVAL';
    private static final String FIELD_LABEL_OFFSHORE_APPROVAL = 'OFFSHORE APPROVAL';
    // Modified By Neha Bansal under CR-12673 Starts
    private static final String FIELD_LABEL_Offshore_Access = 'Offshore Access';
    private static final String FIELD_HEADER_OFFSHORE_ACCESS = 'OFFSHORE_ACCESS';
    private static final String FIELD_LABEL_OFFSHORE_STORAGE = 'Offshore Storage';
    private static final String FIELD_HEADER_OFFSHORE_STORAGE = 'OFFSHORE_STORAGE';
    private static final String FIELD_LABEL_OFFSHORE_LOCATION = 'OFFSHORE LOCATION';
    private static final String FIELD_LEBEL_RECORD_COUNT = 'record count';
    private static final String FIELD_HEADER_DOING_BUSINESS_AS = 'Doing Business As';
    // Modified By Neha Bansal under CR-12673 Ends
    //private static final String FIELD_LEBEL_SPECIAL_TERMS_AND_CONDITION = 'SPECIAL TERMS/CONDITIONS';
    private static final String CLIENT_LIST_LITERAL = 'Client List';
    private static final String CHARACTER_SET = 'ISO-8859-1';
    private static final String DATA_TYPE_DATE = 'Date';
    private static final String DATA_TYPE_DOUBLE = 'Double';
    private static final String DATA_TYPE_DATETIME = 'Datetime';
    private static final String DATA_TYPE_PICKLIST = 'Picklist';
    private static final String DATE_EXCEPTION_MESSAGE = 'Invalid date';
    private static final String DOUBLE_EXCEPTION_MESSAGE = 'Invalid double';
    private static final String DATA_TYPE_BOOLEAN = 'Boolean';
    private static final String LITERAL_TRUE = 'true';
    private static final String LITERAL_FALSE = 'false';
    public String fileName {get; set;}
    private Integer counter;
    public Integer size{get;set;}
    private Integer errorLogCounter;
    public Integer errorLogSize{get;set;}
    private boolean errorContains;
    private boolean errorContainsForMultipleContractType;
    public List<ArrayWrapper> errorLogs{get;set;}
    private Boolean containsExtraCommas = false;
    private Integer numberOfExtraCommas = 0;
    private String attachmentId;
    // To store the json value of successfully updated
    transient public String jsonDataSuccess { get; set; }
    // To store the json value of error logs
    transient public String jsonDataError { get; set; }

    // To store list of list of contracts for exporting
    //public List<List<AMA_Contract_Detail__c>> listOfContracts { get; set; }

    /**
     * Name: ArrayWrapper
     * Desc: Wrapper class to show Error Logs.
    **/
    public Class ArrayWrapper {
        public String errorRecord{get;set;}
        public String errorMsg{get;set;}
        public Integer rowNo{get;set;}

        public ArrayWrapper(Integer rowNo, string errorRecord, String errorMsg) {
            this.rowNo = rowNo;
            this.errorRecord =  errorRecord;
            this.errorMsg = errorMsg;
        }
    }

    //Property to show number of records according to pagination
    public List<AMA_Contract_Detail__c> toDisplay {
        get {
            toDisplay = new List<AMA_Contract_Detail__c>();
            for(Integer i = counter;  i < counter+size && i<lstContracts.size(); i++) {
                toDisplay.add(lstContracts[i]);
            }
            return toDisplay;
        }
        set;
    }

    //Property to show number of error records according to pagination
    public List<ArrayWrapper> toDisplayErrorLogs {
        get {
            toDisplayErrorLogs = new List<ArrayWrapper>();
            for(Integer i = errorLogCounter;  i < errorLogCounter+errorLogSize && i<errorLogs.size(); i++) {
                toDisplayErrorLogs.add(errorLogs[i]);
            }
            return toDisplayErrorLogs;
        }
        set;
    }

    /**
     * Name: Default Constructor
     * Desc: To initialize values
    **/
    public CNT_TPA_AMA_ContractDtl_CSV_Import() {
        counter = 0;
        size = 10;
        errorLogCounter = 0;
        errorLogSize =10;
        contractDataLines = new String[] {};
        errorLogs = new List<ArrayWrapper>();
        errorContains = false;
        errorContainsForMultipleContractType = false;
        lstContracts = new List < AMA_Contract_Detail__c > ();
        lstFieldLables = new List<String>();
        lstFieldNames = new List<String>();
        fieldNameToTypeMap = new Map<String,String>();
        jsonDataSuccess = '';
        jsonDataError = '';
    }

    /**
     * Name: readFromFile
     * @param:
     * @return:
     * Desc: To read the data from uploaded CSV File
    **/
    public void readFromFile() {

        try {
            if(!test.isRunningTest()) {
                contractDataAsString = blobToString(csvFileBody,CHARACTER_SET); //UTF-8
            }
            readCSVFile();
        }
        catch(exception e) {
            lstContracts.clear();
            errorLogs.clear();
            if(e.getMessage().equalsIgnoreCase('BLOB is not a valid UTF-8 string')) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'CSV file is not in proper format. Please upload csv file in UTF-8 format or CSV(MS-Dos) file type.<br/> Error message:-'+e.getMessage()));
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Csv file is not in proper format. <br/> Error message:-'+e.getMessage()));
            }
            UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(TRUE, FALSE, UTL_LogFactory.GUID, e.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + e.getLineNumber() + ':::CNT_TPA_AMA_ContractDtl_CSV_Import:::readFromFile', ''));
        }
    }

    /**
     * Name: blobToString
     * @param: Blob input - File content, String inCharset - character set
     * @return: String - File content in string
     * Desc: To convert csv file content to string thats supports any charset.
    **/
    public String blobToString(Blob input, String inCharset) {

        String hex = EncodingUtil.convertToHex(input);
        if(String.isNotBlank(hex))
        {
            System.assertEquals(0, hex.length() & 1);
            final Integer bytesCount = hex.length() >> 1;
            String[] bytes = new String[bytesCount];
            for(Integer i = 0; i < bytesCount; ++i)
                bytes[i] =  hex.mid(i << 1, 2);
            return EncodingUtil.urlDecode('%' + String.join(bytes, '%'), inCharset);
        }
        else
        {
            return hex;
        }
    }

    /**
     * Name: readCSVFile
     * @param:
     * @return: PageReference: Returns reference of the page
     * Desc: To read uploaded CSV File to store the data in 'AMA Contract Details' Object
    **/
    public PageReference readCSVFile() {
        lstContracts.clear();
        errorLogs.clear();
        lstFieldNames.clear();
        lstFieldLables.clear();
        System.debug('==List Cleared'+lstContracts+'='+lstFieldNames+'='+lstFieldLables);

        //Map to get field type from Label
        Map<String,String> fieldLabelToTypeMap = new Map<String,String>();
        //Map to get field API Name from Label
        Map<String,String> fieldLabelToApiNameMap = new Map<String,String>();
        //Map to store field API Name of each field
        Map <String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get('AMA_Contract_Detail__c').getDescribe().fields.getMap();

        //To populate maps to get field type from API Name, Field API name from label and field type from label
        for(Schema.SObjectField sfield : fieldMap.Values()) {
            fieldLabelToApiNameMap.put(sfield.getDescribe().getLabel().toLowerCase(),sfield.getDescribe().getName());
            fieldLabelToTypeMap.put(sfield.getDescribe().getLabel().toLowerCase(),String.valueOf(sfield.getDescribe().getType()));
            fieldNameToTypeMap.put(sfield.getDescribe().getName(),String.valueOf(sfield.getDescribe().getType()));
        }

        String[] csvFieldNames;
        String[] csvRecordData;
        //Manual Row Iterator Code
        if(String.isBlank(contractDataAsString)) {
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'CSV file does not contain data.'));
                    return null;
        }

        if(hiddenContractListType.equalsIgnoreCase(CLIENT_LIST_LITERAL))
        {
            hiddenContractListType = CLIENT_LIST_LITERAL;
            Schema.DescribeFieldResult fieldResult = AMA_Contract_Detail__c.Contract_Type__c.getDescribe();
            List<Schema.PicklistEntry> pleForContractType = fieldResult.getPicklistValues();
            for(Schema.PicklistEntry f : pleForContractType)
            {
                    contractTypePicklistValues.put(f.getValue().toLowerCase(),f.getValue());
            }
        }
        else
        {
            hiddenContractListType = LETTERSHOP_LITERAL;
        }

        UTL_TPA_AMA_RowIterator lineIterator = New UTL_TPA_AMA_RowIterator(contractDataAsString,'\r\n','\n'); //Delimiters and alternate delimiters that will be used to get each row from csv file data

        String firstRow;
        Boolean isFirstRow = true;
        String nextRow;
        Integer dataRowIndex = 0;
        //system.assert(false,hiddenContractListType + 'abc' + contractListTypeTemp);
        while(lineIterator.hasNext()) {
            dataRowIndex++;
            if(isFirstRow) {

                isFirstRow = false;
                firstRow = lineIterator.next();
                //System.debug('**firstRow**'+firstRow);
                //To split first line of csv file to get heaader names
                csvFieldNames = firstRow.split(',');
                //System.debug('******csvFieldNames***'+csvFieldNames);
                String[] listNotMatch = new List<String>();

                Boolean containsUniqueID = false;
                for (Integer i = 0; i < csvFieldNames.size(); i++) {
                    csvFieldNames[i] = csvFieldNames[i].trim();
                    csvFieldNames[i] = csvFieldNames[i].replace('\r\n', '');
                    csvFieldNames[i] = csvFieldNames[i].replace('\n', '');
                    csvFieldNames[i] = csvFieldNames[i].replace('\r', '');
                    csvFieldNames[i] = csvFieldNames[i].replace('"', '');
                    //To check if the uploaded file is of the same contract type selected by user
                    if((csvFieldNames[i].equalsIgnoreCase(LETTERSHOP_LITERAL) && hiddenContractListType.equalsIgnoreCase(CLIENT_LIST_LITERAL))
                        || csvFieldNames[i].equalsIgnoreCase(FIELD_LABEL_CLIENT) && hiddenContractListType.equalsIgnoreCase(LETTERSHOP_LITERAL) ) {
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please Upload '+ hiddenContractListType +' File'));
                        return null;
                    }
                    if(csvFieldNames[i].toLowerCase() != FIELD_LEBEL_RECORD_COUNT && csvFieldNames[i].toLowerCase() != FIELD_HEADER_DOING_BUSINESS_AS) // Modified By Neha Bansal under CR-12673 
                        lstFieldLables.add(csvFieldNames[i]);
                    //Mapping csv file column names with the field labels
                    if(csvFieldNames[i].equalsIgnoreCase(LETTERSHOP_LITERAL)) {
                        csvFieldNames[i] = FIELD_LABEL_CLIENT;
                    }
                    if(csvFieldNames[i].containsIgnoreCase(FIELD_HEADER_ON_BEHALF_OF)) {
                        csvFieldNames[i] = FIELD_LABEL_CLIENT_SERVICES.toLowerCase();
                    }
                    if(csvFieldNames[i].containsIgnoreCase(FIELD_LABEL_MAX_FEE_REACHED) || csvFieldNames[i].containsIgnoreCase(FIELD_LABEL_MAX_SBII_FEE)) {
                        csvFieldNames[i] = FIELD_LABEL_MAX_FEE_REACHED.toLowerCase();
                    } 
                    // Modified By Neha Bansal under CR-12673 Starts
                    if(csvFieldNames[i].containsIgnoreCase(FIELD_HEADER_OFFSHORE_ACCESS) || csvFieldNames[i].containsIgnoreCase(FIELD_LABEL_Offshore_Access)) {
                        csvFieldNames[i] = FIELD_LABEL_Offshore_Access.toLowerCase();
                    }
                    if(csvFieldNames[i].containsIgnoreCase(FIELD_HEADER_OFFSHORE_STORAGE) || csvFieldNames[i].containsIgnoreCase(FIELD_LABEL_OFFSHORE_STORAGE)) {
                        csvFieldNames[i] = FIELD_LABEL_OFFSHORE_STORAGE.toLowerCase();
                    }
                    if(csvFieldNames[i].containsIgnoreCase(FIELD_LABEL_OFFSHORE_APPROVAL) || csvFieldNames[i].containsIgnoreCase(FIELD_HEADER_OFFSHORE_APPOVAL)) {
                        csvFieldNames[i] = FIELD_LABEL_OFFSHORE_APPROVAL.toLowerCase();
                    }
                    if(csvFieldNames[i].containsIgnoreCase(FIELD_LABEL_OFFSHORE_LOCATION)) {
                        csvFieldNames[i] = FIELD_LABEL_OFFSHORE_LOCATION.toLowerCase();
                    }
                    fieldNumberMap.put(csvFieldNames[i].toLowerCase(), i);
                    if( fieldLabelToApiNameMap.get(csvFieldNames[i].toLowerCase()) == null && csvFieldNames[i].toLowerCase() != FIELD_LEBEL_RECORD_COUNT && (csvFieldNames[i].toLowerCase() != FIELD_LABEL_OFFSHORE_APPROVAL.toLowerCase() && csvFieldNames[i].toLowerCase() != FIELD_LABEL_OFFSHORE_STORAGE.toLowerCase() && csvFieldNames[i].toLowerCase() != FIELD_HEADER_DOING_BUSINESS_AS.toLowerCase())) { // && csvFieldNames[i].toLowerCase() != FIELD_LEBEL_SPECIAL_TERMS_AND_CONDITION
                        listNotMatch.add(csvFieldNames[i]);
                    }
                    //if((csvFieldNames[i].toLowerCase() != FIELD_LABEL_OFFSHORE_APPROVAL.toLowerCase() && csvFieldNames[i].toLowerCase() != FIELD_LABEL_OFFSHORE_STORAGE.toLowerCase())) { 
                    lstFieldNames.add(fieldLabelToApiNameMap.get(csvFieldNames[i].toLowerCase()));
                    //}
                    // Modified By Neha Bansal under CR-12673 Ends
                }
                if(listNotMatch.size()>0) {
                    String headersNotMatched = String.join( listNotMatch, ' , ');
                    if(headersNotMatched.length() > 255)
                    {
                        headersNotMatched = headersNotMatched.substring(0, 256) + '...';

                    }
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Following column headers of file do not match with AMA Contract Detail :'+ headersNotMatched));
                    return null;
                }
            } else {
                nextRow = lineIterator.next();
                if(nextRow.equalsIgnoreCase('File Ended')) {
                    break;
                }
                if(nextRow.trim() == '')
                    continue;
                //Creating instance of AMA Contract Object
                amaContractObj = new AMA_Contract_Detail__c();

                if(nextRow.endsWith(',')) {
                    nextRow = nextRow+' ';
                }
                
                //Regex Code
                if(nextRow.contains('"')) {
                    csvRecordData = getCSVrecordData(nextRow);
                } else {
                    csvRecordData = nextRow.split(',');
                }

                if(checkBlankRecord(csvRecordData)){ //cleanFields
                    continue;
                }

                multipleContractTypeSet.clear();
                invalidMultipleContractTypes.clear();
                Boolean multipleContractsFound =  false;

                try {
                    for (Integer col = 0; col < csvFieldNames.size() && col < csvRecordData.size(); col++) {
                        csvFieldNames[col] = csvFieldNames[col].trim().toLowerCase();
                        fieldNumber = fieldNumberMap.get(csvFieldNames[col]);
                        fieldValue = (csvRecordData[fieldNumber] == null) ? '' : csvRecordData[fieldNumber];  //(cleanFields[fieldNumber] == null) ? '' : cleanFields[fieldNumber];
                        String fieldAPIName = fieldLabelToApiNameMap.get(csvFieldNames[col]);
                        String fieldType = fieldLabelToTypeMap.get(csvFieldNames[col]);
                        System.debug('==fieldType=='+fieldType+'==fieldAPIName:'+fieldAPIName+'==csvFieldNames[col]:'+csvFieldNames[col]+'==fieldLabelToApiNameMap:'+fieldLabelToApiNameMap);
                        fieldValue = fieldValue.trim();
                        fieldValue = fieldValue.replace('"', '');
                        if(fieldValue != '' && fieldValue != null) {
                            if(csvFieldNames[col] != FIELD_LEBEL_RECORD_COUNT && csvFieldNames[col] != FIELD_HEADER_DOING_BUSINESS_AS) { // &&  csvFieldNames[col] != FIELD_LEBEL_SPECIAL_TERMS_AND_CONDITION // Modified By Neha Bansal under CR-12673
                                
                                if(fieldType.equalsIgnoreCase(DATA_TYPE_DATE)) {
                                    fieldValue = fieldValue.replace('-', '/');
                                    if(fieldValue != null && fieldValue !='') {

                                        if(parseDate(dataRowIndex,csvRecordData,fieldValue,csvFieldNames[col]) != null)
                                        amaContractObj.put(fieldAPIName, parseDate(dataRowIndex,csvRecordData,fieldValue,csvFieldNames[col]));

                                    }
                                } else if (fieldType.equalsIgnoreCase(DATA_TYPE_DATETIME)) {
                                    Datetime newDatetime = datetime.parse(fieldValue);
                                    amaContractObj.put(fieldAPIName, newDatetime);
                                } else if (fieldType.equalsIgnoreCase(DATA_TYPE_BOOLEAN)) {
                                    if(fieldValue.equalsIgnoreCase('y') || fieldValue.equalsIgnoreCase(LITERAL_TRUE)) {
                                        amaContractObj.put(fieldAPIName, true);
                                    } else if(!fieldValue.equalsIgnoreCase('n') && !fieldValue.equalsIgnoreCase(LITERAL_FALSE)) {
                                        String csvRecordString =  String.join( csvRecordData, ' , ' );
                                        csvRecordString = csvRecordString.replace(' ','&nbsp;');
                                        if(fieldValue.length()>40)
                                        {
                                            fieldValue = fieldValue.substring(0,40);
                                            fieldValue = fieldValue.replace(' ','&nbsp;');
                                            errorLogs.add(new ArrayWrapper(dataRowIndex,csvRecordString, ' Column Name: ' +csvFieldNames[col].toUpperCase()+'<br/>'+ 'Supported values are Y, True, N and False.' +' Invalid boolean value: ' +fieldValue+'...'));
                                        }
                                        else
                                        {
                                            fieldValue = fieldValue.replace(' ','&nbsp;');
                                            errorLogs.add(new ArrayWrapper(dataRowIndex,csvRecordString, ' Column Name: ' +csvFieldNames[col].toUpperCase()+'<br/>'+ 'Supported values are Y, True, N and False.' +' Invalid boolean value: ' +fieldValue));
                                        }

                                        errorContains = true;
                                    }
                                } else if(fieldType == DATA_TYPE_DOUBLE){


                                } else if(fieldType == DATA_TYPE_PICKLIST){

                                    if(fieldValue.contains(','))
                                    {
                                        multipleContractsFound =  true;
                                        list<string> multipleContractTypes = fieldValue.split(',');

                                        for(String contractType: multipleContractTypes)
                                        {
                                            contractType = contractType.trim();
                                            validateContractType(contractType);
                                        }

                                    }
                                    else
                                    {
                                        validateContractType(fieldValue);
                                    }

                                } else {

                                    integer maxlength;
                                    if(fieldAPIName == 'Client__c')
                                        maxlength = Schema.SObjectType.AMA_Contract_Detail__c.fields.Client__c.getLength();

                                    else if(fieldAPIName == 'DBL__c')
                                        maxlength = Schema.SObjectType.AMA_Contract_Detail__c.fields.DBL__c.getLength();
                                    // Modified By Neha Bansal under CR-12673 Starts
                                    else if( fieldAPIName == 'Offshore_Access__c') 
                                        maxlength = Schema.SObjectType.AMA_Contract_Detail__c.fields.Offshore_Access__c.getLength();
                                    
                                    else if( fieldAPIName == 'Offshore_Storage__c') 
                                        maxlength = Schema.SObjectType.AMA_Contract_Detail__c.fields.Offshore_Storage__c.getLength();
                                    // Modified By Neha Bansal under CR-12673 Ends
                                    else if( fieldAPIName == 'Client_Services_On_Behalf_Of__c') 
                                         maxlength = Schema.SObjectType.AMA_Contract_Detail__c.fields.Client_Services_On_Behalf_Of__c.getLength();

                                    else if( fieldAPIName == 'Special_Terms_And_Conditions__c')
                                         maxlength = Schema.SObjectType.AMA_Contract_Detail__c.fields.Special_Terms_And_Conditions__c.getLength();


                                    if(fieldValue.length() > maxlength) {

                                        String csvRecordString = String.join( csvRecordData, ' , ' );
                                        csvRecordString = csvRecordString.replace(' ','&nbsp;');
                                        if(fieldValue.length()>40)
                                        {
                                            fieldValue = fieldValue.substring(0,40);
                                            fieldValue = fieldValue.replace(' ','&nbsp;');
                                            errorLogs.add(new ArrayWrapper(dataRowIndex, csvRecordString, ' Column Name: ' +csvFieldNames[col].toUpperCase()+'<br/>'+' It can contain only '+maxlength+' characters.'+ ' Invalid value: ' +fieldValue+'...'));
                                        }
                                        else
                                        {
                                            fieldValue = fieldValue.replace(' ','&nbsp;');
                                            errorLogs.add(new ArrayWrapper(dataRowIndex, csvRecordString, ' Column Name: ' +csvFieldNames[col].toUpperCase()+'<br/>'+' It can contain only '+maxlength+' characters.'+ ' Invalid value: ' +fieldValue));
                                        }
                                        errorContains = true;
                                    }
                                    else{
                                        amaContractObj.put(fieldAPIName, fieldValue);
                                    }
                                }
                            }
                        }
                        else if(fieldAPIName == 'Client__c' || fieldAPIName == 'Client_Services_On_Behalf_Of__c' || fieldAPIName == 'Contract_Type__c'){
                            String csvRecordString =  String.join( csvRecordData, ' , ' );
                            csvRecordString = csvRecordString.replace(' ','&nbsp;');
                            errorLogs.add(new ArrayWrapper(dataRowIndex, csvRecordString, ' Column Name: ' +csvFieldNames[col].toUpperCase()+'<br/>'+' Recheck the file for empty/blank cells and fix before upload ' ));
                            errorContains = true;
                        }
                    }
                } catch(Exception e) {
                    String csvRecordString = String.join( csvRecordData, ' , ' );
                    csvRecordString = csvRecordString.replace(' ','&nbsp;');
                    errorLogs.add(new ArrayWrapper(dataRowIndex,csvRecordString,e.getMessage()));
                    errorContains = true;
                    UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(TRUE, FALSE, UTL_LogFactory.GUID, e.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + e.getLineNumber() + ':::CNT_TPA_AMA_ContractDtl_CSV_Import:::readCSVFile', ''));
                }
                if(hiddenContractListType.equalsIgnoreCase(LETTERSHOP_LITERAL)) {
                    amaContractObj.Contract_Type__c = LETTERSHOP_LITERAL;
                }
                amaContractObj.Contract_List_Type__c = hiddenContractListType;

                // logic for contract type
                if(!multipleContractTypeSet.isEmpty() && errorContains == false){

                        for(String contractType: multipleContractTypeSet)
                        {
                            AMA_Contract_Detail__c amaObj = new AMA_Contract_Detail__c();
                            amaObj = amaContractObj.clone(false, false, false, false);
                            amaObj.Contract_Type__c = contractType;
                            lstContracts.add(amaObj);
                        }

                } else if(multipleContractTypeSet.isEmpty() && errorContains == false && errorContainsForMultipleContractType ==  false){

                    lstContracts.add(amaContractObj);
                }


                if(errorContainsForMultipleContractType == true && !invalidMultipleContractTypes.isEmpty())
                {
                    String csvRecordString =  String.join(csvRecordData, ' , ' );
                    csvRecordString = csvRecordString.replace(' ','&nbsp;');
                    String invalidContractTypes = '';
                    for(String invalidContract: invalidMultipleContractTypes)
                    {
                        if(String.isBlank(invalidContractTypes))
                        {
                            invalidContractTypes = invalidContract;
                        }
                        else
                        {
                            invalidContractTypes = invalidContractTypes + ' , '+ invalidContract;
                        }
                    }
                    invalidContractTypes = invalidContractTypes.replace(' ','&nbsp;');
                    errorLogs.add(new ArrayWrapper(dataRowIndex,csvRecordString,  ' Column Name: CONTRACT TYPE' +'<br/>'+ 'Contract type not found.' +' Invalid Contract Type value: ' +invalidContractTypes));
                    

                }

                errorContains = false;
                errorContainsForMultipleContractType = false;
            }
        }
        //Create Json for error logs
        jsonDataError = '';
        jsonDataError = JSON.serialize( errorLogs );
        jsonDataError = String.escapeSingleQuotes(jsonDataError);
        jsonDataError = jsonDataError.remove('&nbsp;');
        jsonDataError = jsonDataError.remove('\\\\"');
        jsonDataError = jsonDataError.remove('\\\\n');
        jsonDataError = jsonDataError.replace('<br/>',', Error: ');
        //System.assert(false,jsonDataError);

        System.debug('**List data**'+lstContracts);
        if(lstContracts.size() == 0 && errorLogs.size() == 0) {
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.INFO, 'No records found in csv file.');
            ApexPages.addMessage(errorMessage);
        }
        totalRecordsToInsert = lstContracts.size();
        //Create Json for successful records
        jsonDataSuccess = '';
        jsonDataSuccess = JSON.serialize( lstContracts );
        jsonDataSuccess = String.escapeSingleQuotes(jsonDataSuccess);
        jsonDataSuccess = jsonDataSuccess.remove('&nbsp;');
        jsonDataSuccess = jsonDataSuccess.remove('\\\\"');
        jsonDataSuccess = jsonDataSuccess.remove('\\\\n');
        //System.assert(false,jsonDataSuccess);
        if(lstContracts.size() > 0)
        {
            try {
                isDataSaved = false;
                string type = hiddenContractListType.replaceAll( '\\s+', '');
                String name = 'TempAttachment'+'_'+ type;

                List<AMA_Contracts_Attachments__c> contractAttachments = SLT_TPAAMAContractsAttachments.instance.selectByFilterWithLimit( 'Contract_Attachment_Name__c = \'' + name + '\' ', 1);
                if(contractAttachments.size() > 0) {
                    delete contractAttachments[0];
                }
                attachmentId = saveAttachment(name);


            } catch(Exception err) {
                System.debug('***Exception While creating attachment****'+err.getMessage());
            }
         }
        return null;
    }

    /**
     * Name: validateContractType
     * @author: supriya Johari
     * @param:  String - ContractType
     * @return:   Boolean value
     * Desc: To handle the blank record updation case.
    **/

    public void validateContractType (string contractType)
    {
        if(contractTypePicklistValues.containsKey(contractType.toLowerCase())){

            multipleContractTypeSet.add(contractTypePicklistValues.get(contractType.toLowerCase()));
        }
        else
        {
            if(mapContractTypeNames == null)
            {
                mapContractTypes();

            }

            if(mapContractTypeNames != null)
            {

                if(!mapContractTypeNames.isEmpty() && string.isNotBlank(contractType) ){

                    if(mapContractTypeNames.containsKey(contractType.toLowerCase()))
                    {
                        multipleContractTypeSet.add(mapContractTypeNames.get(contractType.toLowerCase()));

                    } else
                    {
                        String newContractType = '';
                        Integer pos = contractType.lastIndexOf(' ');
                        if(pos >= 0)
                        {
                            String suffix = contractType.substring(pos+1);
                            if(suffix.isNumeric())
                            {
                                newContractType = contractType.substring(0, pos);
                            }
                        }
                        newContractType = newContractType.trim();

                        if(String.isNotBlank(newContractType) && contractTypePicklistValues.containsKey(newContractType.toLowerCase()))
                        {
                            multipleContractTypeSet.add(contractTypePicklistValues.get(newContractType.toLowerCase()));
                        }
                        else if(String.isNotBlank(newContractType) && mapContractTypeNames.containsKey(newContractType.toLowerCase()))
                        {
                            multipleContractTypeSet.add(mapContractTypeNames.get(newContractType.toLowerCase()));
                        }
                        else
                        {
                            invalidMultipleContractTypes.add(contractType);
                            errorContainsForMultipleContractType = true;
                        }
                    }
                }

            }
        }
    }


    /**
     * Name: checkBlankRecord
     * @param:  String[] - csvRecordData
     * @return:   Boolean value
     * Desc: To handle the blank record updation case.
    **/
    public Boolean checkBlankRecord(String[] csvRecordData) {
        String csvRecordString;
        csvRecordString =  String.join(csvRecordData, '' );
        if(String.isBlank(csvRecordString))
            return true;
        else
            return false;
    }

    public String[] getCSVrecordData(String contractDataLines) {
        String[] csvRecord ;
        Pattern commaPattern = Pattern.compile(',(?=([^\"]*\"[^\"]*\")*[^\"]*$)');
        csvRecord = commaPattern.split(contractDataLines);
        commaPattern = null;
        return csvRecord;
    }

    /**
     * Name: parseDate
     * @author: supriya Johari
     * @param:  String[] - csvRecordData and String - dateValue
     * @return:    Date
     * Desc: To handle the DateException while parsing date.
    **/
    public Date parseDate (Integer dataRowIndex,String[] csvRecordData,String dateValue, String csvFieldName) {
        Date newDate;
        try {
            newDate = date.parse(dateValue);
            return newDate;
        } catch(Exception e) {
            if(e.getMessage().contains(DATE_EXCEPTION_MESSAGE)) {
                String csvRecordString = String.join( csvRecordData, ' , ' );
                csvRecordString = csvRecordString.replace(' ','&nbsp;');

                if(dateValue.length()>40)
                {

                    dateValue = dateValue.substring(0,40);
                    dateValue = dateValue.replace(' ','&nbsp;');
                    errorLogs.add(new ArrayWrapper(dataRowIndex,csvRecordString,' Column Name: '+csvFieldName.toUpperCase()+'<br/>'+' Date format should be MM/DD/YYYY.'+' Invalid Date: ' +dateValue+'...' ));
                }
                else
                {
                    dateValue = dateValue.replace(' ','&nbsp;');
                    errorLogs.add(new ArrayWrapper(dataRowIndex,csvRecordString,' Column Name: '+csvFieldName.toUpperCase()+'<br/>'+' Date format should be MM/DD/YYYY.'+' Invalid Date: ' + dateValue ));
                }
            }
            errorContains = true;
            return null;
         }
    }


    /**
     * Name: mapContractTypes
     * @author: supriya Johari
     * @param:
     * @return:    void
     * Desc: To map all the possible contract types with correct contract type name.
    **/
    private void mapContractTypes ()
    {
        mapContractTypeNames =  new map<string,string>();
        for(TPA_AMA_Contract_Type__c amaContractTypes: [Select id,Name,AMA_Contract_Type__c, Contract_Type_Possible_Names__c from TPA_AMA_Contract_Type__c ]) {

            Boolean nameAdded = false;
            list<String> contractTypePossibleValues = amaContractTypes.Contract_Type_Possible_Names__c.split(';');
            for(String contractTypeValue : contractTypePossibleValues){
                mapContractTypeNames.put(contractTypeValue.toLowerCase(),amaContractTypes.AMA_Contract_Type__c);
                if(contractTypeValue == amaContractTypes.AMA_Contract_Type__c)
                {
                    nameAdded = true;
                }
            }
            if(!nameAdded){
                mapContractTypeNames.put(amaContractTypes.AMA_Contract_Type__c.toLowerCase(),amaContractTypes.AMA_Contract_Type__c);
            }
        }
    }





    /**
     * Name: saveData
     * @param:
     * @return:
     * Desc: To save the AMA Contract Details records that are fetched from CSV File
    **/
    public void saveData() {
        //Set a save point for rollback
        Savepoint sp = Database.setSavepoint();

        //Deleting existing records
        List<AMA_Contract_Detail__c> contractsList = SLT_AMAContractDetail.instance.selectByFilterOnly( 'Contract_List_Type__c = \'' + hiddenContractListType + '\' ');


        //Inserting new records
        try {
            List<AMA_Contracts_Attachments__c> contractsAttachmentsList = SLT_TPAAMAContractsAttachments.instance.selectByFilter(new Set<String>{'Contract_Attachment_Name__c'}, 'id = \'' + attachmentId + '\' ');
            if(contractsAttachmentsList.size() > 0) {
                contractsAttachmentsList[0].Contract_Attachment_Name__c = fileName;
                contractsAttachmentsList[0].Description__c= hiddenContractListType+' file uploaded on '+Datetime.now();
                saveSuccessAndErrorRecordsCSV();
                update contractsAttachmentsList[0];
                for (AMA_Contract_Detail__c obj : lstContracts) {
                    obj.AMA_Contracts_Attachments__c = attachmentId;
                }
            }
            BCH_TPA_AMA_ContractDtl_CSV_import bchObj = new BCH_TPA_AMA_ContractDtl_CSV_import();
            if(contractsList.size() > 0) {
                bchObj.action = 'deleteRecords';
                bchObj.contractsListToDelete = contractsList;
                bchObj.contractsListToinsert = lstContracts;
            }else{
                bchObj.action = 'insertRecords';
                bchObj.contractsListToinsert = lstContracts;

            }
            Database.executeBatch(bchObj);
            isDataSaved = true;
            size = 10;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO, 'AMA Contract Detail records inserted successfully.'));

        } catch (Exception e) {
            Database.rollback(sp);
            if(attachmentId != null){
              List<AMA_Contracts_Attachments__c> attachList = SLT_TPAAMAContractsAttachments.instance.selectByFilterOnly( 'id = \'' + attachmentId + '\' ');
              if(attachList.size() > 0)
                  delete attachList[0];
            }
            UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(TRUE, FALSE, UTL_LogFactory.GUID, e.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + e.getLineNumber() + ':::CNT_TPA_AMA_ContractDtl_CSV_Import:::saveData', ''));
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'An error has occurred while saving data. <br/> Error Message:-'+e.getMessage()));
        }
    }

    /**
     * Name: saveAttachment
     *
     *
     *
    **/
    public String saveAttachment(String name)
    {

        try{
            AMA_Contracts_Attachments__c contractsAttachment= new AMA_Contracts_Attachments__c();
            contractsAttachment.Contract_Attachment_Name__c = name;
            insert contractsAttachment;

            Attachment attach= new Attachment();
            attach.Body= csvFileBody;
            attach.Name= fileName;
            attach.ContentType = 'text/csv';
            attach.ParentID = contractsAttachment.id;

            insert attach;



            return contractsAttachment.id;

        }
        catch(Exception e)
        {
            UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(TRUE, FALSE, UTL_LogFactory.GUID, e.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + e.getLineNumber() + ':::CNT_TPA_AMA_ContractDtl_CSV_Import:::saveAttachment', ''));
            System.assert(false,e.getMessage());
            return null;
        }
    }


    /**
     * Name: saveSuccessRecordsCSV
     * @author: supriya Johari
     * @param: String Id of AMA contract attachment
     * @return: void
     * Desc: To save Success records of CSV file
    **/
    public void saveSuccessAndErrorRecordsCSV() {
        if(String.isNotBlank(successRecordAsString)) {
            //creating Attachment Object
            Attachment attach= new Attachment();
            attach.Body = Blob.valueof(successRecordAsString); //Modified By Neha Bansal under Issue-12354
            attach.Name= 'SuccessRecords.csv';
            attach.ContentType = 'text/csv';
            attach.ParentID = attachmentId;
            insert attach;
        }

        if(String.isNotBlank(errorRecordAsString)) {
            errorRecordCSVFile = Blob.valueof(errorRecordAsString);

            //creating Attachment Object
            Attachment attach= new Attachment();
            attach.Body= errorRecordCSVFile;
            attach.Name= 'ErrorRecords.csv';
            attach.ContentType = 'text/csv';
            attach.ParentID = attachmentId;
            insert attach;
        }
    }



    /**
     * Name: Next
     * @param:
     * @return:
     * Desc: To show records of the next page
    **/
    public void Next() {
        counter = counter+size;
    }

    /**
     * Name: Previous
     * @param:
     * @return:
     * Desc: To show records of the previous page
    **/
    public void Previous() {
        counter = counter-size;
    }

    /**
    * Name: NextForErrorLogs
    * @param:
    * @return:
    * Desc: To show records of the next page for ErrorLogs
    **/
    public void NextForErrorLogs() {
    errorLogCounter = errorLogCounter+errorLogSize;
    }

    /**
     * Name: PreviousForErrorLogs
     * @param:
     * @return:
     * Desc: To show records of the previous page for ErrorLogs
    **/
    public void PreviousForErrorLogs() {
        errorLogCounter = errorLogCounter-errorLogSize;
    }

    /**
     * Name: First
     * @param:
     * @return:
     * Desc: To show records of the first page
    **/
    public void First() {
        counter = 0;
    }

    /**
     * Name: Last
     * @param:
     * @return:
     * Desc: To show records of the last page
    **/
    public void Last() {
        counter = lstContracts.size()-math.mod(lstContracts.size(), size);
    }


    /**
     * Name: FirstForErrorLogs
     * @param:
     * @return:
     * Desc: To show records of the first page for error Logs
    **/
    public void FirstForErrorLogs() {
        errorLogCounter = 0;
    }

    /**
     * Name: LastForErrorLogs
     * @param:
     * @return:
     * Desc: To show records of the last page for error Logs
    **/
    public void LastForErrorLogs() {
        errorLogCounter = errorLogs.size()-math.mod(errorLogs.size(), errorLogSize);
    }


    /**
     * Name: getHasNext
     * @param:
     * @return:
     * Desc: To get if the current page has any next page
    **/
    public Boolean getHasNext() {
        if(counter+size < lstContracts.size())
            return false;
        return true;
    }


    /**
     * Name: getHasPrevious
     * @param:
     * @return: Boolean : Returns True if page has any previous page else returns false
     * Desc: To get if the current page has any previous page
    **/
    public Boolean getHasPrevious() {
        if(counter > 0)
            return false;
        return true;
    }

    /**
     * Name: getHasNextForErrorLogs
     * @param:
     * @return:
     * Desc: To get if the current page has any next page for ErrorLogs
    **/
    public Boolean getHasNextForErrorLogs() {
        if(errorLogCounter+errorLogSize < errorLogs.size())
            return false;
        return true;
    }

    /**
     * Name: getHasPreviousForErrorLogs
     * @param:
     * @return: Boolean : Returns True if page has any previous page else returns false
     * Desc: To get if the current page has any previous page for ErrorLogs
    **/
    public Boolean getHasPreviousForErrorLogs() {
        if(errorLogCounter > 0)
            return false;
        return true;
    }

    /**
     * Name: getPageNumber
     * @param:
     * @return: Integer: Returns current page number
     * Desc: To get the current page number
    **/
    public Integer getPageNumber() {
        return counter/size + 1;
    }

    /**
     * Name: getPageNumberForErrorLogs
     * @param:
     * @return: Integer: Returns current page number for ErrorLogs
     * Desc: To get the current page number for ErrorLogs
    **/
    public Integer getPageNumberForErrorLogs() {
        return errorLogCounter/errorLogSize + 1;
    }

    /**
     * Name: getTotalPages
     * @param:
     * @return: Return total number of pages
     * Desc: To get number of total pages
    **/
    public Integer getTotalPages() {
        if (math.mod(lstContracts.size(), size) > 0) {
            return lstContracts.size()/size + 1;
        } else {
            return (lstContracts.size()/size);
        }
    }

    /**
     * Name: getTotalPagesForErrorLogs
     * @param:
     * @return: Return total number of pages for ErrorLogs
     * Desc: To get number of total pages for ErrorLogs
    **/
    public Integer getTotalPagesForErrorLogs() {
        if (math.mod(errorLogs.size(), errorLogSize) > 0) {
            return errorLogs.size()/errorLogSize + 1;
        } else {
            return (errorLogs.size()/errorLogSize);
        }
    }

    /**
     * Name: getChangeListSize
     * @param:
     * @return:
     * Desc: To change the number the records to be shown on the page
    **/
    public void getChangeListSize() {
        counter = 0;
    }

    /**
     * Name: getChangeListSize
     * @param:
     * @return:
     * Desc: To change the number the records to be shown on the page
    **/
    public void getChangeListSizeForErrorLogs() {
        errorLogCounter = 0;
    }

    public Integer getCpuTime() {
        return Limits.getCpuTime();
    }
}