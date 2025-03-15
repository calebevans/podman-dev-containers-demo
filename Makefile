build-images:
#	Java images
	podman build -f ./Containerfiles/Containerfile.java17 -t demo-dev-java:17 .
#	Python images
	podman build -f ./Containerfiles/Containerfile.python311 -t demo-dev-python:3.11 .
