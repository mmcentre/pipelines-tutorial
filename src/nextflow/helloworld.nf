#!/usr/bin/env nextflow

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