#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { RNASEQ } from './workflows/rnaseq'

workflow {
    RNASEQ(params.input)
}