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
  while pos < input.length && input[pos] != ' ' && input[pos] != "\n" && input[pos] != ')'
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

  def defparameter(sym, val)
    @v[sym] = val
  end
end

def initial_env
  Env.new({
    :t => :t,
    :nil => nil,
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
    # progn special form
    if value[0] == :progn
      res = nil
      value[1..].each do |v|
        res = eval(env, v)
      end
      return res
    end

    # defun special form
    if value[0] == :defun
      name = value[1]
      args = value[2]
      raise "defun: the second argument is not a list" unless args.is_a? Array
      raise "defun: arguments are not implemented" if 0 < args.length
      raise "defun: multiple bodies are not implemented" if 4 < value.length
      body = value[3]
      env.defparameter(name, ->() { eval(env, body) })
      return nil
    end

    args = value[1..].map { |arg| eval(env, arg) }
    f = env.find(value[0])
    if !f.nil?
      return f.call(args) if 0 < args.length
      return f.call()
    end
  end

  return env.find(value) if env.defined? value

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
result = eval(initial_env, value)
print result
