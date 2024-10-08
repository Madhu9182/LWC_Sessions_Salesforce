public with sharing class CTLocationTracingController {
    public static List<Location_Tracing__c> getVistors(String locationId) {
        return [SELECT Id, Name, Person__c, Location__c, Visit_Date__c, Person__r.Token__c, Person__r.Health_Status__c 
                FROM Location_Tracing__c 
                WHERE Id =: locationId
                ORDER BY Visit_Date__c DESC 
                NULLS LAST 
                LIMIT 100];
    }
    public static List<Location_Tracing__c> getLocationsByPersonIds(Set<Id> personIds){
        return [SELECT Id, Person__c, Location__c
                FROM Location_Tracing__c
                WHERE Person__c IN : personIds 
                AND Visit_Date__c = LAST_N_DAYS:10];
    }
    public static List<Location_Tracing__c> getLocationsByLocationIds(Set<Id> locationIds){
        return [SELECT Id, Person__c, Location__c, Visit_Date__c
                FROM Location_Tracing__c 
                WHERE Location__c IN : locationIds
                AND Person__r.Health_Status__c = 'Green'
                AND Visit_Date__c = Last_N_Days : 10];
    }

    public static List<Location_Tracing__c> checkDuplicates(List<Location_Tracing__c> newLocationTraces){
        //store unique location ids
        Set<Id> locationIds = new Set<Id>();
        //Store unique person ids
        Set<Id> personIds = new Set<Id>();
        for(Location_Tracing__c trace : newLocationTraces){
            locationIds.add(trace.Location__c);
            personIds.add(trace.Person__c);
        }

        //Map of location id, set of person ids
        Map<Id, Set<Id>> mapOfExistingRecords = new Map<Id, Set<Id>>();
        // location1, [person1, person2]
        //query existing location tracing records
        List<Location_Tracing__c> existingRecords = [SELECT Id, Person__c, Location__c
                                                        FROM Location_Tracing__c 
                                                        WHERE Location__c IN : locationIds
                                                        AND Person__c IN : personIds];

        List<Location_Tracing__c> duplicates = new List<Location_Tracing__c>();
        //if exiting records is not null then iterate over the existing records to build Map<id(locationIds), set<id>(personIds)> line no 35
        if(existingRecords != null && existingRecords.size() > 0){
            for(Location_Tracing__c trace : existingRecords){
                //we need to check if map<id> has the key or not, if not we need to add the key
                /**
                 * check if map already has the locationId key
                 * Add this new item in the map using location id as key
                 * and blank Set<Id> as value
                 */
                if(! mapOfExistingRecords.containsKey(trace.Location__c)){
                    mapOfExistingRecords.put(trace.Location__c, new Set<Id>());
                }
                //add persond ids to map set
                mapOfExistingRecords.get(trace.Location__c).add(trace.Person__c);
            }

            //loop over new location tracing records
            for(Location_Tracing__c trace : newLocationTraces){
                //first check for location id
                //if item found in map, then check for person in set
                if(mapOfExistingRecords.containsKey(trace.Location__c) 
                    && mapOfExistingRecords.get(trace.Location__c).contains(trace.Person__c)){
                        duplicates.add(trace);
                }
            }
        }
        return duplicates;
    }
}