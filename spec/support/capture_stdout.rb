require 'stringio'

def capture_stdout
  captured_output = StringIO.new
  real_stdout = $stdout
  $stdout = captured_output
  yield
  captured_output.string
ensure
  $stdout = real_stdout
end
