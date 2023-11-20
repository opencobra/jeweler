process VALIDATE_SBML {
    tag "${meta.id}"
    label 'process_single'

    conda ""
    container 'docker.io/opencobra/memote:0.16.0'

    input:
    tuple val(meta), path(model)

    output:
    tuple val(meta), stdout, path('*.json.gz'), emit: report
    path 'versions.yml', emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def filename = "${meta.id}.json.gz"
    """
    validate_sbml.py \\
        ${args} \\
        --output '${filename}' \\
        '${model}'

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        cobra: \$(python -c 'import cobra;print(cobra.__version__)')
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    def filename = "${meta.id}.json.gz"
    """
    # validate_sbml.py \\
    #   ${args} \\
    #   --output '${filename}' \\
    #   '${model}'

    echo valid

    touch '${filename}'

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        cobra: \$(python -c 'import cobra;print(cobra.__version__)')
    END_VERSIONS
    """
}
