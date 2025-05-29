public without sharing class UTL_OWF_DataProcessUtility {
    
    public static String getData(String payload,String requestedBy){ 
        Map<String, Object> ap_payload = payload != null ? (Map<String, Object>)JSON.deserializeUntyped(payload) : null;
        Map<String, List<String>> ObjectTofieldMappingsMap = new Map<String, List<String>>();
        Map<String, Map<String,String>> ObjectToCellReferenceAndfieldMappingsMap = new Map<String, Map<String,String>>();
        Map<String, Set<String>> objectNameToIdMap = new Map<String, Set<String>>();
        List<Map<String, List<Object>>> data = new List<Map<String, List<Object>>>();
        try{
            for(String objectName : ap_payload.keySet()){
                List<Object> objectList = (List<Object>)ap_payload.get(objectName);
                Map<String,Object> objectData = (Map<String, Object>)objectList[0];
                objectNameToIdMap.put(objectName,new Set<String>(String.valueOf(objectData.get('Id')).split(',')));
            }
           for (Template_Data__c mapping : [SELECT Id, Cell_Reference__c, Field_Name__c, Object_Name__c FROM Template_Data__c WHERE Object_Name__c IN: ap_payload.keySet() AND DML_Type__c ='Read' and Status__c ='Active' and Requested_By__c =: requestedBy]) {
                if(ObjectTofieldMappingsMap.containsKey(mapping.Object_Name__c)){
                    ObjectToCellReferenceAndfieldMappingsMap.get(mapping.Object_Name__c).put(mapping.Cell_Reference__c,mapping.Field_Name__c);
                    ObjectTofieldMappingsMap.get(mapping.Object_Name__c).add(mapping.Field_Name__c);
                }
                else{
                    ObjectToCellReferenceAndfieldMappingsMap.put(mapping.Object_Name__c,new Map<String,String>());
                    ObjectToCellReferenceAndfieldMappingsMap.get(mapping.Object_Name__c).put(mapping.Cell_Reference__c,mapping.Field_Name__c);
                    ObjectTofieldMappingsMap.put(mapping.Object_Name__c,new List<String>{mapping.Field_Name__c});
                }
            }
            for(String objectName : ObjectTofieldMappingsMap.keySet()){
                String query ='SELECT '+ String.join(ObjectTofieldMappingsMap.get(objectName),',')+ ' FROM '+ objectName+ ' WHERE Id in (\'' + String.join(objectNameToIdMap.get(objectName), '\',\'') +'\')';
                data.add(prepareData(objectName, DataBase.query(query), ObjectToCellReferenceAndfieldMappingsMap));
            }
            return JSON.serialize(data); 
        }
        catch(Exception e){
            Map<String, Map<String,String>> errors = new Map<String, Map<String,String>>();
            errors.put('Error', new Map<String,String>());
            errors.get('Error').put('An exception occured',e.getMessage());
            return JSON.serialize(new List<Map<String, Map<String,String>>>{errors}); 
        }
    }
    
    private static Map<String,List<Object>> prepareData(String objectName, List<Sobject> objectData, Map<String, Map<String,String>> ObjectToCellReferenceAndfieldMappingsMap){
        Map<String,List<Object>> data = new Map<String,List<Object>>();
        Map<String,String> fieldData;
        data.put(objectName,new List<Object>());
        Map<String,String> cellreferenceTofieldAPIName = ObjectToCellReferenceAndfieldMappingsMap.get(objectName);
        for(Sobject objData: objectData){
            fieldData = new Map<String,String>();
            for(String cellreference: cellreferenceTofieldAPIName.keySet()){
                fieldData.put(cellreference,ExtractFieldValues(objData,(cellreferenceTofieldAPIName.get(cellreference))));
            }
            data.get(objectName).add(fieldData); 
        }
        
        return data;
        
    }
    
    public static string ExtractFieldValues(sObject objectData, string fieldAPIName){
        string fieldvalue='';
        if(fieldAPIName.contains('.')){
            List<string> splitedFields = fieldAPIName.split('\\.');
            try{
                for(integer i=0;i<splitedFields.size()-1;i++){
                    objectData=objectData.getSobject(splitedFields[i]);   
                }
                fieldvalue = string.valueof(objectData.get(splitedFields[splitedFields.size()-1]));
            }catch(exception ex){
                system.debug('******exception while fetching fieldValues as relationship '+fieldAPIName+'  value is blank.'+ex.getmessage()); 
                fieldvalue='';
            }
            
        }else if(objectData.get(fieldAPIName)!=null){
            fieldvalue = string.valueOf(objectData.get(fieldAPIName));
        }
        return fieldvalue;
    }
	
    Public static String handlePutAndPostRequest(String requestBody) {
        try {
            Map<String, Object> json = requestBody != null ? (Map<String, Object>)System.JSON.deserializeUntyped(requestBody) : null;
            Map<String, String> fieldMappings = new Map<String, String>();
            Map<String, Boolean> fieldToRequiredMap = new Map<String, Boolean>();
            Map<String, String> reverseMappings = new Map<String, String>();
            for (Template_Data__c mapping : [SELECT Id, Cell_Reference__c, Field_Name__c, Required__c, Object_Name__c FROM Template_Data__c WHERE Object_Name__c IN: json.keySet() AND DML_Type__c ='Write' and Status__c ='Active' WITH SECURITY_ENFORCED]) {
                fieldMappings.put(mapping.Cell_Reference__c, mapping.Field_Name__c);
                reverseMappings.put(mapping.Field_Name__c, mapping.Cell_Reference__c);
                fieldToRequiredMap.put(mapping.Field_Name__c,mapping.Required__c);
            }
            
            Map<String, Object> transformed = (Map<String, Object>)transformKeys((Object)System.JSON.deserializeUntyped(requestBody), fieldMappings);
            List<sObject> sObjectList = new List<sObject>();
            Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();
            for (String valueKey : transformed.keySet()) {
                Map<String, Schema.SObjectField> fieldsMap = globalDescribe.get(valueKey).getDescribe().fields.getMap();
                Type dynamicType = Type.forName('Schema.' + valueKey);
                for (Object record : (List<Object>)transformed.get(valueKey)) {
                    sObjectList.add(createEntry(dynamicType, fieldsMap, (Map<String, Object>)record,fieldToRequiredMap));
                }
            }
            if (sObjectList.size() > 0) {
                upsert sObjectList;
            }
            return 'Success';
        }
        catch(Exception e) {
            return e.getMessage();
        }
    }
	
	private static Object transformKeys(Object data, Map<String, String> keyMapping) {
        if (data instanceof Map<String, Object>) {
            Map<String, Object> originalMap = (Map<String, Object>) data;
            Map<String, Object> newMap = new Map<String, Object>();

            for (String key : originalMap.keySet()) {
                String newKey = keyMapping.containsKey(key) ? keyMapping.get(key) : key;
                newMap.put(newKey, transformKeys(originalMap.get(key), keyMapping));
            }

            return newMap;

        } else if (data instanceof List<Object>) {
            List<Object> originalList = (List<Object>) data;
            List<Object> newList = new List<Object>();

            for (Object item : originalList) {
                newList.add(transformKeys(item, keyMapping));
            }

            return newList;
        }

        return data;
    }
	
    public static sObject createEntry(Type dynamicType, Map<String, Schema.SObjectField> fieldsMap, Map<String, Object> fields, Map<String, Boolean> fieldToRequiredMap) {
        SObject sobj = (SObject) dynamicType.newInstance();
        String errorMessage = '';
        for (String fieldName : fields.keySet()) {
            if (!fieldsMap.containsKey(fieldName)) continue;

            Schema.DescribeFieldResult fDesc = fieldsMap.get(fieldName).getDescribe();
            Schema.DisplayType type = fDesc.getType();
            Object val = fields.get(fieldName);

            try {
                //Boolean required = false;
                Boolean required = fieldToRequiredMap.containsKey(fieldName) ? fieldToRequiredMap.get(fieldName) : false;
                if(required && (val == null || val == '')) {
                    errorMessage += fieldName +' ,';
                }
                if (val == null || val == '') {
                    sobj.put(fieldName, null);
                } else if (type == Schema.DisplayType.String) {
                    sobj.put(fieldName, String.valueOf(val));
                } else if (type == Schema.DisplayType.Boolean && val instanceof Boolean) {
                    sobj.put(fieldName, (Boolean)val);
                } else if (type == Schema.DisplayType.Date && val instanceof String) {
                    sobj.put(fieldName, Date.valueOf((String)val));
                } else if ((type == Schema.DisplayType.Integer || type == Schema.DisplayType.Double) && val instanceof Decimal) {
                    sobj.put(fieldName, (Decimal)val);
                } else if (type == Schema.DisplayType.Integer && val instanceof Integer) {
                    sobj.put(fieldName, (Integer)val);
                } else {
                    sobj.put(fieldName, val);
                    // Unsupported or mismatched types can be logged/skipped
                }
            } catch (Exception ex) {
                System.debug('error '+ex);
            }
        }
        if(errorMessage != '') {
            errorMessage = errorMessage.removeEnd(',');
            errorMessage += 'filed can\'t be blank';
            DmlException e = new DmlException();
            e.setMessage(errorMessage);
    		throw e;
        }
        return sobj;
    }

}