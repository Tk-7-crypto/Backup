public class WSC_CSM_TranslateCallout {
    public static Map<String, Knowledge__kav> getTranslatedData(List<UTL_CSM_ArticleTranslation.ArticleWrapper> articleWrapperList) {
        List<String> articleFieldSet = new List<String>{'Summary', 'Title', 'Question__c', 'Answer__c', 'Content__c', 'L1Answer__c', 'L1Content__c'};
        Map<String, Knowledge__kav> translationByLanguage = new Map<String, Knowledge__kav>(); 
        for(UTL_CSM_ArticleTranslation.ArticleWrapper articleWrapper: articleWrapperList) {
            String articleDataToTranslate = '';
            List<String> fieldSetTranslated = new List<String>();
            Knowledge__kav article = articleWrapper.masterArticle;
            String sourceLanguage = CON_CSM.CALLOUT_LANGUAGE_MAP.containsKey(article.ArticleMasterLanguage) ? CON_CSM.CALLOUT_LANGUAGE_MAP.get(article.ArticleMasterLanguage) : article.ArticleMasterLanguage;
            for(String field: articleFieldSet) {
                String fieldData = (String)article.get(field);
                if(fieldData != null && fieldData != '') {
                    articleDataToTranslate += '&q=' + EncodingUtil.urlEncode(fieldData, 'UTF-8');
                    fieldSetTranslated.add(field);
                } 
            }
            Map<String, HTTPResponse> languageResponseMap = translateCallout(articleDataToTranslate, articleWrapper.languagesForTranslation, sourceLanguage);
            if (languageResponseMap != null && languageResponseMap.size() > 0 ) {
                for(String languageCode: languageResponseMap.keySet()) {
                    try {
                        HttpResponse response = languageResponseMap.get(languageCode);
                        String jsonResults = response.getBody();
                        JSONParser parser = JSON.createParser(jsonResults);
                        if(response != null && response.getStatusCode() == 200) {
                            Integer index = 0;
                            Knowledge__kav articleTranslation = new Knowledge__kav();
                            while(parser.nextToken() != null && index < fieldSetTranslated.size()) {
                                if((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == CON_CSM.S_TRANSLATED_TEXT)) {
                                    parser.nextToken();
                                    String data = parser.getText();
                                    data = data.replaceAll('%(?![0-9a-fA-F]{2})', '%25');
                                    data = data.replaceAll('\\+', '%2B');
                                    data = EncodingUtil.urlDecode(data, 'UTF-8');
                                    data = data.unescapeHtml4();
                                    articleTranslation.put(fieldSetTranslated[index], data);
                                    index++;
                                }
                            }
                            articleTranslation.Language = languageCode;
                            translationByLanguage.put(languageCode + '~' + article.KnowledgeArticleId, articleTranslation);
                        }
                        else {
                            System.debug('Translate Callout Error: '+response.getBody());
                            String errorMessage = '';
                            while(parser.nextToken() != null) {
                                if((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'message')) {
                                    parser.nextToken();
                                    errorMessage = parser.getText();
                                    break;
                                }
                            }
                            throw new UTL_CSM_ArticleTranslation.TranslationException('Translation failed: '+errorMessage);
                        }
                    } catch(Exception ex) {
                        System.debug('Callout Error : '+ex.getMessage());
                        throw new UTL_CSM_ArticleTranslation.TranslationException('Callout Error: '+ex.getMessage());
                    }
                }
            }
        }
        return translationByLanguage;
    }
    
    @TestVisible
    private static Map<String, HTTPResponse> translateCallout(String articleDataToTranslate, Set<String> languages, String sourceLanguage) {
        Map<String, HTTPResponse> languageResponseMap = new Map<String, HTTPResponse>();
        CSM_Translate_API_Connection__c translateAPI = UTL_CSM_ArticleTranslation.translateAPISetting;
        if (articleDataToTranslate != '' && translateAPI != null && translateAPI.Translate_API_Key__c != null && languages != null && !languages.isEmpty()) {
            for(String languageCode: languages) {
                HttpRequest request = new HttpRequest();
                Http http = new Http();
                List<Object> parameters = new List<Object> {languageCode, sourceLanguage, 'html'};
                String requestPart = String.format(translateAPI.Translate_API_Request_2__c, parameters);
                String url = translateAPI.Translate_API_URL__c + translateAPI.Translate_API_Key__c + requestPart;
                request.setMethod('GET');
                request.setHeader('referer', translateAPI.API_Referer__c);
                request.setBody(articleDataToTranslate);
                request.setEndPoint(url);
                HTTPResponse resp;
                resp = http.send(request);
                languageResponseMap.put(languageCode, resp);
            }
        } else if (translateAPI == null || translateAPI.Translate_API_Key__c == null || translateAPI.Translate_API_Key__c == '') {
            System.debug('The Translate API Key value is empty');
            throw new UTL_CSM_ArticleTranslation.TranslationException('The Translate API Key value is empty');
        } else if (articleDataToTranslate == '') {
            System.debug('The text intended to translate is empty');
            throw new UTL_CSM_ArticleTranslation.TranslationException('The text intended to translate is empty');
        }
        return languageResponseMap;
    }

    @TestVisible
    public static HttpResponse translateText(String text, String targetLanguage) {
        if (String.isBlank(text)) {
            System.debug('The text intended to translate is empty');
            throw new UTL_CSM_ArticleTranslation.TranslationException('The text intended to translate is empty');
        }

        CSM_Translate_API_Connection__c translateAPI = UTL_CSM_ArticleTranslation.translateAPISetting;
        if (translateAPI == null || String.isBlank(translateAPI.Translate_API_Key__c)) {
            System.debug('The Translate API Key value is empty');
            throw new UTL_CSM_ArticleTranslation.TranslationException('The Translate API Key value is empty');
        }

        try {
            String url = translateAPI.Translate_API_URL__c + translateAPI.Translate_API_Key__c;
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(url);
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json;charset=UTF-8');

            Map<String, Object> requestBody = new Map<String, Object>();
            requestBody.put('q', text);
            requestBody.put('target', targetLanguage);

            request.setBody(JSON.serialize(requestBody));

            HttpResponse response = http.send(request);

            if (response.getStatusCode() != 200) {
                System.debug('Error in Google Translate API call: ' + response.getBody());
            }

            return response;
        } catch (Exception e) {
            System.debug('Exception during translation: ' + e.getMessage());
            return null;
        }
    }     
    /**
     * The response of the google translate API 
     * should be something like this:
     * 
     *  {
     *		"data": {
     *			"translations": [
     *			{
     *				"translatedText": "Hallo Welt",
     *				"detectedSourceLanguage": "en"
     *			},
     *			{
     *				"translatedText": "Mein Name ist Jeff",
     *				"detectedSourceLanguage": "en"
     *			}
     *			]
     *		}
     *	}
    */    
}