/**
 * Controller for related list preview
 *
 * ----------------------------------------------------------------------------
 * Date Modified    Modified By             Description of the update
 * ----------------------------------------------------------------------------
 * 29-Apr-2020      CLD                     Created
 */
public with sharing class CNT_PSA_relatedListWithPreview {
  public CNT_PSA_relatedListWithPreview() {
  }

  // AuraResult items constants
  public static final String PARAM_DATATABLE_COLUMNS = 'datatableColumns';
  public static final String PARAM_PREVIEW_FIELDS =  'previewFields';
  public static final String PARAM_GENERAL_FIELDS =  'generalFields'; // item name for fieldsForNewRecordEdit?
  public static final String PARAM_NEW_RECORD_TYPE_NAME = 'newRecordTypeName'; // key for the result item containing the record type name to use for new recrods?
  public static final String PARAM_NEW_RECORD_TYPE_ID = 'newRecordTypeId'; // key for the result item containing the record type name to use for new recrods?
  public static final String PARAM_PROJECT_TASK = 'projectTask'; // key for the project task (parent of our related children)
  public static final String PARAM_PROJECT_TASK_API_NAME = 'projectTaskAPIName'; // key for the project task api name
  public static final String PARAM_SERVICE_CODE = 'serviceCode'; // key for the service code

  // constant field / object api names
  public static final String PARENT_TASK_FIELD_NAME = 'pse__Parent_Task__c' ;
  public static final String PROJECT_TASK_SOBJECT_NAME = 'pse__Project_Task__c';

  // Label and field name  for datatable column linking to record
  public static final String DATATABLE_RECORD_HREF_LABEL = 'Project Task Name';
  public static final String DATATABLE_RECORD_HREF_FIELD = 'Name';

  // Data Type constants
  public static final String DT_DATETIME = 'datetime';
  public static final String DT_DATE = 'date';
  public static final String DT_DATE_LOCAL = 'date-local';
  public static final String DT_DOUBLE  =  'double';
  public static final String DT_DECIMAL = 'decimal';
  public static final String DT_NUMBER = 'number';
  public static final String DT_REFERENCE =  'reference';
  public static final String DT_URL = 'url';

  // Type Attribute constants
  public static final String TA_LABEL = 'label';
  public static final String TA_FIELD_NAME = 'fieldName';

  // PSA_Service_Line_Task_Field_Set_Mapping__mdt form section
  public static final String FLD_SET_MAP_FORM_SECTION_GENERAL = 'General';
  public static final String FLD_SET_MAP_FORM_SECTION_COLUMNS = 'Columns';

  /**
   * List of fields to initially grab from project task services
   */
  private static final Set<String> PROJECT_TASK_SVC_LINE_FIELDS = new Set<String>{
    'Id', 'Service_Line__c', 'Service_Line__r.Service_Line_Code__c',
    'Service_Code__c', 'pse__Milestone__c', 'pse__Milestone__r.Name',
    'pse__Project__c', 'pse__Project__r.Name'
  };

  // public static final String BLANK_FIELD =  'BlankField';

  /**
   * List of fields to use when creating new records in UI
   * (note: should  be a subset of PROJECT_TASK_SVC_LINE_FIELDS )
   */
  private static final Set<String> PROJECT_TASK_NEW_GENERAL_FIELDS = new Set<String>{
    'Name', 'RecordTypeId', 'pse__Parent_Task__c', 'Service_Line__c', 'pse__Project__c', 'pse__Milestone__c'
  };

  //  Default FieldSets for the rendered preivew fields and  datatable columns
  public static final String DEFAULT_PREVIEW_FIELDSET = 'PSA_RDS_Task_General';
  public static final String DEFAULT_COLUMN_FIELDSET = 'PSA_RDS_Task_Columns';

  // Default Record Type name and id for  use in generating new records!
  public static final String RECORDTYPENAME_PROJECT_TASK_RDSDELIVERABLETASK = 'RDS Deliverable Task';
  public static final Id RECORDTYPEID_PROJECT_TASK_RDSDELIVERABLETASK = Schema.SObjectType.pse__Project_Task__c.getRecordTypeInfosByName().get(RECORDTYPENAME_PROJECT_TASK_RDSDELIVERABLETASK).getRecordTypeId();

  /**
   * Retrieves preview datatable columns and fields to render based on the supplied
   * project task record id
   *
   * @param {Id} - representing the  project task record id
   * @return AuraResult containiing the fields, datatable columns, and records to render
   */
  @AuraEnabled(cacheable=true)
  public static AuraResult getProjectTaskPreviewItems (Id recordId) {
    AuraResult auraResult = new AuraResult();

    // lookup the underlying project task and service line code to refine the preview and datatable column fieldsets to render
    Map<Id,pse__Project_Task__c> idToProjectTask = new SLT_Project_Task().getProjectTaskById(new Set<Id> {recordId}, PROJECT_TASK_SVC_LINE_FIELDS );
    pse__Project_Task__c ptask =  idToProjectTask.get(recordId);
    String serviceLineCode = ptask.Service_Line__r.Service_Line_Code__c;
    String serviceCode = ptask.Service_Code__c;

    // Default FieldSets for columns and preview fields!
    String previewFieldName = DEFAULT_PREVIEW_FIELDSET;
    String dbcolumnFieldSetName = DEFAULT_COLUMN_FIELDSET;

    // Overwrite our preview and db columns field sets based on form sections by service line codes!
    Map<String, PSA_Service_Line_Task_Field_Set_Mapping__mdt> svcMappings = lookupMappings(serviceLineCode);
    PSA_Service_Line_Task_Field_Set_Mapping__mdt svcLineColumns = svcMappings.get(FLD_SET_MAP_FORM_SECTION_COLUMNS);
    PSA_Service_Line_Task_Field_Set_Mapping__mdt svcLineGeneral = svcMappings.get(FLD_SET_MAP_FORM_SECTION_GENERAL);
    if (svcLineColumns != null && String.isNotEmpty(svcLineColumns.Field_Set_Name__c)) {
      dbcolumnFieldSetName =  svcLineColumns.Field_Set_Name__c;
    }
    if (svcLineGeneral != null && String.isNotEmpty(svcLineGeneral.Field_Set_Name__c)) {
      previewFieldName = svcLineGeneral.Field_Set_Name__c;
    }

    // Use the dbcolumndFieldSetName to build datatable columns to render
    DatatableFieldColumnWrapper dfcw = new DatatableFieldColumnWrapper(PROJECT_TASK_SOBJECT_NAME, dbcolumnFieldSetName, DATATABLE_RECORD_HREF_FIELD, DATATABLE_RECORD_HREF_LABEL);

    // Get fields to preview/edit/create detail section for the specific preview field set
    String[] previewFields = new SLT_Project_Task().getFieldListByFieldSetName(previewFieldName);

// include this to quickly  test add / removing
String reasonForDeletionField = 'Reason_for_Deletion__c';
if (previewFields.indexOf(reasonForDeletionField) < 0) { previewFields.add(reasonForDeletionField); }


    // Fetch the table rows to render based on the datatable columns
    Sobject[] records =  new SLT_SObject().selectSObjectByLookup(dfcw.sobjType, PARENT_TASK_FIELD_NAME, recordId, dfcw.setFieldsToQuery);

    // return result items and records
    auraResult.items.put(PARAM_PROJECT_TASK, ptask);
    auraResult.items.put(PARAM_PROJECT_TASK_API_NAME, PROJECT_TASK_SOBJECT_NAME);
    auraResult.items.put(PARAM_DATATABLE_COLUMNS, dfcw.lstDataColumns); // Inject datatable columns to render
    auraResult.items.put(PARAM_PREVIEW_FIELDS, previewFields); // Inject collection  of fields to use in preview
    auraResult.items.put(PARAM_GENERAL_FIELDS, PROJECT_TASK_NEW_GENERAL_FIELDS);
    auraResult.items.put(PARAM_NEW_RECORD_TYPE_NAME, RECORDTYPENAME_PROJECT_TASK_RDSDELIVERABLETASK);
    auraResult.items.put(PARAM_NEW_RECORD_TYPE_ID, RECORDTYPEID_PROJECT_TASK_RDSDELIVERABLETASK);
    auraResult.items.put(PARAM_SERVICE_CODE, serviceCode);
    auraResult.records = dfcw.datatableRecords(records); // prep records (flatten) for use in lwc datatable
    auraResult.isSuccess = true;

    return auraResult;
  }

  /**
   * Grab fields sets for use based on service line code!
   * And returns results mapped by Form Section
   */
  private static Map<String, PSA_Service_Line_Task_Field_Set_Mapping__mdt> lookupMappings (String serviceLineCode) {
    Map<String, PSA_Service_Line_Task_Field_Set_Mapping__mdt> results = new Map<String, PSA_Service_Line_Task_Field_Set_Mapping__mdt>();
    if (String.isNotEmpty(serviceLineCode)) {
      String type =  'Task';
      String serviceCode=  null;
      Set<String> formSections = new Set<String>{
        FLD_SET_MAP_FORM_SECTION_GENERAL,
        FLD_SET_MAP_FORM_SECTION_COLUMNS
      };

      List<PSA_Service_Line_Task_Field_Set_Mapping__mdt> mappings = new SLT_PSAServiceLineTaskFieldSetMapping().getTaskFieldSetMappings(type, serviceCode, serviceLineCode, formSections);
      for (PSA_Service_Line_Task_Field_Set_Mapping__mdt mpg: mappings) {
        results.put(mpg.Form_Section__c, mpg);
      }
    }
    return results;
  }

  /**
   *  DatatableFieldColumnWrapper
   */
  public class DatatableFieldColumnWrapper {
    public Schema.sObjectType sobjType {get;set;}
    public String sobjTypeName {get;set;}
    public List<DataTableColumns> lstDataColumns {get; set;}
    public Set<String> setFieldsToQuery {get; set;}
    public Set<String> setFieldNamesToEdit {get; set;}

    /**
     * From the name of the fieldset specified on the sobject type, builds DataTableColumns
     * to render in LWC Datatable components and a set of fields to query.  Uses the
     * specified record href field and label to define datatable column to link to the rendered record
     *
     * @param {String} - sObjectType string value for the Schema sobject type
     * @param {String} - strFieldSetName string value for the sobjects fieldset name
     * @param {String} - recordHrefField string value for the api name of the field to use for record href label e.g. ('Name')
     * @param {String} - recordHrefLabel string value for label to render in the record href field
     */
    public DatatableFieldColumnWrapper(String sObjectType, String strFieldSetName, String recordHrefField, String recordHrefLabel) {
      this.sobjTypeName = sObjectType;
      this.sobjType = ((SObject)(Type.forName('Schema.' + sObjectType).newInstance())).getSObjectType();
      DescribeSObjectResult describeSObjectResultObj = sobjType.getDescribe();
      Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get(strFieldSetName);

      //To hold the table hearders
      this.lstDataColumns = new List<DataTableColumns>();

      // @@ inject a 'record_href' column, to be set after data is pulled back
      DataTableColumns recordLinkColumn = new DataTableColumns(recordHrefLabel, 'record_href', 'url');
      recordLinkColumn.typeAttributes.put(TA_LABEL, new Map<String, Object>{TA_FIELD_NAME => recordHrefField});
      lstDataColumns.add(recordLinkColumn);

      //  fields to be edited in preview
      this.setFieldNamesToEdit = new Set<String>();

      // Fields to be queried - fetched from fieldset
      this.setFieldsToQuery = new Set<String>(new String[]{'Id',recordHrefField}); // ensure we have Id, Name/recordHrefField columns
      if (fieldSetObj != null) {
        // Build the datatable columns to render!
        for( Schema.FieldSetMember eachFieldSetMember : fieldSetObj.getFields()) {
            // collect field to preview edit!
            setFieldNamesToEdit.add(String.valueOf(eachFieldSetMember.getFieldPath()));

            String label = String.valueOf(eachFieldSetMember.getLabel());
            String fieldName = String.valueOf(eachFieldSetMember.getFieldPath());
            String dataType = String.valueOf(eachFieldSetMember.getType()).toLowerCase();

            Map<String, Object> typeAttrs = new Map<String, Object>();
            Map<String, Object> cellAttrs = new Map<String, Object>();

            // skip proccessing the recordHrefField / column since we already injected record_href field
            if (fieldName == recordHrefField) {
              continue;
            }

            //This way we can set the type of a column
            //We do not get the exact type from schema object which matches to lightning:datatable component structure
            // # setup lwc datatable column date fields
            if(dataType == DT_DATETIME ||  dataType == DT_DATE) {
                dataType = DT_DATE_LOCAL;

                typeAttrs.put('month', '2-digit');
                typeAttrs.put('day', '2-digit');
            }
            // # define double or decimals as number fields
            if (dataType == DT_DOUBLE || dataType == DT_DECIMAL) {
              dataType = DT_NUMBER;
              // cellAttrs.put('alignment', 'left');
            }
            // # setup reference field set as a lwc datatable url column
            if (dataType == DT_REFERENCE) {
              // # inject reference Name to query for use in our URL datataype!
              String fieldPathName = eachFieldSetMember.getFieldPath().replace('__c', '__r.Name');
              setFieldsToQuery.add(fieldPathName);

              // mark column as a  url and include the related name as the field name to render
              dataType = DT_URL;

              //  define type attribute field name as ('***__r_Name') value is injected when flattening results
              typeAttrs.put(TA_LABEL, new Map<String, Object>{TA_FIELD_NAME => fieldPathName.replace('.', '_')});
            }

            // collect field to query
            setFieldsToQuery.add(String.valueOf(eachFieldSetMember.getFieldPath()));

            // # Build datatable column!
            DataTableColumns datatableColumn = new DataTableColumns(label, fieldName, dataType);
            datatableColumn.typeAttributes = typeAttrs != null ? typeAttrs  : new Map<String, Object>();
            datatableColumn.cellAttributes = cellAttrs != null ? cellAttrs : new Map<String, Object>();

            lstDataColumns.add(datatableColumn);
        }
      }
    }

    /**
     * Prep records for use in LWC Datatable.
     *
     * Flatten array of objects and nested objects into a
     * single array of objects for use in LWC Datatable
     */
      public Object[] datatableRecords(Sobject[] records) {
          List<Object> flattenedResults = new List<Object>();
          List<Object> mobjresults = (List<Object>) JSON.deserializeUntyped(JSON.serialize(records));
          for(Object mobj : mobjresults) {
              if(mobj instanceof Map<String, Object>) {
                  Map<String, Object> flattenedRec = (Map<String, Object>) mobj;
                  String sourceSobjectId = (String) flattenedRec.get('Id');
                  // @@ inject record_href value for injected datatable url field
                  flattenedRec.put('record_href', '/lightning/r/' + this.sobjTypeName + '/' + sourceSobjectId + '/view');
                  
                  // @@ HANDLE REFRENECE / URL FIELDS! by injecting the name into the results!
                  for(DataTableColumns datatableColumn: this.lstDataColumns) {
                      if(datatableColumn.type == DT_URL && datatableColumn.fieldName != null && datatableColumn.fieldName != 'record_href'
                         && (flattenedRec.get(datatableColumn.fieldName.replace('__c', '__r')) != null)
                         && (flattenedRec.get(datatableColumn.fieldName.replace('__c', '__r')) instanceof Map<String, Object>)
                         && ((Map<String, Object>) flattenedRec.get(datatableColumn.fieldName.replace('__c', '__r'))).size() > 0) {
                             String urlRef = datatableColumn.fieldName;
                             String urlRefRefObj = datatableColumn.fieldName.replace('__c', '__r');
                             Map<String, Object> refObj = (Map<String, Object>) flattenedRec.get(urlRefRefObj);
                             Map<String, Object> attrs = (Map<String, Object>) refObj.get('attributes');
                             String refType = (String) attrs.get('type');
                             String refObjId = (String) refObj.get('Id');
                             
                             // inject these fields (***__r_Id) and (***__r_Name) into row!
                             flattenedRec.put(urlRefRefObj + '_Id', refObjId);
                             flattenedRec.put(urlRefRefObj + '_Name', refObj.get('Name'));
                             
                             // inject _href for our links!
                             flattenedRec.put(urlRef, String.isNotEmpty(refType) ? '/lightning/r/'  + refType  + '/'  + refObjId +  '/view' : '/' + refObjId);
                         }
                  }
                  flattenedResults.add(flattenedRec);
              }
          }
          return flattenedResults;
      }
  }

	/**
	 * Represents Datatable Columns to render
	 */
	public class DataTableColumns {
		@AuraEnabled public String label {get;set;}
		@AuraEnabled public String fieldName {get;set;}
		@AuraEnabled public String type {get;set;}
		@AuraEnabled public Boolean sortable {get;set;}
		@AuraEnabled public Map<String, Object> cellAttributes {get;set;}
		@AuraEnabled public Map<String, Object> typeAttributes {get;set;}

    /**
     * Create a datatablecolumn for a label, field api anme, and data type
     */
		public DataTableColumns(String label, String fieldName, String type){
			this.label = label;
			this.fieldName = fieldName;
			this.type = type;
			this.sortable = true;
			this.cellAttributes = new Map<String, Object>();
			this.typeAttributes =  new Map<String, Object>();
		}
	}

	/*
	 * Class returned from @AuraEnabled methods
	 */
	public class AuraResult {
		@AuraEnabled public Object[] records {get;set;}
		@AuraEnabled public Map<String, Object> items {get;set;}
		@AuraEnabled public Boolean isSuccess {get;set;}
		public AuraResult () {
			this.records = new Object[]{};
			this.items = new Map<String, Object>();
		}
	}
}
