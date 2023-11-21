[![DOI](https://zenodo.org/badge/691285192.svg)](https://zenodo.org/doi/10.5281/zenodo.10173259)

## Introduction

**opencobra/jeweler** is a bioinformatics pipeline that tests and grades genome-scale metabolic models (GEMs). It first validates [SBML](https://sbml.org/) documents that describe metabolic models for constraint-based analysis. Valid documents are then passed on to the genome-scale metabolic model test suite ([MEMOTE](https://memote.io)).

<!-- TODO nf-core: Include a figure that guides the user through the major workflow steps. Many nf-core
     workflows use the "tube map" design for that. See https://nf-co.re/docs/contributing/design_guidelines#examples for examples.   -->

1. Optionally, attempt to download an SBML document from a given model identifier ([COBRApy](https://opencobra.github.io/cobrapy/)).
2. Validate the SBML document for use with constraint-based analysis ([COBRApy](https://opencobra.github.io/cobrapy/)).
3. Test the model in the SBML document with the genome-scale metabolic model test suite ([MEMOTE](https://memote.io)).

## Usage

> **Note**
> If you are new to Nextflow and nf-core, please refer to [this page](https://nf-co.re/docs/usage/installation) on how
> to set-up Nextflow. Make sure to [test your setup](https://nf-co.re/docs/usage/introduction#how-to-run-a-pipeline)
> with `-profile test` before running the workflow on actual data.

First, prepare a samplesheet with your input data that looks as follows. Please also take a look at the [test samplesheet](assets/samplesheet.csv) for inspiration.

`samplesheet.csv`:

```csv
id,name,model
MODEL1507180060,iJR904,
MODEL2109130006,,
```

If the SBML document exists in an online repository, such as [BioModels](https://www.ebi.ac.uk/biomodels/) or [BiGG](http://bigg.ucsd.edu/), then the model identifier is enough. Otherwise, you need to reference the model file directly. An entry for the name is entirely optional.

Now, you can run the pipeline using:

```bash
nextflow run opencobra/jeweler \
   -profile <docker/singularity/.../institute> \
   --input samplesheet.csv \
   --outdir <OUTDIR>
```

> **Warning:**
> Please provide pipeline parameters via the CLI or Nextflow `-params-file` option. Custom config files including those
> provided by the `-c` Nextflow option can be used to provide any configuration _**except for parameters**_;
> see [docs](https://nf-co.re/usage/configuration#custom-configuration-files).

## Credits

opencobra/jeweler was originally written by Moritz E. Beber.

<!-- We thank the following people for their extensive assistance in the development of this pipeline: -->

<!-- TODO nf-core: If applicable, make list of people who have also contributed -->

## Contributions and Support

If you would like to contribute to this pipeline, please see the [contributing guidelines](.github/CONTRIBUTING.md).

## Citations

If you use opencobra/jeweler for your analysis, please cite it using the following doi: [10.5281/zenodo.10173259](https://zenodo.org/doi/10.5281/zenodo.10173259) -->

An extensive list of references for the tools used by the pipeline can be found in the [`CITATIONS.md`](CITATIONS.md) file.

This pipeline uses code and infrastructure developed and maintained by the [nf-core](https://nf-co.re) community, reused here under the [MIT license](https://github.com/nf-core/tools/blob/master/LICENSE).

> **The nf-core framework for community-curated bioinformatics pipelines.**
>
> Philip Ewels, Alexander Peltzer, Sven Fillinger, Harshil Patel, Johannes Alneberg, Andreas Wilm, Maxime Ulysse Garcia, Paolo Di Tommaso & Sven Nahnsen.
>
> _Nat Biotechnol._ 2020 Feb 13. doi: [10.1038/s41587-020-0439-x](https://dx.doi.org/10.1038/s41587-020-0439-x).
