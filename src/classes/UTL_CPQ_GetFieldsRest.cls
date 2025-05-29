@RestResource(urlMapping = '/fields/*')
global with sharing class UTL_CPQ_GetFieldsRest {
    @HttpGet
    global static List<FieldsList> getObjectFields()
    {
        RestRequest request = RestContext.request;
        return CPQ_Utility.getObjectFields(request.requestURI.substring(request.requestURI.lastIndexOf('/') + 1));
    }
    global class FieldsList
    {
        public String label;
        public String apiName;
        public String description;
        public String sdataType;
        public String picklistValue;
        public Boolean IsRequired;
    }
}