@Filters ?= {}

class @Filters.EnumFilter
  constructor: (field) ->
    @name = field.name
    @values = _.map field.options, 'value'
    @field = () -> field

  type: ->
    "enum"

  label: ->
    @field().label

  options: ->
    @field().options

  applyTo: (query) ->
    query[@name] = @values

    if @values.length == 0
      query.empty = true

  empty: ->
    @values.length == 0

  allSelected: ->
    @values.length == @field().options.length

  selectedDescription: ->
    if @values.length == 0
      "none"
    else if @values.length == @field().options.length
      "all"
    else if @values.length == 1
      @field().labelFor(@values[0])
    else
      "#{@values.length} selected"

  shortDescription: (first) ->
    if @values.length == 0
      label = @field().label.toLowerCase()
      if first
        "No #{label}"
      else
        "no #{label}"
    else
      labels = _.map(@values, (value) => "\"#{@field().labelFor(value)}\"")
      if labels.length == 3
        if labels[2].length <= "1 other".length
          "#{labels[0]}, #{labels[1]} or #{labels[2]}"
        else
          "#{labels[0]}, #{labels[1]} and 1 other"
      else if labels.length > 3
        "#{labels[0]}, #{labels[1]} and #{labels.length - 2} others"
      else
        StringService.toSentence(labels, ", ", " or ")

  toJSON: ->
    {
      name: @name
      values: @values
    }

  initializeFrom: (data) ->
    @values = data.values
    @

