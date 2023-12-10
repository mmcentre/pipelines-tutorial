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
  This tool is written in Nextflow language and is intended to demonstrate how
  to run a simple CWL workflow and pass arguments to it.
  It prints whatever message is passed to the tool via
  either a command line argument.

  Adopted from https://github.com/nextflow-io/hello/blob/master/main.nf
  and modified to accept command line parameters
 */


params.message = 'Bonjour,Ciao,Hello,Hola'

process sayHello {
  input:
    val x
  output:
    stdout
  script:
    """
    echo '$x world!'
    """
}

workflow {
  Channel.fromList(params.message.split(',') as List) | sayHello | view
}