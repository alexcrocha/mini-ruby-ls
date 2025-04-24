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
	// Define client options, which determines aspects of the editor side. In this case, we're defining the output channel where messages are printed
	// and the document selector, to specify which documents the language server should handle
	const outputChannel = vscode.window.createOutputChannel("Mini Ruby LS", {
		log: true,
	});
	const clientOptions: LanguageClientOptions = { documentSelector: [{ language: "ruby" }], outputChannel };

	// Create the language client and start the client.
	client = new LanguageClient(
		'miniRubyLs',
		'Mini Ruby Language Server',
		serverOptions,
		clientOptions
	);
	vscode.commands.registerCommand('miniRubyLs.start', () => {
		client.start();
	});
	vscode.commands.registerCommand('miniRubyLs.stop', () => {
		client.stop();
	});
	// Start the client. This will also launch the server
	client.start();
}

// This method is called when your extension is deactivated
export function deactivate() {
	client.dispose();
}
