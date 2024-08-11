/* 
Accepted: blue
Rejected: orange
Closed Denied: red
Closed Granted: green
Closed Other: purple

*/

function colorizeByStatus(d) {
  if (d.Case_Status == 'Accepted') {
    return '#F9B9F2'
  } else if (d.Case_Status == 'Rejected') {
    return '#FB8B24'
  } else if (d.Case_Status == 'Closed Denied') {
    return '#F61713'
  } else if (d.Case_Status == 'Closed Granted') {
    return '#94B3A6'
  } else if (d.Case_Status == 'Closed Other') {
    return '#2F4858'
  } else {
    return 'black'
  }
}

d3.csv("viz-data/viz-data.csv")
        .then(data => {

          // Step 5. create an SVG container inside #my-svg-chart using d3.select().append()
          const myChart = d3
            .select('#my-svg-chart')
            .append('svg')

          var totalCaseNums = 41617;
          var totalWidth = document.querySelector('#my-svg-chart').offsetWidth;

          var unitWidth = (totalWidth / totalCaseNums);
          console.log(unitWidth);

          var stageHeight = 2;
          
          // Step 6. create SVG shapes binded with data, using d3.selectAll().data().join()
          const individualCharts = myChart
            .selectAll('rect')
            .data(data)
            .join('rect');

          // if rectangles already exist
          // const individualCharts = myChart
          //   .selectAll('rect')
          //   .data(data)

          // Step 7. tweak the attributes of the SVG shapes to position them at the right places
          const gridSize = 20, gap = 2; 

          // with SVG rectangle-specific attributes

          var baseOffset = 0;

          individualCharts
              // takes data (d) and row index (i)
              .attr('x', (d,i) => {
                return d.posIndex * unitWidth;
              })
              .attr('width', (d,i) => {
                return unitWidth;
              })
              .attr('y', (d,i) => {
                  return d.So_Far * stageHeight;
              })
              
              .attr('height', (d,i) => {
                return d.Time_Elapsed * stageHeight;
              })

          // Step 8. Encode data onto the SVG shapes using colors, sizes, directions, etc.
          individualCharts
            .style('fill', d=> {
              return 'black';
              return colorizeByStatus(d);
            })
            .style('stroke', d=> {
              return 'black';
            })
            .style('stroke-width', d=> {
              return '1px';
            })
            /*
            .style('stroke-dasharray', d=> {
              var skipLength = unitWidth + stageHeight;
              return ('0,' + skipLength.toString() + ',' + unitWidth.toString() + ',' + stageHeight.toString());
            })
            */

            var scrollyContainer = document.querySelector('#scrolly-images');

    (() => {
        const scroller = scrollama()
  
        scroller
          .setup({
            parent: document.querySelector("#scrolly-images"),
            step: ".step",
            offset: 0.6,
            debug: false,
          })
          .onStepEnter(function ({ element, index, direction }) {
            const event = new CustomEvent("stepin", { detail: { direction: direction } })
            element.dispatchEvent(event)
          })
          .onStepExit(function ({ element, index, direction }) {
            const event = new CustomEvent("stepout", { detail: { direction: direction } })
            if (direction === "up" && element.previousElementSibling) {
              const event = new CustomEvent("stepin", { detail: { direction: direction } })
              element.previousElementSibling.dispatchEvent(event)
            }
          })
  
        window.addEventListener("resize", scroller.resize)
      })()
  
      /*
      This part sets up your actions. In this case, it's changing the image in the scrolly container.
      */
      d3.select("#step1").on('stepin', (e) => {
        individualCharts
            .style('stroke', d=> {
              return 'black';
            })
      })

      d3.select("#step2").on('stepin', (e) => {
        individualCharts
            .style('stroke', d=> {
              if ((d.Case_Status == 'Rejected') && (d.Occurrence == 1)) {
                return colorizeByStatus(d);
              } else {
                return 'black';
              } 
                
            })
      })

      d3.select("#step3").on('stepin', (e) => {
        individualCharts
            .style('stroke', d=> {
              console.log(d.Status_Reasons)
              if ((d.Case_Status == 'Rejected') && (d.Status_Reasons.includes('SEN')) && (d.Occurrence == 1)) {
                return colorizeByStatus(d);
              } else {
                return 'black';
              } 
                
            })
      })

      d3.select("#step4").on('stepin', (e) => {
        individualCharts
            .style('stroke', d=> {
              console.log(d.Status_Reasons)
              if ((d.Case_Status == 'Closed Denied') && (d.Occurrence == 1)) {
                return colorizeByStatus(d);
              } else {
                return 'black';
              } 
                
            })
      })

      d3.select("#step5").on('stepin', (e) => {
        individualCharts
            .style('stroke', d=> {
              console.log(d.Status_Reasons)
              if ((d.Case_Status == 'Closed Granted') && (d.Occurrence == 1)) {
                return colorizeByStatus(d);
              } else {
                return 'black';
              } 
                
            })
      })

      d3.select("#step6").on('stepin', (e) => {
        console.log('step 6 trigger')
        individualCharts
            .style('stroke', d=> {
              console.log(d.Refile)
              if (d.Refile == 'TRUE') {
                return colorizeByStatus(d);
              } else {
                return 'black';
              } 
                
            })
      })

      d3.select("#step7").on('stepin', (e) => {
        individualCharts
            .style('stroke', d=> {
              if (d.Case_Status == 'Closed Granted') {
                return colorizeByStatus(d);
              } else {
                return 'black';
              } 
                
            })
      })
  
      
  /*
      d3.select("#step8").on('stepin', (e) => {
        console.log('hello world');
        d3.select('#scrolly-images')['_groups'][0][0].style.height = '10000px';
        d3.select('.sticky-thing')['_groups'][0][0].style.top = 'calc(-70vh - 105.75px)';
      })
      */

        })