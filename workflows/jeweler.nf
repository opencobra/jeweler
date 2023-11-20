/******************************************************************************
 * Import Local Modules
 ******************************************************************************/

include { FETCH_SBML } from '../modules/local/fetch_sbml/main'
include { MEMOTE_REPORT_SNAPSHOT } from '../modules/local/memote_report_snapshot/main'

/******************************************************************************
 * Import Local Subworkflows
 ******************************************************************************/

/******************************************************************************
 * Import nf-core Moduels
 ******************************************************************************/

/******************************************************************************
 * Import nf-core Subworkflows
 ******************************************************************************/

/******************************************************************************
 * Main Workflow
 ******************************************************************************/

// Info required for completion email and summary
def multiqc_report = []

workflow JEWELER {
    take:
        ch_input

    main:
        def ch_versions = Channel.empty()

        def ch_split_input = ch_input
            .branch { meta, model ->
                // Missing files are provided as an empty list.
                no_model: model instanceof List && model.empty
                model: true
            }

        FETCH_SBML(ch_split_input.no_model.map { meta, model -> meta } )
        ch_versions = ch_versions.mix(FETCH_SBML.out.versions.first())

        def ch_memote_input = Channel.empty()
            .mix(ch_split_input.model)
            .mix(FETCH_SBML.out.sbml)

        MEMOTE_REPORT_SNAPSHOT(ch_memote_input)
        ch_versions = ch_versions.mix(MEMOTE_REPORT_SNAPSHOT.out.versions.first())

    emit:
        report  = MEMOTE_REPORT_SNAPSHOT.out.report
        versions = ch_versions
}
