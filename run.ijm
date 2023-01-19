// PL Kaltzis - 29/10/21
setOption("BlackBackground", true);
function batchRun(d,p){a=getFileList(d);for(i=0;i<a.length;i++){t=a[i];u=d+t;if(File.isDirectory(u)){batchRun(u,p);}else if(matches(t,p)) {print(d);exe(d,t);}}};

// Path to top level directory and pattern to match in target files.
// Pattern can be a string or regular expression.
path = "C:/Users/peter/Documents/Libs/DMLAb/Honours/Image Analysis/Demo/";
pattern = ".*roi.tif";
batchRun(path, pattern);


// NOTES: SHOULD TRAVECULAR BASE/MIDDLE/APEX ALIGN WITH ENDO LAYERS???


// Macro to run on matching files.
function exe(dir, file) {
	path = dir + ","; // Setting path.
	waitForUser("Match!");
	
	// Preprocess.
	runMacro("pk/make_folders.ijm", path+"channels-labels-marker-masks-zips");
	runMacro("pk/clean_channels.ijm", path+"roi,myo-marker-endo-nuclei");
	runMacro("pk/create_masks.ijm", path+"myo,2,4,2,myo_low");
	runMacro("pk/create_masks.ijm", path+"endo,2,4,2,endo_low");
	runMacro("pk/filter_noise.ijm", path+"myo_low-endo_low,4,myo-endo-nuclei");
	runMacro("pk/create_masks.ijm", path+"myo_clean,4,10,4,myo");
	runMacro("pk/create_masks.ijm", path+"endo_clean,2,6,2,endo");
	runMacro("pk/stardist.ijm", path+"nuclei_clean,0,100,0.4,0.4,100,roi");
	runMacro("pk/segment.ijm", path+"label_roi.tif,list_roi.zip,mask_myo.tif,myo,endo");
	runMacro("pk/crop_mask.ijm", path+"mask_myo.tif,mask_compact.tif,mask_myo_compact.tif,normal");
	runMacro("pk/crop_mask.ijm", path+"mask_myo.tif,mask_compact.tif,mask_myo_trabecular.tif,reverse");
	runMacro("pk/segment.ijm", path+"label_myo.tif,list_myo.zip,mask_myo_compact.tif,myo_compact,myo_trabecular");

	// Bi-segmentations.
	// runMacro("pk/into_layers.ijm", path+"label_myo_trabecular.tif,mask_myo_compact.tif,0.95,myo_trabecular2_base-myo_trabecular2_apex");
	// runMacro("pk/segment.ijm", path+"label_myo_trabecular.tif,list_myo_trabecular.zip,mask_myo_trabecular2_base.tif,myo_trabecular2_base,myo_trabecular2_apex");
	// runMacro("pk/into_layers.ijm", path+"label_endo.tif,mask_myo_compact.tif,0.95,endo2_base-endo2_apex");
	// runMacro("pk/segment.ijm", path+"label_endo.tif,list_endo.zip,mask_endo2_base.tif,endo2_base,endo2_apex");
	// runMacro("pk/crop_mask.ijm", path+"mask_myo_trabecular.tif,mask_myo_trabecular2_base.tif,mask_myo_trabecular2_base.tif,normal");
	// runMacro("pk/crop_mask.ijm", path+"mask_myo_trabecular.tif,mask_myo_trabecular2_base.tif,mask_myo_trabecular2_apex.tif,reverse");
	// runMacro("pk/crop_mask.ijm", path+"mask_endo.tif,mask_endo2_base.tif,mask_endo2_base.tif,normal");
	// runMacro("pk/crop_mask.ijm", path+"mask_endo.tif,mask_endo2_base.tif,mask_endo2_apex.tif,reverse");

	// Tri-segmentations.
	// runMacro("pk/into_layers.ijm", path+"label_myo_trabecular.tif,mask_myo_compact.tif,0.95,myo_trabecular_base-myo_trabecular_middle-myo_trabecular_apex");
	// runMacro("pk/segment.ijm", path+"label_myo_trabecular.tif,list_myo_trabecular.zip,mask_myo_trabecular_base.tif,myo_trabecular_base,myo_trabecular_middle_apex");
	// runMacro("pk/segment.ijm", path+"label_myo_trabecular_middle_apex.tif,list_myo_trabecular_middle_apex.zip,mask_myo_trabecular_middle.tif,myo_trabecular_middle,myo_trabecular_apex");
	// runMacro("pk/into_layers.ijm", path+"label_endo.tif,mask_myo_compact.tif,0.95,endo_base-endo_middle-endo_apex");
	// runMacro("pk/segment.ijm", path+"label_endo.tif,list_endo.zip,mask_endo_base.tif,endo_base,endo_middle_apex");
	// runMacro("pk/segment.ijm", path+"label_endo_middle_apex.tif,list_endo_middle_apex.zip,mask_endo_middle.tif,endo_middle,endo_apex");
	// runMacro("pk/crop_mask.ijm", path+"mask_myo_trabecular.tif,mask_myo_trabecular_base.tif,mask_myo_trabecular_base.tif,normal");
	// runMacro("pk/crop_mask.ijm", path+"mask_myo_trabecular.tif,mask_myo_trabecular_middle.tif,mask_myo_trabecular_middle.tif,normal");
	// runMacro("pk/crop_mask.ijm", path+"mask_myo_trabecular.tif,mask_myo_trabecular_base.tif-mask_myo_trabecular_middle.tif,mask_myo_trabecular_apex.tif,reverse");
	// runMacro("pk/crop_mask.ijm", path+"mask_endo.tif,mask_endo_base.tif,mask_endo_base.tif,normal");
	// runMacro("pk/crop_mask.ijm", path+"mask_endo.tif,mask_endo_middle.tif,mask_endo_middle.tif,normal");
	// runMacro("pk/crop_mask.ijm", path+"mask_endo.tif,mask_endo_base.tif-mask_endo_middle.tif,mask_endo_apex.tif,reverse");

	// Mapping intensities and counting.
	// runMacro("pk/map_activities.ijm", path+"intensity.tif,0.2,blue-red");
	// File.delete(dir+"masks/mask_compact.tif");
	// runMacro("pk/get_areas.ijm", path);

	open(dir+"roi.tif");
	open(dir+"masks/mask_myo.tif");
	run("Create Selection");
	selectWindow("roi.tif");
	run("Restore Selection");
	close("mask*");
	waitForUser(dir);
	close("roi.tif");
}
