babel = require 'babel-core'

transform = (content) ->
    plugins = [
        "syntax-async-functions",
        "syntax-class-properties",
        "syntax-trailing-function-commas",
        "transform-class-properties",
        "transform-es2015-arrow-functions",
        "transform-es2015-block-scoping",
        "transform-es2015-classes",
        "transform-es2015-computed-properties",
        "transform-es2015-constants",
        "transform-es2015-destructuring",
        ["transform-es2015-modules-commonjs", {"strict": false, "allowTopLevelThis": true}],
        "transform-es2015-parameters",
        "transform-es2015-shorthand-properties",
        "transform-es2015-spread",
        "transform-es2015-template-literals",
        "transform-flow-strip-types",
        "transform-object-assign",
        "transform-object-rest-spread",
        "transform-react-display-name",
        "transform-react-jsx",
        "transform-regenerator",
        "transform-es2015-for-of",
        'external-helpers-2',
        [require('fbjs-scripts/babel-6/inline-requires')],
        [require('./_system-import')]
    ];

    plugins = plugins.map (plugin) ->
        plugin = [].concat plugin
        if typeof plugin[0] is 'string'
            plugin[0] = require('babel-plugin-' + plugin[0])
            plugin[0] = if plugin[0].__esModule then plugin[0].default else plugin[0]

        return plugin;


    return babel.transform(content, {
        retainLines: true,
        compact: true,
        comments: false,
        sourceMaps: false,
        plugins: plugins
    }).code


exports.contentType = "javascript"

exports.process = ( txt , path , module , cb ) ->
    try
        console.log transform( txt )
        cb( null , transform( txt ) )
    catch err
        cb( err )
