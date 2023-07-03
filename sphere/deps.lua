

return {

	-- controllers

	editorController = {
		"noteChartModel",
		"editorModel",
		"noteSkinModel",
		"previewModel",
		"configModel",
		"resourceModel",
		"windowModel",
	},
	fastplayController = {
		"rhythmModel",
		"replayModel",
		"modifierModel",
		"noteChartModel",
		"difficultyModel",
	},
	gameplayController = {
		"rhythmModel",
		"noteChartModel",
		"noteSkinModel",
		"configModel",
		"modifierModel",
		"difficultyModel",
		"replayModel",
		"multiplayerModel",
		"previewModel",
		"discordModel",
		"scoreModel",
		"onlineModel",
		"resourceModel",
		"windowModel",
		"notificationModel",
		"speedModel",
		"cacheModel",
	},
	mountController = {
		"mountModel",
		"configModel",
		"cacheModel",
	},
	multiplayerController = {
		"multiplayerModel",
		"modifierModel",
		"configModel",
		"selectModel",
		"noteChartSetLibraryModel",
	},
	resultController = {
		"selectModel",
		"replayModel",
		"rhythmModel",
		"modifierModel",
		"onlineModel",
		"configModel",
		"fastplayController",
	},
	selectController = {
		"noteChartModel",
		"selectModel",
		"previewModel",
		"modifierModel",
		"noteSkinModel",
		"configModel",
		"backgroundModel",
		"multiplayerModel",
		"onlineModel",
		"mountModel",
		"cacheModel",
		"osudirectModel",
		"windowModel",
	},

	-- models

	audioModel = {"configModel"},
	backgroundModel = {"configModel"},
	configModel = {},
	cacheModel = {"configModel"},
	collectionModel = {
		"configModel",
		"cacheModel",
	},
	discordModel = {},
	difficultyModel = {},
	editorModel = {
		"configModel",
		"resourceModel",
	},
	notificationModel = {},
	windowModel = {"configModel"},
	mountModel = {"configModel"},
	screenshotModel = {"configModel"},
	themeModel = {"configModel"},
	scoreModel = {"configModel"},
	onlineModel = {"configModel"},
	modifierModel = {},
	noteSkinModel = {"configModel"},
	noteChartModel = {
		"configModel",
		"cacheModel",
	},
	inputModel = {"configModel"},
	noteChartSetLibraryModel = {
		"searchModel",
		"sortModel",
		"cacheModel",
	},
	noteChartLibraryModel = {
		"cacheModel",
	},
	scoreLibraryModel = {
		"configModel",
		"onlineModel",
		"scoreModel",
	},
	sortModel = {},
	searchModel = {"configModel"},
	selectModel = {
		"configModel",
		"searchModel",
		"sortModel",
		"noteChartSetLibraryModel",
		"noteChartLibraryModel",
		"scoreLibraryModel",
		"collectionModel",
	},
	previewModel = {
		"configModel",
	},
	updateModel = {"configModel"},
	rhythmModel = {
		"inputModel",
		"resourceModel",
	},
	osudirectModel = {
		"configModel",
		"cacheModel",
	},
	multiplayerModel = {
		"rhythmModel",
		"configModel",
		"modifierModel",
		"selectModel",
		"onlineModel",
		"osudirectModel",
	},
	replayModel = {
		"rhythmModel",
		"noteChartModel",
		"modifierModel",
	},
	speedModel = {"configModel"},
	resourceModel = {"configModel"},

	-- views

	gameView = {"game"},
	selectView = {"game"},
	resultView = {"game"},
	gameplayView = {"game"},
	multiplayerView = {"game"},
	editorView = {"game"},
}
