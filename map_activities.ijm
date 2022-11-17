// Getting input.
setOption("ExpandableArrays", true);
input = split(getArgument(), ",");
path = input[0];
intensity = input[1];

// Getting colors and layers
layers = split(input[2], "-");
colors = split(input[3], "-");

// Getting thresholds.
thresholds = newArray(layers.length+1);
thresholds[0] = 0;
for (i=1; i<thresholds.length; i++) {
	thresholds[i] = parseFloat(layers[i-1])*255;
}

// Preparing output array.
output = newArray();

// Opening files and getting variables.
open(path+"channels/"+intensity);
files = getFileList(path+"labels/");
for (i = 0; i < files.length; i++) {
	run("Duplicate...", "duplicate");
	rename("int");
	file = replace(files[i], "label_", "");
	file = replace(file, ".tif", "");
	roiManager("open", path+"zips/list_"+file+".zip");
	n = roiManager("count");
	fileOutput = newArray(n);
	activity = newArray(n);
	Array.fill(activity, 0);
	selectWindow("int");
	for (j = 0; j < n; j++) {
	    roiManager('select', j);
	    int = getValue("Mean");
	    k = thresholds.length - 1;
	    while(thresholds[k] > int) {
	    	k = k - 1;
	    }
	    activity[j] = k;
	    fileOutput[j] = k;
	}
	run("RGB Color");
	run("Select All");
	run("Clear");
	for (j = 0; j < n; j++) {
	    roiManager('select', j);
	    setColor(colors[activity[j]]);
	    fill();
	}
	save(path+"marker/marker_"+file+".tif");
	close("ROI Manager");
	close();
	output[output.length] = "-";
	output = Array.concat(output, fileOutput);
}

close(intensity);

// return String.join(output, ",");