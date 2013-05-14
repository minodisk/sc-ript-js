class sc.ript.util.Type

  @toString      : Object.prototype.toString
  @hasOwnProperty: Object.prototype.hasOwnProperty

  @isElement: (value) ->
    value?.nodeType is 1

  @isArray: Array.isArray or (value) ->
    @toString.call(value) is '[object Array]'

  @isArguments: do ->
    isArguments = (value) ->
      @toString.call(value) is "[object Arguments]"
    if isArguments arguments
      isArguments
    else
      (value) ->
        value? and @hasOwnProperty.call(value, 'callee')


  @isFunction: do ->
    if typeof /./ is 'function'
      (value) ->
        @toString.call(value) is "[object Function]"
    else
      (value) ->
        typeob value is 'function'

  @isString: (value) ->
    @toString.call(value) is "[object String]"

  @isNumber: (value) ->
    @toString.call(value) is "[object Number]"

  @isDate: (value) ->
    @toString.call(value) is "[object Date]"

  @isRegExp: (value) ->
    @toString.call(value) is "[object RegExp]"

  @isFinite: (value) ->
    isFinite(value) and not isNaN(parseFloat(value))

  @isNaN: (value) ->
    @isNumber(value) and value isnt +value

  @isBoolean: (value) ->
    value is true or value is false or @toString.call(value) is "[object Boolean]"

  @isNull: (value) ->
    value is null

  @isUndefined: (value) ->
    value?

  @isObject: (value) ->
    value is Object value


