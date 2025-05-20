codeunit 50134 "Stock Monitor"
{

    procedure CheckLowStock()
    var
        Item: Record Item;
        LowStockThreshold: Integer;
        ItemNos: array[5] of Code[20];
        i: Integer;
        Buffer: Record "LowStockBuffer";
        HasLowStock: Boolean;
    begin
        // Optional debug message
        // Message('CheckLowStock triggered');

        LowStockThreshold := 10;
        HasLowStock := false;

        // Optional: clear old records (uncomment for testing)
        // Buffer.DeleteAll();

        ItemNos[1] := '1000';
        ItemNos[2] := '1100';
        ItemNos[3] := '1700';
        ItemNos[4] := '1001';
        ItemNos[5] := 'LS-150';

        for i := 1 to 5 do begin
            if Item.Get(ItemNos[i]) then begin
                Item.CalcFields(Inventory);

                if Item.Inventory < LowStockThreshold then begin
                    // Optional debug message
                    // Message('Item %1 has low stock (%2)', Item."No.", Item.Inventory);

                    if Buffer.Get(Item."No.") then begin
                        Buffer.Description := Item.Description;
                        Buffer.Inventory := Item.Inventory;
                        Buffer.Modify();
                    end else begin
                        Buffer.Init();
                        Buffer."Item No." := Item."No.";
                        Buffer.Description := Item.Description;
                        Buffer.Inventory := Item.Inventory;
                        Buffer.Insert();
                    end;
                end;
            end;
        end;
    end;

    trigger OnRun()
    begin
        CheckLowStock(); // This allows it to be triggered by the Job Queue
    end;
}
