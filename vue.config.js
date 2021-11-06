function getPublicPath() {
  switch (process.env.NODE_ENV) {
    case 'production': return './'
    default: return './'
  }
}

module.exports = {
  publicPath: getPublicPath()
}
