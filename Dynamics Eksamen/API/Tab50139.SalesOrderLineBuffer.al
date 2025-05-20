table 50139 SalesOrderLineBuffer
{
    ObsoleteState = Removed;
    // Optional but recommended:
    // ObsoleteReason = 'No longer needed';
    Caption = 'SalesOrderLineBuffer';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Item No."; Code[20])
        {
            Caption = 'Item No.';
        }
        field(2; Quantity; Decimal) // fix the typo here ('de' -> 'Decimal')
        {
            Caption = 'Quantity';
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
