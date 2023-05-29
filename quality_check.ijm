// Getting inputs.
input = getArgument();
input = split(input, ",");
path = input[0];

// Creating QC_compact.
if (File.exists(path+"masks/mask_myo_compact.tif")) {
	
	// QC against roi.
//	open(path+"roi.tif");
//	open(path+"masks/mask_myo_compact.tif");
//	run("Create Selection");
//	selectWindow("roi.tif");
//	run("Restore Selection");
//	save(path+"QC_compact.tif");
//	close("roi.tif");
//	close("mask_myo_compact.tif");

	// QC against myo/endo masks.
	open(path+"masks/mask_myo.tif");
	run("Create Selection");
	run("RGB Color");
	setColor(200,200,200);
	fill();
	open(path+"masks/mask_endo.tif");
	run("Create Selection");
	selectWindow("mask_myo.tif");
	run("Restore Selection");
	setColor(100,100,100);
	fill();
	close("mask_endo.tif");
	open(path+"masks/mask_myo_compact.tif");
	run("Create Selection");
	selectWindow("mask_myo.tif");
	run("Restore Selection");
	close("mask_myo_compact.tif");
	save(path+"QC_compact.tif");
	close("mask_myo.tif");
}

// Creating other QC files.
if (File.exists(path+"marker/marker_roi.tif")) {
	open(path+"masks/mask_myo.tif");
	setForegroundColor(255,255,0);
	open(path+"channels/intensity.tif");
	run("RGB Color");
	run("Restore Selection");
	run("Draw");
	run("Select None");
	var nuclei_file = "nuclei.tif";
	if (File.exists(path+"channels/nuclei_clean.tif")) {
		nuclei_file = "nuclei_clean.tif";
	}
	open(path+"channels/"+nuclei_file);
	rename("nuclei");
	run("RGB Color");
	run("Restore Selection");
	run("Draw");
	run("Select None");
	open(path+"marker/marker_roi.tif");
	run("Restore Selection");
	run("Draw");
	run("Select None");
	close("mask_myo.tif");
	setForegroundColor(0,255,0);
	open(path+"masks/mask_endo.tif");
	selectWindow("intensity.tif");
	run("Restore Selection");
	run("Draw");
	run("Select None");
	selectWindow("nuclei");
	run("Restore Selection");
	run("Draw");
	run("Select None");
	selectWindow("marker_roi.tif");
	run("Restore Selection");
	run("Draw");
	run("Select None");
	close("mask_endo.tif");
	selectWindow("intensity.tif");
	save(path+"QC_intensity.tif");
	close("intensity.tif");
	selectWindow("nuclei");
	save(path+"QC_nuclei.tif");
	close("nuclei");
	selectWindow("marker_roi.tif");
	save(path+"QC_marker.tif");
	close("marker_roi.tif");
}

