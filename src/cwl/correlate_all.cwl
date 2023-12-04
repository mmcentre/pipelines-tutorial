#!/usr/bin/env cwl-runner

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

