/*
* Version       : 1.0
* Description   : Apex Controller for PortalTopic component.
*/
public with sharing class CNT_CSM_Qualtric_Survey {
    
    /*
    * Return Url for qualtrics survey
    */
    @AuraEnabled
    public static String getQulatricSurveyURL(String url, String fieldName){
        List<String> listFieldName = fieldName.split(';');
        List<User> users = new SLT_User().selectContactDetailByUser(new Set<Id> {userInfo.getUserId()}, 
            new Set<String> (listFieldName));
        String surveyUrl = '';
        Map<String, String> mapOfFieldAndValue = new Map<String, String>();
        
        if(users != null && !users.isEmpty()){
            for(String name: listFieldName) {
                if(name.contains('.')) {
                    List<String> listOfField = name.split('\\.');
                    surveyUrl += listOfField[0]+listOfField[1]+'='+(String) users[0].getSobject(listOfField[0]).get(listOfField[1])+'&';
                } else {
                    surveyUrl += name+'='+(String) users[0].get(name)+'&';
                }
                
            }
            if(surveyUrl.endsWith('&')){
                surveyUrl = surveyUrl.substring(0, surveyUrl.length()-1);
            }
        }
        
        return url+surveyUrl;
    }
}