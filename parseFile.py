import re
from pageGenerator import *

accessIdentifier = "(open|public|internal|private(set)|private|fileprivate)?"
additionalPropertyWords = "((override)?(\\s+)(class|static)?)?"
objectPrefix = "^(\\s*)" + accessIdentifier + "(\\s+final)?" + "(\\s*)"
propertyPrefix = "^(\\s*)" + accessIdentifier + "(\\s*)" + additionalPropertyWords + "(\\s*)"
funcPattern = "^(\\s*)" + accessIdentifier + "(\\s*)" + additionalPropertyWords + "(\\s*)func\\s"
initPrefix = "^(\\s*)((convenience|required)(\\s*))?"
initPattern = initPrefix + "init\\("
funcOrInitPattern = "(%s|%s)" % (funcPattern, initPattern)

# check that func was latest in text that other objects
def isFuncWasLast(text):
	funcLast = text.rfind('func')
	classLast = text.rfind('class')
	structLast = text.rfind('struct')
	enumLast = text.rfind('enum')
	protocolLast = text.rfind('protocol')
	extension = text.rfind('extension')
	objectLast = max(classLast, structLast, enumLast, protocolLast, extension)
	return funcLast > objectLast

# function remove all bodies from functions and inner objects
def removeBody(text):
	newText = ""
	prevText = ""
	level = 0
	isInsideFunc = False
	for char in text:
		prevText += char
		if char == '{':
			if level == 0 and isFuncWasLast(prevText):
				isInsideFunc = True
			level += 1
		if level < 2 and not isInsideFunc:
			newText += char
		if char == '}':
			level -= 1
		
	return newText

# function compress all files declarations in one line
def removeBreakLines(text):
	newText = ""
	isFunc = False
	for line in text.split('\n'):
		isMethod = re.search(funcOrInitPattern, line)
		isCase = re.search(propertyPrefix + 'case', line) and line.find('(') != -1 
		if isFunc or isCase:
			line = line.strip()	
		newText += line
		isFunc = isMethod or isFunc or isCase
		if isFunc:
			openCount = line.count('(')
			closeCount = line.count(')')
			if (closeCount > openCount) or ((isMethod or isCase) and closeCount == openCount):
				isFunc = False
				newText += '\n'
		else:
			newText += '\n'
	return newText

# function remove all empty lines
def removeEmptyLines(text):
	newText = ""
	isInnerSpace = False
	for line in text.split('\n'):
		if len(line.strip()) == 0:
			continue
		if line.find('{') != -1:
			isInnerSpace = True
		if line.find('}') != -1:
			isInnerSpace = False
		newText += line + '\n'
	return newText

# function create objects from final text version
def getObjects(text):
	fileComment = ""
	fileCommentIsEnd = False
	objects = list()
	globalScope = SwiftObject("Global scope", "", list(), list())
	currentObject = None
	comment = ""
	for line in text.split('\n'):
		# get all initial comments to variable and use it as file header
		if re.search('(^|\\s*)(//)', line) and not fileCommentIsEnd:
			fileComment += line
		else:
			fileCommentIsEnd = True
		# check object declaration
		if re.search('^(\\s*)import(\\s+)', line):
			globalScope.declarations.insert(0, line)
		elif re.search(objectPrefix + '(class|struct|enum|protocol|extension)\\s', line) and not line.strip().startswith("//"):
			if currentObject is None:
				obj = SwiftObject(line.partition("{")[0], comment, list(), list())
				objects.append(obj)
				currentObject = obj
				comment = ""
			else:
				currentObject.declarations.append(line)
		# check variables declarations
		elif re.search(propertyPrefix + '(((var|let)\\s)|case)', line):
			# if object is none then we are in global scope
			if currentObject is None:
				globalScope.declarations.append(line.partition('=')[0])
			else:
				currentObject.declarations.append(line.partition('=')[0])
		# check functions and initialisations declaration
		elif re.search(funcOrInitPattern, line):
			function = Function(line, comment if len(comment) > 0 else "No comment")
			comment = ""
			# if object is none then we are in global scope
			if currentObject is None:
				globalScope.functions.append(function)
			else:
				currentObject.functions.append(function)
		# check comments
		elif re.search('(^|\\s*)(//)', line):
			comment += line + '\n'
		else:
			comment = ""
		if line.find('}') != -1:
			currentObject = None
	# if we find some functions on gloabl scope then we add new object and call it 'Global'
	if len(globalScope.functions) != 0 or len(globalScope.declarations) != 0:
		objects.insert(0, globalScope)
	return (fileComment, objects)

# get name of object from declaration line
def getObjectName(objName):
	return objName.partition(":")[0].partition("<")[0].split()[-1]

def parseFile(prefix, path, workingDirectory, name):
	filename = '%s/%s.swift' % (prefix + path, name)
	print("Parsing file %s" % filename)
	file = open(filename, mode='r')
	text = file.read()
	file.close()
	textWithoutBody = removeBody(text)
	textWithoutBreakingLines = removeBreakLines(textWithoutBody)
	textWithoutEmptyLines = removeEmptyLines(textWithoutBreakingLines)
	(fileComment, objects) = getObjects(textWithoutBreakingLines)
	text = generatePage(fileComment, objects)
	pageName = '%s/%s%s.html' % (workingDirectory, path, name)
	page = open(pageName, mode='w')
	page.write(text)
	page.close()
	# add objects to references if it is not global and not extension
	classReference = list(filter(lambda swiftObject: not swiftObject.name.find("extension") != -1 and not swiftObject.name.find("Global scope") != -1, objects))
	processedReferences = { getObjectName(swiftObject.name): pageName for swiftObject in classReference }
	return dict(processedReferences)