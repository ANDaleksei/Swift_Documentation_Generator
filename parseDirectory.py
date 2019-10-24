from parseFile import *
from os.path import *
from os import listdir, mkdir

def parseDirectory(path, workingDirectory):
	if isfile(path) and path.endswith(".swift"):
		print("Working directory: %s" % workingDirectory)
		print("Path: %s" % (dirname(path) + "/"))
		print("File name: %s" % (basename(path)[:-6]))
		parseFile(dirname(path) + "/", workingDirectory, basename(path)[:-6])
	elif isdir(path):
		if not exists(workingDirectory + "/" + path):
			mkdir(workingDirectory + "/" + path)
		files = listdir(path + "/")
		for file in files:
			parseDirectory(path + "/" + file, workingDirectory)

if not exists("testOutput"):
	mkdir("testOutput")
parseDirectory("testProject", "testOutput")