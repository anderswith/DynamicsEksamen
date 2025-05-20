codeunit 50135 SalesOrderReceiver
{
    [ServiceEnabled]
    procedure CreateSalesOrder(itemsJson: Text): Text
    var
        JsonToken: JsonToken;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        Customer: Record Customer;
        PaymentMethodRec: Record "Payment Method";
        JsonArray: JsonArray;
        RootObject: JsonObject;
        LineItem: JsonObject;
        NoSeriesMgt: Codeunit 396; //number series management

        ItemNo: Code[20];
        Quantity: Integer;
        Description: Text;
        i: Integer;
        CustomerName: Text[100];
        CustomerNo: Code[20];
        Address: Text[100];
        City: Text[50];
        PostCode: Text[20];
        Country: Code[20];
        Email: Text[100];
        //CurrencyCode: Code[10];
        OrderDate: Date;
        PaymentMethod: Text[50];
        Phone: Text[50];
        UnitPrice: Decimal;

    begin

        //validation and sets variables
        if not RootObject.ReadFrom(itemsJson) then
            Error('Failed to parse JSON payload.');

        if not RootObject.Get('customerNo', JsonToken) then
            Error('Missing customerNo');
        CustomerNo := JsonToken.AsValue().AsText();

        if not RootObject.Get('customerName', JsonToken) then
            Error('Missing customerName');
        CustomerName := JsonToken.AsValue().AsText();

        if not RootObject.Get('address', JsonToken) then
            Error('Missing address');
        Address := JsonToken.AsValue().AsText();

        if not RootObject.Get('city', JsonToken) then
            Error('Missing city');
        City := JsonToken.AsValue().AsText();

        if not RootObject.Get('postcode', JsonToken) then
            Error('Missing postcode');
        PostCode := JsonToken.AsValue().AsText();

        if not RootObject.Get('country', JsonToken) then
            Error('Missing country');
        Country := JsonToken.AsValue().AsText();

        if not RootObject.Get('email', JsonToken) then
            Error('Missing email');
        Email := JsonToken.AsValue().AsText();

        if not RootObject.Get('phone', JsonToken) then
            Error('Missing phone');
        Phone := JsonToken.AsValue().AsText();

        //if not RootObject.Get('currency', JsonToken) then
        //Error('Missing currency');
        //CurrencyCode := JsonToken.AsValue().AsText();

        if not RootObject.Get('orderDate', JsonToken) then
            Error('Missing orderDate');
        OrderDate := JsonToken.AsValue().AsDate();

        if not RootObject.Get('paymentMethod', JsonToken) then
            Error('Missing paymentMethod');
        PaymentMethod := JsonToken.AsValue().AsText();

        if not PaymentMethodRec.Get(PaymentMethod) then begin
            PaymentMethodRec.Init();
            PaymentMethodRec.Code := PaymentMethod;
            PaymentMethodRec.Description := 'Auto-created: ' + PaymentMethod;
            PaymentMethodRec.Insert(true);
        end;
        // if customer exists, customer variables are modified to match what was typed in at checkout.
        if Customer.Get(CustomerNo) then begin
            Customer.Name := CustomerName;
            Customer.Address := Address;
            Customer.City := City;
            Customer."Post Code" := PostCode;
            Customer."Country/Region Code" := Country;
            Customer."E-Mail" := Email; //in case a new email is used when purchasing.
            Customer."Phone No." := Phone;
            Customer.Modify(true);
        end else
            Error('Customer %1 does not exist. Cannot create order.', CustomerNo);

        // Create the sales header
        SalesHeader.Init();
        SalesHeader."Sell-to Customer No." := CustomerNo;
        SalesHeader."Document Type" := SalesHeader."Document Type"::Order;
        SalesHeader.Validate("Sell-to Customer No.", CustomerNo);
        SalesHeader.Validate("Sell-to Customer Name", CustomerName);
        SalesHeader."Currency Code" := '';
        SalesHeader.Validate("Order Date", OrderDate);
        SalesHeader.Validate("Payment Method Code", PaymentMethod);
        SalesHeader.Insert(true);

        // Parse sales lines
        if not RootObject.Get('salesLines', JsonToken) then
            Error('Missing salesLines');

        JsonArray := JsonToken.AsArray();

        for i := 0 to JsonArray.Count() - 1 do begin
            JsonArray.Get(i, JsonToken);
            LineItem := JsonToken.AsObject();

            if not LineItem.Get('itemNo', JsonToken) then
                Error('Missing itemNo');
            ItemNo := JsonToken.AsValue().AsText();

            if not LineItem.Get('quantity', JsonToken) then
                Error('Missing quantity');
            Quantity := JsonToken.AsValue().AsDecimal();

            if not LineItem.Get('description', JsonToken) then
                Error('Missing description');
            Description := JsonToken.AsValue().AsText();

            if not LineItem.Get('unitPrice', JsonToken) then
                Error('Missing unitPrice');
            UnitPrice := JsonToken.AsValue().AsDecimal();

            // ensure that line no is always unique
            SalesLine.SetRange("Document Type", SalesHeader."Document Type");
            SalesLine.SetRange("Document No.", SalesHeader."No.");
            if SalesLine.FindLast() then
                SalesLine."Line No." := SalesLine."Line No." + 10000
            else
                SalesLine."Line No." := 10000;

            SalesLine.Init();
            SalesLine."Document Type" := SalesLine."Document Type"::Order;
            SalesLine."Document No." := SalesHeader."No.";
            SalesLine.Type := SalesLine.Type::Item;
            SalesLine.Validate("No.", ItemNo);
            SalesLine.Validate("Quantity", Quantity);
            SalesLine.Validate("Description", Description);
            SalesLine.Validate("Unit Price", UnitPrice);
            SalesLine.Insert(true);
        end;

        exit('Sales order created successfully: ' + SalesHeader."No.");
    end;

    [ServiceEnabled]
    procedure CreateCustomer(itemsJson: Text): Text;
    var
        Customer: Record Customer;
        JsonObject: JsonObject;
        JsonToken: JsonToken;
        CustomerNo: Code[20];
        Email: Text[100];
        CustomerName: Text[100];
    begin
        // Parse JSON into JsonObject
        if not JsonObject.ReadFrom(itemsJson) then
            Error('Invalid JSON input.');

        if not JsonObject.Get('customerNo', JsonToken) then
            Error('Missing customerNo');
        CustomerNo := JsonToken.AsValue().AsText();

        if JsonObject.Get('email', JsonToken) then
            Email := JsonToken.AsValue().AsText();


        if not JsonObject.Get('customerName', JsonToken) then
            Error('Missing CustomerName');
        CustomerName := JsonToken.AsValue().AsText();

        //Prevent duplications
        if Customer.Get(CustomerNo) then
            exit(StrSubstNo('Customer %1 already exists.', CustomerNo));

        // Create new customer
        Customer.Init();
        Customer.Validate("No.", CustomerNo);
        Customer.Validate(Name, CustomerName);
        Customer.Validate("E-Mail", Email);
        Customer."Gen. Bus. Posting Group" := 'GENBUS';
        Customer."Customer Posting Group" := 'DOMESTIC';
        Customer.Insert();

        exit(StrSubstNo('Customer %1 created successfully.', CustomerNo));
    end;


}




