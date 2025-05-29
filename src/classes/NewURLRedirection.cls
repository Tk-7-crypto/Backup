/**
 * This is the controller class for the Acount/Contact overriden page
 * version : 1.0
 */
public with Sharing Class NewURLRedirection {
    // Entry Check Permission Set Name 
    public String EC_PS_Name = 'Data_Trim_Entry_Check';
    
    // Custom Permission Set Name
    public String CPS_Name = 'Access_to_Entry_Check';
            
    private String RetURL;
    
     /**
     * This is the constructor for this apex class
     */
    public NewURLRedirection(ApexPages.StandardController Controller) {
        this.RetURL = System.currentPageReference().getParameters().get('retURL');
        return;
    }
    
    /**
     * This method is used to decide users are eligible for Entry Check access or Genral New Button for Account 
     * @return PageReference : Return to the Account new page
     */
    public pagereference initAccount() {
        if (this.RetURL == null || this.RetURL == '') {
            this.RetURL = '%2F001%2Fo';
        }
        
        //Initialize Entry Check URL
        PageReference pageRef_ECA = new PageReference('/apex/C__DataTrimEntryCheck_Custom?obj=001');
        pageref_ECA.setRedirect(true);
        
        //Initialize Normal New Account URL
        PageReference pageRef_NormalA = new PageReference('/001/e?nooverride=1&ent=Account&retURL='+this.RetURL+'&save_new_url=%2F001%2Fe%3FretURL%3D%252F001%252Fo');
        pageref_NormalA.setRedirect(true);
                                                                
        if(isCPSPermissionExist()) {
            return pageref_ECA;                            
        } else {
            return pageRef_NormalA;
        }             
    }
    
    /**
     * This method is used to decide users are eligible for Entry Check access or Genral New Button for Contact 
     * @return PageReference : Return to the Contact new page
     */           
    public pagereference initContact() {
        String AccountId = System.currentPageReference().getParameters().containskey(('accid')) ? System.currentPageReference().getParameters().get('accid') : '';
        PageReference pageRef_ECC ;
        
        //Initialize Entry Check URL
        if(AccountId.length() > 0) {
            pageRef_ECC = new PageReference('/apex/C__DataTrimEntryCheck_Custom?obj=003&retURL=' + this.RetURL + '&accid=' + AccountId);
        } else {
            pageRef_ECC = new PageReference('/apex/C__DataTrimEntryCheck_Custom?obj=003&retURL=' + this.RetURL);
        }
        pageref_ECC.setRedirect(true);
        
        //Initialize Normal New Contact URL
        if (this.RetURL == null || this.RetURL == '') {
            this.RetURL = '%2F003%2Fo';
        }
                
        PageReference pageRef_NormalC = new PageReference('/003/e?retURL=' + this.RetURL + '&nooverride=1&accid=' + AccountId);
        pageref_NormalC.setRedirect(true);
         
        if(isCPSPermissionExist()) {
            return pageref_ECC;                            
        } else {
            return pageRef_NormalC;
        }  
    }
            
        
    /**
     * To check custom permission of user from profile and permission sets
     * @return Boolean
    */     
    public Boolean isCPSPermissionExist() {
        List<SetupEntityAccess> listOfCustomPermission = [ SELECT setupentityid FROM   setupentityaccess WHERE  
                                    setupentityid IN ( SELECT id FROM custompermission WHERE  
                                    developername = :CPS_Name ) AND parentid IN ( SELECT permissionsetid FROM   
                                    permissionsetassignment WHERE  assigneeid = :userInfo.getUserId())  
                                    ];                                                                                            
        Boolean hasCPSPermission = false;                                            
        if(listOfCustomPermission.size() > 0) {
            hasCPSPermission = true;                            
        }           
        return hasCPSPermission;
    }
}