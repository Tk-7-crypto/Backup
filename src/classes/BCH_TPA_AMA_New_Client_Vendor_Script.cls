/**
* @author : Supriya Johari
* To find new Clients and vendors in AMA Process
* Modified the class under ER-3884
*/

global class BCH_TPA_AMA_New_Client_Vendor_Script implements Database.Batchable<sObject>, Database.Stateful {
    public List<AMA_Contract_Detail__c> amaContracts;

    // to truncate Client and vendor name
    public Set<String>charactersToBeTruncated;

    // possible names for usa
    public Set<String>usaPossibleNames;

    public String truncatedName;

    public Map<String, TPA_AMA_Client_Vendor_Match__c> ClientWithTruncatedName = new Map<String, TPA_AMA_Client_Vendor_Match__c>();

    global BCH_TPA_AMA_New_Client_Vendor_Script() {
        usaPossibleNames = new Set<String> {
            'US'
            , 'U.S.'
            , 'USA'
            , 'United States Of America'
            , 'U.S'
            , 'U.S.A'
            , 'United States'
            , 'U.S.A.'
        };
        charactersToBeTruncated = new Set<String> {
            ', inc'
            , ',inc'
            , ' inc'
            , ' inc.'
            , ',inc.'
            , ', inc.'
            , ', llc'
            , ',llc'
            , ' llc'
            , ', llp'
            , ',llp'
            , ' llp'
            , ', corp'
            , ',corp'
            , ' corp'
            , ', lp'
            , ',lp'
            , ' lp'
            , ', ltd'
            , ',ltd'
            , ' ltd'
            , ' ltd.'
            , ', ltd.'
            , ',ltd.'
            , ', l.p.'
            , ',l.P.'
            , ' l.p.'
            , ', us'
            , ',us'
            , ' us'
            , ' &co'
            , ' & co'
            , '. co'
            , '.co'
            , ' co.'
            , ' and company'
            , ' pvt'
            , ' pvt.'
        };
        ClientWithTruncatedName = new Map<String, TPA_AMA_Client_Vendor_Match__c>();

        // to get Client names for which mapping is provided
        List<TPA_AMA_Client_Vendor_Search_Map__c> amaClientVendorSearchList = [select id, AMA_Account_Search_Text__c from TPA_AMA_Client_Vendor_Search_Map__c];

        Set<String> searchMap = new Set<String>();

        for(TPA_AMA_Client_Vendor_Search_Map__c amaClientsSearchMap: amaClientVendorSearchList) {
            if(String.isNotBlank(amaClientsSearchMap.AMA_Account_Search_Text__c))
                searchMap.add(amaClientsSearchMap.AMA_Account_Search_Text__c.toLowerCase());
        }

        // to get all the client and vendors names which does not exist in search Map
        amaContracts = [Select id, Client__c, Client_Services_On_Behalf_Of__c from AMA_Contract_Detail__c where(NOT Client__c Like 'Test_%') AND(NOT Client_Services_On_Behalf_Of__c Like 'Test_%')];
        Set<String> clientSet = new Set<String>();

        for(AMA_Contract_Detail__c amaContract: amaContracts) {
            TPA_AMA_Client_Vendor_Match__c matchObject;

            // for client
            if(String.isNotBlank(amaContract.Client__c) && !searchMap.contains(amaContract.Client__c.trim().toLowerCase())) {
                matchObject = new TPA_AMA_Client_Vendor_Match__c();
                matchObject.Client_Name__c = amaContract.Client__c.trim();
                matchObject.Truncated_Name__c = getTruncatedName(amaContract.Client__c.trim()).trim();
                ClientWithTruncatedName.put(amaContract.Client__c, matchObject);

            }

            // for vendor   
            if(String.isNotBlank(amaContract.Client_Services_On_Behalf_Of__c) && !amaContract.Client_Services_On_Behalf_Of__c.containsIgnoreCase('own behalf') && !searchMap.contains(amaContract.Client_Services_On_Behalf_Of__c.trim().toLowerCase())) {
                matchObject = new TPA_AMA_Client_Vendor_Match__c();
                matchObject.Client_Name__c = amaContract.Client_Services_On_Behalf_Of__c.trim();
                matchObject.Truncated_Name__c = getTruncatedName(amaContract.Client_Services_On_Behalf_Of__c.trim()).trim();
                ClientWithTruncatedName.put(amaContract.Client_Services_On_Behalf_Of__c, matchObject);
            }
        }

        //Deleting the existing AMA Client Vendor matching extracts
        List<TPA_AMA_Client_Vendor_Match__c> amaClientVendorMatchingList = [select id from TPA_AMA_Client_Vendor_Match__c];
        if(amaClientVendorMatchingList.size()>0) {
            delete amaClientVendorMatchingList;
        }

    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'Select id, name, Country__c, Is_TPA_Account__c From Address__c';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject>objList) {
        for(TPA_AMA_Client_Vendor_Match__c clientVendorMatch: ClientWithTruncatedName.values()) {
            clientVendorMatch.New_Client_Vendor__c = 'New Client/Vendor';
            for(sObject obj: objList) {
                Address__c acc = (Address__c) obj;
                if(String.isNotBlank(acc.name) && acc.name.startsWithIgnoreCase(clientVendorMatch.Truncated_Name__c)) {

                    if(String.isNotBlank(clientVendorMatch.IMS_Total_Clients__c))
                        clientVendorMatch.IMS_Total_Clients__c = clientVendorMatch.IMS_Total_Clients__c + '; ' + acc.name + '"' + acc.id + '"';
                    else
                        clientVendorMatch.IMS_Total_Clients__c = acc.name + '"' + acc.id + '"';

                    if(usaPossibleNames.contains(acc.Country__c) && acc.Is_TPA_Account__c == true) {
                        if(String.isNotBlank(clientVendorMatch.IMS_Client_Names__c))
                            clientVendorMatch.IMS_Client_Names__c = clientVendorMatch.IMS_Client_Names__c + '; ' + acc.name + '"' + acc.id + '"';
                        else
                            clientVendorMatch.IMS_Client_Names__c = acc.name + '"' + acc.id + '"';

                    }

                }
            }
        }

    }


    public String getTruncatedName(String ClientName) {
        Boolean Matched = false;
        truncatedName = ClientName;
        if(Matched == false) {
            for(String truncatedCharacters: charactersToBeTruncated) {

                if(truncatedName.endsWithIgnoreCase(truncatedCharacters)) {
                    truncatedName = truncatedName.removeEndIgnoreCase(truncatedCharacters).trim();
                    truncatedName = truncatedName.removeEnd(',');
                    system.debug('truncated name middle ' + truncatedName);
                    getTruncatedName(truncatedName);
                    Matched = true;
                }

            }
        }
        system.debug('truncated name end' + truncatedName);
        return truncatedName;
    }



    global void finish(Database.BatchableContext BC) {
        //Deleting the existing AMA Client Vendor matching extracts
        List<TPA_AMA_Client_Vendor_Match__c> amaClientVendorMatchingDeletedRecords = [select id from TPA_AMA_Client_Vendor_Match__c where IsDeleted = true ALL ROWS];
        if(amaClientVendorMatchingDeletedRecords.size()>0) {
            DataBase.emptyRecycleBin(amaClientVendorMatchingDeletedRecords);
        }

        List<TPA_AMA_Client_Vendor_Match__c> listToInsert = new List<TPA_AMA_Client_Vendor_Match__c>();


        listToInsert = ClientWithTruncatedName.values();

        for(TPA_AMA_Client_Vendor_Match__c matchObj: listToInsert) {

            List<String> matchAccountsList = new List<String>();
            List<String> mappedAccounts = new List<String>();
            if(String.isNotBlank(matchObj.IMS_Client_Names__c)) {
                matchAccountsList = matchObj.IMS_Client_Names__c.split('; ');
            }

            if(matchAccountsList.size() == 1) {
                mappedAccounts = matchAccountsList.get(0).split('"');
                if(mappedAccounts.size() >= 2) {
                    matchObj.Mapped_Account_Name__c = mappedAccounts.get(0);
                    matchObj.Mapped_Account_Id__c = mappedAccounts.get(1);
                }
            }
        }

        Set<TPA_AMA_Client_Vendor_Match__c> myset = new Set<TPA_AMA_Client_Vendor_Match__c>();
        List<TPA_AMA_Client_Vendor_Match__c> result = new List<TPA_AMA_Client_Vendor_Match__c>();
        myset.addAll(listToInsert);
        result.addAll(myset);
        Schema.SObjectField extrnalField = TPA_AMA_Client_Vendor_Match__c.Fields.Client_Name__c;
        DataBase.upsert(result, extrnalField, false);

        sendMailforNewClientsAndVendor();


    }

    public void sendMailforNewClientsAndVendor() {
        List<Messaging.SingleEmailMessage>mails = new List<Messaging.SingleEmailMessage>();

        // Step 1: Create a new Email
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

        // Step 2: Set list of people who should get the email
        List<TPA_AMA_Settings__c> amaSetting =  TPA_AMA_Settings__c.getall().values();

        // Step 3: Set who the email is sent from
        List<String> sendTo = new List<String>();
        if(amaSetting != null && amaSetting.size() > 0 && amaSetting.get(0).Dev_Mail_ID_For_Internal_Mails__c != null) {
            sendTo = amaSetting.get(0).Dev_Mail_ID_For_Internal_Mails__c.split(';');
            mail.setToAddresses(sendTo);
        }

        // Step 4. Set email contents - you can use variables!
        mail.setSubject('AMA Client/Vendor Matching extracts updated');
        String body = 'Dear AMA Developer,<br/><br/>';
        body += 'AMA Client/Vendor Matching extracts updated based on new AMA Contract Details file recently uploaded.<br/><br/>';
        body += '<b>Note:-</b> Please observe the matching extracts and send to Vijay if required.<br/><br/>';
        body += 'Thanks.<br/>';
        body += 'Salesforce.<br/>';
        body += 'Submitted by ' + UserInfo.getUserName() + '.<br/>';
        mail.setHtmlBody(body);

        // Step 5. Add your email to the master list
        mails.add(mail);
        
        if(!Test.isRunningTest()) {
            Messaging.sendEmail(mails);
        }
    }

}