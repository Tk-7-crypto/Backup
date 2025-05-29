/*
 * Author: Kimberly Small
 * Description: Apex Controller for Level Up lightning component.
 */
public class CNT_CRM_LevelUp {
    
    /*
    * This method is used to retrieve the level progression for the record
    * @param Id recordId
    * @param String cmpObject
    * @param String maxLevel
    * @return List<Map<String,Object>>
    */
    @AuraEnabled
    public static List<Map<String,Object>> getLevelProgression(Id recordId, String cmpObject, Integer maxLevel){
        List<Map<String,Object>> fields = new List<Map<String,Object>>();
        Set<String> levelUpFields = Level_Up__c.getAll().keySet();
        Set<String> objectFields = new Set<String>();
        String queryFields = 'Id';

        // Get the correct fields for selected object
        for(String field : levelUpFields) {
            Level_Up__c levelUp = Level_Up__c.getInstance(field);
            Boolean isAccField = levelUp.Account__c;
            Boolean isConField = levelUp.Contact__c;

            if(cmpObject == 'Account' && isAccField){
                queryFields = queryFields + ', ' +  field;
                objectFields.add(field);
            }
            else if(cmpObject == 'Contact' && isConField){
                queryFields = queryFields + ', ' +  field;
                objectFields.add(field);
            }
        }

        List<sObject> records = Database.query('SELECT ' + queryFields + ' FROM ' + cmpObject + ' WHERE Id = :recordId LIMIT 1');

        // Get the level and field completion for each field  queried from the current record
        for(String field : objectFields){
            Map<String, Object> fieldCompletetion = new Map<String, Object>();
            Boolean completed = false;
            Object fieldValue = records[0].get(field);
            Level_Up__c levelUp = Level_Up__c.getInstance(field);
            Integer fieldLevel;
            if(cmpObject == 'Account'){
                fieldLevel = (Integer)levelUp.Account_Level__c;
            }
            else if(cmpObject == 'Contact'){
               fieldLevel = (Integer)levelUp.Contact_Level__c;
            }

            if(fieldValue != Null){
                completed = true;
            }

            fieldCompletetion.put('Field', field);
            fieldCompletetion.put('Level', fieldLevel);
            fieldCompletetion.put('Completed', completed);

            fields.add(fieldCompletetion);
        }

        List<Map<String,Object>> currentLevelFields = getCurrentLevelFields(fields, maxLevel);
        
        return currentLevelFields;
    }

    /* This method is used to retrieve fields for the current level
    * @param List<Map<String,Object>> fields
    * @param String maxLevel
    * @return List<Map<String,Object>>
    */
    private static List<Map<String,Object>> getCurrentLevelFields(List<Map<String,Object>> fields, Integer maxLevel){
        Boolean levelFieldsComplete = true;
        Boolean finalLevel = false;
        Integer lvl = 1;
        
        do {
            if(fields.size() == 0){
                break;
            }
            for(Map<String,Object> field : fields){
                if(lvl != maxLevel && field.get('Level') == lvl && field.get('Completed') == false){
                    levelFieldsComplete = false;
                    break;
                }
            }
            if(levelFieldsComplete && lvl < maxLevel){
                lvl += 1;
            }
            else if(lvl == maxLevel){
                finalLevel = true;
            }
        } while (levelFieldsComplete && !finalLevel);

        List<Map<String,Object>> currentLevelFields = new List<Map<String,Object>>();
        for(Map<String,Object> field : fields){
            if(finalLevel){
                // Add a map for the completion level
                Map<String, Object> fieldCompletetion = new Map<String, Object>();
                fieldCompletetion.put('Level', maxLevel);
                currentLevelFields.add(fieldCompletetion);
            }
            else if(field.get('Level') == lvl){
                currentLevelFields.add(field);
            }
        }
        
        return currentLevelFields;
    }
}