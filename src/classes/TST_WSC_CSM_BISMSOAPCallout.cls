public class TST_WSC_CSM_BISMSOAPCallout {
    
     public static WSC_CSM_BISMIncidentMgmt.message_element  createTicket(WSC_CSM_BISMIncidentMgmt.messageHeaderType header, WSC_CSM_BISMIncidentMgmt.ticketInformationType createTicket) {
         CSM_ExternalClient_info__c cc = CSM_ExternalClient_info__c.getValues('BISM');
         //String endpoint_x = 'https://api-dev.boehringer-ingelheim.com:8443/incident-management-api/v1/ticket';
         String endpoint_x = cc.Client_Url__c;
         Map<String,String> head = new Map<String,String>();
         head.put('KeyId', cc.Password__c);
         WSC_CSM_BISMIncidentMgmt.HTTPS_Port_DEV dev = new WSC_CSM_BISMIncidentMgmt.HTTPS_Port_DEV();
         dev.inputHttpHeaders_x = head;
         return dev.CreateTicket(header, createTicket);
     }
    
    public static WSC_CSM_BISMIncidentMgmt.message_element  UpdateTicket(WSC_CSM_BISMIncidentMgmt.messageHeaderType header, WSC_CSM_BISMIncidentMgmt.ticketInformationType updateTicket) {
         CSM_ExternalClient_info__c cc = CSM_ExternalClient_info__c.getValues('BISM');
         //String endpoint_x = 'https://api-dev.boehringer-ingelheim.com:8443/incident-management-api/v1/ticket';
         String endpoint_x = cc.Client_Url__c;
         Map<String,String> head = new Map<String,String>();
         head.put('KeyId', cc.Password__c);
         WSC_CSM_BISMIncidentMgmt.HTTPS_Port_DEV dev = new WSC_CSM_BISMIncidentMgmt.HTTPS_Port_DEV();
         dev.inputHttpHeaders_x = head;
         return dev.UpdateTicket(header, updateTicket); 
     }
    
    public static WSC_CSM_BISMIncidentMgmt.message_element  ActivityUpdate(WSC_CSM_BISMIncidentMgmt.messageHeaderType header, WSC_CSM_BISMIncidentMgmt.activityUpdateType activityTicket) {
         CSM_ExternalClient_info__c cc = CSM_ExternalClient_info__c.getValues('BISM');
         //String endpoint_x = 'https://api-dev.boehringer-ingelheim.com:8443/incident-management-api/v1/ticket';
         String endpoint_x = cc.Client_Url__c;
         Map<String,String> head = new Map<String,String>();
         head.put('KeyId', cc.Password__c);
         WSC_CSM_BISMIncidentMgmt.HTTPS_Port_DEV dev = new WSC_CSM_BISMIncidentMgmt.HTTPS_Port_DEV();
         dev.inputHttpHeaders_x = head;
         return dev.activityUpdate(header, activityTicket); 
     }
    
    public static WSC_CSM_BISMIncidentMgmt.message_element  CloseTicket(WSC_CSM_BISMIncidentMgmt.messageHeaderType header,WSC_CSM_BISMIncidentMgmt.closeTicketType closeTicket) {
         CSM_ExternalClient_info__c cc = CSM_ExternalClient_info__c.getValues('BISM');
         //String endpoint_x = 'https://api-dev.boehringer-ingelheim.com:8443/incident-management-api/v1/ticket';
         String endpoint_x = cc.Client_Url__c;
         Map<String,String> head = new Map<String,String>();
         head.put('KeyId', cc.Password__c);
         WSC_CSM_BISMIncidentMgmt.HTTPS_Port_DEV dev = new WSC_CSM_BISMIncidentMgmt.HTTPS_Port_DEV();
         dev.inputHttpHeaders_x = head;
         return dev.CloseTicket(header, closeTicket); 
     }
    
    public static WSC_CSM_BISMIncidentMgmt.message_element  ResolveTicket(WSC_CSM_BISMIncidentMgmt.messageHeaderType header,WSC_CSM_BISMIncidentMgmt.resolveTicketType resolveTicket) {
         CSM_ExternalClient_info__c cc = CSM_ExternalClient_info__c.getValues('BISM');
         //String endpoint_x = 'https://api-dev.boehringer-ingelheim.com:8443/incident-management-api/v1/ticket';
         String endpoint_x = cc.Client_Url__c;
         Map<String,String> head = new Map<String,String>();
         head.put('KeyId', cc.Password__c);
         WSC_CSM_BISMIncidentMgmt.HTTPS_Port_DEV dev = new WSC_CSM_BISMIncidentMgmt.HTTPS_Port_DEV();
         dev.inputHttpHeaders_x = head;
         return dev.ResolveTicket(header, resolveTicket); 
     }
    
    public static WSC_CSM_BISMIncidentMgmt.message_element  ConfirmTicket(WSC_CSM_BISMIncidentMgmt.messageHeaderType header,WSC_CSM_BISMIncidentMgmt.responseType response) {
         CSM_ExternalClient_info__c cc = CSM_ExternalClient_info__c.getValues('BISM');
         //String endpoint_x = 'https://api-dev.boehringer-ingelheim.com:8443/incident-management-api/v1/ticket';
         String endpoint_x = cc.Client_Url__c;
         Map<String,String> head = new Map<String,String>();
         head.put('KeyId', cc.Password__c);
         WSC_CSM_BISMIncidentMgmt.HTTPS_Port_DEV dev = new WSC_CSM_BISMIncidentMgmt.HTTPS_Port_DEV();
         dev.inputHttpHeaders_x = head;
         return dev.ConfirmTicket(header, response); 
     }

}