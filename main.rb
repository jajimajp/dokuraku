#!/usr/bin/env ruby

def isdigit(c)
  c.ord.between?('0'.ord, '9'.ord)
end

def parse_int(input, pos)
  s = ''
  while isdigit(input[pos]) do
    s += input[pos]
    pos += 1
  end
  return s.to_i, pos
end

def parse(input, pos)
  c = input[pos]

  if isdigit(c)
    v, pos = parse_int(input, pos)
    return v
  end

  return parse(input, pos+1)
end

line = gets
value = parse(line, 0)
puts value
