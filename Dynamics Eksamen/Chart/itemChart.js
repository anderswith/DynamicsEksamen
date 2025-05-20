window.SetChartData = function (data) {
    const parsed = JSON.parse(data);

    const canvas = document.createElement('canvas');
    canvas.id = 'itemChart';

    // Set canvas drawing size
    canvas.width = 400;
    canvas.height = 250;

    // Set CSS size to match or different if you want scaling
    canvas.style.width = '400px';
    canvas.style.height = '250px';

    document.body.innerHTML = '';
    document.body.appendChild(canvas);

    new Chart(canvas.getContext('2d'), {
        type: 'bar',
        data: {
            labels: parsed.labels,
            datasets: [{
                label: 'Quantity Sold',
                data: parsed.values,
                backgroundColor: 'rgba(54, 162, 235, 0.5)',
                borderColor: 'rgba(54, 162, 235, 1)',
                borderWidth: 1
            }]
        },
        options: {
            responsive: false,   // Disable responsive to respect manual size
            scales: {
                x: { title: { display: true, text: 'Date' } },
                y: { title: { display: true, text: 'Quantity' } }
            }
        }
    });
};

