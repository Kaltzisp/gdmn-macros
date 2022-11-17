/*
 * Joins a fragmented binary skeleton along the shortest crow-flies paths. 
 *
 */

 // Getting current image and skeleton image. 
//skel = getArgument();
//old = getTitle();
close("ROI Manager");

// Getting fragments
run("Select None");
run("Analyze Particles...", "size=0-Infinity add");
Overlay.hide;
n = roiManager("count");
for (i=0; i<n; i++) {
	roiManager("select", i);
	getSelectionCoordinates(X, Y);
	complement = Array.getSequence(n);
	complement = Array.deleteIndex(complement, i);
	print(complement.length);
	roiManager("select", complement);
	roiManager("combine");
	getSelectionCoordinates(NX, NY);
	run("Clear");
}
