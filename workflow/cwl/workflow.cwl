#!/usr/bin/env cwl-runner

# Note that if you are working on the analysis development locally, i.e. outside
# of the REANA platform, you can proceed as follows:
#
#   $ cd reana-demo-lhcb-d2pimumu
#   $ mkdir cwl-local-run
#   $ cd cwl-local-run
#   $ cp -a ../*.C ../*.h ../data ../workflow/cwl/input.yml .
#   $ cwltool --quiet --outdir="./results" ../workflow/cwl/workflow.cwl input.yml
#   $ firefox ../results/phi.pdf


cwlVersion: v1.0
class: Workflow

inputs:
  optimise_tool: File
  model_fixing_tool: File
  mass_fit_tool: File
  roo_fit_headers: File
  lhcb_style: File
  data: File

outputs:
  optimise_tool.log:
    type: File
    outputSource:
      optimise/optimise_tool.log
  result_2D_Optimisation_Pi:
    type: File
    outputSource:
      optimise/result_2D_Optimisation_Pi
  result_MuMuMass_Pi:
    type: File
    outputSource:
      optimise/result_MuMuMass_Pi
  model_fixing.log:
    type: File
    outputSource:
      model_fixing/model_fixing.log
  mass_fit.log:
    type: File
    outputSource:
      mass_fit/mass_fit.log
  result_low_dimuon_signal:
    type: File
    outputSource:
      mass_fit/result_low_dimuon_signal
  result_high_dimuon_signal:
    type: File
    outputSource:
      mass_fit/result_high_dimuon_signal
  result_eta:
    type: File
    outputSource:
      mass_fit/result_eta
  result_rho_omega:
    type: File
    outputSource:
      mass_fit/result_rho_omega
  result_phi:
    type: File
    outputSource:
      mass_fit/result_phi


steps:
  optimise:
    run: optimise.cwl
    in:
      optimise_tool: optimise_tool
      roo_fit_headers: roo_fit_headers
      data: data
    out: [result_2D_Optimisation_Pi, result_MuMuMass_Pi, optimise_tool.log]
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
    out: [result_low_dimuon_signal, result_high_dimuon_signal, result_eta, result_rho_omega, result_phi, mass_fit.log]
