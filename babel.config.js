module.exports = function (api) {
  api.cache(true);

  const presets = [
    ['@babel/preset-env', {
      targets: {
        node: 'current',
      },
      useBuiltIns: 'entry',
      corejs: 3,
    }]
  ];

  const plugins = [
    '@babel/plugin-transform-destructuring',
    ['@babel/plugin-proposal-class-properties', { loose: true }],
    '@babel/plugin-proposal-object-rest-spread',
    '@babel/plugin-syntax-dynamic-import',
    '@babel/plugin-transform-runtime',
    '@babel/plugin-transform-regenerator'
  ];

  return {
    presets,
    plugins,
  };
}
