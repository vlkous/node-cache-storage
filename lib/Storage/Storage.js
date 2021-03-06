// Generated by CoffeeScript 1.6.3
(function() {
  var Storage;

  Storage = (function() {
    Storage.prototype.async = false;

    Storage.prototype.cache = null;

    function Storage() {
      if (!(this instanceof Storage)) {
        if (typeof this.read === 'undefined' || typeof this.write === 'undefined' || typeof this.remove === 'undefined' || typeof this.removeAll === 'undefined' || typeof this.getMeta === 'undefined') {
          throw new Error('Cache storage: you have to implement methods read, write, remove, removeAll and getMeta.');
        }
      }
    }

    Storage.prototype.checkFilesSupport = function() {
      var isWindow, version;
      isWindow = typeof window === 'undefined' ? false : true;
      if (isWindow && window.require.simq !== true) {
        throw new Error('Files meta information can be used in browser only with simq.');
      }
      if (isWindow) {
        version = window.require.version;
        if (typeof version === 'undefined' || parseInt(version.replace(/\./g, '')) < 510) {
          throw new Error('File method information is supported only with simq@5.1.0 and later.');
        }
      }
    };

    return Storage;

  })();

  module.exports = Storage;

}).call(this);
