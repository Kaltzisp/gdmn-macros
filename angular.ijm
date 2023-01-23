// Angular_V2.2: Peter Kaltzis - 19th January 2022.
// Config.
close("*");
close("ROI Manager");
setOption("ExpandableArrays", true);
setOption("BlackBackground", true);

// === USE CONTROL+R (COMMAND+R ON MAC) TO RUN THE MACRO ===

// Creating dialog.
Dialog.createNonBlocking("Angular Macro v2");
Dialog.addString("Path", "path-to-files", 30);
Dialog.addNumber("Minimum cell size", 50);
Dialog.addChoice("Label cells", newArray("Cell #", "ROI #", "Both"));
Dialog.addCheckbox("Connect z-stack", true);
Dialog.addCheckbox("Generate skeletons", true);
Dialog.addCheckbox("Calculate angles", true);
Dialog.show();

// Getting dialog options.
path = Dialog.getString();
min_size = Dialog.getNumber();
label = Dialog.getChoice();
runStack = Dialog.getCheckbox();
runSkeleton = Dialog.getCheckbox();
runAngle = Dialog.getCheckbox();

// Fixing path.
path = replace(path, "\\", "/");
if (path.substring(path.length - 1) != "/") {
	path = path + "/";
}

if (runStack) {
	// Filtering image.
	open(path+"nuclei.tif");
	run("Analyze Particles...", "size=0-"+min_size+" add stack");
	while (roiManager("count") > 0) {
		roiManager("select", 0);
		run("Clear", "slice");
		roiManager("delete");
	}
	close("ROI Manager");
	run("Select None");
	
	// Z-connecting stack.
	var idx = 0;
	run("Analyze Particles...", "size="+min_size+"-Infinity add stack");
	for (i = 0; i < roiManager("count"); i++) {
		roiManager("select", i);
		x = round(getValue("X"));
		y = round(getValue("Y"));
		if (getValue(x,y) == 255) {
			idx += 1;
			setColor(255 - idx);
			floodFill(x, y);
			while(getSliceNumber() < nSlices) {
				setSlice(getSliceNumber() + 1);
				if (getValue(x,y) != 0) {
					doWand(x, y);
					fill();
					x = round(getValue("X"));
					y = round(getValue("Y"));
				}
			}
		}
	}
	
	// Removing ROI overlays and saving 8-bit nuclei stack.
	roiManager("deselect");
	roiManager("delete");
	close("ROI Manager");
	run("Select None");
	save(path+"nuclei_connected.tif");
	close("nuclei.tif");
}

if (runSkeleton) {
	setForegroundColor(255, 255, 255);
	setBackgroundColor(0, 0, 0);
	// Creating skeletons.
	open(path+"endo.tif");
	run("Median...", "radius=10 stack");
	run("Skeletonize", "stack");
	
	// Manually selecting luminal areas.
	setTool("brush");
	for (i = 1; i <= nSlices; i++) {
	    setSlice(i);
	    run("Select None");
	    waitForUser("Selecton luminal segment then hit OK.");
	    run("Clear Outside", "slice");
	}
	run("Select None");
	
	// Getting macro path.
	mpath = getDirectory("macros");
	mpath = replace(mpath, "\\", "/") + "pk/";
	// Pruning skeletons.
	for (i = 1; i <= nSlices; i++) {
		setSlice(i);
		run("Duplicate...", "slice");
		rename("slice");
		runMacro(mpath + "prune_skeleton.bsh");
		rename(i);
		selectWindow("endo.tif");
		close("slice");
	}
	close("endo.tif");
	run("Images to Stack", "use");
	save(path+"skeletons_pruned.tif");
	close("Stack");
}

if (runAngle) {
	// Get selection coords.
	open(path+"skeletons_pruned.tif");
	rename("ref");
	run("Create Selection");
	Roi.getContainedPoints(X, Y);
	n = X.length;
	run("Select None");
	
	// Getting nuclei.
	open(path+"nuclei_connected.tif");
	rename("nuclei");
	setThreshold(1,255);
	setColor(255,255,255);
	for (i = 1; i <= nSlices; i++) {
	    setSlice(i);
		run("Analyze Particles...", "size="+min_size+"-Infinity pixel add");
		run("Hide Overlay");
		run("Select None");
	}
	resetThreshold;
	
	// Iterating over ROIs.
	m = roiManager("count");
	idxs = newArray(m);
	rois = newArray(m);
	angles = newArray(m);
	ferets = newArray(m);
	lengths = newArray(m);
	selectWindow("nuclei");
	for(j=0; j<m; j++) {

		// Selecting cell roi.
		roiManager("select", j);
		slice = getSliceNumber();
		
		// Getting ref.
		selectWindow("ref");
		setSlice(slice);
		setThreshold(200,255);
		run("Create Selection");
		Roi.getContainedPoints(X, Y);
		n = X.length;
		selectWindow("nuclei");
		roiManager("select", j);
		
		// Getting centroid and index.
		x = getValue("X");
		y = getValue("Y");
		idx = 255 - getValue("Mean");
		
		// Measuring point A.
		Ax = getValue("FeretX");
		Ay = getValue("FeretY");
		
		// Measuring feret.
		feretLength = getValue("Feret");
		feretAngle = getValue("FeretAngle");
		if (feretAngle > 90) { feretAngle -= 180; }
		feretAngle = (PI/180) * feretAngle;
		
		// Calculating point B.
		Bx = round(Ax + feretLength * cos(feretAngle));
		By = round(Ay - feretLength * sin(feretAngle));
		
		// Finding nearest selection points.
		Cx = 0; Cy = 0; Ci = 0;
		Dx = 0; Dy = 0; Di = 0;
		skip = "_";
		while (Ci == Di) {
			minDistanceA = getWidth() * getHeight();
			minDistanceB = getWidth() * getHeight();
			minDistA = getWidth() * getHeight();
			for (i=0; i<n; i++) {
				if (matches(skip, ".*_"+i+"_.*")) {
					continue;
				} else {
					distanceA = sqrt(pow(X[i]-Ax,2)+pow(Y[i]-Ay,2));
					distanceB = sqrt(pow(X[i]-Bx,2)+pow(Y[i]-By,2));
					distA = sqrt(pow(X[i]-x,2)+pow(Y[i]-y,2));
					if (distanceA < minDistanceA) {
						minDistanceA = distanceA;
						Cx = X[i]; Cy = Y[i];
						Ci = i;
					} if (distanceB < minDistanceB) {
						minDistanceB = distanceB;
						Dx = X[i]; Dy = Y[i];
						Di = i;
					} if (distA < minDistA) {
						minDistA = distA;
					}
				}
			}
			skip = skip + Ci + "_";
		}
		
		// Finding angle.
		f = atan2(By-Ay, Bx-Ax); 
		t = atan2(Dy-Cy, Dx-Cx);
		theta = abs(t-f)*(180/PI);
		
		
		// Drawing feret.
		//	setColor(100,100,100);
		//	drawLine(Ax, Ay, Cx, Cy);
		//	drawLine(Bx, By, Dx, Dy);
		//	setColor(0,0,0);
		//	drawLine(Ax, Ay, Bx, By);
		
		idxs[j] = idx;
		rois[j] = j;
		angles[j] = theta;
		ferets[j] = getValue("Feret");
		lengths[j] = minDistA;
	}
	
	
	// Sorting arrays.
	Array.sort(idxs, rois, angles, ferets, lengths);
	Array.show(idxs, rois, angles, ferets, lengths);
	saveAs("results", path+"all_cells.csv");
	close("all_cells.csv");
	
	// Creating average arrays.
	j = 0;
	object = newArray();
	avg_angles = newArray();
	avg_ferets = newArray();
	avg_distances = newArray();
	num_slices = newArray();
	
	// Finding averages.
	imax = idxs[idxs.length - 1];
	run("RGB Color");
	setFont("SansSerif", 18, "antialised");
	for(i=1; i<=imax; i++) {
		// Annotating.
		r = random*155;
		g = random*155+50;
		b = random*155+50;
		avg_angle = 0;
		avg_feret = 0;
		avg_length = 0;
		num = 0;
		for (j=0; j<m; j++) {
			if (idxs[j] == i) {
				avg_angle += angles[j];
				avg_feret += ferets[j];
				avg_length += lengths[j];
				num += 1;
				roiManager("select", rois[j]);
				setColor(r,g,b);
				fill();
				setColor(255,255,255);
				if (label == "Cell #") {
					str = i;
				} else if (label == "ROI #") {
					str = j;
				} else {
					str = ""+i+"("+rois[j]+")";
				}
				drawString(str, getValue("X"), getValue("Y"));
			}
		}
		avg_angle = avg_angle / num;
		avg_feret = avg_feret / num;
		avg_length = avg_length / num;
		object[object.length] = i;
		avg_angles[avg_angles.length] = avg_angle;
		avg_ferets[avg_ferets.length] = avg_feret;
		avg_distances[avg_distances.length] = avg_length;
		num_slices[num_slices.length] = num;
	}
	
	
	// Drawing on ref.
	setColor(255,0,0);
	for (i = 1; i <= nSlices; i++) {
		selectWindow("ref");
	    setSlice(i);
	    run("Create Selection");
		selectWindow("nuclei");
	    setSlice(i);
	    run("Restore Selection");
	    fill();
	}
	
	// Closing extras.
	close("ref");
	close("ROI Manager");
	
	// Saving.
	run("Select None");
	setSlice(1);
	save(path+"label.tif");
	Array.show(object, num_slices, avg_angles, avg_ferets, avg_distances);
	saveAs("results", path+"averages.csv");
	close("averages.csv");
	// close("nuclei");
}



