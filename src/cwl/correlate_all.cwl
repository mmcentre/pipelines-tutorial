#!/usr/bin/env cwl-runner

### Simple tool to calculate correlation coefficient between multiple columns of a CSV file

#  Copyright (c) 2023.  Harvard University
#
#   Developed by Michael A Bouzinier, Research Software Engineering,
#   Harvard University Research Computing and Data (RCD) Services.
#
#   This is a part of the materials used for
#   "Introduction to Data Processing Workflow Languages"
#   training course.
#   See https://docs.google.com/presentation/d/1mFZB3Eja9NIkgcLPt7d5IUUlHac0Uit3
#   for more information. This file is not part of any production software
#   and is provided solely for the purpose of demonstrating capabilities
#   of workflow definition programming languages and performing exercises.
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#          http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#

cwlVersion: v1.2
class: Workflow

requirements:
  SubworkflowFeatureRequirement: {}
  StepInputExpressionRequirement: {}
  InlineJavascriptRequirement: {}
  ScatterFeatureRequirement: {}

hints:
  DockerRequirement:
    dockerPull: forome/slimpipe


doc: |
  Simple tool to calculate Pearson correlation coefficient between
  several given pairs of columns of a tab-separated file
  
  This workflow is intended to demonstrate a possible solution to the 
  following imaginary problem: having a tab-separated values file 
  with several columns, we would like to select one numerical column 
  (main variable) and explore how other numerical columns correlate with it.
  
  Disclaimer: The actual problem can be easily solved with a 
  simple Python, R, Java or C program. The purpose here 
  though is not to present a use real-world case for a workflow definition 
  language but to show how to use CWL.
  
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
  https://docs.google.com/presentation/d/1mFZB3Eja9NIkgcLPt7d5IUUlHac0Uit3/edit#slide=id.p25


inputs:
  program:
    type: File
    doc: Path to the file with Python code
  plot:
    type: File
    doc: Path to the file containing Gnu Plot script
  data:
    type: File
    doc: Path the tab-separated data file
  variable:
    type: string
    doc: Names of the first columns
    default: 'poverty'
  columns:
    type: string[]
    doc: Names of the second columns
    default:
      - no_grad
      - density
      - median_age
      - median_household_income
      - population_density
      - smoke_rate
      - mean_bmi
      - tmmx
      - pm25
      - latitude
      - longitude

steps:
  unpack:
    # This line will be ignored
    ### This line will be ignored the CWL executor but can be used
    ### by a YaML documentation tool
    doc: |
      This block will be ignored by the CWL executor 
      but can be used by a CWL documentation tool
    run:
      class: CommandLineTool
      baseCommand: [gunzip, '-c']
      inputs:
        archive:
          type: File
          inputBinding:
            position: 1
      outputs:
        unpacked:
          type: stdout
      stdout: $(inputs.archive.nameroot)
    in:
      archive: data
    out:
      - unpacked

  clean:
    run:
      class: CommandLineTool
      baseCommand: [grep, '-v', '(null)' ]
      inputs:
        raw_data:
          type: File
          inputBinding:
            position: 1
      outputs:
        clean_data:
          type: stdout
      stdout: $('clean-' + inputs.raw_data.basename)
    in:
      raw_data: unpack/unpacked
    out:
      - clean_data


  correlate:
    run: correlate.cwl
    in:
      program: program
      data: clean/clean_data
      column1: variable
      column2: columns
    scatter: column2
    out:
      - correlation_coefficient

  combine:
    run:
      class: CommandLineTool
      baseCommand: [cat]
      inputs:
        files:
          type: File[]
          inputBinding:
            position: 1
      outputs:
        combined:
          type: stdout
      stdout: correlations.txt
    in:
      files: correlate/correlation_coefficient
    out:
      - combined

  sort:
    run:
      class: CommandLineTool
      baseCommand: [sort, '-gk', '3,3']
      inputs:
        data:
          type: File
          inputBinding:
            position: 1
      outputs:
        sorted:
          type: stdout
      stdout: correlations.txt
    in:
      data: combine/combined
    out:
      - sorted

  plot:
    run: plot.cwl
    in:
      script: plot
      data: sort/sorted
    out:
      - plot

outputs:
# Uncomment lines below to save intermediate files
#  unpacked:
#    type: File
#    outputSource: unpack/unpacked
#  clean_data:
#    type: File
#    outputSource: clean/clean_data
#  correlations:
#    type: File[]
#    outputSource: correlate/correlation_coefficient
  table:
    type: File
    outputSource: sort/sorted
  plot:
    type: File
    outputSource: plot/plot

