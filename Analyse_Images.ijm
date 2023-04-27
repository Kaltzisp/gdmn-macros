// Color shortcuts.
black = "#000000";
red = "#ff0000";
green = "#00bb00";
blue = "#0000ff";

// Checking previous path.
var defaultPath = "copy_path_here";
var defaultPattern = "roi.tif";
var defaultChannels = "myo-endo-marker-nuclei";
tmp = getDirectory("temp");
if (File.exists(tmp+"FIJI_DEFAULTS")) {
	defaults = split(File.openAsRawString(tmp+"FIJI_DEFAULTS"), ",");
	defaultPath = defaults[0];
	defaultPattern = defaults[1];
	defaultChannels = defaults[2];
}

// Dialog info.
Dialog.createNonBlocking("GdMN Macro Tool");
Dialog.addHelp("https://www.google.com/search?q=I+haven%27t+coded+a+help+function+yet.+Ask+Peter+for+help.");
Dialog.addMessage("Fiji Analysis Tool for GdMN lab - V1.0", 20, black);
Dialog.addMessage("Created by Peter Kaltzis", 11, "#000055");

// Path and file pattern.
Dialog.addCheckbox("Browse for folder...", false);
Dialog.addString("Path to images:", defaultPath, 100);

Dialog.addString("Image file pattern:", defaultPattern);
Dialog.addToSameRow();
Dialog.addMessage("The asterisk * is a wildcard - e.g. Image*roi.tif will match Image_01_roi.tif, Image_02_roi.tif, etc.", 12, blue);

Dialog.addCheckbox("Create folder hierarchy", false);
Dialog.addToSameRow();
Dialog.addMessage("Run this ALONE. Do not combine with other methods.", 12, blue);

// Image analysis methods.
Dialog.addMessage("Select all methods to apply:", 15, red);

// Folder creation, channel splitting and cleaning.
Dialog.addCheckbox("Select ROIs", false);
Dialog.addCheckbox("Split channels", false);
Dialog.addToSameRow();
Dialog.addNumber("Crosstalk suppression:", 1, 2, 6, "");
Dialog.addToSameRow();
Dialog.addString("Channel order:", defaultChannels, 20);

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
Dialog.addCheckbox("Get trabecular mask from compact mask", false);

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
Dialog.addCheckbox("Threshold marker & quantify", false);
Dialog.addToSameRow();
Dialog.addString("Intensity threshold(s):", 30);
Dialog.addToSameRow();
Dialog.addToSameRow();
Dialog.addString("%         Threshold colors:", "blue-red");
Dialog.addCheckbox("Calculate area quantifications", false);
Dialog.addCheckbox("Generate QC files", false);

// Showing dialog.
Dialog.show();

// Fixing path.
path = Dialog.getString();
path = replace(path, "\\", "/");
if (path.substring(path.length - 1) != "/") {
	path = path + "/";
}

// Checking path directory.
browse = Dialog.getCheckbox();
if (browse) {
	path = getDirectory("Select a directory.");
}

// Checking logs directory.
runMacro("pk/make_folders.ijm", path+",logs");
getDateAndTime(y,m,d,D,H,M,S,MS);
dvals = newArray(y,m,d,H,M,S);
for (i=0; i<dvals.length; i++) {
	if (lengthOf(dvals[i]) == 1) {
		dvals[i] = "0" + dvals[i];
	}
}
logfile = String.join(dvals, "-");
f = File.open(path+"logs/"+logfile);

// Getting dialog info.
print(f, "path= " + path);
folder_hierarchy = Dialog.getCheckbox(); print(f, "folder_hierarchy=" + folder_hierarchy);
select_rois = Dialog.getCheckbox(); print(f, "select_rois=" + select_rois);
split_channels = Dialog.getCheckbox(); print(f, "split_channels=" + split_channels);
create_myo_masks = Dialog.getCheckbox(); print(f, "create_myo_masks=" + create_myo_masks);
create_endo_masks = Dialog.getCheckbox(); print(f, "create_endo_masks=" + create_endo_masks);
create_optional_mask = Dialog.getCheckbox(); print(f, "create_optional_mask=" + create_optional_mask);
clean_nuclear_channel = Dialog.getCheckbox(); print(f, "clean_nuclear_channel=" + clean_nuclear_channel);
draw_custom_mask = Dialog.getCheckbox(); print(f, "draw_custom_mask=" + draw_custom_mask);
compute_trabecular_mask = Dialog.getCheckbox(); print(f, "compute_trabecular_mask=" + compute_trabecular_mask);
run_stardist = Dialog.getCheckbox(); print(f, "run_stardist=" + run_stardist);
segment_tissues = Dialog.getCheckbox(); print(f, "segment_tissues=" + segment_tissues);
segment_myo = Dialog.getCheckbox(); print(f, "segment_myo=" + segment_myo);
create_sublayers = Dialog.getCheckbox(); print(f, "create_sublayers=" + create_sublayers);
trabecular_sublayers = Dialog.getCheckbox(); print(f, "trabecular_sublayers=" + trabecular_sublayers);
endocardial_sublayers = Dialog.getCheckbox(); print(f, "endocardial_sublayers=" + endocardial_sublayers);
perform_thresholding = Dialog.getCheckbox(); print(f, "perform_thresholding=" + perform_thresholding);
get_areas = Dialog.getCheckbox(); print(f, "get_areas=" + get_areas);
generate_qc = Dialog.getCheckbox(); print(f, "generate_qc=" + generate_qc);

pattern = Dialog.getString(); print(f, "pattern=" + pattern);
channels = Dialog.getString(); print(f, "channels=" + channels);
optional_mask = Dialog.getString(); print(f, "optional_mask=" + optional_mask);
manual_mask_name = Dialog.getString(); print(f, "manual_mask_name=" + manual_mask_name);
manual_mask_template = Dialog.getString(); print(f, "manual_mask_template=" + manual_mask_template);
threshold_values = Dialog.getString(); print(f, "threshold_values=" + threshold_values);
threshold_colors = Dialog.getString(); print(f, "threshold_colors=" + threshold_colors);

myo_supp = Dialog.getNumber(); print(f, "myo_supp=" + myo_supp);
myo_amp = Dialog.getNumber(); print(f, "myo_amp=" + myo_amp);
myo_avg = Dialog.getNumber(); print(f, "myo_avg=" + myo_avg);
myo_smooth = Dialog.getNumber(); print(f, "myo_smooth=" + myo_smooth);
endo_amp = Dialog.getNumber(); print(f, "endo_amp=" + endo_amp);
endo_avg = Dialog.getNumber(); print(f, "endo_avg=" + endo_avg);
endo_smooth = Dialog.getNumber(); print(f, "endo_smooth=" + endo_smooth);
optional_amp = Dialog.getNumber(); print(f, "optional_amp=" + optional_amp);
optional_avg = Dialog.getNumber(); print(f, "optional_avg=" + optional_avg);
optional_smooth = Dialog.getNumber(); print(f, "optional_smooth=" + optional_smooth);
percentile_low = Dialog.getNumber(); print(f, "percentile_low=" + percentile_low);
percentile_high = Dialog.getNumber(); print(f, "percentile_high=" + percentile_high);
probability = Dialog.getNumber(); print(f, "probability=" + probability);
overlap = Dialog.getNumber(); print(f, "overlap=" + overlap);
min_area = Dialog.getNumber(); print(f, "min_area=" + min_area);
num_sublayers = Dialog.getNumber(); print(f, "num_sublayers=" + num_sublayers);

// Closing logfile.
File.close(f);

// Saving default values.
defaultString = "";
defaultString = defaultString + path + ",";
defaultString = defaultString + pattern + ",";
defaultString = defaultString + channels + ",";
File.saveString(defaultString, tmp+"FIJI_DEFAULTS");

// Confirming analysis.
pattern = replace(pattern, "*", ".*");
var runOn = newArray();
function batchRun(dir, rgx) {
	fileArray = getFileList(dir);
	for(i=0; i<fileArray.length; i++) {
		thisFile = fileArray[i];
		filePath = dir + thisFile;
		if(File.isDirectory(filePath)) {
			batchRun(filePath, rgx);
		} else if(matches(thisFile, rgx)) {
				runOn[runOn.length] = filePath;
		}
	}
}
batchRun(path, pattern);
Dialog.create("Confirm Analysis?");
Dialog.addMessage("Preparing to run in folder:", 12, black);
Dialog.addMessage(path, 12, blue);
Dialog.addMessage("On ALL files matching the pattern:", 12, black);
Dialog.addMessage(pattern, 12, blue);
Dialog.addMessage("The macro has identified: "+runOn.length+" images which match these criteria", 20, green);
Dialog.addMessage("WARNING: IF YOU PROCEED, PREVIOUS QUANTIFICATIONS AND LABELS WILL BE OVERWRITTEN.", 12, red);
Dialog.show();

// Running macro iteratively.
for (i=0; i<runOn.length; i++) {
	// Getting path and file.
	path = split(runOn[i], "/");
	fileName = path[path.length - 1];
	path = String.join(Array.trim(path, path.length - 1), "/") + "/";
	
	// Path sanitization for OSes.
	OS = getInfo("os.name");
	if (OS == "Windows") {
		// Pass.
	} else if (OS == "Linux") {
		path = "/" + path;
	} else if (OS == "Mac OS X") {
		path = "/" + path;
	}
	
	if (folder_hierarchy) {
		// Create folder hierarchy.
		runMacro("pk/create_hierarchy.ijm", path+","+fileName);
		close("Log");
	} else {
		// Check folder integrity and that all the prerequisite folders exist.
		runMacro("pk/make_folders.ijm", path+",channels-labels-marker-masks-zips");
		
		// Running macros based on input.
		if (select_rois) {
			runMacro("pk/select_rois.ijm", path+","+fileName);
		}
		if (split_channels) {
			runMacro("pk/clean_channels.ijm", path+","+myo_supp+",roi,"+channels);
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
			var nuclei_file = "nuclei.tif";
			if (File.exists(path+"channels/nuclei_clean.tif")) {
				nuclei_file = "nuclei_clean.tif";
			}
			runMacro("pk/stardist.ijm", path+","+nuclei_file+","+percentile_low+","+percentile_high+","+probability+","+overlap+","+min_area+",roi");
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
					File.delete(path+"labels/label_myo_trabecular_middle_apex.tif");
					File.delete(path+"zips/list_myo_trabecular_middle_apex.zip");
					close("Log");
					runMacro("pk/crop_mask.ijm", path+",mask_myo_trabecular.tif,mask_myo_trabecular_base.tif,mask_myo_trabecular_base.tif,normal");
					runMacro("pk/crop_mask.ijm", path+",mask_myo_trabecular.tif,mask_myo_trabecular_middle.tif,mask_myo_trabecular_middle.tif,normal");
					runMacro("pk/crop_mask.ijm", path+",mask_myo_trabecular.tif,mask_myo_trabecular_base.tif-mask_myo_trabecular_middle.tif,mask_myo_trabecular_apex.tif,reverse");
				}
				if (endocardial_sublayers) {
					runMacro("pk/into_layers.ijm", path+",label_endo.tif,mask_myo_compact.tif,0.95,endo_base-endo_middle-endo_apex");
					runMacro("pk/segment.ijm", path+",label_endo.tif,list_endo.zip,mask_endo_base.tif,endo_base,endo_middle_apex");
					runMacro("pk/segment.ijm", path+",label_endo_middle_apex.tif,list_endo_middle_apex.zip,mask_endo_middle.tif,endo_middle,endo_apex");
					File.delete(path+"labels/label_endo_middle_apex.tif");
					File.delete(path+"zips/list_endo_middle_apex.zip");
					close("Log");
					runMacro("pk/crop_mask.ijm", path+",mask_endo.tif,mask_endo_base.tif,mask_endo_base.tif,normal");
					runMacro("pk/crop_mask.ijm", path+",mask_endo.tif,mask_endo_middle.tif,mask_endo_middle.tif,normal");
					runMacro("pk/crop_mask.ijm", path+",mask_endo.tif,mask_endo_base.tif-mask_endo_middle.tif,mask_endo_apex.tif,reverse");
				}
			}
		}
		if (perform_thresholding) {
			f = File.open(path+"counts.csv");
			counts = runMacro("pk/map_activities.ijm", path+",intensity.tif,"+threshold_values+","+threshold_colors);
			print(f, counts);
			File.close(f);
		}
		if (get_areas) {
			runMacro("pk/get_areas.ijm", path);
		}
		if (generate_qc) {
			runMacro("pk/quality_check.ijm", path);
		}

	}
}

