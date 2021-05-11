#!/usr/bin/env python
"""
A script to generate pfn in BNL dcache for given datasets

Date:    Mar 25, 2014
Contact: Shuwei Ye <yesw@bnl.gov>
"""
Version="pnfs_ls-00-01-04 (2019-07-31)"

# check the associated protocols on
#  http://atlas-agis.cern.ch/agis/service/detail/18144/

# xrootdPrefix = "root://dcdcap02.usatlas.bnl.gov/"
# xrootdPrefix= "root://dcxrd.usatlas.bnl.gov:1096/" # got from Hiro on 20160329
xrootdPrefix= "root://dcgftp.usatlas.bnl.gov:1096/" # within BNL, got from Hiro on 20170518
# xrootdPrefix_outside= "root://dcdoor11.usatlas.bnl.gov:1094/" # access from outside, got from Hiro on 20170518
xrootdPrefix_outside= "root://dcgftp.usatlas.bnl.gov:1094/"
dcachePrefix = "dcache:"
usersPNFS = "/pnfs/usatlas.bnl.gov/users"
mountPNFS = "/direct/usatlas+pnfs"

import os, sys
import optparse
import fnmatch
from glob import glob
import re
import time

rootfile_ext = re.compile("\.root(|.\d)$")

# PathPrefix = "/atlas/dq2"

usage = """
     %prog [options] dsetListFile
  or
     %prog [options] dsetNamePattern[,dsetNamePattern2[,more namePatterns]]
  or
     %prog -o clistFilename /pnfs/FilePathPattern [morePaths]
  or
     %prog -p -o clistFilename [pnfsFilePath | pnfsDirPath] [morePaths]

  This script generates pfn (physical file name), pnfs-path,  
or xrootd-path of files on BNL dcache for given datasets or files on PNFS,
where wildcard and symlink are supported in pnfsFilePath and pnfsDirPath"""
 
optParser = optparse.OptionParser(usage=usage,conflict_handler="resolve")
optParser.add_option('-v',action='store_const', const=True, 
                  dest='verbose', default=False, help='Verbose')
optParser.add_option('-V','--version',action='store_const',const=True,
                  dest='printVersion', default=False, help='print my version')
optParser.add_option('-p','--privateFiles', action='store_const', const=True, dest='privateFiles',
                  default=False, help='List private non-dataset files on dCache')
optParser.add_option('-i','--incomplete', action='store_const', const=True, dest='incomplete',
                  default=False, help='Use incomplete sites if complete not available')
optParser.add_option('-u','--usersDCache', action='store_const', const=True, dest='usersDCache',
                  default=False, help='Use datasets under users private dCache')
optParser.add_option('-l','--listOnly', action='store_const', const=True, dest='listOnly',
                  default=False, help='list only matched datasets under users dCache, no pfn output')
optParser.add_option('-o','--outPfnFile', action='store',dest='outPfnFile',
                  type='string', default='',
                  help='write pfn list into a file instead of printing to the screen')
optParser.add_option('-d','--dirForPfn', action='store',dest='outPfnDir',
                  type='string', default='',
                  help='write pfn list into a directory with a file per dataset')
optParser.add_option('-N','--usePNFS',action='store_const',const=True,
                  dest='usePNFS', default=False, help='using pNFS access, default is xrootd within BNL')
# optParser.add_option('-D','--useDCache',action='store_const',const=True,
#                   dest='useDCache', default=False, help='using dcache: access, default is xrootd within BNL')
optParser.add_option('--useXRootdOutside',action='store_const',const=True,
                  dest='useXRootdOutside', default=False, help='using xroot from outside BNL: access, default is xrootd within BNL')
optParser.add_option('-L','--localBNLSite', action='store',dest='localBNLSite',
                  type='string', default='',
                  help='specify a BNL site, overriding the one choosen by the script')

# parse options and args
options, args = optParser.parse_args()
if options.verbose:
    print options
    print "args=",args
    print

if options.printVersion:
   print "Version:", Version
   sys.exit(0)

if len(args) == 0:
   optParser.print_help()
   optParser.exit(1)

def printUsingClist(clist=None):
   if clist == None:
      clist = "my.clist"
   print "\nYou can use the generated clist file in your job in the following way:"
   clistUsage =  """
    TChain* chain = new TChain(treeName);
    TFileCollection fc("fc","list of input root files","%s");
    chain->AddFileInfoList(fc.GetList());
""" % clist
   print clistUsage


# if options.useXrootd and options.useDCache:
#    sys.exit("Warning!!! CANNOT use both options 'useXrootd' and 'useDCache'")
# if options.useDCache and options.usePNFS:
#    optParser.error("Options --usrDCache and --usePNFS are mutually exclusive")

filePrefix = xrootdPrefix
if options.usePNFS:
   filePrefix = ""
# if options.useDCache:
#    filePrefix = dcachePrefix

headline_output = "# clist file for access within BNL"
if options.useXRootdOutside:
   filePrefix = xrootdPrefix_outside
   headline_output = "# clist file for access from outside BNL"

outMethod = None
pfnPerDset = False
outPfnFile = options.outPfnFile

# check if the first argument starts with /
arg0 = args[0]
if arg0.startswith('/'):
   realpath_arg0 = os.path.realpath(arg0)
   if realpath_arg0.startswith(mountPNFS):
      options.privateFiles = True
   else:
      sys.exit("!!!Error!!! argument starts with /, but not a pnfs path")


# outPfnFile must be given for privateFiles
if options.privateFiles:
   if len(outPfnFile) <= 0:
      sys.exit("!!!Error!!! outPfnFile is NOT given for listing private files")

# out method: File or Dir
outPFN = None
if len(outPfnFile)>0:
   outPFN = open(outPfnFile, 'w')
   outMethod = "File"

outPfnDir = options.outPfnDir
if len(outPfnDir)>0:
   outMethod = "Dir"


# bothRepList={}
# bothRepList = {"COMPLETE":[],"INCOMPLETE":[]}

if options.privateFiles:
   pnfsFiles = args
   if len(pnfsFiles) == 0:
      sys.exit("!!!Error!!! No filenames on PNFS is given to be listed")
else:
   dsetListName=args[0]
   if os.path.isfile(dsetListName):
      listFile = open(dsetListName)
      dsetNames = listFile.readlines()
      listFile.close()
   else:
      # print "dsetListName=",dsetListName
      dsetNames = []
      for arg in args:
          dsetNames += arg.split(',')
   if options.verbose:
      print "dsetNames=",dsetNames

nFilesFound = 0
if options.privateFiles:
   print >>outPFN, headline_output
   print >>outPFN, "#site=Private dCache; input args=",pnfsFiles
   for filePattern in pnfsFiles:
      filesPattern = filePattern
      if os.path.isdir(filePattern):
         filesPattern = os.path.join(filesPattern,"*.root*")
      for oneItem in glob(os.path.expanduser(filesPattern)):
          realPath_item = os.path.realpath(oneItem)
          if not realPath_item.startswith(mountPNFS):
             print "!!!Warning!!! %s is NOT on /pnfs\n" % oneItem
             continue
          if filesPattern == filePattern or rootfile_ext.search(realPath_item):
             nFilesFound += 1
             pnfsPath_item = realPath_item.replace(mountPNFS,"/pnfs")
             print >>outPFN, filePrefix + pnfsPath_item
   outPFN.close()
   print nFilesFound, " files listed into clist file=",outPfnFile
   printUsingClist(outPfnFile)
   sys.exit(0)

# dealing with datasets
old_argv = sys.argv
sys.argv = ['']

if not (options.listOnly and options.usersDCache):
   try:
      from rucio.client import Client
      client = Client()
      myLs   = client
   except:
      sys.exit("Warning!! \"RucioClient\" not set, please set it first")

from cStringIO import StringIO
mystdout = StringIO()
old_stdout = sys.stdout
# sys.stdout = mystdout

def extract_scope(dset):
    # Try to extract the scope from the DSN
    if dset.find(':') > -1:
        if len(dset.split(':')) > 2:
            sys.exit("Too many colons in dataset name=%s" % dset)
        scope, name = dset.split(':')
    else:
        scope = dset.split('.')[0]
        if dset.startswith('user') or dset.startswith('group'):
            scope = ".".join(dset.split('.')[0:2])
        name = dset
    if name.endswith('/'):
       name = name[:-1]
    return scope, name


#-------------------
def listDSOnGrid(DS):
#-------------------
  scope, DS = extract_scope(DS)
  filters = {"type": "dataset", "name": DS}
  dsets = []
  if DS.find('*') > 0:
     dids = client.list_dids(scope, filters={"name":DS}, type='collection', long=True)
     for did in dids:
        if did['did_type'] == 'CONTAINER':
           dsetCont = did['name']
           dset_dids = client.scope_list(scope, dsetCont)
           for dset_did in dset_dids:
               dsetName = dset_did['name']
               dsets += [[dsetName,dsetCont]]
        else:
           dsetName = did['name']
           dsets += [[dsetName,None]]

  else:
     did_info = client.get_did(scope, DS)
     if did_info['type'] == 'CONTAINER':
         dsetCont = DS
         dset_dids = client.scope_list(scope, dsetCont)
         for dset_did in dset_dids:
             dsets += [ [dset_did['name'], dsetCont] ]
     else:
         dsets = [ [did_info['name'],None] ]
  localBNLSite = options.localBNLSite
  dsets_rse = []
  for (dsetName,dsetCont) in dsets:
     best_rse = None
     best_local = 0
     files_total = 0
     if options.verbose:
        print ":listDSOnGrid: dset=",dsetName, ", localBNLSite=",localBNLSite
     for rep in client.list_dataset_replicas(scope, dsetName):
        rse = rep['rse']
        if options.verbose:
           print "rse=",rse
        if localBNLSite != "" and rse != localBNLSite:
           continue
        if not rse.startswith("BNL-") or rse.find("TAPE") >= 0 :
           continue

        local = rep['available_length']
        if options.verbose:
           print "site=",rse, ", local files=",local
        if local > best_local or (rse == "BNL-OSG2_LOCALGROUPDISK" and local == best_local):
           best_rse = rse
           best_local = local
           files_total = rep['length']
     if options.verbose:
        print "best_rse=",best_rse, ", best_local=",best_local
     if best_local > 0:
        isComplete = "yes"
        if best_local < files_total:
           isComplete = "no"
        dsets_rse += [[dsetName, best_rse, isComplete, dsetCont]]
     else:
        dsets_rse += [[dsetName, None, None, dsetCont]]

  return dsets_rse


#-------------------------------
def listUsersDCache(dsPattern):
#------------------------------
   datasets = []
   scope, dsNamePattern = extract_scope(dsPattern)
   dsDirPattern = os.path.join(usersPNFS, "*", "rucio", scope, dsNamePattern)
   subDirs = glob(dsDirPattern)
   for subDir in subDirs:
      dsName = os.path.basename(subDir)
      if dsName not in datasets:
         datasets += [ dsName ]
   return datasets

#--------------------------
def listUsersDCFiles(dsName):  # unfinished
#--------------------------
   filenames = {}
   scope, dsName = extract_scope(dsName)
   filesPattern = os.path.join(usersPNFS, "*", "rucio", scope, dsName, "*")
   files = glob(filesPattern)
   for file_fullPath in files:
      filename = os.path.basename(file_fullPath)
      if filename not in filenames:
         filenames[filename] = file_fullPath
   return filenames


dsets_inComp = []
dsets_absent = []

dsetNames_processed = []
headline_written = False
for dsPattern in dsetNames:
  if len(dsPattern) > 0 and dsPattern[0] == '/':
     print "Warining, is %s really a dataset name ?!" % dsPattern
     continue
  dsInUsersDCache = []
  if dsPattern.count(':') > 0:
     DS = dsPattern.split(':')[-1]
  else:
     DS = dsPattern.strip()
  DS_noSlash = DS.rstrip('/')
  print >> old_stdout, "DS=",DS

  if options.usersDCache:
     dsets = listUsersDCache(DS)
     if len(dsets) == 0:
        print "DS=",DS, " not found in users dcache area"
        continue
     print "dsets in User DCache=", dsets
     if options.listOnly:
        continue
        # sys.exit(0)
  else:
     dsets = listDSOnGrid(DS)

  # print "dsets=",dsets
  # sys.exit(0)

  filePerDset = None
  for dsetName_items in dsets:
      if type(dsetName_items) is list:
         (dsetName,localSite,isComplete, dsetCont) = dsetName_items

         if dsetName in dsetNames_processed:
            print "Warning, dsetName=",dsetName, " was processed before"
            continue
         dsetNames_processed += [dsetName]

         if localSite == None:
            dsets_absent += [dsetName]
            if options.verbose:
               print "Not site found for dsetName=",dsetName
            continue

         if isComplete == "no":
            dsets_inComp += [dsetName]
            if options.incomplete:
               print "Incomplete site %s used for dset=%s" % (localSite, dsetName)
            else:
               continue
      else:
         dsetName = dsetName_items
         localSite = "BNL_UsersDCache"
         isComplete = "dCache"
      print "\ndsetName=",dsetName
      print "Using local site=", localSite

      scope, dummy = extract_scope(dsetName)
      # recursive=True is necessary for container dset in Users dCache area
      files_Iter = client.scope_list(scope=scope, name=dsetName, recursive=True)
      filenames_OnGrid = []
      for item in files_Iter:
         if item['type'] == "FILE":
            filenames_OnGrid += [ item['name'] ]

      if options.verbose:
         print "filenames_OnGrid=",filenames_OnGrid

      path_filenames = {}

      if isComplete == "dCache":
         path_filenames = listUsersDCFiles(dsetName)
         filenames_InUsersDC = path_filenames.keys()
         if set(filenames_InUsersDC) != set(filenames_OnGrid):
            dsets_inComp += [dsetName]
            if options.incomplete:
               print "Incomplete site %s used for dset=%s" % (localSite, dsetName)
            else:
               continue
      else:
         filePathsOnGrid = []
         replicas = client.list_replicas([{"scope":scope, "name":dsetName}])
         for replica in replicas:
            rses = replica['rses']
            rse_localSite = rses[localSite]
            if rse_localSite == None:
               continue
            fileInfo = rse_localSite[0]
            pnfs_pos = fileInfo.find("/pnfs")
            if pnfs_pos < 0:
               print "!!Warning!! filename not begin with /pnfs, filename=",fileInfo
            path_filename = fileInfo.strip()[pnfs_pos:]
            if options.verbose:
               print "fileInfo=",fileInfo,", path_filename=",path_filename
            filename = path_filename.split('/')[-1]
            path_filenames[filename] = path_filename

      if options.verbose:
         print "path_filenames=",path_filenames

      stdout_pfn = old_stdout
      if outPFN != None:
         stdout_pfn = outPFN
      elif outPfnDir:
         if not os.path.exists(outPfnDir):
            os.mkdir(outPfnDir)
         if dsetCont == None:
            if filePerDset:
               filePerDset.close()
            filePerDset = open(outPfnDir+'/'+dsetName+".clist",'w')
         else:
            if filePerDset:
               baseName = os.path.basename(filePerDset.name)
               if baseName != dsetCont+".clist":
                  filePerDset.close()
                  filePerDset = None
            if filePerDset == None:
               filePerDset = open(outPfnDir+'/'+dsetCont+".clist",'w')
         stdout_pfn = filePerDset
         headline_written = False

      if not headline_written:
         print >>stdout_pfn, headline_output
         headline_written = True
      print >>stdout_pfn, "#site=",localSite, "; dset=", dsetName
      for (filename,path_filename) in sorted(path_filenames.items()):
            if rootfile_ext.search(path_filename):
               print >>stdout_pfn, filePrefix + path_filename
               nFilesFound += 1

      mystdout.reset()
      mystdout.truncate()
      sys.stdout = old_stdout

      # print "dsetName=",dsetName, "\n Complete replicas=",bothRepList["Complete"], "\n InComplete replicas=",bothRepList["InComplete"]

  if filePerDset:
     filePerDset.close()


if outPFN != None:
   outPFN.close()

sys.stdout = old_stdout
sys.argv = old_argv


if len(dsets_absent)>0:
   print "\nThe folllowing %d datasets are NOT found at BNL, thus clist not generated" % len(dsets_absent)
   for dset in dsets_absent:
      print dset

if options.verbose:
   print "dsets_inComp=",dsets_inComp

if len(dsets_inComp)>0:
   if options.incomplete:
      print "\nThe folllowing %d datasets are found INCOMPLETE at BNL, but the generated clist file would STILL include them" % len(dsets_inComp)
   else:
      print "\nThe folllowing %d datasets are found INCOMPLETE at BNL, so the generated clist file would NOT include them" % len(dsets_inComp)
   for dset in dsets_inComp:
      print dset

if nFilesFound > 0:
   if outMethod == "File":
      printUsingClist(outPfnFile)
   else:
      printUsingClist()

# for d  in dsets.keys():
#    print d,'\tcomplete replicas:',dsets[d][1],'\tincomplete:',dsets[d][0]
