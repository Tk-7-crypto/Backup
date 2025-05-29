public with sharing class CNT_CDA_LookupReportComnt {

    @AuraEnabled
    public static String getSystemDownMessage() {
        String downTimeMessage = '';
        List<CDA_Language_Cross_Walk__c> lstCrossWalk = [Select Id, Default_Value__c from CDA_Language_Cross_Walk__c where Control_Type__c = 'DownTimeMessage'];
        if(lstCrossWalk != null && lstCrossWalk.size() > 0) {
            downTimeMessage = lstCrossWalk[0].Default_Value__c;
        }
        return downTimeMessage;
    }

    public enum DownTimeStatus {
        PD, //Permanent Down
        TM, //Temporary Message
        PL //Portal is Live
    }

    @AuraEnabled
    public static String isSystemDown() {
        CDA_Settings__c cdaSettObj = CDA_Settings__c.getOrgDefaults();
        if(cdaSettObj.Is_CDA_System_Down__c) {
            return DownTimeStatus.PD.Name();
        }
        else if(cdaSettObj.Is_Show_CDA_System_Down_Msg__c) {
            return DownTimeStatus.TM.Name();
        }
        else {
            return DownTimeStatus.PL.Name();
        }
    }

    @AuraEnabled
    public static Boolean isCurrentUserAllowedOnSystemDown() {
        if(Label.CDA_Allow_System_Down_Access_To != null) {
            Id loggedInUser = UserInfo.getUserId();
            for(Id userId: Label.CDA_Allow_System_Down_Access_To.split(',')) {
                if(userId == loggedInUser) {
                    return true;
                }
            }
        }
        return false;
    }

    @AuraEnabled
    public static List<CDA_Request__c> getCDARequests(String pageNumber, String currnetPagesCount, String sortField, String sortDirection, Map<String, String> searchMap, Boolean isNegotiatorTab) {
        String fieldStr = UTL_CDAUtility.getObjectFieldStr('CDA_Request__c');
        if(UTL_CDAUtility.getRelationObjectFieldStr('QI_Legal_Entity__c', 'QI_Legal_Entity_Name__c') != null) {
            fieldStr += ',' + UTL_CDAUtility.getRelationObjectFieldStr('QI_Legal_Entity__c', 'QI_Legal_Entity_Name__c');
        }
        
        if(UTL_CDAUtility.getRelationObjectFieldStr('CDA_Approved_Governing_Law_Location__c', 'Location_of_Governing_Law__c') != null) {
            fieldStr += ',' + UTL_CDAUtility.getRelationObjectFieldStr('CDA_Approved_Governing_Law_Location__c', 'Location_of_Governing_Law__c');
        }
        
        // fieldStr += ',(Select id, name, description, CreatedDate from Attachments order by createdDate desc)'; // to fetch attchement record releated to the request
        
        fieldStr += ', Owner.Name, Owner.Email, CreatedBy.Name'; // to fetch record owner detail        
        
        String query = 'SELECT ' + fieldStr + ' FROM CDA_Request__c WHERE RecordType.Name != \'' + UTL_CDAUtility.historicalDataRecordType + '\'';

        system.debug('In CNT_CDA_LookupReportComnt: searchMap: ' + searchMap);
        query = SRV_CDA_CDARequest.setQueryCondition(query, searchMap, isNegotiatorTab);
        // query += ' ORDER BY ' + sortField + ' ' + sortDirection + ' LIMIT ' + currnetPagesCount + ' OFFSET ';
        query += ' ORDER BY ' + sortField + ' ' + sortDirection ;
        if(!String.isBlank(currnetPagesCount) && Integer.valueOf(currnetPagesCount) > 0) {
            query += ' LIMIT ' + currnetPagesCount;
        }
        if(String.isBlank(pageNumber) || Integer.valueOf(pageNumber) == 1) {
            query += ' OFFSET 0';
        }
        else {
            query += ' OFFSET '+ String.valueOf( (Integer.valueOf(pageNumber) - 1) * Integer.valueOf(currnetPagesCount));
        }
        system.debug('In CNT_CDA_LookupReportComnt: query: ' + query);
        return Database.query(query);
    }

    @AuraEnabled
    public static UTL_CDA_PaginationWrapper getPageCountInfo(String pageCountInfo, Map<String, String> searchMap, Boolean isNegotiatorTab) {

        String query = 'SELECT COUNT() FROM CDA_Request__c ';
        query += ' WHERE RecordType.Name != \'' + UTL_CDAUtility.historicalDataRecordType + '\'';

        query = SRV_CDA_CDARequest.setQueryCondition(query, searchMap, isNegotiatorTab);
        system.debug('isNegotiatorTab: ' + isNegotiatorTab);
        system.debug('In CNT_CDA_LookupReportComnt: getPageCountInfo: query: ' + query);


        Integer currentListCount = (pageCountInfo != null && pageCountInfo != '') ? Integer.valueOf(pageCountInfo) : 10 ;

        UTL_CDA_PaginationWrapper pgn = new UTL_CDA_PaginationWrapper();
        pgn.totalRecords = Database.countQuery(query);
        pgn.totalPages = (pgn.totalRecords/currentListCount)+1;
        pgn.currentPageNumber = 1;
        List<Integer> cnt = new List<Integer>();
        for(Integer loop_var = 0; loop_var < pgn.totalPages; loop_var++){
            cnt.add(loop_var+1);
            if((loop_var+1) == 4)
                break;
        }
        if(pgn.totalPages > 4)
            cnt.add(pgn.totalPages);
        pgn.pageCounter = cnt;

        return pgn;
    }

    /*
    *  When page count change or next or previous button is clicked
    *  provide footer with new set of page counter info
    *  to display
    * */

    @AuraEnabled
    public static UTL_CDA_PaginationWrapper getPageCountChange(String pageNumber, String currnetPagesCount, String totalPages, String totalRecords) {
        system.debug('In getPageCountChange: pageNumber: ' + pageNumber);
        system.debug('In getPageCountChange: currnetPagesCount: ' + currnetPagesCount);
        system.debug('In getPageCountChange: totalPages: ' + totalPages);
        system.debug('In getPageCountChange: totalRecords: ' + totalRecords);
        UTL_CDA_PaginationWrapper pgn = new UTL_CDA_PaginationWrapper();
        pgn.currentPageNumber = Integer.valueOf(pageNumber);
        pgn.totalPages = Integer.valueOf(totalPages);
        pgn.totalRecords = Integer.valueOf(totalRecords);

        List<Integer> cnt = new List<Integer>();

        if((Integer.valueOf(pageNumber)+2) < Integer.valueOf(totalPages) && Integer.valueOf(pageNumber) != 1) {
            system.debug('In getPageCountChange: Condition1: ');
            for(Integer loop_var = (Integer.valueOf(pageNumber)-1); loop_var < (Integer.valueOf(pageNumber)+3); loop_var++){
                cnt.add(loop_var);
            }
            cnt.add(pgn.totalPages);

        } else if(Integer.valueOf(pageNumber) == 1) {
            system.debug('In getPageCountChange: Condition2: ');
            for(Integer loop_var = 1; loop_var < 5; loop_var++) {
                if(loop_var == pgn.totalPages) {
                    break;
                }
                cnt.add(loop_var);
            }
            cnt.add(pgn.totalPages);
        } else {
            if(Integer.valueOf(currnetPagesCount) >= pgn.totalPages) {
                system.debug('In getPageCountChange: Condition3: ');
                for(Integer loop_var = 1;loop_var < (pgn.totalPages+1);loop_var++) {
                    cnt.add(loop_var);
                }
            } else {
                system.debug('In getPageCountChange: Condition4: ');
                for(Integer loop_var = (pgn.totalPages-4); loop_var < (pgn.totalPages+1); loop_var++) {
                    cnt.add(loop_var);
                }
            }
        }
        pgn.pageCounter = cnt;

        return pgn;
    }

    @AuraEnabled
    public static Map<String, List<String>> getDependentOptionsImpl(string objApiName, string contrfieldApiName, string depfieldApiName) {
        Map<String, List<String>> objResults = UTL_CDA_BitSet.getDependentOptions(objApiName, contrfieldApiName, depfieldApiName);
        return objResults;
    }
}