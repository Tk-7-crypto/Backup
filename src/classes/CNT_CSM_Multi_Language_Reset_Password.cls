public class CNT_CSM_Multi_Language_Reset_Password {
    public String recipientId;
    public string relatedToId{get;set;}
    public User recipientUser {get;set;}
    public Boolean isTpaProfile {get;set;}
    public string getRecipientId() { return recipientId; }
    public string welcomeToIQVIAHeading{get;set;}
    public string accessToTheTPAPortal{get;set;}

    public void setRecipientId(String inString) {
        recipientId = inString;
        Id emailRecipientId = (inString != null && inString != '') ? Id.valueOf(inString) : null;
        setRecipientData(emailRecipientId);
    }    
    private void setRecipientData(Id emailRecipientId) {
        Schema.sObjectType entityType = emailRecipientId != null ? emailRecipientId.getsobjecttype() : null;
        if(entityType != null && entityType == User.sObjectType) {
            Map<Id, User> recipientMap = new SLT_User().selectByUserId(new Set<Id>{emailRecipientId}, 
                                                                        new Set<String>{'Id', 'FirstName', 'LastName', 'UserName', 'ProfileId','Profile.Name'});  
            if(recipientMap != null && recipientMap.containsKey(emailRecipientId) && recipientMap.get(emailRecipientId) != null) {
                recipientUser = recipientMap.get(emailRecipientId); 
            }   
        }
        else if(entityType != null && entityType == Contact.sObjectType){
            List<User> recipientList = new SLT_User().selectByContactId(new Set<Id>{emailRecipientId}, 
                                                                        new Set<String>{'Id', 'FirstName', 'LastName', 'UserName', 'ProfileId','Profile.Name'});
            if(recipientList != null && recipientList.size() > 0) {
                recipientUser = recipientList[0];            
            }             
        }

        //Covered under ticket ESPSFDCTPA-3952 Start  
        if(recipientUser != null && recipientUser.Profile != null && recipientUser.Profile.Name != null && UTL_TPA.tpaClientPortalProfiles.contains(recipientUser.Profile.Name)){
            isTpaProfile = true ;
            welcomeToIQVIAHeading = System.Label.Welcome_to_IQVIA_third_Party_Access_Program;
            accessToTheTPAPortal = System.Label.Your_access_to_the_TPA_Portal_has_been_granted_via_the_IQVIA_Customer_Service;
            
        }
        else {
            welcomeToIQVIAHeading = System.Label.Welcome_to_the_IQVIA_Customer_Service_Hub;
            accessToTheTPAPortal = '';
            isTpaProfile = false;  
        }
        //Covered under ticket ESPSFDCTPA-3952 End 
        
    }
}
