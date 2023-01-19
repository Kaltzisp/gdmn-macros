// Color shortcuts.
black = "#000000";
red = "#ff0000";
green = "#00bb00";
blue = "#0000ff";

// Dialog info.
Dialog.createNonBlocking("GdMN Macro Tool");
Dialog.addHelp("https://www.google.com/search?q=I+haven%27t+coded+a+help+function+yet.+Ask+Peter+for+help.");
Dialog.addMessage("Fiji Analysis Tool for GdMN lab - V1.0", 20, black);
Dialog.addMessage("Created by Peter Kaltzis", 11, "#000055");

// Path and file pattern.
Dialog.addString("Path to images:", "copy_path_here", 100);
Dialog.addString("Image file pattern:", "roi.tif");
Dialog.addToSameRow();
Dialog.addMessage("The asterisk * is a wildcard - e.g. Image*roi.tif will match Image_01_roi.tif, Image_02_roi.tif, etc.", 12, blue);

// Image analysis methods.
Dialog.addMessage("Select all methods to apply:", 15, red);

// Folder creation, channel splitting and cleaning.
Dialog.addCheckbox("Split channels", false);
Dialog.addToSameRow();
Dialog.addString("Channel order:", "myo-endo-nuclei-marker", 20);

// Mask creation.
Dialog.addCheckbox("Create myo masks", false);
Dialog.addToSameRow();
Dialog.addNumber("Amplification:", 4)
Dialog.addToSameRow();
Dialog.addNumber("Averaging:", 10);
Dialog.addToSameRow();
Dialog.addNumber("Smoothness:", 4);
Dialog.addCheckbox("Create endo masks", false);
Dialog.addToSameRow();
Dialog.addNumber("Amplification:", 2)
Dialog.addToSameRow();
Dialog.addNumber("Averaging:", 6);
Dialog.addToSameRow();
Dialog.addNumber("Smoothness:", 2);
Dialog.addCheckbox("Create additional mask", false);
Dialog.addToSameRow();
Dialog.addNumber("Amplification:", 2)
Dialog.addToSameRow();
Dialog.addNumber("Averaging:", 6);
Dialog.addToSameRow();
Dialog.addNumber("Smoothness:", 2);
Dialog.addToSameRow();
Dialog.addString("Channel:", "marker");

// Noise filtering using sharp masks.
Dialog.addCheckbox("Clean nuclear channel", false);
Dialog.addToSameRow();
Dialog.addMessage("Attempts to clean blood and other noise from nuclear channel.", 12, blue);

// Linebreak.
Dialog.addMessage("");

// Draw custom masks.
Dialog.addCheckbox("Draw custom mask", false);
Dialog.addToSameRow();
Dialog.addString("Mask name:", "myo_compact");
Dialog.addToSameRow();
Dialog.addString("Template:", "myo");
Dialog.addToSameRow();
Dialog.addMessage("Manually select a region. Template can be roi/myo/endo.", 12, blue);
Dialog.addCheckbox("Compute trabecular mask from compact mask", false);

// Linebreak.
Dialog.addMessage("");

// StarDist plugin.
Dialog.addCheckbox("StarDist nuclear segmentation", false);
Dialog.addToSameRow();
Dialog.addNumber("Lower %", 1.0);
Dialog.addToSameRow();
Dialog.addNumber("Upper %", 99.8);
Dialog.addToSameRow();
Dialog.addNumber("Probability (0-1)", 0.5);
Dialog.addToSameRow();
Dialog.addNumber("Overlap (0-1)", 0.4);
Dialog.addToSameRow();
Dialog.addNumber("Minimum area", 30, 2, 5, "um");

// Nuclear classification.
Dialog.addCheckbox("Myo/Endo classification", false);
Dialog.addToSameRow();
Dialog.addMessage("Segments nuclei into separate myocardial and endocardial labels.", 12, blue);
Dialog.addCheckbox("Compact/Trabecular classification", false);
Dialog.addToSameRow();
Dialog.addMessage("Further segments myocardial nuclei into compact and trabecular labels.", 12, blue);

// Linebreak.
Dialog.addMessage("");

// Tissue sublayers.
Dialog.addCheckbox("Segment into sublayers", false);
Dialog.addToSameRow();
Dialog.addNumber("Number of sublayers:", 3);
Dialog.addToSameRow();
Dialog.addCheckbox("Trabecular Myocardium", true);
Dialog.addToSameRow();
Dialog.addCheckbox("Endocardium", true);

// Linebreak.
Dialog.addMessage("");

// Marker thresholding and quantification.
Dialog.addCheckbox("Threshold marker", false);
Dialog.addToSameRow();
Dialog.addString("Intensity threshold(s):", 30);
Dialog.addToSameRow();
Dialog.addToSameRow();
Dialog.addString("%         Threshold colors:", "blue-red");
Dialog.addCheckbox("Save quantifications", false);

// Showing dialog.
Dialog.show();


// Getting dialog info.
split_channels = Dialog.getCheckbox();
create_myo_masks = Dialog.getCheckbox();
create_endo_masks = Dialog.getCheckbox();
create_optional_mask = Dialog.getCheckbox();
clean_nuclear_channel = Dialog.getCheckbox();
draw_custom_mask = Dialog.getCheckbox();
compute_trabecular_mask = Dialog.getCheckbox();
run_stardist = Dialog.getCheckbox();
segment_tissues = Dialog.getCheckbox();
segment_myo = Dialog.getCheckbox();
create_sublayers = Dialog.getCheckbox();
trabecular_sublayers = Dialog.getCheckbox();
endocardial_sublayers = Dialog.getCheckbox();
perform_thresholding = Dialog.getCheckbox();
save_output = Dialog.getCheckbox();

path = Dialog.getString();
pattern = Dialog.getString();
channels = Dialog.getString();
optional_mask = Dialog.getString();
manual_mask_name = Dialog.getString();
manual_mask_template = Dialog.getString();
threshold_values = Dialog.getString();
threshold_colors = Dialog.getString();

myo_amp = Dialog.getNumber();
myo_avg = Dialog.getNumber();
myo_smooth = Dialog.getNumber();
endo_amp = Dialog.getNumber();
endo_avg = Dialog.getNumber();
endo_smooth = Dialog.getNumber();
optional_amp = Dialog.getNumber();
optional_avg = Dialog.getNumber();
optional_smooth = Dialog.getNumber();
percentile_low = Dialog.getNumber();
percentile_high = Dialog.getNumber();
probability = Dialog.getNumber();
overlap = Dialog.getNumber();
min_area =  Dialog.getNumber();
num_sublayers = Dialog.getNumber();

// Confirming analysis.
path = replace(path, "\\", "/");
if (path.substring(path.length - 1) != "/") {
	path = path + "/";
}
pattern = replace(pattern, "*", ".*");
var count = 0;
function batchRun(d,p) {
	a=getFileList(d);
	for(i=0;i<a.length;i++) {
		t=a[i];
		u=d+t;
		if(File.isDirectory(u)) {
			batchRun(u,p);
		} else if(matches(t,p)) {
				count = count + 1;
		}
	}
};
batchRun(path, pattern);
Dialog.create("Confirm Analysis?");
Dialog.addMessage("Preparing to run in folder:", 12, black);
Dialog.addMessage(path, 12, blue);
Dialog.addMessage("On ALL files matching the pattern:", 12, black);
Dialog.addMessage(pattern, 12, blue);
Dialog.addMessage("The macro has identified: "+count+" images which match these criteria", 20, green);
Dialog.addMessage("WARNING: IF YOU PROCEED, PREVIOUS QUANTIFICATIONS AND LABELS WILL BE OVERWRITTEN.", 12, red);
Dialog.show();

// Check folder integrity and that all the prerequisite folders exist.
runMacro("pk/make_folders.ijm", path+",channels-labels-marker-masks-zips");


// Running macros based on input.
if (split_channels) {
	runMacro("pk/clean_channels.ijm", path+",roi,"+channels);
}
if (create_myo_masks) {
	runMacro("pk/create_masks.ijm", path+",myo,"+myo_amp+","+myo_avg+","+myo_smooth+",myo");
	runMacro("pk/create_masks.ijm", path+",myo,"+(myo_amp/2)+","+(myo_avg/2)+","+(myo_smooth/2)+",myo_low");
}
if (create_endo_masks) {
	runMacro("pk/create_masks.ijm", path+",endo,"+endo_amp+","+endo_avg+","+endo_smooth+",endo");
	runMacro("pk/create_masks.ijm", path+",endo,"+(endo_amp/2)+","+(endo_avg/2)+","+(endo_smooth/2)+",endo_low");
}
if (create_optional_mask) {
	runMacro("pk/create_masks.ijm", path+","+optional_mask+","+optional_amp+","+optional_avg+","+optional_smooth+","+optional_mask);
}
if (clean_nuclear_channel) {
	runMacro("pk/filter_noise.ijm", path+",myo_low-endo_low,4,nuclei");
}
if (draw_custom_mask) {
	runMacro("pk/custom_mask.ijm", path+","+manual_mask_name+","+manual_mask_template);
	if (manual_mask_name == "myo_compact") {
		runMacro("pk/crop_mask.ijm", path+",mask_myo.tif,mask_myo_compact.tif,mask_myo_compact.tif,normal");
	}
}
if (compute_trabecular_mask) {
	runMacro("pk/crop_mask.ijm", path+",mask_myo.tif,mask_myo_compact.tif,mask_myo_trabecular.tif,reverse");
}
if (run_stardist) {
	runMacro("pk/stardist.ijm", path+",nuclei_clean,"+percentile_low+","+percentile_high+","+probability+","+overlap+","+min_area+",roi");
}
if (segment_tissues) {
	runMacro("pk/segment.ijm", path+",label_roi.tif,list_roi.zip,mask_myo.tif,myo,endo");
}
if (segment_myo) {
	runMacro("pk/segment.ijm", path+",label_myo.tif,list_myo.zip,mask_myo_compact.tif,myo_compact,myo_trabecular");
}
if (create_sublayers) {
	if (num_sublayers == 2) {
		if (trabecular_sublayers) {
			runMacro("pk/into_layers.ijm", path+",label_myo_trabecular.tif,mask_myo_compact.tif,0.95,myo_trabecular2_base-myo_trabecular2_apex");
			runMacro("pk/segment.ijm", path+",label_myo_trabecular.tif,list_myo_trabecular.zip,mask_myo_trabecular2_base.tif,myo_trabecular2_base,myo_trabecular2_apex");
			runMacro("pk/crop_mask.ijm", path+",mask_myo_trabecular.tif,mask_myo_trabecular2_base.tif,mask_myo_trabecular2_base.tif,normal");
			runMacro("pk/crop_mask.ijm", path+",mask_myo_trabecular.tif,mask_myo_trabecular2_base.tif,mask_myo_trabecular2_apex.tif,reverse");
		}
		if (endocardial_sublayers) {
			runMacro("pk/into_layers.ijm", path+",label_endo.tif,mask_myo_compact.tif,0.95,endo2_base-endo2_apex");
			runMacro("pk/segment.ijm", path+",label_endo.tif,list_endo.zip,mask_endo2_base.tif,endo2_base,endo2_apex");
			runMacro("pk/crop_mask.ijm", path+",mask_endo.tif,mask_endo2_base.tif,mask_endo2_base.tif,normal");
			runMacro("pk/crop_mask.ijm", path+",mask_endo.tif,mask_endo2_base.tif,mask_endo2_apex.tif,reverse");
		}
	} else if (num_sublayers == 3) {
		if (trabecular_sublayers) {
			runMacro("pk/into_layers.ijm", path+",label_myo_trabecular.tif,mask_myo_compact.tif,0.95,myo_trabecular_base-myo_trabecular_middle-myo_trabecular_apex");
			runMacro("pk/segment.ijm", path+",label_myo_trabecular.tif,list_myo_trabecular.zip,mask_myo_trabecular_base.tif,myo_trabecular_base,myo_trabecular_middle_apex");
			runMacro("pk/segment.ijm", path+",label_myo_trabecular_middle_apex.tif,list_myo_trabecular_middle_apex.zip,mask_myo_trabecular_middle.tif,myo_trabecular_middle,myo_trabecular_apex");
			runMacro("pk/crop_mask.ijm", path+",mask_myo_trabecular.tif,mask_myo_trabecular_base.tif,mask_myo_trabecular_base.tif,normal");
			runMacro("pk/crop_mask.ijm", path+",mask_myo_trabecular.tif,mask_myo_trabecular_middle.tif,mask_myo_trabecular_middle.tif,normal");
			runMacro("pk/crop_mask.ijm", path+",mask_myo_trabecular.tif,mask_myo_trabecular_base.tif-mask_myo_trabecular_middle.tif,mask_myo_trabecular_apex.tif,reverse");
		}
		if (endocardial_sublayers) {
			runMacro("pk/into_layers.ijm", path+",label_endo.tif,mask_myo_compact.tif,0.95,endo_base-endo_middle-endo_apex");
			runMacro("pk/segment.ijm", path+",label_endo.tif,list_endo.zip,mask_endo_base.tif,endo_base,endo_middle_apex");
			runMacro("pk/segment.ijm", path+",label_endo_middle_apex.tif,list_endo_middle_apex.zip,mask_endo_middle.tif,endo_middle,endo_apex");
			runMacro("pk/crop_mask.ijm", path+",mask_endo.tif,mask_endo_base.tif,mask_endo_base.tif,normal");
			runMacro("pk/crop_mask.ijm", path+",mask_endo.tif,mask_endo_middle.tif,mask_endo_middle.tif,normal");
			runMacro("pk/crop_mask.ijm", path+",mask_endo.tif,mask_endo_base.tif-mask_endo_middle.tif,mask_endo_apex.tif,reverse");
		}
	}
}
if (perform_thresholding) {
	runMacro("pk/map_activities.ijm", path+",intensity.tif,"+threshold_values+","+threshold_colors);
}
if (save_output) {
	runMacro("pk/get_areas.ijm", path);
}














