/****************************************************************************************
Name            : ChatterPrivacyNoticeControllerPOC
Author          : Himanshu Parashar
Created Date    : December 22, 2011
Revision History: 
                
Usage           : Used to mark whether or not a user has accepted the privacy notice,
                  and helps determine if a notice popup should be displayed.
****************************************************************************************/
    
public with sharing class CNT_TPA_PrivacyNotice { 
    
    Public boolean isMessageShow{get;set;}
    Public boolean isTPAPermanentDown{get;set;}
	
    public string msgPrimaryBoardContent {get; set;}
    public static String language {get; set;}
    public static Map<String, String> supportedLanguageMap{
        get{
            if(supportedLanguageMap == null)
            {
                supportedLanguageMap = new Map<String, String>();
                for(string langCodeMapObj :UTL_TPA_Multilingual.mlGlobalSettings.Supported_Language_Code_with_Field_Map__c.split(';'))
                {
                    supportedLanguageMap.put(langCodeMapObj.split('=')[0], langCodeMapObj.split('=')[1]);
                }        
            }
            return supportedLanguageMap;
        }
        private set;
    }
    
  /** The associated User */
  private User CurrentUser;
  String communityUrl = UTL_TPA.TPA_COMMUNIYTURL;

  /** Flag for whether or not to display the popup. */
  public boolean displayPopup {get; private set;}
  
  /** Creates a privacy notice controller based on the current user. */
  public CNT_TPA_PrivacyNotice() {
    language = UTL_TPA_Multilingual.getLanguage();
    List<TPA_Text_Editor__c> editorDataList = [select id, Page_Name__c, Content__c, English_Translation__c, Japanese_Translation__c from TPA_Text_Editor__c where id =: TPA_Settings__c.getOrgDefaults().clientPrivacyMessageBoardId__c];
    for(TPA_Text_Editor__c mb : editorDataList){
        if(mb.Page_Name__c == 'Client Privacy Policy Message Board')
            msgPrimaryBoardContent = mb.get(supportedLanguageMap.get(language).split('~')[1]) != null ? String.valueOf(mb.get(supportedLanguageMap.get(language).split('~')[1])) : String.valueOf(mb.Content__c);
    }
    List<User> user = [SELECT TPA_Is_Privacy_Policy_Agreed__c,TPA_Is_Show_TPA_Down_Message__c FROM User WHERE id =:UserInfo.getUserId() ];
    if(user!=null && user.size()>0)
        CurrentUser = user.get(0);
    
  }
  
  /** Example greeting based on the user's name. */
  public String getTitle() {
    return 'TPA Data Privacy Policy';
  }
  
  /** Get the flag for the consent to store bio. */
  public boolean getAcknowledgement() {
    if(CurrentUser == null)
        return true;
    return CurrentUser.TPA_Is_Privacy_Policy_Agreed__c;
  }

  /** Update the consent flags to indicated accepted. */
  public PageReference accept() {
    // Mark the acknowledgement field, and hide the popup
    CurrentUser.TPA_Is_Privacy_Policy_Agreed__c =true;
    CurrentUser.TPA_Portal_Joining_Date__c = DateTime.now();
    displayPopup = false;
    update CurrentUser;
    
    string tpaLangOverride = ApexPages.currentPage().getParameters().get('isLangOverride');
    PageReference pageRef;
    if(tpaLangOverride != null && tpaLangOverride != '')
        pageRef = new PageReference(communityUrl+'/VFP_TPA_CustomLandingPage?isLangOverride=' + tpaLangOverride);
    else
        pageRef = new PageReference(communityUrl+'/VFP_TPA_CustomLandingPage');
    pageRef.setRedirect(true);
    return pageRef;
    
  } 

  /** Initialize to display popup based on consent flag. */
  public PageReference init() {
      CurrentUser.TPA_Is_Show_TPA_Down_Message__c = false; 
      update CurrentUser;
      TPA_Settings__c pageMessageList = TPA_Settings__c.getOrgDefaults();
      isMessageShow = pageMessageList.Is_Show_Message__c;
      isTPAPermanentDown =  pageMessageList.Is_TPA_Permanent_Down__c;
      if( CurrentUser.TPA_Is_Privacy_Policy_Agreed__c || isTPAPermanentDown){
        displayPopup = false;
        PageReference pageRef = new PageReference(communityUrl+'/VFP_TPA_CustomLandingPage');
        pageRef.setRedirect(true);
        return pageRef;
    }
    else{
        displayPopup = true;
        
    }
    return null;
  }
  
  /** Helper method to force popup. */
  public void showPopup() { 
    displayPopup = true;
  }
}