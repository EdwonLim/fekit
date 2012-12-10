compiler = require "../compiler/compiler"
utils = require "../util"
connect = require "connect"
rewrite = require "connect-url-rewrite"
urlrouter = require "urlrouter"
dns = require "dns"
http = require "http"
qs = require "querystring"
sysurl = require "url"
syspath = require "path"
sysfs = require "fs"

exports.usage = "创建本地服务器, 可以基于其进行本地开发"

exports.set_options = ( optimist ) ->

    optimist.alias 'p' , 'port'
    optimist.describe 'p' , '启动端口号, 一般无法使用 80 时设置, 并且需要自己做端口转发'

    optimist.alias 'r' , 'route'
    optimist.describe 'r' , '路由,将指定路径路由到其它地址, 物理地址需要均在当前执行目录下. 格式为 项目名:路由后的物理目录名'

mime_config = 
    ".js" : "application/javascript"
    ".css" : "text/css"

_routeRules = ( options ) ->

    if !options.route then return []

    r = options.route.split(":")

    return [ "\/#{r[0]}\/ \/#{r[1]}\/" ]

setupServer = ( options ) ->

    ROOT = options.cwd

    fekitRouter = urlrouter (app) =>

            # PRD地址
            app.get utils.UrlConvert.PRODUCTION_REGEX , ( req , res , next ) =>

                p = syspath.join( ROOT , sysurl.parse( req.url ).pathname )

                if utils.path.is_directory(p)
                    next()
                    return

                urlconvert = new utils.UrlConvert(p)
                srcpath = urlconvert.to_src()

                utils.logger.info("由 PRD #{req.url} 解析至 SRC #{srcpath}")

                res.writeHead( 200, { 'Content-Type': mime_config[urlconvert.extname] });

                if utils.path.exists( srcpath ) 
                    res.end( compiler.compile( srcpath) )
                else
                    res.end( "文件不存在 #{srcpath}" )

    app = connect()
            .use( connect.logger( 'tiny' ) ) 
            .use( rewrite( _routeRules( options ) ) )
            .use( connect.bodyParser() ) 
            .use( fekitRouter )
            .use( connect.static( options.cwd , { hidden: true, redirect: true })  ) 
            .use( connect.query()  ) 
            .use( connect.directory( options.cwd ) ) 

    listenPort( http.createServer(app) , options.port || 80 )



listenPort = ( server, port ) ->
    # TODO 貌似不能捕获error, 直接抛出异常
    server.on "error", (e) ->
        if e.code is 'EADDRINUSE' then console.log "[ERROR]: 端口 #{port} 已经被占用, 请关闭占用该端口的程序或者使用其它端口."
        if e.code is 'EACCES' then console.log "[ERROR]: 权限不足, 请使用sudo执行."
        process.exit 1

    server.on "listening", (e) ->
        console.log "[LOG]: fekit server 运行成功, 端口为 #{port}."
        console.log "[LOG]: 按 Ctrl + C 结束进程." 

    server.listen( port )




exports.run = ( options ) ->
    setupServer( options )