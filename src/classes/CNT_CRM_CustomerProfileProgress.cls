/*
 * Author: Kimberly Small
 * Description: Apex Controller for Customer Profile lightning component.
 */
public class CNT_CRM_CustomerProfileProgress {
    private static Decimal maxDataQualityScore = 0;
    private static Decimal dataQualityScore = 0;

    /*
    * This method is used to retrieve the data quality score for the record
    * @param String recordId
    * @param String cmpObject
    * @return Map<String,Decimal>
    */
    @AuraEnabled
    public static Map<String,Decimal> getScores(Id recordId, String cmpObject){
        String queryFields = 'Id';
        
        Set<String> cProfileFields = Customer_Profile__c.getAll().keySet();
        Set<String> objectFields = new Set<String>();

        for(String field : cProfileFields) {
            Customer_Profile__c cProfile = Customer_Profile__c.getInstance(field);
            Boolean isAccField = cProfile.Account__c;
            Boolean isConField = cProfile.Contact__c;

            if(cmpObject == 'Account' && isAccField){
                queryFields = queryFields + ', ' +  field;
                objectFields.add(field);
            }
            else if(cmpObject == 'Contact' && isConField){
                queryFields = queryFields + ', ' +  field;
                objectFields.add(field);
            }
        }

        List<sObject> obj = Database.query('SELECT ' + queryFields + ' FROM ' + cmpObject + ' WHERE Id = :recordId LIMIT 1');
        
        for(String field : objectFields){
            Object fieldValue = obj[0].get(field);
            Customer_Profile__c cProfile = Customer_Profile__c.getInstance(field);
            incrementScores(field, cProfile, fieldValue, cmpObject);
        }
        
        Decimal dataQualityPercentage = calculateScorePercentage(maxDataQualityScore, dataQualityScore);
        
        // Using a map so we can pull in additional scores in the future
        Map<String,Decimal> scores = new Map<String,Decimal>();
        
        scores.put('Data Quality Score', dataQualityPercentage);
        
        return scores;
    }
    
    /*
    * This method is used to increment the Data Quality score based on weights defined 
    * in the Customer Profile custom settings. If the field is populated, the Data Quality
    * score should increase.
    * @param String field
    * @param Customer_Profile__c cProfile
    * @param Object fieldValue
    * @param String cmpObject
    */
    private static void incrementScores(String field, Customer_Profile__c cProfile, Object fieldValue, String cmpObject){
        Decimal fieldWeight;
        
        if(cmpObject == 'Account'){
            fieldWeight = cProfile.Account_Weight__c;
        }
        else if(cmpObject == 'Contact'){
            fieldWeight = cProfile.Contact_Weight__c;
        }
        
        maxDataQualityScore += fieldWeight;
        if(fieldValue != Null){
            dataQualityScore += fieldWeight;
        }
    }
    
    /*
    * This method is used to calculate the desired score percentage.
    * @param Decimal maxScore
    * @param Decimal actualScore
    * @return Decimal
    */
    private static Decimal calculateScorePercentage(Decimal maxScore, Decimal actualScore){
        Decimal scorePercentage = 0;
        if(maxScore != 0){
            scorePercentage = (actualScore / maxScore) * 100;
        }
        return scorePercentage.round(System.RoundingMode.HALF_UP);
    }
}