var webpack = require("webpack");

var devServerPort = process.env.PORT || 8080;

module.exports = {
  entry: [
    "font-awesome-webpack!./font-awesome.config.js",
    "assets/scripts/index"
  ],
  output: {
    path: "./build",
    publicPath: "/build",
    filename: "bundle.js"
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
    new webpack.ProvidePlugin({
      "_": "lodash",
      "React": "react/addons",
      "React.createComponent": "./assets/scripts/lib/_react_component.coffee"
      "RouterMini": "react-mini-router",
      "Flux": "flux",
      "Bemmer": "bemmer-node/bemmer-class",
      "bemmer": "bemmer-node"
    })
  ],
  devServer: {
    port: devServerPort,
    historyApiFallback: {
      index: "/index.html"
    }
  }
};
