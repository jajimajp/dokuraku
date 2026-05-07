#!/usr/bin/env ruby

class Input
  def initialize(stream = STDIN)
    @stream = stream
    @eof = nil
    readc
  end

  def readc
    @c = ''
    if @stream.eof?
      @eof = true
    else
      @c = @stream.getc
    end
  end

  def c
    # Current reading character.
    @c
  end

  def eof?
    @eof
  end
end

class Char
  def self.is_char(value)
    value.is_a?(Char)
  end

  # represents char as [:char, <string>]
  def initialize(c)
    raise "#{c} is not a string" unless c.is_a? String
    raise "the length is not 1: #{c} " unless c.length == 1
    @v = [:char, c]
  end

  def value
    @v[1]
  end
end

def isdigit(c)
  c.ord.between?('0'.ord, '9'.ord)
end

def skip_spaces(input)
  input.readc while !input.eof? && (input.c == ' ' || input.c == "\n")
end

def parse_int(input)
  s = ''
  while isdigit(input.c) do
    s += input.c
    input.readc
  end
  return s.to_i
end

def parse_list(input)
  list = []
  # input.c must be '('
  input.readc

  skip_spaces(input)
  while input.c != ')' do
    parsed = parse(input)
    list << parsed
    skip_spaces(input)
  end

  # input.c must be ')'
  input.readc

  return list
end

def parse_symbol(input)
  skip_spaces(input)
  s = ''
  while !input.eof? && input.c != ' ' && input.c != "\n" && input.c != ')'
    s += input.c
    input.readc
  end
  return s.to_sym
end

def parse_char(input)
  # input.c must be '#'
  input.readc
  # input.c must be '\'
  input.readc

  c = input.c
  input.readc
  return Char.new(c)
end

def parse_string(input)
  # input.c must be '"'
  input.readc

  s = ''
  while input.c != '"'
    s += input.c
    input.readc

    raise "parse_string: unexpeced EOF" if input.eof?
  end

  # input.c must be '"'
  input.readc
  return s
end

def consume_to_newline(input)
  while !input.eof? && input.c != "\n"
    input.readc
  end

  input.readc unless input.eof?
end

def parse(input)
  skip_spaces(input)

  return nil if input.eof?

  if input.c == ';'
    consume_to_newline(input)
    return parse(input)
  end

  if isdigit(input.c)
    v = parse_int(input)
    return v
  end

  if input.c == '('
    return parse_list(input)
  end

  if input.c == '"'
    return parse_string(input)
  end

  if input.c == '#'
    return parse_char(input)
  end

  return parse_symbol(input)
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
  def initialize(init = {}, fallback = nil)
    @v = init
    @fallback = fallback
  end

  def has?(sym)
    @v.has_key?(sym) || @fallback&.has?(sym)
  end

  def find(sym)
    return @v[sym] if @v.has_key?(sym)
    @fallback&.find sym
  end

  def defparameter(sym, val)
    if @fallback.nil? || has?(sym)
      @v[sym] = val
      return
    end
    @fallback.defparameter(sym, val)
  end

  def to_s
    @v.to_s
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
    :"read-char" => lambda do |args|
      c = STDIN.getc
      return Char.new(c) unless c.nil?
      if args.length == 1 && args[0] == nil # nil specified
        return nil
      else
        raise "read-char: EOF"
      end
    end,
    :"write-char" => lambda do |args|
      raise "write-char: not a char: #{args[0]}" unless Char.is_char args[0]
      putc args[0].value
    end,
    :write => lambda do |args|
      if Char.is_char args[0]
        putc args[0].value
        return
      end
      if args[0].is_a? String
        p args[0]
        return
      end
      puts args
    end,
    :princ => lambda do |args|
      if Char.is_char args[0]
        putc args[0].value
        return
      end
      puts args[0]
    end,
  })
end

def eval(env, value)
  if value.is_a? Integer
    return value
  end

  if Char.is_char value
    return value
  end

  if value.is_a? String
    return value
  end

  if value.is_a? Array
    # if special form
    if value[0] == :if
      cond = eval(env, value[1])
      unless cond.nil?
        return eval(env, value[2]) # true clause
      end
      return eval(env, value[3]) # false clause
    end

    # progn special form
    if value[0] == :progn
      res = nil
      value[1..].each do |v|
        res = eval(env, v)
      end
      return res
    end

    # defparameter special form
    if value[0] == :defparameter
      k = value[1]
      v = eval(env, value[2])
      env.defparameter(k, v)
      return nil
    end

    # defun special form
    if value[0] == :defun
      name = value[1]
      arg_vars = value[2]
      raise "defun: the second argument is not a list" unless arg_vars.is_a? Array
      raise "defun: multiple bodies are not implemented" if 4 < value.length
      body = value[3]
      env.defparameter(name, lambda do |args|
        vars = arg_vars.zip(args).to_h
        newenv = Env.new(vars, env)
        eval(newenv, body)
      end)
      return nil
    end

    args = value[1..].map { |arg| eval(env, arg) }
    f = env.find(value[0])
    return f.call(args) if !f.nil?
    raise "eval: unknown symbol: #{value[0]}"
  end

  return env.find(value) if env.has? value

  raise "unexpected value: #{value}"
end

def print(value)
  if value.nil?
    puts "nil"
    return
  end

  if Char.is_char value
    puts "\#\\#{value.value}"
    return
  end

  if value.is_a? String
    p value
    return
  end

  puts value
end

print_value = false
file = ''
ARGV.each do |arg|
  if arg == '--print-value'
    print_value = arg
    next
  end
  file = arg
end
input = if file == ''
  Input.new
else
  f = File.open(file, 'r')
  Input.new(f)
end

env = initial_env
loop do
  value = parse input
  break if value.nil?
  result = eval(env, value)
  print result if print_value
end
