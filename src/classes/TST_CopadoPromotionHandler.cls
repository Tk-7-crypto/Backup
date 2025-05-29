/**
 * @author Vlad Tyazhov
 * Apex test for: DAO_CopadoPromotionHandler.
 * Use seeAllData to avoid "Copado license not available" error on Promotion insert.
 */
@IsTest
private class TST_CopadoPromotionHandler {
    @IsTest(SeeAllData=true)
    static void testPromotion() {
        // given
        User u = [SELECT Id FROM User WHERE Name = 'Continuous Integration Deployment Process'];

        // when
        System.runAs(u) {
            copadoccmint__Copado_Integration_Setting__c integrationSetting = new copadoccmint__Copado_Integration_Setting__c(
                    copadoccmint__External_System__c = 'JIRA',
                    copadoccmint__Named_Credential__c = 'test'
            );
            insert integrationSetting;

            copado__Deployment_Flow__c pipeline = new copado__Deployment_Flow__c(copado__Active__c = true);
            insert pipeline;

            copado__Project__c project = new copado__Project__c(
                    Name = 'project1',
                    copadoccmint__Copado_Integration_Setting__c = integrationSetting.Id,
                    copado__Deployment_Flow__c = pipeline.Id
            );
            insert project;

            copado__Promotion__c promotion = new copado__Promotion__c(copado__Project__c = project.Id);
            // if (UserInfo.isCurrentUserLicensed('copado'))  don't work for copado

            try {
                insert promotion;

            } catch (DmlException e) {
                if (e.getMessage().contains('Copado Deployer License nor Copado User License is enabled')) {
                    System.debug('Copado Admin license not found. TGR_CopadoPromotion will have 0% coverage.');
                } else {
                    throw new DmlException(e.getMessage());  // some real error with promotion trigger
                }
            }
        }
    }
}