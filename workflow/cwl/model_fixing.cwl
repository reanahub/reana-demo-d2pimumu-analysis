cwlVersion: v1.0
class: CommandLineTool

requirements:
  DockerRequirement:
    dockerPull:
      reanahub/reana-env-root6
  InitialWorkDirRequirement:
    listing:
      - $(inputs.model_fixing_tool)
      - $(inputs.roo_fit_headers)
      - $(inputs.data)

inputs:
  model_fixing_tool: File
  roo_fit_headers: File
  data: File
  outfilename:
    type: string
    default: PhiModels.root

baseCommand: /bin/sh

arguments:
  - prefix: -c
    valueFrom: |
      root -b -q '$(inputs.model_fixing_tool.basename)("$(runtime.outdir)/$(inputs.data.basename)", "$(runtime.outdir)/$(inputs.outfilename)")'

stdout: model_fixing.log

outputs:
  model_fixing.log:
    type: stdout
  phi_models:
    type: File
    outputBinding:
      glob: $(inputs.outfilename)