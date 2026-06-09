.pragma library

function isImageFile(url) {
	return url
		.toString()
		.toLowerCase()
		.match(/\.(png|jpe?g)$/);
}

function isPointInPolygon(px, py, item, currentCanvas) {
	const x = [
		item.topLeftX * currentCanvas.scaleX,
		item.topRightX * currentCanvas.scaleX,
		item.bottomRightX * currentCanvas.scaleX,
		item.bottomLeftX * currentCanvas.scaleX,
	];
	const y = [
		item.topLeftY * currentCanvas.scaleY,
		item.topRightY * currentCanvas.scaleY,
		item.bottomRightY * currentCanvas.scaleY,
		item.bottomLeftY * currentCanvas.scaleY,
	];

	let inside = false;
	for (let i = 0, j = 3; i < 4; j = i++) {
		const xi = x[i],
			yi = y[i];
		const xj = x[j],
			yj = y[j];

		const intersect =
			yi > py !== yj > py && px < ((xj - xi) * (py - yi)) / (yj - yi) + xi;

		if (intersect) inside = !inside;
	}
	return inside;
}

function detectImages(
	urls,
	scanRoot,
	imagesModel,
	detectionsModel,
	Julia,
	noResultDialog,
) {
	if (urls.length === 0) return;
	scanRoot.isProcessing = true;

	Qt.callLater(() => {
		imagesModel.clear();
		detectionsModel.clear();
		scanRoot.activeIndex = -1;

		for (const url of urls) {
			const detections = Julia.detect(url);
			const imageDetections = [];
			// To-Do replace detections array with julia struct
			for (const detection of detections) {
				imageDetections.push({
					content: detection[0],
					format: detection[1],
					topLeftX: detection[2],
					topLeftY: detection[3],
					topRightX: detection[4],
					topRightY: detection[5],
					bottomRightX: detection[6],
					bottomRightY: detection[7],
					bottomLeftX: detection[8],
					bottomLeftY: detection[9],
				});
			}
			imagesModel.append({ path: url, detections: imageDetections });
		}

		scanRoot.isProcessing = false;

		let totalDetections = 0;
		for (let k = 0; k < imagesModel.count; k++) {
			totalDetections += imagesModel.get(k).detections.count;
		}

		if (totalDetections === 0) {
			noResultDialog.open();
			imagesModel.clear();
		} else {
			scanRoot.showDropZone = false;
		}
	});
}

function updateActiveDetections(
	imageIndex,
	imagesModel,
	detectionsModel,
	scanRoot,
	detailsDrawer,
) {
	detectionsModel.clear();
	scanRoot.activeIndex = -1;
	detailsDrawer.close();

	if (imageIndex >= 0 && imageIndex < imagesModel.count) {
		const currentItem = imagesModel.get(imageIndex);
		for (let i = 0; i < currentItem.detections.count; i++) {
			detectionsModel.append(currentItem.detections.get(i));
		}
	}
}
