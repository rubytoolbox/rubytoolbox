var rubygemDownloadChart = function(selector, totalDownloads, monthlyDownloads) {
  var ctx = document.querySelector(selector).getContext('2d');

  new Chart(ctx, {
    type: "bar",
    data: {
      datasets: [
        {
          type: "line",
          label: "Total Downloads",
          yAxisID: "A",
          data: totalDownloads,
          fill: true,
          borderWidth: 2,
          borderColor: "#A61414",
          backgroundColor: "rgba(200,200,200,0.2)"
        },
        {
          type: "bar",
          label: "Downloads in previous 4 weeks",
          yAxisID: "B",
          data: monthlyDownloads,
          fill: true,
          borderWidth: 0,
          backgroundColor: "rgba(80,80,80,0.8)"
        }
      ]
    },
    options: {
      tooltips: {
        mode: "index",
        intersect: false,
        axis: "x"
      },
      legend: {
        position: "bottom",
      },
      scales: {
        xAxes: [
          {
            type: "time",
            gridLines : {
              display : false
            }
          }
        ],
        yAxes: [
          {
            id: 'A',
            type: 'linear',
            position: 'left',
            gridLines : {
              display : false
            },
            ticks: {
              callback: function(value, index) {
                return value.toLocaleString();
              }
            }
          },
          {
            id: 'B',
            type: 'linear',
            position: 'right',
            gridLines : {
              display : false
            },
            ticks: {
              callback: function(value, index) {
                return value.toLocaleString();
              }
            }
          }
        ]
      }
    }
  });
};
