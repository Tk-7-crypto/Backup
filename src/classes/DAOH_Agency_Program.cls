public class DAOH_Agency_Program {
    
    public static void activateAgencyProgram(List<Agency_Program__c> newList,Map<Id, Agency_Program__c> oldMap) {
        Set<String> fieldSet = new Set<String>{'Id'};
        String tempName1 = '';
        String tempName2 = '';
        String tempName3 = '';
        String tempName4 = '';
        Boolean flag = false;        
        
        for(Agency_Program__c ap : newList)
        {
            if(ap.Status__c == 'Active')
            {
                tempName1 = ap.Name + '_First';
                tempName2 = ap.Name + '_Second';
                tempName3 = ap.Name + '_Third';
                tempName4 = ap.Name + '_Expired';
                flag = true;
            }
        }
        
        if(flag){
            
            List<EmailTemplate> et1 = new SLT_EmailTemplate().selectEmailDTemplateByName(tempName1, fieldSet);
            List<EmailTemplate> et2 = new SLT_EmailTemplate().selectEmailDTemplateByName(tempName2, fieldSet);
            List<EmailTemplate> et3 = new SLT_EmailTemplate().selectEmailDTemplateByName(tempName3, fieldSet);
            List<EmailTemplate> et4 = new SLT_EmailTemplate().selectEmailDTemplateByName(tempName4, fieldSet);
            
            if(!(et1.size() > 0 && et2.size() > 0 && et3.size() > 0 && et4.size() > 0 && tempName1!='')){
                newList[0].Status__c.addError('Please create all Notification Templates to activate Agency Program');
            }
        }
    }
}