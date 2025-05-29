public class LogBase {
    // Base Interface template to create custom logs
    public interface ICustomLogBase {
        sobject logToInsert();
        
        void generateLog();
    }
    
    public class LogFactory {
        public LogFactory(){}
        
        // Return the appropriate class instance based on className
        public LogBase.ICustomLogBase Instance(String className) {
            Type t = Type.forName(className);
            return (LogBase.ICustomLogBase) t.newInstance();
        }
    }
}