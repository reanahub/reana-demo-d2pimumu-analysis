#!/usr/bin/env cwl-runner

# TODO: complete local commands when everything runs smoothly
# Note that if you are working on the analysis development locally, i.e. outside
# of the REANA platform, you can proceed as follows:
#
#   $ cd reana-demo-lhcb-d2pimumu
#   $ mkdir cwl-local-run
#   $ cd cwl-local-run
#   $ cp -a ../code ../workflow/cwl/input.yml .
#   $ cwltool --quiet --outdir="./results" ../workflow/cwl/workflow.cwl input.yml
#   $ firefox ../results/plot.png


cwlVersion: v1.0
class: Workflow

inputs:
  model_fixing_tool: File
  mass_fit_tool: File
  roo_fit_headers: File
  lhcb_style: File
  data: File

outputs:
  result:
    type: File
    outputSource:
      mass_fit/result
  model_fixing.log:
    type: File
    outputSource:
      model_fixing/model_fixing.log
  mass_fit.log:
    type: File
    outputSource:
      mass_fit/mass_fit.log

steps:
  model_fixing:
    run: model_fixing.cwl
    in:
      model_fixing_tool: model_fixing_tool
      roo_fit_headers: roo_fit_headers
      data: data
    out: [phi_models, model_fixing.log]
  mass_fit:
    run: mass_fit.cwl
    in:
      mass_fit_tool: mass_fit_tool
      roo_fit_headers: roo_fit_headers
      lhcb_style: lhcb_style
      phi_models: model_fixing/phi_models
      data: data
    out: [result, mass_fit.log]
