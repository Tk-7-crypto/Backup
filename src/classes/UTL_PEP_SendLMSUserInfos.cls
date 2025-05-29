/*
* Version       : 1.0
* Description   : Utility Class for sending extra user infos during sso login
*/
global class UTL_PEP_SendLMSUserInfos extends Auth.ConnectedAppPlugin
{
    // Authorize the app if the user has achieved quota tracked in a custom field
    global override Boolean authorize(Id userId, Id connectedAppId, Boolean isAdminApproved, Auth.InvocationContext context) 
    {
        return isAdminApproved;
    }
        
    global override Map<String,String> customAttributes(Id userId, Id connectedAppId, Map<String,String>
        formulaDefinedAttributes, Auth.InvocationContext context)         
    {  
        //get user details
        User u = [SELECT Name,ContactId, userRole.Name, userRole.PortalRole, AccountId FROM User WHERE Id = :userId];
        if(u!=null && u.AccountId!=NULL){
            Account acc = [SELECT Name, AccountCountry__c, 
                           (select Partner_Type__c from Contacts where Partner_Type__c !=null and Id =: u.ContactId),
                           (select ID,Name,Product2.Id,Product2.Name 
                            	FROM Assets 
                            	WHERE Status!='Obsolete' 
                            	AND Visible_in_CSH__c = true AND Name!='Partner Portal' AND Visible_in_LMS__c = true) 
                           FROM Account 
                           Where Id=:u.AccountId];
           
            String role = CON_PEP.S_PEP_CONSULTANT;
            if(u.userRole.PortalRole == CON_PEP.S_PEP_MANAGER){
                role = CON_PEP.S_PEP_MANAGER ;   
            }
            formulaDefinedAttributes.put('userRole',role);
            if(acc.Contacts[0] != null && acc.Contacts[0].Partner_Type__c != null){
                formulaDefinedAttributes.put('partnerType', acc.Contacts[0].Partner_Type__c.replace(';',','));
            }
            
            formulaDefinedAttributes.put('companyName', acc.Name);
            formulaDefinedAttributes.put('location', acc.AccountCountry__c);
            String names = '' ;
            Integer i = 0 ;
            for(Asset ast:acc.Assets){
              if(ast.Product2.Id != null){
                 if(i==acc.Assets.size()-1)
                    names+='{'+ast.Product2.Id+','+ast.Product2.Name+'}' ;
                 else
                    names+='{'+ast.Product2.Id+','+ast.Product2.Name+'},' ;      
              }
              i++ ;  
            }
            formulaDefinedAttributes.put('products', names);                        
    }
    	return formulaDefinedAttributes; 
    }
}