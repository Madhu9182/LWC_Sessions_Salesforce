public class ToDoController {

    // All these Aura Enabled methods they are exposed as the ECMAScript module in lightning web component framework
    @AuraEnabled
    public static String addTodo(String payload) {
        todo payloadObject = (todo) JSON.deserialize(payload, todo.class);

        SObject tsk = (Sobject) Type.forName('todo__c').newInstance();
        tsk.put('Name', payloadObject.todoName);
        tsk.put('Done__c', payloadObject.done);

        insert tsk;

        return String.valueOf(tsk.Id);
    }

    @AuraEnabled
    public static void updateTodo(String payload){
        todo payloadObject = (todo) JSON.deserialize(payload, todo.class);

        SObject tsk = (Sobject) Type.forName('todo__c').newInstance();
        tsk.put('Id', payloadObject.todoId);
        tsk.put('Name', payloadObject.todoName);
        tsk.put('Done__c', payloadObject.done);

        update tsk;
    }

    @AuraEnabled
    public static void deleteTodo(String todoId){
        SObject tsk = (Sobject) Type.forName('todo__c').newInstance();
        tsk.put('Id', todoId);

        delete tsk;
    }
    
    // Cached response is treated as fresh data only for 30 sec, if you make a call again after 30 sec, then cache will be refreshed with latest server response
    @AuraEnabled(cacheable=true)
    public static List<Todo> getAllTodos(){
        List<SObject> tsks = Database.query(
            'SELECT Id, Name, CreatedDate, Done__c FROM todo__c WHERE CreatedDate = LAST_N_DAYS:7 ORDER BY CreatedDate DESC'
        );

        return getToDos(tsks);
    }

    @AuraEnabled
    public static List<Todo> getCurrentTodos(){
        List<SObject> tsks = Database.query(
            'SELECT Id, Name, CreatedDate, Done__c FROM todo__c WHERE CreatedDate = TODAY ORDER BY CreatedDate DESC'
        );

        return getToDos(tsks);
    }

    public static List<todo> getToDos(List<SObject> tsks) {
        List<todo> todos = new List<todo>();
        for(SObject tsk : tsks) {
            todo ToDo = new todo();
            ToDo.todoId = tsk.Id;
            ToDo.todoName = String.valueOf(tsk.get('Name'));
            ToDo.todoDate = Date.valueOf(tsk.get('CreatedDate'));
            ToDo.done = Boolean.valueOf(tsk.get('Done__c'));
            todos.add(ToDo);
        }

        return todos;
    }

    class ToDo {
        @AuraEnabled
        public String todoId;
        @AuraEnabled
        public String todoName;
        @AuraEnabled
        public Date todoDate;
        @AuraEnabled
        public Boolean done;
    }
}