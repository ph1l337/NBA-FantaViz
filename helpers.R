# createStackedbarChart

# require(devtools)
# install_github('rNVD3', 'ramnathv')
bar1 <- nvd3Plot(~gear, data = mtcars, type = "discreteBarChart", width = 600)
bar1$printChart("chart1")