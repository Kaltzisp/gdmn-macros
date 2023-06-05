/*
 *  Segments a label image using a mask and roi set.
 *  
 *  Parameters:
 *  	path_to_files
 *  	label_image
 *  	roi_set
 *  	mask
 *  	output_1_name
 *  	outut_2_name
 */

// Getting inputs.
input = getArgument();
input = split(input, ",");

// Opening windows and getting names.
path = input[0];
open(path+"labels/"+input[1]);
label = getTitle();
open(path+"masks/"+input[3]);
mask = getTitle();

// Looping over inside and outside.
for (j = 0; j < 2; j++) {
	// Duplicating label.
	selectWindow(label);
	run("Select None");
	run("Duplicate...", " ");
	active = getTitle();

	// Opening roi zip.
	open(path+"zips/"+input[2]);
	
	// Filling in first roi (usually black).
	roiManager('select', 0);
	setColor(roiManager("count"));
	fill();
	
	// Clearing inside.
	selectWindow(mask);
	run("Create Selection");
	selectWindow(active);
	run("Restore Selection");
	if (j==0) {
		run("Clear");
	} else {
		run("Clear Outside");
	}

	// Cleaning rois.
	n = roiManager('count');
	for (i = n-1; i >=0; i--) {
	    roiManager('select', i);
	    area = getValue("%Area");
	    if (area < 50) {
	    	 run("Clear");
	    	 roiManager("delete");
	    } else {
	    	setColor(getValue("Mode"));
	    	fill();
	    }
	}
	
	// Saving.
	if (j==0) {
		output = input[5];
	} else {
		output = input[4];
	}
	// Only save if there is data to save.
	if (roiManager("count") > 0) {
		save(path+"labels/label_"+output+".tif");
		roiManager("save", path+"zips/list_"+output+".zip");
	}
	close();
	selectWindow("ROI Manager");
	run("Close");
}

// Closing files.
close(label);
close(mask);