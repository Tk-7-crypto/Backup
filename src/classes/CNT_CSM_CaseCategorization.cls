/*
 * Version       : 1.0
 * Description   : Apex Controller for CNT_LXC_Categorization Lightning component
 */
public class CNT_CSM_CaseCategorization {
    /**
    * This method used to return List<SObject> by given Id
    * @params  String recordId
    * @params  String objName
    * @return  List<SObject>
    */
    @AuraEnabled
    public static List<SObject> getRecord(String objName, String recordId){
        List<SObject> objects = new List<SObject>();
        try {

            if(objName == 'case'){
                objects = new SLT_Case().selectById(new Set<Id> { recordId });
            }else if(objName == 'Knowledge__kav' ){
                objects = new SLT_Knowledge().selectById(new Set<Id> { recordId });
            }else if(objName == 'CSM_QI_CaseAutomationScheduler__c'){
                objects = new SLT_CaseAutomationScheduler().selectById(new Set<Id> {recordId});
            }
        } catch(Exception ex) {
            ApexPages.addMessages(ex);
            throw new AuraHandledException(JSON.serialize(ex));
        }
        return objects;
    }

    /**
    * This method used to return List<CaseArticle> by given caseId
    * @params  String caseId
    * @return  List<CaseArticle>
    */
    @AuraEnabled
    public static List<CaseArticle> getCaseArticles(String caseId){
        List<CaseArticle> CaseArticles = new List<CaseArticle>();

        try {
            caseArticles = new SLT_CaseArticle().selectByCaseId(new Set<Id> {caseId});
        } catch(Exception ex) {
            ApexPages.addMessages(ex);
            throw new AuraHandledException(JSON.serialize(ex));
        }
        return caseArticles;
    }

    /**
    * This method used to return List<AggregateResult> of  Product__r.Name Categorization by given CaseId
    * @params  String recordId
    * @return  List<AggregateResult>
    */
    @AuraEnabled
    public static List<AggregateResult> getProductCategorizationForCase(String recordId, String pillar){
        List<Case> caseList = new List<Case>();
        List<Product2> products=  new List<Product2>();
        List<AggregateResult> productList = new  List<AggregateResult>();
        try {
            caseList = new SLT_Case().selectById(new Set<Id> { recordId });
            if(caseList != null && !caseList.isEmpty() && caseList[0].AccountId != null ) {
                Set<String> fieldSet = new Set<String>();
                fieldSet.add('Name');
                fieldSet.add('Id');
                fieldSet.add('Community_Topic__r.Name');
                String filterCondition ='';
                filterCondition = 'Id in(SELECT Product2Id FROM asset WHERE AccountId=\''+ caseList[0].AccountId +'\' AND Status !=\'Obsolete\') AND Pillar__c includes (\''+ pillar +'\') AND SpecificToCSM__c =true';
                //products=  new SLT_Product2().selectByAccountId(new Set<Id> { caseList[0].AccountId });
                products=  new SLT_Product2().getProductWithFilter(fieldSet,filterCondition);
                Set<String> c = new Set<String>();
                for (Integer i=0; i<products.size(); i++){
                    c.add(products[i].Name);
                }
                productList = new SLT_CaseCategorization().getProducts(c,caseList[0].RecordTypeId);
            }
            return productList;
        } catch(Exception ex) {
            ApexPages.addMessages(ex);
            throw new AuraHandledException(JSON.serialize(ex));
        }
    }

    /**
    * This method used to return List<Product2> by given caseId
    * @params  String caseId
    * @return  List<Product2>
    */
    @AuraEnabled
    public static List<Product2> getProductsCategorizationForData(String recordId){
        List<Case> caseList = new List<Case>();
        List<Product2> productList=  new List<Product2>();
        try {
            caseList = new SLT_Case().selectById(new Set<Id> { recordId });
            if(caseList != null && !caseList.isEmpty() && caseList[0].AccountId != null ) {
                productList =  new SLT_Product2().selectByAccountId(new Set<Id> { caseList[0].AccountId });
            }
            return productList;
        } catch(Exception ex) {
            ApexPages.addMessages(ex);
            throw new AuraHandledException(JSON.serialize(ex));
        }
    }

    /**
    * This method used to return List<AggregateResult> of  Product__r.Name Categorization
    * @params  String recordId
    * @return  List<AggregateResult>
    */
    @AuraEnabled
    public static List<AggregateResult> getProductCategorization(String pillar){
        List<AggregateResult> productList = new  List<AggregateResult>();
        try {
            productList = [select Name from Product2 where pillar__c includes (:pillar) group by Name];
            return productList;
        } catch(Exception ex) {
            ApexPages.addMessages(ex);
            throw new AuraHandledException(JSON.serialize(ex));
        }
    }

    /**
    * This method used to return List<AggregateResult> of  SubType1__c Categorization by given productName
    * @params  String productName
    * @return  List<AggregateResult>
    */
    @AuraEnabled
    public static List<AggregateResult> getCategorizationWithAggregate(String q){
        try {
            return new SLT_CaseCategorization().selectWithAggregate(q);

        } catch(Exception ex) {
            ApexPages.addMessages(ex);
            throw new AuraHandledException(JSON.serialize(ex));
        }
    }

    @AuraEnabled
    public static List<String> getKnowledgeArticleChapterList(String contrField){
        try {
            List<String> KAChapter = new List<String>();
            List<CSM_QI_Case_Categorization__c> cateList = new SLT_CaseCategorization().getCaseCategorizationByFilter('ProductName__c=\''+contrField+'\' and Type__c = \'Knowledge\' and Active__c = true');
            for(CSM_QI_Case_Categorization__c c : cateList){
                KAChapter.add(c.Article_Chapter__c);
            }
            KAChapter.sort();
            return KAChapter; 

        } catch(Exception ex) {
            ApexPages.addMessages(ex);
            throw new AuraHandledException(JSON.serialize(ex));
        }
    }
    
    /**
    * This method used to update categorization of Object Case or Knowledge__kav by given objectToUpdate, productName, subtype1,subtype2
    * @params SObject objectToUpdate
    * @paramsString productName
    * @params String subtype1,
    * @params String subtype2
    * @params String subtype3
    * @params String template
    * @params recordTypeId
    */
    @AuraEnabled
    public static void updateObjectCategorization(SObject objectToUpdate, String controllingField,String subtype1,String subtype2,String subtype3,String template, String pillar,String ArticleChapter, String AffectsVersion, CSM_QI_CREATE_Media_Date__c mediaDateDetail, String reasonforLateRequestReRun, String otherAuditsAndTheirFrequencies, String createAdditionalInfoJson){
        List<CSM_QI_Case_Categorization__c> categorizations= new List<CSM_QI_Case_Categorization__c>();
        String msg = '';
        if (objectToUpdate.getSObjectType() == Case.sObjectType) {
            Case caseToUpdate = new Case();
            caseToUpdate = (Case)objectToUpdate;
            if (pillar == CON_CSM.S_TECHNOLOGY_SOLUTIONS) {
                List<Asset> assets=new List<Asset>();
                List<Account> accounts=new List<Account>();
                List<Contact> contacts=new List<Contact>();
                if (caseToUpdate.Number_of_Article__c > 0) {
                    assets = [select Id from Asset where Name =: controllingField and AccountId =: caseToUpdate.AccountId];
                    categorizations = new SLT_CaseCategorization().getCaseCategorizationDetails(controllingField, subtype1, subtype2, subtype3, pillar);
                    if(assets.size() > 0) {
                        caseToUpdate.AssetId = assets[0].Id;
                    }else{
                        caseToUpdate.AssetId = null;
                    }
                    if(!categorizations.isEmpty()){
                        caseToUpdate.Case_CategorizationId__c = categorizations[0].Id;
                    }
                    caseToUpdate.ProductName__c = controllingField;
                    caseToUpdate.SubType1__c = subtype1;
                    caseToUpdate.SubType2__c = subtype2;
                    caseToUpdate.SubType3__c = subtype3;
                    caseToUpdate.Affects_Version__c = AffectsVersion;
                }else{
                    categorizations = new SLT_CaseCategorization().getCaseCategorizationDetails(controllingField, subtype1, subtype2, subtype3, pillar);
                    if(!categorizations.isEmpty()) {
                        assets = new SLT_Asset().selectByAccountIdAndProductId(new Set<Id> {caseToUpdate.AccountId},new Set<Id> {categorizations[0].Product__c});
                        contacts = new SLT_Contact().selectByContactIdList(new Set<Id> {caseToUpdate.ContactId}, new Set<String> {'Id','Contact_User_Type__c'});
                        if(assets.size() > 0){
                            caseToUpdate.AssetId=assets[0].Id;
                        }
                        caseToUpdate.Case_CategorizationId__c = categorizations[0].Id;
                        caseToUpdate.ProductName__c = categorizations[0].ProductName__c;
                        caseToUpdate.SubType1__c = categorizations[0].SubType1__c;
                        caseToUpdate.SubType2__c = categorizations[0].SubType2__c;
                        caseToUpdate.SubType3__c = categorizations[0].SubType3__c;
                        caseToUpdate.Product_Name_Einstein_CC__c = categorizations[0].ProductName__c;
                        caseToUpdate.CaseSubType1__c = categorizations[0].SubType1__c;
                        caseToUpdate.CaseSubType2__c = categorizations[0].SubType2__c;
                        caseToUpdate.CaseSubType3__c = categorizations[0].SubType3__c;
                        caseToUpdate.Affects_Version__c = AffectsVersion;
                        if(caseToUpdate.Case_Type__c != 'Problem' && categorizations[0].caseType__c != null && categorizations[0].caseType__c != '') {
                            caseToUpdate.Case_Type__c = categorizations[0].caseType__c;
                        }

                        if(!contacts.isEmpty() && 'HO User' == contacts[0].Contact_User_Type__c) {
                            accounts = new SLT_Account().selectById(new Set<Id> {caseToUpdate.AccountId});
                            if(!accounts.isEmpty() && accounts[0].CSH_SubType__c && categorizations[0] != null && categorizations[0].CSH_Visible__c) {
                                caseToUpdate.CSHSubType__c = categorizations[0].CSHSubType__c;
                            }else{
                                List<CSM_QI_Case_Categorization__c> cateList = new SLT_CaseCategorization().getCaseCategorizationByFilter('Product__r.Name=\''+controllingField+'\' and Type__c = \'Categorization\' and SubType1__c=\''+subtype1+'\' and SubType2__c=\'Please Specify\'');
                                if(cateList != null && !cateList.isEmpty()){
                                    caseToUpdate.CSHSubType__c = cateList[0].CSHSubType__c;
                                }
                            }
                        }
                    }
                }
               caseToUpdate = updateMileStoneType(caseToUpdate, controllingField, subtype1, subtype2, subtype3);
            }
            /*
            else if(pillar == CON_CSM.S_DATACreateService){
                List<Asset> assets=new List<Asset>();
                assets = [select Id from Asset where Name =: controllingField and AccountId =: caseToUpdate.AccountId];
                categorizations = new SLT_CaseCategorization().getCaseCategorizationDetails(controllingField, subtype1, subtype2, subtype3, pillar);
                if(assets.size() > 0) {
                    caseToUpdate.AssetId = assets[0].Id;
                }else{
                    caseToUpdate.AssetId = null;
                }
                if(!categorizations.isEmpty()){
                    caseToUpdate.Case_CategorizationId__c = categorizations[0].Id;
                }
                caseToUpdate.ProductName__c = controllingField;
                caseToUpdate.SubType1__c = subtype1;
                caseToUpdate.SubType2__c = subtype2;
                caseToUpdate.SubType3__c = subtype3;
            }
            */
            else if (pillar == CON_CSM.S_R_D) {
                categorizations = new SLT_CaseCategorization().getCaseCategorizationByFilter('Type__c = \'Categorization\' and LOS__c=\''+controllingField+'\' and SubType1__c=\''+subtype1+'\' and SubType2__c=\''+subtype2+'\' and SubType3__c=\''+subtype3+'\'');
                if(!categorizations.isEmpty()) {
                    caseToUpdate.Case_CategorizationId__c = categorizations[0].Id;
                    caseToUpdate.LOS__c = categorizations[0].LOS__c;
                    caseToUpdate.SubType1__c = categorizations[0].SubType1__c;
                    caseToUpdate.SubType2__c = categorizations[0].SubType2__c;
                    caseToUpdate.SubType3__c = categorizations[0].SubType3__c;
                }
                if (caseToUpdate.RecordTypeId =='0126A000000hC32QAE'){
                    caseToUpdate.Template__c = template;
                }
            }
            else if (pillar == CON_CSM.S_INFORMATION_OFFERING) {
                List<Asset> assets=new List<Asset>();
                if (caseToUpdate.RecordTypeName__c == CON_CSM.S_DATACreateService) {
                    categorizations = new SLT_CaseCategorization().getCaseCategorizationDetails(controllingField, subtype1, subtype2, subtype3, pillar);
                    if(!categorizations.isEmpty()) {
                        assets = new SLT_Asset().selectByAccountIdAndProductId(new Set<Id> {caseToUpdate.AccountId},new Set<Id> {categorizations[0].Product__c});
                        if(assets.size() > 0){
                            caseToUpdate.AssetId=assets[0].Id;
                        }
                        caseToUpdate.Case_CategorizationId__c = categorizations[0].Id;
                        caseToUpdate.ProductName__c = categorizations[0].ProductName__c;
                        caseToUpdate.SubType1__c = categorizations[0].SubType1__c;
                        caseToUpdate.SubType2__c = categorizations[0].SubType2__c;
                        caseToUpdate.SubType3__c = categorizations[0].SubType3__c;
                    }
                    if (mediaDateDetail != null) {
                        caseToUpdate.DueDate__c = mediaDateDetail.Maint_Due_Date__c;
                        caseToUpdate.Media_Date__c = mediaDateDetail.Media_Date__c;
                        caseToUpdate.Media_Date_Label__c = mediaDateDetail.Media_Date_Label__c;
                        caseToUpdate.Media_Download_Date__c = mediaDateDetail.Download_Date__c;
                    } else if (mediaDateDetail == null) {
                        caseToUpdate.DueDate__c = null;
                        caseToUpdate.Media_Date__c = null;
                        caseToUpdate.Media_Date_Label__c = '';
                        caseToUpdate.Media_Download_Date__c = null;
                    }
                    caseToUpdate.Reason_for_Late_Request_Re_Run__c = reasonforLateRequestReRun;
                    caseToUpdate.Other_audits_and_their_frequencies__c = otherAuditsAndTheirFrequencies;
                    if (createAdditionalInfoJson != '') {
                        List<Object> createAdditionalInfoList = (List<Object>) JSON.deserializeUntyped(createAdditionalInfoJson);
                        for (Object obj : createAdditionalInfoList) {
                            Map<String, Object> fieldData = (Map<String, Object>) obj;
                            String fieldApiName = (String) fieldData.get('apiName');
                            Object fieldValue = fieldData.get('value');
                            if (caseToUpdate.getSObjectType().getDescribe().fields.getMap().containsKey(fieldApiName)) {
                                if (caseToUpdate.getSObjectType().getDescribe().fields.getMap().get(fieldApiName).getDescribe().getType() == Schema.DisplayType.Date) {
                                    fieldValue = Date.valueOf((String) fieldValue);
                                }
                                caseToUpdate.put(fieldApiName, fieldValue);
                            }
                        }
                    }
                } else {
                    assets = [select Id from Asset where Name =: controllingField and AccountId =: caseToUpdate.AccountId];
                    if(assets.size() > 0) {
                        caseToUpdate.AssetId = assets[0].Id;
                    }else{
                        caseToUpdate.AssetId = null;
                    }
                    caseToUpdate.ProductName__c = controllingField;
                    caseToUpdate.SubType1__c = subtype1;
                    caseToUpdate.SubType2__c = subtype2;
                    caseToUpdate.SubType3__c = subtype3;
                }
            }

            if(!categorizations.isEmpty() || pillar == CON_CSM.S_INFORMATION_OFFERING || ( pillar == CON_CSM.S_TECHNOLOGY_SOLUTIONS && caseToUpdate.Number_of_Article__c > 0 ) ) {
                try{
                    update caseToUpdate;
                }catch(DmlException e) {
                    for (Integer i = 0; i < e.getNumDml(); i++) {
                        //Get Validation Rule & Trigger Error Messages
                        msg =+e.getDmlMessage(i) +  '\n';
                    }
                    throw new AuraHandledException(msg);
                }catch(Exception e) {
                    //throw all other exception message
                    throw new AuraHandledException(e.getMessage());
                }
            }


        }else if (objectToUpdate.getSObjectType() == Knowledge__kav.sObjectType) {
            List<Product2> products = [select Id from Product2 where Name =: controllingField and pillar__c includes (:pillar) ];
            Knowledge__kav knowledgeToUpdate = new Knowledge__kav();
            knowledgeToUpdate = (Knowledge__kav)objectToUpdate;
            if(!products.isEmpty()) {
                knowledgeToUpdate.Product__c = products[0].Id;
            }
            knowledgeToUpdate.ProductName__c = controllingField;
            knowledgeToUpdate.SubType1__c = subtype1;
            knowledgeToUpdate.SubType2__c = subtype2;
            knowledgeToUpdate.SubType3__c = subtype3;
            knowledgeToUpdate.Article_Chapter__c = ArticleChapter;
            update knowledgeToUpdate;
        }
        else if (objectToUpdate.getSObjectType() == CSM_QI_CaseAutomationScheduler__c.sObjectType){
            CSM_QI_CaseAutomationScheduler__c automationRecord = new CSM_QI_CaseAutomationScheduler__c();
            automationRecord = (CSM_QI_CaseAutomationScheduler__c)objectToUpdate;
            List<Asset> assets=new List<Asset>();
            if(pillar == CON_CSM.S_TECHNOLOGY_SOLUTIONS){
                categorizations = new SLT_CaseCategorization().getCaseCategorizationDetails(controllingField, subtype1, subtype2, subtype3, pillar);
                if(!categorizations.isEmpty()) {
                    assets = new SLT_Asset().selectByAccountIdAndProductName(automationRecord.Account_Name__c, controllingField);
                    if(assets.size() > 0) {
                        automationRecord.Asset_Name__c = assets[0].Id;
                    }
                    automationRecord.Case_Categorization__c = categorizations[0].Id;
                    //automationRecord.ProductName__c = categorizations[0].ProductName__c;
                    automationRecord.SubType1__c = categorizations[0].SubType1__c;
                    automationRecord.SubType2__c = categorizations[0].SubType2__c;
                    automationRecord.SubType3__c = categorizations[0].SubType3__c;
                    try{
                        update automationRecord;
                    }
                    catch(Exception e){
                        throw new AuraHandledException(e.getMessage());
                    }
                }
            }
        }
    }

    /**
    * This method used to update a Case
    * @params  String recordId
    * @params  String objName
    * @return  List<SObject>
    */
    @AuraEnabled
    public static void updateCase(Case c){
        update c;
    }

    /**
    * This method used to get dependencies between 2 pickList
    * @params  String objApiName
    * @params  String contrfieldApiName
    * @params  String depfieldApiName
    * @return  Map<String,List<String>>
    */
    @AuraEnabled
    public static Map<String,List<String> > getDependentOptionsImpl(string objApiName, string contrfieldApiName, string depfieldApiName){
        system.debug(objApiName + '##' + contrfieldApiName + '###' + depfieldApiName);

        String objectName = objApiName.toLowerCase();
        String controllingField = contrfieldApiName.toLowerCase();
        String dependentField = depfieldApiName.toLowerCase();
        Map<String,List<String>> fieldDependenciesData = new Map<String,List<String>>();  // Key : ControllingField Picklist Value Label ; Value : List of all DependentField Picklist Value Labels
        Map<String, String> controllingFieldAPIValueVSLabel = new Map<String,String>();   //Key : Picklist Value API Name ; Value = Picklist Value Label
        Map<String, String> dependentFieldAPIValueVSLabel = new Map<String,String>();   //Key : Picklist Value API Name ; Value = Picklist Value Label
        
        Schema.SObjectType objType = Schema.getGlobalDescribe().get(objectName);
        Schema.DescribeSObjectResult describeResult = objType.getDescribe();
        Schema.DescribeFieldResult controllingFieldInfo = describeResult.fields.getMap().get(controllingField).getDescribe();
        Schema.DescribeFieldResult dependentFieldInfo = describeResult.fields.getMap().get(dependentField).getDescribe();
        
        List<Schema.PicklistEntry> controllingValues = controllingFieldInfo.getPicklistValues();
        List<Schema.PicklistEntry> dependentValues = dependentFieldInfo.getPicklistValues();
        
        for(Schema.PicklistEntry currControllingValue : controllingValues){
            controllingFieldAPIValueVSLabel.put(currControllingValue.getValue(), currControllingValue.getLabel());
            fieldDependenciesData.put(currControllingValue.getValue(), new List<String>());
        }                
                    
        
        for(Schema.PicklistEntry currDependentValue : dependentValues)
        {
            dependentFieldAPIValueVSLabel.put(currDependentValue.getValue(), currDependentValue.getLabel());
                        
            PickListInfoValidForDeserializationClass picklistInfo = (PickListInfoValidForDeserializationClass) JSON.deserialize(JSON.serialize(currDependentValue), PickListInfoValidForDeserializationClass.class);
            String hexString = EncodingUtil.convertToHex(EncodingUtil.base64Decode(picklistInfo.validFor)).toUpperCase();  //decoding validFor from Base64 to Hex value, so that we can formulate the conditions in Hex, Decimal & Binary, which we all are familiar with.
            //System.debug('DependentField: Label:' + currDependentValue.getValue() + ' ValidForInHex:' + hexString + ' JsonString:' + JSON.serialize(currDependentValue));
            // validFor:AgACgAAA ; ValidForBase64Decoded: 000000 100000 000000 000010 100000 000000 000000 000000 ; ValidForInHex:020002800000  ||  JsonString:{"active":true,"defaultValue":false,"label":"Antivirus and Security Software","validFor":"AgACgAAA","value":"Antivirus and Security Software"}
            Integer baseCount = 0;       //Decimal [0-15] = Hex [0-F] = Binary [0000 - 1111], hence baseCount has to start from 0 & has to be incremented by 4 places.
            for(Integer curr : hexString.getChars())  // HEX[0-9] have charset range from 48 to 57 & HEX[A-F] have charset range from 65 to 70, hence for every hexchar in hexstring, returns the decimal value -> output is a list
            {
                Integer val = 0;
                if(curr >= 65){             //HEX['A'=>65, 'B'=>66, 'C'=>67, 'D'=>68, 'E'=>69, 'F'=>70] 
                    val = curr - 65 + 10;   //Decimal 10 = Hex A, ..... Decimal 15 = Hex F, hence added 10
                }else{                      //HEX['0'=>48, '1'=>49, '2'=>50, '3'=>51, '4'=>52, '5'=>53, '6'=>54, '7'=>55, '8'=>56, '9'=>57]  
                    val = curr - 48;        //Decimal 0 = Hex 0, ..... Decimal 9 = Hex 9.
                }
                /* Since validFor uses trailing 0's to complete the validFor Binary string, hence if in case, for a Picklist let's say there are only 2 Controlling values, then 
                 * Controlling Picklist Value will be residing in 01 & 10 ==> i.e 1000 & 0100  ==> baseCount will be either 0 or 1.
                 */
                
                if((val & 8) == 8)       //Bitwise AND 1000 with val, if returns 1000 ==> Retrive the Controlling value from current baseCount position
                {
                    //System.debug('Dependent Field: ' + currDependentValue.getLabel() + ' Partof ControllingField:' + controllingValues[baseCount + 0].getValue());
                    fieldDependenciesData.get(controllingValues[baseCount + 0].getValue()).add(currDependentValue.getLabel());
                }
                if((val & 4) == 4)       //Bitwise AND 0100 with val, if returns 0100 ==> Retrive the Controlling value from current baseCount+1 positions ahead
                {
                    //System.debug('Dependent Field: ' + currDependentValue.getLabel() + ' Partof ControllingField:' + controllingValues[baseCount + 1].getValue());
                    fieldDependenciesData.get(controllingValues[baseCount + 1].getValue()).add(currDependentValue.getLabel());                    
                }
                if((val & 2) == 2)       //Bitwise AND 0010 with val, if returns 0010 ==> Retrive the Controlling value from current baseCount+2 positions ahead
                {
                    //System.debug('Dependent Field: ' + currDependentValue.getLabel() + ' Partof ControllingField:' + controllingValues[baseCount + 2].getValue());
                    fieldDependenciesData.get(controllingValues[baseCount + 2].getValue()).add(currDependentValue.getLabel());                    
                }
                if((val & 1) == 1)       //Bitwise AND 0001 with val, if returns 0001 ==> Retrive the Controlling value from current baseCount+3 positions ahead
                {
                    //System.debug('Dependent Field: ' + currDependentValue.getLabel() + ' Partof ControllingField:' + controllingValues[baseCount + 3].getValue());
                    fieldDependenciesData.get(controllingValues[baseCount + 3].getValue()).add(currDependentValue.getLabel());                    
                }
                baseCount += 4;
            }
        }
        
        /** for(String fieldDependenciesKey : fieldDependenciesData.keySet()){
            System.debug('fieldDependenciesData: '+fieldDependenciesKey+' :=: '+fieldDependenciesData.get(fieldDependenciesKey));
        }*/
         
        
        return fieldDependenciesData;
    }


    @AuraEnabled(cacheable=true)
    public static List<String> getPicklistValues(String objectName, String fieldName) {
        List<String> picklistValues = new List<String>();

        try {
            Schema.SObjectType sObjectType = Schema.getGlobalDescribe().get(objectName);

            if (sObjectType != null) {
                Schema.DescribeFieldResult fieldResult = sObjectType.getDescribe().fields.getMap().get(fieldName).getDescribe();
                List<Schema.PicklistEntry> picklistEntries = fieldResult.getPicklistValues();
                for (Schema.PicklistEntry entry : picklistEntries) {
                    picklistValues.add(entry.getValue());
                }
            } else {
                System.debug('Invalid object name: ' + objectName);
            }
        } catch (Exception e) {
            System.debug('Error retrieving picklist values: ' + e.getMessage());
        }

        return picklistValues;
    }

    @AuraEnabled
    public static TimeSheet__c getTimeSheetRecord(String caseId){
        List<TimeSheet__c> sheet = new List<TimeSheet__c>();
        String userId = UserInfo.getUserId();
        sheet = Database.query('Select Id, Name, Timeinhours__c,StartTime__c,Status__c,Case__c From TimeSheet__c Where Case__c =:caseId and LastModifiedById =:userId and Status__c = \'start\' LIMIT 1');
        if(!sheet.isEmpty()) {
            return sheet[0];
        }else{
            return null;
        }
    }

    @AuraEnabled
    public static List<AggregateResult> getProductCategorizationForAutomation(String recordId, String pillar){
        String recordTypeId;
        if(pillar == CON_CSM.S_TECHNOLOGY_SOLUTIONS){
            recordTypeId = '0126A000000hC35QAE';
        }
        else if(pillar == CON_CSM.S_INFORMATION_OFFERING){
            recordTypeId = '0126A000000hC33QAE';
        }
        List<CSM_QI_CaseAutomationScheduler__c> recordList = new List<CSM_QI_CaseAutomationScheduler__c>();
        List<Product2> products=  new List<Product2>();
        List<AggregateResult> productList = new  List<AggregateResult>();
        try {
            recordList = new SLT_CaseAutomationScheduler().selectById(new Set<Id> { recordId });
            if(recordList != null && !recordList.isEmpty() && recordList[0].Account_Name__c != null ) {
                Set<String> fieldSet = new Set<String>();
                fieldSet.add('Name');
                fieldSet.add('Id');
                fieldSet.add('Community_Topic__r.Name');
                String filterCondition ='';
                filterCondition = 'Id IN(SELECT Product2Id FROM Asset WHERE AccountId=\''+ recordList[0].Account_Name__c +'\' AND Status !=\'Obsolete\')';
                products=  new SLT_Product2().getProductWithFilter(fieldSet,filterCondition);
                Set<String> productNameSet = new Set<String>();
                for (Integer i=0; i<products.size(); i++){
                    productNameSet.add(products[i].Name);
                }
                productList = new SLT_CaseCategorization().getProducts(productNameSet, recordTypeId);
            }
            return productList;
        } catch(Exception ex) {
            ApexPages.addMessages(ex);
            throw new AuraHandledException(JSON.serialize(ex));
        }
    }

    @AuraEnabled
    public static List<String> getAffectsVersion(String contrField){
        try {
            List<String> affectsVersion = new List<String>();
            List<CSM_QI_Case_Categorization__c> cateList = new SLT_CaseCategorization().getCaseCategorizationByFilter('ProductName__c=\''+contrField+'\' and Type__c = \'Affects Version\' and Active__c = true');
            for(CSM_QI_Case_Categorization__c c : cateList){
                affectsVersion.add(c.Affects_Version__c);
            }
            affectsVersion.sort();
            return affectsVersion; 

        } catch(Exception ex) {
            ApexPages.addMessages(ex);
            throw new AuraHandledException(JSON.serialize(ex));
        }
    }

    @AuraEnabled
    public static List<String> getTemplate(String contrField){
        try {
            List<String> template = new List<String>();
            List<CSM_QI_Case_Categorization__c> cateList = new SLT_CaseCategorization().getCaseCategorizationByFilter('LOS__c=\''+contrField+'\' and Type__c = \'Activity\' and Active__c = true');
            for(CSM_QI_Case_Categorization__c c : cateList){
                template.add(c.RnD_Template__c);
            }
            template.sort();
            return template; 

        } catch(Exception ex) {
            ApexPages.addMessages(ex);
            throw new AuraHandledException(JSON.serialize(ex));
        }
    }

    
    @AuraEnabled
    public static case updateMileStoneType(Case c, String product, String subtype1, String subtype2, String subtype3) {
        CSM_QI_Case_Categorization__c cat = [SELECT Milestone_Type__c FROM CSM_QI_Case_Categorization__c 
            WHERE ProductName__c = :product AND SubType1__c = :subtype1 AND SubType2__c = :subtype2 AND SubType3__c = :subtype3 AND Pillar__c = :CON_CSM.S_TECHNOLOGY_SOLUTIONS AND Type__c = 'Categorization'
            LIMIT 1];
        List<String> milestoneTypeList = new List<String>{'BA10LOW','BA30MED','BA50HIGH','CR10LOW','CR30MED','CR50HIGH','DM10LOW','DM30MED','DM50HIGH'};
        boolean isNotUpdated = true;
        if (cat != null) {
            if(c.TaskMilestone__c == null && cat.Milestone_Type__c != null){
                c.TaskMilestone__c = cat.Milestone_Type__c;
            }else if(c.TaskMilestone__c != null){
                for(String ms : milestoneTypeList){
                    if(c.TaskMilestone__c.contains(ms)){
                        if(cat.Milestone_Type__c == null){
                            if(c.TaskMilestone__c.contains(';')){
                                c.TaskMilestone__c = c.TaskMilestone__c.replace(';'+ms, '');
                            }else{
                                c.TaskMilestone__c = c.TaskMilestone__c.replace(ms, '');
                            }
                        }else if(cat.Milestone_Type__c != null){
                            c.TaskMilestone__c = c.TaskMilestone__c.replace(ms, cat.Milestone_Type__c); 
                        }
                        isNotUpdated = false;
                    }  
                }
                if(isNotUpdated && cat.Milestone_Type__c != null){
                    c.TaskMilestone__c += ';' + cat.Milestone_Type__c;
                }
            }
        }
        return c;
    }

    @AuraEnabled(cacheable=false)
    public static List<CSM_QI_Case_Categorization__c> getArticleChapters() {
        return [
            SELECT Id, Product__c, ProductName__c, Article_Chapter__c, Article_Chapter_Order__c, Pillar__c
            FROM CSM_QI_Case_Categorization__c
            WHERE Article_Chapter__c != null
            AND Type__c = 'Knowledge'
            AND Product__r.Community_Topic__c != null
            ORDER BY ProductName__c
        ];
    }

    @AuraEnabled(cacheable=true)
    public static List<Product2> getAvailableProductsForAddArticleChapters(String pillar) {
        return [
            SELECT Id, Name 
            FROM Product2 
            WHERE SpecificToCSM__c = true 
            AND Community_Topics__c != null 
            AND Id NOT IN (
                SELECT Product__c 
                FROM CSM_QI_Case_Categorization__c 
                WHERE Type__c = 'Knowledge'
            ) 
            AND Pillar__c = :pillar
        ];
    }


    @AuraEnabled(cacheable=false)
    public static List<KnowledgeArticleWrapper> getKnowledgeArticles(String articleChapter, String productName, String pillar) {
        List<Knowledge__kav> articles = [
            SELECT Id, Title, Summary, UrlName, LastPublishedDate, ArticleNumber
            FROM Knowledge__kav
            WHERE ProductName__c = :productName
            AND Pillar__c = :pillar
            AND Article_Chapter__c = :articleChapter
            AND PublishStatus = 'Online'
            AND Language = 'en_US'
        ];

        Set<String> ArticleNumbers = new Set<String>();
        for (Knowledge__kav article : articles) {
            ArticleNumbers.add(article.ArticleNumber);
        }
    
        Map<String, Decimal> articleOrderMap = new Map<String, Decimal>();
        List<CSM_QI_Knowledge_Article_Order__c> orders = [
            SELECT ArticleNumber__c, Order__c
            FROM CSM_QI_Knowledge_Article_Order__c
            WHERE ArticleNumber__c IN :ArticleNumbers
        ];

        for (CSM_QI_Knowledge_Article_Order__c order : orders) {
            articleOrderMap.put(order.ArticleNumber__c, order.Order__c);
        }

        List<KnowledgeArticleWrapper> articleWrappers = new List<KnowledgeArticleWrapper>();
        for (Knowledge__kav article : articles) {
            Decimal order = articleOrderMap.containsKey(article.ArticleNumber) ? articleOrderMap.get(article.ArticleNumber) : 9999;
            articleWrappers.add(new KnowledgeArticleWrapper(article, order));
        }
        
        return articleWrappers;
    }

    @AuraEnabled
    public static void saveArticleOrder(List<KnowledgeArticleWrapper> articleWrappers) {
        List<CSM_QI_Knowledge_Article_Order__c> articleOrderToUpdate = new List<CSM_QI_Knowledge_Article_Order__c>();
        Set<String> articleIds = new Set<String>();
    
        for (KnowledgeArticleWrapper wrapper : articleWrappers) {
            articleIds.add(wrapper.article.ArticleNumber);
        }
        Map<String, CSM_QI_Knowledge_Article_Order__c> existingArticleOrderMap = new Map<String, CSM_QI_Knowledge_Article_Order__c>();
        for (CSM_QI_Knowledge_Article_Order__c existingArticleOrder : [
            SELECT Id, ArticleNumber__c, Order__c
            FROM CSM_QI_Knowledge_Article_Order__c
            WHERE ArticleNumber__c IN :articleIds
        ]) {
            existingArticleOrderMap.put(existingArticleOrder.ArticleNumber__c, existingArticleOrder);
        }
        for (KnowledgeArticleWrapper wrapper : articleWrappers) {
            CSM_QI_Knowledge_Article_Order__c articleOrder;
    
            if (existingArticleOrderMap.containsKey(wrapper.article.ArticleNumber)) {
                articleOrder = existingArticleOrderMap.get(wrapper.article.ArticleNumber);
                articleOrder.Order__c = wrapper.order;
            } else {
                articleOrder = new CSM_QI_Knowledge_Article_Order__c();
                articleOrder.ArticleNumber__c = wrapper.article.ArticleNumber;
                articleOrder.Order__c = wrapper.order;
            }
    
            articleOrderToUpdate.add(articleOrder);
        }

        upsert articleOrderToUpdate;
        
    }

    @AuraEnabled
    public static List<EXT_CSM_CheckboxDetails> getReasonLateList(){
        List<EXT_CSM_CheckboxDetails> options = new List<EXT_CSM_CheckboxDetails>();
        List<CSM_RecordType_Based_Picklist_Setting__mdt> recordTypeBasedSettings = Database.query('SELECT DeveloperName, PicklistValues__c FROM CSM_RecordType_Based_Picklist_Setting__mdt WHERE RecordType_Name__c =\'DATACreateService\' AND ObjectName__c =\'Case\' AND PicklistFieldName__c =\'Reason_for_Late_Request_Re_Run__c\' LIMIT 1');
        if(recordTypeBasedSettings != null && !recordTypeBasedSettings.isEmpty()) {
            List<String> typeList = recordTypeBasedSettings[0].PicklistValues__c.split(';');
            for (String pf : typeList) {
                options.add(new EXT_CSM_CheckboxDetails(pf, pf,true));
            }
        }
        return options;
    }

    public class KnowledgeArticleWrapper {
        @AuraEnabled
        public Knowledge__kav article { get; set; }
        @AuraEnabled
        public Decimal order { get; set; }

        public KnowledgeArticleWrapper() {
            this.article = new Knowledge__kav();
            this.order = 0;
        }

        public KnowledgeArticleWrapper(Knowledge__kav article, Decimal order) {
            this.article = article;
            this.order = order;
        }
    }
    

    
    public class PickListInfoValidForDeserializationClass
    {
        public String validFor;
    }

    @AuraEnabled(cacheable=true)
    public static List<Asset> getAssetsForAccount(Id accountId) {
        return [
            SELECT Id, Product2Id, Product2.Name
            FROM Asset
            WHERE AccountId = :accountId
        ];
    }

    @AuraEnabled(cacheable=true)
    public static CategorizationResponse getCategorizationOptions(List<String> assetProductIds, String recordTypeId, String caseType) {
        String caseTypePattern = '%' + caseType + '%';
        List<CSM_QI_Case_Categorization__c> categorizations = [
            SELECT Id, ProductName__c, Product__c, SubType1__c, SubType2__c, SubType3__c
            FROM CSM_QI_Case_Categorization__c
            WHERE Product__c IN :assetProductIds AND RecordTypeId__c = :recordTypeId AND Active__c = true AND Type__c ='Categorization' AND CaseType__c LIKE :caseTypePattern
            ORDER BY ProductName__c
        ];
    
        Map<String, Map<String, Map<String, List<Map<String, Object>>>> > productSubtypes = new Map<String, Map<String, Map<String, List<Map<String, Object>>>>>();
        Map<String, String> productLabels = new Map<String, String>();
    
        for (CSM_QI_Case_Categorization__c categorization : categorizations) {
            if (!productLabels.containsKey(categorization.Product__c)) {
                productLabels.put(categorization.Product__c, categorization.ProductName__c);
            }
    
            if (!productSubtypes.containsKey(categorization.Product__c)) {
                productSubtypes.put(categorization.Product__c, new Map<String, Map<String, List<Map<String, Object>>>>());
            }
    
            if (!productSubtypes.get(categorization.Product__c).containsKey(categorization.SubType1__c)) {
                productSubtypes.get(categorization.Product__c).put(categorization.SubType1__c, new Map<String, List<Map<String, Object>>>());
            }
    
            if (!productSubtypes.get(categorization.Product__c).get(categorization.SubType1__c).containsKey(categorization.SubType2__c)) {
                productSubtypes.get(categorization.Product__c).get(categorization.SubType1__c).put(categorization.SubType2__c, new List<Map<String, Object>>());
            }
    
            Map<String, Object> subtype3Option = new Map<String, Object>{
                'label' => categorization.SubType3__c,
                'value' => categorization.SubType3__c,
                'id' => categorization.Id
            };
    
            productSubtypes.get(categorization.Product__c)
                           .get(categorization.SubType1__c)
                           .get(categorization.SubType2__c).add(subtype3Option);
        }
    
        CategorizationResponse response = new CategorizationResponse();
        response.products = new List<Map<String, Object>>();
    
        for (String productId : productLabels.keySet()) {
            Map<String, Object> productOption = new Map<String, Object>();
            productOption.put('label', productLabels.get(productId));
            productOption.put('value', productId);
    
            List<Map<String, Object>> subtypes1 = new List<Map<String, Object>>();
    
            for (String subtype1 : productSubtypes.get(productId).keySet()) {
                Map<String, Object> subtype1Option = new Map<String, Object>();
                subtype1Option.put('label', subtype1);
                subtype1Option.put('value', subtype1);
    
                List<Map<String, Object>> subtype2List = new List<Map<String, Object>>();
    
                for (String subtype2 : productSubtypes.get(productId).get(subtype1).keySet()) {
                    Map<String, Object> subtype2Option = new Map<String, Object>();
                    subtype2Option.put('label', subtype2);
                    subtype2Option.put('value', subtype2);
    
                    List<Map<String, Object>> subtype3Options = productSubtypes.get(productId)
                        .get(subtype1).get(subtype2);
    
                    subtype2Option.put('subtype3', subtype3Options);
    
                    subtype2List.add(subtype2Option);
                }
    
                subtype1Option.put('subtype2', subtype2List);
                subtypes1.add(subtype1Option);
            }
    
            productOption.put('subtypes1', subtypes1);
            response.products.add(productOption);
        }
    
        return response;
    }
    


    @AuraEnabled(cacheable=true)
    public static List<CSM_QI_CREATE_Media_Date__c> getMediaDates(String product, String subtype1, String subtype2) {
        List<CSM_QI_CREATE_Media_Date__c> mediaDates = new List<CSM_QI_CREATE_Media_Date__c>();
        mediaDates = [SELECT Id, Media_Date_Label__c, Media_Date__c, Download_Date__c, Maint_Due_Date__c 
                    FROM CSM_QI_CREATE_Media_Date__c 
                    WHERE ProductName__c = :product AND SubType2__c = :subtype2];
        return mediaDates;
    }

    public class CategorizationResponse {
        @AuraEnabled public List<Map<String, Object>> products;
    }

    
}