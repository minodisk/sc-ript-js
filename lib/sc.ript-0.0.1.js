(function() {
  var Bitmap, Button, DLoader, Event, EventEmitter, NumberUtil, Point, Rectangle, k, path, v, _ref,
    __slice = [].slice,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  DLoader = (function() {
    function DLoader() {}

    DLoader.loadData = function(url, method, data) {
      var d, err, xhr;

      if (method == null) {
        method = 'get';
      }
      if (data == null) {
        data = '';
      }
      d = new Deferred;
      if (window.ActiveXObject != null) {
        try {
          xhr = new ActiveXObject('Msxml2.XMLHTTP');
        } catch (_error) {
          err = _error;
          try {
            xhr = new ActiveXObject('Microsoft.XMLHTTP');
          } catch (_error) {
            err = _error;
            throw new TypeError('doesn\'t support XMLHttpRequest');
          }
        }
      } else if (window.XMLHttpRequest) {
        xhr = new XMLHttpRequest;
      } else {
        throw new TypeError('doesn\'t support XMLHttpRequest');
      }
      xhr.onerror = function(err) {
        return d.fail(err);
      };
      xhr.onreadystatechange = function() {
        if (xhr.readyState !== 4) {
          return;
        }
        return d.call(xhr.responseText);
      };
      xhr.open(method, url, true);
      xhr.send(data);
      return d;
    };

    DLoader.loadImage = function(url) {
      var d, image;

      d = new Deferred;
      image = new Image;
      image.onerror = function(err) {
        return d.fail(err);
      };
      image.onload = function() {
        return d.call(image);
      };
      image.src = url;
      return d;
    };

    DLoader.loadFile = function(file) {
      var d, reader;

      d = new Deferred;
      reader = new FileReader;
      reader.onerror = function(err) {
        return d.fail(err);
      };
      reader.onload = function() {
        return d.call(reader.result);
      };
      reader.readAsDataURL(file);
      return d;
    };

    return DLoader;

  })();

  Bitmap = (function() {
    function Bitmap(canvas) {
      this.canvas = canvas;
      this.context = this.canvas.getContext('2d');
    }

    Bitmap.prototype.width = function(value) {
      if (value == null) {
        return this.canvas.width;
      }
      return this.canvas.width = value;
    };

    Bitmap.prototype.height = function(value) {
      if (value == null) {
        return this.canvas.height;
      }
      return this.canvas.height = value;
    };

    Bitmap.prototype.clear = function() {
      return this.canvas.width = this.canvas.width;
    };

    Bitmap.prototype.draw = function(image) {
      return this.context.drawImage(image, 0, 0);
    };

    Bitmap.prototype.drawAt = function(image, point) {
      return this.context.drawImage(image, point.x, point.y);
    };

    Bitmap.prototype.drawTo = function(image, rect) {
      return this.context.drawImage(image, rect.x, rect.y, rect.width, rect.height);
    };

    Bitmap.prototype.drawFromTo = function(image, from, to) {
      return this.context.drawImage(image, from.x, from.y, from.width, from.height, to.x, to.y, to.width, to.height);
    };

    Bitmap.prototype.encodeAsPNG = function() {
      return this.canvas.toDataURL('image/jpeg');
    };

    Bitmap.prototype.encodeAsJPG = function(quality) {
      if (quality == null) {
        quality = 0.8;
      }
      return this.canvas.toDataURL('image/jpeg', quality);
    };

    return Bitmap;

  })();

  Event = (function() {
    function Event(type, data) {
      this.type = type;
      this.data = data;
    }

    return Event;

  })();

  EventEmitter = (function() {
    function EventEmitter() {
      this._receivers = {};
    }

    EventEmitter.prototype.on = function(type, listener, useCapture, priority) {
      var i, receiver, receivers;

      if (useCapture == null) {
        useCapture = false;
      }
      if (priority == null) {
        priority = 0;
      }
      if (typeof listener !== 'function') {
        throw new TypeError('listener is\'t Function');
      }
      if (this._receivers[type] == null) {
        this._receivers[type] = [];
      }
      receivers = this._receivers[type];
      i = receivers.length;
      while (i--) {
        receiver = reveicers[i];
        if (receiver.listener === listener) {
          return this;
        }
      }
      receivers.push({
        listener: listener,
        useCapture: useCapture,
        priority: priority
      });
      receivers.sort(function(a, b) {
        return b.priority - a.priority;
      });
      return this;
    };

    EventEmitter.prototype.off = function(type, listener) {
      var i, receivers;

      receivers = this._receivers[type];
      if (!receivers) {
        return this;
      }
      i = receivers.length;
      while (i--) {
        if (receivers[i].listener === listener) {
          receivers.splice(i, 1);
        }
        if (receivers.length === 0) {
          delete this._receivers[type];
        }
      }
      return this;
    };

    EventEmitter.prototype.emit = function(event) {
      var receiver, receivers, _fn, _i, _len,
        _this = this;

      receivers = this._receivers[event.type];
      if (receivers == null) {
        return this;
      }
      event.currentTarget = this;
      _fn = function(receiver) {
        return setTimeout(function() {
          if (event._isPropagationStoppedImmediately) {
            return;
          }
          return receiver.listener.call(_this, event);
        }, 0);
      };
      for (_i = 0, _len = receivers.length; _i < _len; _i++) {
        receiver = receivers[_i];
        _fn(receiver);
      }
      return this;
    };

    return EventEmitter;

  })();

  Point = (function() {
    Point.equals = function(pt0, pt1) {
      return pt0.x === pt1.x && pt0.y === pt1.y;
    };

    Point.dotProduct = function(pt0, pt1) {
      return pt0.x * pt1.x + pt0.y * pt1.y;
    };

    Point.angle = function(pt0, pt1) {
      return pt1.subtract(pt0).angle();
    };

    Point.distance = function(pt0, pt1) {
      return pt1.subtract(pt0).length();
    };

    Point.interpolate = function(pt0, pt1, ratio) {
      return pt0.add(pt1.subtract(pt0).multiply(ratio));
    };

    function Point(x, y) {
      this.x = x != null ? x : 0;
      this.y = y != null ? y : 0;
    }

    Point.prototype.angle = function(value) {
      var length;

      if (value == null) {
        return Math.atan2(this.y, this.x);
      }
      length = this.length();
      this.x = length * Math.cos(value);
      return this.y = length * Math.sin(value);
    };

    Point.prototype.length = function(value) {
      var angle;

      if (value == null) {
        return Math.sqrt(this.x * this.x + this.y * this.y);
      }
      angle = this.angle();
      this.x = value * Math.cos(angle);
      return this.y = value * Math.sin(angle);
    };

    Point.prototype.clone = function() {
      return new Point(this.x, this.y);
    };

    Point.prototype.add = function(pt) {
      return new Point(this.x + pt.x, this.y + pt.y);
    };

    Point.prototype.subtract = function(pt) {
      return new Point(this.x - pt.x, this.y - pt.y);
    };

    Point.prototype.multiply = function(value) {
      return new Point(this.x * value, this.y * value);
    };

    Point.prototype.divide = function(value) {
      return new Point(this.x / value, this.y / value);
    };

    return Point;

  })();

  Rectangle = (function() {
    function Rectangle(x, y, width, height) {
      this.x = x != null ? x : 0;
      this.y = y != null ? y : 0;
      this.width = width != null ? width : 0;
      this.height = height != null ? height : 0;
    }

    return Rectangle;

  })();

  path = (function() {
    function path() {}

    path.join = function() {
      var last, normalized, pathes, _i, _len;

      pathes = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      pathes = pathes.join('/').replace(/\/{2,}/g, '/').split('/');
      normalized = [];
      for (_i = 0, _len = pathes.length; _i < _len; _i++) {
        path = pathes[_i];
        switch (path) {
          case '.':
            break;
          case '..':
            last = normalized[normalized.length - 1];
            if ((last != null) && last !== '..') {
              normalized.pop();
            } else {
              normalized.push(path);
            }
            break;
          default:
            normalized.push(path);
            break;
        }
      }
      return normalized.join('/');
    };

    return path;

  })();

  NumberUtil = (function() {
    function NumberUtil() {}

    NumberUtil.RADIAN_PER_DEGREE = Math.PI / 180;

    NumberUtil.DEGREE_PER_RADIAN = 180 / Math.PI;

    NumberUtil.KB = 1024;

    NumberUtil.MB = NumberUtil.KB * NumberUtil.KB;

    NumberUtil.GB = NumberUtil.MB * NumberUtil.KB;

    NumberUtil.TB = NumberUtil.GB * NumberUtil.KB;

    NumberUtil.degree = function(radian) {
      return radian * this.DEGREE_PER_RADIAN;
    };

    NumberUtil.radian = function(degree) {
      return degree * this.RADIAN_PER_DEGREE;
    };

    NumberUtil.signify = function(value, digit) {
      var base;

      base = Math.pow(10, digit);
      return (value * base >> 0) / base;
    };

    NumberUtil.kb = function(bytes) {
      return bytes / this.KB;
    };

    NumberUtil.mb = function(bytes) {
      return bytes / this.MB;
    };

    NumberUtil.random = function(a, b) {
      return a + (b - a) * Math.random();
    };

    return NumberUtil;

  })();

  Button = (function(_super) {
    __extends(Button, _super);

    Button.FULL = {
      out: '_out',
      over: '_over',
      down: '_down',
      disabled: '_disabled'
    };

    Button.DEFAULT = {
      out: '_out',
      over: '_over'
    };

    Button.TOUCH = {
      out: '_out',
      disabled: '_disabled'
    };

    Button.defaultPostfixes = {
      out: '_out',
      over: '_over'
    };

    function Button($elem, postfixes, recursive) {
      var $img, $imgs, i, img, key, nameParts, postfix, src, unloadedPostfixes, _i, _j, _len, _len1, _ref, _ref1;

      this.$elem = $elem;
      this.postfixes = postfixes;
      this.recursive = recursive != null ? recursive : false;
      this._onClick = __bind(this._onClick, this);
      this._onMouseUp = __bind(this._onMouseUp, this);
      this._onMouseDown = __bind(this._onMouseDown, this);
      this._onMouseOver = __bind(this._onMouseOver, this);
      this._onMouseOut = __bind(this._onMouseOut, this);
      Button.__super__.constructor.call(this);
      if (!(((_ref = this.$elem) != null ? _ref.length : void 0) > 0)) {
        throw new TypeError('element isn\'t exist');
      }
      if (this.postfixes == null) {
        this.postfixes = Button.defaultPostfixes;
      }
      if (this.$elem[0].nodeName === 'IMG') {
        $imgs = this.$elem;
      } else if (this.recursive) {
        $imgs = this.$elem.find('img');
      } else {
        $imgs = this.$elem.children('img');
      }
      this._namePartsRegistry = {};
      this._imgs = [];
      postfixes = [];
      _ref1 = this.postfixes;
      for (key in _ref1) {
        postfix = _ref1[key];
        postfixes.push(postfix);
      }
      for (_i = 0, _len = $imgs.length; _i < _len; _i++) {
        img = $imgs[_i];
        $img = $(img);
        src = $img.attr('src');
        if (src == null) {
          continue;
        }
        for (i = _j = 0, _len1 = postfixes.length; _j < _len1; i = ++_j) {
          postfix = postfixes[i];
          if (postfix == null) {
            continue;
          }
          nameParts = src.match(RegExp("^(.*)" + postfix + "(\\.\\w+)$"));
          if ((nameParts != null ? nameParts.length : void 0) !== 3) {
            continue;
          }
          this._namePartsRegistry[img] = nameParts;
          unloadedPostfixes = postfixes.slice();
          unloadedPostfixes.splice(i, 1);
          this._preload(nameParts, unloadedPostfixes);
          this._imgs.push($img);
          break;
        }
      }
      this.$elem.on('click', this._onClick).on('mouseleave', this._onMouseOut).on('mouseenter', this._onMouseOver).on('mousedown', this._onMouseDown).on('mouseup', this._onMouseUp);
      this.enabled(true);
    }

    Button.prototype.destruct = function() {
      this.$elem.off('click', this._onClick).off('mouseleave', this._onMouseOut).off('mouseenter', this._onMouseOver).off('mousedown', this._onMouseDown).off('mouseup', this._onMouseUp);
      delete this.$elem;
      delete this.postfixes;
      delete this.recursive;
      delete this._enabled;
      delete this._status;
      delete this._isMouseOver;
      delete this._namePartsRegistry;
      return delete this._imgs;
    };

    Button.prototype.enabled = function(value) {
      if (value == null) {
        return this._enabled;
      }
      if (this._enabled === value) {
        return this;
      }
      if (value) {
        this._enabled = value;
        this.$elem.css('cursor', 'pointer');
        this._onMouseUp();
      } else {
        this.$elem.css('cursor', 'default');
        this._onMouseOut();
        this.status('disabled');
        this._enabled = value;
      }
      return this;
    };

    Button.prototype.status = function(value) {
      var $img, nameParts, postfix, src, vml, _i, _len, _ref, _results;

      if (value == null) {
        return this._status;
      }
      if (this._status === value) {
        return this;
      }
      postfix = this.postfixes[value];
      if (postfix == null) {
        return this;
      }
      this._status = value;
      _ref = this._imgs;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        $img = _ref[_i];
        nameParts = this._namePartsRegistry[$img[0]];
        src = nameParts[1] + postfix + nameParts[2];
        vml = $img[0].vml;
        if (vml) {
          vml.image.fill.setAttribute('src', src);
          continue;
        }
        _results.push($img.attr('src', src));
      }
      return _results;
    };

    Button.prototype._preload = function(nameParts, postfixes) {
      var postfix, _i, _len, _results;

      _results = [];
      for (_i = 0, _len = postfixes.length; _i < _len; _i++) {
        postfix = postfixes[_i];
        if (postfix == null) {
          continue;
        }
        _results.push($('<img>').attr('src', nameParts[1] + postfix + nameParts[2]));
      }
      return _results;
    };

    Button.prototype._onMouseOut = function(e) {
      this._isMouseOver = false;
      if (!this._enabled) {
        return;
      }
      this.status('out');
      if (e) {
        return this.emit(e);
      }
    };

    Button.prototype._onMouseOver = function(e) {
      this._isMouseOver = true;
      if (!this._enabled) {
        return;
      }
      this.status('over');
      if (e) {
        return this.emit(e);
      }
    };

    Button.prototype._onMouseDown = function(e) {
      if (!this._enabled) {
        return;
      }
      this.status('down');
      if (e) {
        return this.emit(e);
      }
    };

    Button.prototype._onMouseUp = function(e) {
      if (!this._enabled) {
        return;
      }
      this.status(this._isMouseOver ? 'over' : 'out');
      if (e) {
        return this.emit(e);
      }
    };

    Button.prototype._onClick = function(e) {
      if (!this._enabled) {
        return;
      }
      if (e) {
        return this.emit(e);
      }
    };

    return Button;

  })(EventEmitter);

  _ref = {
    "sc": {
      "ript": {
        "deferred": {
          "DLoader": DLoader
        },
        "display": {
          "Bitmap": Bitmap
        },
        "events": {
          "Event": Event,
          "EventEmitter": EventEmitter
        },
        "geom": {
          "Point": Point,
          "Rectangle": Rectangle
        },
        "path": path,
        "utils": {
          "NumberUtil": NumberUtil
        },
        "ui": {
          "Button": Button
        }
      }
    }
  };
  for (k in _ref) {
    v = _ref[k];
    window[k] = v;
  }

}).call(this);

/*
//@ sourceMappingURL=sc.ript-0.0.1.map
*/