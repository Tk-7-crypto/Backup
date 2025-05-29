/**
 * Represents the parameters required for executing a Queueable job.
 * This class encapsulates the necessary data that can be passed to a Queueable job to ensure proper execution.
 *
 * @author Pramod Kumar
 */
public class UTL_QueueableJobParameters {
    public List<Id> idList;
    public String objectAPIName;
    public String message;

    /**
     * Default constructor for UTL_QueueableJobParameters.
     * Initializes an empty instance of the parameters class.
     */
    public UTL_QueueableJobParameters() {}
}