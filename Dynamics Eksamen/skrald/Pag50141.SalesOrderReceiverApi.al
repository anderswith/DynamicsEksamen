page 50141 SalesOrderReceiverApi
{
    APIGroup = 'sales';
    APIPublisher = 'AndersW';
    APIVersion = 'v1.0';
    Caption = 'Sales Order Receiver API';
    DelayedInsert = true;
    EntityName = 'salesorderreceiver';
    EntitySetName = 'salesorderreceivers';
    PageType = API;

    [ServiceEnabled]
    procedure CreateSalesOrder(itemsJson: Text): Text
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        Customer: Record Customer;
        JsonArray: JsonArray;
        RootObject: JsonObject;
        LineItem: JsonObject;
        JsonToken: JsonToken;
        ItemNo: Code[20];
        Quantity: Decimal;
        i: Integer;
        CustomerName: Text[100];
        CustomerNo: Code[20];
        PostingDate: Date;
        DocumentDate: Date;
        PaymentTermsCode: Code[10];
    begin
        // Parse JSON string into RootObject
        if not RootObject.ReadFrom(itemsJson) then
            Error('Invalid JSON format.');

        // Extract customerNo
        if not RootObject.Get('customerNo', JsonToken) then
            Error('Missing customerNo');
        CustomerNo := JsonToken.AsValue().AsText();

        // Extract customerName (optional, can verify later)
        if not RootObject.Get('customerName', JsonToken) then
            Error('Missing customerName');
        CustomerName := JsonToken.AsValue().AsText();

        // Extract salesLines array
        if not RootObject.Get('salesLines', JsonToken) then
            Error('Missing salesLines array');
        JsonArray := JsonToken.AsArray();

        // Set posting & document dates to today (could be extended to accept from JSON)
        PostingDate := WorkDate;
        DocumentDate := WorkDate;

        // Get customer record to retrieve payment terms
        if not Customer.Get(CustomerNo) then
            Error('Customer %1 not found.', CustomerNo);
        PaymentTermsCode := Customer."Payment Terms Code";

        // Create Sales Header (new Sales Order)
        SalesHeader.Init();
        SalesHeader."Document Type" := SalesHeader."Document Type"::Order;
        SalesHeader.Validate("Sell-to Customer No.", CustomerNo);
        SalesHeader.Validate("Sell-to Customer Name", CustomerName);
        SalesHeader."Posting Date" := PostingDate;
        SalesHeader."Document Date" := DocumentDate;
        SalesHeader.Validate("Payment Terms Code", PaymentTermsCode);
        SalesHeader.Insert(true);

        // Add Sales Lines
        for i := 0 to JsonArray.Count() - 1 do begin
            JsonArray.Get(i, JsonToken);
            LineItem := JsonToken.AsObject();

            if not LineItem.Get('itemNo', JsonToken) then
                Error('Missing itemNo');
            ItemNo := JsonToken.AsValue().AsText();

            if not LineItem.Get('quantity', JsonToken) then
                Error('Missing quantity');
            Quantity := JsonToken.AsValue().AsDecimal();

            SalesLine.Init();
            SalesLine."Document Type" := SalesLine."Document Type"::Order;
            SalesLine."Document No." := SalesHeader."No.";
            SalesLine."Type" := SalesLine."Type"::Item;
            SalesLine.Validate("No.", ItemNo);
            SalesLine.Validate("Quantity", Quantity);
            SalesLine.Insert(true);
        end;

        exit('Sales order created successfully with No.: ' + SalesHeader."No.");
    end;
}
