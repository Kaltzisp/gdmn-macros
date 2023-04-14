// Getting inputs.
input = getArgument();
input = split(input, ",");
path = input[0];

// Opening write file.
f = File.open(path+"areas.csv");

areaString = "";

// Getting label list.
masks = getFileList(path+"masks/") ;
for (i=0; i<masks.length; i++) {
    open(path+"masks/"+masks[i]);
	// Getting total area.
	if (i==0) {
		run("Select All");
    	area = toString(getValue("Area"));
    	areaString = areaString + area + ",";
    	run("Select None");
	}
    run("Create Selection");
    area = toString(getValue("Area"));
    areaString = areaString + area + ",";
    close(masks[i]);
}

// Saving file.
print(f, areaString);
File.close(f);
