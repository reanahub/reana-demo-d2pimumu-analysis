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
  outfile:
    type: string
    default: results.pdf

baseCommand: /bin/sh

arguments:
  - prefix: -c
    valueFrom: |
      root -b -q '$(inputs.mass_fit_tool.basename)("$(runtime.outdir)/$(inputs.data.basename)", "$(runtime.outdir)/$(inputs.phi_models.basename)", "$(runtime.outdir)/$(inputs.outfile)")'

stdout: mass_fit.log

outputs:
  mass_fit.log:
    type: stdout
  result:
    type: File
    outputBinding:
      glob: $(inputs.outfile)
