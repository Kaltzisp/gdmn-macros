/* 
 *  Runs StarDist using given parameters.
 *  Saves the output label (tif) and roi set (zip).
 *  
 *  Then cleans the label using a minimum nucleus area.
 *  Removes all ROIs with an area below the minimum specified.
 *  
 *  Parameters:
 *  	path_to_files
 *  	input_name
 *  	percentile_low
 *  	percentile_high
 *  	probThreshold
 *  	nmsThreshold
 *  	output_name
 *  	minimum_area
 */

// Getting inputs.
input = getArgument();
input = split(input, ",");

// Getting variables and opening files.
path = input[0];
inFile = input[1]+".tif";
min_area = input[6];
outFile = input[7];
open(path+"channels/"+inFile);

// Running StarDist and saving.
run("Command From Macro", "command=[de.csbdresden.stardist.StarDist2D], args=['input':'"+inFile+"', 'modelChoice':'Versatile (fluorescent nuclei)', 'normalizeInput':'true', 'percentileBottom':'"+input[2]+"', 'percentileTop':'"+input[3]+"', 'probThresh':'"+input[4]+"', 'nmsThresh':'"+input[5]+"', 'outputType':'Both', 'nTiles':'1', 'excludeBoundary':'2', 'roiPosition':'Automatic', 'verbose':'false', 'showCsbdeepProgress':'false', 'showProbAndDist':'false'], process=[false]");
// Cleaning label and zip file with min_area.
n = roiManager('count');
for (i = n-1; i>=0; i--) {
    roiManager('select', i);
    if (getValue("Area") < min_area) {
    	run("Clear");
    	roiManager("delete");
    }
}

// Closing and saving.
selectWindow("ROI Manager");
roiManager("save", path+"zips/list_"+outFile+".zip");
run("Close");
save(path+"labels/label_"+outFile+".tif");
close();
close(inFile);