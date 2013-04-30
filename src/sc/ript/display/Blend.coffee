#package tc.ript.display

class Blend

  @_mix: (a, b, f) ->
    a + (((b - a) * f) >> 8)

  @_peg: (n) ->
    if n < 0 then 0 else if n > 255 then 255 else n

  @scan: (method, src, dst) ->
    method = Blend[method]
    throw new TypeError "#{ method } isn't defined." unless method?
    s = src.data
    d = dst.data
    for i in [0...d.length] by 4
      o = method d[i], d[i + 1], d[i + 2], d[i + 3], s[i], s[i + 1], s[i + 2], s[i + 3]
      d[i..i + 3] = o[0..3]
    dst

  @blend: (dr, dg, db, da, sr, sg, sb, sa) ->
    [
      Blend._mix dr, sr, sa
      Blend._mix dg, sg, sa
      Blend._mix db, sb, sa
      da + sa
    ]

  @add: (dr, dg, db, da, sr, sg, sb, sa) ->
    [
      dr + (sr * sa >> 8)
      dg + (sg * sa >> 8)
      db + (sb * sa >> 8)
      da + sa
    ]

  @subtract: (dr, dg, db, da, sr, sg, sb, sa) ->
    [
      dr - (sr * sa >> 8)
      dg - (sg * sa >> 8)
      db - (sb * sa >> 8)
      da + sa
    ]

  @darkest: (dr, dg, db, da, sr, sg, sb, sa) ->
    [
      Blend._mix dr, Math.min(dr, sr * sa >> 8), sa
      Blend._mix dg, Math.min(dg, sg * sa >> 8), sa
      Blend._mix db, Math.min(db, sb * sa >> 8), sa
      da + sa
    ]

  @lightest: (dr, dg, db, da, sr, sg, sb, sa) ->
    [
      Math.max dr, sr * sa >> 8
      Math.max dg, sg * sa >> 8
      Math.max db, sb * sa >> 8
      da + sa
    ]

  @difference: (dr, dg, db, da, sr, sg, sb, sa) ->
    [
      Blend._mix dr, (if dr > sr then dr - sr else sr - dr), sa
      Blend._mix dg, (if dg > sg then dg - sg else sg - dg), sa
      Blend._mix db, (if db > sb then db - sb else sb - db), sa
      da + sa
    ]

  @exclusion: (dr, dg, db, da, sr, sg, sb, sa) ->
    [
      Blend._mix dr, dr + sr - (dr * sr >> 7), sa
      Blend._mix dg, dg + sg - (dg * sg >> 7), sa
      Blend._mix db, db + sb - (db * sb >> 7), sa
      da + sa
    ]

  @reflex: (dr, dg, db, da, sr, sg, sb, sa) ->
    [
      Blend._mix dr, (if sr is 0xff then sr else dr * dr / (0xff - sr)), sa
      Blend._mix dg, (if sg is 0xff then sg else dg * dg / (0xff - sg)), sa
      Blend._mix db, (if sb is 0xff then sb else db * db / (0xff - sb)), sa
      da + sa
    ]

  @multiply: (dr, dg, db, da, sr, sg, sb, sa) ->
    [
      Blend._mix dr, dr * sr >> 8, sa
      Blend._mix dg, dg * sg >> 8, sa
      Blend._mix db, db * sb >> 8, sa
      da + sa
    ]

  @screen: (dr, dg, db, da, sr, sg, sb, sa) ->
    [
      Blend._mix dr, 0xff - ((0xff - dr) * (0xff - sr) >> 8), sa
      Blend._mix dg, 0xff - ((0xff - dg) * (0xff - sg) >> 8), sa
      Blend._mix db, 0xff - ((0xff - db) * (0xff - sb) >> 8), sa
      da + sa
    ]

  @overlay: (dr, dg, db, da, sr, sg, sb, sa) ->
    [
      Blend._mix dr, (if dr < 0x80 then dr * sr >> 7 else 0xff - ((0xff - dr) * (0xff - sr) >> 7)), sa
      Blend._mix dg, (if dg < 0x80 then dg * sg >> 7 else 0xff - ((0xff - dg) * (0xff - sg) >> 7)), sa
      Blend._mix db, (if db < 0x80 then db * sb >> 7 else 0xff - ((0xff - db) * (0xff - sb) >> 7)), sa
      da + sa
    ]

  @softLight: (dr, dg, db, da, sr, sg, sb, sa) ->
    [
      Blend._mix dr, (dr * sr >> 7) + (dr * dr >> 8) - (dr * dr * sr >> 15), sa
      Blend._mix dg, (dg * sg >> 7) + (dg * dg >> 8) - (dg * dg * sg >> 15), sa
      Blend._mix db, (db * sb >> 7) + (db * db >> 8) - (db * db * sb >> 15), sa
      da + sa
    ]

  @hardLight: (dr, dg, db, da, sr, sg, sb, sa) ->
    [
      Blend._mix dr, (if sr < 0x80 then dr * sr >> 7 else 0xff - (((0xff - dr) * (0xff - sr)) >> 7)), sa
      Blend._mix dg, (if sg < 0x80 then dg * sg >> 7 else 0xff - (((0xff - dg) * (0xff - sg)) >> 7)), sa
      Blend._mix db, (if sb < 0x80 then db * sb >> 7 else 0xff - (((0xff - db) * (0xff - sb)) >> 7)), sa
      da + sa
    ]

  @vividLight: (dr, dg, db, da, sr, sg, sb, sa) ->
    [
      (
        if sr is 0 then 0
        else if sr is 0xff then 0xff
        else if sr < 0x80 then 0xff - Blend._peg(((0xff - dr) << 8) / (sr * 2))
        else Blend._peg((dr << 8) / ((0xff - sr) * 2))
      ),
      (
        if sg is 0 then 0
        else if sg is 0xff then 0xff
        else if sg < 0x80 then 0xff - Blend._peg(((0xff - dg) << 8) / (sg * 2))
        else Blend._peg((dg << 8) / ((0xff - sg) * 2))
      ),
      (
        if sb is 0 then 0
        else if sb is 0xff then 0xff
        else if sb < 0x80 then 0xff - Blend._peg(((0xff - db) << 8) / (sb * 2))
        else Blend._peg((db << 8) / ((0xff - sb) * 2))
      ),
      da + sa
    ]

  @linearLight: (dr, dg, db, da, sr, sg, sb, sa) ->
    [
      (
        if sr < 0x80 then Math.max(sr * 2 + dr - 0xff, 0)
        else Math.min(sr + dr, 0xff)
      ),
      (
        if sg < 0x80 then Math.max(sg * 2 + dg - 0xff, 0)
        else Math.min(sg + dg, 0xff)
      ),
      (
        if sb < 0x80 then Math.max(sb * 2 + db - 0xff, 0)
        else Math.min(sb + db, 0xff)
      ),
      da + sa
    ]

  @pinLight: (dr, dg, db, da, sr, sg, sb, sa) ->
    [
      (
        if sr < 0x80 then Math.min sr * 2, dr
        else Math.max (sr - 0x80) * 2, dr
      ),
      (
        if sg < 0x80 then Math.min sg * 2, dg
        else Math.max (sg - 0x80) * 2, dg
      ),
      (
        if sb < 0x80 then Math.min sb * 2, db
        else Math.max (sb - 0x80) * 2, db
      ),
      da + sa
    ]

  @hardMix: (dr, dg, db, da, sr, sg, sb, sa) ->
    r = (
      if sr is 0 then 0
      else if sr is 0xff then 0xff
      else if sr < 0x80 then 0xff - Blend._peg(((0xff - dr) << 8) / (sr * 2))
      else Blend._peg((dr << 8) / ((0xff - sr) * 2))
    )
    g = (
      if sg is 0 then 0
      else if sg is 0xff then 0xff
      else if sg < 0x80 then 0xff - Blend._peg(((0xff - dg) << 8) / (sg * 2))
      else Blend._peg((dg << 8) / ((0xff - sg) * 2))
    )
    b = (
      if sb is 0 then 0
      else if sb is 0xff then 0xff
      else if sb < 0x80 then 0xff - Blend._peg(((0xff - db) << 8) / (sb * 2))
      else Blend._peg((db << 8) / ((0xff - sb) * 2))
    )
    [
      if r < 0x80 then 0 else 0xff,
      if g < 0x80 then 0 else 0xff,
      if b < 0x80 then 0 else 0xff,
      da + sa
    ]

  @dodge: (dr, dg, db, da, sr, sg, sb, sa) ->
    [
      Blend._mix dr, Blend._peg((dr << 8) / (0xff - sr)), sa
      Blend._mix dg, Blend._peg((dg << 8) / (0xff - sg)), sa
      Blend._mix db, Blend._peg((db << 8) / (0xff - sb)), sa
      da + sa
    ]

  @burn: (dr, dg, db, da, sr, sg, sb, sa) ->
    [
      Blend._mix dr, (if sr is 0 then 0 else 0xff - Blend._peg(((0xff - dr) << 8) / sr)), sa
      Blend._mix dg, (if sg is 0 then 0 else 0xff - Blend._peg(((0xff - dg) << 8) / sg)), sa
      Blend._mix db, (if sb is 0 then 0 else 0xff - Blend._peg(((0xff - db) << 8) / sb)), sa
      da + sa
    ]

  @linearDodge: (dr, dg, db, da, sr, sg, sb, sa) ->
    [
      Blend._mix dr, Math.min(sr + dr, 0xff), sa
      Blend._mix dg, Math.min(dg + sg, 0xff), sa
      Blend._mix db, Math.min(db + sb, 0xff), sa
      da + sa
    ]

  @linearBurn: (dr, dg, db, da, sr, sg, sb, sa) ->
    [
      Blend._mix dr, Math.max(sr + dr - 0xff, 0), sa
      Blend._mix dg, Math.max(dg + sg - 0xff, 0), sa
      Blend._mix db, Math.max(db + sb - 0xff, 0), sa
      da + sa
    ]

  @punch: #do ->
#    if /Android/.test navigator.userAgent
#      (dr, dg, db, da, sr, sg, sb, sa) ->
#        [
#          dr
#          dg
#          db
#          if (da * Blend._peg(0xff - sa) / 0xff >> 0) > 0xf0 then 0xff else 0
#        ]
#    else
      (dr, dg, db, da, sr, sg, sb, sa) ->
        [
          dr
          dg
          db
          da * Blend._peg(0xff - sa) / 0xff >> 0
        ]

  @mask: #do ->
#    if /Android/.test navigator.userAgent
#      (dr, dg, db, da, sr, sg, sb, sa) ->
#        [
#          dr
#          dg
#          db
#          if da * sa / 0xff  > 0xf0 then 0xff else 0
#        ]
#    else
      (dr, dg, db, da, sr, sg, sb, sa) ->
        [
          dr
          dg
          db
          da * sa / 0xff >> 0
        ]


