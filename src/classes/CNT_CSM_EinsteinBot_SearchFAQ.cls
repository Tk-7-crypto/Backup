public class CNT_CSM_EinsteinBot_SearchFAQ {

    
    public class SearchInput{
        @InvocableVariable(required = true)
        public String searchKeyword;
        
        @InvocableVariable(required=true)
        public Id routableId;
        
        //@InvocableVariable(required = true)
        //public Product2 productName;
    }
    
    public class SearchOutput{
        @InvocableVariable(required = true)
        public String searchOutput;
    }

    @InvocableMethod(label='SearchFAQ')
    public static List<SearchOutput> searchFAQ(List<SearchInput> searchInputList){
        String keyword = searchInputList[0].searchKeyword;
        Id chatSessionId = searchInputList[0].routableId;
        String faqResult = 'RICH_TEXT:';
        // Fetch the existing products linked to the account of current user
        LiveChatTranscript chatContactRecord = [SELECT ContactId FROM LiveChatTranscript WHERE Id = :chatSessionId LIMIT 1];
        
        if(chatContactRecord != null && chatContactRecord.ContactId != null){
            Id contactId = chatContactRecord.ContactId;
            Id accountId = null;
            boolean isCSHKBAccess = false;
            string commaSeparatedKnowledge ='\'';
            List<Product2> products = CNT_CSM_EinsteinBot_ProductsAccess.getContactProducts(contactId);
            List<Contact> con = Database.query('Select Id,AccountId,Remove_KB_Access__c from Contact where Id =:contactId');
            if(con != null){
                for(Contact c: con){
                    accountId = c.AccountId;
                    isCSHKBAccess = c.Remove_KB_Access__c;
                }
                
                List<Knowledge_Account_RelationShip__c > karList = Database.query('select Id, Name, Account__c, Knowledge__c,Knowledge__r.ArticleNumber,  Location__c from Knowledge_Account_RelationShip__c where Account__c =:accountId and Knowledge__c != null');
                for(Knowledge_Account_RelationShip__c kar : karList){
                    commaSeparatedKnowledge =commaSeparatedKnowledge + kar.Knowledge__r.ArticleNumber + '\',\'';
                }
                commaSeparatedKnowledge = commaSeparatedKnowledge.left(commaSeparatedKnowledge.length()-2);
            }
            if(isCSHKBAccess){
                faqResult +='You donot have the access to view knowledge articles.Please contact system administrator to enable the knowledge article access.';
            }else if(products != null && !products.isEmpty() && !isCSHKBAccess){
                string commaSeparatedproduct ='\'';
                for(Product2 p : products){
                    commaSeparatedproduct =commaSeparatedproduct + p.Name + '\',\'';
                }
                commaSeparatedproduct = commaSeparatedproduct.left(commaSeparatedproduct.length()-2);
                String query = 'FIND \'' +String.escapeSingleQuotes(keyword)+'\' IN ALL Fields Returning Knowledge__kav(Id, Title, UrlName, Content__c, L1Content__c, L2L3Content__c, Question__c, Answer__c, L1Answer__c, L2L3Answer__c WHERE Language=\'en_US\' AND PublishStatus = \'Online\' AND IsLatestVersion = true AND IsVisibleInCsp = true AND ';
                if(commaSeparatedKnowledge.length() > 5){
                    query+='(ArticleNumber in ('+commaSeparatedKnowledge+') OR ProductName__c in ('+commaSeparatedproduct+')) ) WITH SNIPPET (target_length=1500) LIMIT 5';
                }else{
                    query+= 'ProductName__c in ('+commaSeparatedproduct+') ) WITH SNIPPET (target_length=1500) LIMIT 5';   
                }
                Search.SearchResults searchResults = Search.find(query);
                List<Search.SearchResult> articleList = new List<Search.SearchResult>();
                articleList = searchResults.get('Knowledge__kav');
                String articleBaseUrl = getCommunityBaseUrl();
                for(Search.SearchResult searchResult : articleList){
                    Knowledge__kav article = (Knowledge__kav) searchResult.getSObject();
                    String snippet = searchResult.getSnippet();
                    if(snippet != null){
                        String articleSummary = summarizeArticleForChatbot(articleBaseUrl, article,snippet,String.escapeSingleQuotes(keyword));
                        faqResult = faqResult + articleSummary;    
                    }
                }
            }
        }
        if(faqResult == 'RICH_TEXT:'){
            faqResult = 'No result found';
        }
        
        List<SearchOutput> faqOutputs = new List<SearchOutput>();
        SearchOutput output = new SearchOutput();
        output.searchOutput = faqResult;
        faqOutputs.add(output);
        return faqOutputs;
    }
    
    public static String getCommunityBaseUrl(){
        List<Network> communityNetworks = [SELECT Id FROM Network WHERE Name ='IQVIA Customer Service Hub'];
        String baseUrl = '';
        if(communityNetworks.size() > 0){
            Network communityNetwork = communityNetworks[0];
            String loginUrl = Network.getLoginUrl(communityNetwork.Id);
            baseUrl = loginUrl.replace('/login', '/s/article/');
        }
        return baseUrl;
    }
    
    public static String summarizeArticleForChatbot(String articleBaseUrl, Knowledge__kav article, String snippet,String searchWord){
        String summary, url;
        url = articleBaseUrl + article.UrlName+'?searchword='+searchWord;
        
        if(snippet != null){
            summary = 'Article : <a href="'+url+'" target="_blank">'+article.Title+'</a>\n \n\n'+snippet+' \n\n-----------------------------------\n\n';
        }/*else{
            summary = 'Article : <a href="'+url+'" target="_blank">'+article.Title+'</a>\n\n-----------------------------------\n\n';
        }*/
        
        return summary;
    }
}
