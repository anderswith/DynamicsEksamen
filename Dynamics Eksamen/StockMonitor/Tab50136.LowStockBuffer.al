table 50136 LowStockBuffer
{
    Caption = 'LowStockBuffer';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Item No."; Code[20])
        {
            Caption = 'Item No.';
        }
        field(2; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(3; Inventory; Decimal)
        {
            Caption = 'Inventory';
        }
    }
    keys
    {
        key(PK; "Item No.")
        {
            Clustered = true;
        }
    }
}
