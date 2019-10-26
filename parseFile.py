import re
from pageGenerator import *

def isFuncWasLast(text):
	funcLast = text.rfind('func')
	classLast = text.rfind('class')
	structLast = text.rfind('struct')
	enumLast = text.rfind('enum')
	protocolLast = text.rfind('protocol')
	extension = text.rfind('extension')
	return funcLast > classLast and funcLast > structLast and funcLast > enumLast and funcLast > protocolLast and funcLast > extension

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

def removeBreakLines(text):
	newText = ""
	isFunc = False
	for line in text.split('\n'):
		isMethod = re.search('(^|\\s*)(func\\s|init())', line)
		if isFunc:
			line = line.strip()	
		newText += line
		isFunc = isMethod or isFunc
		if isFunc:
			#if line.find(')') != -1:
			openCount = line.count('(')
			closeCount = line.count(')')
			if (closeCount > openCount) or (isMethod and closeCount == openCount):
				isFunc = False
				newText += '\n'
		else:
			newText += '\n'
	return newText

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

def getObjects(text):
	objects = list()
	globalFunc = list()
	currentObject = None
	comment = ""
	for line in text.split('\n'):
		if re.search('(^|\\s*)(class|struct|enum|protocol|extension)\\s', line):
			if currentObject is None:
				obj = SwiftObject()
				obj.name = line[:-1]
				obj.declarations = list()
				obj.functions = list()
				objects.append(obj)
				currentObject = obj
			else:
				currentObject.declarations.append(line)
		elif re.search('(^|\\s*)(var|let)\\s', line) and currentObject is not None:
			currentObject.declarations.append(line)
		elif line.find('}') != -1:
			currentObject = None
		elif re.search('(^|\\s*)(func\\s|init())', line):
			function = Function()
			function.comment = comment if len(comment) > 0 else "No comment"
			function.name = line
			comment = ""
			if currentObject is None:
				globalFunc.append(function)
			else:
				currentObject.functions.append(function)
		elif re.search('(^|\\s*)(//)', line):
			comment += line + '\n'
		else:
			comment = ""
	if len(globalFunc) != 0:
		globalScope = SwiftObject()
		globalScope.name = "Global"
		globalScope.declarations = list()
		globalScope.functions = globalFunc
		objects.append(globalScope)
	return objects

def parseFile(path, workingDirectory, name):
	file = open('%s/%s.swift' % (path, name), mode='r')
	text = file.read()
	file.close()
	interface = removeBody(text)
	textWithoutBreaking = removeBreakLines(interface)
	print(textWithoutBreaking)
	onlyNeededStaff = removeEmptyLines(textWithoutBreaking)
	objects = getObjects(onlyNeededStaff)
	for object in objects:
		print("Name is %s" % object.name)
		for decl in object.declarations:
			print("Declaration is %s" % decl)
		for f in object.functions:
			print("Function is %s" % f.name)
	text = generatePage(objects)
	#page = open('%s/%s/%s.html' % (workingDirectory, path, name), mode='w')
	page = open('%s%s/%s.html' % (workingDirectory, path, name), mode='w')
	page.write(text)
	page.close()

parseFile("example", "", "PostPlayerStore")








