/*
* Version       : 1.0
* Description   : This class is used to get approval URL in visualforce email template
*/
public class CNT_CSM_ApprovalURL {
    public String recID {get; set;}  
    
    public String urlStr{  
        get  
        {  
            return UTL_ApprovalProcessLink.generateApprovalURL(recID);  
        }
    } 
}