---
title: "Creating Publication Quality Graphs in R"
author: "<b>Tim Appelhans and Florian Detsch</b>"
date: "Last modified: 2017-10-21"
site: bookdown::bookdown_site
output: 
  bookdown::gitbook:
    split_by: section
documentclass: book
bibliography: references.bib
biblio-style: apalike
link-citations: yes
github-repo: marburg-open-courseware/publication-quality-graphics
---

# Preface {-}

This tutorial was developed as part of a one-day workshop held within the Ecosystem Informatics PhD program at the University of Marburg. Its contents are published under the creative commons license ['Attribution-ShareAlike 3.0 Unported (CC BY-SA 3.0)'](http://creativecommons.org/licenses/by-sa/3.0/).

![](http://i.creativecommons.org/l/by-sa/3.0/88x31.png)

The tutorial was originally provided as one big document, but for easier digestion of the content, we have decided to break it into several smaller bits. We hope you find parts of this tutorial, if not all of it useful.

Comments, feedback, suggestions and bug reports are always welcome and should be directed to [florian.detsch{at}staff.uni-marburg.de](mailto:florian.detsch@staff.uni-marburg.de).

<b>In this workshop we will</b>

* learn a few things about handling and preparing our data for the creation of meaningful graphs;
* quickly introduce the two main ways of plot creation in R - base graphics and <b>grid</b> graphics (we will mostly concentrate on the latter later on);
* become familiar with the two main packages for highly flexible data visualization in R - <b>lattice</b> and <b>ggplot2</b> (likely biased towards <b>lattice</b>, to be totally honest)
* learn how to modify the default options of these packages in order to really get what we want; 
* learn even more flexibility using the <b>grid</b> package to (i) create visualizations comprising multiple plots on one page and (ii) manipulate existing plots to suit our needs; and
* learn how to save our visualizations in different formats that comply with general publication standards of most academic journals.

TIP: If you study the code provided in this tutorial closely, you will likely find some additional programming gems here and there which are not specifically introduced in this workshop (such as the first few lines of code in Section \@ref(data-handling) ;-)).

<b>In this workshop it is assumed that you</b>

* already know how to get your data into R (`read.table()` etc.);
* have a basic understanding how particular parts of your data can be accessed (`$`, `[` - in case you do not know what these special characters mean in an R sense, you might want to start at a more basic level, e.g. [here](http://tryr.codeschool.com/)); and
* are familiar with the notion of object creation and assignment (using either `<-` or `=`).

<b>Note, however, that this workshop is not about statistics (we will only be marginally exposed to very basic statistical principles).</b>

_Before we start, we would like to highlight a few useful web resources for finding help in case you get stuck with a particular task:_

* First and foremost, [Google is your friend](http://www.google.com) - for R related questions just type something like "r lattice how to change plot background color". The crux here is that you provide both the programming language (i.e. R) and the name of the package your question is related to (i.e. <b>lattice</b>). This way you will very likely find useful answers (the web is full of knowledgeable geeks).
* Using Google in this way, you will most likely end up at [StackOverflow](http://www.stackoverflow.com) at some stage. This is a very helpful platform for all sorts of programming issues with an ever increasing contribution of the R community. To search directly at StackOverflow for R related stuff, type "r" in front of your search.
* For quick reference on the most useful basic functionality of R, use http://www.statmethods.net.
* [Rseek](http://www.rseek.org) is a search site dedicated exclusively to R-related stuff.
* [R-Bloggers](http://www.r-bloggers.com) is a nice site that provides access to all sorts of blog sites dedicated to R from all around the world (in fact, a lot of the material of this workshop is derived from posts found there).
* Another great tutorial on how to prepare publication quality graphics can be found [here](http://cellbio.emory.edu/bnanes/figures/). This tutorial also uses R as the data analysis tool of choice, but it goes a fair bit further using additional software such as [InkScape](https://inkscape.org/en/) for the final touches of the graphics.
* Another resource for creating visualizations, with a particular focus on climatological and atmospheric applications, using R can be found at http://metvurst.wordpress.com
* To see what we are usually up to at Environmental Informatics Marburg, we refer the interested reader to our [homepage](http://www.environmentalinformatics-marburg.de).

Finally, please note that we adhere to the format conventions introduced by @Xie2016 in his [introductory book](https://bookdown.org/yihui/bookdown/) about the R <b>bookdown</b> package. Accordingly, we do not add prompts (`>` and `+`) to the R source code presented herein, and text output is commented out with two hashes (`##`) by default, for example: 


```r
cat("Hello world.\n")
```

```
## Hello world.
```

This is meant to facilitate copying and running the code, while the text output will be automatically ignored since it is commented out. Package names are in bold text (e.g., **grid**), and inline code and file names are formatted in a typewriter font (e.g., `grid::upViewport(0)`). Function names are followed by parentheses (e.g., `grid::viewport()`). The double-colon operator `::` means accessing a function from a particular package.

<!--chapter:end:index.Rmd-->

# Data Handling {#data-handling}

One thing that most people fail to acknowledge is that visualizing data in R (or any other programming language for that matter) usually involves a little more effort than simply calling some plot function to create a meaningful graph. Data visualization is in essence an abstract representation of raw data. Most plotting routines available in R, however, are not designed to provide any useful data abstraction. This means that it is up to us to prepare our data to a level of abstraction that is feasible for what we want to show with our visualization. 

Therefore, before we start to produce plots, we will need to spend some time and effort to get familiar with some tools to manipulate our raw data sets. In particular, we will learn how to `subset()`, `aggregate()`, `sort()`, and `merge()` our data sets. For the sake of reproducibility, this workshop will make use of the `diamonds` data set (which comes with **ggplot2**) in all the provided examples.


```r
### here's a rather handy way of loading all packages that you need
### for your code to work in one go
pkg <- c('ggplot2', 'latticeExtra', 'gridExtra', 'MASS', 
         'colorspace', 'plyr', 'Hmisc', 'scales')
jnk <- sapply(pkg, library, character.only = TRUE)

### load the diamonds data set (comes with ggplot2)
data(diamonds)
```

**Right, enough of that introductory talk, let's start getting our hands dirty...**


## Subsetting Data {#subset}

The `diamonds` data set from **ggplot2** is structured as follows:


```r
str(diamonds)
```

```
## Classes 'tbl_df', 'tbl' and 'data.frame':	53940 obs. of  10 variables:
##  $ carat  : num  0.23 0.21 0.23 0.29 0.31 0.24 0.24 0.26 0.22 0.23 ...
##  $ cut    : Ord.factor w/ 5 levels "Fair"<"Good"<..: 5 4 2 4 2 3 3 3 1 3 ...
##  $ color  : Ord.factor w/ 7 levels "D"<"E"<"F"<"G"<..: 2 2 2 6 7 7 6 5 2 5 ...
##  $ clarity: Ord.factor w/ 8 levels "I1"<"SI2"<"SI1"<..: 2 3 5 4 2 6 7 3 4 5 ...
##  $ depth  : num  61.5 59.8 56.9 62.4 63.3 62.8 62.3 61.9 65.1 59.4 ...
##  $ table  : num  55 61 65 58 58 57 57 55 61 61 ...
##  $ price  : int  326 326 327 334 335 336 336 337 337 338 ...
##  $ x      : num  3.95 3.89 4.05 4.2 4.34 3.94 3.95 4.07 3.87 4 ...
##  $ y      : num  3.98 3.84 4.07 4.23 4.35 3.96 3.98 4.11 3.78 4.05 ...
##  $ z      : num  2.43 2.31 2.31 2.63 2.75 2.48 2.47 2.53 2.49 2.39 ...
```

The `str()` command is probably the most useful command in all of R. It shows the complete structure of our data set and provides a 'road map' of how to access certain parts of the data.   

For example, the console output tells us that `diamonds$carat` is a numerical vector of length 53940, whereas `diamonds$cut` is a factor with the ordered levels 


```r
levels(diamonds$cut)
```

```
## [1] "Fair"      "Good"      "Very Good" "Premium"   "Ideal"
```

Suppose we're a stingy person and don't want to spend too much money on the wedding ring for our loved one, we could create a data set only including diamonds that cost less than 1000 USD (though 1000 USD does still seem very generous to me).


```r
diamonds_cheap <- subset(diamonds, price < 1000)
```

Then our new data set would look like this


```r
str(diamonds_cheap)
```

```
## Classes 'tbl_df', 'tbl' and 'data.frame':	14499 obs. of  10 variables:
##  $ carat  : num  0.23 0.21 0.23 0.29 0.31 0.24 0.24 0.26 0.22 0.23 ...
##  $ cut    : Ord.factor w/ 5 levels "Fair"<"Good"<..: 5 4 2 4 2 3 3 3 1 3 ...
##  $ color  : Ord.factor w/ 7 levels "D"<"E"<"F"<"G"<..: 2 2 2 6 7 7 6 5 2 5 ...
##  $ clarity: Ord.factor w/ 8 levels "I1"<"SI2"<"SI1"<..: 2 3 5 4 2 6 7 3 4 5 ...
##  $ depth  : num  61.5 59.8 56.9 62.4 63.3 62.8 62.3 61.9 65.1 59.4 ...
##  $ table  : num  55 61 65 58 58 57 57 55 61 61 ...
##  $ price  : int  326 326 327 334 335 336 336 337 337 338 ...
##  $ x      : num  3.95 3.89 4.05 4.2 4.34 3.94 3.95 4.07 3.87 4 ...
##  $ y      : num  3.98 3.84 4.07 4.23 4.35 3.96 3.98 4.11 3.78 4.05 ...
##  $ z      : num  2.43 2.31 2.31 2.63 2.75 2.48 2.47 2.53 2.49 2.39 ...
```

Now the new ```diamonds_cheap``` subset is a reduced version of the original ```diamonds``` data set only having 14499 entries instead of the original 53940 entries.

In case we were interested in a subset only including all diamonds of 'Premium' quality (column `cut`), the command would be


```r
diamonds_premium <- subset(diamonds, cut == "Premium")
str(diamonds_premium)
```

```
## Classes 'tbl_df', 'tbl' and 'data.frame':	13791 obs. of  10 variables:
##  $ carat  : num  0.21 0.29 0.22 0.2 0.32 0.24 0.29 0.22 0.22 0.3 ...
##  $ cut    : Ord.factor w/ 5 levels "Fair"<"Good"<..: 4 4 4 4 4 4 4 4 4 4 ...
##  $ color  : Ord.factor w/ 7 levels "D"<"E"<"F"<"G"<..: 2 6 3 2 2 6 3 2 1 7 ...
##  $ clarity: Ord.factor w/ 8 levels "I1"<"SI2"<"SI1"<..: 3 4 3 2 1 5 3 4 4 2 ...
##  $ depth  : num  59.8 62.4 60.4 60.2 60.9 62.5 62.4 61.6 59.3 59.3 ...
##  $ table  : num  61 58 61 62 58 57 58 58 62 61 ...
##  $ price  : int  326 334 342 345 345 355 403 404 404 405 ...
##  $ x      : num  3.89 4.2 3.88 3.79 4.38 3.97 4.24 3.93 3.91 4.43 ...
##  $ y      : num  3.84 4.23 3.84 3.75 4.42 3.94 4.26 3.89 3.88 4.38 ...
##  $ z      : num  2.31 2.63 2.33 2.27 2.68 2.47 2.65 2.41 2.31 2.61 ...
```

Note the **two** equal signs in order to specify our selection. This stems from an effort to be consistent with selection criteria such as "smaller than" (`<=`) or "not equal" (`!=`) and basically translates to "is equal"!

Any combinations of these conditional statements are valid within one and the same `subset` call, e.g.


```r
diamonds_premium_and_cheap <- subset(diamonds, cut == "Premium" & 
                                       price <= 1000)
```

produces a rather strict subset only allowing diamonds of premium quality that cost less than 1000 USD.

In case we want **ANY** of these, meaning all diamonds of premium quality **OR** cheaper than 1000 USD, we would use the `|` operator to combine the two specifications:


```r
diamonds_premium_or_cheap <- subset(diamonds, cut == "Premium" | 
                                   price <= 1000)
```

The **OR** specification is much less rigid than the **AND** specification which will result in a larger data set:

* `diamonds_premium_and_cheap` has 3204 rows, while
* `diamonds_premium_or_cheap` has 25111 rows.


```r
str(diamonds_premium_and_cheap)
```

```
## Classes 'tbl_df', 'tbl' and 'data.frame':	3204 obs. of  10 variables:
##  $ carat  : num  0.21 0.29 0.22 0.2 0.32 0.24 0.29 0.22 0.22 0.3 ...
##  $ cut    : Ord.factor w/ 5 levels "Fair"<"Good"<..: 4 4 4 4 4 4 4 4 4 4 ...
##  $ color  : Ord.factor w/ 7 levels "D"<"E"<"F"<"G"<..: 2 6 3 2 2 6 3 2 1 7 ...
##  $ clarity: Ord.factor w/ 8 levels "I1"<"SI2"<"SI1"<..: 3 4 3 2 1 5 3 4 4 2 ...
##  $ depth  : num  59.8 62.4 60.4 60.2 60.9 62.5 62.4 61.6 59.3 59.3 ...
##  $ table  : num  61 58 61 62 58 57 58 58 62 61 ...
##  $ price  : int  326 334 342 345 345 355 403 404 404 405 ...
##  $ x      : num  3.89 4.2 3.88 3.79 4.38 3.97 4.24 3.93 3.91 4.43 ...
##  $ y      : num  3.84 4.23 3.84 3.75 4.42 3.94 4.26 3.89 3.88 4.38 ...
##  $ z      : num  2.31 2.63 2.33 2.27 2.68 2.47 2.65 2.41 2.31 2.61 ...
```

```r
str(diamonds_premium_or_cheap)
```

```
## Classes 'tbl_df', 'tbl' and 'data.frame':	25111 obs. of  10 variables:
##  $ carat  : num  0.23 0.21 0.23 0.29 0.31 0.24 0.24 0.26 0.22 0.23 ...
##  $ cut    : Ord.factor w/ 5 levels "Fair"<"Good"<..: 5 4 2 4 2 3 3 3 1 3 ...
##  $ color  : Ord.factor w/ 7 levels "D"<"E"<"F"<"G"<..: 2 2 2 6 7 7 6 5 2 5 ...
##  $ clarity: Ord.factor w/ 8 levels "I1"<"SI2"<"SI1"<..: 2 3 5 4 2 6 7 3 4 5 ...
##  $ depth  : num  61.5 59.8 56.9 62.4 63.3 62.8 62.3 61.9 65.1 59.4 ...
##  $ table  : num  55 61 65 58 58 57 57 55 61 61 ...
##  $ price  : int  326 326 327 334 335 336 336 337 337 338 ...
##  $ x      : num  3.95 3.89 4.05 4.2 4.34 3.94 3.95 4.07 3.87 4 ...
##  $ y      : num  3.98 3.84 4.07 4.23 4.35 3.96 3.98 4.11 3.78 4.05 ...
##  $ z      : num  2.43 2.31 2.31 2.63 2.75 2.48 2.47 2.53 2.49 2.39 ...
```

There is, in principle, no limitation to the combination of these so-called Boolean (or logical) operators 

* and: `&` 
* or: `|` 
* equal to: `==` 
* not equal to: `!=` 
* greater than (or equal): `>` (`>=`)
* less than (or equal): `<` (`<=`)

I guess you get the idea...


## Aggregating Data

Suppose we wanted to calculate the average price of the diamonds for each level of ```cut```, i.e. the average price for all diamonds of "Ideal" quality, for all diamonds of "Premium" quality and so on, this could be done using `aggregate()` like this:


```r
ave_price_cut <- aggregate(diamonds$price, by = list(diamonds$cut), 
                           FUN = mean)
ave_price_cut
```

```
##     Group.1        x
## 1      Fair 4358.758
## 2      Good 3928.864
## 3 Very Good 3981.760
## 4   Premium 4584.258
## 5     Ideal 3457.542
```

Note that `by = ...` needs a list of grouping variables, even if there is only one entry. Unless a named list is specified (see 'Value' in `?aggregate`), the original column names are not carried over to the newly created table of averaged values. Instead, these get the generic names ```Group.1``` and ```x```.

```Group.1``` already indicates that we are not limited to aggregate just over one factorial variable, more are also possible. Furthermore, any  function to compute the summary statistics which can be applied to all data subsets is allowed, e.g. to compute the number of items per category we could use ```length()```:


```r
ave_n_cut_color <- aggregate(diamonds$price, 
                             by = list(diamonds$cut,
                                       diamonds$color), 
                             FUN = length)
ave_n_cut_color
```

```
##      Group.1 Group.2    x
## 1       Fair       D  163
## 2       Good       D  662
## 3  Very Good       D 1513
## 4    Premium       D 1603
## 5      Ideal       D 2834
## 6       Fair       E  224
## 7       Good       E  933
## 8  Very Good       E 2400
## 9    Premium       E 2337
## 10     Ideal       E 3903
## 11      Fair       F  312
## 12      Good       F  909
## 13 Very Good       F 2164
## 14   Premium       F 2331
## 15     Ideal       F 3826
## 16      Fair       G  314
## 17      Good       G  871
## 18 Very Good       G 2299
## 19   Premium       G 2924
## 20     Ideal       G 4884
## 21      Fair       H  303
## 22      Good       H  702
## 23 Very Good       H 1824
## 24   Premium       H 2360
## 25     Ideal       H 3115
## 26      Fair       I  175
## 27      Good       I  522
## 28 Very Good       I 1204
## 29   Premium       I 1428
## 30     Ideal       I 2093
## 31      Fair       J  119
## 32      Good       J  307
## 33 Very Good       J  678
## 34   Premium       J  808
## 35     Ideal       J  896
```

Given that as a result of aggregating this way we loose our variable names, it makes sense to set them afterwards, so that we can easily refer to them later on.


```r
names(ave_n_cut_color) <- c("cut", "color", "n")
str(ave_n_cut_color)
```

```
## 'data.frame':	35 obs. of  3 variables:
##  $ cut  : Ord.factor w/ 5 levels "Fair"<"Good"<..: 1 2 3 4 5 1 2 3 4 5 ...
##  $ color: Ord.factor w/ 7 levels "D"<"E"<"F"<"G"<..: 1 1 1 1 1 2 2 2 2 2 ...
##  $ n    : int  163 662 1513 1603 2834 224 933 2400 2337 3903 ...
```

So, I hope you see how useful ```aggregate()``` is for calculating summary statistics of your data.

## Sorting Data

Sorting our data according to one (or more) of the variables can also come in very handy and can be achieved using ```sort()```.


```r
sort(ave_n_cut_color$n)
```

```
##  [1]  119  163  175  224  303  307  312  314  522  662  678  702  808  871
## [15]  896  909  933 1204 1428 1513 1603 1824 2093 2164 2299 2331 2337 2360
## [29] 2400 2834 2924 3115 3826 3903 4884
```

Sorting an entire data frame is a little less straightforward and can be done using ```order()```.

* for sorting according to one variable


```r
ave_n_cut_color <- ave_n_cut_color[order(ave_n_cut_color$cut), ]
ave_n_cut_color
```

```
##          cut color    n
## 1       Fair     D  163
## 6       Fair     E  224
## 11      Fair     F  312
## 16      Fair     G  314
## 21      Fair     H  303
## 26      Fair     I  175
## 31      Fair     J  119
## 2       Good     D  662
## 7       Good     E  933
## 12      Good     F  909
## 17      Good     G  871
## 22      Good     H  702
## 27      Good     I  522
## 32      Good     J  307
## 3  Very Good     D 1513
## 8  Very Good     E 2400
## 13 Very Good     F 2164
## 18 Very Good     G 2299
## 23 Very Good     H 1824
## 28 Very Good     I 1204
## 33 Very Good     J  678
## 4    Premium     D 1603
## 9    Premium     E 2337
## 14   Premium     F 2331
## 19   Premium     G 2924
## 24   Premium     H 2360
## 29   Premium     I 1428
## 34   Premium     J  808
## 5      Ideal     D 2834
## 10     Ideal     E 3903
## 15     Ideal     F 3826
## 20     Ideal     G 4884
## 25     Ideal     H 3115
## 30     Ideal     I 2093
## 35     Ideal     J  896
```

* for sorting according to two variables


```r
ave_n_cut_color <- ave_n_cut_color[order(ave_n_cut_color$cut,
                                         ave_n_cut_color$n), ]
ave_n_cut_color
```

```
##          cut color    n
## 31      Fair     J  119
## 1       Fair     D  163
## 26      Fair     I  175
## 6       Fair     E  224
## 21      Fair     H  303
## 11      Fair     F  312
## 16      Fair     G  314
## 32      Good     J  307
## 27      Good     I  522
## 2       Good     D  662
## 22      Good     H  702
## 17      Good     G  871
## 12      Good     F  909
## 7       Good     E  933
## 33 Very Good     J  678
## 28 Very Good     I 1204
## 3  Very Good     D 1513
## 23 Very Good     H 1824
## 13 Very Good     F 2164
## 18 Very Good     G 2299
## 8  Very Good     E 2400
## 34   Premium     J  808
## 29   Premium     I 1428
## 4    Premium     D 1603
## 14   Premium     F 2331
## 9    Premium     E 2337
## 24   Premium     H 2360
## 19   Premium     G 2924
## 35     Ideal     J  896
## 30     Ideal     I 2093
## 5      Ideal     D 2834
## 25     Ideal     H 3115
## 15     Ideal     F 3826
## 10     Ideal     E 3903
## 20     Ideal     G 4884
```


## Merging Data

Often enough we end up with multiple data sets on our hard drive that contain useful data for the same analysis. In this case we might want to amalgamate our data sets so that we have all the data in one set.   
R provides a function called ```merge()``` that does just that:


```r
ave_n_cut_color_price <- merge(ave_n_cut_color, ave_price_cut, 
                               by.x = "cut", by.y = "Group.1")
ave_n_cut_color_price
```

```
##          cut color    n        x
## 1       Fair     J  119 4358.758
## 2       Fair     D  163 4358.758
## 3       Fair     I  175 4358.758
## 4       Fair     E  224 4358.758
## 5       Fair     H  303 4358.758
## 6       Fair     F  312 4358.758
## 7       Fair     G  314 4358.758
## 8       Good     J  307 3928.864
## 9       Good     I  522 3928.864
## 10      Good     D  662 3928.864
## 11      Good     H  702 3928.864
## 12      Good     G  871 3928.864
## 13      Good     F  909 3928.864
## 14      Good     E  933 3928.864
## 15     Ideal     J  896 3457.542
## 16     Ideal     I 2093 3457.542
## 17     Ideal     D 2834 3457.542
## 18     Ideal     H 3115 3457.542
## 19     Ideal     F 3826 3457.542
## 20     Ideal     E 3903 3457.542
## 21     Ideal     G 4884 3457.542
## 22   Premium     J  808 4584.258
## 23   Premium     I 1428 4584.258
## 24   Premium     D 1603 4584.258
## 25   Premium     F 2331 4584.258
## 26   Premium     E 2337 4584.258
## 27   Premium     H 2360 4584.258
## 28   Premium     G 2924 4584.258
## 29 Very Good     J  678 3981.760
## 30 Very Good     I 1204 3981.760
## 31 Very Good     D 1513 3981.760
## 32 Very Good     H 1824 3981.760
## 33 Very Good     F 2164 3981.760
## 34 Very Good     G 2299 3981.760
## 35 Very Good     E 2400 3981.760
```

As the variable names of our two data sets differ, we need to specifically provide the names for each by which the merging should be done (```by.x``` and ```by.y```). The default of ```merge()``` tries to find variable names which are identical.

Note, in order to merge more than two data frames at a time, we need to call a powerful higher-order function called ```Reduce()```. This is one mighty function for doing all sorts of things iteratively.


```r
names(ave_price_cut) <- c("cut", "price")

set.seed(12)

df3 <- data.frame(cut = ave_price_cut$cut,
                  var1 = rnorm(nrow(ave_price_cut), 10, 2),
                  var2 = rnorm(nrow(ave_price_cut), 100, 20))

ave_n_cut_color_price <- Reduce(function(...) merge(..., all=T), 
                                list(ave_n_cut_color, 
                                     ave_price_cut,
                                     df3))
ave_n_cut_color_price
```

```
##          cut color    n    price      var1      var2
## 1       Fair     J  119 4358.758  7.038865  94.55408
## 2       Fair     D  163 4358.758  7.038865  94.55408
## 3       Fair     I  175 4358.758  7.038865  94.55408
## 4       Fair     E  224 4358.758  7.038865  94.55408
## 5       Fair     H  303 4358.758  7.038865  94.55408
## 6       Fair     F  312 4358.758  7.038865  94.55408
## 7       Fair     G  314 4358.758  7.038865  94.55408
## 8       Good     J  307 3928.864 13.154339  93.69303
## 9       Good     I  522 3928.864 13.154339  93.69303
## 10      Good     D  662 3928.864 13.154339  93.69303
## 11      Good     H  702 3928.864 13.154339  93.69303
## 12      Good     G  871 3928.864 13.154339  93.69303
## 13      Good     F  909 3928.864 13.154339  93.69303
## 14      Good     E  933 3928.864 13.154339  93.69303
## 15     Ideal     J  896 3457.542  6.004716 108.56030
## 16     Ideal     I 2093 3457.542  6.004716 108.56030
## 17     Ideal     D 2834 3457.542  6.004716 108.56030
## 18     Ideal     H 3115 3457.542  6.004716 108.56030
## 19     Ideal     F 3826 3457.542  6.004716 108.56030
## 20     Ideal     E 3903 3457.542  6.004716 108.56030
## 21     Ideal     G 4884 3457.542  6.004716 108.56030
## 22   Premium     J  808 4584.258  8.159990  97.87072
## 23   Premium     I 1428 4584.258  8.159990  97.87072
## 24   Premium     D 1603 4584.258  8.159990  97.87072
## 25   Premium     F 2331 4584.258  8.159990  97.87072
## 26   Premium     E 2337 4584.258  8.159990  97.87072
## 27   Premium     H 2360 4584.258  8.159990  97.87072
## 28   Premium     G 2924 4584.258  8.159990  97.87072
## 29 Very Good     J  678 3981.760  8.086511  87.43490
## 30 Very Good     I 1204 3981.760  8.086511  87.43490
## 31 Very Good     D 1513 3981.760  8.086511  87.43490
## 32 Very Good     H 1824 3981.760  8.086511  87.43490
## 33 Very Good     F 2164 3981.760  8.086511  87.43490
## 34 Very Good     G 2299 3981.760  8.086511  87.43490
## 35 Very Good     E 2400 3981.760  8.086511  87.43490
```

Obviously, setting proper names would be the next step now...

Ok, so now we have a few tools at hand to manipulate our data in a way that we should be able to produce some meaningful graphs which tell the story that we want to be heard, or better, seen...

**So, let's start plotting stuff.**

<!--chapter:end:01-data-handling.Rmd-->

# Data Visualization



In the next few sections, we will produce several varieties of *scatter plots*, *box-and-whisker plots* (from here on after 'boxplots'), *histograms* and *density plots*, and *plots with error bars*. All of these will first be produced using the **lattice** package and then an attempt is made to recreate these in (pretty much) the exact same way in **ggplot2**. First, the default versions are created and then we will see how they can be modified in order to produce plots that satisfy the requirements of most academic journals.    

We will see that some things are easier to achieve using **lattice**, whereas other things are easier in **ggplot2**, so it is probably good advice to learn how to use both of them...


## A few Notes on using Color

Before we start plotting our data, we need to spend some time to have a closer look at color representation of certain variables. A careful study of color spaces (e.g. @Zeileis2009, [HCLwizard](http://hclwizard.org/hcl-color-scheme/), [Aisch (2011)](http://vis4.net/blog/posts/avoid-equidistant-hsv-colors/) or [Wikipedia](https://en.wikipedia.org/wiki/HSL_and_HSV)) leads to the conclusion that the HCL color space is preferable when mapping a variable to color (be it factorial or continuous).

This color space is readily available in R through the package **colorspace** and the function of interest is called ```hcl()```.

In the code chunk that follows we will create a color palette that varies in both color (hue) and also luminance (brightness) so that this can be distinguished even in grey-scale (printed) versions of the plot. As a reference color palette we will use the 'Spectral' palette from [ColorBrewer](http://colorbrewer2.org) which is also a multi-hue palette but represents a diverging color palette. Hence, each end of the palette will look rather similar when converted to greyscale. 


```r
library(RColorBrewer)

clrs_spec <- colorRampPalette(rev(brewer.pal(11, "Spectral")))
clrs_hcl <- function(n) {
  hcl(h = seq(230, 0, length.out = n), 
      c = 60, l = seq(10, 90, length.out = n), 
      fixup = TRUE)
  }

### function to plot a color palette
pal <- function(col, border = "transparent", ...)
{
 n <- length(col)
 plot(0, 0, type="n", xlim = c(0, 1), ylim = c(0, 1),
      axes = FALSE, xlab = "", ylab = "", ...)
 rect(0:(n-1)/n, 0, 1:n/n, 1, col = col, border = border)
}
```

So here's the Spectral palette from ColorBrewer interpolated over 100 colors:


```r
pal(clrs_spec(100))
```

<div class="figure" style="text-align: center">
<img src="_main_files/figure-html/spectr-pal-1.svg" alt="A diverging rainbow color palette from [ColorBrewer](http://colorbrewer2.org/#type=sequential&amp;scheme=BuGn&amp;n=3)." width="768" />
<p class="caption">(\#fig:spectr-pal)A diverging rainbow color palette from [ColorBrewer](http://colorbrewer2.org/#type=sequential&scheme=BuGn&n=3).</p>
</div>

And this is what it looks like in greyscale:


```r
pal(desaturate(clrs_spec(100)))
```

<div class="figure" style="text-align: center">
<img src="_main_files/figure-html/spectr-pal-grey-1.svg" alt="Same palette as above in grey-scale." width="768" />
<p class="caption">(\#fig:spectr-pal-grey)Same palette as above in grey-scale.</p>
</div>

We see that this palette varies in lightness from a very bright center to darker ends on each side. Note, that the red end is slightly darker than the blue end.

This is quite ok in case we want to show some diverging data (deviations from a zero point, for example the mean). However, if we are dealing with a sequential measure, such as temperature, or in our case the density of points plotted per some grid cell, we really need to use a sequential color palette. There are two common problems with sequential palettes:

1. We need to create a palette that maps the data accurately. This means that the perceived distances between the different hues utilized need to reflect the distances between our data points. AND this distance needs to be constant, no matter between which two point of the palette we want to estimate their distance. Let me give you an example. Consider the classic 'rainbow' palette ([MATLAB](https://www.mathworks.com/products/matlab.html) refers to this as 'jet colors'):


```r
pal(rainbow(100))
```

<div class="figure" style="text-align: center">
<img src="_main_files/figure-html/rainb-pal-1.svg" alt="The classic rainbow color palette." width="768" />
<p class="caption">(\#fig:rainb-pal)The classic rainbow color palette.</p>
</div>

It becomes obvious that there are several thin bands in this color palette (yellow, aquamarine, purple) which do not map the distances between variable values accurately. That is, the distance between two values located in or around the yellow region of the palette will seem to change faster than, for example, somewhere in the green region (and red and blue).

When converted to greyscale, this palette produces a hell of a mess:


```r
pal(desaturate(rainbow(100)))
```

<div class="figure" style="text-align: center">
<img src="_main_files/figure-html/rainb-pal-grey-1.svg" alt="Same palette as above in grey-scale." width="768" />
<p class="caption">(\#fig:rainb-pal-grey)Same palette as above in grey-scale.</p>
</div>

Note, that this palette is maybe the most widely used color coding palette for mapping a sequential continuous variable to color. We will see further examples later on... We hope you get the idea that this is not a good way of mapping a sequential variable to color!

```hcl()``` produces so-called perceptually uniform color palettes and is therefore much better suited to represent sequential data:


```r
pal(clrs_hcl(100))
```

<div class="figure" style="text-align: center">
<img src="_main_files/figure-html/hcl-pal-1.svg" alt="An HCL based multi-hue color palette with increasing luminance towards the red end." width="768" />
<p class="caption">(\#fig:hcl-pal)An HCL based multi-hue color palette with increasing luminance towards the red end.</p>
</div>

We see that the different hues are spread constantly over the palette and therefore it is easy to estimate distances between data values from the changes in color. The fact that we also vary luminance here means that we get a very light color at one end (in our case, the red end which is more of a pink tone than red). This might, at first sight, not seem very aesthetically pleasing, yet it enables us to encode our data even in greyscale:


```r
pal(desaturate(clrs_hcl(100)))
```

<div class="figure" style="text-align: center">
<img src="_main_files/figure-html/hcl-pal-grey-1.svg" alt="Same palette as above in grey-scale." width="768" />
<p class="caption">(\#fig:hcl-pal-grey)Same palette as above in grey-scale.</p>
</div>



As a general suggestion I encourage you to make use of the HCL color space whenever you can. But most importantly, it is essential to do some thinking before mapping data to color. The most basic question you always need to ask yourself is probably

> What is the nature of the data that I want to show? More precisely, is it sequential, diverging, or qualitative? 

Once you know this, it is easy to choose the appropriate color palette for the mapping. A good place to start for choosing palettes that are perceptually well thought through is [ColorBrewer](http://www.colorbrewer2.org).

Ok, so now let's start with the classic statistical plot, the scatter plot...


## Scatter plots (lattice)

Even with all the enhancements and progress made in the field of computer based graphics in recent years, or even decades, the best (as most intuitive) way to show the relationship between two continuous variables remains the scatter plot. Just like for the smoothest ride, the best shape of the wheel is still round.

If, from our original `diamonds` data set, we wanted to see the relation between price and carat of the diamonds (or more precisely how price is influenced by carat), we would use a scatter plot.


```r
scatter_lattice <- xyplot(price ~ carat, data = diamonds)
scatter_lattice
```

<div class="figure" style="text-align: center">
<img src="_main_files/figure-html/scatter-lattice-1.svg" alt="A basic scatter plot produced with **lattice**." width="80%" />
<p class="caption">(\#fig:scatter-lattice)A basic scatter plot produced with **lattice**.</p>
</div>

What we see is that, generally, lower carat values tend to be cheaper. However, there is a lot of scatter, especially at the high price end, i.e. there are diamonds of 1 carat that cost just as much as diamonds of 4 or more carat. So maybe this is a function of the cut? Let's see...

[//]: # (Another thing that we might be interested in is the nature and strength of the relationship that we see in our scatter plot. These plots are still the fundamental way of visualizing linear (and non-linear) statistics between 2 (or more) variables. In our case (and I said we will only be marginally touching statistics here) let's try to figure out what the linear relationship between x (cut) and y (price) is. Given that we are plotting cut on the y-axis and the general linear regression formula is ```y ~ a + b*x```, this means that we are assuming that cut is influencing (determining) price, NOT the other way round!!)

**lattice** is a very powerful package that provides a lot of flexibility and power to create all sorts of tailor-made statistical plots. In particular, it is designed to provide an easy-to-use framework for the representation of some variable(s) conditioned on some other variable(s). This means, that we can easily show the same relationship from figure 1, but this time for each of the different quality levels (the variable ```cut``` in the `diamonds` data set) into which diamonds are classified. These conditional subsets are called 'panels' in **lattice**.

This is done using the ```|``` character just after the formula expression. So the complete formula would read:

```
y ~ x | g
``` 

In other words, `y` is a function of `x` conditional to the values in `g` (where `g` is usually a factorial variable). The code below shows how all of this can be achieved, viz.

* plot ```price ~ carat``` conditional to ```cut```,
* draw the regression line for each panel, and
* also provide the R-squared value for each panel.


```r
scatter_lattice <- xyplot(price ~ carat | cut, 
                          data = diamonds, 
                          panel = function(x, y, ...) {
                            panel.xyplot(x, y, ...)
                            lm1 <- lm(y ~ x)
                            lm1sum <- summary(lm1)
                            r2 <- lm1sum$adj.r.squared
                            panel.abline(a = lm1$coefficients[1], 
                                         b = lm1$coefficients[2])
                            panel.text(labels = 
                                         bquote(italic(R)^2 == 
                                                  .(format(r2, 
                                                           digits = 3))),
                                       x = 4, y = 1000)
                            },
                          xscale.components = xscale.components.subticks,
                          yscale.components = yscale.components.subticks,
                          as.table = TRUE)

scatter_lattice
```

<div class="figure" style="text-align: center">
<img src="_main_files/figure-html/scatter-lattice-with-panels-and-line-1.svg" alt="A panel plot showing regression lines for each panel produced with **lattice**." width="672" />
<p class="caption">(\#fig:scatter-lattice-with-panels-and-line)A panel plot showing regression lines for each panel produced with **lattice**.</p>
</div>

This is where **lattice** becomes a bit more challenging, yet how do they say: with great power comes great complexity... Okay, maybe we didn't get this quote completely correct, but it certainly reflects the nature of **lattice**'s flexibility: A lot of things are possible, but they need a bit more effort than accepting the default settings.

Basically, what we have done here is to provide a so-called panel function (actually, we have provided 3 of them). But let's look at this step-by-step... 

As **lattice** is geared towards providing plots in small multiples (as [Edward Tufte](https://www.edwardtufte.com/tufte/) calls them) or panels, it provides an argument called `panel` to which we can assign certain functions that will be evaluated separately for each of the panels. There's a variety of pre-defined panel functions (such as the ones we used here - `panel.xyplot()`, `panel.abline()`, `panel.text()`), but we can also define our own panel functions. This is why **lattice** is so versatile and powerful. Basically, writing panel functions is just like writing any other function in R (though some limitations do exist).

The important thing to note here is that ```x``` and ```y``` in the context of panel functions refer to the ```x``` and ```y``` variables we define in the plot definition, i.e. ```x = carat``` and ```y = price```. So, for the panel functions we can use this shorthand, like as we are doing in defining our linear model as ```lm1 <- lm(y ~ x)```. This linear model will be calculated separately for each of the panels, which are basically nothing else than subsets of our data corresponding to the different levels of cut. Maybe it helps to think of this as a certain type of for loop:


```r
for (level in levels(cut)) 
  lm1 <- lm(price ~ carat)
```

This then enables us to access the outcome of this linear model separately for each panel and we can use ```panel.abline()``` to draw a line in each panel corresponding to the calculated model coefficients (i.e. intercept (`a`) and slope (`b`). Hence, we are drawing the regression line which represents the line of least squares for each panel separately.

The same holds true for the calculation and plotting of the adjusted R-squared value for each linear model per panel. In this case we use the ```panel.text()``` function to 'write' the corresponding value into each of the panel boxes. The location of the text is determined by the ```x = ``` and ```y = ``` arguments. This is where some care needs to be taken, as in the ```panel.text()``` call ```x``` and ```y``` don't refer to the ```x``` and ```y``` variables of the global plot function ```xyplot()``` anymore, but rather represent the locations of where to position the text within each of the panel boxes in the units used for each of the axes (in our case ```x = 4``` and ```y = 1000```).

There's two more things to note with regard to panel functions:

1. In order to draw what we originally intended to draw, i.e. the scatter plot, we need to provide a panel function that represents our initial intention. In our case this is the rather blank call ```panel.xyplot(x, y, ...)```. Without this, the points of our plot will not be drawn and we will get a plot that only shows the regression line and the text (feel free to try it!). This seems like a good place to introduce one of the most awkward (from a programming point of view) but at the same time most awesome (from a users point of view) things in the R language. The three magic dots (```...```) are a shorthand for "everything else that is possible in a certain function". This is both a very lazy and at the same time a very convenient way of passing arguments to a function. Basically, this enables us to provide any additional argument that the function might be able to understand. Any argument that ```xyplot()``` is able to evaluate (understand) can be passed in addition to ```x``` and ```y```. Try it out yourself by, for example, specifying ```col = "red"```. If we had not included ```...``` in the ```panel = function(x, y, ...)``` call, the ```col = ``` definition would not be possible. Anyway, this is only a side note that is not really related to the topic at hand, so let's move on....

2. The order in which panel functions are supplied does matter. This means that the first panel function will be evaluated (and drawn) first, then the second, then the third and so on. Hence, if we were to plot the points of our plot on top of everything else, we would need to provide the ```panel.xyplot()``` function as the last of the panel functions.

Right, so now we have seen how to use panel functions to calculate and draw things specific to each panel. One thing I really dislike about **lattice** is the default graphical parameter settings, in particular colors. However, changing these is rather straightforward. We can easily create our own themes by replacing the default values for each of the graphical parameters individually and saving these as our own themes. The function that lets us access the default (or already modified) graphical parameter settings is called ```trellis.par.get()```. By assigning this to a new object, we can modify every entry of the default settings to our liking (remember ```str()``` provides a 'road map' for accessing individual bits of an object).


```r
my_theme <- trellis.par.get()
my_theme$strip.background$col <- "grey80"
my_theme$plot.symbol$pch <- 16
my_theme$plot.symbol$col <- "grey60"
my_theme$plot.polygon$col <- "grey90"

l_sc <- update(scatter_lattice, par.settings = my_theme, 
               layout = c(3, 2),
               between = list(x = 0.3, y = 0.3))

print(l_sc)
```

<div class="figure" style="text-align: center">
<img src="_main_files/figure-html/latt-panel-scat2-1.svg" alt="A panel plot with modified settings of the **lattice** layout." width="672" />
<p class="caption">(\#fig:latt-panel-scat2)A panel plot with modified settings of the **lattice** layout.</p>
</div>

Apart from showing us how to change the graphical parameter settings, the above code chunk also highlights one of the very handy properties of **lattice** (which is also true for **ggplot2**). We are able to store any plot we create in an object and can refer to this object later. This enables us to simply ```update()``` the object rather than having to define it over (and over) again.

Like many other packages, **lattice** has a companion called **latticeExtra**. This package provides several additions and extensions to the core functionality of **lattice**. One of the very handy additions is a panel function called ```panel.smoother()``` which enables us to evaluate several linear and non-linear models for each panel individually. This means that we actually don't need to calculate these models 'by hand' for each panel, but can use this pre-defined function to evaluate them. This is demonstrated in the next code chunk.

Note that we are still calculating the linear model in order to be able to provide the R-squared value for each panel. We don't need ```panel.abline()``` to draw the regression line anymore. Actually, this is done using ```panel.smoother()``` which also provides us with an estimation of the standard error related to the mean estimation of ```y``` for each ```x```. This may be hard to see, but there is a confidence band of the standard error plotted around the regression line in each panel. 

For an overview of possible models to be specified using ```panel.smoother()```, see the corresponding help pages (`?panel.smoother`) from **latticeExtra**.


```r
scatter_lattice <- xyplot(price ~ carat | cut, 
                          data = diamonds, 
                          panel = function(x, y, ...) {
                            panel.xyplot(x, y, ...)
                            lm1 <- lm(y ~ x)
                            lm1sum <- summary(lm1)
                            r2 <- lm1sum$adj.r.squared
                            panel.text(labels = 
                                         bquote(italic(R)^2 == 
                                                  .(format(r2, 
                                                           digits = 3))),
                                       x = 4, y = 1000)
                            panel.smoother(x, y, method = "lm", 
                                           col = "black", 
                                           col.se = "black",
                                           alpha.se = 0.3)
                            },
                          xscale.components = xscale.components.subticks,
                          yscale.components = yscale.components.subticks,
                          as.table = TRUE)

l_sc <- update(scatter_lattice, par.settings = my_theme)

print(l_sc)
```

<div class="figure" style="text-align: center">
<img src="_main_files/figure-html/latt-panel-smooth-scat-1.svg" alt="A panel plot showing regression lines and confidence intervals for each **lattice** panel." width="672" />
<p class="caption">(\#fig:latt-panel-smooth-scat)A panel plot showing regression lines and confidence intervals for each **lattice** panel.</p>
</div>

Having a look at the scatter plots we have produced so far, there is an obvious problem. There are so many points that it is impossible to determine their actual distribution. One way to address this problem could be to plot each point in a semi-transparent manner. I have tried this potential solution and found that it does not help a great deal (but please, feel free to try this out for yourselves). Hence, we need another way to address the over-plotting of points.

A potential remedy is to map the 2-dimensional space, in which we create our plot, to a regular grid and estimate the point density in each of the cells. This can be done using a so-called 2-dimensional kernel density estimator. We won't have the time to go into much detail about this method here, but we will see how this can be done...

What is important for our purpose is that we actually need to estimate this twice. Once globally, meaning for the whole data set, in order to find the absolute extremes (minimum and maximum) of our data distribution. This is important for the color mapping, because the values of each panel need to be mapped to a common scale in order to interpret them. In other words, this way we are making sure that the similar values of our data are represented by similar shades of, let's say red. However, in order to be able to estimate the density for each of our panels we also need to do the same calculation in our panel function. 

Essentially what we are creating is a gridded data set (like a photo) of the density of points within each of the defined pixels. The **lattice** function for plotting gridded data is called ```levelplot()```. Here's the code:


```r
xy <- kde2d(x = diamonds$carat, y = diamonds$price, n = 100) 
xy_tr <- con2tr(xy)
offset <- max(xy_tr$z) * 0.2
z_range <- seq(min(xy_tr$z), max(xy_tr$z) + offset, offset * 0.01)

l_sc <- update(scatter_lattice, aspect = 1, par.settings = my_theme, 
               between = list(x = 0.3, y = 0.3),
               panel=function(x,y) {
                 xy <- kde2d(x,y, n = 100) 
                 xy.tr <- con2tr(xy)                 
                 panel.levelplot(xy_tr$x, xy_tr$y, xy_tr$z, asp = 1,
                                 subscripts = seq(nrow(xy_tr)), 
                                 contour = FALSE, region = TRUE, 
                                 col.regions = c("white", 
                                                 rev(clrs_hcl(10000))),
                                 at = z_range)
                 lm1 <- lm(y ~ x)
                 lm1sum <- summary(lm1)
                 r2 <- lm1sum$adj.r.squared
                 panel.abline(a = lm1$coefficients[1], 
                              b = lm1$coefficients[2])
                 panel.text(labels = 
                              bquote(italic(R)^2 == 
                                       .(format(r2, digits = 3))),
                            x = 4, y = 1000)
                 } 
               ) 

print(l_sc)
```

<div class="figure" style="text-align: center">
<img src="_main_files/figure-html/latt-dens-scat-1.svg" alt="A **lattice** panel plot of the point density within each panel created by `panel.levelplot()`." width="672" />
<p class="caption">(\#fig:latt-dens-scat)A **lattice** panel plot of the point density within each panel created by `panel.levelplot()`.</p>
</div>

It should not go unnoted that there is a panel function in **lattice** that does this for you. The function is called ```panel.smoothScatter()``` and unless we need to specify a custom color palette, this is more than sufficient. As a hint, if you want to use this panel function with your own color palette, you need to make sure that your palette starts with white as otherwise things will look really weird...


```r
l_sc_smooth <- update(scatter_lattice, aspect = 1, 
                      par.settings = my_theme, 
                      between = list(x = 0.3, y = 0.3),
                      panel = panel.smoothScatter)

print(l_sc_smooth)
```

```
## (loaded the KernSmooth namespace)
```

<div class="figure" style="text-align: center">
<img src="_main_files/figure-html/latt-smooth-scat-1.svg" alt="A **lattice** panel plot of the point density within each panel created by `panel.smoothScatter()`." width="672" />
<p class="caption">(\#fig:latt-smooth-scat)A **lattice** panel plot of the point density within each panel created by `panel.smoothScatter()`.</p>
</div>

This representation of our data basically adds another dimension to our plot which enables us to see that no matter which quality, most of the diamonds are actually of low carat and low price. Whether this is good or bad news depends on your interpretation (and the size of your wallet, of course).


## Scatter plots (ggplot2)

Now let's try to recreate our **lattice**-based achievements using **ggplot2**.

**ggplot2** is radically different from the way that **lattice** works. **lattice** is much closer to the traditional way of plotting in R. There are different functions for different types of plots. In **ggplot2** this is different. Every plot we want to draw is, at a fundamental level, created in exactly the same way. What differs are the subsequent calls on how to represent the individual plot components (basically ```x``` and ```y```). This means a much more consistent way of *building* visualizations, but it also means that things are rather different from what you might have learned about syntax and structure of (plotting) objects in R. But don't worry, even Tim managed to understand how things are done in **ggplot2** (and prior to writing this he had almost never used it before).

Before we get carried away too much, let's jump right into our first plot using **ggplot2**.


```r
scatter_ggplot <- ggplot(aes(x = carat, y = price), data = diamonds)

g_sc <- scatter_ggplot + geom_point()

print(g_sc)
```

<div class="figure" style="text-align: center">
<img src="_main_files/figure-html/gg-scat-1.svg" alt="A basic scatter plot created with **ggplot2**." width="672" />
<p class="caption">(\#fig:gg-scat)A basic scatter plot created with **ggplot2**.</p>
</div>

Similar to **lattice**, plots are (usually) stored in objects. But that is about all the similarity there is.

Let's look at the above code in a little more detail. The first line is the fundamental definition of **what** we want to plot. We provide the 'aesthetics' for the plot via ```aes()```. We state that we want the values on the x-axis to represent carat and the y-values are price. Furthermore, we want to take these variables from the `diamonds` data set. That's basically it, and this will not change a hell of a lot in the subsequent plotting routines.

What will change in the plotting code chunks that follow is **how** we want the relationship between these variables to be represented in our plot. This is done by defining so-called 'geometries' (```geom_...()```). In this first case, we stated that we want the relationship between ```x``` and ```y``` to be represented as points, hence we used ```geom_point()```.

If we wanted to provide a plot showing the relationship between price and carat in panels representing the quality of the diamonds, we need what in **ggplot2** is called 'faceting' (i.e. panels in **lattice**). To achieve this, we simply repeat our plotting call from earlier and add another layer to the call which does the faceting.


```r
g_sc <- scatter_ggplot + 
  geom_point() +
  facet_wrap(~ cut)

print(g_sc)
```

<div class="figure" style="text-align: center">
<img src="_main_files/figure-html/gg-facet-scat-1.svg" alt="The **ggplot2** version of a faceted plot." width="672" />
<p class="caption">(\#fig:gg-facet-scat)The **ggplot2** version of a faceted plot.</p>
</div>

If the plot we aim to create is a simple black-and-white scatter plot, as in our case here, a white facet background seems reasonable. However, there might be cases when a grey background, as used to be the default setting of **ggplot2** for quite a long time, is a better idea. This is particularly valid as soon as colors are involved as this tends to increase the contrast of the colors. In such cases, we could easily change the background color to grey using a pre-defined theme called ```theme_grey()``` (make sure to check out `?theme_grey` for a list of available themes).


```r
g_sc <- scatter_ggplot + 
  geom_point() +
  facet_wrap(~ cut) + 
  theme_grey()

print(g_sc)
```

<div class="figure" style="text-align: center">
<img src="_main_files/figure-html/gg-facet-scat-grey-1.svg" alt="The **ggplot2** version of a faceted plot with grey facet background." width="672" />
<p class="caption">(\#fig:gg-facet-scat-grey)The **ggplot2** version of a faceted plot with grey facet background.</p>
</div>

In order to provide the regression line for each panel like we did in **lattice**, we need a function called ```stat_smooth()```. This is fundamentally the same function that we used earlier, as the ```panel.smoother()``` in **lattice** is based on ```stat_smooth()```.

Putting this together we could do something like this (note that we also change the number of rows and columns into which the facets should be arranged):


```r
g_sc <- scatter_ggplot + 
  geom_point(color = "grey60") +
  facet_wrap(~ cut, nrow = 2, ncol = 3) +
  stat_smooth(method = "lm", se = TRUE, 
              fill = "black", color = "black")

print(g_sc)
```

<div class="figure" style="text-align: center">
<img src="_main_files/figure-html/gg-facet-smooth-scat-1.svg" alt="A faceted **ggplot2** plot with regression lines and confidence bands in each facet." width="672" />
<p class="caption">(\#fig:gg-facet-smooth-scat)A faceted **ggplot2** plot with regression lines and confidence bands in each facet.</p>
</div>

Simple and straightforward, and the result looks rather similar to the **lattice** version we created earlier.

Creating a point density scatter plot in **ggplot2** is actually a fair bit easier than in **lattice**, as **ggplot2** provides several predefined ```stat_*()``` functions. One of these is designed to create 2-dimensional kernel density estimations, just what we want. However, this is where the syntax of **ggplot2** really becomes a bit abstract. The definition of the fill argument of this call is ```..density..``` which, at least to me, does not seem very intuitive. 

Furthermore, it is not quite sufficient to supply the `stat_*()` function, we also need to state how to map the colors to that definition. Therefore, we need yet another layer which defines what color palette to use. As we want a continuous variable (density) to be filled with a gradient of _n_ colors, we need to use ```scale_fill_gradientn()``` in which we can define the colors we want to be used.


```r
g_sc <- scatter_ggplot + 
  geom_tile() +
  facet_wrap(~ cut, nrow = 3, ncol = 2) +
  stat_density2d(aes(fill = ..density..), n = 100,
                 geom = "tile", contour = FALSE) +
  scale_fill_gradientn(colors = c("white",
                                   rev(clrs_hcl(100)))) +
  stat_smooth(method = "lm", se = FALSE, color = "black") +
  coord_fixed(ratio = 5/30000)

print(g_sc)
```

<div class="figure" style="text-align: center">
<img src="_main_files/figure-html/gg-dens-scat-1.svg" alt="The **ggplot2** version of a panel plot showing point densities in each panel." width="80%" />
<p class="caption">(\#fig:gg-dens-scat)The **ggplot2** version of a panel plot showing point densities in each panel.</p>
</div>


## Box-and-Whisker Plots (lattice)

I honestly don't have a lot to say about boxplots. They are probably the most useful plots for showing the nature (or distribution) of your data and allow for some easy comparisons between different levels of a factor for example. See [Wikimedia](http://upload.wikimedia.org/wikipedia/commons/1/1a/Boxplot_vs_PDF.svg) for a visual representation of the standard R settings of boxplots in relation to mean and standard deviation of a normal distribution.

So without further ado, here's a basic **lattice** boxplot.


```r
bw_lattice <- bwplot(price ~ color, data = diamonds)
bw_lattice
```

<div class="figure" style="text-align: center">
<img src="_main_files/figure-html/latt-bw1-1.svg" alt="A basic boxplot produced with **lattice**." width="672" />
<p class="caption">(\#fig:latt-bw1)A basic boxplot produced with **lattice**.</p>
</div>

Not so very beautiful... So, let's again modify the standard ```par.settings``` so that we get an acceptable visual appearance of our boxplot. Much better, isn't it?


```r
bw_theme <- trellis.par.get()
bw_theme$box.dot$pch <- "|"
bw_theme$box.rectangle$col <- "black"
bw_theme$box.rectangle$lwd <- 2
bw_theme$box.rectangle$fill <- "grey90"
bw_theme$box.umbrella$lty <- 1
bw_theme$box.umbrella$col <- "black"
bw_theme$plot.symbol$col <- "grey40"
bw_theme$plot.symbol$pch <- "*"
bw_theme$plot.symbol$cex <- 2
bw_theme$strip.background$col <- "grey80"

l_bw <- update(bw_lattice, par.settings = bw_theme)

print(l_bw)
```

<div class="figure" style="text-align: center">
<img src="_main_files/figure-html/latt-bw2-1.svg" alt="A **lattice** boxplot with modified graphical parameter settings." width="672" />
<p class="caption">(\#fig:latt-bw2)A **lattice** boxplot with modified graphical parameter settings.</p>
</div>


```r
bw_lattice <- bwplot(price ~ color | cut, data = diamonds,
                     asp = 1, as.table = TRUE, varwidth = TRUE)
l_bw <- update(bw_lattice, par.settings = bw_theme, xlab = "color", 
               fill = clrs_hcl(7),
               xscale.components = xscale.components.subticks,
               yscale.components = yscale.components.subticks)

print(l_bw)
```

<div class="figure" style="text-align: center">
<img src="_main_files/figure-html/latt-panel-bw-1.svg" alt="A **lattice** panel boxplot with colored boxes and box widths relative to the number of observations." width="672" />
<p class="caption">(\#fig:latt-panel-bw)A **lattice** panel boxplot with colored boxes and box widths relative to the number of observations.</p>
</div>

In addition to the rather obvious provision of a color palette to fill the boxes, in this final boxplot we have also told **lattice** to adjust the widths of the boxes so that they reflect the relative sizes of the data samples for each of the factors (colors). This is a rather handy way of providing insight into the data distribution along the factor of the x-axis. We can show this without having to provide any additional plot to highlight that some of the factor levels (i.e. colors) are much less represented than others ('J' compared to 'G', for example, especially for the 'Ideal' quality class). 


## Box-and-Whisker Plots (ggplot2)

As much as we are **lattice** enthusiasts, we always end up drawing boxplots with **ggplot2** because they look so much nicer, meaning that there's no need to modify so many graphical parameter settings in order to get an acceptable result. You will see what I mean when we plot a **ggplot2** version using the default settings.


```r
bw_ggplot <- ggplot(diamonds, aes(x = color, y = price))

g_bw <- bw_ggplot + geom_boxplot()

print(g_bw)
```

<div class="figure" style="text-align: center">
<img src="_main_files/figure-html/gg-bw1-1.svg" alt="A basic **ggplot2** boxplot." width="672" />
<p class="caption">(\#fig:gg-bw1)A basic **ggplot2** boxplot.</p>
</div>

This is much better straight away! And, as we've already seen, the faceting requires also just one more line...


```r
bw_ggplot <- ggplot(diamonds, aes(x = color, y = price))

g_bw <- bw_ggplot + 
  geom_boxplot(fill = "grey90") +
  facet_wrap(~ cut)

print(g_bw)
```

<div class="figure" style="text-align: center">
<img src="_main_files/figure-html/gg-facet-bw-1.svg" alt="A faceted **ggplot2** boxplot." width="672" />
<p class="caption">(\#fig:gg-facet-bw)A faceted **ggplot2** boxplot.</p>
</div>

So far, you may have gotten the impression that pretty much everything is a little bit easier the **ggplot2** way. Well, a lot of things are, but some are not. If we wanted to highlight the relative sample sizes of the different color levels like we did earlier in **lattice** (using ```varwidth = TRUE```) we have to put a little more effort into **ggplot2**. Meaning, we have to calculate this ourselves. There is no built-in functionality for this feature (yet), at least none that I am aware of.

But anyway, it is not too complicated. The equation for this adjustment is rather straightforward, we simply take the square root of the counts for each color and divide it by the overall number of observations. Then we standardize this relative to the maximum of this calculation. As a final step, we need to break this down to each of the panels of the plot. This is the toughest part of it. I won't go into any detail here, but the ```llply()``` part of the following code chunk is basically the equivalent of what is going on behind the scenes of **lattice** (though the latter most likely does not use ```llply()```).

Anyway, it does not require too many lines of code to achieve the box width adjustment in **ggplot2**.


```r
w <- sqrt(table(diamonds$color)/nrow(diamonds))
### standardize w to maximum value
w <- w / max(w)

g_bw <- bw_ggplot + 
  facet_wrap(~ cut) +
  llply(unique(diamonds$color), 
        function(i) geom_boxplot(fill = clrs_hcl(7)[i],
                                 width = w[i], outlier.shape = "*",
                                 outlier.size = 3,
                                 data = subset(diamonds, color == i)))

print(g_bw)
```

<div class="figure" style="text-align: center">
<img src="_main_files/figure-html/gg-facet-width-bw-1.svg" alt="A faceted **ggplot2** boxplot with colored boxes and box widths relative to number of observations." width="672" />
<p class="caption">(\#fig:gg-facet-width-bw)A faceted **ggplot2** boxplot with colored boxes and box widths relative to number of observations.</p>
</div>

The result is very similar to what we have achieved earlier. In summary, **lattice** needs a little more care to adjust the standard graphical parameters, whereas **ggplot2** requires us to manually calculate the width of the boxes. WE leave it up to you which way suits you better... the two of us have already made our choice a few years ago ;-)

Boxplots are, as mentioned above, a brilliant way to visualize data distribution(s). Their strength lies in the comparability of different classes as they are plotted next to each other using a common scale. Another, more classical - as parametric - way are histograms and density plots.


## Histograms and Density Plots (lattice)

The classic way to visualize the distribution of any data are histograms. They are closely related to density plots, where the individual data points are not binned into certain classes but a continuous density function is calculated to show the distribution. Both approaches reflect a certain level of abstraction (binning vs. functional representation), therefore a general formulation of which of them is more accepted is hard. In any case, the both achieve exactly the same result, they will show us the distribution of our data.

As is to be expected with **lattice**, the default plotting routine does not really satisfy the (or maybe better our) aesthetic expectations.


```r
hist_lattice <- histogram(~ price, data = diamonds)
hist_lattice
```

<div class="figure" style="text-align: center">
<img src="_main_files/figure-html/altt-hist-1.svg" alt="A basic histogram produced with **lattice**." width="672" />
<p class="caption">(\#fig:altt-hist)A basic histogram produced with **lattice**.</p>
</div>

This is even worse for the default density plot...


```r
dens_lattice <- densityplot(~ price, data = diamonds)
dens_lattice
```

<div class="figure" style="text-align: center">
<img src="_main_files/figure-html/latt-dens-1.svg" alt="A basic density plot produced with **lattice**." width="672" />
<p class="caption">(\#fig:latt-dens)A basic density plot produced with **lattice**.</p>
</div>

Yet, as we've already adjusted our global graphical parameter settings, we can now easily modify this.


```r
hist_lattice <- histogram(~ price | color, 
                          data = diamonds,
                          as.table = TRUE,
                          par.settings = my_theme)

l_his <- hist_lattice

print(l_his)
```

<div class="figure" style="text-align: center">
<img src="_main_files/figure-html/latt-panel-hist-1.svg" alt="A **lattice** panel histogram with modified graphical parameter settings." width="672" />
<p class="caption">(\#fig:latt-panel-hist)A **lattice** panel histogram with modified graphical parameter settings.</p>
</div>

Now, this is a plot that every journal editor will very likely accept.

Until now, we have seen how to condition our plots according to one factorial variable (```diamonds$cut```). It is, in theory, possible to condition plots on any number of factorial variable, though more than two is seldom advisable. Two, however, is definitely acceptable and still easy enough to perceive and interpret. In **lattice** this is generally formulated as 

```
y ~ x | g + f
```

where ```g``` and ```f``` are the factorial variables used for the conditioning.

In the below code chunk, we are first creating our plot object. Then, we are using a function called ```useOuterStrips()``` which makes sure that the strips that correspond to the conditioning variables are plotted on both the top and the left side of our plot. The default **lattice** setting is to plot both at the top, which makes the navigation through the plot by the viewer a little more difficult.

Another default setting for density plots in **lattice** is to plot a point (circle) for each observation of our variable (price) at the bottom of the plot along the x--axis. In our case, as we have a lot of data points, this is not desirable, so we set ```plot.points = FALSE```.


```r
dens_lattice <- densityplot(~ price | cut + color, 
                            data = diamonds,
                            as.table = TRUE,
                            par.settings = my_theme,
                            plot.points = FALSE,
                            between = list(x = 0.2, y = 0.2),
                            scales = list(x = list(rot = 45)))

l_den <- useOuterStrips(dens_lattice)

print(l_den)
```

<div class="figure" style="text-align: center">
<img src="_main_files/figure-html/latt-panel-dens-1.svg" alt="A panel density plot conditioned according to two variables using **lattice**." width="672" />
<p class="caption">(\#fig:latt-panel-dens)A panel density plot conditioned according to two variables using **lattice**.</p>
</div>

You may have noticed that the lines of the density plot are plotted in a light shade of blue (cornflowerblue to be precise). It is up to you to change this...

Another thing you may notice when looking at the above plot is that the x-axis labels are rotated by 45 degrees. This one we also leave up to you to figure out... ;-)


## Histograms and Density Plots (ggplot2)

Much like with boxplots, the default settings of **ggplot2** are quite a bit nicer for both histograms and density plots.


```r
hist_ggplot <- ggplot(diamonds, aes(x = price))

g_his <- hist_ggplot +
  geom_histogram()

print(g_his)
```

<div class="figure" style="text-align: center">
<img src="_main_files/figure-html/gg-hist-eval-1.svg" alt="A basic histogram produced with **ggplot2**." width="672" />
<p class="caption">(\#fig:gg-hist-eval)A basic histogram produced with **ggplot2**.</p>
</div>

One thing that is really nice about the **ggplot2** density plots is that it is so easy to fill the area under the curve which really helps the visual representation of the data.


```r
dens_ggplot <- ggplot(diamonds, aes(x = price))

g_den <- dens_ggplot +
  geom_density(fill = "black", alpha = 0.5)

print(g_den)
```

<div class="figure" style="text-align: center">
<img src="_main_files/figure-html/gg-dens-1.svg" alt="A basic density plot produced with **ggplot2**." width="672" />
<p class="caption">(\#fig:gg-dens)A basic density plot produced with **ggplot2**.</p>
</div>

Just as before, we are encountering the rather peculiar way of **ggplot2** to adjust certain default settings to suit our needs (likes). If we wanted to show percentages instead of counts for the histograms, we again need to use the strange ```..something..``` syntax.

Another thing I want to highlight in the following code chunk is the way to achieve binary conditioning in **ggplot2**. This can be achieved through

```
facet_grid(g ~ f)
```

where, again, ```g``` and ```f``` are the two variables used for conditioning.


```r
g_his <- hist_ggplot +
  geom_histogram(aes(y = ..ncount..)) +
  scale_y_continuous(labels = percent_format()) +
  facet_grid(color ~ cut) + 
  ylab("Percent")

print(g_his)
```

<div class="figure" style="text-align: center">
<img src="_main_files/figure-html/gg-facet-hist-1.svg" alt="A faceted **ggplot2** histogram with percentages on the y-axis." width="672" />
<p class="caption">(\#fig:gg-facet-hist)A faceted **ggplot2** histogram with percentages on the y-axis.</p>
</div>

Similar to our **lattice** approach we're going to rotate the x-axis labels by 45 degrees.


```r
dens_ggplot <- ggplot(diamonds, aes(x = price))

g_den <- dens_ggplot +
  geom_density(fill = "black", alpha = 0.5) +
  facet_grid(color ~ cut) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

print(g_den)
```

<div class="figure" style="text-align: center">
<img src="_main_files/figure-html/gg-facet-density-1.svg" alt="A faceted **ggplot2** density plot conditioned according to two variables." width="672" />
<p class="caption">(\#fig:gg-facet-density)A faceted **ggplot2** density plot conditioned according to two variables.</p>
</div>

Ok, another thing we might want to show is a certain estimated value (like the mean of our sample) including error bars.


## Plotting Error Bars (lattice)

Honestly, **lattice** sucks at plotting error bars... Therefore, we will only explore one way of achieving this. In case you really want to explore this further, we refer you to StackOverflow and other R related forums and lists. You will possibly find a workable solution there, but we doubt that you will like it. As you will see in Section `{#gg-err}`, error bars are much easier plotted using **ggplot2**.


```r
my_theme$dot.symbol$col <- "black"
my_theme$dot.symbol$cex <- 1.5
my_theme$plot.line$col <- "black"
my_theme$plot.line$lwd <- 1.5

dmod <- lm(price ~ cut, data = diamonds)
cuts <- data.frame(cut = unique(diamonds$cut), 
                   predict(dmod, data.frame(cut = unique(diamonds$cut)), 
                           se = TRUE)[c("fit", "se.fit")])

errbar_lattice <- Hmisc::Dotplot(cut ~ Cbind(fit, 
                                             fit + se.fit, 
                                             fit - se.fit),
                                 data = cuts, 
                                 par.settings = my_theme)

l_err <- errbar_lattice

print(l_err)
```

<div class="figure" style="text-align: center">
<img src="_main_files/figure-html/latt-err-1.svg" alt="A **lattice** dotplot including error bars produced with `Hmisc::Dotplot()`." width="672" />
<p class="caption">(\#fig:latt-err)A **lattice** dotplot including error bars produced with `Hmisc::Dotplot()`.</p>
</div>


## Plotting Error Bars (ggplot2) {#gg-err}

As mentioned above, when plotting error bars **ggplot2** is much easier. Whether this is because of the general ongoing discussion about the usefulness of these plots I do not want to judge.

Anyway, plotting error bars in **ggplot2** is as easy as everything else...


```r
errbar_ggplot <- ggplot(cuts, aes(cut, fit, ymin = fit - se.fit, 
                                  ymax=fit + se.fit))
g_err <- errbar_ggplot + 
  geom_pointrange() +
  coord_flip() +
  theme_classic()

print(g_err)
```

<div class="figure" style="text-align: center">
<img src="_main_files/figure-html/gg-err-1.svg" alt="A **ggplot2** dotplot including error bars and using a classic theme." width="672" />
<p class="caption">(\#fig:gg-err)A **ggplot2** dotplot including error bars and using a classic theme.</p>
</div>

Especially, when plotting them as part of a bar plot.


```r
g_err <- errbar_ggplot + 
  geom_bar(stat = "identity", fill = "grey80") +
  geom_errorbar(width = 0.2) +
  coord_flip() +
  theme_classic()

print(g_err)
```

<div class="figure" style="text-align: center">
<img src="_main_files/figure-html/gg-err-bar-1.svg" alt="A **ggplot2** bar plot including error bars and using a classic theme." width="672" />
<p class="caption">(\#fig:gg-err-bar)A **ggplot2** bar plot including error bars and using a classic theme.</p>
</div>

Just as before with the box widths, though, applying this to each facet is a little more complicated... But still, trust us on this, much easier than to achieve the same result in **lattice**.


```r
errbar_ggplot_facets <- ggplot(diamonds, aes(x = color, y = price))

### function to calculate the standard error of the mean
se <- function(x) sd(x)/sqrt(length(x))

### function to be applied to each panel/facet
myFun <- function(x) {
  data.frame(ymin = mean(x) - se(x), 
             ymax = mean(x) + se(x), 
             y = mean(x))
  }

g_err_f <- errbar_ggplot_facets + 
  stat_summary(fun.y = mean, geom = "bar", 
               fill = rep(clrs_hcl(7), 5)) + 
  stat_summary(fun.data = myFun, geom = "linerange") + 
  facet_wrap(~ cut)

print(g_err_f)
```

<div class="figure" style="text-align: center">
<img src="_main_files/figure-html/gg-facet-err-bar-1.svg" alt="A **ggplot2** panel bar plot with error bars and modified fill colors." width="672" />
<p class="caption">(\#fig:gg-facet-err-bar)A **ggplot2** panel bar plot with error bars and modified fill colors.</p>
</div>

<!--chapter:end:02-data-visualisation.Rmd-->

# Manipulating Plots with the grid Package

Okay, so now we have seen how to produce a variety of widely used plot types using both **lattice** and **ggplot2**. I hope that, apart from the specifics, you also obtained a general idea of how these two packages work and how you may use the various things we've touched upon in scenarios other than the ones provided here.

Now, we're moving on to a more basic and much more flexible level of modifying, constructing and arranging graphs. Both **lattice** and **ggplot2** are based on the **grid** package. This means that we can use this package to fundamentally modify whatever we've produced (remember, we're always storing our plots in objects) in a much more flexible way than provided by any of these packages.

With his **grid** package, Paul Murrell has achieved nothing less than a highly sophisticated and, in our opinion, much more flexible and powerful plotting framework for R. This has also been 'officially' recognized by the R Core Team as Paul is now a member of the very same (at least to our knowledge) and his **grid** package is shipped with the base version of R. This means that we don't have to install the package anymore (however, we still have to load it via ```library(grid)```).

In order to fully appreciate the possibilities of the **grid** package, it helps to think of this package as a package for drawing things. Yes, we're not producing statistical plots as such (for this we have **lattice** and **ggplot2**), we're actually _drawing_ things!

The fundamental features of the **grid** package are the ```viewports```. By default, the whole plotting area, may it be the standard R or any other such plotting device (e.g. `png()`), is considered as the root viewport (basically like the ```home/<username>``` folder on Linux or the ```C:\Users\<username>``` folder on Windows). In this viewport we now have the possibility to specify other viewports which are relative to the root viewport (just like the ```Users\<username>\Documents``` folder on Windows or ```home/<username>/Downloads``` under Linux). 

The very important thing to realize here is that in order to do anything in this folder (be it creating another sub-folder, or simply saving a file, or whatever), we first need to _create_ the folder and then we need to _navigate_ into it. If you keep this in mind, you will quickly understand the fundamental principle of **grid**.

When we start using the **grid** package, we always start with the 'root' viewport. This is already available, it is created for us, so we don't need to do anything. This is our starting point. The really neat thing about **grid** is that each viewport is, by default, defined as ranging from 0 to 1 in both x and y direction. For example, the lower left corner is defined as `x = 0` and `y = 0`. Accordingly, the lower right corner is `x = 1` and `y = 0`, the upper right corner is `x = 1` and `y = 1` and so on... 

It is, however, possible to specify a myriad of different unit systems (type ```?grid::unit``` to get an overview of what is available). We usually stick to the default settings called `npc` ('Normalised Parent Coordinates') which range from 0 to 1 in each direction, as this makes setting up viewports very intuitive (as demonstrated above).

A viewport needs some basic specifications for it to be located somewhere in the plotting area (the current viewport). These are:

* `x` - location along the x-axis
* `y` - location along the y -axis
* `width` - width of the viewport
* `height` - height of the viewport
* `just` - justification of the viewport in both x and y directions

Here, `width` and `height` should be rather self-explanatory. On the other hand, `x`, `y` and `just` are a bit more mind-bending. By default, `x = y = 0.5` and `just = cemtre`. This means that the new viewport will be positioned at `x = 0.5` and `y = 0.5`. The default of `just` is `centre` which means that a new viewport will be created at the midpoint of the current viewport (`x, y`) and centered on this point. It helps to think of the `just` specification in the same way that you provide your text justification in an Office software (left, right, centre & justified). Let's try a first example which should highlight the way this works.




```r
library(grid)
```

<div class="figure" style="text-align: center">
<img src="_main_files/figure-html/grid-first-vp-1.svg" alt="Producing a standard viewport using **grid**." width="672" />
<p class="caption">(\#fig:grid-first-vp)Producing a standard viewport using **grid**.</p>
</div>

```r
grid.newpage() # open a new (ie empty) 'root' viewport

grid.rect()
grid.text("this is the root vp", x = 0.5, y = 0.95, 
          just = c("centre", "top"))

our_first_vp <- viewport(x = 0.5, y = 0.5, 
                         height = 0.5, width = 0.5,
                         just = c("centre", "centre"))

pushViewport(our_first_vp)

grid.rect(gp = gpar(fill = "pink"))
grid.text("this is our first vp", x = 0.5, y = 0.95, 
          just = c("centre", "top"))
```

<div class="figure" style="text-align: center">
<img src="_main_files/figure-html/grid-first-vp-2.svg" alt="Producing a standard viewport using **grid**." width="672" />
<p class="caption">(\#fig:grid-first-vp)Producing a standard viewport using **grid**.</p>
</div>

Okay, so now we have created a new viewport in the middle of the current (i.e. 'root') viewport that is half the height and half the width of its root. Afterwards, we navigated into this new viewport using `pushViewport()` and drew a pink-filled rectangle spanning the entire area using `grid.rect()`.

Note that we didn't leave the viewport yet. This means that, whatever we do now, will happen in the currently active viewport (i.e. the pink one). To illustrate this, we will simply repeat the exact same code from above once more.


```r
our_first_vp <- viewport(x = 0.5, y = 0.5, 
                         height = 0.5, width = 0.5,
                         just = c("centre", "centre"))

pushViewport(our_first_vp)

grid.rect(gp = gpar(fill = "cornflowerblue"))
```

<div class="figure" style="text-align: center">
<img src="_main_files/figure-html/grid-second-vp-1.svg" alt="Producing a second viewport using **grid**." width="672" />
<p class="caption">(\#fig:grid-second-vp)Producing a second viewport using **grid**.</p>
</div>

In more practical terms, this means that whatever viewport we are currently in, this one defines our reference system (0 to 1). In case you don't believe me, we can repeat this procedure five times more...


```r
for (i in 1:5) {
  our_first_vp <- viewport(x = 0.5, y = 0.5, 
                           height = 0.5, width = 0.5,
                           just = c("centre", "centre"))
  
  pushViewport(our_first_vp)
  
  grid.circle(gp = gpar(fill = colors()[i*3]))
}
```

<div class="figure" style="text-align: center">
<img src="_main_files/figure-html/grid-several-vps-1.svg" alt="Producing several viewports using **grid**." width="672" />
<p class="caption">(\#fig:grid-several-vps)Producing several viewports using **grid**.</p>
</div>

Now that should be proof enough! We are cascading down viewports always creating a rectangle that fills half the 'mother' viewport at each step. Yet, as the 'mother' viewport becomes smaller and smaller, our rectangles also become smaller along the way (programmers would actually call these steps iterations, but we won't be bothered here...).

So, how do we navigate back? If we counted correctly, we went down 7 rabbit holes. In order to get out of these again, we need to use `upViewport(7)` and, in order to verify that we are back in 'root', we may ask **grid** what viewport we are currently in.



```r
upViewport(7)

current.viewport()
```

```
## viewport[ROOT]
```

Sweet, we're back in the 'root' viewport... (by the way, `upViewport(0)` would have taken us right up to the 'root' viewport without the requirement for counting, see `?grid::upViewport`).

Now, let's see how this `just` parameter works. As you have seen we are now in the 'root' viewport. Let's try to draw another rectangle that sits right at the top left corner of the pink one. In theory the lower right corner of this viewport should be located at `x = 0.25` and `y = 0.75`. If we specify it like this, we need to adjust the justification, because we do not want to center it on these coordinates. If these coordinates are the point of origin, this viewport should be justified right horizontally and bottom vertically. And the space we have to plot should be `0.25` vertically and `0.25` horizontally. Let's try this...


```r
top_left_vp <- viewport(x = 0.25, y = 0.75, 
                        height = 0.25, width = 0.25,
                        just = c("right", "bottom"))

pushViewport(top_left_vp)

grid.rect(gp = gpar(fill = "grey", alpha = 0.5))
```

<div class="figure" style="text-align: center">
<img src="_main_files/figure-html/grid-top-left-vp-1.svg" alt="Producing yet another viewport using **grid**." width="672" />
<p class="caption">(\#fig:grid-top-left-vp)Producing yet another viewport using **grid**.</p>
</div>



I hope that you have understood two things now:

1. How to create and navigate between viewports, and
2. Why I said earlier that **grid** is a package for drawing.

Assuming that you have understood these two points, let's make use of the first one and use this incredibly flexible plotting framework for arranging multiple plots on one page.


## Multiple Plots per Page

In order to succeed plotting several of our previously created plots on one page, there's two things of importance:

1. The **lattice** and **ggplot2** plot objects need to be printed using `print` , and
2. We need to set `newpage = FALSE` in the print call so that the previously drawn elements are not deleted.

Let's try and plot some of these plots next to each other on one page by setting up a suitable viewport structure. First of all, we obviously need to produce plots. Note that we will use very basic plots here, but this should work with whatever **lattice** or **ggplot2** object you have created earlier.


```r
p1_lattice <- xyplot(price ~ carat, data = diamonds)
p2_lattice <- histogram(~ price, data = diamonds)

p1_ggplot <- ggplot(aes(x = carat, y = price), data = diamonds) +
  geom_point()
p2_ggplot <- ggplot(diamonds, aes(x = price)) +
  geom_histogram()

### clear plot area
grid.newpage()

### define first plotting region (viewport)
vp1 <- viewport(x = 0, y = 0, 
                height = 0.5, width = 0.5,
                just = c("left", "bottom"),
                name = "lower left")

### enter vp1 
pushViewport(vp1)

### show the plotting region (viewport extent)
grid.rect()

### plot a plot - needs to be printed (and newpage set to FALSE)!!!
print(p1_lattice, newpage = FALSE)

### leave vp1 - up one level (into root vieport)
upViewport(1)

### define second plot area
vp2 <- viewport(x = 1, y = 0, 
                height = 0.5, width = 0.5,
                just = c("right", "bottom"),
                name = "lower right")

### enter vp2
pushViewport(vp2)

### show the plotting region (viewport extent)
grid.rect()

### plot another plot
print(p2_lattice, newpage = FALSE)

### leave vp2
upViewport(1)


vp3 <- viewport(x = 0, y = 1, 
                height = 0.5, width = 0.5,
                just = c("left", "top"),
                name = "upper left")

pushViewport(vp3)

### show the plotting region (viewport extent)
grid.rect()

print(p1_ggplot, newpage = FALSE)

upViewport(1)


vp4 <- viewport(x = 1, y = 1, 
                height = 0.5, width = 0.5,
                just = c("right", "top"),
                name = "upper right")

pushViewport(vp4)

### show the plotting region (viewport extent)
grid.rect()

print(p2_ggplot, newpage = FALSE)

upViewport(1)
```

<div class="figure" style="text-align: center">
<img src="_main_files/figure-html/grid-multiple-1.svg" alt="Using **grid** to arrange multiple plots on one page." width="960" />
<p class="caption">(\#fig:grid-multiple)Using **grid** to arrange multiple plots on one page.</p>
</div>

So there we have it. Creating and navigating between viewports enables us to build a graphical layout in whatever way we want. In our opinion, this is way better than saving all the plots to the hard drive and then using some sort of graphics software such as [Adobe Photoshop](https://de.wikipedia.org/wiki/Adobe_Photoshop) or [Inkscape](https://de.wikipedia.org/wiki/Inkscape) to arrange the plots onto one page. After all, sometimes we may have several of these multi-plot pages that we want to produce. As of now, we know how to do this automatically, thus rendering any post-production steps unnecessary.


## Manipulating Existing Plots

Another application of **grid** is to manipulate an existing plot object. You may have noted that our version of the 2-dimensional density scatter plot produced with **lattice** lacks a color key. Looking at the **ggplot2** version of the density scatter, by contrast, we see that this one already has a color key which is placed to the right of the main plot. 

As regards the **lattice** version, a color key can be easily added using **grid**. Since **lattice** is built upon **grid**, it produces a lot of viewports in the creation of the plots (like our scatter plot). After these have been set up, we can navigate to each of them and edit (or delete) them or add new stuff. Given that we have five panels, we actually have some 'white' space left in the bottom-right corner that we could use for the color key placement, thus making better use of the available space...

In order to do so, we need to know into which of the viewports we need to navigate. Luckily, **lattice** provides a structured naming convention for its viewports, which makes navigating between single viewports rather easy. Since we are interested in the area covered by the main figure only, we will use `trellis.vpname("figure")` to extract the name of the corresponding viewport and pass this on to `downViewport()` in order to navigate to it. You will notice that this is very similar to `pushViewport()`, except for the target viewport being already there. 

Like that, we can set up a new viewport in the main plotting area (the 'figure' viewport) to make use of the existing white space. Remember that the default units of **grid** range from 0 to 1. This means that we can easily calculate the necessary viewport dimensions. Let's see how this is done (note that we are actually creating two new viewports in the figure area, one for the color key and another one for the color key label).


```r
my_theme <- trellis.par.get()
my_theme$strip.background$col <- "grey80"
my_theme$plot.symbol$pch <- 16
my_theme$plot.symbol$col <- "grey60"
my_theme$plot.polygon$col <- "grey90"

scatter_lattice <- xyplot(price ~ carat | cut, 
                          data = diamonds, 
                          panel = function(x, y, ...) {
                            panel.xyplot(x, y, ...)
                            lm1 <- lm(y ~ x)
                            lm1sum <- summary(lm1)
                            r2 <- lm1sum$adj.r.squared
                            panel.text(labels = 
                                         bquote(italic(R)^2 == 
                                                  .(format(r2, 
                                                           digits = 3))),
                                       x = 4, y = 1000)
                            panel.smoother(x, y, method = "lm", 
                                           col = "black", 
                                           col.se = "black",
                                           alpha.se = 0.3)
                            },
                          xscale.components = xscale.components.subticks,
                          yscale.components = yscale.components.subticks,
                          as.table = TRUE)

l_sc <- update(scatter_lattice, par.settings = my_theme)
xy <- kde2d(x = diamonds$carat, y = diamonds$price, n = 100) 
xy_tr <- con2tr(xy)
offset <- max(xy_tr$z) * 0.2
z_range <- seq(min(xy_tr$z), max(xy_tr$z) + offset, offset * 0.01)

l_sc <- update(scatter_lattice, aspect = 1, par.settings = my_theme, 
               between = list(x = 0.3, y = 0.3),
               panel=function(x,y) {
                 xy <- kde2d(x,y, n = 100) 
                 xy_tr <- con2tr(xy)                 
                 panel.levelplot(xy_tr$x, xy_tr$y, xy_tr$z, asp = 1,
                                 subscripts = seq(nrow(xy_tr)), 
                                 contour = FALSE, region = TRUE, 
                                 col.regions = c("white", 
                                                 rev(clrs_hcl(10000))),
                                 at = z_range)
                 lm1 <- lm(y ~ x)
                 lm1sum <- summary(lm1)
                 r2 <- lm1sum$adj.r.squared
                 panel.abline(a = lm1$coefficients[1], 
                              b = lm1$coefficients[2])
                 panel.text(labels = 
                              bquote(italic(R)^2 == 
                                       .(format(r2, digits = 3))),
                            x = 4, y = 1000)
                 #panel.xyplot(x,y) 
                 } 
               ) 


grid.newpage()
#grid.rect()
print(l_sc, newpage = FALSE)
#grid.rect()
downViewport(trellis.vpname(name = "figure"))
#grid.rect()
vp1 <- viewport(x = 1, y = 0, 
                height = 0.5, width = 0.3,
                just = c("right", "bottom"),
                name = "legend.vp")

pushViewport(vp1)
#grid.rect()

vp1_1 <- viewport(x = 0.2, y = 0.5, 
                  height = 0.7, width = 0.5,
                  just = c("left", "centre"),
                  name = "legend.key")

pushViewport(vp1_1)
#grid.rect()

key <- draw.colorkey(key = list(col = c("white", rev(clrs_hcl(10000))),
                                at = z_range), draw = TRUE)

seekViewport("legend.vp")
#grid.rect()
vp1_2 <- viewport(x = 1, y = 0.5, 
                  height = 1, width = 0.3,
                  just = c("right", "centre"),
                  name = "legend.text", angle = 0)

pushViewport(vp1_2)
#grid.rect()

grid.text("estimated point density", 
          x = 0, y = 0.5, rot = 270, 
          just = c("centre", "bottom"))

upViewport(3)
```

<div class="figure" style="text-align: center">
<img src="_main_files/figure-html/grid-manipulate-1.svg" alt="Using **grid** to add a color key to an existing **lattice** plot object." width="960" />
<p class="caption">(\#fig:grid-manipulate)Using **grid** to add a color key to an existing **lattice** plot object.</p>
</div>

Not too complicated, is it? And, in comparison to the **ggplot2** version, we are utilizing the available space a bit more efficiently. Though, obviously, we could also manipulate the **ggplot2** density scatter plot (or any other plot) in a similar manner. In general, we hope that it has become clear just how useful **grid** can be and how it provides us with tools which enable us to produce individual graphics that satisfy our needs. 

So far, we have put our efforts into plot creation and learned about a variety of tools that can help us achieve what we want. As a next logical step, let's see how we can save our graphics to our hard drive.

<!--chapter:end:03-data-manipulation.Rmd-->

# Saving your Visualizations {#saving}

Saving graphics in R is, in theory, straightforward. We simply need to call a suitable device. There are a number of different plotting devices available. Here, we will introduce 4 examples, `tiff()`, `png()`, `postscript()`, and `pdf()`. The latter two should be used for vector graphics (e.g. line plots, point plots, polygon plots etc.), whereas `tiff()` and `png()` are preferable for raster graphics (e.g. photos, our density scatter plot or anything pixel based).

All the graphics devices in R basically work the same way:

1. Open the respective device (postscript, png, etc.),
2. Plot (or in our case `print()`) the plot objects, and
3. Close the device using `dev.off()` - otherwise the file will not be written to the hard drive.

In code, this is:


```r
png("some_filename.png", width = 10, height = 10, units = "cm", res = 300)
## here goes your plotting routine, e.g.: xyplot(1:10 ~ 1:10)
invisible(dev.off())
```

Sounds rather easy, but as they say, the devil is in the details... Unfortunately, neither **lattice** nor **ggplot2** graphics play very well with the respective graphics devices. Consider the following setting where we want to produce a `tiff` output with a resolution of 300 dpi, a width of 17.35 cm, a height of 23.35 cm, the font family "ArialMT" and a point size of 18.

Instead of saving a graph, however, we only check whether the point size of 18 is passed correctly to the respective plotting environment (i.e. `base graphics`, **lattice** and **ggplot2**).


```r
tiff("test.tif", family = "ArialMT", units = "cm",
     width = 17.35, height = 23.35, pointsize = 18, res = 300)

# query base graphics graphical parameter text size (pointsize)
par()$ps
```

```
## [1] 18
```

```r
# query lattice text size
trellis.par.get()$fontsize$text
```

```
## [1] 12
```

```r
# query ggplot2 text size
theme_bw()$text$size
```

```
## [1] 11
```

```r
# turn device off
invisible(dev.off())
```

We see that neither **lattice** nor **ggplot2** adhere to the specified point size whereas `base graphics` do. Let's try this for the other devices, too. First, `png`:


```r
png("test.png", family = "ArialMT", units = "cm",
     width = 17.35, height = 23.35, pointsize = 18, res = 300)
# query base graphics graphical parameter text size (pointsize)
par()$ps
```

```
## [1] 18
```

```r
# query lattice text size
trellis.par.get()$fontsize$text
```

```
## [1] 12
```

```r
# query ggplot2 text size
theme_bw()$text$size
```

```
## [1] 11
```

```r
# turn device off
invisible(dev.off())
```

Similar to `tiff`. Now for `eps`:


```r
postscript("test.eps", family = "ArialMT",
           width = 17.35 / 2.54, height = 23.35 / 2.54, pointsize = 18)
# query base graphics graphical parameter text size (pointsize)
par()$ps
```

```
## [1] 18
```

```r
# query lattice text size
trellis.par.get()$fontsize$text
```

```
## [1] 12
```

```r
# query ggplot2 text size
theme_bw()$text$size
```

```
## [1] 11
```

```r
# turn device off
invisible(dev.off())
```

Finally, for `pdf`:


```r
pdf("test.pdf", family = "ArialMT",
    width = 17.35 / 2.54, height = 23.35 / 2.54, pointsize = 18)
# query base graphics graphical parameter text size (pointsize)
par()$ps
```

```
## [1] 18
```

```r
# query lattice text size
trellis.par.get()$fontsize$text
```

```
## [1] 12
```

```r
# query ggplot2 text size
theme_bw()$text$size
```

```
## [1] 11
```

```r
# turn device off
invisible(dev.off())
```

... and we see that only `base graphics` really correctly sets the supplied font size.

Alright, this was only a small exercise to highlight the fact, that it is not straightforward to get that fine control over graphics output in R. But before we dive into this deeper, we will first need to know what it is that we want to achieve, meaning we need a precise definition of the guidelines our graphics output should adhere to. Generally, academic journals provide formatting guidelines for both figures and tables. These, however, differ from journal to journal so that it is impossible to come up with a one-fits-all solution here. Therefore, we will pick one of these guides to highlight the process of achieving the desired formatting which can then be adapted to any other formatting guide. Even though this is in R terms not directly related to exporting visualizations through different devices, these finer controls will be covered her, as from an academic publishing point of view this is exactly the point where we need to start thinking about these formatting issues.

Depending on the journal the formatting guidelines can be quite detailed, though some journals allow for more flexibility. Generally, there are a few parameters that the majority of journals define in their formatting guides. These include (but are surely not limited to):

* file types
* font size
* font family (font type)
* dimensions
* resolution (in case of raster graphics)

In case of more rigid formatting guidelines, further rules may be imposed on:

* color mode
* background color
* lines and strokes
* file size
* orientation

As an example, we will use the [artwork guidelines](http://www.plosone.org/static/figureGuidelines#figures) from PLOS ONE, for which more details are listed [here](http://www.plosone.org/static/figureSpecifications). 

For `tiff` images the requirements are as follows:

* __width:__ 8.30 cm (one column images), 17.35 (two column images)
* __maximum height:__ 23.35 cm (caption will not fit on the same page then)
* __minimum resolution:__ 300 ppi
* __compression:__ LZW
* __color mode:__ RGB (millions of colors), 8 bits per channel
* __background:__ white, not transparent
* __layers:__ a single layer called "Background"
* __text:__ font types Arial, Times or Symbol 6 - 12 pt
* __lines:__ line width between 0.5 to 1.5 pt
* __white space:__ a 2 pt white space around each figure is recommended
* __file size:__ 10 MB max
* __orientation:__ up to the author

Additionally, some general remarks on software related issues can be found [here](http://www.plosone.org/static/figureInstructions). From the latter I quote:

> Numerous programs can create figures but are not dedicated to working with graphics. These may be limited in their capability to create TIFFs or EPSs that comply with PLOS specifications. Such applications include ChemDraw, Haploview, PyMol, R, ImageMagick, Corel Draw, GeneSpring, Matlab, Origin, Prism, Sigmaplot, and Stata. To create a high-quality TIFF from images created in other applications, use the instructions below to convert to PDF and then to TIFF or EPS.

This basically means that we should not directly export our graphics from R to either `tiff` or `eps` (the only two file formats accepted by PLOS ONE), but rather save them as a `pdf` and then follow [this guide](http://www.plosone.org/static/figureInstructions#convertingfigs) on how to convert the `pdf` to acceptable `tiff` or `eps` formats. Here, we will cover all of these, so whether you send an original R `tiff` or convert it from the R `pdf` is completely up to you.

Ok, so let's start with the `tiff` device...


## Tagged Image File Format

In all of the following chapters we will first create very basic **lattice** and **ggplot2** plot objects:


```r
p_lattice <- xyplot(price ~ carat, data = diamonds)
p_ggplot <- ggplot(aes(x = carat, y = price), data = diamonds) +
  geom_point()
```

Ok, so we have our basic plot objects that we want to export as `tiff` images. Note that for graphics of points and lines it is usually preferred to export them using a vector graphics device (`eps` or `pdf`) but for the sake of demonstration, we will not care about this right now and export our scatter plot as `tiff` anyway (`eps` and `pdf` examples follow). In all the examples that follow, we will produce figures that are maximum width (17.35 cm) and maximum height (23.35 cm) according to the PLOS ONE specifications. Furthermore, we will always first see how this is done with lattice, then with ggplot2.

For `tiff` the default settings are as follows (PLOS ONE requirements in brackets):

* width and heigth: 480 (max 2049 / 2758)
* units: "px" - pixels (n.a.)
* pointsize: 12 (6 - 12)
* compression: "none" (LZW)
* bg (background): "white" (white)
* res (resolution): NA - this basically means 72 ppi (300 - 600 ppi)
* type: system dependent (check with `getOption("bitmapType")`)
* family: system dependent - on Linux X11 it is "Helvetica" (Arial, Times, Symbol)

If we want to use units different from pixels for our width and height specifications, we need to supply a resolution to be used through `res`. 

So, the first thing to do is open the `tiff` device. In order to comply with PLOS ONE we set:

* width to 17.35
* height to 23.35
* res to 300
* compression to "lzw"


```r
tiff("test_la.tif", width = 17.35, height = 23.35, units = "cm", res = 300,
     compression = "lzw")
```

then, we render our plot object:


```r
print(p_lattice)
```

and finally, we close our device:


```r
invisible(dev.off()) # dev.off() is sufficient. Invisible suppresses text.
```

This will create a `tiff` image of our plot with a text point size of 12 for the axis labels, a point size of 10 for the axis tick labels and a point size of 14 for the plot title (iff supplied). As we have seen, both **lattice** and **ggplot2** ignore any parameter passed to the device via `pointsize`. Therefore, in case we want to change the point size of the text in our plot, we need to achieve this in another way. 

In the following setup we will change the default font size to 20 pt and the axis tick labels to _italic_.


```r
tiff_theme <- trellis.par.get()
tiff_theme$fontsize$text <- 20
tiff_theme$axis.text$font <- 3

print(update(p_lattice, par.settings = tiff_theme))
```

<img src="_main_files/figure-html/change-pointsize-tiff-1.svg" width="672" />

In order to export the graphic we simply wrap the above between the `tiff()` and `dev.off()` calls (note here that we change the default font family to "Times" - check the exported image):


```r
tiff("test_la.tif", width = 17.35, height = 23.35, units = "cm", res = 300,
     compression = "lzw")

tiff_theme <- trellis.par.get()
tiff_theme$fontsize$text <- 20
tiff_theme$axis.text$font <- 3

print(update(p_lattice, par.settings = tiff_theme))

invisible(dev.off())
```

This, however, does change the axis label text to a point size of `20`, but the axis ticks are labelled with a point size of `16`. This is because **lattice** uses so-called `character expansion (short cex)` factors for different regions of the plot. Axis tick labels have `cex = 0.8` and the title has `cex = 1.2`. Therefore, the tick labels will be `fontsize * cex` i.e. `20 * 0.8` in point size. We can, however, change this as well. 

In the following we will change the axis font size to 10 and the axis tick label font size to 17.5:


```r
# tiff("test_la.tif", width = 17.35, height = 23.35, units = "cm", res = 300,
#      compression = "lzw")

tiff_theme <- trellis.par.get()
tiff_theme$fontsize$text <- 12 # set back to base fontsize 12
expansion_axislabs <- 10/12
expansion_ticks <- 17.5/12
tiff_theme$par.xlab.text$cex <- expansion_axislabs
tiff_theme$par.ylab.text$cex <- expansion_axislabs
tiff_theme$axis.text$cex <- expansion_ticks

print(update(p_lattice, par.settings = tiff_theme))
```

<img src="_main_files/figure-html/change-relative-pointsize-tiff-1.svg" width="672" />

```r
# invisible(dev.off())
```

The same also applies if you use `panel.text()` or `panel.key()`. Use the `cex` parameter to adjust to the font size you want your text to be.

Ok, so much for **lattice**. Let's see how we can change things in **ggplot2**.

The equivalent to the `par.settings = ` in **lattice** are the different `theme_`s in **ggplot2**. We have already seen this in the **ggplot2** queries of the text size in Section \@ref(saving). However, the way we set the font size is not at all equivalent. We are not allowed to assign a new value to the themes like e.g. `theme_bw()$text$size <- 5`. But ggplot2 provides functionality to set the font size via `theme_set()` with the parameter `base_size`:


```r
theme_set(theme_bw(base_size = 25))

print(p_ggplot +
        theme_bw())
```

<img src="_main_files/figure-html/change-pointsize-gg-tiff-1.svg" width="672" />

Apart from `theme_set()` which changes the theme globally there is also a function called `theme_update()` which changes parameters for the current theme in use. Once you change to a different theme, these settings will be neglected. 

**Note, we need to supply the absolute point sizes to these functions, not the relative expansion factors!**


```r
theme_set(theme_bw(base_size = 10))
theme_update(axis.text = element_text(size = 17.5, face = "italic"))

print(p_ggplot)
```

<img src="_main_files/figure-html/change-themes-gg-tiff-1.svg" width="672" />

```r
print(p_ggplot + 
        theme_grey())
```

<img src="_main_files/figure-html/change-themes-gg-tiff-2.svg" width="672" />

The export procedure will then be equivalent to before:


```r
tiff("test_gg.tif", width = 17.35, height = 23.35, units = "cm", res = 300,
     compression = "lzw")
theme_set(theme_bw(base_size = 10))
theme_update(axis.text = element_text(size = 17.5, face = "italic"))

print(p_ggplot)
invisible(dev.off())
```

Right, so now we know how to modify the standard settings shipped with both **lattice** and **ggplot2**. This will be pretty much the same for the other devices...


## Portable Network Graphics

For `.png` files things are very similar to `.tiff` except that we don't need to specify a compression:


```r
png("test_gg.png", width = 17.35, height = 23.35, units = "cm", res = 300)
theme_set(theme_bw(base_size = 10))
theme_update(axis.text = element_text(size = 17.5, face = "italic"))

print(p_ggplot)
invisible(dev.off())
```


## Encapsulated Postscript

As mentioned earlier, the proper way of saving vector based graphics (such as line graphs, point graphs or basically anything with not too many graphical features, e.g. polygons) is using a vector graphics based device. Here, we will consider `(encapsulated) postscript - .eps` and `portable document format - .pdf`.

For R's `postscript` device the important default settings are as follows (PLOS ONE requirements in brackets):

* width and heigth: 0 inches (max 6.83 / 9.19)
* pointsize: 12 (6 - 12)
* bg (background): "transparent" (white)
* family: "Helvetica" (Arial, Times, Symbol)
* onefile: TRUE (n.a. - yet likely only one file is acceptable)
* horizontal: TRUE (accepting both)
* paper: "default" check via `getOption("papersize")` (n.a.)
* colormodel: "srgb" (RGB - so sRGB should be fine)

The full set of details can be retrieved using:


```r
ps.options()
```

```
## $onefile
## [1] TRUE
## 
## $family
## [1] "Helvetica"
## 
## $title
## [1] "R Graphics Output"
## 
## $fonts
## NULL
## 
## $encoding
## [1] "default"
## 
## $bg
## [1] "transparent"
## 
## $fg
## [1] "black"
## 
## $width
## [1] 0
## 
## $height
## [1] 0
## 
## $horizontal
## [1] TRUE
## 
## $pointsize
## [1] 12
## 
## $paper
## [1] "default"
## 
## $pagecentre
## [1] TRUE
## 
## $print.it
## [1] FALSE
## 
## $command
## [1] "default"
## 
## $colormodel
## [1] "srgb"
## 
## $useKerning
## [1] TRUE
## 
## $fillOddEven
## [1] FALSE
```

Changing these is basically the way to handle device setup when printing to `eps`. These default settings can be changed using `setEPS()`. And here is where it gets a little awkward. If you run `setEPS()` without any arguments, the defaults listed above will change slightly


```r
setEPS()
ps.options()
```

```
## $onefile
## [1] FALSE
## 
## $family
## [1] "Helvetica"
## 
## $title
## [1] "R Graphics Output"
## 
## $fonts
## NULL
## 
## $encoding
## [1] "default"
## 
## $bg
## [1] "transparent"
## 
## $fg
## [1] "black"
## 
## $width
## [1] 7
## 
## $height
## [1] 7
## 
## $horizontal
## [1] FALSE
## 
## $pointsize
## [1] 12
## 
## $paper
## [1] "special"
## 
## $pagecentre
## [1] TRUE
## 
## $print.it
## [1] FALSE
## 
## $command
## [1] "default"
## 
## $colormodel
## [1] "srgb"
## 
## $useKerning
## [1] TRUE
## 
## $fillOddEven
## [1] FALSE
```

Notably, `onefile` is now `FALSE` as is `horizontal`, `paper` is now `special` and `height` and `width` are now 7. Apart from the `onefile` I think this is fine. Especially when utilizing layered plotting approaches like we do here (i.e. **lattice** and **ggplot2**), `onefile` should be set to `TRUE` as otherwise we may well end up with `.eps` files with many pages. However, `setEPS()` will not let us change this. Therefore, we will need to set this for each device.

Hence, in order to comply with PLOS ONE we need:


```r
setEPS(bg = "white", family = "Times", width = 6.83)
postscript("test_la.eps", onefile = TRUE)

print(p_lattice)

invisible(dev.off())
```

All the tweaking of the plot layout applies here just the same (e.g. adjusting the axis tick labelling font sizes etc.). 

For vector graphics resolution is irrelevant as the elements are actual lines or points and not pixels. Therefore, we need to start thinking about lines and points now. And here things are again a little "special" in R. The base size for points is 1/72 inch (standard) but for lines it is 1/96 inch. This means that when we specify a line width of 1 via `lwd = 1` we are really getting a line width of 0.75 as `72/96 = 0.75`. In light of the PLOS ONE requirements for lines to be at least 0.5 pt this will mean that when we set `lwd = 0.5` we are actually producing a line that is too thin (0.375 pt). On the other hand, setting `lwd = 2` means that we still adhere to the guidelines as the result will only be 1.5 pt in width. 

If, however, we want to address this issue we could do something like this (using a simple line plot as an example):


```r
setEPS(bg = "white", family = "Times", width = 6.83)
postscript("test_la_line.eps", onefile = TRUE)

print(xyplot(1:10 ~ 1:10, type = "l", lwd = 96/72 * 2))

invisible(dev.off())
```

Obviously, the line width adjustment can also be done globally in the theme setup.

As a final tweak, we will see how to change the white space around a plot in **lattice**:


```r
# setEPS(bg = "white", family = "Times", width = 6.83)
# postscript("test_la_line.eps", onefile = TRUE)

mar_theme <- lattice.options()
mar_theme$layout.widths$left.padding$x <- 2
mar_theme$layout.widths$left.padding$units <- "points"
mar_theme$layout.widths$right.padding$x <- 2
mar_theme$layout.widths$right.padding$units <- "points"
mar_theme$layout.heights$top.padding$x <- 2
mar_theme$layout.heights$top.padding$units <- "points"
mar_theme$layout.heights$bottom.padding$x <- 2
mar_theme$layout.heights$bottom.padding$units <- "points"

print(xyplot(1:10 ~ 1:10, type = "l", lwd = 96/72 * 2, 
             lattice.options = mar_theme))
```

<img src="_main_files/figure-html/seteps-whitespace-1.svg" width="672" />

```r
# invisible(dev.off())
```

This will, however, only really provide a 2 pt white space on the left side of the plot. I found some indications as to some bugs in setting these layout parameters, so whether this is intended or not remains unclear for now. I will keep digging and update this tutorial as soon as I find a proper solution.

In **ggplot2** the margin adjustment can again be done using `theme_update()`:


```r
theme_set(theme_bw(base_size = 20))
theme_update(plot.margin = unit(rep(2, 4), units = "points"))

print(p_ggplot)
```

<img src="_main_files/figure-html/change-themes-gg-eps-1.svg" width="672" />

You might say that the approach taken by **ggplot2** regarding the margin adjustment is favorable as we don't need to provide the desired values to each entry of the `lattice.options()`. There is, however, an equivalent function in **lattice** called `trellis.par.set()`.

Personally, I like the assignment approach (`<-`) better as it usually involves a little more poking around in the various settings which means you are likely to understand things in a little more detail.


## Portable Document Format

`pdf` basically works the same as `postscript`. Both produce vector graphics output. The default settings can be checked with:


```r
pdf.options()
```

```
## $width
## [1] 7
## 
## $height
## [1] 7
## 
## $onefile
## [1] TRUE
## 
## $family
## [1] "Helvetica"
## 
## $title
## [1] "R Graphics Output"
## 
## $fonts
## NULL
## 
## $version
## [1] "1.4"
## 
## $paper
## [1] "special"
## 
## $encoding
## [1] "default"
## 
## $bg
## [1] "transparent"
## 
## $fg
## [1] "black"
## 
## $pointsize
## [1] 12
## 
## $pagecentre
## [1] TRUE
## 
## $colormodel
## [1] "srgb"
## 
## $useDingbats
## [1] TRUE
## 
## $useKerning
## [1] TRUE
## 
## $fillOddEven
## [1] FALSE
## 
## $compress
## [1] TRUE
```

However, there is no equivalent to `setEPS()`. Therefore, we need to provide all device specifications/changes of the default settings directly in the device setup:


```r
pdf("test_la_line.pdf", onefile = TRUE, bg = "white", 
    family = "Times", width = 6.83)

print(xyplot(1:10 ~ 1:10, type = "l", lwd = 96/72 * 2))

invisible(dev.off())
```

<!--chapter:end:04-saving-graphics.Rmd-->

# Final remarks

Ok, so now we have a rather comprehensive, though far from complete (if that is even possible) set of tools for visualizing our data using classical statistical plots.

I hope that this tutorial was, at least in parts, useful for some of you and that we were able to expand your skill set of producing publication quality graphics using R to some extent.

As mentioned at the beginning of this tutorial, I am happy to receive feedback, comments, criticism and bug reports at the e-mail address provided.

Cheers,

Tim and Florian

<!--chapter:end:05-final-remarks.Rmd-->

# References {-}

<!--chapter:end:06-references.Rmd-->

