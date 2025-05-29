@isTest 
global class TST_WSC_CSM_ServiceNowCom_WSMock implements WebServiceMock {
   global void doInvoke(
           Object stub,
           Object request,
           Map<String, Object> response,
           String endpoint,
           String soapAction,
           String requestName,
           String responseNS,
           String responseName,
           String responseType) {
               WSC_CSM_SNow_Internal_SforceCase.insertResponse_element[] resList = new List<WSC_CSM_SNow_Internal_SforceCase.insertResponse_element>();
               WSC_CSM_SNow_Internal_SforceCase.insertResponse_element res= new WSC_CSM_SNow_Internal_SforceCase.insertResponse_element();
               res.display_name = 'INT0003';
               res.display_value = 'INT0003';
               resList.add(res);
       response.put('response_x', resList); 
   }
}