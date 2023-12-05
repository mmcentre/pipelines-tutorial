#!/usr/bin/env nextflow

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
    // container 'forome/slimpipe'
    publishDir 'results', mode: 'copy'

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
    set output "barchart.png"
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