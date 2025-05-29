public class TPA_Dyn_Off_Not_GeneratorQueue implements Queueable,Database.AllowsCallouts { 
    public String reqId = '';
    public String vendorAccountId = '';
    public String clientLanguage = '';
    public String vendorLanguage = '';
    public String reqName = '';
    public String GUID = '';
    public String ClientContactEmail = '';
    public Boolean isdynamicOffNotificationReqForVendor = False;
    public String reqStatus = '';
    public String runType;
    public Boolean isLAADResponseReq ; //Added By Neha Under CR-11850
    public Set<Id> allPurposeIds;
    public Boolean isRunTPAButtonClicked;
    public Boolean isAckByClient;
     
    public static final string CLIENT_CON = 'Client';  //Added by Vikram Singh under Issue-9952
    public static final string VENDOR_CON = 'Vendor';
    
    public void execute(QueueableContext context) {
       // if(isRunTPAButtonClicked && !isAckByClient){
        // if(runType == 'RunTpaBusinessRule'){
        //     SRV_TPA_DocusignEnvelope.generateDocForSign(reqId, GUID); 
        // }
      SRV_TPA_TPARequest.generateOffNotificationDoc(reqId, CLIENT_CON, vendorAccountId, clientLanguage, reqName, ClientContactEmail, isdynamicOffNotificationReqForVendor, reqStatus, GUID); 
      SRV_TPA_TPARequest.generateOffNotificationDoc(reqId, VENDOR_CON, vendorAccountId, vendorLanguage, reqName, ClientContactEmail, isdynamicOffNotificationReqForVendor, reqStatus, GUID); 
        
    }
    
}