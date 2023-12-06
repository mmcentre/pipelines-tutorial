# Introduction to Data Processing Workflow Languages

Exercises for the Harvard University
[Introduction to Data Processing Workflow Languages](https://www.rc.fas.harvard.edu/events/introduction-to-data-processing-workflow-languages/)
training course.

For details, see [slides](https://docs.google.com/presentation/d/1-6haJB_VScR_ezV94I8oqIP2rexT66Zo/edit?usp=sharing&ouid=106547068334112306780&rtpof=true&sd=true).

This repository contains sample pipelines in 
[CWL](https://www.commonwl.org/) 
and [Nextflow](https://www.nextflow.io/index.html).

The pipeline explores correlation between different numeric 
columns of a tab-separated file and builds a bar-chart plot. 
The user select one column (main variable) and a set of secondary 
columns that are correlated with the selected variable.

The actual data file contains a mix of demographics, behavioral,
climate and air pollution data. It is hosted in IBM Cloud S3 bucket.


>Note: This piepline is not intended to be used as best practices
> but as playground to explore different features of CWL and Nextflow
> workflow definition languages.
> 
> The same tasks migh be easier to do as standalone Python or R
> program, but the goal here is to show how to use specialized
> workflow definition domain specific languages (DSL).

It performs the following steps:

1.  Cleanse the data. The input file contains strings `(null)`
    for some numeric values. Rows that with such values will 
    not be parseable by pandas package and hence should be removed.
2.  For every column that we would like to correlate with the 
    main variable, we will calculate Pearson Correlation Coefficient 
    using Python pandas package. Calculations can be done in 
    parallel for different columns.
3. Gather and combine results of the calculations in step 2.
4. Use Gnuplot to build a bar-chart

