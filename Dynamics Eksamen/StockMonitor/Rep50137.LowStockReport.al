report 50137 LowStockReport
{
    ApplicationArea = All;
    Caption = 'LowStockReport';
    UsageCategory = ReportsAndAnalysis;
    DefaultLayout = Word;
    WordLayout = 'LowStockReport.docx';
    RDLCLayout = 'LowStockReport.rdlc';
    dataset
    {
        dataitem(LowStockBuffer; LowStockBuffer)
        {
            column(ItemNo; "Item No.") { }
            column(Description; Description) { }
            column(Inventory; Inventory) { }
        }
    }
    requestpage
    {
        layout
        {
            area(Content)
            {
                group(GroupName)
                {
                }
            }
        }
        actions
        {
            area(Processing)
            {
            }
        }
    }
}
