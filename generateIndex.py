def generateIndex(projectName, rootPage, references):
	referencesContent = makeList(references)
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
	  	<p class="alert alert-light" style="font-size: 0.75em">Generation date: 2019-10-26</p>
	  	<h3 class="alert alert-light"><a href="%s">Project Documentation</a></h3>
	  	<h4 class="alert alert-light">Classes references:</h4>

	    %s

	    <!-- Optional JavaScript -->
	    <!-- jQuery first, then Popper.js, then Bootstrap JS -->
	    <script src="https://code.jquery.com/jquery-3.3.1.slim.min.js" integrity="sha384-q8i/X+965DzO0rT7abK41JStQIAqVgRVzpbzo5smXKp4YfRvH+8abtTE1Pi6jizo" crossorigin="anonymous"></script>
	    <script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.7/umd/popper.min.js" integrity="sha384-UO2eT0CpHqdSJQ6hJty5KVphtPhzWj9WO1clHTMGa3JDZwrnQq4sF86dIHNDz0W1" crossorigin="anonymous"></script>
	    <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/js/bootstrap.min.js" integrity="sha384-JjSmVgyd0p3pXB1rRibZUAYoIIy6OrQ6VrjIEaFf/nJGzIxFDsf4x0xIM+B07jRM" crossorigin="anonymous"></script>
	  </body>
	</html>
	""" % (projectName, rootPage, referencesContent)

def makeList(references):
	content = "\n".join([makeOneRow(reference) for reference in references])
	return """
	<ul class="list-group">
	  %s
	</ul>
	""" % content

def makeOneRow(reference):
	return '<li class="list-group-item"><a href="%s">%s</a></li>' % (reference[1], reference[0])