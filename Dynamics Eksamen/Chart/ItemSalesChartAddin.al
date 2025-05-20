controladdin ItemSalesChartAddin
{
    Scripts = 'Chart/itemchart.js',
              'https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js';

    StartupScript = 'Chart/itemchart.js';
    RequestedHeight = 250;
    RequestedWidth = 400;

    procedure SetChartData(Data: Text);
}
