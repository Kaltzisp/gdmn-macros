/* 
 *  Uses a label image to expanding iteratively from a base mask.
 *  Divides the label image into a set of new masks.
 *  
 *  Parameters:
 *  	path_to_files
 *  	label_image
 *  	base_mask
 *  	outer_limit
 *  	new_masks (- separated)
 */

// Getting inputs.
input = getArgument();
input = split(input, ",");

// Opening windows and getting names.
setOption("BlackBackground", true);
path = input[0];
open(path+"labels/"+input[1]);
label = getTitle();
open(path+"masks/"+input[2]);
mask = getTitle();
outer_limit = parseFloat(input[3]);

// Getting number of new masks.
layers = split(input[4], "-");

// Finding px_total (total shaded area) of label.
selectWindow(label);
run("Select All");
px_total = getValue("%Area") * getValue("Area")* 0.01;
run("Select None");

// Getting mask selection.
selectWindow(mask);
run("Create Selection");
selectWindow(label);
run("Restore Selection");
run("Select None");

// Initialising loop variables.
expansion = 0;
upscale = 128;

// Loop through expansions from: 128px to 64px to ... to 1px.
while(upscale>=1) {
	px_roi = 0;
	while(px_roi < outer_limit * px_total) {
		expansion += upscale;
		run("Restore Selection");
		run("Enlarge...", "enlarge="+expansion+" pixel");
		px_roi = getValue("%Area") * getValue("Area")* 0.01;
	}
	expansion -= upscale;
	upscale = upscale * 0.5;
}

// Increasing expansion by 1px to cover entire area.
expansion += 1;

// Loops through layers to create masks.
for (i=1; i<=layers.length; i++) {
	// Recreating initial selection.
	selectWindow(mask);
	run("Select None");
	run("Create Selection");
	
	// Enlarging to outer boundary of selection and creating mask.
	factor = (i/layers.length) * expansion;
	run("Enlarge...", "enlarge="+factor+" pixel");
	run("Create Mask");

	// Clearing inner selection from mask.
	selectWindow(mask);
	run("Select None");
	run("Create Selection");
	selectWindow("Mask");
	run("Restore Selection");
	factor = ((i-1)/layers.length) * expansion;
	run("Enlarge...", "enlarge="+factor+" pixel");
	run("Clear");

	// Saving and closing.
	run("Create Selection");
	save(path+"masks/mask_"+layers[i-1]+".tif");
	close();
}

// Closing files.
close(label);
close(mask);