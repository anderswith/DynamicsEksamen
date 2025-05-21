codeunit 50138 SalesOrderLine
{
    ObsoleteState = Pending;
    ObsoleteReason = 'Table created by mistake. No longer used.';
    ObsoleteTag = 'v1.0.1';

    procedure DoSomething()
    begin
        // deprecated
    end;


    var
        ItemNo: Code[20];
        Quantity: Decimal;
}
