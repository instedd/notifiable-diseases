@StringService =
  toSentence: (array, separator = ", ", last = " and ") ->
    str = ""
    len = array.length
    for elem, i in array
      if i > 0
        if i == len - 1
          str += last
        else
          str += separator
      str += elem
    str
