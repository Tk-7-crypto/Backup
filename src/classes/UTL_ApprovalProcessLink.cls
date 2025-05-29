public class UTL_ApprovalProcessLink {
    public static String generateApprovalURL(Id recordID){  
        SLT_ProcessInstanceWorkitem processIntance = new SLT_ProcessInstanceWorkitem();
        List<ProcessInstanceWorkitem> workItemLst =   processIntance.getProcessInstanceWorkitemByTargetId(new Set<Id>{recordID});
        return generateUrl(workItemLst);  
    }  
    
    public static String generateUrl(List<ProcessInstanceWorkitem> workItemLst ){
        String url='';  
        if(workItemLst.size() > 0)  
        {              
        url= CON_CSM_OneKey.S_HTTP+ System.URL.getSalesforceBaseUrl().getHost() +   
         CON_CSM_OneKey.S_PROCESS + workItemLst[0].id;     
        } 
        
        return url; 
    }
}