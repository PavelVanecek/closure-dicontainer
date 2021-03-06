// This file was autogenerated by closure-dicontainer.
// Please do not edit.
goog.provide('app.DiContainer');

goog.require('goog.asserts');
goog.require('goog.functions');
goog.require('goog.storage.Storage');
goog.require('goog.storage.mechanism.Mechanism');

/**
 * @constructor
 * @final
 */
app.DiContainer = function() {
  this.rules = [];
};

/**
 * @type {Array}
 * @private
 */
app.DiContainer.prototype.rules;

/**
 * Configure resolving rules for DI Container.
 * @param {...Object} var_args
 *   - resolve: Type or array of types to be resolved.
 *   - as: Which type should be return instead.
 *   - with: Named values for arguments we know in runtime therefore have
 *      to be configured in runtime too.
 *   - by: A factory method for custom resolving.
 */
app.DiContainer.prototype.configure = function(var_args) {
  for (var i = 0; i < arguments.length; i++) {
    var rule = arguments[i];
    goog.asserts.assertObject(rule,
      'DI container: Configuration rule is not type of object.');
    goog.asserts.assertObject(rule.resolve,
      'DI container: Rule resolve property is not type of object.');
    goog.asserts.assert(this.ruleIsWellConfigured(rule),
      'DI container: Rule has to define at least one of these props: with, as, by.');
    goog.asserts.assert(this.ruleNotYetConfigured(rule),
      'DI container: Rule resolve prop can be configured only once.');
    this.rules.push(rule);
  }
};

/**
 * Factory for 'goog.storage.Storage'.
 * @param {Object=} opt_rule
 * @return {goog.storage.Storage}
 */
app.DiContainer.prototype.resolveGoogStorageStorage = function(opt_rule) {
  var rule = /** @type {{
    resolve: (Object),
    as: (Object|undefined),
    with: ({
      mechanism: (!goog.storage.mechanism.Mechanism|undefined)
    }),
    by: (Function|undefined)
  }} */ (opt_rule || this.getRuleFor(goog.storage.Storage));
  var args = [
    rule['with'].mechanism !== undefined ? rule['with'].mechanism : this.resolveGoogStorageMechanismMechanism()
  ];
  if (this.resolvedGoogStorageStorage) return this.resolvedGoogStorageStorage;
  this.resolvedGoogStorageStorage = /** @type {goog.storage.Storage} */ (this.createInstance(goog.storage.Storage, rule, args));
  return this.resolvedGoogStorageStorage;
};

/**
 * Factory for 'goog.storage.mechanism.Mechanism'.
 * @param {Object=} opt_rule
 * @return {goog.storage.mechanism.Mechanism}
 * @private
 */
app.DiContainer.prototype.resolveGoogStorageMechanismMechanism = function(opt_rule) {
  var rule = /** @type {{
    resolve: (Object),
    as: (Object|undefined),
    by: (Function|undefined)
  }} */ (opt_rule || this.getRuleFor(goog.storage.mechanism.Mechanism));
  if (this.resolvedGoogStorageMechanismMechanism) return this.resolvedGoogStorageMechanismMechanism;
  this.resolvedGoogStorageMechanismMechanism = /** @type {goog.storage.mechanism.Mechanism} */ (this.createInstance(goog.storage.mechanism.Mechanism, rule));
  return this.resolvedGoogStorageMechanismMechanism;
};

/**
 * @param {Object} rule
 * @return {boolean}
 * @private
 */
app.DiContainer.prototype.ruleIsWellConfigured = function(rule) {
  if (rule['with'] || rule.by || rule.as) {
    if (rule['with']) goog.asserts.assertObject(rule['with'],
      'DI container: rule.with property must be type of object.');
    if (rule['as']) goog.asserts.assertObject(rule.as,
      'DI container: rule.as property must be type of object.');
    if (rule['by']) goog.asserts.assertFunction(rule.by,
      'DI container: rule.by property must be type of function.');
    return true;
  }
  return false;
};

/**
 * @param {Object} newRule
 * @return {boolean}
 * @private
 */
app.DiContainer.prototype.ruleNotYetConfigured = function(newRule) {
  return !this.rules.some(function(rule) {
    return rule.resolve == newRule.resolve;
  });
};

/**
 * @param {*} type
 * @return {Object}
 * @private
 */
app.DiContainer.prototype.getRuleFor = function(type) {
  var rule = {};
  for (var i = 0; i < this.rules.length; i++) {
    if (this.rules[i].resolve != type) continue;
    rule = this.rules[i];
    break;
  }
  rule['with'] = rule['with'] || {};
  return rule;
};

/**
 * @param {!Function} type
 * @param {Object} rule
 * @param {Array=} args
 * @return {?}
 * @private
 */
app.DiContainer.prototype.createInstance = function(type, rule, args) {
  if (rule.by && !rule.by.length)
    return rule.by();
  var createArgs = [rule.as || type];
  if (args) createArgs.push.apply(createArgs, args);
  var instance = goog.functions.create.apply(null, createArgs);
  if (rule.by && rule.by.length)
    rule.by(instance);
  return instance;
};