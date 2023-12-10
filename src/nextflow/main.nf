#!/usr/bin/env nextflow

//  Copyright (c) 2023.  Harvard University
//
//   Developed by Michael A Bouzinier, Research Software Engineering,
//   Harvard University Research Computing and Data (RCD) Services.
//
//   This is a part of the materials used for
//   "Introduction to Data Processing Workflow Languages"
//   training course.
//   See https://docs.google.com/presentation/d/1mFZB3Eja9NIkgcLPt7d5IUUlHac0Uit3
//   for more information. This file is not part of any production software
//   and is provided solely for the purpose of demonstrating capabilities
//   of workflow definition programming languages and performing exercises.
//
//   Licensed under the Apache License, Version 2.0 (the "License");
//   you may not use this file except in compliance with the License.
//   You may obtain a copy of the License at
//
//          http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

/*
  Simple tool to calculate Pearson correlation coefficient between
  several given pairs of columns of a tab-separated file

  This workflow is intended to demonstrate a possible solution to the
  following imaginary problem: having a tab-separated values file
  with several columns, we would like to select one numerical column
  (main variable) and explore how other numerical columns correlate with it.

  Disclaimer: The actual problem can be easily solved with a
  simple Python, R, Java or C program. The purpose here
  though is not to present a use real-world case for a workflow definition
  language but to show how to use Nextflow.

  The workflow performs the following steps:

  1. Cleanse the data
    * The original file contains some unparseable values, e.g., “(null)” for numeric data
    * Use grep to remove rows with unparseable values
  2. For every column that we would like to correlate with the main variable,
     calculate Pearson Correlation Coefficient using Python pandas package
     This can be done in parallel, using scatter directive
  3. Combine results of the step 2 into a single file and sort it
  4. Plot a bar chart, showing correlations using gnuplot


  Inline comments are not added this workflow intentionally to
  improve readability. The workflow is commented in the
  Google slides:
  https://docs.google.com/presentation/d/1mFZB3Eja9NIkgcLPt7d5IUUlHac0Uit3/edit#slide=id.p34

*/

params.variable = 'poverty'
params.columns = [
      'no_grad',
      'density',
      'median_age',
      'median_household_income',
      'population_density',
      'smoke_rate',
      'mean_bmi',
      'tmmx',
      'pm25',
      'latitude',
      'longitude'
]

process clean {
    // Uncomment next two lines to publish intermediate files:
    // container 'forome/slimpipe'
    // publishDir 'results', mode: 'copy'

    input:
    path rawDataFile

    output:
    path 'clean_data.csv'

    script:
    """
    #!/bin/sh
    gunzip - < $rawDataFile | grep -v '(null)' > clean_data.csv
    """
}

process sort {
    container 'forome/slimpipe'
    publishDir 'results', mode: 'copy'

    input:
    path csv

    output:
    path 'correlations.txt'

    script:
    """
    #!/bin/sh
    sort -gk 3,3 $csv > correlations.txt
    """
}

process correlate {
    container 'forome/slimpipe'
    publishDir 'results', mode: 'copy'

    input:
        tuple (path(data), val(var), val(col))

    output:
    stdout

    script:
    """
    #!/usr/local/bin/python
    import sys
    import pandas

    df = pandas.read_csv('$data', sep='\t')
    s1 = '$var'
    s2 = '$col'
    print(f"{s1.replace('_','-')} \t{s2.replace('_','-')}\t {df[s1].corr(df[s2])}")
    """
}

process plot {
    container 'forome/slimpipe'
    publishDir 'results', mode: 'copy'

    input:
    path data

    output:
    path 'correlations.png'

    script:
    """
    #!/usr/bin/gnuplot

    set xtics rotate
    set boxwidth 1.2
    set style fill solid
    set terminal png
    set output "correlations.png"
    set title "Correlation between poverty and other variables"
    set ylabel "Pearson Correlation Coefficient"

    plot 'correlations.txt' using 3:xtic(2) with histogram notitle
    """
}


workflow {
    main:

    variable = Channel.from(params.variable)
    columns = Channel.fromList(params.columns)
    rawDataFile = Channel.fromPath(params.data, checkIfExists:true)
    cleanDataFile = clean(rawDataFile)
    
    cleanDataFile.combine(variable).combine(columns)
        | correlate
        | collectFile
        | sort
        | plot
        | view
}