// Getting input.
input = split(getArgument(), ",");
path = input[0];
folders = split(input[1],"-");

// Making folders.
for(i=0; i<folders.length; i++) {
	if (File.exists(path+folders[i]) == 0) {
		File.makeDirectory(path+folders[i]+"/");
	}
}
