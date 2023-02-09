// Getting input.
input = split(getArgument(), ",");
path = input[0];
file = input[1];

// Opening image and prompting ROI selection.
open(path+file);
setTool("polygon");
waitForUser("Select ROI then hit OK.");

// Duplicating roi.
run("Duplicate...", "title=roi duplicate");
run("Clear Outside", "stack");
run("Select None");

// Running grays and saving.
for (i = 1; i <= nSlices; i++) {
    setSlice(i);
    run("Grays");
}
save(path+"roi.tif");
close("*");