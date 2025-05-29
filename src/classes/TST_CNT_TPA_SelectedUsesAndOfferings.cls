@isTest
public class TST_CNT_TPA_SelectedUsesAndOfferings {
    private static testmethod void testFetchUseOffRecords(){
        String profileName = CNT_TPA_SelectedUsesAndOfferings.currentUserProfileName;
        String url = CNT_TPA_SelectedUsesAndOfferings.tpaCommunityUrl;
        CNT_TPA_SelectedUsesAndOfferings.fetchUseOffRecords('');
    }
}