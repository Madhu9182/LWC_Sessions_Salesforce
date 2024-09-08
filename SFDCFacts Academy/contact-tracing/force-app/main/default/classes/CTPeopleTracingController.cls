public with sharing class CTPeopleTracingController {
    public static List<People_Tracing__c> getTraces(String personId) {
        return [SELECT Id, Contact_Date__c, Contact_Type__c, Person_1__c, Person_1__r.Health_Status__c, Person_2__c, Person_2__r.Health_Status__c                  
                FROM People_Tracing__c 
                WHERE Person_1__c =: personId
                OR Person_2__c =: personId
                ORDER BY Contact_Date__c DESC];
    }

    public static List<People_Tracing__c> checkDuplicates(List<People_Tracing__c> newPeopleTraces){
        //store unique person Ids
        Set<Id> persondIds = new Set<Id>();
        for(People_Tracing__c trace : newPeopleTraces){
            persondIds.add(trace.Person_1__c);
            persondIds.add(trace.Person_2__c);
        }
        //list of duplicate records
        List<People_Tracing__c> duplicates = new List<People_Tracing__c>();
        //Map of Id and Set of Id
        //Going to store a person Id in Map and all the persons he has met in the set ids
        Map<Id, Set<Id>> mapOfExistingRecords = new Map<Id, Set<Id>>();
        //Query Existing records
        List<People_Tracing__c> existingRecords = [SELECT Id, Person_1__c, Person_2__c
                                                   FROM People_Tracing__c
                                                   WHERE Person_1__c IN :persondIds
                                                   AND Person_2__c IN :persondIds];
        // Now iterate over 'existingRecords' to build 'mapOfExistingRecords'
        if(existingRecords != null && existingRecords.size() > 0){
            for(People_Tracing__c trace : existingRecords){
                if(! mapOfExistingRecords.containsKey(trace.Person_1__c)){
                    mapOfExistingRecords.put(trace.Person_1__c, new Set<Id>());
                }
                mapOfExistingRecords.get(trace.Person_1__c).add(trace.Person_2__c);

                //build map for person 2
                if(! mapOfExistingRecords.containsKey(trace.Person_2__c)){
                    mapOfExistingRecords.put(trace.Person_2__c, new Set<Id>());
                }
                mapOfExistingRecords.get(trace.Person_2__c).add(trace.Person_1__c);
            }
            //Iterate over these newPeopleTraces and each of these new records we are going to find a duplicate in existing records
            //so for that we need to iterate over newPeopleTraces
            //loop over existing records to find duplicates
            for(People_Tracing__c trace : newPeopleTraces){
                /**
                 * first I am going to identify if my map has Person_1__c as a key and if it has then i will move to my second condition
                 * where i will check if that particular item also has Person_2__c in the set
                 * if it has then its a duplicate
                 * and same for Person_2__c as a key and Person_1__c as a value joining the conditions with OR
                 */
                if(mapOfExistingRecords.containsKey(trace.Person_1__c) && mapOfExistingRecords.get(trace.Person_1__c).contains(trace.Person_2__c)
                || mapOfExistingRecords.containsKey(trace.Person_2__c) && mapOfExistingRecords.get(trace.Person_2__c).contains(trace.Person_1__c))
                {
                    duplicates.add(trace);
                }
            }
        }
        return duplicates;           
    }
}