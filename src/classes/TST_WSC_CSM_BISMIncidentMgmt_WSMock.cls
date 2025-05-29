@isTest
global class TST_WSC_CSM_BISMIncidentMgmt_WSMock implements WebServiceMock{
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
            WSC_CSM_BISMIncidentMgmt.message_element response_x = new WSC_CSM_BISMIncidentMgmt.message_element();
            WSC_CSM_BISMIncidentMgmt.messageHeaderType header = new WSC_CSM_BISMIncidentMgmt.messageHeaderType();
            WSC_CSM_BISMIncidentMgmt.systemAddressType sender = new WSC_CSM_BISMIncidentMgmt.systemAddressType();
            WSC_CSM_BISMIncidentMgmt.systemAddressType receiver = new WSC_CSM_BISMIncidentMgmt.systemAddressType();
            WSC_CSM_BISMIncidentMgmt.responseType rs = new WSC_CSM_BISMIncidentMgmt.responseType();
            header.transactionId = 'transactionId';
            header.initiator = 'POLARIS';
            header.currentOwner = 'POLARIS';
            //callerid
            sender.id = '12345';
            sender.name = 'POLARIS';
            header.sender = sender;
            receiver.id = '1234';
            receiver.name = 'BISNOW';
            header.receiver = receiver;
            response_x.header = header;
            System.debug('header.sender.id : '+header.sender.id);
            rs.type_x = 'createTicket';
            rs.status = 'nok';
            rs.ownershipTransferred = false;
            rs.message = 'Please fill in mandatory info in the following header fields and resend the request: transactionId';
            response_x.response = rs;
            Map<String, WSC_CSM_BISMIncidentMgmt.message_element> response_map_x = new Map<String, WSC_CSM_BISMIncidentMgmt.message_element>();
            response.put('response_x', response_x);
           }
}