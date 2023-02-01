/*
	Feathers UI
	Copyright 2023 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

import vscode.ExtensionContext;
import vscode.QuickPickItem;
import vscode.Uri;
import vscode.WorkspaceFolder;

class Extension {
	private static final COMMAND_OPEN_FOLDER = "Open Folder";

	@:expose("activate")
	public static function main(context:ExtensionContext):Void {
		Vscode.commands.registerCommand("feathersui.newProject", createNewProject);
	}

	private static function createNewProject():Void {
		var workspaceFolders = Vscode.workspace.workspaceFolders;
		if (workspaceFolders == null) {
			openEmptyFolderAndCreateProject();
			return;
		}

		var items:Array<WorkspaceFolderQuickPickItem> = [];
		for (workspaceFolder in workspaceFolders) {
			items.push({label: workspaceFolder.name, detail: workspaceFolder.uri.fsPath, workspaceFolder: workspaceFolder});
		}
		items.push({label: "Open Folder…"});
		Vscode.window.showQuickPick(items, {title: "Create new project in folder…"}).then(result -> {
			if (result == null) {
				// nothing was chosen
				return;
			}
			if (result.workspaceFolder == null) {
				openEmptyFolderAndCreateProject();
				return;
			}
			createNewProjectAtUri(result.workspaceFolder.uri);
			return;
		}, (reason) -> {});
	}

	private static function openEmptyFolderAndCreateProject():Void {
		Vscode.window.showOpenDialog({
			title: "Open empty folder for new project…",
			canSelectFiles: false,
			canSelectMany: false,
			canSelectFolders: true
		}).then((uris) -> {
			if (uris == null || uris.length == 0) {
				return;
			}
			var uri = uris[0];
			if (Vscode.workspace.updateWorkspaceFolders(0, 0, {uri: uri})) {
				createNewProjectAtUri(uri);
			}
			return;
		}, (reason) -> {});
	}

	private static function createNewProjectAtUri(uri:Uri):Void {
		var terminal = Vscode.window.createTerminal();
		terminal.sendText("haxelib run feathersui new-project \"" + uri.fsPath + "\" --vscode");
		terminal.show();
	}
}

private typedef WorkspaceFolderQuickPickItem = {
	> QuickPickItem,
	@:optional var workspaceFolder:WorkspaceFolder;
}
