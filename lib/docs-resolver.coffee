module.exports = DocsResolver =
  cache: {}

  resolve:(path, callback) ->
    if path in Object.keys @cache
      callback(@cache[path])
    else
      @searchMathingDocs(path, callback)

  searchMathingDocs: (path, callback) ->
    for objectType in ['type','enum','struct','trait','fn']
      @assertPageAvailability(path, "#{objectType}.$1.html", callback)
    @assertModulePageAvailability(path, callback)

  assertModulePageAvailability: (path, callback) -> @assertPageAvailability(path, "$1/index.html", callback)

  assertPageAvailability: (path, resourceEndFormat, callback) ->
    channel = atom.config.get('rust-api-docs-helper.rustChannel')
    p = path.replace(/(\w*?)$/, resourceEndFormat)
    req = new XMLHttpRequest()
    req.onloadend = @onLoadEnd(path, @cache, callback)
    req.open("HEAD","http://doc.rust-lang.org/#{channel}/#{p}")
    req.send()

  onLoadEnd: (path, cache, callback) -> (e) ->
    if e.currentTarget.status is 200
      urlFound = e.currentTarget.responseURL
      cache[path] = urlFound
      callback(urlFound)
