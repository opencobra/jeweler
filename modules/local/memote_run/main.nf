process MEMOTE_RUN {
    tag "${meta.id}"
    label 'process_medium'

    conda "${moduleDir}/environment.yml"
    container 'docker.io/opencobra/memote:0.16.1'

    input:
    tuple val(meta), path(model)

    output:
    tuple val(meta), path('*.json.gz'), emit: report
    path 'versions.yml', emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def filename = "${prefix}.json.gz"
    """
    memote run \\
        ${args} \\
        --ignore-git \\
        --filename '${filename}' \\
        '${model}' \\
        || echo "\$?"

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        memote: \$(memote --version | sed 's/memote, version //g')
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def filename = "${prefix}.json.gz"
    """
    # memote run \\
    #     ${args} \\
    #     --ignore-git \\
    #     --no-collect \\
    #     --filename '${filename}' \\
    #     '${model}' \\
    #     || echo "\$?"

    touch '${filename}'

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        memote: \$(memote --version | sed 's/memote, version //g')
    END_VERSIONS
    """
}
