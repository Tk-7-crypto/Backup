public class CNT_CSM_AttachArticle {

    @AuraEnabled
    public static List<SObject> searchArticles(String searchText, String caseId, Integer rowLimit, Integer rowOffset) {
        List<Case> cases = new List<Case>();
        List<List<SObject> > results = new List<List<SObject> >();
        List<SObject> k = new List<SObject>();
        String pillar;
        String product = '';
        String prdCond = '';
        cases = new SLT_Case().selectByCaseIdList(new Set<Id> { caseId }, new Set<String> {'Subject', 'RecordTypeName__c', 'ProductName__c', 'LOS__c', 'AccountId','Account.KBA_Visibility_Restriction__c', 'Contact.KB_Location__c'});
        if(cases.size() > 0) {
            Set<Id> kIds = new Set<Id>();
            for(CaseArticle ca: [SELECT KnowledgeArticleVersionId FROM CaseArticle WHERE CaseId = :caseId]) {
                kIds.add(ca.KnowledgeArticleVersionId);
            }
            if(searchText == '') {
                searchText = cases[0].Subject;
            }
            String KB_Location = cases[0].Contact.KB_Location__c;
            String location_condition = '';
            if (KB_Location != null) {
                KB_Location = '\'' + KB_Location.replace(';','\',\'') +'\'';
                location_condition = ' OR Location__r.Location__c  in ('+ KB_Location +')';
            }
            if(cases[0].RecordTypeName__c == CON_CSM.S_TECHNOLOGY_R_T) {
                pillar = CON_CSM.S_TECHNOLOGY_SOLUTIONS;
                if (cases[0].ProductName__c != null) {
                    product = cases[0].ProductName__c;
                }
            } else if(cases[0].RecordTypeName__c == CON_CSM.S_DATACASE) {
                pillar = CON_CSM.S_INFORMATION_OFFERING;
                if (cases[0].ProductName__c != null) {
                    product = cases[0].ProductName__c;
                }
            } else if(cases[0].RecordTypeName__c == CON_CSM.S_RDCASE || cases[0].RecordTypeName__c == CON_CSM.S_R_D_V_T || cases[0].RecordTypeName__c == CON_CSM.S_ACTIVITY_R_T ) {
                pillar = CON_CSM.S_R_D;
                if (cases[0].LOS__c != null) {
                    product = cases[0].LOS__c;
                }
            }
            if (product != '') {
                prdCond = ' AND ProductName__c = \'' + product +'\'';
            }
            if(cases[0].AccountId != null && cases[0].Account.KBA_Visibility_Restriction__c) {
                Set<Id> knowledgeIds = new Set<Id>();
                for(Knowledge_Account_RelationShip__c kbAccount: Database.query('SELECT Id, Knowledge__c FROM Knowledge_Account_RelationShip__c WHERE Account__c =\'' + cases[0].AccountId + '\' AND (Location__c = \'\' ' + location_condition + ' )')) {
                    knowledgeIds.add(kbAccount.Knowledge__c);
                }
                if(!knowledgeIds.isEmpty()) {
                    String q = 'FIND :searchText IN ALL FIELDS RETURNING Knowledge__kav(Id, RecordTypeId, ArticleNumber, Content__c, L1Content__c, L2L3Content__c, Question__c, Answer__c, L1Answer__c, L2L3Answer__c, Title, knowledgeArticleId, ProductName__c, SubType1__c, SubType2__c, SubType3__c, IsVisibleInCsp, LastPublishedDate WHERE PublishStatus =\'Online\' AND Language = \'en_US\' AND Pillar__c = :pillar AND Id IN :knowledgeIds AND Id NOT IN :kids' + prdCond +' LIMIT '+ rowLimit +' OFFSET ' + rowOffset +' )';
                    results =  search.query(q);
                }
            }
            else {
                if(cases[0].AccountId != null) {
                    String q1 = 'FIND :searchText IN ALL FIELDS RETURNING Knowledge__kav(Id, RecordTypeId, ArticleNumber, Content__c, L1Content__c, L2L3Content__c, Question__c, Answer__c, L1Answer__c, L2L3Answer__c, Title, knowledgeArticleId, ProductName__c, SubType1__c, SubType2__c, SubType3__c, IsVisibleInCsp, LastPublishedDate WHERE PublishStatus =\'Online\' AND Language = \'en_US\' AND Pillar__c = :pillar and Id not in :kids' + prdCond + ' AND Id in (select Knowledge__c from Knowledge_Account_RelationShip__c where Account__c =\''+ cases[0].AccountId +'\' AND (Location__c = \'\' ' + location_condition + ' )) LIMIT '+ rowLimit +' OFFSET ' + rowOffset +' )';
                    List<List<SObject> > results1 =  search.query(q1);
                    results.addAll(results1);
                }
                String q2 = 'FIND :searchText IN ALL FIELDS RETURNING Knowledge__kav(Id, RecordTypeId, ArticleNumber, Content__c, L1Content__c, L2L3Content__c, Question__c, Answer__c, L1Answer__c, L2L3Answer__c, Title, knowledgeArticleId, ProductName__c, SubType1__c, SubType2__c, SubType3__c, IsVisibleInCsp, LastPublishedDate WHERE PublishStatus =\'Online\' AND Language = \'en_US\' AND Pillar__c = :pillar and Id not in :kids' + prdCond + ' AND Id NOT in (select Knowledge__c from Knowledge_Account_RelationShip__c) LIMIT '+ rowLimit +' OFFSET ' + rowOffset +' )';
                List<List<SObject> > results2 =  search.query(q2);
                results.addAll(results2);
            }
        }

        for (List<SObject> sobjs : results){
            k.addAll(sobjs);
        }
        return k;
    }

    @AuraEnabled(cacheable=true)
    public static List<Knowledge__kav> getCaseArticle( String caseId) {
        Set<Id> kIds = new Set<Id>();
        List<Knowledge__kav> results = new List<Knowledge__kav>();
        for(CaseArticle ca: [SELECT KnowledgeArticleVersionId FROM CaseArticle WHERE CaseId = :caseId]) {
            kIds.add(ca.KnowledgeArticleVersionId);
        }
        if(kIds != null && !kIds.isEmpty()) {
            results = new SLT_Knowledge().selectById(kIds);
        }
        return results;
    }

    @AuraEnabled
    public static void insertCaseArticle( String caseId, String knowledgeArticleId) {
        CaseArticle ca  = new CaseArticle (caseId = caseId, KnowledgeArticleId = knowledgeArticleId );
        insert ca;
    }

    @AuraEnabled
    public static void deleteCaseArticle(String caseId, String knowledgeArticleId) {
        try {
            CaseArticle ca = [SELECT Id, KnowledgeArticleVersionId FROM CaseArticle WHERE CaseId = :caseId AND KnowledgeArticleId = :knowledgeArticleId LIMIT 1];
            KnowledgeArticleVersion article = [SELECT Title FROM KnowledgeArticleVersion WHERE Id = :ca.KnowledgeArticleVersionId LIMIT 1];
            String orgDomain = URL.getOrgDomainUrl().toExternalForm();
            String articleUrl = orgDomain + '/lightning/r/Knowledge__kav/' + ca.KnowledgeArticleVersionId + '/view';
            delete ca;
            FeedItem feedItem = new FeedItem();
            feedItem.ParentId = caseId;
            feedItem.Body = 'Article <s><a href="' + articleUrl + '">' + article.Title.escapeHtml4() + '</a></s> has been detached.';
            feedItem.Type = 'ContentPost';
            feedItem.IsRichText = true;
            insert feedItem;
        } catch (Exception e) {
            throw new AuraHandledException('Error deleting CaseArticle: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static List<IQVIACopilot_ChatGPT__c> draftEmailAction(String caseId, String knowledgeArticleId) {
        return CNT_CSM_SNOWChatGPT.askCaseAssistance(caseId, 'Draft Article Email', 'English','en_US',knowledgeArticleId);
    }
    
    @AuraEnabled(cacheable=true)
    public static boolean getDataCustomSetting() {
        CSM_Case_Details_Global_Setting__c emailKb = CSM_Case_Details_Global_Setting__c.getValues('IQVIAKBCopilotDraftEmail');
        Boolean isGenAI = FeatureManagement.checkPermission('CSM_IQVIA_Assistant_Access');
        boolean isCheck = false;
        if((Test.isRunningTest() || isGenAI) && emailKb != null && emailKb.Origin__c != null){
            String userId = UserInfo.getUserId();
            String pg = emailKb.Origin__c;
             List<GroupMember> groupList = Database.query('select Id, GroupId, UserOrGroupId, SystemModstamp from GroupMember where GroupId = :pg and UserOrGroupId =:userId');
            if(groupList != null && groupList.size() > 0){
                isCheck = true;
            }
        }else if(isGenAI){
           isCheck = true;
        }
        return isCheck;
    }
    
}