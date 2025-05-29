/**
  *    @author :- Dhruv Gour
  *    Date:- 1st May, 2015 
  *    Details:-ER -1664(This is controller class of SCM_MasterAgreementEdit page )  
  */

public class SCM_MasterAgreementEditController {
	
	private Agreement__c agreement ;
//Added By Rakesh : 13 May 2015 : Issue-5340 : START
    private Id oppId;
    public boolean hasAggNameEditPermission {get; set;}
    //END : Issue-5340
	
	public SCM_MasterAgreementEditController(ApexPages.StandardController controller)
    {
        agreement = (Agreement__c)controller.getRecord(); 
        Agreement__c ag = [select id, Name, recordTypeId, recordType.Name, Related_Opportunity__c from Agreement__c where id = :agreement.ID];
        oppId = ag.Related_Opportunity__c;
        Contract_Management_Setting__c contractSetting = Contract_Management_Setting__c.getInstance();
        contractSetting = Contract_Management_Setting__c.getInstance();
        string cancelURL = ApexPages.currentPage().getParameters().get('cancelURL');
        SCM_GetUserProfileController userProfileCon = new SCM_GetUserProfileController();
        this.hasAggNameEditPermission  = (userProfileCon.hasAggNameEditPermission || (!string.isBlank(cancelURL) && cancelURL.contains('cancelactioninterceptor'))); 
    }
    
    public void saveAgreement() {
        try {
            if(agreement!=null) {
                update agreement;
            }
        } Catch(Exception e) {
             ApexPages.addMessages(e);
        }
    }  
    
    //Added By Rakesh : 13 May 2015 : Issue-5340 : START
    public pageReference  cancelAgreement()
    {
        pageReference pg;
        string cancelURL = ApexPages.currentPage().getParameters().get('cancelURL');
        try
        {
            //If parent ID is not null then save parent agreement to  record to be saved 
            if(!string.isBlank(cancelURL) && cancelURL.contains('cancelactioninterceptor'))
            {
                delete agreement;
                
                if(oppId !=null)
                {
                    pg = new pageReference('/'+oppId );
                } else
                {
                    pg = new pageReference('/'+ Schema.getGlobalDescribe().get('Agreement__c').getDescribe().getKeyPrefix()+'/o');
                }
            } 
            else
            {
                pg = new pageReference('/'+agreement.Id);
            }           
                                                //Update record
        }
        Catch(Exception e)
        {
             ApexPages.addMessages(e);
             return null ;                      //Redirect to agreement view page  
        }
        
        return pg; 
    }
    //END : Issue-5340   
}