// Getting inputs.
input = getArgument();
input = split(input, ",");
path = input[0];
mask = input[1];
selection = input[2];
output = input[3];
orientation = input[4];

// Splitting selections.
selections = split(selection, "-");
open(path+"masks/"+mask);

// Opening compact mask and stacking it on myo.
for (i = 0; i < selections.length; i++) {
	open(path+"masks/"+selections[i]);
	if (selections[i] != "mask_compact.tif") {
		run("Create Selection");	
	}
	selectWindow(mask);
	run("Restore Selection");
	if (orientation == "reverse") {
		run("Clear");
	} else {
		run("Clear Outside");
	}
	run("Select None");
	close(selections[i]);
}

// Closing and saving.
save(path+"masks/"+output);
close(mask);