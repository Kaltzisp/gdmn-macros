// Getting input.
input = split(getArgument(), ",");
path = input[0];
file = input[1];

// Removing extension from filename.
file = File.getNameWithoutExtension(file);

// Creating directory hierarchy.
dirHierarchy = split(file, "-");
var dir = "";

for (i=0; i<dirHierarchy.length; i++) {
	dir = path + String.join(Array.trim(dirHierarchy, i + 1), "/");
	if (!File.isDirectory(dir)) {
		File.makeDirectory(dir);
	}
}

// Moving file.
File.copy(path+file+".tif", dir+"/"+file+".tif");
File.delete(path+file+".tif");
