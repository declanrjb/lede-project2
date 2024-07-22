    /*************
    
    This is the JavaScript that makes the scrolly work 
    
    *************/

    /* 
    This part attaches a scroll to the element with id="scrolly-images"    
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
            .style('fill', d=> {
              console.log(d.Case_Status)
            })
      })
  
      d3.select("#step2").on('stepin', (e) => {
        d3.select(e.target.closest(".scrolly-container")).select("img").attr("src", "image2.jpg")
      })
  
      d3.select("#step4").on('stepin', (e) => {
        console.log('hello world');
        d3.select('#scrolly-images')['_groups'][0][0].style.height = '10000px';
        /* 211.5 */
        d3.select('.sticky-thing')['_groups'][0][0].style.top = 'calc(-70vh - 105.75px)';
      })