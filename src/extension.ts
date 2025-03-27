// The module 'vscode' contains the VS Code extensibility API
// Import the module and reference it with the alias vscode in your code below
import * as vscode from 'vscode';
import { LanguageClient, ServerOptions, LanguageClientOptions, Executable } from 'vscode-languageclient/node';

let client: LanguageClient;

// This method is called when your extension is activated
// Your extension is activated the very first time the command is executed
export function activate(context: vscode.ExtensionContext) {
	const serverPath = vscode.Uri.joinPath(context.extensionUri, "server.rb").fsPath;
	const executable: Executable = { command: serverPath };
	const serverOptions: ServerOptions = { run: executable, debug: executable };

	const clientOptions: LanguageClientOptions = { documentSelector: [{ language: "ruby" }] };

	// Create the language client and start the client.
	client = new LanguageClient(
		'miniRubyLs',
		'Mini Ruby Language Server',
		serverOptions,
		clientOptions
	);

	// Start the client. This will also launch the server
	client.start();
}

// This method is called when your extension is deactivated
export function deactivate() {
	client.dispose();
}
