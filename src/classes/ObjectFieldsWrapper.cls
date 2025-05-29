// Wrapper Class for Object Fields Detail
    public Class ObjectFieldsWrapper {
        
        @AuraEnabled
        public String fieldApiName;
        @AuraEnabled
        public String fieldLabel;
        @AuraEnabled
        public String fieldDataType;
        @AuraEnabled
        public List<String> fieldValues;
        @AuraEnabled
        public Map<String,String> fieldValuesMap;
	@AuraEnabled 
        public String fieldHelpText;
        
        /**
         * constructor
         * @params  String fieldApiName
         * @params  String fieldLabel
         * @params  Schema.DisplayType fieldDataType
         * @params  List<String> fieldValues
         */ 
        public ObjectFieldsWrapper(String fieldApiName, String fieldLabel, Schema.DisplayType fieldDataType, List<String> fieldValues, Map<String,String> fieldValuesMap) {
            this.fieldApiName = fieldApiName;
            this.fieldLabel = fieldLabel;
            this.fieldDataType = fieldDataType.name();
            this.fieldValues = fieldValues;
            this.fieldValuesMap = fieldValuesMap;
        }
        
        /**
         * constructor
         * @params  String fieldApiName
         * @params  String fieldLabel
         * @params  Schema.DisplayType fieldDataType
         * @params  List<String> fieldValues
         * @params  String fieldHelpText
         */ 
        public ObjectFieldsWrapper(String fieldApiName, String fieldLabel, Schema.DisplayType fieldDataType, List<String> fieldValues, String fieldHelpText) {
            this.fieldApiName = fieldApiName;
            this.fieldLabel = fieldLabel;
            this.fieldDataType = fieldDataType.name();
            this.fieldValues = fieldValues;
            this.fieldHelpText = fieldHelpText;
        }
    }