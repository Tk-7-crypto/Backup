@isTest
private class TST_CLS_ProductionReference {
    public static testmethod void t1()
    {
        Test.startTest();
            CLS_ProductionReference Convertor = new CLS_ProductionReference();
            Integer iTest = Convertor.CalculateElapsedMinsThisYear();
            system.debug('Mins this year: '+ iTest.format());
            String sOutput = Convertor.ConvertToRadix34(364883);
            system.debug('Output: '+ sOutput);
            system.assertEquals('AAMV',sOutput);
        Test.stopTest();
    }
    
}