// Getting input.
input = split(getArgument(), ",");
path = input[0];
type = input[1];
quants = split(input[2], "-");

// Header code.
setOption("ExpandableArrays", true);
if (type == "headers") {
	files = newArray();
	if (File.exists(path+"marker/")); {
		f = getFileList(path+"marker/");
		files = Array.concat(files, f);
	}
	if (File.exists(path+"masks/")) {
		f = getFileList(path+"masks/");
		files = Array.concat(files, f);
	}
	
	// Getting path length.
	path = split(path, "/");
	var headers = newArray(path.length);
	headers[0] = "Path";
	// Turning file names into headers. Currently this only works for pos/neg, will not work for multi-category.
	for (j=0; j<files.length; j++) {
		n = headers.length;
		file = replace(files[j], ".tif", "");
		title = replace(file, "marker_", "");
		title = replace(title, "mask_", "");
		if (startsWith(file, "marker_")) {
			headers[n] = "negative_"+title;
			headers[n+1] = "active_"+title;
			headers[n+2] = "total_"+title;
		}
		if (startsWith(file, "mask_")) {
			headers[n] = "area_"+title;
		}
		
	}
	return String.join(headers, ",") + "\n";
	
} else if (type == "entries") { // Entries code.
	split_path = split(path, "/");
	split_path = String.join(split_path, ",");
	var row = split_path + ",";
	if (File.exists(path+"counts.csv")) {
		new_row = File.openAsRawString(path+"counts.csv");
		new_row = new_row.substring(0, new_row.length - 2); // Removes newline.
		row = row + new_row;
	}
	if (File.exists(path+"areas.csv")) {
		new_row = File.openAsRawString(path+"areas.csv");
		new_row = new_row.substring(0, new_row.length - 2); // Removes newline.
		row = row + new_row;
	}
	return row + "\n";
}
