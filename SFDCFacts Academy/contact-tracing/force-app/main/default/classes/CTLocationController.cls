/*
* Main Controller class for Location__c object
*/
public with sharing class CTLocationController {
    /*
     * Get 100 locations with recent status change
     * @return List<Location__c> 
     */
    public static List<Location__c> getRecentStatusChanges() {
        return [SELECT Id, Name, Address__c, Pincode__c, Red_Score__c, Status_Update_Date__c, Status__c 
                FROM Location__c 
                ORDER BY Status_Update_Date__c DESC 
                NULLS LAST LIMIT 100];
    }
    /**
     * search a location by name, zipcode or address
     * @return List<Location__c>
     */
    public static List<Location__c> searchLocation(String searchTerm){
        searchTerm = searchTerm + '%';
        return [SELECT Id, Name, Address__c, Pincode__c, Red_Score__c, Status_Update_Date__c, Status__c 
                FROM Location__c
                WHERE Name LIKE :searchTerm
                OR Pincode__c LIKE :searchTerm
                OR Address__c LIKE :searchTerm
                ORDER BY Status_Update_Date__c DESC NULLS LAST];
    }
    /**
     * search location by id
     * @return Location__c
     */
    public static Location__c getLocationById(String locationId){
        List<Location__c> locations = [SELECT Id, Name, Address__c, Pincode__c, Red_Score__c, Status_Update_Date__c, Status__c 
                                    FROM Location__c 
                                    WHERE Id =: locationId];
        if(locations != null && locations.size() > 0){
            return locations[0];
        }else {
            return null;
        }
    }
    /**
     * Get Count of locations in each status
     * @return Map<String, Integer>
     */
    public static Map<String, Integer> getStatusCount(){
        Map<String, Integer> healthCountMap = new Map<String, Integer>();
        for(AggregateResult ar : [SELECT Status__c, COUNT(Id) total FROM Location__c GROUP BY Status__c]){
            healthCountMap.put(String.valueOf(ar.get('Status__c')), Integer.valueOf(ar.get('total')));
        }
        return healthCountMap;
    }
}