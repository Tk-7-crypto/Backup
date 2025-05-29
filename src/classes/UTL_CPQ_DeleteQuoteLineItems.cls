@RestResource(urlMapping = '/DeleteQuoteLineItems/*')
global with sharing class UTL_CPQ_DeleteQuoteLineItems
{
    @HttpGet
    global static ResponseObject deleteQuoteLineItems() 
    {
        RestRequest req = RestContext.request;
        Id parentId = req.requestURI.substring(req.requestURI.lastIndexOf('/') + 1);

        ResponseObject returnObj = new ResponseObject();
        try 
        {
            CPQ_RMUtility.deleteCountryInput(parentId);
            CPQ_RMUtility.deleteTimeline(parentId);
            CPQ_RMUtility.deleteAdminTimeEntryData(new Set<Id> {parentId});
            CPQ_RMUtility.deleteClinicalVisitFrequencyData(new Set<Id> {parentId});
            CPQ_RMUtility.deleteAttachment(parentId);
            CPQ_RMUtility.updateHeaderData(parentId);
            CPQ_Utility.deleteQuoteLineItems(parentId);
            returnObj.isSuccess = true;
        } 
        catch(Exception e) 
        {
            returnObj.isSuccess = false;
            returnObj.errorMessage = e.getMessage();
        }
        return returnObj;
    }
    global class ResponseObject 
    {
        public Boolean isSuccess;
        public String  errorMessage;
    }
}
