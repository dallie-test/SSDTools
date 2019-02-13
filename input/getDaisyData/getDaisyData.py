import os
import subprocess

# input scenario 1
BaseURL     ="http://daisy-1-8-4.frontier.nl/source/"       # url van Daisy
Username    ="GP2018def"                                       # username
Password    ="-P4s7!Hh"                                   # wachtwoord
Years       ="1971-2016"                                    # jaren in de vorm: 1971-2011
BaseDir     ="../"                                       # directory voor de uitvoer (in sub-directories)
Folder      ="GP2018"
Study       ="001 Hybride"

#%% get scenario's
def runBashScript(fn,inputs):
    if not inputs:
        subprocess.Popen(fn,shell=True)
    else:
        command = "bash " + fn
#        command = fn
        for i in inputs:
            command = command +" '"+i+"'"
        print(command)    
        subprocess.Popen(command,shell=True)
    
wd = os.getcwd()
os.chdir('lib/')

# check if BaseDit exists, if not create
if not os.path.exists(BaseDir):
    os.makedirs(BaseDir)

inputs = [BaseURL, 
          Username, 
          Password, 
          Years, 
          BaseDir,
          Folder,
          Study]
runBashScript('GetItAll.sh',inputs)    

os.chdir(wd)


