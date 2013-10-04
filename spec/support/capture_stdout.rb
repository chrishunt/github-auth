require 'stringio'

def capture_stdout
  captured_output = StringIO.new
  real_stdout = $stdout
  $stdout = captured_output
  yield
ensure
  $stdout = real_stdout
  return captured_output.string
end
