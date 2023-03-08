import { Controller } from "@hotwired/stimulus"
import ApexCharts from "apexcharts";
import axios from "axios";

export default class extends Controller {
  connect() {
    this.populate()
  }

  populate() {
    axios.get(`/back_tests_list_item_data?id=${this.data.get("back-test-id")}`).then((response) => {
      let data = response.data;

      this.setData(data)

      console.log("1")
      this.createAverageTickProcessingTime(data)
      console.log("2")
      this.createProfitLossAreaChart();
      console.log("3")
      this.createProfitLossBarCharts();
      console.log("4")

      setTimeout(() => {
        this.updateUi()
      }, 2000)
    })

  }

  setData(data) {
    this.element.querySelector("#name-container").innerHTML = data.name
    this.element.querySelector("#started-at-readable-container").innerHTML = data.started_at_readable
    this.element.querySelector("#balance-pct-change-container").innerHTML = data.balance_pct_change
    this.element.querySelector("#starting-balance-container").innerHTML = data.starting_balance
    this.element.querySelector("#current-balance-container").innerHTML = data.current_balance
    this.element.querySelector("#net-balance-container").innerHTML = data.net_balance
    this.element.querySelector("#profit-loss-container").innerHTML = data.profit_loss
    this.element.querySelector("#net-profit-loss-container").innerHTML = data.net_profit_loss
    this.element.querySelector("#time-elapsed-container").innerHTML = data.time_elapsed
    this.element.querySelector("#time-remaining-container").innerHTML = data.time_remaining
    this.element.querySelector("#model-period-container").innerHTML = data.model_period
    this.element.querySelector("#model-progress-container").innerHTML = data.model_progress
    this.element.querySelector("#pct-complete-container").innerHTML = data.pct_complete
    this.element.querySelector("#mean-pct-returns-container").innerHTML = data.mean_pct_returns
    this.element.querySelector("#std-dev-container").innerHTML = data.std_dev
    this.element.querySelector("#sharpe-ratio-container").innerHTML = data.sharpe_ratio
    this.element.querySelector("#total-position-count-container").innerHTML = data.total_position_count
    this.element.querySelector("#open-position-count-container").innerHTML = data.open_position_count
    this.element.querySelector("#unrealised-pl-container").innerHTML = data.unrealised_pl
    this.element.querySelector("#wins-count-container").innerHTML = data.wins_count
    this.element.querySelector("#wins-pct-container").innerHTML = data.wins_pct
    this.element.querySelector("#losses-count-container").innerHTML = data.losses_count
    this.element.querySelector("#losses-pct-container").innerHTML = data.losses_pct
    this.element.querySelector("#avg-return-container").innerHTML = data.avg_return
    this.element.querySelector("#avg-win-container").innerHTML = data.avg_win
    this.element.querySelector("#avg-loss-container").innerHTML = data.avg_loss
  }

  updateUi() {
    let context = this
    axios.get(`/back_tests_list_item_data?id=${this.data.get("back-test-id")}`).then((response) => {
      let data = response.data;
      this.setData(data)
      this.updateAverageTickProcessingTime(data);
      this.updateProfitLossAreaCharts();
      this.updateProfitLossBarCharts();
      setTimeout(() => {
        context.updateUi()
      }, 10000)
    })
  }

  createAverageTickProcessingTime(data) {
    let averageTotalTickTimeSeries = data.average_total_tick_time_series
    let averageSkippedTickTimeSeries = data.average_skipped_tick_time_series
    let averageProcessedTickTimeSeries = data.average_processed_tick_time_series
    let container = this.element.querySelector(`#average-tick-time-chart-container-${this.data.get("back-test-id")}`)

    this.averageTickProcessingTimeChart = new ApexCharts(
        container, this.profitLossAreaChartOptions(
            [
                { data: averageTotalTickTimeSeries, name: "Average Time Per Tick" },
                { data: averageSkippedTickTimeSeries, name: "Skipped" },
                { data: averageProcessedTickTimeSeries, name: "processed" },
            ]
        )
  )
    this.averageTickProcessingTimeChart.render()
  }

  updateAverageTickProcessingTime(data) {
    let averageTotalTickTimeSeries = data.average_total_tick_time_series
    let averageSkippedTickTimeSeries = data.average_skipped_tick_time_series
    let averageProcessedTickTimeSeries = data.average_processed_tick_time_series

    this.averageTickProcessingTimeChart.updateSeries([
      { data: averageTotalTickTimeSeries, name: "Average Time Per Tick" },
      { data: averageSkippedTickTimeSeries, name: "Skipped" },
      { data: averageProcessedTickTimeSeries, name: "processed" },
    ])
  }

  createProfitLossAreaChart() {
    let container = this.element.querySelector(`#profit-loss-area-chart-container-${this.data.get("back-test-id")}`)

    axios.get(`/profit_loss_series_for_back_test?id=${this.data.get("back-test-id")}`).then((response) => {
      let seriesData = response.data.html

      this.areaChart = new ApexCharts(container, this.profitLossAreaChartOptions(seriesData))
      this.areaChart.render()
    })
  }

  updateProfitLossAreaCharts() {
    axios.get(`/profit_loss_series_for_back_test?id=${this.data.get("back-test-id")}`).then((response) => {
      let seriesData = response.data.html

      this.areaChart.updateSeries(seriesData)
    })
  }

  createProfitLossBarCharts() {
    let container = this.element.querySelector(`#profit-loss-bar-chart-container-${this.data.get("back-test-id")}`)

    axios.get(`/profit_loss_bars_for_back_test?id=${this.data.get("back-test-id")}`).then((response) => {
      let seriesData = response.data.html

      this.barChart = new ApexCharts(container, this.profitLossBarChartOptions(seriesData))
      this.barChart.render()
    })
  }

  updateProfitLossBarCharts() {
    axios.get(`/profit_loss_bars_for_back_test?id=${this.data.get("back-test-id")}`).then((response) => {
      let seriesData = response.data.html

      this.barChart.updateSeries(seriesData)
    })
  }

  profitLossAreaChartOptions(series) {
    return {
      stroke: {
        width: 1,
        curve: "smooth"
      },

      legend: {
        show: false
      },
      dataLabels: {
        enabled: false
      },
      grid: {
        show: false
      },
      chart: {
        animations: {
          enabled: false
        },
        toolbar: {
          show: false
        },
        sparkline: {
          enabled: true
        },
        type: "area",
        height: "200px",
        width: "100%",
      },
      plotOptions: {
        bar: {
          distributed: true
        }
      },
      series: series
    }
  }

  profitLossBarChartOptions(series) {
    return {
      legend: {
        show: false
      },
      dataLabels: {
        enabled: false
      },
      grid: {
        show: false
      },
      chart: {
        animations: {
          enabled: false
        },
        toolbar: {
          show: false
        },
        sparkline: {
          enabled: true
        },
        type: "bar",
        height: 50,
        width: "100%",
      },
      plotOptions: {
        bar: {
          horizontal: true,
          distributed: true
        }
      },
      series: series
    }
  }
}
