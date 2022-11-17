// Getting input.
input = split(getArgument(), ",");
path = input[0];
masks = split(input[1], "-");
expansion = input[2];
files = split(input[3],"-");

// Setting background.
setOption("BlackBackground", true);

// Opening files to clean.
for (i=0; i<files.length; i++) {
	open(path+"channels/"+files[i]+".tif");
	run("Select None");
}

// Stacking masks.
open(path+"masks/mask_"+masks[0]+".tif");
rename("masks");
for (i=1; i<masks.length; i++) {
	run("Select None");
	open(path+"masks/mask_"+masks[i]+".tif");
	run("Create Selection");
	selectWindow("masks");
	run("Restore Selection");
	setColor(255,255,255);
	fill();
	close("mask_"+masks[i]+".tif");
}
run("Create Selection");
run("Enlarge...", "enlarge="+expansion);

// Opening files to clean.
for (i=0; i<files.length; i++) {
	selectWindow(files[i]+".tif");
	run("Restore Selection");
	run("Clear Outside", "stack");
	run("Select None");
	save(path+"channels/"+files[i]+"_clean.tif");
	close(files[i]+".tif");
}
close("masks");