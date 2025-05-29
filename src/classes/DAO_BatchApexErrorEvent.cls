/**
 * Batch Apex Error Event Object Domain / trigger handler
 *
 * ----------------------------------------------------------------------------
 * Date Modified             Modified By             Description of the update
 * ----------------------------------------------------------------------------
 * 22 May 2020               CLD                 		 Initial Version
 */
public with sharing class DAO_BatchApexErrorEvent extends fflib_SObjectDomain {

  /**
   * Constructor of this class
   * @params sObjectList List<pse__Project_Task__ChangeEvent>
   */
  public DAO_BatchApexErrorEvent(List<Sobject> sObjectList) {
    super(sObjectList);
  }

  /**
   * Constructor Class for construct new Instance of This Class
   */
  public class Constructor implements fflib_SObjectDomain.IConstructable {
    public fflib_SObjectDomain construct(List<SObject> sObjectList) {
      return new DAO_BatchApexErrorEvent(sObjectList);
    }
  }
  /**
   * This method is used for after insert of the Batch Apex Error Event (BatchApexErrorEvent) trigger.
   * @return void
   */
  public override void handleAfterInsert() {
    DAOH_BatchApexErrorEvent.logCDCAuditJobError(Records);
  }
}