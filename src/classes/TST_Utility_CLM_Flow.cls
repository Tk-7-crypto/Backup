@isTest
public class TST_Utility_CLM_Flow {
    @isTest
    private static void testConvertToString() {
        List<String> result = Utility_CLM_Flow.convertToString(new List<String>{'A\r\nB\r\nC'});
        System.assertEquals('A;B;C', result[0], 'List is not converted');
    }
}