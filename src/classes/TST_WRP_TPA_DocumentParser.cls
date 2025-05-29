@isTest(SeeAllData=false)
public with sharing class TST_WRP_TPA_DocumentParser {
    @isTest
    public static void testWrapper(){
        WRP_TPA_DocumentParser obj = new WRP_TPA_DocumentParser();
        obj.envelopeId = '';
        obj.envelopeDocuments = new List<WRP_TPA_DocumentProperties>();
    }
}