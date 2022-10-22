@isTest
public with sharing class VFC01_Team_TEST {
    @TestSetup
    static void makeData(){
        Account acc1 = new Account(Name = 'Test Account 1');
        insert acc1;

        Product2 pd1 = new Product2(Name = 'Chemise Verte longue XYX', Family = 'Chemise');
        insert pd1;

        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = Test.getStandardPricebookId(),
            Product2Id = pd1.Id,
            UnitPrice = 1020,
            IsActive = true
        );
        insert pbe;

        List<Order> ordersList = new List<Order>();
        for(Integer i = 0; i < 10; i++){
            Order order = new Order(AccountId = acc1.Id, EffectiveDate = Date.today(), Status = 'Draft', Pricebook2Id = Test.getStandardPricebookId());
            ordersList.add(order);
        }
        insert ordersList;

        List<OrderItem> ois = new List<OrderItem>();
        for(Order order : ordersList){
            OrderItem oi1 = new OrderItem (OrderId = order.Id, PricebookEntryId = pbe.Id, Quantity=10, UnitPrice = 150);
            OrderItem oi2 = new OrderItem (OrderId = order.Id, PricebookEntryId = pbe.Id, Quantity=20, UnitPrice = 1000);
            ois.add(oi1);
            ois.add(oi2);
        }

        insert ois;
    }

    @isTest
    static void testSumOrders(){
        AggregateResult groupedResults = [SELECT SUM(TotalAmount) total FROM Order];
        test.startTest();
        VFC01_Team testSum = new VFC01_Team();
        Decimal sumOfOrders = testSum.SumOders;
        test.stopTest();

        System.assertEquals((Decimal)groupedResults.get('total'), sumOfOrders);
    }
}
