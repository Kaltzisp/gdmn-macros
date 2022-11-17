// Getting input.
input = split(getArgument(), ",");
path = input[0];
type = input[1];
multiplier = parseFloat(input[2]);
radius = parseFloat(input[3]);
closer = parseFloat(input[4]);
output = input[5];

// Creating mask.
open(path+"channels/"+type+".tif");
run("Multiply...", "value="+multiplier);
run("Median...", "radius="+radius);
run("Morphological Filters", "operation=Closing element=Square radius="+closer);
run("Convert to Mask");
run("Create Selection");
save(path+"masks/mask_"+output+".tif");
close(type+".tif");
close(type+"-Closing");