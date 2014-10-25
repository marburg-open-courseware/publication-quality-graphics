

## 4. Saving your visualisations

Saving graphics in R is very straight forward. We simply need to call a suitable device. There are a number of different plotting devices available. Here, we will introduce 4 examples, `tiff`, `png`, `postscript` and `pdf`. `postscript` and `pdf` should be used for vector graphics (e.g. line plots, point plots, polygon plots etc.), whereas `tiff` and `png` are preferable for raster graphics (e.g. photos, our density scatter plot or anything pixel based).

All the graphics devices in R basically work the same way:

1. we open the respective device (postscript, png, tiff, pdf, jpeg, ...)
2. we plot (or in our case print our plot objects)
3. we close the device using `dev.off()` - otherwise the file will not be written to the hard drive.

In code, this is:


```r
png("some_filename.png", width = 10, height = 10, units = "cm", res = 300)
## here goes your plotting routine, e.g.: xyplot(1:10 ~ 1:10)
invisible(dev.off())
```

<figure><img src="../../book_figures/device.png"><figcaption></figcaption></figure>

Sounds rather easy, but as they say, the devil is in the details... Unfortunately, neither `lattice` nor `ggplot2` grpahics play very well with the respective graphics devices. Consider the following setting where we want to produce a `tiff` output with a resolution of 300 dpi, a width of 17.35 cm, a height of 23.35 cm, the font family "ArialMT" and a pointsize of 18.

Insetad of saving a graph, however, we only check whether the pointsize of 18 is passed correctly to the respective plotting environment (i.e. `base graphics`, `lattice` and `ggplot2`).


```r
tiff("test.tif", family = "ArialMT", units = "cm",
     width = 17.35, height = 23.35, pointsize = 18, res = 300)

# query base graphics graphical parameter text size (pointsize)
par()$ps
```

```
[1] 18
```

```r
# query lattice text size
trellis.par.get()$fontsize$text
```

```
[1] 12
```

```r
# query ggplot2 text size
theme_bw()$text$size
```

```
[1] 12
```

```r
# turn device off
invisible(dev.off())
```

<figure><img src="../../book_figures/graphical paramters tiff.png"><figcaption></figcaption></figure>

We see that neither `lattice` nor `ggplot2` adhere to the specified pointsize whereas `base grpahics` do. Let's try this for the other devices too. First, `png`:


```r
png("test.png", family = "ArialMT", units = "cm",
     width = 17.35, height = 23.35, pointsize = 18, res = 300)
# query base graphics graphical parameter text size (pointsize)
par()$ps
```

```
[1] 18
```

```r
# query lattice text size
trellis.par.get()$fontsize$text
```

```
[1] 12
```

```r
# query ggplot2 text size
theme_bw()$text$size
```

```
[1] 12
```

```r
# turn device off
invisible(dev.off())
```

<figure><img src="../../book_figures/graphical paramters png.png"><figcaption></figcaption></figure>

Similar to `tiff`. Now for `eps`:


```r
postscript("test.eps", family = "ArialMT",
           width = 17.35 / 2.54, height = 23.35 / 2.54, pointsize = 18)
# query base graphics graphical parameter text size (pointsize)
par()$ps
```

```
[1] 18
```

```r
# query lattice text size
trellis.par.get()$fontsize$text
```

```
[1] 18
```

```r
# query ggplot2 text size
theme_bw()$text$size
```

```
[1] 12
```

```r
# turn device off
invisible(dev.off())
```

<figure><img src="../../book_figures/graphical paramters eps.png"><figcaption></figcaption></figure>

Aha! Here `lattice` all of a sudden adheres to the pointsize, `ggplot2` still ignores it.
Finally, for `pdf`:


```r
pdf("test.pdf", family = "ArialMT",
    width = 17.35 / 2.54, height = 23.35 / 2.54, pointsize = 18)
# query base graphics graphical parameter text size (pointsize)
par()$ps
```

```
[1] 18
```

```r
# query lattice text size
trellis.par.get()$fontsize$text
```

```
[1] 12
```

```r
# query ggplot2 text size
theme_bw()$text$size
```

```
[1] 12
```

```r
# turn device off
invisible(dev.off())
```

<figure><img src="../../book_figures/graphical paramters pdf.png"><figcaption></figcaption></figure>

... and we're back to square one with only `base graphics` really correctly setting the supplied fontsize.

Alright, this was only a small exercise to highlight the fact, that it is not straight forward to get that fine control over grphics output in R. But before we dive into this deeper, we will first need to know what it is that we want to achive, meaning we need a precise definition of the guidlines our grpahics output should adhere to. Generally, academic journals provide formatting guidelines for both figures and tables. These, however, differ from journal to journal so that it is impossible to come up with a one-fits-all solution here. Therefore, we will pick one of these guides to highlight the process of achieving the desired formatting which can then be adapted to any other formatting guide. Even though this is in R terms not directly related to exporting visualisations through different devices, these finer controls will be covered her, as from an academic publishing point of view this is exactly the point where we need to start thinking about these formatting issues.

Depending on the journal the formatting guidelines can be quite detailed, though some journals allow for more flexibility. Generally, there are a few parameters that the majority of journals define in their formatting guides. These include (but are surely not limited to):

* filetypes
* font size
* font family (font type)
* dimensions
* resolution (in case of raster graphics)

In case of more rigid formatting guidelines, further rules may be imposed on:

* color mode
* background colour
* lines and strokes
* file size
* orientation

to name a few. Here, we will focus on the first list.

As an example, we will use the guidelines from PLOS ONE. An overview of these can be found [here](http://www.plosone.org/static/figureGuidelines#figures) and more details are listed [here](http://www.plosone.org/static/figureSpecifications). Additionally, some general remarks on software related issues can be found [here](http://www.plosone.org/static/figureInstructions). From the latter I quote:

> Numerous programs can create figures but are not dedicated to working with graphics. These may be limited in their capability to create TIFFs or EPSs that comply with PLOS specifications. Such applications include ChemDraw, Haploview, PyMol, R, ImageMagick, Corel Draw, GeneSpring, Matlab, Origin, Prism, Sigmaplot, and Stata. To create a high-quality TIFF from images created in other applications, use the instructions below to convert to PDF and then to TIFF or EPS.

This basically means that we should not directly export our graphics from R to either `tiff` or `eps` (the only two file formats accepted by PLOS ONE), but rather save them as a `pdf` and then follow [this guide](http://www.plosone.org/static/figureInstructions#convertingfigs) on how to convert the `pdf` to acceptable `tiff` or `eps` formats. Here, we will cover all of these, so whether you send an original R `tiff` or convert it from the R `pdf` is completely up to you.

Ok, so let's start with the `tiff` device...