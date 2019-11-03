from parseFile import *
from generateIndex import *
from generateReferences import *
from os.path import *
from generateDirectoryPage import *
from os import listdir, mkdir
import sys
import argparse

# inputs: path to directory and files it contains
# output: returns only directories or swift files
def preprocessFilenames(path, files):
	result = list()
	for file in files:
		name = path + "/" + file
		if isfile(name) and name.endswith(".swift"):
			result.append(file)
		elif isdir(name):
			result.append(file)
	return result

# inputs: path to directory and files it contains
# output: content of md file
def parseMD(path, files):
	for file in files:
		fullname = (path + "/" + file)
		if isfile(fullname) and (fullname).endswith(".md"):
			readme = open(fullname, mode="r")
			text = readme.read()
			readme.close()
			return text
	return "No catalog description"

# inputs: path to project (prefix + path), workingDirectory is a directory where we'll store documentation
# outputs: classes references across all project
# this function create all html files for each swift file in input project
def parseDirectory(prefix, path, workingDirectory):
	references = dict()
	allPath = prefix + path
	md = ""
	if isfile(allPath) and allPath.endswith(".swift"):
		name = basename(path)[:-6]
		path = dirname(path) + "/"
		references.update(parseFile(prefix, path + "/", workingDirectory, name))
		return references, File(basename(allPath),'%s/%s%s.html' % (workingDirectory, path, name))

		name = basename(path)[:-6]
		path = dirname(path) + "/"
		references.update(parseFile(prefix, path + "/", workingDirectory, name))
		return references, File(basename(allPath, '%s/%s%s.html' % (workingDirectory, path, name)))
	elif isdir(allPath):
		directory = Directory(basename(allPath), workingDirectory + "/" + path + ".html")
		if not exists(workingDirectory + "/" + path):
			mkdir(workingDirectory + "/" + path)
		files = listdir(allPath + "/")
		file = open(workingDirectory + "/" + path + ".html", mode="w")
		md = parseMD(allPath, files)
		file.write(generatePage(basename(path), preprocessFilenames(allPath, files), md))
		file.close()
		for file in files:
			filereferences, fileObj = parseDirectory(prefix, path + "/" + file, workingDirectory)
			references.update(filereferences)
			if fileObj is not None:
				directory.files.append(fileObj)
		return references, directory
	else:
		return  dict(), None


def parseProject(projectPath, outputPath):

	projectName = basename(projectPath)
	if not exists(outputPath):
		mkdir(outputPath)

	prefix = dirname(projectPath) + "/" if len(dirname(projectPath)) > 0 else ""
	if isfile(projectPath) and projectPath.endswith(".swift"):
		path = "/" if len(dirname(projectPath)) > 0 else ""
		references = parseFile(dirname(projectPath), path, outputPath, basename(projectPath)[:-6])
		rootDirectory = File(basename(projectPath),'%s.html' % (outputPath + '/' + basename(projectPath)[:-6]))
		rootProject = outputPath + "/" + projectName[:-6] + ".html"
	else:
		references, rootDirectory = parseDirectory(prefix, projectName, outputPath)
		rootProject = outputPath + "/" + projectName + ".html"
	sorted_references = sorted(references.items(), key=lambda kv: kv[0])
	index = generateIndex(projectName, rootProject, rootDirectory)
	page = open("index.html", mode='w')
	page.write(index)
	page.close()
	refFile = open("references.html", mode='w')
	refFile.write(generateReferences(sorted_references))
	refFile.close()


parser = argparse.ArgumentParser(description='Swift documentation generator')
parser.add_argument("--path", help="Path to the folder with swift files", required=True)
parser.add_argument("--outputPath", help="Name of the folder where output will be saved", required=True)
args = parser.parse_args()
parseProject(args.path, args.outputPath)
exit()