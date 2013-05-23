(function() {
  var sc,
    __slice = [].slice,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  sc = {
    "ript": {
      "color": {},
      "deferred": {},
      "display": {},
      "event": {},
      "filter": {},
      "geom": {},
      "serializer": {},
      "util": {}
    }
  };

  if (typeof window !== "undefined" && window !== null) {
    window.sc = sc;
  }

  if (typeof module !== "undefined" && module !== null) {
    module.exports = sc;
  }

  sc.ript.color.Color = (function() {
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

    Color.average = function() {
      var colors, rgb, rgbs;

      colors = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      rgbs = (function() {
        var color, _i, _len, _results;

        _results = [];
        for (_i = 0, _len = colors.length; _i < _len; _i++) {
          color = colors[_i];
          _results.push(new RGB(color));
        }
        return _results;
      })();
      rgb = RGB.average.apply(null, rgbs);
      return rgb.toHex();
    };

    return Color;

  })();

  sc.ript.color.HSV = (function() {
    function HSV(h, s, v) {
      var b, c, g, hex, r, rgb, x, y;

      this.h = h;
      this.s = s;
      this.v = v;
      if (arguments.length === 1) {
        hex = h;
        rgb = new RGB(hex);
        r = rgb.r / 255;
        g = rgb.g / 255;
        b = rgb.b / 255;
        h = s = v = 0;
        if (r >= g) {
          x = r;
        } else {
          x = g;
        }
        if (b > x) {
          x = b;
        }
        if (r <= g) {
          y = r;
        } else {
          y = g;
        }
        if (b < y) {
          y = b;
        }
        v = x;
        c = x - y;
        if (x === 0) {
          s = 0;
        } else {
          s = c / x;
        }
        if (s !== 0) {
          if (r === x) {
            h = (g - b) / c;
          } else {
            if (g === x) {
              h = 2 + (b - r) / c;
            } else {
              if (b === x) {
                h = 4 + (r - g) / c;
              }
            }
          }
          h = h * 60;
          if (h < 0) {
            h = h + 360;
          }
        }
        this.h = h;
        this.s = s;
        this.v = v;
      }
      this.normalize();
    }

    HSV.prototype.normalize = function() {
      this.s = this.s < 0 ? 0 : this.s > 1 ? 1 : this.s;
      this.v = this.v < 0 ? 0 : this.v > 1 ? 1 : this.v;
      this.h = this.h % 360;
      if (this.h < 0) {
        return this.h += 360;
      }
    };

    HSV.prototype.toRGB = function() {
      var h, i, s, v, x, y, z;

      this.normalize();
      h = this.h, s = this.s, v = this.v;
      h /= 60;
      i = h >> 0;
      x = v * (1 - s);
      y = v * (1 - s * (h - 1));
      z = v * (1 - s * (1 - h + i));
      x = x * 0xff >> 0;
      y = y * 0xff >> 0;
      z = z * 0xff >> 0;
      v = v * 0xff >> 0;
      switch (i) {
        case 0:
          return new RGB(v, z, x);
        case 1:
          return new RGB(y, v, x);
        case 2:
          return new RGB(x, v, z);
        case 3:
          return new RGB(x, y, v);
        case 4:
          return new RGB(z, x, v);
        case 5:
          return new RGB(v, x, y);
      }
    };

    HSV.prototype.toHex = function() {
      return this.toRGB().toHex();
    };

    return HSV;

  })();

  sc.ript.color.RGB = (function() {
    RGB.average = function() {
      var b, g, length, r, rgb, rgbs, _i, _len;

      rgbs = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      r = g = b = 0;
      for (_i = 0, _len = rgbs.length; _i < _len; _i++) {
        rgb = rgbs[_i];
        r += rgb.r;
        g += rgb.g;
        b += rgb.b;
      }
      length = rgbs.length;
      r /= length;
      g /= length;
      b /= length;
      return new RGB(r, g, b);
    };

    function RGB(r, g, b) {
      var hex;

      this.r = r;
      this.g = g;
      this.b = b;
      if (arguments.length === 1) {
        hex = r;
        this.r = hex >> 16 & 0xff;
        this.g = hex >> 8 & 0xff;
        this.b = hex & 0xff;
      }
      this.normalize();
    }

    RGB.prototype.normalize = function() {
      this.r &= 0xff;
      this.g &= 0xff;
      return this.b &= 0xff;
    };

    RGB.prototype.toHex = function() {
      return this.r << 16 | this.g << 8 | this.b;
    };

    return RGB;

  })();

  sc.ript.deferred.DLoader = (function() {
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

  sc.ript.display.Blend = (function() {
    function Blend() {}

    Blend._mix = function(a, b, f) {
      return a + (((b - a) * f) >> 8);
    };

    Blend._peg = function(n) {
      if (n < 0) {
        return 0;
      } else if (n > 255) {
        return 255;
      } else {
        return n;
      }
    };

    Blend.scan = function(method, src, dst) {
      var d, i, o, s, _i, _ref, _ref1;

      method = Blend[method];
      if (method == null) {
        throw new TypeError("" + method + " isn't defined.");
      }
      s = src.data;
      d = dst.data;
      for (i = _i = 0, _ref = d.length; _i < _ref; i = _i += 4) {
        o = method(d[i], d[i + 1], d[i + 2], d[i + 3], s[i], s[i + 1], s[i + 2], s[i + 3]);
        [].splice.apply(d, [i, (i + 3) - i + 1].concat(_ref1 = o.slice(0, 4))), _ref1;
      }
      return dst;
    };

    Blend.blend = function(dr, dg, db, da, sr, sg, sb, sa) {
      return [Blend._mix(dr, sr, sa), Blend._mix(dg, sg, sa), Blend._mix(db, sb, sa), da + sa];
    };

    Blend.add = function(dr, dg, db, da, sr, sg, sb, sa) {
      return [dr + (sr * sa >> 8), dg + (sg * sa >> 8), db + (sb * sa >> 8), da + sa];
    };

    Blend.subtract = function(dr, dg, db, da, sr, sg, sb, sa) {
      return [dr - (sr * sa >> 8), dg - (sg * sa >> 8), db - (sb * sa >> 8), da + sa];
    };

    Blend.darkest = function(dr, dg, db, da, sr, sg, sb, sa) {
      return [Blend._mix(dr, Math.min(dr, sr * sa >> 8), sa), Blend._mix(dg, Math.min(dg, sg * sa >> 8), sa), Blend._mix(db, Math.min(db, sb * sa >> 8), sa), da + sa];
    };

    Blend.lightest = function(dr, dg, db, da, sr, sg, sb, sa) {
      return [Math.max(dr, sr * sa >> 8), Math.max(dg, sg * sa >> 8), Math.max(db, sb * sa >> 8), da + sa];
    };

    Blend.difference = function(dr, dg, db, da, sr, sg, sb, sa) {
      return [Blend._mix(dr, (dr > sr ? dr - sr : sr - dr), sa), Blend._mix(dg, (dg > sg ? dg - sg : sg - dg), sa), Blend._mix(db, (db > sb ? db - sb : sb - db), sa), da + sa];
    };

    Blend.exclusion = function(dr, dg, db, da, sr, sg, sb, sa) {
      return [Blend._mix(dr, dr + sr - (dr * sr >> 7), sa), Blend._mix(dg, dg + sg - (dg * sg >> 7), sa), Blend._mix(db, db + sb - (db * sb >> 7), sa), da + sa];
    };

    Blend.reflex = function(dr, dg, db, da, sr, sg, sb, sa) {
      return [Blend._mix(dr, (sr === 0xff ? sr : dr * dr / (0xff - sr)), sa), Blend._mix(dg, (sg === 0xff ? sg : dg * dg / (0xff - sg)), sa), Blend._mix(db, (sb === 0xff ? sb : db * db / (0xff - sb)), sa), da + sa];
    };

    Blend.multiply = function(dr, dg, db, da, sr, sg, sb, sa) {
      return [Blend._mix(dr, dr * sr >> 8, sa), Blend._mix(dg, dg * sg >> 8, sa), Blend._mix(db, db * sb >> 8, sa), da + sa];
    };

    Blend.screen = function(dr, dg, db, da, sr, sg, sb, sa) {
      return [Blend._mix(dr, 0xff - ((0xff - dr) * (0xff - sr) >> 8), sa), Blend._mix(dg, 0xff - ((0xff - dg) * (0xff - sg) >> 8), sa), Blend._mix(db, 0xff - ((0xff - db) * (0xff - sb) >> 8), sa), da + sa];
    };

    Blend.overlay = function(dr, dg, db, da, sr, sg, sb, sa) {
      return [Blend._mix(dr, (dr < 0x80 ? dr * sr >> 7 : 0xff - ((0xff - dr) * (0xff - sr) >> 7)), sa), Blend._mix(dg, (dg < 0x80 ? dg * sg >> 7 : 0xff - ((0xff - dg) * (0xff - sg) >> 7)), sa), Blend._mix(db, (db < 0x80 ? db * sb >> 7 : 0xff - ((0xff - db) * (0xff - sb) >> 7)), sa), da + sa];
    };

    Blend.softLight = function(dr, dg, db, da, sr, sg, sb, sa) {
      return [Blend._mix(dr, (dr * sr >> 7) + (dr * dr >> 8) - (dr * dr * sr >> 15), sa), Blend._mix(dg, (dg * sg >> 7) + (dg * dg >> 8) - (dg * dg * sg >> 15), sa), Blend._mix(db, (db * sb >> 7) + (db * db >> 8) - (db * db * sb >> 15), sa), da + sa];
    };

    Blend.hardLight = function(dr, dg, db, da, sr, sg, sb, sa) {
      return [Blend._mix(dr, (sr < 0x80 ? dr * sr >> 7 : 0xff - (((0xff - dr) * (0xff - sr)) >> 7)), sa), Blend._mix(dg, (sg < 0x80 ? dg * sg >> 7 : 0xff - (((0xff - dg) * (0xff - sg)) >> 7)), sa), Blend._mix(db, (sb < 0x80 ? db * sb >> 7 : 0xff - (((0xff - db) * (0xff - sb)) >> 7)), sa), da + sa];
    };

    Blend.vividLight = function(dr, dg, db, da, sr, sg, sb, sa) {
      return [(sr === 0 ? 0 : sr === 0xff ? 0xff : sr < 0x80 ? 0xff - Blend._peg(((0xff - dr) << 8) / (sr * 2)) : Blend._peg((dr << 8) / ((0xff - sr) * 2))), (sg === 0 ? 0 : sg === 0xff ? 0xff : sg < 0x80 ? 0xff - Blend._peg(((0xff - dg) << 8) / (sg * 2)) : Blend._peg((dg << 8) / ((0xff - sg) * 2))), (sb === 0 ? 0 : sb === 0xff ? 0xff : sb < 0x80 ? 0xff - Blend._peg(((0xff - db) << 8) / (sb * 2)) : Blend._peg((db << 8) / ((0xff - sb) * 2))), da + sa];
    };

    Blend.linearLight = function(dr, dg, db, da, sr, sg, sb, sa) {
      return [(sr < 0x80 ? Math.max(sr * 2 + dr - 0xff, 0) : Math.min(sr + dr, 0xff)), (sg < 0x80 ? Math.max(sg * 2 + dg - 0xff, 0) : Math.min(sg + dg, 0xff)), (sb < 0x80 ? Math.max(sb * 2 + db - 0xff, 0) : Math.min(sb + db, 0xff)), da + sa];
    };

    Blend.pinLight = function(dr, dg, db, da, sr, sg, sb, sa) {
      return [(sr < 0x80 ? Math.min(sr * 2, dr) : Math.max((sr - 0x80) * 2, dr)), (sg < 0x80 ? Math.min(sg * 2, dg) : Math.max((sg - 0x80) * 2, dg)), (sb < 0x80 ? Math.min(sb * 2, db) : Math.max((sb - 0x80) * 2, db)), da + sa];
    };

    Blend.hardMix = function(dr, dg, db, da, sr, sg, sb, sa) {
      var b, g, r;

      r = (sr === 0 ? 0 : sr === 0xff ? 0xff : sr < 0x80 ? 0xff - Blend._peg(((0xff - dr) << 8) / (sr * 2)) : Blend._peg((dr << 8) / ((0xff - sr) * 2)));
      g = (sg === 0 ? 0 : sg === 0xff ? 0xff : sg < 0x80 ? 0xff - Blend._peg(((0xff - dg) << 8) / (sg * 2)) : Blend._peg((dg << 8) / ((0xff - sg) * 2)));
      b = (sb === 0 ? 0 : sb === 0xff ? 0xff : sb < 0x80 ? 0xff - Blend._peg(((0xff - db) << 8) / (sb * 2)) : Blend._peg((db << 8) / ((0xff - sb) * 2)));
      return [r < 0x80 ? 0 : 0xff, g < 0x80 ? 0 : 0xff, b < 0x80 ? 0 : 0xff, da + sa];
    };

    Blend.dodge = function(dr, dg, db, da, sr, sg, sb, sa) {
      return [Blend._mix(dr, Blend._peg((dr << 8) / (0xff - sr)), sa), Blend._mix(dg, Blend._peg((dg << 8) / (0xff - sg)), sa), Blend._mix(db, Blend._peg((db << 8) / (0xff - sb)), sa), da + sa];
    };

    Blend.burn = function(dr, dg, db, da, sr, sg, sb, sa) {
      return [Blend._mix(dr, (sr === 0 ? 0 : 0xff - Blend._peg(((0xff - dr) << 8) / sr)), sa), Blend._mix(dg, (sg === 0 ? 0 : 0xff - Blend._peg(((0xff - dg) << 8) / sg)), sa), Blend._mix(db, (sb === 0 ? 0 : 0xff - Blend._peg(((0xff - db) << 8) / sb)), sa), da + sa];
    };

    Blend.linearDodge = function(dr, dg, db, da, sr, sg, sb, sa) {
      return [Blend._mix(dr, Math.min(sr + dr, 0xff), sa), Blend._mix(dg, Math.min(dg + sg, 0xff), sa), Blend._mix(db, Math.min(db + sb, 0xff), sa), da + sa];
    };

    Blend.linearBurn = function(dr, dg, db, da, sr, sg, sb, sa) {
      return [Blend._mix(dr, Math.max(sr + dr - 0xff, 0), sa), Blend._mix(dg, Math.max(dg + sg - 0xff, 0), sa), Blend._mix(db, Math.max(db + sb - 0xff, 0), sa), da + sa];
    };

    Blend.punch = function(dr, dg, db, da, sr, sg, sb, sa) {
      return [dr, dg, db, da * Blend._peg(0xff - sa) / 0xff >> 0];
    };

    Blend.mask = function(dr, dg, db, da, sr, sg, sb, sa) {
      return [dr, dg, db, da * sa / 0xff >> 0];
    };

    return Blend;

  })();

  sc.ript.display.BlendMode = (function() {
    function BlendMode() {}

    BlendMode.NORMAL = 'normal';

    BlendMode.BLEND = 'blend';

    BlendMode.ADD = 'add';

    BlendMode.SUBTRACT = 'subtract';

    BlendMode.DARKEST = 'darkest';

    BlendMode.LIGHTEST = 'lightest';

    BlendMode.DIFFERENCE = 'difference';

    BlendMode.EXCLUSION = 'exclusion';

    BlendMode.MULTIPLY = 'multiply';

    BlendMode.SCREEN = 'screen';

    BlendMode.OVERLAY = 'overlay';

    BlendMode.SOFT_LIGHT = 'softLight';

    BlendMode.HARD_LIGHT = 'hardLight';

    BlendMode.VIVID_LIGHT = 'vividLight';

    BlendMode.LINEAR_LIGHT = 'linearLight';

    BlendMode.PIN_LIGHT = 'pinLight';

    BlendMode.HARD_MIX = 'hardMix';

    BlendMode.DODGE = 'dodge';

    BlendMode.BURN = 'burn';

    BlendMode.LINEAR_DODGE = 'linearDodge';

    BlendMode.LINEAR_BURN = 'linearBurn';

    BlendMode.PUNCH = 'punch';

    BlendMode.MASK = 'mask';

    return BlendMode;

  })();

  sc.ript.display.CapsStyle = (function() {
    function CapsStyle() {}

    CapsStyle.NONE = 'butt';

    CapsStyle.BUTT = 'butt';

    CapsStyle.ROUND = 'round';

    CapsStyle.SQUARE = 'square';

    return CapsStyle;

  })();

  sc.ript.display.DisplayObject = (function() {
    DisplayObject._RADIAN_PER_DEGREE = Math.PI / 180;

    function DisplayObject() {
      this.x = this.y = this.rotation = 0;
      this.scaleX = this.scaleY = 1;
      this.blendMode = BlendMode.NORMAL;
    }

    DisplayObject.prototype.matrix = function() {
      return new Matrix().scale(this.scaleX, this.scaleY).rotate(this.rotation * DisplayObject._RADIAN_PER_DEGREE).translate(this.x, this.y);
    };

    return DisplayObject;

  })();

  sc.ript.display.Bitmap = (function(_super) {
    __extends(Bitmap, _super);

    Bitmap._PI_2 = Math.PI * 2;

    Bitmap._PI_OVER_2 = Math.PI / 2;

    Bitmap._ELLIPSE_CUBIC_BEZIER_HANDLE = (Math.SQRT2 - 1) * 4 / 3;

    function Bitmap(width, height, color, alpha) {
      var canvas, source;

      if (width == null) {
        width = 320;
      }
      if (height == null) {
        height = 320;
      }
      if (color == null) {
        color = 0;
      }
      if (alpha == null) {
        alpha = 0;
      }
      Bitmap.__super__.constructor.call(this);
      if (width instanceof Bitmap) {
        source = width;
        width = source.width();
        height = source.height();
      } else {
        switch (width.nodeName) {
          case 'CANVAS':
            canvas = width;
            width = canvas.width;
            height = canvas.height;
            break;
          case 'IMG':
            source = width;
            width = source.width;
            height = source.height;
        }
      }
      width = +width;
      height = +height;
      if (width === 0 || height === 0) {
        throw new TypeError('Can\'t construct with 0 size');
      }
      if (canvas != null) {
        this.canvas = canvas;
      } else {
        this.canvas = document.createElement('canvas');
        this.width(width);
        this.height(height);
      }
      this._context = this.canvas.getContext('2d');
      this._context.strokeStyle = 'rgba(0,0,0,0)';
      if (alpha !== 0) {
        this.beginFill(color, alpha);
        this.drawRect(0, 0, width, height);
        this.endFill();
      }
      if (source != null) {
        this.draw(source);
      }
    }

    Bitmap.prototype.clone = function() {
      var bitmap;

      bitmap = new Bitmap(this.width(), this.height());
      bitmap.draw(this);
      return bitmap;
    };

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

    Bitmap.prototype.encodeAsPNG = function() {
      return ByteArray.fromDataURL(this.encodeAsBase64PNG());
    };

    Bitmap.prototype.encodeAsJPG = function(quality) {
      if (quality == null) {
        quality = 0.8;
      }
      return ByteArray.fromDataURL(this.encodeAsBase64JPG(quality));
    };

    Bitmap.prototype.encodeAsBase64PNG = function(onlyData) {
      var data;

      if (onlyData == null) {
        onlyData = false;
      }
      data = this.canvas.toDataURL('image/png');
      if (onlyData) {
        return data.split(',')[1];
      } else {
        return data;
      }
    };

    Bitmap.prototype.encodeAsBase64JPG = function(quality, onlyData) {
      var data;

      if (quality == null) {
        quality = 0.8;
      }
      if (onlyData == null) {
        onlyData = false;
      }
      data = this.canvas.toDataURL('image/jpeg', quality);
      if (onlyData) {
        return data.split(',')[1];
      } else {
        return data;
      }
    };

    Bitmap.prototype.clear = function() {
      this.canvas.width = this.canvas.width;
      return this._context.fillStyle = this._context.strokeStyle = 'rgba(0,0,0,0)';
    };

    Bitmap.prototype.draw = function(image, matrix) {
      var dst, src;

      if (image instanceof Bitmap) {
        if (image.blendMode !== BlendMode.NORMAL) {
          src = image.getPixels();
          dst = this.getPixels();
          dst = Blend.scan(image.blendMode, src, dst);
        }
        image = image.canvas;
      }
      if (matrix != null) {
        this._context.setTransform(matrix.m11, matrix.m12, matrix.m21, matrix.m22, matrix.tx, matrix.ty);
      }
      if (dst != null) {
        this._context.putImageData(dst, 0, 0);
      } else {
        this._context.drawImage(image, 0, 0);
      }
      return this._context.setTransform(1, 0, 0, 1, 0, 0);
    };

    Bitmap.prototype.getPixels = function(rect) {
      if (rect == null) {
        rect = new Rectangle(0, 0, this.width(), this.height());
      }
      return this._context.getImageData(rect.x, rect.y, rect.width, rect.height);
    };

    Bitmap.prototype.setPixels = function(imageData) {
      return this._context.putImageData(imageData, 0, 0);
    };

    Bitmap.prototype.getPixel32 = function(x, y) {
      var a, b, g, r, _ref;

      _ref = this._context.getImageData(x, y, 1, 1).data, r = _ref[0], g = _ref[1], b = _ref[2], a = _ref[3];
      return a << 24 | r << 16 | g << 8 | b;
    };

    Bitmap.prototype.getPixel = function(x, y) {
      var b, g, r, _ref;

      _ref = this._context.getImageData(x, y, 1, 1).data, r = _ref[0], g = _ref[1], b = _ref[2];
      return r << 16 | g << 8 | b;
    };

    Bitmap.prototype.filter = function() {
      var filter, filters, imageData, _i, _len;

      filters = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      imageData = this.getPixels();
      for (_i = 0, _len = filters.length; _i < _len; _i++) {
        filter = filters[_i];
        filter.run(imageData);
      }
      return this.setPixels(imageData);
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
      return this._context.miterLimit = miterLimit;
    };

    Bitmap.prototype.beginFill = function(color, alpha) {
      if (color == null) {
        color = 0;
      }
      if (alpha == null) {
        alpha = 1;
      }
      return this._context.fillStyle = Color.toCSSString(color, alpha);
    };

    Bitmap.prototype.endFill = function() {
      this._context.closePath();
      return this._context.fillStyle = 'rgba(0,0,0,0)';
    };

    Bitmap.prototype.moveTo = function(x, y) {
      return this._context.moveTo(x, y);
    };

    Bitmap.prototype.lineTo = function(x, y) {
      return this._context.lineTo(x, y);
    };

    Bitmap.prototype.drawRect = function(x, y, width, height) {
      this._context.beginPath();
      this._context.rect(x, y, width, height);
      this._context.closePath();
      return this._render();
    };

    Bitmap.prototype.drawCircle = function(x, y, radius, clockwise) {
      this._context.beginPath();
      this._context.moveTo(x + radius, y);
      this._context.arc(x, y, radius, 0, Bitmap._PI_2, clockwise < 0);
      this._context.closePath();
      return this._render();
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
      return this.drawPath([GraphicsPathCommand.MOVE_TO, GraphicsPathCommand.CUBIC_CURVE_TO, GraphicsPathCommand.CUBIC_CURVE_TO, GraphicsPathCommand.CUBIC_CURVE_TO, GraphicsPathCommand.CUBIC_CURVE_TO], [x + width, y, x + width, y + handleHeight, x + handleWidth, y + height, x, y + height, x - handleWidth, y + height, x - width, y + handleHeight, x - width, y, x - width, y - handleHeight, x - handleWidth, y - height, x, y - height, x + handleWidth, y - height, x + width, y - handleHeight, x + width, y], clockwise);
    };

    Bitmap.prototype.curveTo = function(x1, y1, x2, y2) {
      return this._context.quadraticCurveTo(x1, y1, x2, y2);
    };

    Bitmap.prototype.cubicCurveTo = function(x1, y1, x2, y2, x3, y3) {
      return this._context.bezierCurveTo(x1, y1, x2, y2, x3, y3);
    };

    Bitmap.prototype.drawPath = function(commands, data, clockwise) {
      var command, i, _i, _len;

      if (clockwise == null) {
        clockwise = 0;
      }
      this._context.beginPath();
      i = 0;
      for (_i = 0, _len = commands.length; _i < _len; _i++) {
        command = commands[_i];
        switch (command) {
          case GraphicsPathCommand.MOVE_TO:
            this._context.moveTo(data[i++], data[i++]);
            break;
          case GraphicsPathCommand.LINE_TO:
            this._context.lineTo(data[i++], data[i++]);
            break;
          case GraphicsPathCommand.CURVE_TO:
            this._context.quadraticCurveTo(data[i++], data[i++], data[i++], data[i++]);
            break;
          case GraphicsPathCommand.CUBIC_CURVE_TO:
            this._context.bezierCurveTo(data[i++], data[i++], data[i++], data[i++], data[i++], data[i++]);
        }
      }
      this._context.closePath();
      return this._render();
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

    Bitmap.prototype.drawLine = function(points) {
      var commands, data, point, _i, _len;

      commands = [];
      data = [];
      for (_i = 0, _len = points.length; _i < _len; _i++) {
        point = points[_i];
        commands.push(GraphicsPathCommand.LINE_TO);
        data.push(point.x, point.y);
      }
      return this.drawPath(commands, data);
    };

    Bitmap.prototype.drawSpline = function(points, interpolation) {
      var closed, commands, data, i, iLen, j, jLen, p0, p1, p2, p3, pointsLength, _i, _j;

      if (interpolation == null) {
        interpolation = 10;
      }
      commands = [];
      data = [];
      closed = points[0].equals(points[points.length - 1]);
      pointsLength = points.length;
      jLen = closed ? pointsLength : pointsLength - 1;
      iLen = interpolation;
      for (j = _i = 0; _i < jLen; j = _i += 1) {
        p0 = points[this._normalizeIndex(j - 1, pointsLength, closed)];
        p1 = points[this._normalizeIndex(j, pointsLength, closed)];
        p2 = points[this._normalizeIndex(j + 1, pointsLength, closed)];
        p3 = points[this._normalizeIndex(j + 2, pointsLength, closed)];
        if (j === jLen - 1) {
          iLen = closed ? 1 : interpolation + 1;
        }
        for (i = _j = 0; _j < iLen; i = _j += 1) {
          commands.push(GraphicsPathCommand.LINE_TO);
          data.push(this._interpolateSpline(p0.x, p1.x, p2.x, p3.x, i / interpolation), this._interpolateSpline(p0.y, p1.y, p2.y, p3.y, i / interpolation));
        }
      }
      commands[0] = GraphicsPathCommand.MOVE_TO;
      return this.drawPath(commands, data);
    };

    Bitmap.prototype._normalizeIndex = function(index, pointsLength, closed) {
      if (!closed) {
        if (index < 0) {
          return 0;
        } else if (index >= pointsLength) {
          return pointsLength - 1;
        } else {
          return index;
        }
      } else {
        if (index < 0) {
          return pointsLength - 1 + index;
        } else if (index >= pointsLength) {
          return 1 + (index - pointsLength);
        } else {
          return index;
        }
      }
    };

    Bitmap.prototype._interpolateSpline = function(p0, p1, p2, p3, t) {
      var t2, t3;

      t2 = t * t;
      t3 = t2 * t;
      return 0.5 * (-p0 + 3 * p1 - 3 * p2 + p3) * t3 + 0.5 * (2 * p0 - 5 * p1 + 4 * p2 - p3) * t2 + 0.5 * (-p0 + p2) * t + p1;
    };

    Bitmap.prototype._render = function() {
      this._context.fill();
      return this._context.stroke();
    };

    return Bitmap;

  })(sc.ript.display.DisplayObject);

  sc.ript.display.GraphicsPathCommand = (function() {
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

  sc.ript.display.JointStyle = (function() {
    function JointStyle() {}

    JointStyle.BEVEL = 'bevel';

    JointStyle.MITER = 'miter';

    JointStyle.ROUND = 'round';

    return JointStyle;

  })();

  sc.ript.event.Event = (function() {
    function Event(type, data) {
      this.type = type;
      this.data = data;
    }

    return Event;

  })();

  sc.ript.event.EventEmitter = (function() {
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

  sc.ript.filter.Filter = (function() {
    function Filter(quality) {
      this.quality = quality != null ? quality : 1;
    }

    Filter.prototype.run = function(imageData) {
      var data, height, i, p, pixels, q, width, x, y, _i, _j, _results;

      width = imageData.width, height = imageData.height, data = imageData.data;
      pixels = [];
      i = 0;
      for (y = _i = 0; _i < height; y = _i += 1) {
        pixels[y] = [];
        for (x = _j = 0; _j < width; x = _j += 1) {
          pixels[y][x] = [data[i], data[i + 1], data[i + 2], data[i + 3]];
          i += 4;
        }
      }
      pixels;
      q = this.quality;
      _results = [];
      while (q--) {
        i = 0;
        _results.push((function() {
          var _k, _results1;

          _results1 = [];
          for (y = _k = 0; _k < height; y = _k += 1) {
            _results1.push((function() {
              var _l, _results2;

              _results2 = [];
              for (x = _l = 0; _l < width; x = _l += 1) {
                p = pixels[y][x] = this._evaluatePixel(pixels, x, y, width, height);
                data[i] = p[0];
                data[i + 1] = p[1];
                data[i + 2] = p[2];
                data[i + 3] = p[3];
                _results2.push(i += 4);
              }
              return _results2;
            }).call(this));
          }
          return _results1;
        }).call(this));
      }
      return _results;
    };

    Filter.prototype._evaluatePixel = function(pixels, x, y, width, height) {
      return pixels[y][x];
    };

    Filter.prototype._getPixel = function(pixels, x, y, width, height) {
      x = x < 0 ? 0 : x > width - 1 ? width - 1 : x;
      y = y < 0 ? 0 : y > height - 1 ? height - 1 : y;
      return pixels[y][x];
    };

    return Filter;

  })();

  sc.ript.filter.ColorMatrixFilter = (function(_super) {
    __extends(ColorMatrixFilter, _super);

    function ColorMatrixFilter(matrix) {
      this.matrix = matrix;
      ColorMatrixFilter.__super__.constructor.call(this);
    }

    ColorMatrixFilter.prototype._evaluatePixel = function(pixels, x, y, width, height) {
      var a, b, g, m, r, _ref;

      m = this.matrix;
      _ref = pixels[y][x], r = _ref[0], g = _ref[1], b = _ref[2], a = _ref[3];
      return [r * m[0] + g * m[1] + b * m[2] + a * m[3] + m[4], r * m[5] + g * m[6] + b * m[7] + a * m[8] + m[9], r * m[10] + g * m[11] + b * m[12] + a * m[13] + m[14], r * m[15] + g * m[16] + b * m[17] + a * m[18] + m[19]];
    };

    return ColorMatrixFilter;

  })(sc.ript.filter.Filter);

  sc.ript.filter.KernelFilter = (function(_super) {
    __extends(KernelFilter, _super);

    function KernelFilter(radiusX, radiusY, kernel, quality, applyAlpha) {
      KernelFilter.__super__.constructor.call(this, quality);
      this._radiusX = radiusX;
      this._radiusY = radiusY;
      this._width = this._radiusX * 2 - 1;
      this._height = this._radiusY * 2 - 1;
      if (kernel.length !== this._width * this._height) {
        throw new TypeError('kernel length isn\'t match with radius');
      }
      this._applyAlpha = applyAlpha;
      this._kernel = kernel;
    }

    KernelFilter.prototype._evaluatePixel = function(pixels, x, y, width, height) {
      var pixel;

      pixel = [0, 0, 0, 0];
      this._runKernel(pixel, pixels, x, y, width, height);
      if (!this._applyAlpha) {
        pixel[3] = pixels[y][x][3];
      }
      return pixel;
    };

    KernelFilter.prototype._runKernel = function(pixel, pixels, x, y, width, height) {
      var absX, absY, amount, i, p, relX, relY, _i, _ref, _ref1, _results;

      i = 0;
      _results = [];
      for (relY = _i = _ref = 1 - this._radiusY, _ref1 = this._radiusY; _i < _ref1; relY = _i += 1) {
        absY = y + relY;
        _results.push((function() {
          var _j, _ref2, _ref3, _results1;

          _results1 = [];
          for (relX = _j = _ref2 = 1 - this._radiusX, _ref3 = this._radiusX; _j < _ref3; relX = _j += 1) {
            absX = x + relX;
            p = this._getPixel(pixels, absX, absY, width, height);
            amount = this._kernel[i];
            pixel[0] += p[0] * amount;
            pixel[1] += p[1] * amount;
            pixel[2] += p[2] * amount;
            pixel[3] += p[3] * amount;
            _results1.push(i++);
          }
          return _results1;
        }).call(this));
      }
      return _results;
    };

    return KernelFilter;

  })(sc.ript.filter.Filter);

  sc.ript.filter.BilateralFilter = (function(_super) {
    __extends(BilateralFilter, _super);

    BilateralFilter._SIGMA_8BIT = 2.04045;

    function BilateralFilter(radiusX, radiusY, threshold) {
      var gaussSpaceCoeff, kernel, relX, relY, sigmaColor, _i, _j, _ref, _ref1;

      if (radiusX == null) {
        radiusX = 2;
      }
      if (radiusY == null) {
        radiusY = 2;
      }
      if (threshold == null) {
        threshold = 0x20;
      }
      kernel = [];
      gaussSpaceCoeff = -0.5 / ((radiusX / BilateralFilter._SIGMA_8BIT) * (radiusY / BilateralFilter._SIGMA_8BIT));
      for (relY = _i = _ref = 1 - radiusY; _i < radiusY; relY = _i += 1) {
        for (relX = _j = _ref1 = 1 - radiusX; _j < radiusX; relX = _j += 1) {
          kernel.push(Math.exp((relX * relX + relY * relY) * gaussSpaceCoeff));
        }
      }
      BilateralFilter.__super__.constructor.call(this, radiusX, radiusY, kernel, 1, false);
      sigmaColor = threshold / 0xff * Math.sqrt(0xff * 0xff * 3) / BilateralFilter._SIGMA_8BIT;
      this._gaussColorCoeff = -0.5 / (sigmaColor * sigmaColor);
    }

    BilateralFilter.prototype._runKernel = function(pixel, pixels, x, y, width, height) {
      var absX, absY, center, db, dg, dr, i, p, relX, relY, totalWeight, weight, _i, _j, _ref, _ref1, _ref2, _ref3;

      center = this._getPixel(pixels, x, y, width, height);
      totalWeight = 0;
      i = 0;
      for (relY = _i = _ref = 1 - this._radiusY, _ref1 = this._radiusY; _i < _ref1; relY = _i += 1) {
        absY = y + relY;
        for (relX = _j = _ref2 = 1 - this._radiusX, _ref3 = this._radiusX; _j < _ref3; relX = _j += 1) {
          absX = x + relX;
          p = this._getPixel(pixels, absX, absY, width, height);
          dr = p[0] - center[0];
          dg = p[1] - center[1];
          db = p[2] - center[2];
          weight = this._kernel[i] * Math.exp((dr * dr + dg * dg + db * db) * this._gaussColorCoeff);
          totalWeight += weight;
          pixel[0] += p[0] * weight;
          pixel[1] += p[1] * weight;
          pixel[2] += p[2] * weight;
          i++;
        }
      }
      pixel[0] /= totalWeight;
      pixel[1] /= totalWeight;
      return pixel[2] /= totalWeight;
    };

    return BilateralFilter;

  })(sc.ript.filter.KernelFilter);

  sc.ript.filter.BlurFilter = (function(_super) {
    __extends(BlurFilter, _super);

    function BlurFilter(radiusX, radiusY, quality) {
      var invert, kernel, length, side;

      side = radiusX * 2 - 1;
      length = side * side;
      invert = 1 / length;
      kernel = [];
      while (length--) {
        kernel.push(invert);
      }
      console.log(radiusX, radiusY, kernel);
      BlurFilter.__super__.constructor.call(this, radiusX, radiusY, kernel, quality, true);
    }

    return BlurFilter;

  })(sc.ript.filter.KernelFilter);

  sc.ript.filter.GaussianBlurFilter = (function(_super) {
    __extends(GaussianBlurFilter, _super);

    function GaussianBlurFilter(radiusX, radiusY, sigma) {
      var dx, dy, i, kernel, s, w, weight, _i, _j, _k, _ref, _ref1, _ref2;

      if (sigma == null) {
        sigma = 0.84089642;
      }
      s = 2 * sigma * sigma;
      weight = 0;
      kernel = [];
      for (dy = _i = _ref = 1 - radiusY; _i < radiusY; dy = _i += 1) {
        for (dx = _j = _ref1 = 1 - radiusX; _j < radiusX; dx = _j += 1) {
          w = 1 / (s * Math.PI) * Math.exp(-(dx * dx + dy * dy) / s);
          weight += w;
          kernel.push(w);
        }
      }
      for (i = _k = 0, _ref2 = kernel.length; _k < _ref2; i = _k += 1) {
        kernel[i] /= weight;
      }
      GaussianBlurFilter.__super__.constructor.call(this, radiusX, radiusY, kernel, 1, true);
    }

    return GaussianBlurFilter;

  })(sc.ript.filter.KernelFilter);

  sc.ript.filter.ThresholdFilter = (function(_super) {
    __extends(ThresholdFilter, _super);

    function ThresholdFilter(threshold, operation) {
      this.threshold = threshold;
      this.operation = operation;
      ThresholdFilter.__super__.constructor.call(this);
    }

    ThresholdFilter.prototype._evaluatePixel = function(pixels, x, y, width, height) {
      var a, b, color, g, r, _ref;

      _ref = pixels[y][x], r = _ref[0], g = _ref[1], b = _ref[2], a = _ref[3];
      color = a << 24 | r << 16 | g << 8 | b;
      switch (this.operation) {
        case "<":
          color = color < this.threshold ? color : 0;
          break;
        case "<=":
          color = color <= this.threshold ? color : 0;
          break;
        case ">":
          color = color > this.threshold ? color : 0;
          break;
        case ">=":
          color = color >= this.threshold ? color : 0;
          break;
        case "==":
          color = color === this.threshold ? color : 0;
          break;
        case "!=":
          color = color !== this.threshold ? color : 0;
      }
      return [color >> 16 & 0xff, color >> 8 & 0xff, color & 0xff, color >> 24 & 0xff];
    };

    return ThresholdFilter;

  })(sc.ript.filter.Filter);

  sc.ript.geom.Matrix = (function() {
    function Matrix(m11, m12, m21, m22, tx, ty) {
      this.m11 = m11 != null ? m11 : 1;
      this.m12 = m12 != null ? m12 : 0;
      this.m21 = m21 != null ? m21 : 0;
      this.m22 = m22 != null ? m22 : 1;
      this.tx = tx != null ? tx : 0;
      this.ty = ty != null ? ty : 0;
    }

    Matrix.prototype.translate = function(x, y) {
      if (x == null) {
        x = 0;
      }
      if (y == null) {
        y = 0;
      }
      this.concat(new Matrix(1, 0, 0, 1, x, y));
      return this;
    };

    Matrix.prototype.scale = function(x, y) {
      if (x == null) {
        x = 1;
      }
      if (y == null) {
        y = 1;
      }
      this.concat(new Matrix(x, 0, 0, y, 0, 0));
      return this;
    };

    Matrix.prototype.rotate = function(theta) {
      var c, s;

      s = Math.sin(theta);
      c = Math.cos(theta);
      this.concat(new Matrix(c, s, -s, c, 0, 0));
      return this;
    };

    Matrix.prototype.concat = function(matrix) {
      var m11, m12, m21, m22, tx, ty;

      m11 = this.m11, m12 = this.m12, m21 = this.m21, m22 = this.m22, tx = this.tx, ty = this.ty;
      this.m11 = m11 * matrix.m11 + m12 * matrix.m21;
      this.m12 = m11 * matrix.m12 + m12 * matrix.m22;
      this.m21 = m21 * matrix.m11 + m22 * matrix.m21;
      this.m22 = m21 * matrix.m12 + m22 * matrix.m22;
      this.tx = tx * matrix.m11 + ty * matrix.m21 + matrix.tx;
      this.ty = tx * matrix.m12 + ty * matrix.m22 + matrix.ty;
      return this;
    };

    Matrix.prototype.invert = function() {
      var d, m11, m12, m21, m22, tx, ty;

      m11 = this.m11, m12 = this.m12, m21 = this.m21, m22 = this.m22, tx = this.tx, ty = this.ty;
      d = m11 * m22 - m12 * m21;
      this.m11 = m22 / d;
      this.m12 = -m12 / d;
      this.m21 = -m21 / d;
      this.m22 = m11 / d;
      this.m41 = (m21 * ty - m22 * tx) / d;
      this.m42 = (m12 * tx - m11 * ty) / d;
      return this;
    };

    return Matrix;

  })();

  sc.ript.geom.Point = (function() {
    Point.equals = function(pt0, pt1) {
      return pt0.equals(pt1);
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

    Point.inflate = function(src, dst, pixel) {
      var d, dx, dy, ratio;

      dx = src.x - dst.x;
      dy = src.y - dst.y;
      d = Math.sqrt(dx * dx + dy * dy);
      ratio = 1 + pixel / d;
      return this.interpolate(src, dst, ratio);
    };

    function Point(x, y) {
      if (x == null) {
        x = 0;
      }
      if (y == null) {
        y = 0;
      }
      this.x = +x;
      this.y = +y;
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

    Point.prototype.equals = function(pt) {
      return this.x === pt.x && this.y === pt.y;
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

  sc.ript.geom.Rectangle = (function() {
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

  sc.ript.path = (function() {
    function path() {}

    path.join = function() {
      var last, normalized, path, pathes, _i, _len;

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

  sc.ript.serializer.QueryString = (function() {
    var Type;

    function QueryString() {}

    Type = sc.ript.util.Type;

    QueryString.stringify = function(obj, sep, eq) {
      var key, kvs, val;

      if (sep == null) {
        sep = '&';
      }
      if (eq == null) {
        eq = '=';
      }
      kvs = [];
      for (key in obj) {
        val = obj[key];
        kvs.push("" + key + eq + val);
      }
      return kvs.join(sep);
    };

    QueryString.parse = function(str, sep, eq, _arg) {
      var i, k, kv, maxKeys, obj, v, _i, _len, _ref, _ref1;

      if (sep == null) {
        sep = '&';
      }
      if (eq == null) {
        eq = '=';
      }
      maxKeys = (_arg != null ? _arg : {}).maxKeys;
      if (maxKeys == null) {
        maxKeys = 1000;
      }
      obj = {};
      _ref = str.split(sep);
      for (i = _i = 0, _len = _ref.length; _i < _len; i = ++_i) {
        kv = _ref[i];
        if (maxKeys !== 0 && i > maxKeys) {
          break;
        }
        _ref1 = kv.split(eq), k = _ref1[0], v = _ref1[1];
        if (obj[k] != null) {
          if (Type.isArray(obj[k])) {
            obj[k].push(v);
          } else {
            obj[k] = [obj[k], v];
          }
        } else {
          obj[k] = v;
        }
      }
      return obj;
    };

    return QueryString;

  })();

  sc.ript.util.ByteArray = (function() {
    function ByteArray() {}

    ByteArray.BlobBuilder = window.BlobBuilder || window.WebKitBlobBuilder || window.MozBlobBuilder || window.MSBlobBuilder;

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
        bb = new this.BlobBuilder;
        bb.append(ia.buffer);
        return bb.getBlob(mimeString);
      } else if (window.Blob != null) {
        return new Blob([ab], {
          type: mimeString
        });
      }
    };

    return ByteArray;

  })();

  sc.ript.util.Iterator = (function() {
    function Iterator() {}

    Iterator.count = function(len, callback, step) {
      var i;

      if (step == null) {
        step = 1;
      }
      if (step === 0 || len <= 0) {
        return;
      }
      if (step > 0) {
        i = 0;
        while (i < len) {
          if (callback(i) === false) {
            return;
          }
          i += step;
        }
      } else {
        i = len;
        while ((i += step) >= 0) {
          if (callback(i) === false) {
            return;
          }
        }
      }
    };

    return Iterator;

  })();

  sc.ript.util.NumberUtil = (function() {
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

    NumberUtil.toSplit3String = function(value) {
      var tmp;

      value = "" + value;
      while (value !== (tmp = value.replace(/^([+-]?\d+)(\d\d\d)/, '$1,$2'))) {
        value = tmp;
      }
      return value;
    };

    NumberUtil.digitAt = function(num, digit) {
      var str;

      str = "" + num;
      if (digit < 0 || digit >= str.length) {
        return 0;
      }
      return +str.substr(-(digit + 1), 1);
    };

    NumberUtil.digits = function(num) {
      return ("" + num).length;
    };

    return NumberUtil;

  })();

  sc.ript.util.StringUtil = (function() {
    function StringUtil() {}

    return StringUtil;

  })();

  sc.ript.util.Type = (function() {
    var hasOwnProperty, toString, _ref;

    function Type() {}

    _ref = Object.prototype, toString = _ref.toString, hasOwnProperty = _ref.hasOwnProperty;

    Type.isElement = function(value) {
      return (value != null ? value.nodeType : void 0) === 1;
    };

    Type.isArray = Array.isArray || function(value) {
      return toString.call(value) === '[object Array]';
    };

    Type.isArguments = (function() {
      var isArguments;

      isArguments = function(value) {
        return toString.call(value) === "[object Arguments]";
      };
      if (isArguments(arguments)) {
        return isArguments;
      } else {
        return function(value) {
          return (value != null) && hasOwnProperty.call(value, 'callee');
        };
      }
    })();

    Type.isFunction = (function() {
      if (typeof /./ === 'function') {
        return function(value) {
          return toString.call(value) === "[object Function]";
        };
      } else {
        return function(value) {
          return typeob(value === 'function');
        };
      }
    })();

    Type.isString = function(value) {
      return toString.call(value) === "[object String]";
    };

    Type.isNumber = function(value) {
      return toString.call(value) === "[object Number]";
    };

    Type.isDate = function(value) {
      return toString.call(value) === "[object Date]";
    };

    Type.isRegExp = function(value) {
      return toString.call(value) === "[object RegExp]";
    };

    Type.isFinite = function(value) {
      return isFinite(value) && !isNaN(parseFloat(value));
    };

    Type.isNaN = function(value) {
      return this.isNumber(value) && value !== +value;
    };

    Type.isBoolean = function(value) {
      return value === true || value === false || toString.call(value) === "[object Boolean]";
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

}).call(this);

/*
//@ sourceMappingURL=sc.ript-0.0.3.map
*/