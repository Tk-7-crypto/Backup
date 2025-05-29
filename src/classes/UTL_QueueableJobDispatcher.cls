/**
 * QueueableJobDispatcher is responsible for managing and executing a chain of Queueable jobs.
 * It supports dynamic job execution, ensuring that multiple jobs are executed sequentially.
 * This class implements Queueable and Database.AllowsCallouts to support asynchronous processing and external callouts.
 * 
 * @author Pramod Kumar
 */
public class UTL_QueueableJobDispatcher implements Queueable, Database.AllowsCallouts {

    /** Singleton instance of QueueableJobDispatcher. */
    private static UTL_QueueableJobDispatcher instance;
    
    /** Flag to track if the dispatcher has been enqueued in a transaction. */
    private static Boolean isEnqueued = false;  

    /** List of Queueable job class names to be executed. */
    private List<String> jobClassNames = new List<String>();
    
    /** List of parameters associated with each Queueable job. */
    private List<UTL_QueueableJobParameters> jobParametersList = new List<UTL_QueueableJobParameters>();
    
    /** Index to track the order of job execution. */
    private Integer currentIndex = 0; 

    /**
     * Private constructor to enforce singleton pattern.
     */
    private UTL_QueueableJobDispatcher() {}

    /**
     * Returns the singleton instance of QueueableJobDispatcher.
     * If the instance does not exist, it initializes a new one.
     * 
     * @return The singleton instance of QueueableJobDispatcher.
     */
    public static UTL_QueueableJobDispatcher getInstance() {
        if (instance == null) {
            instance = new UTL_QueueableJobDispatcher();
        }
        return instance;
    }

    /**
     * Adds a Queueable job and its parameters to the execution queue.
     * 
     * @param jobClassName The name of the Queueable class to be executed.
     * @param parameters   The parameters required for the Queueable job.
     */
    public void addQueue(String jobClassName, UTL_QueueableJobParameters parameters) {
        jobClassNames.add(jobClassName);
        jobParametersList.add(parameters);
    }
    
    /**
     * Returns the number of jobs currently in the execution queue.
     * 
     * @return The size of the job queue.
     */
    public Integer getQueueSize() {
       return jobClassNames.size();
    }

    /**
     * Executes the Queueable job at the current index and enqueues the next job in the chain.
     * 
     * @param context The QueueableContext provided by the Salesforce platform.
     */
    public void execute(QueueableContext context) {
        System.debug(jobClassNames);
        if (currentIndex < jobClassNames.size()) {
            String jobClassName = jobClassNames[currentIndex];
            UTL_QueueableJobParameters params = jobParametersList[currentIndex];

            Type jobType = Type.forName(jobClassName);
            System.debug(jobType);
            if (jobType != null) {
                try {
                    
                    Queueable jobInstance = (Queueable) jobType.newInstance();
                    if (jobInstance instanceof UTL_SupportsQueueableParameters && params != null) {
                        ((UTL_SupportsQueueableParameters) jobInstance).setParameters(params);
                    } 
					
					jobInstance.execute(context);

                } catch (Exception e) {
                    System.debug('Error instantiating Queueable Job: ' + e.getMessage());
                }
            } else {
                System.debug('Invalid Queueable Job: ' + jobClassName);
            }
                                
            // Enqueue next job in the chain
            if (currentIndex + 1 < jobClassNames.size()) {
                System.enqueueJob(new UTL_QueueableJobDispatcher(jobClassNames, jobParametersList, currentIndex + 1));
            }                        
        }
    }

    /**
     * Private constructor to create a new dispatcher instance for chaining Queueable jobs.
     * 
     * @param jobClassNames     List of Queueable job class names.
     * @param jobParametersList List of parameters associated with each job.
     * @param currentIndex      The index of the current job being executed.
     */
    public UTL_QueueableJobDispatcher(List<String> jobClassNames, List<UTL_QueueableJobParameters> jobParametersList, Integer currentIndex) {
        this.jobClassNames = jobClassNames;
        this.jobParametersList = jobParametersList;
        this.currentIndex = currentIndex;
    }

    /**
     * Enqueues the dispatcher for execution, ensuring only one instance per transaction.
     * If the dispatcher has already been enqueued, it prevents re-enqueuing.
     */
    public static void enqueueDispatcher() {
        if (!isEnqueued && instance != null) {
            System.debug(instance);
            System.enqueueJob(instance);
            isEnqueued = true; 
        }
    }
}