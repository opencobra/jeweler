/******************************************************************************
 * Import Local Modules
 ******************************************************************************/

include { FETCH_SBML } from '../modules/local/fetch_sbml/main'
include { VALIDATE_SBML } from '../modules/local/validate_sbml/main'
include { MEMOTE_REPORT_SNAPSHOT } from '../modules/local/memote_report_snapshot/main'
include { MEMOTE_RUN } from '../modules/local/memote_run/main'

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
        run_report_snapshot
        run_report_raw

    main:
        def ch_versions = Channel.empty()

        def ch_split_input = ch_input
            .branch { meta, model ->
                // Missing files are provided as an empty list.
                no_model: model instanceof List && model.empty
                model: true
            }

        FETCH_SBML(ch_split_input.no_model.map { meta, model -> meta })
        ch_versions = ch_versions.mix(FETCH_SBML.out.versions.first())

        def ch_model_input = Channel.empty()
            .mix(ch_split_input.model)
            .mix(FETCH_SBML.out.sbml)

        VALIDATE_SBML(ch_model_input)
        ch_versions = ch_versions.mix(VALIDATE_SBML.out.versions.first())

        // Convert validation stdout to property.
        def ch_validation_output = VALIDATE_SBML.out.report.map { meta, msg, report ->
                [meta + [is_valid: msg.strip() == 'valid'], report]
            }

        // Create a channel with valid SBML documents to pass to memote.
        def ch_memote_input = ch_validation_output.map { meta, report -> [meta.id, meta] }
            .filter { meta_id, meta -> meta.is_valid }
            .join(
                ch_model_input.map { meta, model -> [meta.id, model] },
                by: 0,
                failOnDuplicate: true
            )
            .map { model_id, meta, model -> [meta, model] }

        ch_report_snapshot = Channel.empty()
        if (run_report_snapshot) {
            MEMOTE_REPORT_SNAPSHOT(ch_memote_input)
            ch_report_snapshot = ch_report_snapshot.mix(MEMOTE_REPORT_SNAPSHOT.out.report)
            ch_versions = ch_versions.mix(MEMOTE_REPORT_SNAPSHOT.out.versions.first())
        }

        ch_report_raw = Channel.empty()
        if (run_report_raw) {
            MEMOTE_RUN(ch_memote_input)
            ch_report_raw = ch_report_raw.mix(MEMOTE_RUN.out.report)
            ch_versions = ch_versions.mix(MEMOTE_RUN.out.versions.first())
        }

    emit:
        report_snapshot = ch_report_snapshot
        report_raw = ch_report_raw
        validation = ch_validation_output
        versions = ch_versions
}
