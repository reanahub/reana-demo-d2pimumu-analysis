========================================================
 REANA example - Search for the rare charm decays
========================================================

.. image:: https://img.shields.io/travis/reanahub/reana-demo-lhcb-d2pimumu.svg
   :target: https://travis-ci.org/reanahub/reana-demo-lhcb-d2pimumu

.. image:: https://badges.gitter.im/Join%20Chat.svg
   :target: https://gitter.im/reanahub/reana?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge

.. image:: https://img.shields.io/github/license/reanahub/reana-demo-lhcb-d2pimumu.svg
   :target: https://raw.githubusercontent.com/reanahub/reana-demo-lhcb-d2pimumu/master/LICENSE



About
======

This example is based on the `analysis-case-study <https://github.com/atrisovic/analysis-case-study>`_.

Analysis structure
===================

Making a research data analysis reproducible basically means to provide
"runnable recipes" addressing (1) where is the input data, (2) what software was
used to analyse the data, (3) which computing environments were used to run the
software and (4) which computational workflow steps were taken to run the
analysis. This will permit to instantiate the analysis on the computational
cloud and run the analysis to obtain (5) output results.


1. Input data
-------------
The data being used is currently only available on request. It consists of a 10 GB ROOT file.

2. Analysis code
----------------

You can either run the analysis step by step (explained below), or use the bash script :code:`run.sh` via:

.. code-block:: console

   $ bash run.sh <data_file> <tmp_phi_models> <result_plot>

Step 0:

`lhcbStyle.C <code/lhcbStyle.C>`_ -
  Plot formats specific to the LHCb collaboration.


`RooFitHeaders.h <code/RooFitHeaders.h>`_ -
  Libraries and packages needed to perform the fitting.


Step 1. `Optimise.C <code/Optimise.C>`_ -

  Note: This is a very resource consuming process.

  Optimisation is the process where combinations of different variable cuts are evaluated in order to maximise the signal yield and reduce the background. In this analysis, the optimisation study is performed to choose the combined BDT and particle identification (PID) selection criteria that maximise the expected statistical significance.
  The result of the script is the heat map called `2D_Optimisation_Pi.pdf`. The higher significance (in yellow) means cleaner signal.
  The optimal significance is found to be at the cuts of `BDT > 0.1` and `PIDmu > 2`.

.. code-block:: console

   $ root -b -q Optimisation.C(<data_file>)


Step 2. `ModelFixing.C <code/ModelFixing.C>`_ -
  Creates the theoretical model that the fit is compared to.

.. code-block:: console

   $ root -b -q ModelFixing.C(<data_file>, <tmp_phi_models>)

Step 3. `OSMassFit.C <code/OSMassFit.C>`_ -
  The fit for the signal was modelled with the sum of Crystal Ball distributions. Each shape consists of a Gaussian core with a power law tail on opposite sides. The background was modelled with a 2nd order Chebyshev polynomial distribution.

.. code-block:: console

   $ root -b -q OSMassFit.C(<data_file>, <tmp_phi_models>, <result_plot>)



3. Compute environment
----------------------
In order to be able to rerun the analysis even several years in the future, we
need to "encapsulate the current compute environment", for example to freeze the
ROOT version our analysis is using. We shall achieve this by preparing a `Docker
<https://www.docker.com/>`_ container image for our analysis steps.

Some of the analysis steps will run in a pure `ROOT <https://root.cern.ch/>`_
analysis environment. We can use an already existing container image, for
example `reana-env-root6 <https://github.com/reanahub/reana-env-root6>`_, for
these steps.

Some of the other analysis tasks wil need ``hftools`` Python library installed
that our Python code needs. We can extend the ``reana-env-root6`` image to
install ``hftools`` and to include our own Python code. This can be achieved as
follows:

.. code-block:: console

   $ less environment/Dockerfile
   # Start from the ROOT6 base image:
   FROM reanahub/reana-env-root6

   # Install HFtools:
   RUN apt-get -y update && \
       apt-get -y install \
          python-pip \
          zip && \
       apt-get autoremove -y && \
       apt-get clean -y
   RUN pip install hftools

   # Mount our code:
   ADD code /code
   WORKDIR /code

We can build our analysis environment image and give it a name
``reanahub/reana-demo-lhcb-d2pimumu``:

.. code-block:: console

   $ docker build -f environment/Dockerfile -t reanahub/reana-demo-lhcb-d2pimumu .

We can push the image to the DockerHub image registry:

.. code-block:: console

   $ docker push reanahub/reana-demo-lhcb-d2pimumu

(Note that typically you would use your own username such as ``johndoe`` in
place of ``reanahub``.)



4. Analysis workflow
--------------------
This analysis example consists of a simple workflow the theoretical model is generated and used for fitting.

The analysis workflow consists of two above-mentioned stages:

.. code-block:: console

                START
                 |
                 | small.root
                 |
                 V
   +-----------------------------+
   | (1) fix model               |
   |                             |
   |    $ root ModelFixing.C ... |
   +-----------------------------+
                 |
                 | PhiModels.root
                 V
   +-----------------------------+
   | (2) fit data                |
   |                             |
   |    $ root OSMassFit.C ...   |
   +-----------------------------+
                 |
                 | low_dimuon_signal.pdf
                 |
                 V
                STOP

For example:

.. code-block:: console

    $ root -b -q 'ModelFixing.C("data.root", "phimodels.root")'
    $ root -b -q 'fitdata.C("data.root", "phimodels.root","plot.pdf")'
    $ ls -l plot.pdf

Note that you can also use `CWL <http://www.commonwl.org/v1.0/>`_ or `Yadage
<https://github.com/diana-hep/yadage>`_ workflow specifications:

- `workflow definition using CWL <workflow/cwl/workflow.cwl>`_
- `workflow definition using Yadage <workflow/yadage/workflow.yaml>`_



5. Output results - Mass fit
-----------------------------

The result of this analysis are the following plots in various dimuon mass ranges. We studied the three body decay in high dimuon and low dimuon mass range, and we did not observe any signal.


+----------------------------------+-------------------------+--------------------------+
| Dimuon resonances                | Dimuon mass range (MeV) | Plot                     |
+==================================+=========================+==========================+
| Three body decay (low dimuon)    | 250 - 525               | `low_dimuon_signal.pdf`  |
+----------------------------------+-------------------------+--------------------------+
| :math:`\eta`                     | 525 - 565               | `eta.pdf`                |
+----------------------------------+-------------------------+--------------------------+
| :math:`\rho , \omega`            | 565 - 850               | `rho_omega.pdf`          |
+----------------------------------+-------------------------+--------------------------+
| :math:`\phi`                     | 850 - 1250              | `phi.pdf`                |
+----------------------------------+-------------------------+--------------------------+
| Three body (high dimuon)         | 1250 - 2000             | `high_dimuon_signal.pdf` |
+----------------------------------+-------------------------+--------------------------+

The plots can be found in the `mass_fits` folder at the end of the execution.

One of the final plots, representing the :math:`\phi`  contribution, is shown below.

.. figure:: https://raw.githubusercontent.com/reanahub/reana-demo-lhcb-d2pimumu/master/docs/phi.png
   :alt: phi.png
   :align: center

.. figure:: https://raw.githubusercontent.com/reanahub/reana-demo-lhcb-d2pimumu/master/docs/eta.png
   :alt: phi.png
   :align: center

.. figure:: https://raw.githubusercontent.com/reanahub/reana-demo-lhcb-d2pimumu/master/docs/high_dimuon_signal.png
   :alt: high_dimuon_signal.png
   :align: center

.. figure:: https://raw.githubusercontent.com/reanahub/reana-demo-lhcb-d2pimumu/master/docs/low_dimuon_signal.png
   :alt: low_dimuon_signal.png
   :align: center

.. figure:: https://raw.githubusercontent.com/reanahub/reana-demo-lhcb-d2pimumu/master/docs/rho_omega.png
   :alt: rho_omega.png
   :align: center


Running the example on REANA cloud
==================================

We start by creating a `reana.yaml <reana.yaml>`_ file describing the above
analysis structure with its inputs, code, runtime environment, computational
workflow steps and expected outputs:

.. code-block:: yaml

	version: 0.3.0
	inputs:
	  files:
	    # - code/Optimise.C
	    - code/ModelFixing.C
	    - code/OSMassFit.C
	  parameters:
	    data: data/small.root
	workflow:
	  type: serial
	  specification:
	    steps:
	      - environment: 'reanahub/reana-env-root6'
		commands:
		- mkdir -p results
		- mkdir -p results/tmp
		# - root -b -q 'code/Optimise.C("${data}")'
		- root -b -q 'code/ModelFixing.C("${data}")'
		- root -b -q 'code/OSMassFit.C("${data}")'
	outputs:
	  files:
	    - results/low_dimuon_signal.pdf
	    - results/high_dimuon_signal.pdf

We can now install the REANA command-line client, run the analysis and download the resulting plots:

.. code-block:: console

    $ # create new virtual environment
    $ virtualenv ~/.virtualenvs/myreana
    $ source ~/.virtualenvs/myreana/bin/activate
    $ # install REANA client
    $ pip install reana-client reana-cluster
    $ # connect to some REANA cloud instance
    $ export REANA_SERVER_URL=https://reana.cern.ch/
    $ export REANA_ACCESS_TOKEN=XXXXXXX
    $ # create new workflow
    $ reana-client create -n my-analysis
    $ export REANA_WORKON=my-analysis
    $ # upload input code and data to the workspace
    $ reana-client upload ./code ./data
    $ # start computational workflow
    $ reana-client start
    $ # ... should be finished in about 15 minutes
    $ reana-client status
    $ # list output files
    $ reana-client ls | grep ".pdf"
    $ # download generated plots
    $ reana-client download 

Please see the `REANA-Client <https://reana-client.readthedocs.io/>`_
documentation for more detailed explanation of typical ``reana-client`` usage
scenarios.

Contributors
============

The list of contributors in alphabetical order:

- `Daniel Prelipcean <https://orcid.org/0000-0002-4855-194X>`_
- `Tibor Simko <https://orcid.org/0000-0001-7202-5803>`_
