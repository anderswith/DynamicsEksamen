page 50143 LowStockBufferList
{
    PageType = List;
    SourceTable = "LowStockBuffer";
    ApplicationArea = All;
    Caption = 'Low Stock Buffer List';
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Item No."; Rec."Item No.")
                {
                }
                field(Description; Rec.Description)
                {
                }
                field(Inventory; Rec.Inventory)
                {
                }
            }
        }
    }
}
