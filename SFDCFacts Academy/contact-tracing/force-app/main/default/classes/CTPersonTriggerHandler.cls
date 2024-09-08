public with sharing class CTPersonTriggerHandler {
    public static void beforeInsert(List<Person__c> newRecords) {
        //Before insert operation for Person__c object
         /**
            * todo : update health status to green
            * todo : generate unique token for the person record
            * first we need to iterate over the person records to update the health status and to generate the token
            */
        for(Person__c person : newRecords){
            person.Health_Status__c = 'Green';
            person.Token__c = CTPersonController.getToken(person.Mobile__c);
        }
    }

    /**
     * we are accepting 2 params, the trigger.new, trigger.oldmap
     * The reason is we need to compare the old value against the new value to check whether the status field really updated or not 
     * Based on that we are going to update the status update date 
     */
    public static void beforeUpdate(List<Person__c> newRecords, Map<Id, Person__c> oldRecordsMap){
        for(Person__c person : newRecords){
            /**
             * check if the status changed in this transaction
             * Also update status_update_date__c
             */
            if( person.Health_Status__c != oldRecordsMap.get(person.Id).Health_Status__c){
                person.Status_Update_Date__c = Date.today();
            }
        }
    }
}