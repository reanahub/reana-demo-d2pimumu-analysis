cwlVersion: v1.0
class: CommandLineTool

requirements:
  DockerRequirement:
    dockerPull:
      reanahub/reana-env-root6
  InitialWorkDirRequirement:
    listing:
      - $(inputs.mass_fit_tool)
      - $(inputs.roo_fit_headers)
      - $(inputs.lhcb_style)
      - $(inputs.data)
      - $(inputs.phi_models)

inputs:
  mass_fit_tool: File
  data: File
  roo_fit_headers: File
  lhcb_style: File
  phi_models: File

baseCommand: /bin/sh

arguments:
  - prefix: -c
    valueFrom: |
      root -b -q '$(inputs.mass_fit_tool.basename)("$(runtime.outdir)/$(inputs.data.basename)", "$(runtime.outdir)/$(inputs.phi_models.basename)", "$(runtime.outdir)")'

stdout: mass_fit.log

outputs:
  mass_fit.log:
    type: stdout
  result_low_dimuon_signal:
    type: File
    outputBinding:
      glob: low_dimuon_signal.pdf
  result_high_dimuon_signal:
    type: File
    outputBinding:
      glob: low_dimuon_signal.pdf
  result_eta:
    type: File
    outputBinding:
      glob: eta.pdf
  result_rho_omega:
    type: File
    outputBinding:
      glob: rho_omega.pdf
  result_phi:
    type: File
    outputBinding:
      glob: phi.pdf