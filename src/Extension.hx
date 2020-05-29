import vscode.WorkspaceFolder;
import vscode.ExtensionContext;

class Extension {
	private static final COMMAND_OPEN_FOLDER = "Open Folder";

	@:expose("activate")
	public static function main(context:ExtensionContext):Void {
		Vscode.commands.registerCommand("feathersui.newProject", createNewProject);
	}

	private static function createNewProject():Void {
		var workspaceFolders = Vscode.workspace.workspaceFolders;
		if (workspaceFolders == null) {
			Vscode.window.showErrorMessage("Failed to create new Feathers UI project. Open an empty folder before running this command.", null,
				COMMAND_OPEN_FOLDER)
				.then(function(result) {
					switch (result) {
						case COMMAND_OPEN_FOLDER:
							Vscode.commands.executeCommand("workbench.action.files.openFolder");
					}
				});
			return;
		}
		if (workspaceFolders.length == 1) {
			var workspaceFolder = workspaceFolders[0];
			createNewProjectInWorkspaceFolder(workspaceFolder);
		} else {
			Vscode.window.showWorkspaceFolderPick().then((workspaceFolder) -> {
				if (workspaceFolder == null) {
					return;
				}
				createNewProjectInWorkspaceFolder(workspaceFolder);
			}, (reason) -> {
					// do nothing
				});
		}
	}

	private static function createNewProjectInWorkspaceFolder(workspaceFolder:WorkspaceFolder):Void {
		var terminal = Vscode.window.createTerminal();
		terminal.sendText("haxelib run feathersui new-project \"" + workspaceFolder.uri.fsPath + "\" --vscode");
		terminal.show();
	}
}
