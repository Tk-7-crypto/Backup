/**
 * This test class is used to test UTL_PEP_SendLMSUserInfos class.
 * version : 1.0
 */
@isTest
private class TST_UTL_PEP_SendLMSUserInfos {
   
     @testSetup
     public static void setup(){        
        User partnerUser = TST_PEP_TestDataFactory.createPartnerUser('partner@iqvia.partner.com');
        User adminUser = TST_PEP_TestDataFactory.createAdminUser('admin','adminPartner@iqvia.com');

        List<User> lstUsers = new List<User>{partnerUser, adminUser};
        insert lstUsers;		
     }
    
     @isTest
     public static void testCustomAttributes(){         
         User adminUser = [SELECT id FROM User WHERE email='adminPartner@iqvia.com'];
         
         System.runAs(adminUser){
         	 UTL_PEP_SendLMSUserInfos utlsendinfos = new UTL_PEP_SendLMSUserInfos();
         
             Test.startTest();
             //query the user we've just created
             User u = [SELECT Name, userRole.Name, userRole.PortalRole, AccountId FROM User WHERE email='partner@iqvia.partner.com'];
             List<Asset> assts = [SELECT ID,Name,Product2.Id,Product2.Name FROM Asset ] ;   
             //the connnected app id is null because it is not used inside that function
             //the context is null for the same reason
             //create an empty formula defined attributes
             Map<String,String> formulaDefinedAttributes = new Map<String,String>();
             Map<String,String> result = utlsendinfos.customAttributes(u.Id,null,formulaDefinedAttributes, null) ;
    
             Test.stopTest();
             System.assertEquals(CON_PEP.S_PEP_CONSULTANT,result.get('userRole'));
             System.assertEquals('Integrator Partner,Data Partner',result.get('partnerType')) ;
             System.assertEquals('Acme',result.get('companyName')) ;
             System.assertEquals('BM',result.get('location')) ;
             System.assertEquals('{'+assts[0].Product2.Id+','+assts[0].Product2.Name+'},{'+assts[1].Product2.Id+','+assts[1].Product2.Name+'}',
                                result.get('products')) ;              
         }
        
    }
    
	@isTest
    public static void testIsAdminApproved(){
        User adminUser = [SELECT id FROM User WHERE email='adminPartner@iqvia.com'];         
        System.runAs(adminUser){ 
            UTL_PEP_SendLMSUserInfos utlsendinfos = new UTL_PEP_SendLMSUserInfos();
            Test.startTest();
            	Boolean result = utlsendinfos.authorize(null,null,true,null);
            Test.stopTest();
            System.assertEquals(true,result);
         }
    }

}