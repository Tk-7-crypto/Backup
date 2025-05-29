/**
  *    @author :- Dhruv Gour
  *    Date:- 7-5-2015
  *    Details:-ER -1664 phase 2 (This is controller class of SCM_EditAggOverride page and used to override pages)  
  *    Test Class - SCM_AgreementEditControllerTest  
  */
public class SCM_EditAggOverrideExt 
{
    private Agreement__c agreement ;                   //Agreement record from the current page after editing
    private PageReference pageRef;                                  //Temparary stores page reference of next URL to be redirected
    private User objUser;                                           //Store current user information by page
    public String userPermission = '';                              //Stores user's permission set
    public static final String FINCOM_ERROR_MESSAGE = 'You do not have sufficient privileges to edit a fincom agreement record.';
    public static final String ERROR_MESSAGE = 'You cannot edit agreement record.';
    public static final String AUTHOR_AMENDED_ERROR_MESSAGE = 'You cannot edit amended agreement record.';
    private Contract_Management_Setting__c contractSetting;         //Stores current instance of custom settings of contract management
    private String userProfileName{get;set;}                        //Stores user's Profile Name
    public Boolean isShowWarning{get;set;}                          //Bolean value that whether warning to be shown or not
    private String retURL;                                          //some part next URL to be redirected
    private String saveNewURL ;                                     //some part next URL to be redirected
    private String cancelURL;                                       //some part next URL to be redirected
    
    //Added By Rakesh : 13 May 2015 : Issue-5340 : START
    private String japanAgreementRecordTypeID ;                     //Stores ID of recordtype 'Japan Aagreement' 
    private String japanMasterAgreementRecordTypeID ;               //Stores ID of recordtype 'Japan Master Agreement' 
    //END : Issue-5340
    
    public SCM_EditAggOverrideExt(ApexPages.StandardController controller)
    {  
        //Agreement record from vf screen and from database fetched and parent agg from database is shown on VF page bydefault .    
        agreement = (Agreement__c)controller.getRecord();         
        this.objUser = ConstantClass.getUserDetails().get(0);
        
        if(objUser != Null) {     
            userPermission = ConstantClass.permissionSetUser(userProfileName , objUser.PermissionSetAssignments);
            userProfileName = objUser.Profile.Name;            
        }
        
        this.isShowWarning = false;
        this.retURL = ApexPages.currentPage().getParameters().get('retURL');  
        this.saveNewURL = 'setup/ui/recordtypeselect.jsp?ent=01I70000000Bhvb&retURL=/a3S/o&save_new_url=/a3S/e?retURL=/a3S/o';
        this.cancelURL = ApexPages.currentPage().getParameters().get('cancelURL'); 
        contractSetting = Contract_Management_Setting__c.getInstance();
        if(contractSetting  != null) {
            japanAgreementRecordTypeID = contractSetting.Japan_Agreement__c ;                     
            japanMasterAgreementRecordTypeID = contractSetting.Japan_Master_Agreement__c  ;                
        }                
    }
    
    //for SCM_Controller_Agreement_EditOverride
    public PageReference redirectToWarningOrStandardPage() {  
        this.setPageRefToWarningOrStandardPage();                           
        return this.pageRef;              
    }
    
    private void setPageRefToWarningOrStandardPage() {  
        Boolean isValidReadOnlyUser= userPermission == 'client';
        Boolean isNotValidUSOnlyUser = !(objUser.PermissionSetAssignments != Null && constantClass.isValidUSUser(objUser.PermissionSetAssignments) && (userPermission == 'author' || userPermission =='sales')) ;
        if(isValidReadOnlyUser) {
            this.isShowWarning = true;     
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,SCM_EditAggOverrideExt.ERROR_MESSAGE));              
        }
        else if(userProfileName != null && !userProfileName.toLowerCase().contains('system admin') && this.agreement!=null && this.agreement.has_agreement_amended__c==true) {
            this.isShowWarning = true;                                                 
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,SCM_EditAggOverrideExt.AUTHOR_AMENDED_ERROR_MESSAGE));                                                      
        }
        else {
            this.setParametersForRedirectToPage();                 
        }
    }
    
    //Redirect To Standard Edit Page
    private void setParametersForRedirectToPage() {                  
        if(this.agreement.RecordTypeId == japanAgreementRecordTypeID)
            this.pageRef = new PageReference('/apex/SCM_JapanAgreementEdit');
        else if(this.agreement.RecordTypeId == japanMasterAgreementRecordTypeID)
            this.pageRef = new PageReference('/apex/SCM_JapanMasterAgreementEdit');
        else {
            this.pageRef = new PageReference('/' + agreement.id+'/e');
            this.pageRef.getParameters().put('nooverride', '1');   
        }              
        this.pageRef.getParameters().put('id', agreement.id);
        this.pageRef.getParameters().put('recTypeId', agreement.RecordTypeId);
        this.pageRef.getParameters().put('retURL','/'+ agreement.id);                      
        this.pageRef.getParameters().put('save_new_url',saveNewURL);
        this.pageRef.getParameters().put('recTypeName', agreement.RecordType.Name);
        this.pageRef.getParameters().put('cancelURL',cancelURL); 
        this.pageRef.setRedirect(true);                              
    }       
}