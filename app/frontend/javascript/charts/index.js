import Chart from "chart.js"
import barChart from "~/javascript/charts/bar_chart"
import lineChart from "~/javascript/charts/line_chart"
import rubygemDownloadChart from "~/javascript/charts/rubygem_download_chart"

Chart.defaults.global.defaultFontFamily = 'Lato, "Helvetica Neue", Helvetica, Arial, sans-serif';
Chart.defaults.global.defaultFontSize = 12;
Chart.defaults.global.defaultFontStyle = "bold";
Chart.defaults.global.animation = 0;

export default { barChart, lineChart, rubygemDownloadChart }
