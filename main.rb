#!/usr/bin/env ruby

def isdigit(c)
  c.ord.between?('0'.ord, '9'.ord)
end

def skip_spaces(input, pos)
  pos += 1 while input[pos] == ' '
  return pos
end

def parse_int(input, pos)
  s = ''
  while isdigit(input[pos]) do
    s += input[pos]
    pos += 1
  end
  return s.to_i, pos
end

def parse_list(input, pos)
  list = []
  # input[pos] Must be '('
  pos += 1

  while input[pos] != ')' do
    pos = skip_spaces(input, pos)
    parsed, pos = parse(input, pos)
    list << parsed
  end
  return list, pos+1
end

def parse_symbol(input, pos)
  pos = skip_spaces(input, pos)
  s = ''
  while input[pos] != ' '
    s += input[pos]
    pos += 1
  end
  return s, pos
end

def parse(input, pos)
  return nil, pos if input.length <= pos

  pos = skip_spaces(input, pos)
  c = input[pos]

  if isdigit(c)
    v, pos = parse_int(input, pos)
    return v, pos
  end

  if c == '('
    return parse_list(input, pos)
  end

  return parse_symbol(input, pos)
end

def eval(value)
  if value.is_a? Integer
    return value
  end

  if value.is_a? Array
    return value[1..].sum if value[0] == '+'
    return value[1..].reduce(:*) if value[0] == '*'
  end

  raise "unexpected value: #{value}"
end

line = gets
value, pos = parse(line, 0)
result = eval(value)
puts result
