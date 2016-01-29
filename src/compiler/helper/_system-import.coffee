t = require('babel-types');

module.exports = () ->
    return {
        visitor: {
            CallExpression: (path, state) ->
                if !isAppropriateSystemImportCall(path.node)
                    return

                bundlesLayout = state.opts.bundlesLayout
                bundleID = bundlesLayout.getBundleIDForModule path.node.arguments[0].value

                bundles = bundleID.split('.')
                bundles.splice(0, 1)
                bundles = bundles.map (id) ->
                    t.stringLiteral('bundle.' + id);

                path.replaceWith t.callExpression(
                    t.identifier('loadBundles'),
                    [t.arrayExpression(bundles)]
                )
        }
    }


isAppropriateSystemImportCall = (node) ->
    return (
        node.callee.type is 'MemberExpression' &&
        node.callee.object.name is 'System' &&
        node.callee.property.name is 'import' &&
        node.arguments.length is 1 &&
        node.arguments[0].type is 'StringLiteral'
    )
