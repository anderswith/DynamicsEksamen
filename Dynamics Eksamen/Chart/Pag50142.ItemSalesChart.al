page 50142 "Item Sales Chart"
{
    PageType = Card;
    SourceTable = Item;
    ApplicationArea = All;
    UsageCategory = Tasks;

    layout
    {
        area(content)
        {
            group(Group)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    Caption = 'Item No.';
                    ToolTip = 'Shows the current item.';
                    Editable = false;
                }

                field(InputItemNo; InputItemNo)
                {
                    ApplicationArea = All;
                    Caption = 'Enter Item No to View Chart';
                    ToolTip = 'Enter any Item No and click "Inspect new item".';
                }

                usercontrol(ItemChart; ItemSalesChartAddin)
                {
                    ApplicationArea = All;
                }

                field(TotalQuantityText; TotalQuantityText)
                {
                    ApplicationArea = All;
                    Caption = 'Total Quantity Sold';
                    Editable = false;
                }

                field(TotalRevenueText; TotalRevenueText)
                {
                    ApplicationArea = All;
                    Caption = 'Total Revenue';
                    Editable = false;
                }



            }
        }
    }

    actions
    {
        area(processing)
        {

            action(ShowChart)
            {
                ApplicationArea = All;
                Caption = 'Show Chart (Current Item)';
                trigger OnAction()
                begin
                    CurrPage.ItemChart.SetChartData(GetSalesData(Rec."No."));
                    UpdateStats(Rec."No.");
                end;
            }

            action(OpenChartForInputItem)
            {
                ApplicationArea = All;
                Caption = 'Inspect new item';
                trigger OnAction()
                var
                    ChartPage: Page "Item Sales Chart";
                    TempItem: Record Item;
                begin
                    if InputItemNo = '' then
                        Error('Please enter an Item No.');

                    if not TempItem.Get(InputItemNo) then
                        Error('Item %1 does not exist.', InputItemNo);

                    ChartPage.SetItemNo(InputItemNo);
                    ChartPage.Run();

                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        CurrPage.ItemChart.SetChartData(GetSalesData(Rec."No."));
        UpdateStats(Rec."No.");
    end;

    var
        InputItemNo: Code[20];
        TotalQuantityText: Text[100];
        TotalRevenueText: Text[100];

    procedure GetSalesData(ItemNo: Code[20]): Text
    var
        SalesLine: Record "Sales Line";
        SalesHeader: Record "Sales Header";
        DateKey: Date;
        Qty: Decimal;
        Found: Boolean;
        Labels: Text[250];
        Values: Text[250];
        ResultJson: Text[500];
        First: Boolean;
        DateArray: array[100] of Date;
        QtyArray: array[100] of Decimal;
        Count: Integer;
        i: Integer;
    begin
        Count := 0;

        SalesLine.SETRANGE(Type, SalesLine.Type::Item);
        SalesLine.SETRANGE("No.", ItemNo);

        if SalesLine.FINDSET() then begin
            repeat
                if SalesHeader.GET(SalesLine."Document Type", SalesLine."Document No.") then begin
                    DateKey := SalesHeader."Order Date";
                    Qty := SalesLine.Quantity;

                    Found := false;
                    for i := 1 to Count do begin
                        if DateArray[i] = DateKey then begin
                            QtyArray[i] := QtyArray[i] + Qty;
                            Found := true;
                            break;
                        end;
                    end;

                    if not Found then begin
                        Count += 1;
                        DateArray[Count] := DateKey;
                        QtyArray[Count] := Qty;
                    end;
                end;
            until SalesLine.NEXT() = 0;
        end;

        Labels := '';
        Values := '';
        First := true;

        for i := 1 to Count do begin
            if First then begin
                Labels := '"' + FORMAT(DateArray[i]) + '"';
                Values := FORMAT(QtyArray[i]);
                First := false;
            end else begin
                Labels := Labels + ',' + '"' + FORMAT(DateArray[i]) + '"';
                Values := Values + ',' + FORMAT(QtyArray[i]);
            end;
        end;

        ResultJson := '{"labels":[' + Labels + '],"values":[' + Values + ']}';
        exit(ResultJson);
    end;

    procedure UpdateStats(ItemNo: Code[20])
    var
        SalesLine: Record "Sales Line";
        TotalQty: Decimal;
        TotalRev: Decimal;
        UnitPrice: Decimal;
    begin
        TotalQty := 0;
        TotalRev := 0;

        SalesLine.SETRANGE(Type, SalesLine.Type::Item);
        SalesLine.SETRANGE("No.", ItemNo);

        if SalesLine.FINDSET() then
            repeat
                TotalQty += SalesLine.Quantity;
                UnitPrice := SalesLine."Unit Price";
                TotalRev += SalesLine.Quantity * UnitPrice;
            until SalesLine.NEXT() = 0;

        TotalQuantityText := Format(TotalQty);
        TotalRevenueText := Format(TotalRev);
    end;

    procedure SetItemNo(ItemNo: Code[20])
    begin
        Rec.Get(ItemNo);
    end;
}



