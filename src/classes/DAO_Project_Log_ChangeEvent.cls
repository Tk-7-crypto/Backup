/**
 * Project Log Change Event Object Domain / trigger handler
 *
 * ----------------------------------------------------------------------------
 * Date Modified             Modified By             Description of the update
 * ----------------------------------------------------------------------------
 * 26 May 2020               CLD                 		 Initial Version
 */
public with sharing class DAO_Project_Log_ChangeEvent extends fflib_SObjectDomain {
  /**
   * Constructor of this class
   * @params sObjectList List<pse__Project_Task__ChangeEvent>
   */
  public DAO_Project_Log_ChangeEvent(List<Sobject> sObjectList) {
    super(sObjectList);
  }

  /**
   * Constructor Class for construct new Instance of This Class
   */
  public class Constructor implements fflib_SObjectDomain.IConstructable {
    public fflib_SObjectDomain construct(List<SObject> sObjectList) {
      return new DAO_Project_Log_ChangeEvent(sObjectList);
    }
  }

  /**
   * This method is used for after insert of the Project Task Change Event (pse__Project_Task__ChangeEvent) trigger.
   * @return void
   */
  public override void handleAfterInsert() {
    DAOH_ChangeEvent.auditChanges(Project_Log__c.sobjectType, Records);
  }
}