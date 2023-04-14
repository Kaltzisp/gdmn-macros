// Getting input.
setOption("ExpandableArrays", false);
input = split(getArgument(), ",");
path = input[0];
intensityImage = input[1];

// Creating output string.
var output = "";

// Getting layer colors and thresholds.
thresholds = split("0-"+input[2], "-");
colors = split(input[3], "-");

// Converting thresholds to pixel values.
for (i=1; i<thresholds.length; i++) {
	thresholds[i] = parseFloat(thresholds[i])*255*0.01;
}

// Opening files and getting variables.
open(path+"channels/"+intensityImage);
labels = getFileList(path+"labels/");

// Creating marker images.
for (i = 0; i<labels.length; i++) {

	// Duplicate intensity image.
	run("Duplicate...", "duplicate");
	rename("intensityImage");

	// Getting file name and zip.
	fileName = replace(labels[i], "(label_|\.tif)", "");
	roiManager("open", path+"zips/list_"+fileName+".zip");

	// Counting objects and creating activity array.
	n = roiManager("count");
	activity = newArray(n);
	Array.fill(activity, 0);

	// Creating counts array.
	counts = newArray(thresholds.length);
	Array.fill(counts, 0);

	// Checking intensities.
	selectWindow("intensityImage");
	for (j=0; j<n; j++) {
	    roiManager("select", j);
	    intensity = getValue("Mean");
	    k = thresholds.length - 1;
	    while(thresholds[k] > intensity) {
	    	k = k - 1;
	    }
	    activity[j] = k;
	    counts[k] += 1;
	}

	// Creating marker image.
	run("Select All");
	run("Clear");
	run("RGB Color");
	for (j=0; j<n; j++) {
	    roiManager("select", j);
	    setColor(colors[activity[j]]);
	    fill();
	}
	
	// Getting total cells and appending to string.
	total = 0;
	for (j=0; j<counts.length; j++) {
		total += counts[j];
	}
	output = output + String.join(counts) + "," + total + ",";
	
	// Saving marker image.
	save(path+"marker/marker_"+fileName+".tif");
	close("ROI Manager");
	close();
}

close(intensityImage);
return output;