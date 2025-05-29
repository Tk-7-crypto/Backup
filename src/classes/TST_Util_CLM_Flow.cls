@isTest
public class TST_Util_CLM_Flow {
    @isTest
    private static void testConvertToList() {
        List<String> result = Util_CLM_Flow.convertToList(new List<String>{'A;B;C'});
        System.assertEquals('A\r\nB\r\nC', result[0], 'String is not converted');
    }
}