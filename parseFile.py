import re
from pageGenerator import *

def removeBody(text):
	newText = ""
	level = 0
	for char in text:
		if char == '{':
			level += 1
		if level < 2:
			newText += char
		if char == '}':
			level -= 1
		
	return newText

def removeBreakLines(text):
	newText = ""
	isFunc = False
	for line in text.split('\n'):
		if isFunc:
			line = line.strip()	
		newText += line
		isFunc = line.find('func') != -1 or isFunc
		if isFunc:
			if line.find(')') != -1:
				isFunc = False
				newText += '\n'
		else:
			newText += '\n'
	return newText

def removeVarsAndEmptyLines(text):
	newText = ""
	objects = ['class', 'struct', 'enum', 'protocol']
	keywords = ['func', '}'] + objects
	isInnerSpace = False
	for line in text.split('\n'):
		if len(line.strip()) == 0:
			continue
		if re.search('(^|\\s*)(var|let)\\s', line):
			continue
		if isInnerSpace and re.search('(^|\\s*)(class|struct|enum|protocol)\\s', line):
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
		if re.search('(^|\\s*)(class|struct|enum|protocol)\\s', line):
			obj = SwiftObject()
			obj.name = line[:-1]
			objects.append(obj)
			currentObject = obj
		elif line.find('{') != -1:
			currentObject = None
		elif re.search('(^|\\s*)(func)\\s', line):
			function = Function()
			function.comment = comment
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
	return objects

file = open('example.swift', mode='r')
text = file.read()
file.close()
interface = removeBody(text)
textWithoutBreaking = removeBreakLines(interface)
onlyNeededStaff = removeVarsAndEmptyLines(textWithoutBreaking)
objects = getObjects(onlyNeededStaff)
text = generatePage(objects)
print(text)









