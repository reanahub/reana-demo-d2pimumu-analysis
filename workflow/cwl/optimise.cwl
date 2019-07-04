cwlVersion: v1.0
class: CommandLineTool

requirements:
  DockerRequirement:
    dockerPull:
      reanahub/reana-env-root6
  InitialWorkDirRequirement:
    listing:
      - $(inputs.optimise_tool)
      - $(inputs.roo_fit_headers)
      - $(inputs.data)

inputs:
  optimise_tool: File
  roo_fit_headers: File
  data: File

baseCommand: /bin/sh

arguments:
  - prefix: -c
    valueFrom: |
      root -b -q '$(inputs.optimise_tool.basename)("$(runtime.outdir)/$(inputs.data.basename)", "$(runtime.outdir)")'

stdout: optimise.log

outputs:
  optimise_tool.log:
    type: stdout
  result_2D_Optimisation_Pi:
    type: File
    outputBinding:
      glob: 2D_Optimisation_Pi.pdf
  result_MuMuMass_Pi:
    type: File
    outputBinding:
      glob: MuMuMass_Pi.pdf