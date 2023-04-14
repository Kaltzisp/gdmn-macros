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
    run("Create Selection");
    area = toString(getValue("Area"));
    areaString = areaString + area + ",";
    close(masks[i]);
}

// Saving file.
print(f, areaString);
File.close(f);
