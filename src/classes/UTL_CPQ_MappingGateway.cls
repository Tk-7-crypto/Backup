/*
* Version       : 0.0.1
* Description   : This Apex class is Utility layer for Mapping Layer API
* Created By    : Danish khan
* Created For   : Mapping layer API
*/
public class UTL_CPQ_MappingGateway {
    
    public static WPR_CPQ_ReturnItems handleGetRequest(WPR_CPQ_SOQLConstructor requestToken) {

        WPR_CPQ_ReturnItems res = new WPR_CPQ_ReturnItems(true, '', '');
        
        try {
            if (requestToken.entity != null && String.isBlank(requestToken.entity)) {
                res.isSuccess = false;
                res.errorMsg = 'Missing required parameter: entity name';
                return res;
            }
            Schema.SObjectType sObjType = Schema.getGlobalDescribe().get(requestToken.entity);
            Map<String, String> apiToRelationship = new Map<String, String>();
            Map<String, String> fieldMapping = new Map<String, String>();
            String currentCondition = 'Object_Name__c = \'' + requestToken.entity + '\'';
            
            for (ChildRelationship rel : sObjType.getDescribe().getChildRelationships()) {
                if (rel.getRelationshipName() == null) {
                    continue;
                }
                apiToRelationship.put(String.valueOf(rel.getChildSObject()), String.valueOf(rel.getRelationshipName()));
            }
            for (WPR_CPQ_SubSOQLConstructor subQ : requestToken.subQueries) {
                if (apiToRelationship.containsKey(subQ.entity)) {
                    currentCondition += ' OR Object_Name__c = \'' + subQ.entity + '\'';
                    subQ.entity = apiToRelationship.get(subQ.entity);
                }
            }
            for (Template_Data__c mapping : new SLT_Template_Data().getTemplateDataByCondition(currentCondition, new Set<String>{'Cell_Reference__c', 'Field_Name__c'})) {
                fieldMapping.put(mapping.Field_Name__c, mapping.Cell_Reference__c);
                if (mapping.Cell_Reference__c == requestToken.entity) requestToken.entity = mapping.Field_Name__c;
            }
            if (sObjType == null) {
                res.isSuccess = false;
                res.errorMsg = 'Invalid object name : ' + requestToken.entity;
                return res;
            }

            if (fieldMapping.size() == 0 && requestToken.fields.size() == 0) {
                res.isSuccess = false;
                res.errorMsg = 'fields not found';
                return res;
            }
            currentCondition = requestToken.whereClause;
            Set<String> fields;
            if (requestToken.fields.size() > 0) {
                fields = new Set<String>(requestToken.fields);
            } else {
                fields = new Set<String>{'Id'};
                fields.addAll(fieldMapping.keySet());
                fields.remove(requestToken.entity);
            }
            res.isSuccess = true;
            res.result = JSON.serialize(transformKeys((Object)JSON.deserializeUntyped(new SLT_MappingGateway().selectSObjectByCondition(sObjType, currentCondition, fields, requestToken.orderBy, requestToken.limitClause, requestToken.subQueries)), fieldMapping)); 
            res.errorMsg = 'Request Was Successfully Processed.';
            return res;
        } catch (Exception e) {
            res.isSuccess = false;
            res.errorMsg = 'Error: ' + e.getMessage() + '\n' + e.getStackTraceString();
            return res;
        }
    }

    public static WPR_CPQ_ReturnItems handlePostRequest(String payload) {
        try {
            List<sObject> sObjectList = processItems(payload);
            SRV_CPQ_MappingGateway.WPR_CPQ_UowDmlResult dmlResult;

            if (sObjectList.size() > 0) {
                dmlResult = SRV_CPQ_MappingGateway.insertRecords(sObjectList);
            }

            if (!dmlResult.success) {
                new WPR_CPQ_ReturnItems(false, 'Error: ' + String.valueOf(dmlResult.errors), JSON.serialize(dmlResult.records));
            }

            List<Map<String, Object>> resp = new List<Map<String, Object>>();

            for (SObject sobj : dmlResult.records) {
                Map<String, Object> res = new Map<String, Object>();
                res.put('Id', sobj.Id);
                resp.add(res);
            }
            return new WPR_CPQ_ReturnItems(true, 'Request Was Successfully Processed.', JSON.serialize(resp));
        } catch (Exception e) {
            return new WPR_CPQ_ReturnItems(false, 'Error: ' + e.getMessage() + '\n' + e.getStackTraceString(), null);
        }
    }
    public static WPR_CPQ_ReturnItems handlePutRequest(String payload) {
        try {
            List<sObject> sObjectList = processItems(payload);
            SRV_CPQ_MappingGateway.WPR_CPQ_UowDmlResult dmlResult;

            if (sObjectList.size() > 0) {
                dmlResult = SRV_CPQ_MappingGateway.updateRecords(sObjectList);
            }

            if (!dmlResult.success) {
                new WPR_CPQ_ReturnItems(false, 'Error: ' + String.valueOf(dmlResult.errors), JSON.serialize(dmlResult.records));
            }

            List<Map<String, Object>> resp = new List<Map<String, Object>>();

            for (SObject sobj : dmlResult.records) {
                Map<String, Object> res = new Map<String, Object>();
                res.put('Id', sobj.Id);
                resp.add(res);
            }
            return new WPR_CPQ_ReturnItems(true, 'Request Was Successfully Processed.', JSON.serialize(dmlResult.records));
        } catch (Exception e) {
            return new WPR_CPQ_ReturnItems(false, 'Error: ' + e.getMessage() + '\n' + e.getStackTraceString(), null);
        }
    }

    public static WPR_CPQ_ReturnItems handlePatchRequest() {
        return new WPR_CPQ_ReturnItems(true, 'Endpoint is accessible', '');
    }

    public static WPR_CPQ_ReturnItems handleDeleteRequest() {
        return new WPR_CPQ_ReturnItems(true, 'Endpoint is accessible', '');
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

    public static sObject createEntry(Type dynamicType, Map<String, Schema.SObjectField> fieldsMap, Map<String, Object> fields) {
        SObject sobj = (SObject) dynamicType.newInstance();
        for (String fieldName : fields.keySet()) {
            if (!fieldsMap.containsKey(fieldName)) continue;

            Schema.DescribeFieldResult fDesc = fieldsMap.get(fieldName).getDescribe();
            Schema.DisplayType type = fDesc.getType();
            Object val = fields.get(fieldName);

            try {
                if (val == null) {
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
                }
            } catch (Exception ex) {
                System.debug(ex.getMessage());
            }
        }
        return sobj;
    }
    
    public static List<sObject> processItems(String payload) {
        try {
            Map<String, Object> ap_payload = payload != null ? (Map<String, Object>)JSON.deserializeUntyped(payload) : null;
            Map<String, String> fieldMappings = new Map<String, String>();
            Map<String, String> reverseMappings = new Map<String, String>();
            
            for (Template_Data__c mapping : [SELECT Id, Cell_Reference__c, Field_Name__c, Object_Name__c FROM Template_Data__c WHERE Object_Name__c IN: ap_payload.keySet() WITH SECURITY_ENFORCED]) {
                fieldMappings.put(mapping.Cell_Reference__c, mapping.Field_Name__c);
                reverseMappings.put(mapping.Field_Name__c, mapping.Cell_Reference__c);
            }

            Map<String, Object> transformed = (Map<String, Object>)transformKeys((Object)JSON.deserializeUntyped(payload), fieldMappings);
            List<sObject> sObjectList = new List<sObject>();
            Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();

            for (String d3_value : transformed.keySet()) {
                Map<String, Schema.SObjectField> fieldsMap = globalDescribe.get(d3_value).getDescribe().fields.getMap();
                Type dynamicType = Type.forName('Schema.' + d3_value);
                for (Object record : (List<Object>)transformed.get(d3_value)) {
                    sObjectList.add(createEntry(dynamicType, fieldsMap, (Map<String, Object>)record));
                }
            }
            return sObjectList;
        } catch (Exception e) {
            System.debug(e.getMessage());
            return new List<sObject>();
        }
    }

    public static String getFieldValueFromRequestBody(RestRequest req, String token) {
        if (req == null) return '';
        return String.isNotBlank(req.headers.get(token)) ? req.headers.get(token) : String.isNotBlank(req.params.get(token)) ? req.params.get(token) : null;
    }
    
    public static List<UTL_CPQ_MappingGateway.WPR_CPQ_SubSOQLConstructor> getSubRequest(RestRequest req) {
        List<UTL_CPQ_MappingGateway.WPR_CPQ_SubSOQLConstructor> subRequests = new List<UTL_CPQ_MappingGateway.WPR_CPQ_SubSOQLConstructor>();
        String level = 'x';
        while (req != null && UTL_CPQ_MappingGateway.getFieldValueFromRequestBody(req, level + '-entity') != null) {
            subRequests.add(new UTL_CPQ_MappingGateway.WPR_CPQ_SubSOQLConstructor(
                UTL_CPQ_MappingGateway.getFieldValueFromRequestBody(req, level + '-entity'),
                UTL_CPQ_MappingGateway.getFieldValueFromRequestBody(req, level + '-condition'),
                (UTL_CPQ_MappingGateway.getFieldValueFromRequestBody(req, level + '-fields') == null  ? new List<String>() : 
                UTL_CPQ_MappingGateway.getFieldValueFromRequestBody(req, level + '-fields').contains(', ') ? UTL_CPQ_MappingGateway.getFieldValueFromRequestBody(req, level + '-fields').split(', ') :
                UTL_CPQ_MappingGateway.getFieldValueFromRequestBody(req, level + '-fields').contains(',') ? UTL_CPQ_MappingGateway.getFieldValueFromRequestBody(req, level + '-fields').split(',') : new List<String>{UTL_CPQ_MappingGateway.getFieldValueFromRequestBody(req, 'fields')})
            ));
            level += 'x';
        }
        return subRequests;
    }

    public class WPR_CPQ_ReturnItems {
        public Boolean isSuccess {get; set;}
        public String errorMsg {get; set;}
        public String result {get; set;}
        public WPR_CPQ_ReturnItems(Boolean isSuccess, String errorMsg, String result) {
            this.isSuccess = isSuccess;
            this.errorMsg = errorMsg;
            this.result = result;
        }
    }

    public class WPR_CPQ_SOQLConstructor {
        public String entity      {get;set;}
        public List<String> fields{get;set;}
        public String whereClause {get;set;}
        public String orderBy     {get;set;}
        public String limitClause {get;set;}
        public List<WPR_CPQ_SubSOQLConstructor> subQueries {get;set;}
        public WPR_CPQ_SOQLConstructor(String entity, String whereClause, List<String> fields, String orderBy, String limitClause, List<WPR_CPQ_SubSOQLConstructor> subQueries) {
            this.entity = entity;
            this.fields = fields;
            this.whereClause = whereClause;
            this.orderBy = orderBy;
            this.limitClause = limitClause;
            this.subQueries = subQueries;
        }
    }

    public class WPR_CPQ_SubSOQLConstructor {
        public String entity      {get;set;}
        public List<String> fields{get;set;}
        public String condition {get;set;}
        public WPR_CPQ_SubSOQLConstructor(String entity, String condition, List<String> fields) {
            this.entity = entity;
            this.fields = fields;
            this.condition = condition;
        }
    }
}
