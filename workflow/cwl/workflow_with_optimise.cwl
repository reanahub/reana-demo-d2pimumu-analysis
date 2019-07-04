#!/usr/bin/env cwl-runner

# Note that if you are working on the analysis development locally, i.e. outside
# of the REANA platform, you can proceed as follows:
#
#   $ cd reana-demo-root6-roofit
#   $ mkdir cwl-local-run
#   $ cd cwl-local-run
#   $ cp -a ../code ../workflow/cwl/input.yml .
#   $ cwltool --quiet --outdir="../results" ../workflow/cwl/workflow.cwl input.yml
#   $ firefox ../results/plot.png


cwlVersion: v1.0
class: Workflow

inputs:
  optimise_tool: File
  model_fixing_tool: File
  mass_fit_tool: File
  data: file

outputs:
  plot:
    type: File
    outputSource:
      results

steps:
  optimise:
    run: optimise.cwl
    in:
      optimoptimise_toolise: optimise_tool
      data: data
  model_fixing:
    run: model_fixing.cwl
    in:
      model_fixing_tool: model_fixing_tool
      data: data
  mass_fit:
    run: mass_fit.cwl
    in:
      mass_fit_tool: mass_fit_tool
      data: data

