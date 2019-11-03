import random
import string
from datetime import date

class Directory:
	def __init__(self, name, link):
		self.name = name
		self.link = link
		self.files = list()

class File:
	def __init__(self, name, link):
		self.name = name
		self.link = link

def randomString(stringLength=10):
    """Generate a random string of fixed length """
    letters = string.ascii_lowercase
    return ''.join(random.choice(letters) for i in range(stringLength))

def generateIndex(projectName, rootPage, directory):
	referencesContent = makeDirectoryHierachy(directory) if isinstance(directory, Directory) else makeFileRow(directory)
	return """
	<!doctype html>
	<html lang="en">
	  <head>
	    <!-- Required meta tags -->
	    <meta charset="utf-8">
	    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">

	    <!-- Bootstrap CSS -->
	    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/css/bootstrap.min.css" integrity="sha384-ggOyR0iXCbMQv3Xipma34MD+dH/1fQ784/j6cY/iJTQUOhcWr7x9JvoRxT2MZw1T" crossorigin="anonymous">

	    <title>Documentation generator!</title>
	  </head>
	  <body>

	  	<h1 class="alert alert-light">%s</h1>
	  	<p class="alert alert-light">Swift gendoc 1.0.0</p>
	  	<p class="alert alert-light" style="font-size: 0.75em">Generation date: %s</p>
	  	<h3 class="alert alert-light"><a href="%s">Project Documentation</a></h3>
	  	<h3 class="alert alert-light"><a href="references.html">Classes References</a></h3>

	    %s

	    <!-- Optional JavaScript -->
	    <!-- jQuery first, then Popper.js, then Bootstrap JS -->
	    <script src="https://code.jquery.com/jquery-3.3.1.slim.min.js" integrity="sha384-q8i/X+965DzO0rT7abK41JStQIAqVgRVzpbzo5smXKp4YfRvH+8abtTE1Pi6jizo" crossorigin="anonymous"></script>
	    <script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.7/umd/popper.min.js" integrity="sha384-UO2eT0CpHqdSJQ6hJty5KVphtPhzWj9WO1clHTMGa3JDZwrnQq4sF86dIHNDz0W1" crossorigin="anonymous"></script>
	    <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/js/bootstrap.min.js" integrity="sha384-JjSmVgyd0p3pXB1rRibZUAYoIIy6OrQ6VrjIEaFf/nJGzIxFDsf4x0xIM+B07jRM" crossorigin="anonymous"></script>
	  </body>
	</html>
	""" % (projectName, date.today(), rootPage, referencesContent)

def makeDirectoryHierachy(directory):
	directoryContent = "\n".join([makeDirectoryHierachy(file) if isinstance(file, Directory) else makeFileRow(file) for file in directory.files])
	idHead = randomString()
	idCollapse = randomString()
	return """
	<div class="card">
         <div class="card-header" id="%s">
            <h5 class="mb-0">
              	<button class="btn btn-link" type="button" data-toggle="collapse" data-target="#%s" aria-expanded="true" aria-controls="%s">
                	%s
              	</button> <a href="%s#%s">(link here)</a>
            </h5>
        </div>
		<div id="%s" class="collapse show" aria-labelledby="%s">
            <div class="card-body">
              		%s
            </div>
         </div>
    </div>
	""" % (idHead, idCollapse, idCollapse, directory.name, directory.link, idHead, idCollapse, idHead, directoryContent)

def makeFileRow(file):
	idHead = randomString()
	return """
	<div class="card">
         <div class="card-header" id="%s">
            <h5 class="mb-0">
              	<a href="%s#%s">%s</a>
            </h5>
        </div>
    </div>
	""" % (idHead, file.link, idHead, file.name)
