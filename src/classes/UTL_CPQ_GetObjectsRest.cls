@RestResource(urlMapping = '/objects/*')
global with sharing class UTL_CPQ_GetObjectsRest {
    @HttpGet
    global static Map<String, List<Objects>> getObjectList()
    {
        RestRequest request = RestContext.request;
        return CPQ_Utility.getObjectList();
    }

    global class Objects
    {
        public String label;
        public String apiName;
        public Integer seq;
    }
}