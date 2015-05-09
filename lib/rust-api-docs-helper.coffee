{CompositeDisposable}   = require 'atom'
{$, View}               = require 'atom-space-pen-views'
CratesRegex             = require './crates-regex'
DocsResolver            = require './docs-resolver'
ImportToPathTransformer = require './import-to-path-transformer'
Shell                   = require 'shell'

module.exports = RustApiDocsHelper =
  config:
    useInternalBrowser:
      type:'boolean'
      description: """If set, a URL open request will be sent, that will attempt to open the docs URL within atom,
                      in a panel to the right of the current one.
                      Please note that for this functionality to work properly you will need an extra package
                      like mark-hahn/web-browser.
                      """
      default: false

  subscriptions: null

  activate: (state) ->
    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.commands.add 'atom-text-editor', 'rust-api-docs-helper:trigger': => @trigger()

  deactivate: -> @subscriptions.dispose()

  trigger: ->
    possibleImportInLine = @searchForPossibleImportLine()
    if possibleImportInLine
      path = ImportToPathTransformer.transform(possibleImportInLine)
      DocsResolver.resolve(path, @openUrlCallback())

  searchForPossibleImportLine: ->
    editor = atom.workspace.getActiveTextEditor()
    currentRow = editor.getLastCursor().getBeginningOfCurrentWordBufferPosition().row
    editor.lineTextForBufferRow(currentRow).match(CratesRegex)

  openUrlCallback: ->
    if atom.config.get('rust-api-docs-helper.useInternalBrowser')
      options =
        searchAllPanes: true
        split : 'right'
      (url) -> atom.workspace.open(url, options)
    else
      Shell.openExternal
