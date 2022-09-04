trigger TriggerOrder on Order (before insert, before update, after update) {
    new TH_Order().run();
}