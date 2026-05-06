#!/usr/bin/env ruby

def isdigit(c)
  c.ord.between?('0'.ord, '9'.ord)
end

def skip_spaces(input, pos)
  pos += 1 while pos < input.length && (input[pos] == ' ' || input[pos] == "\n")
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
  while pos < input.length && input[pos] != ' ' && input[pos] != "\n"
    s += input[pos]
    pos += 1
  end
  return s.to_sym, pos
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

# Receives binary op function and convert it into function which
# receives list arguments.
def compfunc(test)
  lambda do |args|
    for i in 0..args.length-2 do
      return nil if not test.call(args[i], args[i+1])
    end
    return :t
  end
end

class Env
  # @param init - Hash from symbol to lisp value.
  def initialize(init = {})
    @v = init
  end

  def defined?(sym)
    @v.has_key? sym
  end

  def find(sym)
    @v[sym]
  end
end

def functions
  Env.new({
    :+ => ->(args) { args.sum },
    :- => lambda do |args|
      return -1 * args[0] if args.length == 1
      args[0] - args[1..].sum
    end,
    :* => ->(args) { args.reduce(:*) },
    :/ => lambda do |args|
      res = args[0]
      args[1..].each do |arg|
        res /= arg
      end
      res
    end,
    :< => compfunc(->(a, b) { a < b }),
    :> => compfunc(->(a, b) { a > b }),
    :<= => compfunc(->(a, b) { a <= b }),
    :>= => compfunc(->(a, b) { a >= b }),
    :== => compfunc(->(a, b) { a == b }),
  })
end

def eval(env, value)
  if value.is_a? Integer
    return value
  end

  if value.is_a? Array
    args = value[1..].map { |arg| eval(env, arg) }
    f = env.find(value[0])
    return f.call(args) if !f.nil?
  end

  return :t if value.is_a? Symbol and value == :t
  return nil if value.is_a? Symbol and value == :nil

  raise "unexpected value: #{value}"
end

def print(value)
  if value.nil?
    puts "nil"
    return
  end

  puts value
end

line = gets
value, pos = parse(line, 0)
env = functions
result = eval(env, value)
print result
