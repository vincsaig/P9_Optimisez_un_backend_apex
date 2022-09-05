global class Batch01AccountChiffreAffaire implements Database.Batchable<sObject>{
    
    global Database.QueryLocator start(Database.BatchableContext info){ 
        //Requeter seulement les comptes qui ont au moins une commande avec le Status 'Ordered'
        return Database.getQueryLocator('SELECT Id, TotalAmount, AccountId FROM Order WHERE Status = \'Ordered\'');
    }
    
    global void execute(Database.BatchableContext info, List<Order> scope){
        Map<Id,List<Order>> mapAccountIdListOfOrder = new Map<Id, List<Order>>();
        for(Order order : scope){
            if(mapAccountIdListOfOrder.get(order.AccountId) != null){
                mapAccountIdListOfOrder.get(order.AccountId).add(order);
            } 
            else{
                mapAccountIdListOfOrder.put(order.AccountId,new List<Order>{order});
            }
        }

        if(mapAccountIdListOfOrder.size() > 0){
            List<Account> accountsList = [SELECT Id, Chiffre_d_affaire__c FROM Account WHERE Id IN :mapAccountIdListOfOrder.keySet()];
            for(Account account : accountsList){
                account.Chiffre_d_affaire__c = 0;
                for(Order accountOrder : mapAccountIdListOfOrder.get(account.Id)){
                    account.Chiffre_d_affaire__c += accountOrder.TotalAmount;
                }
            }

            if(accountsList.size() > 0){
                update accountsList;
            }
        }
    }
    
    global void finish(Database.BatchableContext info){      
    }
}