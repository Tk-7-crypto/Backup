public class Utility_CLM_Flow {
    @InvocableMethod(label = 'Convert List to String')
    /* This method converts a list to a colan separated string */
    public static List<String> convertToString(List<String> pickVal) {
        String strRes = pickVal[0].replace('\r\n',';');
        return new List<String>{strRes};     
    }
}