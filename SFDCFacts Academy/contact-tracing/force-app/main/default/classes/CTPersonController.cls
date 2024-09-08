public with sharing class CTPersonController {
    /*
    * Generate unique token using mobile number
    * use MD5 algorithm to generate one-way hash
    * @param mobile
    * @return string token
    */
    public static String getToken(String mobileNo){
        Blob value = Blob.valueOf(mobileNo);                // this line its going to give me a blob value from the mobile number
        Blob hash = Crypto.generateDigest('MD5',value);     // Apply MD5 hash algorithm on this

        //get the string value of hash using EncodingUtil class which accepts a Blob parameter
        return EncodingUtil.base64Encode(hash);
    }
    /*
     * Get 100 contacts with recent health status change
     * @return List<Person__c> 
     */
    public static List<Person__c> getRecentHealthChanges(){
        return [SELECT Id, Name, Health_Status__c , Mobile__c, Status_Update_Date__c, Token__c 
        FROM Person__c 
        ORDER BY Status_Update_Date__c Desc 
        NULLS LAST LIMIT 100];
    }
    /*
     * Search a person by name, token or mobile
     * @return List<Person__c> 
     */
    public static List<Person__c> searchPeople(String searchTerm){
        searchTerm = searchTerm + '%';
        return [SELECT Id, Name, Health_Status__c, Mobile__c, Status_Update_Date__c, Token__c 
                FROM Person__c 
                WHERE Name LIKE :searchTerm
                OR Mobile__c LIKE :searchTerm 
                OR Token__c LIKE :searchTerm 
                ORDER BY Status_Update_Date__c DESC NULLS LAST ];
    }
    /*
    * search a person by Id
    * @return Person__c
    */
    public static Person__c getPersonById(String personId){
            List<Person__c> people =  [SELECT Id, Name, Mobile__c, Status_Update_Date__c, Token__c, Health_Status__c 
              FROM Person__c
              WHERE Id  =:personId];

              if(people !=null && people.size() > 0){
                return people[0];
              }
                return null;
    }

    public static Set<Id> getCohabitants(Set<Id> personIds){
      List<String> healthStatuses = new List<String>{'Green','Yellow'};
      List<People_Tracing__c> peopleTraces = [SELECT Id, Person_1__c, Person_2__c FROM People_Tracing__c
                                              WHERE (Person_1__c IN :personIds OR Person_2__c IN:personIds)
                                              AND Contact_Type__c = 'Cohabitant'
                                              AND (Person_1__c.Health_Status__c IN: healthStatuses OR Person_2__c.Health_Status__c IN: healthStatuses)];
      Set<Id> cohabitants = new Set<Id>();
      for(People_Tracing__c pt : peopleTraces){
        if(!personIds.contains(pt.Person_1__c)){
          cohabitants.add(pt.Person_1__c);
        }
        if(!personIds.contains(pt.Person_2__c)){
          cohabitants.add(pt.Person_2__c);
        }
      }
      return cohabitants;
    }
    /**
     * Get Count of people in each health status
     * @return Map<String, Integer>
     */
    public static Map<String, Integer> getHealthStatusCount() {
      Map<String, Integer> healthCountMap = new Map<String,Integer>();
      for(AggregateResult ar : [SELECT Health_Status__c, COUNT(Id) total FROM Person__c GROUP BY Health_Status__c]){
        /**
         * else you can assign it to variables and use them like below
         * String healthStatus = String.valueOf(ar.get('Health_Status__c')
         * Integer count = Integer.valueOf(ar.get('total'))
         * use the healthStatus and count variables
         */
        healthCountMap.put(String.valueOf(ar.get('Health_Status__c')), Integer.valueOf(ar.get('total')));
      }
      return healthCountMap;
    }
}