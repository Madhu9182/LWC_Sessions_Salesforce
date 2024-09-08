public with sharing class AccountContactService {
    public static void updateActiveContacts(Set<Id> accountIds) {
        //get the aggregate result for all accounts
        List<AggregateResult> results =[SELECT AccountId, COUNT(Id) totalContacts FROM Contact 
                                            WHERE Active__c = true AND AccountId IN : accountIds
                                            GROUP BY AccountId];
            //we can iterate over this results so we can build our account list(accountsToUpdate) that we need to update
            Map<Id, Account> accountsToUpdate = new Map<Id, Account>();
            for(AggregateResult result : results){
                //get the account id and active contacts
                String accId = String.valueOf(result.get('AccountId'));
                Integer totalContacts = Integer.valueOf(result.get('totalContacts'));

                //we got our account id and total contacts
                //Now we need to update the accountid with the total contacts so we can do by constructing a new Account
                Account acc = new Account(Id = accId, Active_Contacts__c = totalContacts);
                accountsToUpdate.put(accId, acc);
            }

            //Update accounts with zero active contacts by iterating over accountIds with Id
            for(Id accId : accountIds){
                if(!accountsToUpdate.containsKey(accId)){
                    accountsToUpdate.put(accId, new Account(Id = accId, Active_Contacts__c = 0));
                }
            }
            update accountsToUpdate.values();
    }
}