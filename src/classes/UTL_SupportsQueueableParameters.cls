/**
 * Interface for Queueable jobs that support dynamic parameter injection.
 * Implementing this interface allows a Queueable job to accept parameters.
 *
 * This ensures flexibility by enabling different Queueable jobs to be executed with dynamic data without modifying the core dispatcher logic.
 *
 * @author Pramod Kumar
 */
public interface UTL_SupportsQueueableParameters {
    
    /**
     * Sets the parameters required for the execution of a Queueable job.
     * @param parameters The parameters object containing necessary execution data.
     */    
    void setParameters(UTL_QueueableJobParameters parameters);
}