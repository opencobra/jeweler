process FETCH_SBML {
    tag "${meta.id}"
    label 'process_single'

    conda ""
    container 'docker.io/opencobra/memote:0.16.0'

    input:
    val(meta)

    output:
    tuple val(meta), path('*.sbml.gz'), emit: sbml
    path 'versions.yml', emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def filename = "${meta.id}.sbml.gz"
    """
    fetch_sbml.py \\
        ${args} \\
        --output '${filename}' \\
        '${meta.id}'

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        cobra: \$(python -c 'import cobra;print(cobra.__version__)')
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    def filename = "${meta.id}.sbml.gz"
    """
    echo fetch_sbml.py \\
        ${args} \\
        --output '${filename}' \\
        '${meta.id}'

    touch '${filename}'

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        cobra: \$(python -c 'import cobra;print(cobra.__version__)')
    END_VERSIONS
    """
}
