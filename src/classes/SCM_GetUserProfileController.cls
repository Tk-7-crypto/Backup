/**************************************************************************************************************
Created By Rakesh : 12 June 2014 : Regarding Issue-04641 
Used as controller of VF Page 'SCM_GetUserProfile'
**************************************************************************************************************/
public class SCM_GetUserProfileController 
{
    //******************************************** Class Variables : START ******************************************************************
    public boolean hasAggNameEditPermission {get; set;}
    //******************************************** Class Variables : END   ******************************************************************
    
    //******************************************** Constructor : START ******************************************************************
    public SCM_GetUserProfileController()
    {
        List<User> currentUserInfo = new List<User>( [select id,Name, Profile.Name,User_Country__c from User where Id =: UserInfo.getUserId()]);
        
        List<PermissionSetAssignment> PermissionSetList =  new List<PermissionSetAssignment>(
                                                                                                [SELECT AssigneeId, 
                                                                                                        PermissionSet.Label 
                                                                                                 FROM PermissionSetAssignment 
                                                                                                 WHERE AssigneeId = :UserInfo.getUserId()]
                                                                                            );
        hasAggNameEditPermission  = true ;
        
        for(PermissionSetAssignment permSetAss : PermissionSetList)
        {
            //Check if current User has 'SCM Edit(Sales User Permission)' OR 'SCM Read-Only(Client Service User Permission)' permission set assignment 
            if(
                permSetAss.PermissionSet.Label.toLowerCase().contains('scm') && 
                (
                    ( permSetAss.PermissionSet.Label.toLowerCase().contains('read') && permSetAss.PermissionSet.Label.toLowerCase().contains('only')) || 
                    ( permSetAss.PermissionSet.Label.toLowerCase().contains('edit'))
                )
            )
            {                   
                 hasAggNameEditPermission = false;
                 break;
            }   
        }
        
        if(currentUserInfo[0].Profile.Name.toLowerCase().contains('system administrator'))
        {
            hasAggNameEditPermission  = true ;
        }
    
    }
    //******************************************** Constructor : END   ******************************************************************
}