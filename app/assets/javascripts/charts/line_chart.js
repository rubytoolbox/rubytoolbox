var lineChart = function(selector, labels, values, scale) {
  var ctx = document.querySelector(selector)
                    .getContext('2d');

  new Chart(ctx, {
    type: "line",
    data: {
      labels: labels,
      datasets: [
        {
          data: values,
          fill: true,
          lineTension: 0.2,
          borderWidth: 5,
          pointRadius: 1,
          backgroundColor: "rgba(200,200,200,0.2)",
          borderColor: "rgba(166,20,20,1)"
        }
      ]
    },
    options: {
      legend: {
        display: false
      },
      tooltips: {
        mode: "index",
        intersect: false,
        axis: "x"
      },
      scales: {
        xAxes: [
          {
            gridLines : {
              display : false
            }
          }
        ],
        yAxes: [
          {
            type: scale,
            ticks: {
              beginAtZero: true,
              callback: function(value, index) {
                if (index % 8 == 0) { return value; }
              }
            }
          }
        ]
      }
    }
  });
}
