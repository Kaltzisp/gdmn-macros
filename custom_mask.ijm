// Getting input.
setOption("BlackBackground", true);
input = split(getArgument(), ",");
path = input[0];
template = input[2];
mask = input[1];

if (template == "roi") {
	open(path+template+".tif");
} else {
	open(path+"masks/mask_"+template+".tif");
}

run("Select None");
setTool(2);
waitForUser("Select the area of the "+mask+" mask, and then hit OK.");
run("Create Mask");
run("Create Selection");
save(path+"masks/mask_"+mask+".tif");
close("*");