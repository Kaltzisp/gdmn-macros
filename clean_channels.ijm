// Getting input.
input = split(getArgument(), ",");
path = input[0];
crosstalk_suppression = input[1];
roi = input[2];
channels = split(input[3], "-");

// Splitting channels.
open(path+roi+".tif");
run("Grays");
run("Stack to Images");
for(i=0; i<channels.length; i++) {
	selectWindow(roi+"-000"+(i+1));
	rename(channels[i]);
}

// Cleaning nuclei channel.
selectWindow("nuclei");
run("Duplicate...", " ");
rename("nuclei_clean");
selectWindow("nuclei");
run("Morphological Filters", "operation=Dilation element=Square radius=2");

// Subtracting myo from nuclei.
imageCalculator("Subtract create", "myo", "nuclei-Dilation");
run("Divide...", "value=2.000");
imageCalculator("Subtract create", "nuclei_clean", "Result of myo");
close("nuclei_clean");
rename("nuclei_clean");

// Subtracting endo from nuclei.
imageCalculator("Subtract create", "endo", "nuclei-Dilation");
run("Divide...", "value=2.000");
imageCalculator("Subtract create", "nuclei_clean", "Result of endo");
close("nuclei_clean");
rename("nuclei_clean");

// Saving and closing nuclei.
close("nuclei-Dilation");
close("Result of *");
save(path+"channels/nuclei.tif");
close("nuclei_clean");

// Cleaning myo and endo channels.
selectWindow("endo");
run("Duplicate...", "duplicate");
run("Multiply...", "value="+crosstalk_suppression);
imageCalculator("Subtract create", "myo", "endo-1");
save(path+"channels/myo.tif");
close("Result of myo");
close("endo-1");
imageCalculator("Subtract create", "endo", "myo");
save(path+"channels/endo.tif");
close("Result of endo");

// Saving intensity image.
selectWindow("marker");
save(path+"channels/intensity.tif");
save(path+"channels/marker.tif");

// Close all.
close("*");