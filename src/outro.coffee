module.exports = (diContainerName) ->

  -> """
    /**
     * @param {Object} rule
     * @return {boolean}
     * @private
     */
    #{diContainerName}.prototype.ruleIsWellConfigured = function(rule) {
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
    #{diContainerName}.prototype.ruleNotYetConfigured = function(newRule) {
      return !this.rules.some(function(rule) {
        return rule.resolve == newRule.resolve;
      });
    };

    /**
     * @param {*} type
     * @return {Object}
     * @private
     */
    #{diContainerName}.prototype.getRuleFor = function(type) {
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
    #{diContainerName}.prototype.createInstance = function(type, rule, args) {
      if (rule.by && !rule.by.length)
        return rule.by();
      var createArgs = [rule.as || type];
      if (args) createArgs.push.apply(createArgs, args);
      var instance = goog.functions.create.apply(null, createArgs);
      if (rule.by && rule.by.length)
        rule.by(instance);
      return instance;
    };
  """