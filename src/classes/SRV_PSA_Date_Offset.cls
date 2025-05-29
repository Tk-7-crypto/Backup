public class SRV_PSA_Date_Offset {

    /**
     * Method applies date offsets to a collection of objects
     * Returns a list of those that it modified
     * @params List<SObject> objects
     * @return List<SObject>
     */
    public static List<SObject> applyDateOffsets(List<SObject> objects){
        //NOTE TO FUTURE SELF: Schema.getGlobalDescript...getMap().keySet() returns a **lowercase** set of fields

        //Check for program, otherwise grab generic
        Schema.SObjectType objectType = objects.getSObjectType();
        Set<String> targetObjectFields = Schema.getGlobalDescribe().get(String.valueOf(objectType)).getDescribe().fields.getMap().keySet();
        List<PSA_Date_Offset__c> dateOffsets;

        Set<Id> programIds = new Set<Id>();
        if( targetObjectFields.contains( 'program__c' ) ) {
            for( SObject obj : objects ) {
                if( obj.get('program__c') != null ){
                    programIds.add( (Id)obj.get('program__c') );
                }
            }
        } 

        dateOffsets = fetchDateOffsets( objectType, programIds );

        //Validate Type fields and Source Date Fields once, just in case the data isn't clean
        List<PSA_Date_Offset__c> filteredOffsets = new List<PSA_Date_Offset__c>();
        for ( PSA_Date_Offset__c offset : dateOffsets ){
            if( targetObjectFields.contains( offset.Type_Field__c.toLowerCase() ) && 
                targetObjectFields.contains( offset.Source_Date_Field__c.toLowerCase() ) &&
                targetObjectFields.contains( offset.Target_Date_Field__c.toLowerCase() ) ) {
                filteredOffsets.add( offset );
            } else {
                System.debug('Found incompatible date offset: '+offset);
            }
        }
        
        List<SObject> modified = new List<SObject>();
        for( SObject obj : objects ){
            for( PSA_Date_Offset__c offset : filteredOffsets ){
                if( (programIds.size() == 0 || obj.get('program__c') == offset.Program__c) &&
                    obj.get( offset.Type_Field__c ) == offset.Type_Value__c &&
                    obj.get( offset.Source_Date_Field__c ) != null &&
                    obj.get( offset.Target_Date_Field__c ) == null ) {
                        obj.put( offset.Target_Date_Field__c, addOffset( (Date)obj.get( offset.Source_Date_Field__c ), offset) ); 
                        modified.add(obj);
                }
            }
        }
        return modified;
    }

    /**
     * Returns a date that has been offset based on the PSA Date Offset 
     * @params Date source
     * @params PSA_Date_Offset__c
     * @return Date 
     */
    private static Date addOffset(Date source, PSA_Date_Offset__c offset){
        Date targetDate = null;
        if( offset.Unit_Type__c == 'Weekday'){
            targetDate = UTL_PSA.calculateEndDate(source, offset.Offset__c.intValue());
        } else if( offset.Unit_Type__c == 'Months'){
            targetDate = source.addMonths(offset.Offset__c.intValue());
        } else if( offset.Unit_Type__c == 'Years'){
            targetDate = source.addYears(offset.Offset__c.intValue());
        } else {
            return source;
        }

        return targetDate;
    }

    /**
     * Method to fetch date offsets for a non-program object
     * @params Schema.SObjectType objectType
     * @return List<PSA_Date_Offset__c>
     */
    public static List<PSA_Date_Offset__c> fetchDateOffsets( Schema.SObjectType objectType ){
        return fetchDateOffsets( objectType, new Set<Id>() );
    }

    /**
     * Method to fetch date offsets, including if they have a program set on them
     * @params Schema.SObjectType objectType
     * @params Set<Id> programIds
     * @return List<PSA_Date_Offset__c>
     */
    public static List<PSA_Date_Offset__c> fetchDateOffsets( Schema.SObjectType objectType, Set<Id> programIds ){
        System.Debug('Fetching offsets for programs: '+programIds);
        Set<String> offsetFields = new Set<String>();
        for( Schema.SObjectField field : new SLT_Date_Offset().getSObjectFieldList() ){
            offsetFields.add( String.valueOf(field));
        } 
        if( programIds.size() > 0 ){
            return new SLT_Date_Offset().getDateOffsetByObjectAndProgram(new Set<String>{ String.valueOf(objectType) }, offsetFields, programIds );
        }
        return new SLT_Date_Offset().getDateOffsetByObject(new Set<String>{ String.valueOf(objectType) }, offsetFields );
    }

    public class DateOffsetException extends Exception {}
}