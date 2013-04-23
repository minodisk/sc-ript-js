(function() {
  var Bitmap, Button, ByteArray, CapsStyle, Color, DLoader, Event, EventEmitter, GraphicsPathCommand, JointStyle, NumberUtil, Point, Rectangle, Type, k, path, v, _ref,
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

  GraphicsPathCommand = (function() {
    function GraphicsPathCommand() {}

    GraphicsPathCommand.NO_OP = 0;

    GraphicsPathCommand.MOVE_TO = 1;

    GraphicsPathCommand.LINE_TO = 2;

    GraphicsPathCommand.CURVE_TO = 3;

    GraphicsPathCommand.WIDE_MOVE_TO = 4;

    GraphicsPathCommand.WIDE_LINE_TO = 5;

    GraphicsPathCommand.CUBIC_CURVE_TO = 6;

    return GraphicsPathCommand;

  })();

  JointStyle = (function() {
    function JointStyle() {}

    JointStyle.BEVEL = 'bevel';

    JointStyle.MITER = 'miter';

    JointStyle.ROUND = 'round';

    return JointStyle;

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

  CapsStyle = (function() {
    function CapsStyle() {}

    CapsStyle.NONE = 'butt';

    CapsStyle.BUTT = 'butt';

    CapsStyle.ROUND = 'round';

    CapsStyle.SQUARE = 'square';

    return CapsStyle;

  })();

  Rectangle = (function() {
    function Rectangle(x, y, width, height) {
      this.x = x != null ? x : 0;
      this.y = y != null ? y : 0;
      this.width = width != null ? width : 0;
      this.height = height != null ? height : 0;
    }

    Rectangle.prototype.toString = function() {
      return "[Rectangle x=" + this.x + " y=" + this.y + " width=" + this.width + " height=" + this.height + "]";
    };

    Rectangle.prototype.clone = function() {
      return new Rectangle(this.x, this.y, this.width, this.height);
    };

    Rectangle.prototype.apply = function(rect) {
      this.x = rect.x;
      this.y = rect.y;
      this.width = rect.width;
      this.height = rect.height;
      return this;
    };

    Rectangle.prototype.contains = function(x, y) {
      return (this.x < x && x < this.x + this.width) && (this.y < y && y < this.y + this.height);
    };

    Rectangle.prototype.containsPoint = function(point) {
      var _ref, _ref1;

      return (this.x < (_ref = point.x) && _ref < this.x + this.width) && (this.y < (_ref1 = point.y) && _ref1 < this.y + this.height);
    };

    Rectangle.prototype.contain = function(x, y) {
      if (x < this.x) {
        this.width += this.x - x;
        this.x = x;
      } else if (x > this.x + this.width) {
        this.width = x - this.x;
      }
      if (y < this.y) {
        this.height += this.y - y;
        this.y = y;
      } else if (y > this.y + this.height) {
        this.height = y - this.y;
      }
      return this;
    };

    Rectangle.prototype.offset = function(dx, dy) {
      this.x += dx;
      this.y += dy;
      return this;
    };

    Rectangle.prototype.offsetPoint = function(pt) {
      this.x += pt.x;
      this.y += pt.y;
      return this;
    };

    Rectangle.prototype.inflate = function(dw, dh) {
      this.width += dw;
      this.height += dh;
      return this;
    };

    Rectangle.prototype.inflatePoint = function(pt) {
      this.width += pt.x;
      this.height += pt.y;
      return this;
    };

    Rectangle.prototype.deflate = function(dw, dh) {
      this.width -= dw;
      this.height -= dh;
      return this;
    };

    Rectangle.prototype.deflatePoint = function(pt) {
      this.width -= pt.x;
      this.height -= pt.y;
      return this;
    };

    Rectangle.prototype.union = function(rect) {
      var b, b1, b2, h, l, r, r1, r2, t, w;

      l = this.x < rect.x ? this.x : rect.x;
      r1 = this.x + this.width;
      r2 = rect.x + rect.width;
      r = r1 > r2 ? r1 : r2;
      w = r - l;
      t = this.y < rect.y ? this.y : rect.y;
      b1 = this.y + this.height;
      b2 = rect.y + rect.height;
      b = b1 > b2 ? b1 : b2;
      h = b - t;
      this.x = l;
      this.y = t;
      this.width = w < 0 ? 0 : w;
      this.height = h < 0 ? 0 : h;
      return this;
    };

    Rectangle.prototype.isEmpty = function() {
      return this.x === 0 && this.y === 0 && this.width === 0 && this.height === 0;
    };

    Rectangle.prototype.intersects = function(rect) {
      var b, h, l, r, t, w;

      l = _max(this.x, rect.x);
      r = _min(this.x + this.width, rect.x + rect.width);
      w = r - l;
      if (w <= 0) {
        return false;
      }
      t = _max(this.y, rect.y);
      b = _min(this.y + this.height, rect.y + rect.height);
      h = b - t;
      if (h <= 0) {
        return false;
      }
      return true;
    };

    Rectangle.prototype.intersection = function(rect) {
      var b, h, l, r, t, w;

      l = _max(this.x, rect.x);
      r = _min(this.x + this.width, rect.x + rect.width);
      w = r - l;
      if (w <= 0) {
        return new Rectangle();
      }
      t = _max(this.y, rect.y);
      b = _min(this.y + this.height, rect.y + rect.height);
      h = b - t;
      if (h <= 0) {
        return new Rectangle();
      }
      return new Rectangle(l, t, w, h);
    };

    Rectangle.prototype.measureFarDistance = function(x, y) {
      var b, db, dl, dr, dt, l, min, r, t;

      l = this.x;
      r = this.x + this.width;
      t = this.y;
      b = this.y + this.height;
      dl = x - l;
      dr = x - r;
      dt = y - t;
      db = y - b;
      dl = dl * dl;
      dr = dr * dr;
      dt = dt * dt;
      db = db * db;
      min = _max(dl + dt, dr + dt, dr + db, dl + db);
      return _sqrt(min);
    };

    Rectangle.prototype.adjustOuter = function() {
      var x, y;

      x = Math.floor(this.x);
      y = Math.floor(this.y);
      if (x !== this.x) {
        this.width++;
      }
      if (y !== this.y) {
        this.height++;
      }
      this.x = x;
      this.y = y;
      this.width = Math.ceil(this.width);
      this.height = Math.ceil(this.height);
      return this;
    };

    Rectangle.prototype.transform = function(matrix) {
      var b, l, lb, lt, r, rb, rt, t;

      lt = new Matrix(1, 0, 0, 1, this.x, this.y);
      rt = new Matrix(1, 0, 0, 1, this.x + this.width, this.y);
      rb = new Matrix(1, 0, 0, 1, this.x + this.width, this.y + this.height);
      lb = new Matrix(1, 0, 0, 1, this.x, this.y + this.height);
      lt.concat(matrix);
      rt.concat(matrix);
      rb.concat(matrix);
      lb.concat(matrix);
      l = _min(lt.ox, rt.ox, rb.ox, lb.ox);
      r = _max(lt.ox, rt.ox, rb.ox, lb.ox);
      t = _min(lt.oy, rt.oy, rb.oy, lb.oy);
      b = _max(lt.oy, rt.oy, rb.oy, lb.oy);
      this.x = l;
      this.y = t;
      this.width = r - l;
      this.height = b - t;
      return this;
    };

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

    NumberUtil.gb = function(bytes) {
      return bytes / this.GB;
    };

    NumberUtil.random = function(a, b) {
      return a + (b - a) * Math.random();
    };

    return NumberUtil;

  })();

  ByteArray = (function() {
    ByteArray.BlobBuilder = window.BlobBuilder || window.WebKitBlobBuilder || window.MozBlobBuilder;

    ByteArray.fromDataURL = function(dataURL) {
      var ab, bb, byteString, i, ia, mimeString, _i, _ref;

      mimeString = dataURL.split(',')[0].split(':')[1].split(';')[0];
      byteString = atob(dataURL.split(',')[1]);
      ab = new ArrayBuffer(byteString.length);
      ia = new Uint8Array(ab);
      for (i = _i = 0, _ref = byteString.length; _i < _ref; i = _i += 1) {
        ia[i] = byteString.charCodeAt(i);
      }
      if (this.BlobBuilder != null) {
        bb = new ByteArray.BlobBuilder;
        bb.append(ab);
        return new ByteArray(bb.getBlob(mimeString));
      } else {
        return new ByteArray(new Blob([ab], {
          type: mimeString
        }));
      }
    };

    function ByteArray(data) {
      this.data = data;
    }

    ByteArray.prototype.length = function() {
      return this.data.size;
    };

    return ByteArray;

  })();

  Color = (function() {
    function Color() {}

    Color.toCSSString = function(color, alpha) {
      var b, g, r;

      if (alpha == null) {
        alpha = 1;
      }
      r = color >> 16 & 0xff;
      g = color >> 8 & 0xff;
      b = color & 0xff;
      alpha = alpha < 0 ? 0 : alpha > 1 ? 1 : alpha;
      if (alpha === 1) {
        return "rgb(" + r + "," + g + "," + b + ")";
      } else {
        return "rgba(" + r + "," + g + "," + b + "," + alpha + ")";
      }
    };

    return Color;

  })();

  Bitmap = (function() {
    Bitmap._PI_2 = Math.PI * 2;

    Bitmap._PI_OVER_2 = Math.PI / 2;

    Bitmap._ELLIPSE_CUBIC_BEZIER_HANDLE = (Math.SQRT2 - 1) * 4 / 3;

    function Bitmap(canvas) {
      if (canvas == null) {
        canvas = document.createElement('canvas');
      }
      this.canvas = canvas;
      this._context = this.canvas.getContext('2d');
      this._context.fillStyle = this._context.strokeStyle = 'rgba(0,0,0,0)';
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
      this.canvas.width = this.canvas.width;
      return this._context.fillStyle = this._context.strokeStyle = 'rgba(0,0,0,0)';
    };

    Bitmap.prototype.draw = function(image, matrix) {
      if (matrix != null) {
        this._context.setTransform(matrix.m11, matrix.m12, matrix.m21, matrix.m22, matrix.tx, matrix.ty);
      }
      return this._context.drawImage(image, 0, 0);
    };

    Bitmap.prototype.encodeAsPNG = function() {
      return ByteArray.fromDataURL(this.canvas.toDataURL('image/png'));
    };

    Bitmap.prototype.encodeAsJPG = function(quality) {
      if (quality == null) {
        quality = 0.8;
      }
      return ByteArray.fromDataURL(this.canvas.toDataURL('image/jpeg', quality));
    };

    Bitmap.prototype.lineStyle = function(thickness, color, alpha, capsStyle, jointStyle, miterLimit) {
      if (thickness == null) {
        thickness = 1;
      }
      if (color == null) {
        color = 0;
      }
      if (alpha == null) {
        alpha = 1;
      }
      if (capsStyle == null) {
        capsStyle = CapsStyle.NONE;
      }
      if (jointStyle == null) {
        jointStyle = JointStyle.BEVEL;
      }
      if (miterLimit == null) {
        miterLimit = 10;
      }
      this._context.lineWidth = thickness;
      this._context.strokeStyle = Color.toCSSString(color, alpha);
      this._context.lineCaps = capsStyle;
      this._context.lineJoin = jointStyle;
      this._context.miterLimit = miterLimit;
      return console.log('lineStyle:', this._context.strokeStyle);
    };

    Bitmap.prototype.beginFill = function(color, alpha) {
      if (color == null) {
        color = 0;
      }
      if (alpha == null) {
        alpha = 1;
      }
      this._context.fillStyle = Color.toCSSString(color, alpha);
      return console.log('fillStyle:', this._context.fillStyle);
    };

    Bitmap.prototype.moveTo = function(x, y) {
      return this._context.moveTo(x, y);
    };

    Bitmap.prototype.lineTo = function(x, y) {
      return this._context.lineTo(x, y);
    };

    Bitmap.prototype.drawRect = function(x, y, width, height) {
      return this._context.rect(x, y, width, height);
    };

    Bitmap.prototype.drawCircle = function(x, y, radius, clockwise) {
      this._context.moveTo(x + radius, y);
      return this._context.arc(x, y, radius, 0, Bitmap._PI_2, clockwise < 0);
    };

    Bitmap.prototype.drawEllipse = function(x, y, width, height, clockwise) {
      var handleHeight, handleWidth;

      if (clockwise == null) {
        clockwise = 0;
      }
      width /= 2;
      height /= 2;
      x += width;
      y += height;
      handleWidth = width * Bitmap._ELLIPSE_CUBIC_BEZIER_HANDLE;
      handleHeight = height * Bitmap._ELLIPSE_CUBIC_BEZIER_HANDLE;
      return this.drawPath([0, 3, 3, 3, 3], [x + width, y, x + width, y + handleHeight, x + handleWidth, y + height, x, y + height, x - handleWidth, y + height, x - width, y + handleHeight, x - width, y, x - width, y - handleHeight, x - handleWidth, y - height, x, y - height, x + handleWidth, y - height, x + width, y - handleHeight, x + width, y], clockwise);
    };

    Bitmap.prototype.curveTo = function(x1, y1, x2, y2) {
      return this._context.quadraticCurveTo(x1, y1, x2, y2);
    };

    Bitmap.prototype.cubicCurveTo = function(x1, y1, x2, y2, x3, y3) {
      return this._context.bezierCurveTo(x1, y1, x2, y2, x3, y3);
    };

    Bitmap.prototype.drawPath = function(commands, data, clockwise) {
      var c, command, d, i, j, rect, _i, _j, _k, _len, _len1, _ref;

      if (clockwise == null) {
        clockwise = 0;
      }
      rect = new Rectangle(data[0], data[1], 0, 0);
      for (i = _i = 1, _ref = data.length / 2; _i < _ref; i = _i += 1) {
        j = i * 2;
        rect.contain(data[j], data[j + 1]);
      }
      if (clockwise < 0) {
        d = [];
        i = 0;
        for (_j = 0, _len = commands.length; _j < _len; _j++) {
          command = commands[_j];
          switch (command) {
            case 0:
            case 1:
              d.unshift(data[i++], data[i++]);
              break;
            case 2:
              i += 4;
              d.unshift(data[i - 2], data[i - 1], data[i - 4], data[i - 3]);
              break;
            case 3:
              i += 6;
              d.unshift(data[i - 2], data[i - 1], data[i - 4], data[i - 3], data[i - 6], data[i - 5]);
          }
        }
        data = d;
        commands = commands.slice();
        c = commands.shift();
        commands.reverse();
        commands.unshift(c);
      }
      i = 0;
      for (_k = 0, _len1 = commands.length; _k < _len1; _k++) {
        command = commands[_k];
        switch (command) {
          case GraphicsPathCommand.MOVE_TO:
            this._context.moveTo(data[i++], data[i++]);
            console.log('moveTo:', data[i - 2], data[i - 1]);
            break;
          case GraphicsPathCommand.LINE_TO:
            this._context.lineTo(data[i++], data[i++]);
            console.log('lineTo:', data[i - 2], data[i - 1]);
            break;
          case GraphicsPathCommand.CURVE_TO:
            this._context.quadraticCurveTo(data[i++], data[i++], data[i++], data[i++]);
            break;
          case GraphicsPathCommand.CUBIC_CURVE_TO:
            this._context.bezierCurveTo(data[i++], data[i++], data[i++], data[i++], data[i++], data[i++]);
        }
      }
      if (data[0] === data[data.length - 2] && data[1] === data[data.length - 1]) {
        this._context.closePath();
      }
      this._context.fill();
      return this._context.stroke();
    };

    Bitmap.prototype.drawRoundRect = function(x, y, width, height, ellipseW, ellipseH, clockwise) {
      if (ellipseH == null) {
        ellipseH = ellipseW;
      }
      if (clockwise == null) {
        clockwise = 0;
      }
      return this.drawPath([0, 1, 2, 1, 2, 1, 2, 1, 2], [x + ellipseW, y, x + width - ellipseW, y, x + width, y, x + width, y + ellipseH, x + width, y + height - ellipseH, x + width, y + height, x + width - ellipseW, y + height, x + ellipseW, y + height, x, y + height, x, y + height - ellipseH, x, y + ellipseH, x, y, x + ellipseW, y], clockwise);
    };

    Bitmap.prototype.drawRegularPolygon = function(x, y, radius, length, clockwise) {
      var commands, data, i, rotation, unitRotation, _i;

      if (length == null) {
        length = 3;
      }
      if (clockwise == null) {
        clockwise = 0;
      }
      commands = [];
      data = [];
      unitRotation = Bitmap._PI_2 / length;
      for (i = _i = 0; 0 <= length ? _i <= length : _i >= length; i = 0 <= length ? ++_i : --_i) {
        commands.push(i === 0 ? 0 : 1);
        rotation = -Bitmap._PI_OVER_2 + unitRotation * i;
        data.push(x + radius * Math.cos(rotation), y + radius * Math.sin(rotation));
      }
      return this.drawPath(commands, data, clockwise);
    };

    Bitmap.prototype.drawRegularStar = function(x, y, outer, length, clockwise) {
      var cos;

      if (length == null) {
        length = 5;
      }
      if (clockwise == null) {
        clockwise = 0;
      }
      cos = Math.cos(Math.PI / length);
      return this.drawStar(x, y, outer, outer * (2 * cos - 1 / cos), length, clockwise);
    };

    Bitmap.prototype.drawStar = function(x, y, outer, inner, length, clockwise) {
      var commands, data, i, radius, rotation, unitRotation, _i, _ref;

      if (length == null) {
        length = 5;
      }
      if (clockwise == null) {
        clockwise = 0;
      }
      commands = [];
      data = [];
      unitRotation = Math.PI / length;
      for (i = _i = 0, _ref = length * 2; _i <= _ref; i = _i += 1) {
        commands.push(i === 0 ? 0 : 1);
        radius = (i & 1) === 0 ? outer : inner;
        rotation = -Bitmap._PI_OVER_2 + unitRotation * i;
        data.push(x + radius * Math.cos(rotation), y + radius * Math.sin(rotation));
      }
      return this.drawPath(commands, data, clockwise);
    };

    return Bitmap;

  })();

  Type = (function() {
    function Type() {}

    Type.toString = Object.prototype.toString;

    Type.hasOwnProperty = Object.prototype.hasOwnProperty;

    Type.isElement = function(value) {
      return (value != null ? value.nodeType : void 0) === 1;
    };

    Type.isArray = Array.isArray || function(value) {
      return this.toString.call(value) === '[object Array]';
    };

    Type.isArguments = (function() {
      var isArguments;

      isArguments = function(value) {
        return this.toString.call(value) === "[object Arguments]";
      };
      if (isArguments(arguments)) {
        return isArguments;
      } else {
        return function(value) {
          return (value != null) && this.hasOwnProperty.call(value, 'callee');
        };
      }
    })();

    Type.isFunction = (function() {
      if (typeof /./ === 'function') {
        return function(value) {
          return this.toString.call(value) === "[object Function]";
        };
      } else {
        return function(value) {
          return typeob(value === 'function');
        };
      }
    })();

    Type.isString = function(value) {
      return this.toString.call(value) === "[object String]";
    };

    Type.isNumber = function(value) {
      return this.toString.call(value) === "[object Number]";
    };

    Type.isDate = function(value) {
      return this.toString.call(value) === "[object Date]";
    };

    Type.isRegExp = function(value) {
      return this.toString.call(value) === "[object RegExp]";
    };

    Type.isFinite = function(value) {
      return isFinite(value) && !isNaN(parseFloat(value));
    };

    Type.isNaN = function(value) {
      return this.isNumber(value) && value !== +value;
    };

    Type.isBoolean = function(value) {
      return value === true || value === false || this.toString.call(value) === "[object Boolean]";
    };

    Type.isNull = function(value) {
      return value === null;
    };

    Type.isUndefined = function(value) {
      return value != null;
    };

    Type.isObject = function(value) {
      return value === Object(value);
    };

    return Type;

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
          "GraphicsPathCommand": GraphicsPathCommand,
          "JointStyle": JointStyle,
          "CapsStyle": CapsStyle,
          "Bitmap": Bitmap
        },
        "events": {
          "Event": Event,
          "EventEmitter": EventEmitter
        },
        "geom": {
          "Rectangle": Rectangle,
          "Point": Point
        },
        "path": path,
        "utils": {
          "NumberUtil": NumberUtil,
          "ByteArray": ByteArray,
          "Color": Color,
          "Type": Type
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