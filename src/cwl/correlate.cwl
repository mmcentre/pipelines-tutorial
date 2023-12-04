#!/usr/bin/env cwl-runner
### Simple tool to calculate Pearson correlation coefficient
#  Copyright (c) 2023. Harvard University
#
#  Developed by Research Software Engineering,
#  Faculty of Arts and Sciences, Research Computing (FAS RC)
#  Author: Michael A Bouzinier
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#

cwlVersion: v1.2
class: CommandLineTool
baseCommand: [python]

doc: |
  Simple tool to calculate Pearson correlation coefficient between
  two columns of a tab-separated file

hints:
  DockerRequirement:
    dockerPull: forome/slimpipe


inputs:
  program:
    type: File
    inputBinding:
      position: 1
    doc: Path to the file with Python code
  data:
    type: File
    inputBinding:
      position: 2
    doc: Path the tab-separated data file
  column1:
    type: string
    inputBinding:
      position: 3
    doc: Name of the first column
  column2:
    type: string
    inputBinding:
      position: 4
    doc: Name of the second column

outputs:
  correlation_coefficient:
    type: stdout

stdout: pcc.csv
