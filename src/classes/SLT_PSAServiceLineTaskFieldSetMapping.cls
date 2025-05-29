/*
 * Version       : 1.0
 * Description   : This Apex class is selector layer for the PSA Service Line Task Field Set Mapping Metadata Type.
 */
public class SLT_PSAServiceLineTaskFieldSetMapping extends fflib_SObjectSelector {

    /**
     * This method used to set field list of AccountCountryRegionMapping metadata.
     */
    public Set<String> fieldSet{
        get{
            fieldSet = new Set<String>();
            fieldSet.add('Field_Set_Name__c');
            fieldSet.add('Field_Set_Type__c');
            fieldSet.add('Service_Line_Code__c');
            fieldSet.add('Service_Code__c');
            fieldSet.add('Form_Section__c');
            return fieldSet;
        }
        set {
              fieldSet = value;
        }
    }

    /**
     * This method used to get field list of sobject
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>();
    }

    /**
     * This method used to set up type of sobject
     * @return  Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return PSA_Service_Line_Task_Field_Set_Mapping__mdt.sObjectType;
    }

    /**
    * Method to get FieldSet mappings by Service Code or Service Line Code
    * @return List<PSA_Service_Line_Task_Field_Set_Mapping__mdt>
    */
    public List<PSA_Service_Line_Task_Field_Set_Mapping__mdt> getFieldSetMappingsByCode(String serviceCode){
        return getFieldSetMappingsByCode(serviceCode, null);
    }

    /**
    * Method to get FieldSet mappings by Service Code or Service Line Code
    * @return List<PSA_Service_Line_Task_Field_Set_Mapping__mdt>
    */
    public List<PSA_Service_Line_Task_Field_Set_Mapping__mdt> getFieldSetMappingsByCode(String serviceCode, String serviceLineCode){
        List<PSA_Service_Line_Task_Field_Set_Mapping__mdt> mergedMappings = new List<PSA_Service_Line_Task_Field_Set_Mapping__mdt>();
        List<PSA_Service_Line_Task_Field_Set_Mapping__mdt> serviceCodeMappings = getFieldSetMappingsByServiceCode(serviceCode);
        List<PSA_Service_Line_Task_Field_Set_Mapping__mdt> serviceLineCodeMappings = getFieldSetMappingsByServiceLineCode(serviceLineCode);
        mergedMappings.addAll(serviceCodeMappings);
        // as their should be no field for service code SM1, SM5, SM6
        if(serviceCode == 'SM1' || serviceCode == 'SM5' || serviceCode == 'SM6'){
            
        }
        else{
            mergedMappings.addAll(serviceLineCodeMappings);
        }
        return mergedMappings;
    }

    /**
    * Method to get FieldSet mappings by Service Code
    * @return List<PSA_Service_Line_Task_Field_Set_Mapping__mdt>
    */
    public List<PSA_Service_Line_Task_Field_Set_Mapping__mdt> getFieldSetMappingsByServiceCode(String serviceCode){
        system.debug('SLT_PSAServiceLineTaskFieldSetMapping getting mapping for service code: '+serviceCode);
        return (List<PSA_Service_Line_Task_Field_Set_Mapping__mdt>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Service_Code__c = :serviceCode AND Field_Set_Type__c = \'Deliverable\' AND Form_Section__c = \'Service Line\'').toSOQL());
    }

    /**
    * Method to get FieldSet mappings by Service Line Code
    * @return List<PSA_Service_Line_Task_Field_Set_Mapping__mdt>
    */
    public List<PSA_Service_Line_Task_Field_Set_Mapping__mdt> getFieldSetMappingsByServiceLineCode(String serviceLineCode){
        system.debug('SLT_PSAServiceLineTaskFieldSetMapping getting mapping for service line code: '+serviceLineCode);
        return (List<PSA_Service_Line_Task_Field_Set_Mapping__mdt>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Service_Line_Code__c = :serviceLineCode  AND Field_Set_Type__c = \'Deliverable\' AND Form_Section__c = \'Service Line\'').toSOQL());
    }

    /**
    * Method to get Task FieldSet mappings by any combination of parameters (type is required)
    * @return List<PSA_Service_Line_Task_Field_Set_Mapping__mdt>
    */
    public List<PSA_Service_Line_Task_Field_Set_Mapping__mdt> getTaskFieldSetMappings(String type, String serviceCode, String serviceLineCode, String formSection){
        Set<String> formSections;
        if(!String.isBlank(formSection)){
            formSections = new Set<String>{formSection};
        }
        return getTaskFieldSetMappings(type, serviceCode, serviceLineCode, formSections);
    }

    /**
    * Method to get Task FieldSet mappings by any combination of parameters (type is required)
    * and optional set of form funcitons!
    *
    *  getTaskFieldSetMappings('Task', null, 'PVA', new Set<String>{'General', 'Columns'});
    *
    * @return List<PSA_Service_Line_Task_Field_Set_Mapping__mdt>
    */
    public List<PSA_Service_Line_Task_Field_Set_Mapping__mdt> getTaskFieldSetMappings(String type, String serviceCode, String serviceLineCode, Set<String> formSections){
        System.debug('type: '+type+' serviceCode: '+serviceCode+' serviceLineCode: '+serviceLineCode+' formSections: '+formSections);

        List<PSA_Service_Line_Task_Field_Set_Mapping__mdt> mappings;
        //If we get both service code and service line code, we try service code first
        //If that fails, we will get Service Line
        if(!String.isBlank(serviceCode) && !String.isBlank(serviceLineCode)){
            System.debug('Looking for service mappings first');
            mappings = getTaskFieldSetMappings(type, serviceCode, null, formSections);
            if(mappings.size() > 0){
                System.debug('Found service mappings');
                return mappings;
            }
            System.debug('Found no service mappings, looking for service line mappings');
            return getTaskFieldSetMappings(type, null, serviceLineCode, formSections);
        }


        String condition = 'Field_Set_Type__c = :type';
        if(!String.isBlank(serviceCode)){
            condition += ' AND Service_Code__c = :serviceCode';
        }
        else if(!String.isBlank(serviceLineCode)){
            condition += ' AND Service_Line_Code__c = :serviceLineCode';
        } else {
            condition += ' AND Service_Line_Code__c = null AND Service_Code__c = null';
        }
        condition += (formSections != null && !formSections.isEmpty()) ? ' AND Form_Section__c in :formSections' : ' AND Form_Section__c = \'Service Line\'';
        System.debug('getTaskFieldSetMappings condition: '+condition);
        
        return (List<PSA_Service_Line_Task_Field_Set_Mapping__mdt>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition(condition).toSOQL());
    }
} 
