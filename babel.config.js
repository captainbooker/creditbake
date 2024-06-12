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
    '@babel/plugin-syntax-dynamic-import',
    '@babel/plugin-transform-destructuring',
    ['@babel/plugin-transform-class-properties', { loose: true }],
    ['@babel/plugin-transform-private-methods', { loose: true }],
    ['@babel/plugin-transform-private-property-in-object', { loose: true }],
    '@babel/plugin-transform-runtime',
    '@babel/plugin-transform-regenerator',
  ];

  return {
    presets,
    plugins,
  };
}
