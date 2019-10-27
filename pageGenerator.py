import random
import string

def randomString(stringLength=10):
    """Generate a random string of fixed length """
    letters = string.ascii_lowercase
    return ''.join(random.choice(letters) for i in range(stringLength))

def generatePage(fileComment, objects):
	body = "\n".join([card(object) + "\n" for object in objects])
	return """
	<!doctype html>
	<html lang="en">
	  <head>
	    <!-- Required meta tags -->
	    <meta charset="utf-8">
	    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">

	    <!-- Bootstrap CSS -->
	    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/css/bootstrap.min.css" integrity="sha384-ggOyR0iXCbMQv3Xipma34MD+dH/1fQ784/j6cY/iJTQUOhcWr7x9JvoRxT2MZw1T" crossorigin="anonymous">

	    <title>Hello, world!</title>
	  </head>
	  <body>
	  	<h5 class="alert alert-light text-primary">%s</h5>
	    %s

	    <!-- Optional JavaScript -->
	    <!-- jQuery first, then Popper.js, then Bootstrap JS -->
	    <script src="https://code.jquery.com/jquery-3.3.1.slim.min.js" integrity="sha384-q8i/X+965DzO0rT7abK41JStQIAqVgRVzpbzo5smXKp4YfRvH+8abtTE1Pi6jizo" crossorigin="anonymous"></script>
	    <script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.7/umd/popper.min.js" integrity="sha384-UO2eT0CpHqdSJQ6hJty5KVphtPhzWj9WO1clHTMGa3JDZwrnQq4sF86dIHNDz0W1" crossorigin="anonymous"></script>
	    <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/js/bootstrap.min.js" integrity="sha384-JjSmVgyd0p3pXB1rRibZUAYoIIy6OrQ6VrjIEaFf/nJGzIxFDsf4x0xIM+B07jRM" crossorigin="anonymous"></script>
	  </body>
	</html>
	""" % (fileComment.replace('//', '<br>'), body)

def card(object):
	content = listFunctions(object.functions)
	declarations = makeDeclarations(object.declarations)
	return """
	<div class="card bg-primary mb-3">
	  <div class="card-header text-white"> %s<br>%s </div>
	  <div class="card-body">
	  	%s
	    %s
	  </div>
	</div>
	""" % (object.comment.replace("\n", "<br />"), object.name, declarations, content)

def makeDeclarations(declarations):
	content = "\n".join([makeOneRow(declaration) for declaration in declarations])
	return """
	<div class="card text-primary">
	  <ul class="list-group list-group-flush">
	    %s
	  </ul>
	</div>
	""" % content

def makeOneRow(text):
	return '<li class="list-group-item">%s</li>' % (text.replace('<', '&lt'))

def listFunctions(functions):
	text = "\n".join([functionCollapse(func) + "\n" for func in functions])
	return """
	<div class="accordion" id="accordionExample">
	  %s
	</div>
	""" % text

def functionCollapse(function):
	id = randomString()
	return """
	<div class="card">
	    <div class="card-header" id="headingOne">
	      <h2 class="mb-0">
	        <button class="btn btn-link" type="button" data-toggle="collapse" data-target="#%s" aria-expanded="true" aria-controls="%s">
	          %s
	        </button>
	      </h2>
	    </div>

	    <div id="%s" class="collapse show" aria-labelledby="headingOne" data-parent="#accordionExample">
	      <div class="card-body text-success">
	        %s
	      </div>
	    </div>
	  </div> 
	""" % (id, id, function.name.replace('<', '&lt'), id, function.comment.replace('///', '<br>').replace('//', ''))

class SwiftObject:
	name = ""
	comment = ""
	declarations = list()
	functions = list()


class Function:
	comment = ""
	name = ""