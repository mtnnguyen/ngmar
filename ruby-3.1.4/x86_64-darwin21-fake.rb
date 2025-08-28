# frozen_string_literal: true
# shareable_constant_value: literal
baseruby="/usr/bin/ruby --disable=gems"
_\
=begin
_=
ruby="${RUBY-$baseruby}"
case "$ruby" in "echo "*) $ruby; exit $?;; esac
case "$0" in /*) r=-r"$0";; *) r=-r"./$0";; esac
exec $ruby "$r" "$@"
=end
=baseruby
class Object
  remove_const :CROSS_COMPILING if defined?(CROSS_COMPILING)
  CROSS_COMPILING = RUBY_PLATFORM
  constants.grep(/^RUBY_/) {|n| remove_const n}
  RUBY_VERSION = "3.1.4"
  RUBY_RELEASE_DATE = "2023-03-30"
  RUBY_PLATFORM = "x86_64-darwin21"
  RUBY_PATCHLEVEL = 223
  RUBY_REVISION = "957bb7cb81995f26c671afce0ee50a5c660e540e"
  RUBY_COPYRIGHT = "ruby - Copyright (C) 1993-2023 Yukihiro Matsumoto"
  RUBY_ENGINE = "ruby"
  RUBY_ENGINE_VERSION = "3.1.4"
  RUBY_DESCRIPTION = RubyVM.const_defined?(:JIT) && RubyVM::MJIT.enabled? ?
    nil :
    "ruby 3.1.4p223 (2023-03-30 revision 957bb7cb81) [x86_64-darwin21]"
end
builddir = File.dirname(File.expand_path(__FILE__))
srcdir = "."
top_srcdir = File.realpath(srcdir, builddir)
fake = File.join(top_srcdir, "tool/fake.rb")
eval(File.binread(fake), nil, fake)
ropt = "-r#{__FILE__}"
["RUBYOPT"].each do |flag|
  opt = ENV[flag]
  opt = opt ? ([ropt] | opt.b.split(/\s+/)).join(" ") : ropt
  ENV[flag] = opt
end
