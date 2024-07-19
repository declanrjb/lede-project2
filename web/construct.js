d3.csv("data/complaints-toy.csv")
        .then(data => {
          // check if the data is loaded:
          console.log(data)

          totalPerStage = {}
          for (var i=0; i<data.length; i++) {
            currDataPoint = data[i];
            currStage = currDataPoint['Stage'];
            if (currStage in totalPerStage) {
              totalPerStage[currStage] += parseFloat(currDataPoint['Num_Complaints'])
            } else {
              totalPerStage[currStage] = parseFloat(currDataPoint['Num_Complaints'])
            }
          }

          for (var i=0; i<data.length; i++) {
            if (data[i].Stage == 1) {
              var sumSoFar = 0;
              for (var j=0; j<i; j++) {
                if (data[j]['Stage'] == 1) {
                  sumSoFar += parseFloat(data[j]['Num_Complaints']);
                }
              }
              data[i]['sumSoFar'] = sumSoFar;
            }
          }

          // Step 5. create an SVG container inside #my-svg-chart using d3.select().append()
          const myChart = d3
            .select('#my-svg-chart')
            .append('svg')


          var totalWidth = document.querySelector('#my-svg-chart').offsetWidth;

          
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
                if (d.Stage == 1) {
                  return (d.sumSoFar / totalPerStage['1']) * totalWidth;
                } else {
                  return 0;
                }
              })
              .attr('width', (d,i) => {
                var newWidth = (d.Num_Complaints / totalPerStage['1']) * totalWidth;
                for (var j=0; j<i; j++) {
                  console.log(individualCharts[j]);
                }
                return newWidth;
              })
              .attr('y', (d,i) => {
                  return 0;
              })
              
              .attr('height', (d,i) => {
                return d.Stage * 200;
              })

          // Step 8. Encode data onto the SVG shapes using colors, sizes, directions, etc.
          individualCharts
            .style('fill', d=> {
              if (d.Stage == 1) {
                return 'black';
              } else {
                return 'transparent';
              }
            })
            .style('stroke', d=> {
              if (d.Stage == 1) {
                return 'red';
              } else {
                return 'transparent';
              }
            })
            .style('stroke-width', d=> {
              return '3px';
            })

        })