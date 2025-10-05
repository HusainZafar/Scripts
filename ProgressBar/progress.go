package main

import (
    "fmt"
    "os"
    "strconv"
    "github.com/go-echarts/go-echarts/v2/charts"
    "github.com/go-echarts/go-echarts/v2/opts"
)

func main() {
    if len(os.Args) < 3 {
        fmt.Println("Usage: go run progress.go <current> <total>")
        return
    }

    current, _ := strconv.ParseFloat(os.Args[1], 64) // Parse string as a float with 64 bits precision
    total, _ := strconv.ParseFloat(os.Args[2], 64)

    percent := current/total*100
    fmt.Printf("Progress: %.2f%%\n", percent) // a single % starts a format specifier

    drawBar(percent)
    drawPie(percent)
}

func drawBar(percent float64) {
    totalBlocks := 30
    filled := int(percent/100*float64(totalBlocks))
    
    fmt.Print("[")
    for i := 0; i < totalBlocks; i++ {
        if i < filled {
            fmt.Print("█")
        } else {
            fmt.Print("░")
        }
    }
    fmt.Println("]")
}

func drawPie(percent float64) {
    pie := charts.NewPie()
    pie.SetGlobalOptions(
        charts.WithTitleOpts(opts.Title{
            Title:    "Progress Pie Chart",
            Subtitle: fmt.Sprintf("%.2f%% Complete", percent),
        }),
    )
    
    pie.AddSeries("Progress", []opts.PieData{
        {Name: "Done", Value: percent},
        {Name: "Remaining", Value: 100-percent},
    })

    f, _ := os.Create("progress.html")
    _ = pie.Render(f)
    fmt.Println("Chart saved as progress.html")
}
