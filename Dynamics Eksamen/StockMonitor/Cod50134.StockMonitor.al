codeunit 50134 "Stock Monitor"
{
    procedure CheckLowStock()
    var
        Item: Record Item;
        LowStockThreshold: Integer;
        ItemNos: array[4] of Code[20];
        i: Integer;
        Buffer: Record "LowStockBuffer"; // <-- This is the fix
        HasLowStock: Boolean;
    begin
        LowStockThreshold := 10;
        HasLowStock := false;

        Buffer.DeleteAll(); // Still fine here since it's now a temp buffer

        ItemNos[1] := '1000';
        ItemNos[2] := '1100';
        ItemNos[3] := '1700';
        ItemNos[4] := '1001'; // This one has 0 stock – good test

        for i := 1 to 4 do begin
            if Item.Get(ItemNos[i]) then begin
                if Item.Inventory < LowStockThreshold then begin
                    Buffer.Init();
                    Buffer."Item No." := Item."No.";
                    Buffer.Description := Item.Description;
                    Buffer.Inventory := Item.Inventory;
                    Buffer.Insert();
                    HasLowStock := true;
                end;
            end;
        end;

        if HasLowStock then begin
            Message('One or more items are low in stock.');
            Report.RunModal(50137, true, false); // Show the report
        end;
    end;

}
