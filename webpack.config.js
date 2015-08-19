var Webpack = require('webpack'),
    path = require('path'),
    mainPath = path.resolve(__dirname, 'assets', 'scripts', 'index.coffee'),
    webpackPaths = require('./config/webpack.paths.js'),
    devServerPort = process.env.PORT || 8080;

module.exports = {
  context: __dirname,
  devtool: 'eval-source-map',

  entry: [
    "font-awesome-webpack!./font-awesome.config.js",
    mainPath
  ],

  output: {
    path: webpackPaths.buildPath,
    publicPath: webpackPaths.publicPath,
    filename: webpackPaths.bundleName
  },

  module: {
    loaders: [
      { test: /\.sass$/, loader: "style-loader!css-loader!sass?indentedSyntax" },
      { test: /\.scss$/, loader: "style-loader!css-loader!sass" },
      { test: /\.coffee$/, loader: "coffee-loader" },
      { test: /\.json$/, loader: "json-loader"},
      { test: /\.woff(2)?(\?v=[0-9]\.[0-9]\.[0-9])?$/, loader: "url-loader?limit=10000&minetype=application/font-woff" },
      { test: /\.(ttf|eot|svg)(\?v=[0-9]\.[0-9]\.[0-9])?$/, loader: "file-loader" }
    ]
  },

  resolve: {
    extensions: ["", ".js", ".coffee", ".sass"]
  },

  plugins: [
    new Webpack.ProvidePlugin({
      "_": "lodash",
      "React": "react/addons",
      "Component": path.resolve(__dirname, 'lib', 'local_modules', 'react-component.coffee'),
      "RouterMini": "react-mini-router",
      "RouterWrapper": path.resolve(__dirname, 'lib', 'local_modules', 'react-router-wrapper.coffee'),
      "Flux": "flux",
      "Bemmer": "bemmer-node/bemmer-class"
    }),

    new Webpack.HotModuleReplacementPlugin()
  ],

  devServer: {
    port: devServerPort,
    historyApiFallback: {
      index: "public/index.html"
    }
  }
};
