@RestResource(urlMapping = '/TemplateData/*')
global with sharing class UTL_GetTemplateDataRest {
    @HttpGet
    global static List<TemplateData> getTemplateData()
    {
        RestRequest request = RestContext.request;
        return CPQ_Utility.getTemplateData(request.requestURI.substring(request.requestURI.lastIndexOf('/') + 1));
    }

    global class TemplateData
    {
        public String cellReference;
        public String dmlType;
        public String fieldName;
        public String objectName;
        public String packageName;
        public String sdataType;
        public Integer templateVersion;
    }
}