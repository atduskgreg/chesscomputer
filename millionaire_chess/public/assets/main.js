function showGraph(domElement,args ){
    defaults = {
        chart: {
            type: args.type
        },
        title: {
            text: args.title
        },
        subtitle: {
            text: ''
        },
        xAxis: {
            categories: args.labels
        },
        yAxis: {
            min: -0.003,
            max: 0.003,
            title: {
                text: ''
            }
        },
        tooltip: {
            // headerFormat: '<span style="font-size:10px">{point.key}</span><table>',
            // pointFormat: "",//'<tr><td style="color:{series.color};padding:0">{series.name}: </td>' +
            //    // '<td style="padding:0"><b>{point.y:.1f}</b></td></tr>',
            // footerFormat: '</table>',
            // shared: true,
            // useHTML: true
        },
        plotOptions: {
            column: {
                pointPadding: 0.2,
                borderWidth: 0
            }
        },
        series: [{
            name: args.seriesName,
            data: args.data
    
        }]
    }

    if(args.series){
        defaults.series = args.series;
    }
    domElement.highcharts(defaults);

}