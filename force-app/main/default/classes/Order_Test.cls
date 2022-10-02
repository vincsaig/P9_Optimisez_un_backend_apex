@isTest
private class Order_Test {
    @TestSetup
    static void createData(){
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

        Order o1 = new Order(AccountId = acc1.Id, EffectiveDate = Date.today(), Status = 'Draft', Pricebook2Id = Test.getStandardPricebookId());
        insert o1;

        OrderItem oi1 = new OrderItem (OrderId = o1.Id, PricebookEntryId = pbe.Id, Quantity=10, UnitPrice = 150);
        insert oi1;
        OrderItem oi2 = new OrderItem (OrderId = o1.Id, PricebookEntryId = pbe.Id, Quantity=20, UnitPrice = 1000);
        insert oi2;
    }

    @isTest 
    static void testSetNetAmount() {
        Order order = [SELECT ShipmentCost__c FROM Order LIMIT 1];
        order.ShipmentCost__c = 500;

        test.startTest();
        update order;
        test.stopTest();

        Order updatedOrder = [SELECT ShipmentCost__c, TotalAmount, NetAmount__c FROM Order LIMIT 1];
        Decimal expectedNetAmount = updatedOrder.TotalAmount - updatedOrder.ShipmentCost__c;
        System.assertEquals(expectedNetAmount, updatedOrder.NetAmount__c, 'The NetAmount is wrong');
    }

    @isTest
    static void testSetAccountRevenue(){
        Order order = [SELECT ShipmentCost__c, Status, TotalAmount FROM Order LIMIT 1];
        order.ShipmentCost__c = 500;
        order.Status = 'Ordered';

        test.startTest();
        update order;
        test.stopTest();

        Account acc = [SELECT Chiffre_d_affaire__c FROM Account LIMIT 1];
        System.assertEquals(order.TotalAmount, acc.Chiffre_d_affaire__c, 'The Account revenue is wrong');
    }
}
