#!/usr/bin/env python

# Read the submission directory as a command line argument. You can
# extend the list of arguments with your private ones later on.
import optparse
parser = optparse.OptionParser()
parser.add_option( '-s', '--submission-dir', dest = 'submission_dir',
                   action = 'store', type = 'string', default = 'submitDir',
                   help = 'Submission directory for EventLoop' )
( options, args ) = parser.parse_args()

# Set up (Py)ROOT.
import ROOT
ROOT.xAOD.Init().ignore()

# Set up the sample handler object. See comments from the C++ macro
# for the details about these lines.
import os
sh = ROOT.SH.SampleHandler()
sh.setMetaString( 'nc_tree', 'CollectionTree' )
# pp overlay prompt
# inputFilePath = '/afs/cern.ch/work/x/xiaoning/public/muon_perf/mc16_5TeV.300000.Pythia8BPhotospp_A14_CTEQ6L1_pp_Jpsimu2p5mu2p5.merge.AOD.e4973_d1521_r11472_r11217/'
# ROOT.SH.ScanDir().filePattern( 'AOD.18954529._*.pool.root.1').scan( sh, inputFilePath )
# pp only
inputFilePath = '/atlasgpfs01/usatlas/data/cher97/mc18_jet/'
# inputFilePath = '/atlasgpfs01/usatlas/data/cher97/singlesamples365678/CCPEB/'
# inputFilePath = '/atlasgpfs01/usatlas/data/cher97/mc/'
# inputFilePath = '/atlasgpfs01/usatlas/data/cher97/mc15_68_68/'
# inputFilePath = '/atlasgpfs01/usatlas/data/cher97/mc16_0_0/'
# inputFilePath = '/atlasgpfs01/usatlas/data/cher97/HIJING_evnt/'
# inputFilePath = '/atlasgpfs01/usatlas/data/cher97/data18_jet/'
# inputFilePath = '/atlasgpfs01/usatlas/data/cher97/data18_HPAOD/'
ROOT.SH.ScanDir().filePattern( '*AOD*').scan( sh, inputFilePath )
# ROOT.SH.ScanDir().filePattern( '*root*').scan( sh, inputFilePath )

# inputFilePath = '/afs/cern.ch/work/x/xiaoning/dataFiles/data17_5TeV.00340718.physics_Main.merge.AOD.f911_m1917/'
# inputFilePath = '/afs/cern.ch/work/x/xiaoning/dataFiles/mc16_5TeV.420011.Pythia8EvtGen_A14NNPDF23LO_jetjet_JZ1R04.recon.AOD.e6608_s3238_r11199/'
# inputFilePath = '/afs/cern.ch/work/x/xiaoning/dataFiles/mc16_5TeV.420266.Pythia8EvtGen_A14NNPDF23LO_jetjet_JZ2R04Opt_mufilter.merge.AOD.e7190_s3238_r10441_r10210/'

# ROOT.SH.ScanDir().filePattern( 'data17_5TeV.00340718.physics_Main.merge.AOD.f911_m1917._lb0587._0010.1' ).scan( sh, inputFilePath )
# ROOT.SH.ScanDir().filePattern( 'AOD.17254382._008634.pool.root.1' ).scan( sh, inputFilePath )
# ROOT.SH.ScanDir().filePattern( 'AOD.16822061._000257.pool.root.1' ).scan( sh, inputFilePath )
sh.printContent()

# Create an EventLoop job.
job = ROOT.EL.Job()
job.sampleHandler( sh )
job.options().setDouble( ROOT.EL.Job.optMaxEvents,1000)

# Add an output stream called 'ANALYSIS'.
job.outputAdd( ROOT.EL.OutputStream( 'myOutput' ) )

# Create the algorithm's configuration.
from AnaAlgorithm.DualUseConfig import createAlgorithm
alg = createAlgorithm ( 'MyxAODAnalysis', 'AnalysisAlg' )

# later on we'll add some configuration options for our algorithm that go here
# alg.ElectronPtCut = 30000.0
# alg.SampleName = 'Zee'
# alg.OutputStreamName = 'ANALYSIS'
# alg.isPp = True
alg.Verbose =False
alg.isMC = True
alg.CutLevel = "HITight"
alg.runNum = 313000
#alg.RefEta = 1.0
alg.ProbLim = 0.3
alg.Cent = 1
alg.Eff = True
alg.EtaMatch = 1.5
alg.PtCutMatch = 0.5

alg.PtCutTruthMult = 1.0
alg.PtCutMult = 1.0
alg.EtaMult = 2.5
alg.EtaTruthMult = 2.5
alg.PrimLim = 0
alg.hasJets=True
alg.DAOD=True
alg.truthPt=True

alg.FileName = "mce16_16"
alg.JZ = 4
alg.weightToOne=False
#alg.AODContainerName = "GEN_EVENT"

#from AnaAlgorithm.DualUseConfig import addPrivateTool
# add the GRL tool to the algorithm
#addPrivateTool( alg, 'grlTool', 'GoodRunsListSelectionTool' )

# configure the properties of the GRL tool
#fullGRLFilePath = "/usatlas/u/cher97/ROOTAnalysisTutorial/source/MyAnalysis/share/data17_5TeV.periodAllYear_DetStatus-v98-pro21-16_Unknown_PHYS_StandardGRL_All_Good_25ns_ignore_GLOBAL_LOWMU.xml"
#alg.grlTool.GoodRunsListVec = [ fullGRLFilePath ]
#alg.grlTool.PassThrough = 0 # if true (default) will ignore result of GRL and will just pass all events


# Add our algorithm to the job
job.algsAdd( alg )

# Run the job using the direct driver.
driver = ROOT.EL.DirectDriver()
driver.submit( job, options.submission_dir )

# retrieve a histogram from one sample
#sh_hist = ROOT.SH.SampleHandler()
#sh_hist.load ('submitDir10' + '/hist')
#hist = sh_hist.get ('mc16_13TeV.410501.PowhegPythia8EvtGen_A14_ttbar_hdamp258p75_nonallhad.merge.AOD.e5458_s3126_r9364_r9315').readHist('h_jetPt')

# create a canvas, draw the histogram and wait for a
# double click (then continue/end)
#c = ROOT.TCanvas()
#hist.Draw()
#c.Update()
#c.WaitPrimitive()
