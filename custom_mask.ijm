// Getting input.
setOption("BlackBackground", true);
input = split(getArgument(), ",");
path = input[0];
template = input[2];
mask = input[1];

if (template == "roi") {
	open(path+"roi.tif");
} else if (template=="label_endo") {
	open(path+"labels/label_endo.tif");
} else {
	open(path+"masks/"+template+".tif");
}

// run("Select None");
setTool(2);
waitForUser("Select the area of the "+mask+" mask, and then hit OK.");
run("Create Mask");
run("Create Selection");
save(path+"masks/mask_"+mask+".tif");
close("*");