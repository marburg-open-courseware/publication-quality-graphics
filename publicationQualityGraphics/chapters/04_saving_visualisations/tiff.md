

In all of the following chapters we will first create very basic `lattice` and `ggplot2` plot objects:


```r
p_lattice <- xyplot(price ~ carat, data = diamonds)
p_ggplot <- ggplot(aes(x = carat, y = price), data = diamonds) +
  geom_point() + 
  theme_bw()
```

Ok, so we have our basic plot objects that we want to export as `tiff` images. Note that for graphics of points and lines it is usually preferred to export them using a vector graphics device (`eps` or `pdf`) but for the sake of demonstration, we will not care about this right now and export our scatter plot as `tiff` anyway (`eps` and `pdf` examples follow). In all the examples that follow, we will produce figures that are maximum width (17.35 cm) and maximum height (23.35 cm) accroding to PLOS ONE specifications. Furthermore, we will always first see how this is done with lattice, then with ggplot2.

For `tiff` the default settings are as follows:

* width and heigth: 480
* units: "px" - pixels
* pointsize: 12
* compression: "none"
* bg (background): "white"
* res (resolution): NA
* type: system dependent (check with `getOption("bitmapType")`)

If we want to use units different from pixels for our width and height specifications, we need to supply a resolution to be used through `res`. 

So, the first thing to do is open the `tiff` device:


```r
tiff("test.tif", width = 17.35, height = 23.35, units = "cm", res = 300)
```

then, we render our plot object:


```r
print(p_lattice)
```

and finally we close our device:


```r
invisible(dev.off()) # dev.off() is sufficient. Invisible suppresses text.
```

This will create a `tiff` image of our plot with a text pointsize of 12 for the axis labels, a pointsize of 10 for the axis tick labels and a pointsize of 14 for the plot title (iff supplied). As we have seen, both `lattice` and `ggplot2` ignore any paramter passed to the device via `pointsize`. Therefore, in case we want to change the pointsize of the text in our plot, we need to achieve this in another way. 

In the following setup we will change the default fontsize to 5 pt.


```r
tiff("test.tif", width = 17.35, height = 23.35, units = "cm", res = 300)

tifftheme <- trellis.par.get()
tifftheme$fontsize$text <- 5

print(update(p_lattice, par.settings = tifftheme))

invisible(dev.off())
```

This, however, does change the axis label text to a pointsize of 5, but the axis ticks are labelled with a pointsize of 4. This is because `lattice` uses so-called `character expansion (short cex)` factors for different regions of the plot. Axis tick labels have `cex = 0.8` and the title has `cex = 1.2`. Therefore, the tick labels will be `fontsize * cex` i.e. `5 * 0.8` in pointsize. We can, howver change this also. 

In the following we will change the axis font size to 10 and the axis tick label fotsize to 17.5:


```r
tiff("test.tif", width = 17.35, height = 23.35, units = "cm", res = 300)

tifftheme <- trellis.par.get()
tifftheme$fontsize$text <- 12 # set back to base fontsize 12
expansion_axislabs <- 10/12
expansion_ticks <- 17.5/12
tifftheme$par.xlab.text$cex <- expansion_axislabs
tifftheme$par.ylab.text$cex <- expansion_axislabs
tifftheme$axis.text$cex <- expansion_ticks

print(update(p_lattice, par.settings = tifftheme))

invisible(dev.off())
```

The same also applies if you use `panel.text()` or `panel.key()`. Use the `cex` parameter to ajust to the font size you want your text to be.

Ok, so much for `lattice`. Let's see how we can change things in `ggplot2`.

The equivalent to the `par.settings = ` in `lattice` are the different `theme_`s in `ggplot2`.
