#!/usr/bin/env ruby

def t
  :T
end

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

class Cons
  attr_reader :l, :r

  def self.is_cons(value)
    value.is_a?(Cons)
  end

  def initialize(l, r)
    @l = l
    @r = r
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
  return s.upcase.to_sym
end

def parse_char(input)
  # This assumes that input.c is on '\' (not on '#')

  # input.c must be '\'
  input.readc

  c = input.c
  input.readc

  # Maybe #\Newline
  if c == 'N'
    # Determine by the 2nd character.
    # If it is true, the rest must be 'wline'
    if input.c == 'e'
      ('Newline'.length - 'N'.length).times do
        input.readc
      end
    end
    return Char.new("\n")
  end
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
    input.readc
    if input.c == "'"
      # NOTE: In this interpreter, functions and variables are put in the same
      # environment. This does not become a problem unless the same name used
      # for both variables and functions.
      input.readc
      return parse_symbol(input)
    else
      return parse_char(input)
    end
  end

  if input.c == "'"
    input.readc
    quoted = parse(input)
    return [:QUOTE, quoted]
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
    return t
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

  def setq(sym, val)
    raise "setq: variable not defined: #{sym}" unless has? sym
    if @v.has_key?(sym)
      @v[sym] = val
      return
    end
    @fallback.setq(sym, val)
  end

  def to_s
    @v.to_s
  end
end

def princ(v)
  if Char.is_char v
    print v.value
    return
  end
  if Cons.is_cons v
    print '('
    princ v.l
    if v.r.nil?
      print ')'
    else
      print ' . '
      princ v.r
      print ')'
    end
    return
  end
  print v
end

def concatenate(args)
  raise "concatenate: other than string is not supported" unless args[0] == :STRING

  s = ""
  v = args[1]
  while Cons.is_cons v
    raise "concatenate: not a char: #{v.l}" unless Char.is_char v.l
    s += v.l.value
    v = v.r
  end
  s
end

def dest_list(ls)
  res = []
  while Cons.is_cons ls
    res << ls.l
    ls = ls.r
  end
  res
end

def initial_env
  Env.new({
    :T => t,
    :NIL => nil,
    :CONS => ->(args) { Cons.new(args[0], args[1]) },
    :CAR => lambda do |args|
      raise "car: given value is not a cons cell: #{args[0]}" unless Cons.is_cons args[0]
      args[0].l
    end,
    :CDR => lambda do |args|
      raise "cdr: given value is not a cons cell: #{args[0]}" unless Cons.is_cons args[0]
      args[0].r
    end,
    :CADR => lambda do |args|
      raise "cadr: given value is not a cons cell: #{args[0]}" unless Cons.is_cons args[0]
      cdr = args[0].r
      raise "cadr: given value is not a cons cell: #{cdr}" unless Cons.is_cons cdr
      cdr.l
    end,
    :CADDR => lambda do |args|
      raise "caddr: given value is not a cons cell: #{args[0]}" unless Cons.is_cons args[0]
      cdr = args[0].r
      raise "caddr: given value is not a cons cell: #{cdr}" unless Cons.is_cons cdr
      cddr = cdr.r
      raise "caddr: given value is not a cons cell: #{cddr}" unless Cons.is_cons cddr
      cddr.l
    end,
    :NOT => lambda do |args|
      if args[0].nil?
        t
      else
        nil
      end
    end,
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
    :"=" => compfunc(->(a, b) { a == b }),
    :CHAR= => compfunc(->(a, b) { a.value == b.value }),
    :"READ-CHAR" => lambda do |args|
      c = STDIN.getc
      return Char.new(c) unless c.nil?
      if args.length == 1 && args[0] == nil # nil specified
        return nil
      else
        raise "read-char: EOF"
      end
    end,
    :"WRITE-CHAR" => lambda do |args|
      raise "write-char: not a char: #{args[0]}" unless Char.is_char args[0]
      putc args[0].value
    end,
    :WRITE => lambda do |args|
      if Char.is_char args[0]
        putc args[0].value
        return
      end
      if args[0].is_a? String
        p args[0]
        return
      end
      if Cons.is_cons args[0]
        princ args[0]
        return
      end
      puts args
    end,
    :PRINC => lambda do |args|
      princ args[0]
    end,
    :NUMBERP => ->(args) { if args[0].is_a? Integer then t else nil end },
    :SYMBOLP => ->(args) { if args[0].is_a? Symbol then t else nil end },
    :CONSP => ->(args) { if Cons.is_cons args[0] then t else nil end },
    :"STRING-UPCASE" => ->(args) { args[0].upcase },
    :STRING => lambda do |args|
      return args[0].value.to_s if Char.is_char args[0]
      args[0].to_s
    end,
    # NOTE: This intern does much less than usual lisp interpreters do.
    :INTERN => ->(args) { args[0].to_sym },
    :CONCATENATE => ->(args) { concatenate(args) },
    :LIST => lambda do |args|
      res = nil
      args.reverse.each do |arg|
        res = Cons.new(arg, res)
      end
      res
    end,
    :APPLY => lambda do |args|
      f = args[0]
      f.call(dest_list args[1])
    end,
    :"MAKE-HASH-TABLE" => ->(args) { Hash.new },
    :GETHASH => lambda do |args|
      raise "gethash: not a hash: #{args[1]}" unless args[1].is_a? Hash
      args[1][args[0]]
    end,
    :PUTHASH => lambda do |args|
      raise "puthash: not a hash: #{args[2]}" unless args[2].is_a? Hash
      args[2][args[0]] = args[1]
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
    # quote special form
    if value[0] == :QUOTE
      return value[1]
    end

    # if special form
    if value[0] == :IF
      cond = eval(env, value[1])
      unless cond.nil?
        return eval(env, value[2]) # true clause
      end
      return eval(env, value[3]) # false clause
    end

    # cond special form
    if value[0] == :COND
      value[1..].each do |v|
        cond = eval(env, v[0])
        return eval(env, v[1]) unless cond.nil?
      end
      return nil
    end

    # progn special form
    if value[0] == :PROGN
      res = nil
      value[1..].each do |v|
        res = eval(env, v)
      end
      return res
    end

    # let special form
    if value[0] == :LET
      binds = value[1]
      raise "let: the first parameter is not a list" unless binds.is_a? Array
      raise "let: multiple bodies are not implemented" if 3 < value.length
      body = value[2]
      binds_ls = binds.map do |bind|
        v = eval(env, bind[1])
        [bind[0], v]
      end
      newenv = Env.new(binds_ls.to_h, env)
      return eval(newenv, body)
    end

    # defparameter special form
    if value[0] == :DEFPARAMETER
      k = value[1]
      v = eval(env, value[2])
      env.defparameter(k, v)
      return nil
    end

    # setq special form
    if value[0] == :SETQ
      k = value[1]
      v = eval(env, value[2])
      env.setq(k, v)
      return nil
    end

    # defun special form
    if value[0] == :DEFUN
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

    # lambda special form
    if value[0] == :LAMBDA
      arg_vars = value[1]
      raise "lambda: the first argument is not a list" unless arg_vars.is_a? Array
      raise "lambda: multiple bodies are not implemented" if 3 < value.length
      body = value[2]
      return lambda do |args|
        vars = arg_vars.zip(args).to_h
        newenv = Env.new(vars, env)
        eval(newenv, body)
      end
    end

    args = value[1..].map { |arg| eval(env, arg) }
    f = env.find(value[0])
    return f.call(args) if !f.nil?
    raise "eval: unknown symbol: #{value[0]}"
  end

  return env.find(value) if env.has? value

  raise "unexpected value: #{value}"
end

def print_value(value)
  if value.nil?
    print "nil"
    return
  end

  if Char.is_char value
    if value.value == "\n"
      print "\#\\Newline"
      return
    end
    print "\#\\#{value.value}"
    return
  end

  if Cons.is_cons value
    print '('
    print_value value.l
    if value.r.nil?
      print ')'
    else
      print ' . '
      print_value value.r
      print ')'
    end
    return
  end

  if value.is_a? String
    print "\"#{value}\""
    return
  end

  print value
end

print_value_enabled = false
file = ''
ARGV.each do |arg|
  if arg == '--print-value'
    print_value_enabled = arg
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
  if print_value_enabled
    print_value result
    puts ""
  end
end
