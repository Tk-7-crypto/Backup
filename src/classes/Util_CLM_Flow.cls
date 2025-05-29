public class Util_CLM_Flow {
    @InvocableMethod(label = 'Convert String to List')
    public static List<String> convertToList(List<String> pickVal) {
        String strRes = pickVal[0].replace(';', '\r\n');
        return new List<String>{strRes};     
    }
}